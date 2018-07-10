import {combineReducers} from 'redux';
import lastAction from './reducers/last-action';
import session from '../menu/reducers/session';
import socket from '../play/reducers/socket';
import playerChannel from '../play/reducers/player-channel';
import presenceChannel from '../play/reducers/presence-channel';
import gameChannel from '../play/reducers/game-channel';
import me from './reducers/me';
import game from '../play/reducers/game';
import opponent from '../play/reducers/opponent';
import scores from '../play/reducers/scores';

export default combineReducers({
  // HTTP
  session,
  // Sockets
  socket,
  playerChannel,
  presenceChannel,
  gameChannel,
  opponent,
  game,
  scores,
  // Sockets & HTTP (me.avatar)
  me,
  // local
  lastAction
});
