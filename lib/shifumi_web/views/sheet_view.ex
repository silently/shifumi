defmodule ShifumiWeb.SheetView do
  use ShifumiWeb, :view

  def render("show.json", %{sheet: sheet}) do
    # We don't take into account idle rounds
    eff_round_count =
      sheet.rock_count + sheet.paper_count + sheet.scissors_count + sheet.well_count

    %{
      score: sheet.score,
      game_count: sheet.game_count,
      high_score: sheet.high_score,
      wells: sheet.wells,
      win_pct: safe_div(sheet.game_win_count, sheet.game_count),
      round_win_pct: safe_div(sheet.round_win_count, eff_round_count),
      round_tie_pct: safe_div(sheet.round_tie_count, eff_round_count),
      paper_pct: safe_div(sheet.paper_count, eff_round_count),
      paper_win_pct: safe_div(sheet.paper_win_count, sheet.paper_count),
      rock_pct: safe_div(sheet.rock_count, eff_round_count),
      rock_win_pct: safe_div(sheet.rock_win_count, sheet.rock_count),
      scissors_pct: safe_div(sheet.scissors_count, eff_round_count),
      scissors_win_pct: safe_div(sheet.scissors_win_count, sheet.scissors_count),
      well_pct: safe_div(sheet.well_count, eff_round_count),
      well_win_pct: safe_div(sheet.well_win_count, sheet.well_count)
    }
  end

  defp safe_div(_dividend, 0), do: 0
  defp safe_div(dividend, divisor), do: round(dividend / divisor * 100)
end
