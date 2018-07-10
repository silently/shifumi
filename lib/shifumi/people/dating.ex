defmodule Shifumi.People.Dating do
  @moduledoc """
  Manages players pool to create 2-players live games.

  A player can be in one of two cached pools:
  - *ready*: available to play/waiting
  - *busy*: not available/pausing

  A player may also be referenced as "leaving" if the client has disconnected. After 10 seconds, if the player is still "leaving", he is removed from the pool (both ready and busy), so that we do not keep too many data in the cache.

  Busy may mean (no need to segregate between those): currently playing, paused, browsing (for instance updating her avatar).

  Busy does *not* mean that the player is offline.

  This module helps create games:
  - with 2 available players,
  - DEPRECATED: where both players are *not* present in each other ongoing series of successive victories.

  This second DEPRECATED restriction was part of the gameplay (to avoid repetition) and also to avoid cheating (possibly high number of successive victories if one always win against the same opponent).

  Once a player loses, her history is reset.

  The internal state of this GenServer relies on three ETS tables:
  - both *ready* and *busy* holds tuples in the form `{"player_id", [opponents]}`
  - where `[opponents]` are ones with whom player_id has already fought and win within an ongoing series of successive victories
  - *leaving* holds tuples in the form `{"player_id", timer_ref}`
  -  where `timer_ref` is a reference to the delayed message that will lead to consider the player as being offline

  The internal state model (relying on these ETS tables) should be considered an implementation detail and may change in the future.
  """

  use GenServer

  @online_topic Shifumi.online_topic()
  @inactive_limit Shifumi.inactive_limit()

  @typep state :: {atom, atom, atom}

  #######
  # API #
  #######

  @doc """
  Starts the dating server
  """
  @spec start_link(keyword) :: GenServer.on_start()
  def start_link(opts \\ [name: __MODULE__]) do
    name = opts[:name]
    GenServer.start_link(__MODULE__, name, opts)
  end

  @doc """
  Search for an available partner

  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  @spec find_partner(GenServer.server(), binary) :: :waiting | binary
  def find_partner(server, player_id) do
    GenServer.call(server, {:find_partner, player_id})
  end

  @spec get_size(GenServer.server()) :: {integer, integer, integer}
  def get_size(server) do
    GenServer.call(server, :get_size)
  end

  @spec reset(GenServer.server()) :: :ok
  def reset(server) do
    GenServer.call(server, :reset)
  end

  @spec busy(GenServer.server(), binary) :: :ok
  def busy(server, player_id) do
    GenServer.cast(server, {:busy, player_id})
  end

  @spec log_defeat(GenServer.server(), binary) :: :ok
  def log_defeat(server, player_id) do
    GenServer.cast(server, {:log_defeat, player_id})
  end

  @spec log_tie(GenServer.server(), binary) :: :ok
  def log_tie(server, player_id) do
    GenServer.cast(server, {:log_tie, player_id})
  end

  #############
  # Callbacks #
  #############

  @doc """
  Initial state tuple with empty ready and busy maps
  """
  @spec init(:atom) :: {:ok, state}
  def init(name) do
    ShifumiWeb.Endpoint.subscribe(@online_topic)
    # HACK concat module name atoms to define table names relative to GenServer name
    ready = Module.concat(name, Ready)
    busy = Module.concat(name, Busy)
    leaving = Module.concat(name, Leaving)
    :ets.new(ready, [:named_table])
    :ets.new(busy, [:named_table])
    :ets.new(leaving, [:named_table])
    {:ok, {ready, busy, leaving}}
  end

  @doc """
  Manages presence_diff (thanks to the PubSub subscription in init/1) dealing with countdown leaving state.
  """
  @spec handle_info(Phoenix.Socket.Broadcast.t(), state) :: {:noreply, state}
  def handle_info(
        %Phoenix.Socket.Broadcast{
          event: "presence_diff",
          payload: payload,
          topic: @online_topic
        },
        {_, _, leaving} = state
      ) do
    joins = Map.get(payload, :joins, %{})
    leaves = Map.get(payload, :leaves, %{})

    Map.keys(joins)
    |> Enum.map(fn player_id ->
      case :ets.lookup(leaving, player_id) do
        [{^player_id, timer_ref}] ->
          # If player_id was in *leaving* table, cancel and drop the offline countdown
          Process.cancel_timer(timer_ref)
          :ets.delete(leaving, player_id)

        [] ->
          :nothing
      end
    end)

    Map.keys(leaves)
    |> Enum.map(fn player_id ->
      # Leaving players are moved to *busy* and a countdown is launched to have them being offline
      busy(self(), player_id)
      timer_ref = Process.send_after(self(), {:offline, player_id}, @inactive_limit)
      :ets.insert(leaving, {player_id, timer_ref})
    end)

    {:noreply, state}
  end

  @spec handle_info({:offline, binary}, state) :: {:noreply, state}
  def handle_info({:offline, player_id}, {ready, busy, leaving} = state) do
    :ets.delete(ready, player_id)
    :ets.delete(busy, player_id)
    :ets.delete(leaving, player_id)

    {:noreply, state}
  end

  @doc """
  Tries to find an available player who is not in *p1* history
  If one is found, players are added to each other history
  (and the one that loses will have his history reset)
  """
  @spec handle_call({:find_partner, binary}, GenServer.from(), state) ::
          {:reply, :waiting, state} | {:reply, binary, state}
  def handle_call(
        {:find_partner, p1_id},
        _from,
        {ready, busy, _leaving} = state
      ) do
    case :ets.lookup(ready, p1_id) do
      # duplicate :find_partner call
      [{^p1_id, _}] ->
        {:reply, :waiting, state}

      # Main path, p1_id was not "already ready"
      [] ->
        # Load series from busy ETS table or from DB
        p1_opponents_ids =
          case :ets.lookup(busy, p1_id) do
            [{^p1_id, opponents_ids}] -> opponents_ids
            [] -> Shifumi.Records.get_player_series(p1_id) || []
          end

        opponent_id = :ets.first(ready)

        case :ets.lookup(ready, opponent_id) do
          # p2 was ready, push p1 and p2 to busy and append each other to their history
          [{p2_id, p2_opponents_ids}] ->
            :ets.delete(ready, p2_id)
            :ets.insert(busy, {p1_id, [p2_id | p1_opponents_ids]})
            :ets.insert(busy, {p2_id, [p1_id | p2_opponents_ids]})
            {:reply, p2_id, state}

          # no opponent found
          [] ->
            :ets.insert(ready, {p1_id, p1_opponents_ids})
            :ets.delete(busy, p1_id)
            {:reply, :waiting, state}
        end
    end
  end

  @doc """
  Gives the sizes of the different ETS tables used to maintain state. For testing purposes and maybe sharding.
  """
  @spec handle_call(:get_size, GenServer.from(), state) ::
          {:reply, {integer, integer, integer}, state}
  def handle_call(:get_size, _from, {ready, busy, leaving} = state) do
    {:reply, {:ets.info(ready)[:size], :ets.info(busy)[:size], :ets.info(leaving)[:size]}, state}
  end

  @doc """
  Resets the :ets table contents
  """
  @spec handle_call(:reset, GenServer.from(), state) :: {:reply, :ok, state}
  def handle_call(:reset, _from, {ready, busy, leaving} = state) do
    # Reset leaving timers
    :ets.foldl(
      fn {_player_id, timer_ref}, _acc ->
        Process.cancel_timer(timer_ref)
      end,
      :ok,
      leaving
    )

    # Resets dating tables
    :ets.delete_all_objects(ready)
    :ets.delete_all_objects(busy)
    :ets.delete_all_objects(leaving)
    {:reply, :ok, state}
  end

  @doc """
  Player was waiting for an opponent but is not available anymore
  """
  def handle_cast({:busy, player_id}, {ready, busy, _leaving} = state) do
    case :ets.lookup(ready, player_id) do
      [{^player_id, opponents_ids}] ->
        :ets.delete(ready, player_id)
        :ets.insert(busy, {player_id, opponents_ids})

      [] ->
        :nothing
    end

    {:noreply, state}
  end

  @doc """
  Reset player history
  """
  def handle_cast({:log_defeat, player_id}, {_ready, busy, _leaving} = state) do
    :ets.insert(busy, {player_id, []})
    {:noreply, state}
  end

  @doc """
  Undo player history last addition
  """
  def handle_cast({:log_tie, player_id}, {_ready, busy, _leaving} = state) do
    case :ets.lookup(busy, player_id) do
      [{^player_id, opponents_ids}] ->
        # pops first element
        :ets.insert(busy, {player_id, Enum.drop(opponents_ids, 1)})

      _ ->
        :nothing
    end

    {:noreply, state}
  end
end
