import {connect} from 'react-redux';
import Link from '../components/link';
import {navigateTo} from '../actions/async';

const mapDispatchToProps = dispatch => {
  return {
    handleClick: (path, e) => {
      e.preventDefault();
      dispatch(navigateTo(path));
    }
  }
};

export default connect(
  null,
  mapDispatchToProps
)(Link);
