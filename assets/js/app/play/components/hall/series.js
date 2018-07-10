import React from 'react';

export default class Series extends React.Component {

  render() {

    const bestLive = this.props.scores.bestLive;
    const bestLiveEntries = bestLive && bestLive.map((s, i) =>
      <tr key={i}><td>{s.count}</td><td>{s.nickname}</td></tr>
    );
    const best = this.props.scores.best;
    const bestEntries = best && best.map((s, i) =>
      <tr key={i}><td>{s.count}</td><td>{s.nickname}</td></tr>
    );

    return (
      <div className="row">
        {bestLive &&
          <div className="col s6 m5">
            <h6 className="highlight">ongoing wins</h6>
            <table className="series">
              <thead>
                <tr>
                  <th>series</th>
                  <th>player</th>
                </tr>
              </thead>
              <tbody>
                {bestLiveEntries}
              </tbody>
            </table>
          </div>
        }
        {best &&
          <div className="col s6 m5 offset-m2">
            <h6 className="highlight">best scores ever</h6>
            <table className="series">
              <thead>
                <tr>
                  <th>series</th>
                  <th>player</th>
                </tr>
              </thead>
              <tbody>
                {bestEntries}
              </tbody>
            </table>
          </div>
        }
      </div>
    );
  }
}
