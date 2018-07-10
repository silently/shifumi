import React from 'react';

export default class Loading extends React.Component {
  constructor(props) {
    super(props);
    this.state = {show: false};
  }

  componentDidMount() {
    this.timeout = setTimeout(this.show.bind(this), 1500);
  }

  componentWillUnmount() {
    clearTimeout(this.timeout);
  }

  show() {
    this.setState({show: true});
  }

  render() {
    return (
      <div>
        <div className="big-up">
          {this.state.show &&
            <div className="row center-align anim-appear tm4">
              <div className="col s12">
                <div className="spinner-wrapper">
                  <div className="spinner">
                    <div className="valign-wrapper"><div>loading</div></div>
                    <div className="double-bounce1"></div>
                    <div className="double-bounce2"></div>
                  </div>
                </div>
              </div>
            </div>
          }
        </div>
      </div>
    );
  }
}
