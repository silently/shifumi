import React from 'react';

class Rules extends React.Component {
  constructor(props) {
    super(props);
    document.body.classList.add('rules');
  }

  componentDidMount() {
    window.scrollTo(0,0);
  }

  componentWillUnmount() {
    document.body.classList.remove('rules');
  }

  render() {
    const mainAction = this.props.logged ? <a className="btn-close btn-play btn-floating btn-large teal lighten-1" onClick={this.props.handlePlay}>►</a> : <a className="btn-close btn-floating btn-large teal lighten-1" onClick={this.props.handleClose}>✕</a>;
    return (
      <div>
        {mainAction}
        <div className="row alternate nbm">
          <div className="col s9">
            <div className="contents">
              <h4>Rules</h4>
              <ul className="dashed">
                <li>Usual shapes are <i className="rock"></i> rock <i className="paper"></i> paper and <i className="scissors"></i> scissors</li>
                <li>You also have a limited number of <i className="well"></i> wells</li>
                <li>Rock beats scissors</li>
                <li>Scissors beats paper</li>
                <li>Paper beats rock</li>
                <li>Well beats scissors and rock but loses to paper</li>
                <li>Not playing loses to any shape</li>
                <li>Tie occurs when shapes are the same</li>
              </ul>
            </div>
          </div>
        </div>
        <div className="row nbm">
          <div className="col s9">
            <div className="contents">
              <h4>Match & scores</h4>
              <ul className="dashed">
                <li>Win 3 rounds to win the match</li>
                <li>The <em>ongoing wins</em> score counts successive match wins</li>
                <li><em>ongoing wins</em> goes to 0 when you lose a match</li>
              </ul>
            </div>
          </div>
        </div>
        <div className="row alternate nbm">
          <div className="col s9">
            <div className="contents">
              <h4>Wells</h4>
              <ul className="dashed">
                <li>You have at most 12 wells</li>
                <li>You earn one well when you win a match</li>
                <li>You spend one each time you throw one</li>
              </ul>
            </div>
          </div>
        </div>
        <div className="row nbm">
          <div className="col s9">
            <div className="contents">
              <h4>Edge cases</h4>
              <ul className="dashed">
                <li>If no one plays during 10 rounds, both players lose the match</li>
                <li>After 100 active rounds, the match is considered a tie: no one wins, no one loses</li>
              </ul>
            </div>
          </div>
        </div>
      </div>
    );
  }
}

export default Rules;
