import {connect} from 'react-redux';
import {gameThrow} from '../../actions/async';
import Match from '../../components/playground/match';

const mapStateToProps = (state) => {
  return {
    game: state.game,
    me: state.me,
    opponent: state.opponent
  }
};

const mapDispatchToProps = dispatch => {
  return {
    gameThrow: (shape) => {
      dispatch(gameThrow(shape));
    }
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Match);
