import {connect} from 'react-redux';
import Header from '../components/header';

const mapStateToProps = (state) => {
  return {
    session: state.session
  };
};

export default connect(
  mapStateToProps
)(Header);
