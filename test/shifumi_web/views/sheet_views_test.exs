defmodule ShifumiWeb.SheetViewTest do
  use ShifumiWeb.ConnCase, async: true
  alias ShifumiWeb.SheetView
  alias Shifumi.Records.Sheet

  test "render/2(\"show.json\", ...)" do
    sheet = %Sheet{
      wells: 11,
      game_count: 20,
      high_score: 7,
      score: 4,
      game_win_count: 10,
      round_win_count: 60,
      round_count: 123,
      round_tie_count: 10,
      paper_count: 30,
      paper_win_count: 20,
      rock_count: 30,
      rock_win_count: 15,
      scissors_count: 20,
      scissors_win_count: 13,
      well_count: 20,
      well_win_count: 12
    }

    rendered = SheetView.render("show.json", %{sheet: sheet})

    # Percentage values are processed
    assert rendered.wells === sheet.wells
    assert rendered.game_count === sheet.game_count
    assert rendered.high_score === sheet.high_score
    assert rendered.score === sheet.score
    assert rendered.win_pct === 50
    assert rendered.round_win_pct === 60
    assert rendered.paper_pct === 30
    assert rendered.paper_win_pct === 67
    assert rendered.rock_pct === 30
    assert rendered.rock_win_pct === 50
    assert rendered.scissors_pct === 20
    assert rendered.scissors_win_pct === 65
    assert rendered.well_pct === 20
    assert rendered.well_win_pct === 60
    assert rendered.round_tie_pct === 10
  end
end
