import {connect} from 'react-redux';
import Sheet from '../../components/hall/sheet';

const mapStateToProps = (state) => {
  return {
    me: state.me
  }
};

export default connect(
  mapStateToProps
)(Sheet);
