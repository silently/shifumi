import {connect} from 'react-redux';
import {exit} from '../actions/async';
import Footer from '../components/footer';

const mapStateToProps = (state) => {
  return {
    session: state.session
  };
};

const mapDispatchToProps = dispatch => {
  return {
    exit: () => {
      dispatch(exit());
    }
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Footer);
