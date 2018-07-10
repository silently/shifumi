import React from 'react';

export default class Abort extends React.Component {
  constructor(props) {
    super(props);
  }

  render() {
    return (
      <div>
        <div className="big-up">
          <div className="valign-wrapper">
            <div className="row center-align">
              <div className="col s12">
                <h2>Game Aborted</h2>
              </div>
              <div className="col s12">
                <div>No one played</div>
              </div>
            </div>
          </div>
        </div>
        <div className="small-bottom">
          <div className="row center-align">
            <div className="col s12">
              <button className="btn" onClick={this.props.handleQuit}>hall</button>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
