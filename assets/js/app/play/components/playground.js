import React from 'react';
import Loading from './loading';
import SplashScreen from './playground/splash-screen';
import Intro from '../containers/playground/intro';
import Match from '../containers/playground/match';
import Summary from '../containers/playground/summary';
import * as sequencer from '../actions/sequencer';
import {joinGameChannel, leaveGameChannel, loadGame} from '../actions/async';

export default class Playground extends React.Component {

  componentDidMount() {
    const dispatch = this.props.dispatch;
    dispatch(joinGameChannel())
      .then(() => dispatch(loadGame()));
  }

  componentWillUnmount() {
    this.props.dispatch(leaveGameChannel());
  }

  render() {
    const game = this.props.game;

    if(!game.fetched || game.step === sequencer.GAME_SLEEP) {
      return <Loading />;
    } else if(game.step === sequencer.GAME_SPLASH_SCREEN) {
      return <SplashScreen />;
    } else if(game.step <= sequencer.GAME_PRE_START) {
      return <Intro />;
    } else if(game.step <= sequencer.GAME_RESULT) {
      return <Match />;
    } else {
      return <Summary />
    }
  }
}
