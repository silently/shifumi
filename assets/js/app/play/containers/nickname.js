import {connect} from 'react-redux';
import Nickname from '../components/nickname';
import {setNickname} from '../actions/async';

const mapStateToProps = (state) => {
  return {
    me: state.me,
  }
};

const mapDispatchToProps = dispatch => {
  return {
    handleSubmit: (e) => {
      e.preventDefault();
      const nickname = e.target.nickname.value;
      dispatch(setNickname(nickname));
    }
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Nickname);
