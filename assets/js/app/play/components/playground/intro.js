import React from 'react';
import * as sequencer from '../../actions/sequencer';
import {nextFrame} from '../../../common/helpers';

export default class Intro extends React.Component {
  constructor(props) {
    super(props);
    document.body.classList.add('intro');
    this.launchTransitions();
  }

  launchTransitions() {
    this.state = {frozen: true};
    const trigger = (() => { this.setState({frozen: false});}).bind(this);
    nextFrame(trigger);
  }

  componentWillUnmount() {
    document.body.classList.remove('intro');
  }

  render() {
    const step = this.props.step;
    // my data
    const me = this.props.me;
    const mySheet = me.sheet;
    const myAvatar = me.avatar;
    const myPicture = myAvatar.picture ?
      <img src={`/media/${me.id}.jpg`}/> :
      <div className="default">:)</div>;
    // opponent data
    const opp = this.props.opponent;
    const oppSheet = opp.sheet;
    const oppAvatar = opp.avatar;
    const oppPicture = oppAvatar.picture ?
      <img src={`/media/${opp.id}.jpg`}/> :
      <div className="default">:)</div>;
    // styling
    const countdownClass = step === sequencer.GAME_INTRO ? 'countdown' : 'countdown launch';
    const statAppearClass = this.state.frozen ? 'trans-appear' : 'trans-appear launch';

    return (
      <div>
        <div className="countdown-wrapper">
          <div className={countdownClass}>
          </div>
        </div>
        <div className="card-ref">
          <div className="card-wrapper">
            <div className="card-contents anim-bounce-in-out anim-duration-6 anim-delay-2">
              <span className="opponent">{oppAvatar.nickname}</span>
              <span className="vs"></span>
              <span className="me">{myAvatar.nickname}</span>
            </div>
          </div>
        </div>
        <div className="mid-up valign-wrapper">
          <div>
            <div className="row avatar">
              <div className="col s6">
                <div className="picture">{oppPicture}</div>
              </div>
              <div className="col s6">
                <span className="nickname">{oppAvatar.nickname}</span>
                {oppAvatar.location &&
                  <span className="location"><br />@{oppAvatar.location}</span>
                }
                {oppAvatar.mantra &&
                  <span className="mantra"><br />«{oppAvatar.mantra}»</span>
                }
              </div>
            </div>
            <div className="row">
              <div className="col s12 bigger">
                <table className={statAppearClass}>
                  <tbody>
                    <tr>
                      <td>ongoing wins</td>
                      <td>{oppSheet.score}</td>
                    </tr>
                  </tbody>
                </table>
                <table className={statAppearClass + ' trans-delay-250'}>
                  <tbody>
                    <tr>
                      <td>rock</td>
                      <td>{oppSheet.rock_pct}%</td>
                    </tr>
                    <tr>
                      <td>paper</td>
                      <td>{oppSheet.paper_pct}%</td>
                    </tr>
                    <tr>
                      <td>scissors</td>
                      <td>{oppSheet.scissors_pct}%</td>
                    </tr>
                    <tr>
                      <td>well</td>
                      <td>{oppSheet.well_pct}%</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
        <div className="mid-bottom valign-wrapper">
          <div>
            <div className="row avatar">
              <div className="col s6">
                <div className="picture">{myPicture}</div>
              </div>
              <div className="col s6">
                <span className="nickname">{myAvatar.nickname}</span>
                {myAvatar.location &&
                  <span className="location"><br />@{myAvatar.location}</span>
                }
                {myAvatar.mantra &&
                  <span className="mantra"><br />«{myAvatar.mantra}»</span>
                }
              </div>
            </div>
            <div className="row">
              <div className="col s12 bigger">
                <table className={statAppearClass + ' trans-delay-500'}>
                  <tbody>
                    <tr>
                      <td>ongoing wins</td>
                      <td>{mySheet.score}</td>
                    </tr>
                  </tbody>
                </table>
                <table className={statAppearClass + ' trans-delay-750'}>
                  <tbody>
                    <tr>
                      <td>rock</td>
                      <td>{mySheet.rock_pct}%</td>
                    </tr>
                    <tr>
                      <td>paper</td>
                      <td>{mySheet.paper_pct}%</td>
                    </tr>
                    <tr>
                      <td>scissors</td>
                      <td>{mySheet.scissors_pct}%</td>
                    </tr>
                    <tr>
                      <td>well</td>
                      <td>{mySheet.well_pct}%</td>
                    </tr>
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
};
