defmodule Shifumi.Records.Sheet do
  use Ecto.Schema
  import Ecto.Changeset
  alias Shifumi.Records.Sheet
  alias Shifumi.Records.Log

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "sheets" do
    # Associations
    belongs_to(:player, Shifumi.People.Player)

    field(:game_count, :integer, default: 0)
    field(:game_win_count, :integer, default: 0)
    field(:high_score, :integer, default: 0)
    field(:high_score_at, :naive_datetime)
    field(:paper_count, :integer, default: 0)
    field(:paper_win_count, :integer, default: 0)
    field(:rock_count, :integer, default: 0)
    field(:rock_win_count, :integer, default: 0)
    field(:round_count, :integer, default: 0)
    field(:round_tie_count, :integer, default: 0)
    field(:round_win_count, :integer, default: 0)
    field(:scissors_count, :integer, default: 0)
    field(:scissors_win_count, :integer, default: 0)
    field(:score, :integer, default: 0)
    field(:series, {:array, :binary_id}, default: [])
    field(:well_count, :integer, default: 0)
    field(:well_win_count, :integer, default: 0)
    field(:wells, :integer, default: 1)

    timestamps()
  end

  ##############
  # Changesets #
  ##############

  @doc false
  def changeset(%Sheet{} = sheet, attrs) do
    sheet
    |> cast(attrs, [:high_score, :high_score_at])
  end

  @doc false
  def log_changeset(winner?, %Sheet{} = sheet, %Log{} = log) do
    sheet
    |> change(%{})
    |> process_history(winner?, log)
    |> process_result(winner?, log)
  end

  ############
  # Privates #
  ############

  @max_wells Shifumi.max_wells()

  defp well_won?(wells), do: wells < @max_wells

  # Updates :game_count, :score, :series, :game_win_count, :high_score and :wells
  defp process_result(changeset, winner?, %Log{loser_id: loser_id}) do
    changeset = inc_change(changeset, :game_count)

    if winner? do
      new_score = changeset.data.score + 1
      # checks first if the number of wells has changed through process_history
      wells = Map.get(changeset.changes, :wells, changeset.data.wells)
      well_won? = well_won?(wells)

      if well_won? do
        ShifumiWeb.Endpoint.broadcast("player:" <> changeset.data.player_id, "well_won", %{})
      end

      changeset
      |> put_change(:score, new_score)
      |> put_change(:series, [loser_id | changeset.data.series])
      |> inc_change(:game_win_count)
      |> cond_put_change(
        new_score > changeset.data.high_score,
        :high_score,
        new_score
      )
      |> cond_put_change(
        new_score > changeset.data.high_score,
        :high_score_at,
        NaiveDateTime.truncate(NaiveDateTime.utc_now(), :second)
      )
      |> cond_inc_change(well_won?, :wells)
    else
      changeset
      |> put_change(:score, 0)
      |> put_change(:series, [])
    end
  end

  defp process_history(changeset, winner?, %Log{history: history}) do
    [own_history, opponent_history] =
      case winner? do
        true -> String.split(history, ",")
        false -> String.split(history, ",") |> Enum.reverse()
      end

    process_rounds(changeset, own_history, opponent_history)
  end

  # Updates :round_win_count, :"rpsw"_count, :win_"rpsw"_count
  defp process_rounds(changeset, <<>>, <<>>), do: changeset

  defp process_rounds(changeset, <<own_shape::binary-1, own_tail::binary>>, <<
         opponent_shape::binary-1,
         opponent_tail::binary
       >>) do
    # REVIEW: pattern match with binaries works because the characters used (rpswn) have a one byte length
    {prev_winner?, tie?} =
      case Shifumi.Engine.Rules.solve_round(own_shape, opponent_shape) do
        1 -> {true, false}
        0 -> {false, true}
        _ -> {false, false}
      end

    case own_shape do
      "r" ->
        changeset
        |> inc_change(:rock_count)
        |> cond_inc_change(prev_winner?, :rock_win_count)

      "p" ->
        changeset
        |> inc_change(:paper_count)
        |> cond_inc_change(prev_winner?, :paper_win_count)

      "s" ->
        changeset
        |> inc_change(:scissors_count)
        |> cond_inc_change(prev_winner?, :scissors_win_count)

      "w" ->
        changeset
        |> inc_change(:well_count)
        |> dec_change(:wells)
        |> cond_inc_change(prev_winner?, :well_win_count)

      _ ->
        changeset
    end
    |> inc_change(:round_count)
    |> cond_inc_change(prev_winner?, :round_win_count)
    |> cond_inc_change(tie?, :round_tie_count)
    |> process_rounds(own_tail, opponent_tail)
  end

  defp inc_change(changeset, key) do
    prev_value = get_field(changeset, key)
    put_change(changeset, key, prev_value + 1)
  end

  defp dec_change(changeset, key) do
    prev_value = get_field(changeset, key)
    put_change(changeset, key, prev_value - 1)
  end

  # Conditional put
  defp cond_put_change(changeset, true, key, value), do: put_change(changeset, key, value)
  defp cond_put_change(changeset, false, _key, _value), do: changeset

  # Conditional increment
  defp cond_inc_change(changeset, true, key), do: inc_change(changeset, key)
  defp cond_inc_change(changeset, false, _key), do: changeset
end
