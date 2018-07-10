import React from 'react';

export default class Error extends React.Component {
  constructor(props) {
    super(props);
    this.state = {showInfo: false, showReload: false};
  }

  componentDidMount() {
    this.timeoutInfo = setTimeout(this.showInfo.bind(this), 1500);
    this.timeoutReload = setTimeout(this.showReload.bind(this), 3500);
  }

  componentWillUnmount() {
    clearTimeout(this.timeoutInfo);
    clearTimeout(this.timeoutReload);
  }

  showInfo() {
    this.setState({showInfo: true});
  }

  showReload() {
    this.setState({showReload: true});
  }

  handleReload(e) {
    e.preventDefault();
    window.location.reload();
  }

  render() {
    return (
      <div>
        <div className="big-up">
          {this.state.showInfo &&
            <div className="row center-align anim-appear">
              <div className="col s12">
                <h2>Network Error</h2>
              </div>
              <div className="col s12">
                <div className="spinner-wrapper">
                  <div className="spinner">
                    <div className="valign-wrapper"><div>reconnecting</div></div>
                    <div className="double-bounce1"></div>
                    <div className="double-bounce2"></div>
                  </div>
                </div>
              </div>
            </div>
          }
        </div>
        <div className="small-bottom">
          {this.state.showReload &&
            <div className="row center-align anim-appear">
              <div className="col s12">
                  <button className="btn" onClick={this.handleReload}>reload</button>
              </div>
            </div>
          }
        </div>
      </div>
    );
  }
}
