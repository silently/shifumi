import {connect} from 'react-redux';
import Abort from '../components/abort';
import {gameClientReset} from '../actions/sync';

const mapDispatchToProps = dispatch => {
  return {
    handleQuit: (e) => {
      e.preventDefault();
      dispatch(gameClientReset());
    }
  }
}

export default connect(
  null,
  mapDispatchToProps
)(Abort);
