import {connect} from 'react-redux';
import Root from '../components/root';
import * as sequencer from '../actions/sequencer';

const isLoaded = (state) => {
  return state.socket.connected && state.playerChannel.joined && state.me.fetched;
};

const mapStateToProps = (state) => {
  return {
    networkError: state.socket.networkError,
    loaded: isLoaded(state),
    nicknameNeeded: state.me.nicknameNeeded,
    // if ended: in summary or pre summary animation
    inPlayground: state.game.joinAsked || state.game.ended,
    inSummary: state.game.ended && state.game.step === sequencer.GAME_SUMMARY,
    inAbort: state.game.aborted
  };
};

export default connect(
  mapStateToProps
)(Root);
