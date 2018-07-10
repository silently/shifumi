import {connect} from 'react-redux';
import {gameThrow} from '../../actions/async';
import Intro from '../../components/playground/intro';

const mapStateToProps = (state) => {
  return {
    step: state.game.step,
    me: state.me,
    opponent: state.opponent
  }
};

export default connect(
  mapStateToProps
)(Intro);
