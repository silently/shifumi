import React from 'react';
import * as sequencer from '../../actions/sequencer';
import {ROCK, PAPER, SCISSORS, WELL} from '../../actions/throws';

const _randomShape = (wellAccepted) => {
  const shapes = [ROCK, PAPER, SCISSORS, WELL];
  const length = wellAccepted ? 4 : 3;
  return shapes[Math.floor(Math.random() * length)];
};

export default class Match extends React.Component {
  constructor(props) {
    super(props);
    document.body.classList.add('match');
    this.handleThrow = this.handleThrow.bind(this);
    this.state = {myThrown: null, oppThrown: null, myScore: 0, oppScore: 0};
  }

  static getDerivedStateFromProps(nextProps, prevState) {
    // This is apparently not the way to go, see: https://reactjs.org/blog/2018/06/07/you-probably-dont-need-derived-state.html
    // The behaviour here is: don't touch state if game step has not changed,
    // and delay some props modifications (score for instance) to state only when a particular
    // step has been reached. Because of that, relying only on props (without state) seems difficult
    // but it could be handled in render with local variables.
    if(prevState.step === nextProps.game.step) return null;
    let nextState = null;
    if(nextProps.game.step === sequencer.ROUND_REVEAL || nextProps.game.step === sequencer.GAME_REVEAL) {
      nextState = {oppThrown: nextProps.game.prevRound.opponentShape};
    } else if(nextProps.game.step === sequencer.ROUND_RESULT || nextProps.game.step === sequencer.GAME_RESULT) {
      nextState = {myScore: nextProps.game.me.score, oppScore: nextProps.game.opponent.score};
    } else if(nextProps.game.step === sequencer.ROUND_START) {
      nextState = {myThrown: null, oppThrown: null};
    }
    if(!!nextState) nextState.step = nextProps.game.step;

    return nextState;
  }

  componentWillUnmount() {
    document.body.classList.remove('match');
  }

  handleThrow(shape, e) {
    e.preventDefault();
    // Filter duplicates
    if(shape !== this.state.myThrown) {
      this.props.gameThrow(shape);
      this.setState({myThrown: shape});
    }
  }

  // me is a boolean
  thrownClassToggle(shape, me) {
    const game = this.props.game;
    const thrown = me ? this.state.myThrown : this.state.oppThrown;
    const reveal = game.step === sequencer.ROUND_REVEAL || game.step === sequencer.GAME_REVEAL;
    const playing = game.step === sequencer.ROUND_START;
    const won = me ? game.prevRound.won : !game.prevRound.won;

    if(me && playing && !this.state.myThrown) {
      return shape === WELL && game.me.wells <= 0 ? ' ' : ' anim-pulse';
    }
    if(shape !== thrown) return ' ';
    if(!reveal || game.prevRound.tie) return ' thrown';
    return won ? ' thrown anim-flip' : ' thrown anim-crush';
  }

  cardMessage() {
    const game = this.props.game;
    const step = game.step;
    if(step === sequencer.ROUND_START) return 'play';
    if(step !== sequencer.ROUND_RESULT && step !== sequencer.GAME_RESULT) return '…';
    if(game.round === 1) return '…';
    if(step === sequencer.GAME_RESULT) return game.won ? <span className="won">game won!</span> : <span className="lost">game lost!</span>;
    if(game.prevRound.won) return <span className="won">+ won +</span>;
    if(game.prevRound.tie) return <span>= tie =</span>;
    return <span className="lost">- lost -</span>;
  }

  render() {
    const game = this.props.game;
    const step = game.step;
    // my data
    const me = this.props.me;
    const myAvatar = me.avatar;
    const myPicture = myAvatar.picture ?
      <img src={`/media/${me.id}.jpg`}/> :
      <div className="default">:)</div>;
    // opponent data
    const opp = this.props.opponent;
    const oppAvatar = opp.avatar;
    const oppPicture = oppAvatar.picture ?
      <img src={`/media/${opp.id}.jpg`}/> :
      <div className="default">:)</div>;
    // styling
    const countdownClass = step === sequencer.ROUND_START ? 'launch countdown' : 'countdown';
    const cardAppearClass = step === sequencer.GAME_START ?
      '' :
      step === sequencer.GAME_RESULT ?
        'anim-bounce-out anim-delay-2' :
        'anim-bounce-in anim-delay-250';
    let shapeClass = step === sequencer.ROUND_START ? 'active' : 'inactive';
    shapeClass += ' shape btn-floating';
    const oppScoreClass = (step === sequencer.ROUND_RESULT || step === sequencer.GAME_RESULT) && game.round !== 1 && !game.prevRound.won && !game.prevRound.tie ? ' anim-flash' : '';
    const myScoreClass = (step === sequencer.ROUND_RESULT || step === sequencer.GAME_RESULT) && game.round !== 1 && game.prevRound.won ? ' anim-flash' : '';

    return (
      <div>
        <div className="countdown-wrapper">
          <div className={countdownClass}>
          </div>
        </div>
        <div className="card-ref">
          <div className="score-wrapper opponent-score"><span className="label">score</span><span className={'score' + oppScoreClass}>{this.state.oppScore}</span></div>
          <div className="score-wrapper"><span className="label">score</span><span className={'score' + myScoreClass}>{this.state.myScore}</span></div>
        </div>
        <div className="mid-up opponent">
          <div className="player-wrapper">
            <div className="avatar left">{oppPicture}</div>
            <div className="nickname left">{oppAvatar.nickname}</div>
          </div>
          <div className="valign-wrapper">
            <div className="valign-content">
              <div className="row center-align">
                <div className="col s4 shape-wrapper">
                  <div className={'shape btn-floating' + this.thrownClassToggle(ROCK, false)} disabled>
                    <i className="rock icon"></i>
                  </div>
                </div>
                <div className="col s4 offset-s4 shape-wrapper">
                  <div className="counter-ref">
                    <div className={'shape btn-floating' + this.thrownClassToggle(WELL, false)} disabled>
                      <i className="well icon"></i>
                    </div>
                    <div className="counter">{game.opponent.wells}</div>
                  </div>
                </div>
              </div>
              <div className="row center-align">
                <div className="col s4 offset-s2 shape-wrapper">
                  <div className={'shape btn-floating' + this.thrownClassToggle(PAPER, false)} disabled>
                    <i className="paper icon"></i>
                  </div>
                </div>
                <div className="col s4 shape-wrapper">
                  <div className={'shape btn-floating' + this.thrownClassToggle(SCISSORS, false)} disabled>
                    <i className="scissors icon"></i>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div className="mid-bottom me">
          <div className="player-wrapper">
            <div className="nickname left">{myAvatar.nickname}</div>
            <div className="avatar left">{myPicture}</div>
          </div>
          <div className="valign-wrapper">
            <div className="valign-content">
              <div className="row center-align">
                <div className="col s4 offset-s2 shape-wrapper">
                  <div id="shape-p" className={shapeClass + this.thrownClassToggle(PAPER, true)} onClick={this.handleThrow.bind(this, PAPER)} disabled={step !== sequencer.ROUND_START}>
                    <i className="paper icon"></i>
                  </div>
                </div>
                <div className="col s4 shape-wrapper">
                  <div id="shape-s" className={shapeClass + this.thrownClassToggle(SCISSORS, true)} onClick={this.handleThrow.bind(this, SCISSORS)} disabled={step !== sequencer.ROUND_START}>
                    <i className="scissors icon"></i>
                  </div>
                </div>
              </div>
              <div className="row center-align">
                <div className="col s4 shape-wrapper">
                  <div id="shape-r" className={shapeClass + this.thrownClassToggle(ROCK, true)} onClick={this.handleThrow.bind(this, ROCK)} disabled={step !== sequencer.ROUND_START}>
                    <i className="rock icon"></i>
                  </div>
                </div>
                <div className="col s4">
                  <div className="card-wrapper tm1">
                    <div className={cardAppearClass + ' card-contents valign-wrapper'}>
                      <div className="round-wrapper">{this.cardMessage()}</div>
                    </div>
                  </div>
                </div>
                <div className="col s4 shape-wrapper">
                  <div className="counter-ref">
                    <div id="shape-w" className={shapeClass + this.thrownClassToggle(WELL, true)} onClick={this.handleThrow.bind(this, WELL)} disabled={game.me.wells <= 0 || step !== sequencer.ROUND_START}>
                      <i className="well icon"></i>
                      {game.me.wells <= 0 &&
                        <div className="no-well-ref"><div className="no-well">✕</div></div>
                      }
                    </div>
                    <div className="counter">{game.me.wells}</div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }
};
