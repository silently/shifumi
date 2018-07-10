import {connect} from 'react-redux';
import Summary from '../../components/playground/summary';
import {gameClientReset} from '../../actions/sync';
import {goReady} from '../../actions/async';

const mapStateToProps = (state) => {
  return {
    game: state.game,
    me: state.me,
    opponent: state.opponent
  };
};

const mapDispatchToProps = dispatch => {
  return {
    dispatch,
    handleReplay: (e) => {
      e.preventDefault();
      dispatch(gameClientReset());
      dispatch(goReady());
    },
    handleHall: (e) => {
      e.preventDefault();
      dispatch(gameClientReset());
    }
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Summary);
