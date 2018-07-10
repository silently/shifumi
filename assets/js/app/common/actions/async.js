import * as sync from './sync';
import history from '../history';

export function navigateTo(path) {
  return dispatch => {
    history.push(path);
  }
};

export function exit() {
  return dispatch => {
    dispatch(sync.exitRequest());

    const request = new Request('/auth/exit', {
      method: 'POST',
      headers: new Headers({'x-csrf-token': window.csrfToken}),
      credentials: 'same-origin'
    });
    fetch(request).then(function(response) {
      dispatch(sync.exitSuccess());
      dispatch(navigateTo('/'));
    }).catch(function(error) {
      dispatch(sync.exitFailure());
    });
  }
}
