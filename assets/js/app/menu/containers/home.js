import {connect} from 'react-redux';
import Home from '../components/home';
import {navigateTo} from '../../common/actions/async';

const mapStateToProps = (state) => {
  return {
    avatar: state.me.avatar,
    session: state.session
  };
};

const mapDispatchToProps = dispatch => {
  return {
    handlePlay: (e) => {
      e.preventDefault();
      dispatch(navigateTo("/play"));
    }
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Home);
