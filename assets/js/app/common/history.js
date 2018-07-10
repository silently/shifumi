import createHistory from 'history/createBrowserHistory';
import store from './store';
import {navigate} from './actions/sync';

const history = createHistory();

// Prompt user if they are leaving a game
history.block((location, action) => {
  if (action === 'POP') {
    const {game} = store.getState();
    if (game.joinAsked) {
      return "Leave the game?";
    }
  }
  // does not return => does not block
})

history.listen(location => {
  store.dispatch(navigate(location.pathname));
});

export default history;
