import {connect} from 'react-redux';
import Series from '../../components/hall/series';

const mapStateToProps = (state) => {
  return {
    scores: state.scores
  }
};

export default connect(
  mapStateToProps
)(Series);
