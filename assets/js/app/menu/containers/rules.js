import {connect} from 'react-redux';
import Rules from '../components/rules';
import {navigateTo} from '../../common/actions/async';

const mapStateToProps = (state) => {
  return {
    logged: state.session.logged
  };
};

const mapDispatchToProps = dispatch => {
  return {
    handleClose: (e) => {
      e.preventDefault();
      dispatch(navigateTo("/"))
    },
    handlePlay: (e) => {
      e.preventDefault();
      dispatch(navigateTo("/play"));
    }
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Rules);
