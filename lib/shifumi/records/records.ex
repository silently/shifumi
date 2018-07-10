defmodule Shifumi.Records do
  @moduledoc """
  The Records context for (game) logs, (player) scores and (player) sheets
  """

  import Ecto.Query, warn: false
  alias Shifumi.Repo
  alias Shifumi.Records.{Log, Score, Sheet}
  alias Shifumi.Engine.Game
  alias Shifumi.People.{Avatar, Dating}

  @doc """
  Saves a game log and update both players state
  """
  def process_game(%Game{aborted: aborted} = game) when aborted do
    Dating.log_defeat(Dating, game.player1_id)
    Dating.log_defeat(Dating, game.player2_id)
    process_abort(game.player1_id)
    process_abort(game.player2_id)
  end

  def process_game(%Game{tie: tie} = game) when tie do
    Dating.log_tie(Dating, game.player1_id)
    Dating.log_tie(Dating, game.player2_id)
  end

  def process_game(%Game{} = game) do
    log = Log.from_game(game)
    Dating.log_defeat(Dating, log.loser_id)
    # Persistence
    winner_sheet = get_player_sheet(log.winner_id)
    loser_sheet = get_player_sheet(log.loser_id)
    insert_log!(log)
    update_sheet(true, winner_sheet, log)
    update_sheet(false, loser_sheet, log)
    update_score(true, winner_sheet)
    update_score(false, loser_sheet)
  end

  # Updates player state when game is aborted
  defp process_abort(player_id) do
    from(s in Sheet, where: s.player_id == ^player_id)
    |> Repo.update_all(set: [score: 0, series: []])
  end

  @doc """
  Updates player statistics sheet with a game log
  """
  def update_sheet(winner?, %Sheet{} = sheet, %Log{} = log) do
    Sheet.log_changeset(winner?, sheet, log)
    |> Repo.update()
  end

  @doc """
  Gets a player sheet.
  """
  def get_player_sheet(player_id) do
    Repo.get_by(Sheet, player_id: player_id)
  end

  @doc """
  Get a player series attribute
  """
  def get_player_series(player_id) do
    from(s in Sheet, select: s.series)
    |> Repo.get_by(player_id: player_id)
  end

  @doc """
  Get a player wells attribute
  """
  def get_player_wells(player_id) do
    from(s in Sheet, select: s.wells)
    |> Repo.get_by(player_id: player_id)
  end

  @doc """
  Inserts a game log.
  """
  def insert_log!(%Log{} = log) do
    log |> Repo.insert!()
  end

  @doc """
  Returns the list of best ever scores.
  """
  def best do
    from(
      s in Sheet,
      order_by: [desc: s.high_score, asc: s.high_score_at],
      limit: 10,
      inner_join: a in Avatar,
      on: a.player_id == s.player_id,
      select: %{nickname: a.nickname, count: s.high_score}
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of best live scores.
  """
  def best_live do
    # only live scores
    live_query =
      from(
        s in Score,
        where: s.live == true,
        select: %{player_id: s.player_id, count: s.count, live: s.live}
      )

    # group by player_id on the previous subquery (only live scores)
    max_query =
      from(
        l in subquery(live_query),
        group_by: l.player_id,
        select: %{player_id: l.player_id, count: max(l.count)},
        order_by: [desc: max(l.count)],
        limit: 10
      )

    max_with_avatar_query =
      from(
        a in Avatar,
        inner_join: m in subquery(max_query),
        on: a.player_id == m.player_id,
        select: %{nickname: a.nickname, count: m.count},
        order_by: [desc: m.count]
      )

    max_with_avatar_query |> Repo.all()
  end

  @doc """
  Updates player score
  """
  def update_score(winner?, %Sheet{player_id: player_id} = sheet) do
    cond do
      winner? && sheet.score > 0 ->
        inc_score(player_id)

      winner? ->
        create_player_score(player_id, %{count: 1, live: true})

      sheet.score > 0 ->
        stop_score(player_id)

      true ->
        :nothing
    end
  end

  @doc """
  Creates a score.
  """
  def create_player_score(player_id, attrs) do
    %Score{}
    |> Score.changeset_with_player(Map.put(attrs, :player_id, player_id))
    |> Repo.insert()
  end

  @doc """
  Increments a score.
  """
  def inc_score(player_id) do
    from(s in Score, where: s.player_id == ^player_id and s.live == true)
    |> Repo.update_all(inc: [count: 1])
  end

  @doc """
  Increments a score.
  """
  def stop_score(player_id) do
    from(s in Score, where: s.player_id == ^player_id and s.live == true)
    |> Repo.update_all(set: [live: false])
  end
end
