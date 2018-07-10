import {applyMiddleware, createStore} from 'redux';
import thunk from 'redux-thunk';
import logger from 'redux-logger';
import reducers from './reducers';

// See DEBUG_FLAG setting in rollup.config.js
// We use the logger (logs in the devtools) only in dev mode
const middlewares = DEBUG_FLAG ? applyMiddleware(logger, thunk) : applyMiddleware(thunk);

const store = createStore(
  reducers,
  middlewares
);

// Use localStorage for avatar state
store.subscribe(() => {
  const lastAction = store.getState().lastAction;
  if(['LOAD_AVATAR_SUCCESS', 'UPDATE_AVATAR_SUCCESS', 'LOAD_ME_SUCCESS'].includes(lastAction)) {
    localStorage.setItem('avatar', JSON.stringify(store.getState().me.avatar));
  } else if('EXIT_SUCCESS' === lastAction) {
    localStorage.removeItem('avatar');
  }
});

export default store;
