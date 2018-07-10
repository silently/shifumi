import {connect} from 'react-redux';
import Root from '../components/root';

const mapStateToProps = (state) => {
  return {
    session: state.session
  };
};

export default connect(
  mapStateToProps
)(Root);
