defmodule Shifumi.Engine.GameServer do
  @moduledoc """
  Manages a game internal state depending on players and timed events.
  """

  use GenServer, restart: :transient
  alias Shifumi.Engine
  alias Shifumi.Engine.{GameRegistry, Rules}

  # Allows to have different beat duration in dev/prod and test
  @beat Shifumi.beat()
  @splash_duration Shifumi.splash_duration()
  @max_rounds Shifumi.max_rounds()

  #######
  # API #
  #######

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  def start_intro(server) do
    GenServer.cast(server, :start_intro)
  end

  def get_state(server) do
    GenServer.call(server, :get_state)
  end

  def throw(server, player_id, shape) do
    GenServer.cast(server, {:throw, %{player_id: player_id, shape: shape}})
  end

  #############
  # Callbacks #
  #############

  @doc """
  Initialize and register the current game process (self) to a registry, so that clients (player and game channels) are able to find this process thanks to `Registry.lookup(Shifumi.Engine.GameRegistry, playerX)`, playerX being player1_id or player2_id
  """
  def init({player1_id, player2_id}) do
    state = Engine.init_game(player1_id, player2_id)
    GameRegistry.register(player1_id, state.id)
    GameRegistry.register(player2_id, state.id)

    {:ok, state}
  end

  @doc """
  Triggers game log creation and players' state update
  """
  def terminate(:normal, state) do
    # HACK? spawn with no link so that game terminates even if processing fails,
    # thus freeing players from being stuck/registered in this very game
    spawn(fn ->
      Shifumi.Records.process_game(state)
    end)

    :ok
  end

  @doc """
  Introductory step so that players can read a few information about their opponent
  """
  def handle_cast(:start_intro, state) do
    intro_duration = @splash_duration + @beat
    Process.send_after(self(), {:recast, :new_round}, intro_duration)
    {:noreply, state}
  end

  @doc """
  Managed players thrown shape, just ignore bad shapes
  """
  def handle_cast({:throw, %{}}, %{round: 0} = state) do
    {:noreply, state}
  end

  def handle_cast(
        {:throw, %{player_id: player_id, shape: shape}},
        %{prev_shapes: [shape1, shape2]} = state
      ) do
    if Enum.member?(["r", "p", "s", "w"], shape) do
      new_prev_shapes =
        if player_id == state.player1_id, do: [shape, shape2], else: [shape1, shape]

      new_state = %{state | prev_shapes: new_prev_shapes}
      {:noreply, new_state}
    else
      {:noreply, state}
    end
  end

  @doc """
  Timed steps
  """
  def handle_cast(:new_round, %{round: 0} = state) do
    diff = %{round: 1}
    broadcast(state.id, "game_new_round", diff)
    Process.send_after(self(), {:recast, :new_round}, @beat)
    {:noreply, state |> Map.merge(diff)}
  end

  def handle_cast(:new_round, %{round: @max_rounds} = state) do
    broadcast(state.id, "game_tie", %{})
    {:stop, :normal, state |> Map.put(:tie, true)}
  end

  def handle_cast(:new_round, state) do
    %{prev_shapes: [shape1, shape2]} = state = check_wells(state)

    prev_winner = Rules.solve_round(shape1, shape2)

    state_diff = %{
      history1: state.history1 <> shape1,
      history2: state.history2 <> shape2,
      prev_shapes: ["n", "n"],
      prev_winner: prev_winner
    }

    client_diff = %{
      prev_shapes: [shape1, shape2],
      prev_winner: prev_winner
    }

    if prev_winner == 0 do
      # Tie
      state_diff = state_diff |> Map.put(:round, state.round + 1)
      client_diff = client_diff |> Map.put(:round, state.round + 1)

      # Empty tie round?
      state_diff =
        if shape1 == "n" do
          Map.put(state_diff, :empty_rounds, state.empty_rounds + 1)
        else
          state_diff
        end

      if Map.get(state_diff, :empty_rounds) == Shifumi.max_empty_rounds() do
        # EVENT game_abort
        broadcast(state.id, "game_abort", %{})
        {:stop, :normal, state |> Map.merge(state_diff) |> Map.put(:aborted, true)}
      else
        # EVENT game_new_round after tie
        broadcast(state.id, "game_new_round", client_diff)
        state_diff = state_diff |> Map.put(:round_start_time, NaiveDateTime.utc_now())
        Process.send_after(self(), {:recast, :new_round}, @beat)
        {:noreply, state |> Map.merge(state_diff)}
      end
    else
      score_diff = Rules.score_diff(state.score1, state.score2, prev_winner)
      new_state = state |> Map.merge(state_diff) |> Map.merge(score_diff)

      if Rules.game_has_finished?(new_state.score1, new_state.score2) do
        # EVENT game_end
        client_diff =
          client_diff
          |> Map.merge(score_diff)
          |> Map.put(:winner, client_diff.prev_winner)

        broadcast(state.id, "game_end", client_diff)
        {:stop, :normal, new_state}
      else
        # EVENT game_new_round
        client_diff =
          client_diff
          |> Map.merge(score_diff)
          |> Map.put(:round, state.round + 1)

        broadcast(state.id, "game_new_round", client_diff)

        new_state =
          new_state
          |> Map.put(:round, state.round + 1)
          |> Map.put(:round_start_time, NaiveDateTime.utc_now())

        Process.send_after(self(), {:recast, :new_round}, @beat)
        {:noreply, new_state}
      end
    end
  end

  def handle_call(:get_state, _from, state) do
    # No need to send :prev_winner which is a "volatile information"
    # Nor cheat-enabling leak (round shapes), and other properties (see %Game struct)
    elapsed = NaiveDateTime.diff(NaiveDateTime.utc_now(), state.round_start_time, :millisecond)

    client_state =
      state
      |> Map.take([:id, :player1_id, :player2_id, :round, :score1, :score2, :history1, :history2])
      |> Map.put(:elapsed, elapsed)

    {:reply, client_state, state}
  end

  def handle_info({:recast, msg}, state) do
    GenServer.cast(self(), msg)
    {:noreply, state}
  end

  ############
  # Privates #
  ############

  # Checks a player has 1 well in stock when s/he pretends to throw one
  # Either decrement the wells stock or nullify the throw
  defp check_wells(state) do
    %{prev_shapes: [shape1, shape2], wells: [wells1, wells2]} = state

    state =
      if shape1 == "w" do
        if wells1 > 0 do
          state |> Map.put(:wells, [wells1 - 1, wells2])
        else
          state |> Map.put(:prev_shapes, ["n", shape2])
        end
      else
        state
      end

    state =
      if shape2 == "w" do
        if wells2 > 0 do
          state |> Map.put(:wells, [wells1, wells2 - 1])
        else
          state |> Map.put(:prev_shapes, [shape1, "n"])
        end
      else
        state
      end

    state
  end

  defp broadcast(id, event, msg), do: ShifumiWeb.Endpoint.broadcast("game:" <> id, event, msg)
end
