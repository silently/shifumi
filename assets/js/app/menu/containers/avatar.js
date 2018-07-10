import {connect} from 'react-redux';
import Avatar from '../components/avatar';
import {navigateTo} from '../../common/actions/async';
import {updateAvatar} from '../actions/async';

const dataURItoBlob = function(dataURI) {
  const type = dataURI.split(',')[0].split(':')[1].split(';')[0];
  let bytes;
  if (dataURI.split(',')[0].indexOf('base64') >= 0) {
    bytes = atob(dataURI.split(',')[1]);
  } else {
    bytes = unescape(dataURI.split(',')[1]);
  }

  // Write bytes of the string to a typed array
  const array = new Uint8Array(bytes.length);
  for (let i = 0; i < bytes.length; i++) {
    array[i] = bytes.charCodeAt(i);
  }
  return new Blob([array], {type});
}

const mapStateToProps = (state) => {
  return {
    avatar: state.me.avatar
  };
};

const mapDispatchToProps = dispatch => {
  return {
    dispatch: dispatch,
    update: (formData, imageDataURI) => {
      if(imageDataURI) {
        const blob = dataURItoBlob(imageDataURI);
        formData.set('file', blob, 'avatar.png');
      }
      dispatch(updateAvatar(formData));
    },
    handleClose: (e) => {
      e.preventDefault();
      dispatch(navigateTo("/play"));
    }
  }
};

export default connect(
  mapStateToProps,
  mapDispatchToProps
)(Avatar);
