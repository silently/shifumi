import {connect} from 'react-redux';
import {goReady, goBusy} from '../actions/async';
import Hall from '../components/hall';

const mapStateToProps = (state) => {
  return {
    ready: state.me.ready,
    playersCount: state.presenceChannel.playersCount
  }
};

const mapDispatchToProps = dispatch => {
  return {
    dispatch,
    handleReady: (e) => {
      e.preventDefault();
      dispatch(goReady());
    },
    handleBusy: (e) => {
      e.preventDefault();
      dispatch(goBusy());
    }
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Hall);
