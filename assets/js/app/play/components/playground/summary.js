import React from 'react';
import {refreshMe} from '../../actions/async';
import {gameClientReset} from '../../actions/sync';
import {nextFrame} from '../../../common/helpers';

export default class Summary extends React.Component {
  constructor(props) {
    super(props);
    document.body.classList.add('summary');
    this.launchTransitions();
  }

  launchTransitions() {
    const trigger = (() => { document.querySelector('.mid-to-full').classList.add('start');}).bind(this);
    const show = () => {
      const hidden = document.querySelectorAll('.trans-appear');
      hidden.forEach(el => el.classList.add('launch'));
    }
    nextFrame(trigger);
    setTimeout(show, 600);
  }

  componentDidMount() {
    this.props.dispatch(refreshMe());
  }

  componentWillUnmount() {
    document.body.classList.remove('summary');
    this.props.dispatch(gameClientReset());
  }

  render() {
    const game = this.props.game;

    // Winner data
    const winner = game.won ? this.props.me : this.props.opponent;
    const winnerSheet = winner.sheet;
    const winnerAvatar = winner.avatar;
    const winnerPicture = winnerAvatar.picture ?
      <img src={`/media/${winner.id}.jpg`}/> :
      <div></div>;

    const result = game.won ? 'won' : 'lost';

    return (
      <div className="mid-to-full">
        <div className="mid-up">
          <p>Bonjour</p>
        </div>
        <div className="mid-bottom">
          <div className="big-up trans-appear">
            <div className="valign-wrapper">
              <div>
                <div className="row center-align">
                  <div className="col s12">
                    <h2>Summary</h2>
                  </div>
                </div>
                <div className="row center-align">
                  <div className="col s8 offset-s2">
                    <p>You {result} {game.me.score} - {game.opponent.score} against {this.props.opponent.avatar.nickname} in {game.round} rounds!</p>
                  </div>
                  <div className="col s8 offset-s2">
                    <div className="picture">{winnerPicture}</div>
                  </div>
                  {winnerAvatar.roar &&
                    <div className="col s8 offset-s2">
                      <p className="roar bigger">« {winnerAvatar.roar} »</p>
                    </div>
                  }
                </div>
                {this.props.game.wellWon &&
                  <div className="row center-align">
                    <div className="col s8 offset-s2">
                      <div className="card-wrapper">
                        <div className="card-contents anim-bounce-in-out anim-delay-1-5">
                          <i className="well icon"></i>You won 1 well
                        </div>
                      </div>
                    </div>
                  </div>
                }
              </div>
            </div>
          </div>
          <div className="small-bottom trans-appear">
            <div className="row center-align">
              <div className="col s12">
                <button className="btn" onClick={this.props.handleReplay}>► play again</button>
                <button className="btn lm" onClick={this.props.handleHall}>hall</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
}
