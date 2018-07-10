import React from 'react';
import ReactDOM from 'react-dom';
import {Provider} from 'react-redux';
import store from './common/store';
import Root from './common/containers/root';
import registerServiceWorker from './common/register-sw';

ReactDOM.render(
  <Provider store={store}>
    <Root />
  </Provider>,
  document.getElementById('root')
);

registerServiceWorker();
