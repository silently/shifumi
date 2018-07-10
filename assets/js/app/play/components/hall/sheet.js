import React from 'react';

export default class Sheet extends React.Component {

  render() {
    const sheet = this.props.me.sheet;

    return (
      <div className="row">
        {this.props.me.fetched &&
          <div>
            <div className="col s6">
              <h6 className="highlight">general</h6>
              <table className="sheet">
                <tbody>
                  <tr>
                    <td>ongoing wins</td>
                    <td>{sheet.score}</td>
                  </tr>
                  <tr>
                    <td>best score</td>
                    <td>{sheet.high_score}</td>
                  </tr>
                  <tr>
                    <td>available wells</td>
                    <td>{sheet.wells}</td>
                  </tr>
                  <tr>
                    <td>games played</td>
                    <td>{sheet.game_count}</td>
                  </tr>
                  <tr>
                    <td>games won</td>
                    <td>{sheet.win_pct}%</td>
                  </tr>
                  <tr>
                    <td>rounds won</td>
                    <td>{sheet.round_win_pct}%</td>
                  </tr>
                  <tr>
                    <td>rounds tie</td>
                    <td>{sheet.round_tie_pct}%</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div className="col s6">
              <h6 className="highlight">habits</h6>
              <table className="sheet shapes">
                <tbody>
                  <tr>
                    <td>{sheet.rock_pct}%</td>
                    <td>rocks played</td>
                  </tr>
                  <tr>
                    <td>{sheet.rock_win_pct}%</td>
                    <td>winning rocks</td>
                  </tr>
                  <tr>
                    <td>{sheet.paper_pct}%</td>
                    <td>papers played</td>
                  </tr>
                  <tr>
                    <td>{sheet.paper_win_pct}%</td>
                    <td>winning papers</td>
                  </tr>
                  <tr>
                    <td>{sheet.scissors_pct}%</td>
                    <td>scissors played</td>
                  </tr>
                  <tr>
                    <td>{sheet.scissors_win_pct}%</td>
                    <td>winning scissors</td>
                  </tr>
                  <tr>
                    <td>{sheet.well_pct}%</td>
                    <td>wells played</td>
                  </tr>
                  <tr>
                    <td>{sheet.well_win_pct}%</td>
                    <td>winning wells</td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        }
      </div>
    )
  }
}
