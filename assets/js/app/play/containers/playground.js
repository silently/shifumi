import {connect} from 'react-redux';
import {gameThrow} from '../actions/async';
import Playground from '../components/playground';

const mapStateToProps = (state) => {
  return {
    game: state.game
  }
};

export default connect(
  mapStateToProps
)(Playground);
