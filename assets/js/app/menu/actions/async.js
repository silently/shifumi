import * as sync from './sync';

export function loadAvatar() {
  return dispatch => {
    const request = new Request('/api/avatar', {
      method: 'GET',
      credentials: 'same-origin'
    });

    dispatch(sync.loadAvatarRequest());
    fetch(request).then(function(response) {
      if(response.ok) {
        response.json().then(function(json) {
          dispatch(sync.loadAvatarSuccess(json));
        });
      } else {
        dispatch(sync.loadAvatarFailure());
      }
    }).catch(function(error) {
      dispatch(sync.loadAvatarFailure());
    });
  }
}

export function updateAvatar(formData) {
  return (dispatch, getState) => {
    const {session} = getState();

    const request = new Request('/api/avatar', {
      method: 'PUT',
      headers: new Headers({'x-csrf-token': session.csrfToken}),
      credentials: 'same-origin',
      body: formData
    });

    dispatch(sync.updateAvatarRequest());
    fetch(request).then(function(response) {
      if(response.ok) {
        response.json().then(function(json) {
          dispatch(sync.updateAvatarSuccess(json));
        });
      } else {
        response.json().then(function(json) {
          dispatch(sync.updateAvatarFailure(json.errors));
        });
      }
    }).catch(function(error) {
      dispatch(sync.updateAvatarFailure());
    });
  }
}
