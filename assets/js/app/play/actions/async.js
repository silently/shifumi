import {Socket, Presence} from 'phoenix';
import {WELL} from './throws';
import * as sync from './sync';
import {startFrom} from './sequencer';

/* Inner state */

let _socket;
let _playerChannel;
let _gameChannel;

/* API - Socket */

export function connectSocket() {
  return (dispatch, getState) => {
    const {session} = getState();
    _socket = new Socket('/socket', {params: {player_token: session.playerToken}});
    // Promise resolve/reject won't be re-triggered after the first resolution,
    // so failing paths are handled globally here
    _socket.onOpen(e => dispatch(sync.connectSocketSuccess()));
    _socket.onError(e => dispatch(sync.connectSocketFailure()));
    _socket.onClose(e => dispatch(sync.connectSocketFailure()));
    dispatch(sync.connectSocketRequest());
    // Rely on promise for chaining
    return new Promise(function(resolve, reject) {
      _socket.connect();
      _socket.onOpen(resolve);
      _socket.onError(reject);
      _socket.onClose(reject);
    });
  };
}

/* API - Channels */

export function joinPlayerChannel() {
  return (dispatch, getState) => {
    const {me} = getState();
    // Specifies channel topic
    _playerChannel = _socket.channel('player:' + me.id, {});
    // Sets callbacks
    _playerChannel.on('trigger_join', game => {
      dispatch(sync.gameServerJoinQuery(game));
    });
    _playerChannel.on('trigger_reconnect', game => {
      dispatch(sync.gameServerJoinQuery(game));
    });
    _playerChannel.on('well_won', () => {
      dispatch(sync.wellWon());
    });
    // Rely on promise for chaining
    dispatch(sync.playerChannelRequest());
    const promise = new Promise(function(resolve, reject) {
      _playerChannel.join()
        .receive('ok', resolve)
        .receive('error', reject)
        .receive('timeout', reject);
    });
    return promise.then(
      e => dispatch(sync.playerChannelSuccess()),
      e => dispatch(sync.playerChannelFailure())
    );
  };
}

export function joinPresenceChannel() {
  let _presenceChannel;
  let _presences = {};
  const _countPresences = (p) => (Object.keys(p).length);

  return dispatch => {
    // Specifies channel topic
    _presenceChannel = _socket.channel('presence');
    // Sets callbacks
    _presenceChannel.on('presence_state', state => {
      _presences = Presence.syncState(_presences, state);
      dispatch(sync.updatePresence(_countPresences(_presences)));
    });
    // receive "presence_diff" from server, containing join/leave events
    _presenceChannel.on('presence_diff', diff => {
      _presences = Presence.syncDiff(_presences, diff);
      dispatch(sync.updatePresence(_countPresences(_presences)));
    });
    // Rely on promise for chaining
    return new Promise(function(resolve, reject) {
      _presenceChannel.join()
        .receive('ok', resolve)
        .receive('error', reject)
        .receive('timeout', reject);
    });
  };
}

export function leaveGameChannel() {
  return dispatch => {
    dispatch(sync.gameChannelLeave());
    _gameChannel.leave();
  }
}

export function joinGameChannel() {
  return (dispatch, getState) => {
    const gameId = getState().game.id;
    // Specifies channel topic
    _gameChannel = _socket.channel('game:' + gameId, {});
    // Sets callbacks
    _gameChannel.on('game_new_round', gameDiff => {
      const {game} = getState();
      const newGame = _formatRoundGame(game, gameDiff);
      consumeWells(dispatch, newGame);
      dispatch(sync.gameServerNewRound(newGame));
      startFrom(dispatch, gameDiff, true, false);
    });
    _gameChannel.on('game_end', gameDiff => {
      const {game} = getState();
      consumeWells(dispatch, game);
      dispatch(sync.gameServerEnd(_formatRoundGame(game, gameDiff)));
      startFrom(dispatch, gameDiff, true, true);
    });
    _gameChannel.on('game_abort', e => {
      dispatch(sync.gameServerAborted());
    });
    // Rely on promise for chaining
    dispatch(sync.gameChannelRequest());
    const promise = new Promise(function(resolve, reject) {
      _gameChannel.join()
        .receive('ok', resolve)
        .receive('error', reject)
        .receive('timeout', reject);
    });
    return promise.then(
      e => dispatch(sync.gameChannelSuccess()),
      e => dispatch(sync.gameChannelFailure())
    );
  };
}

export function setNickname(nickname) {
  return dispatch => {
    dispatch(sync.setNicknameRequest());
    const promise = new Promise(function(resolve, reject) {
      _playerChannel.push('init_nickname', nickname)
        .receive('ok', resolve)
        .receive('error', reject)
        .receive('timeout', reject);
    });
    return promise.then(
      res => dispatch(sync.setNicknameSuccess(res.nickname)),
      res => dispatch(sync.setNicknameFailure(res))
    );
  };
}

/* API - Push messages to channels
  Note: don't plug 'timeout' callback when this is a push with no reply
*/

export function loadMe() {
  return dispatch => {
    dispatch(sync.loadMeRequest());
    const promise = new Promise(function(resolve, reject) {
      _playerChannel.push('fetch')
        .receive('ok', resolve)
        .receive('error', reject)
        .receive('timeout', reject);
    });
    return promise.then(
      me => dispatch(sync.loadMeSuccess(me)),
      e => dispatch(sync.loadMeFailure())
    );
  };
}

export function bestLive() {
  return dispatch => {
    const promise = new Promise(function(resolve, reject) {
      _playerChannel.push('best_live')
        .receive('ok', resolve)
        .receive('error', reject)
        .receive('timeout', reject);
    });
    return promise.then(
      res => dispatch(sync.bestLiveSuccess(res.data))
    );
  };
}

export function best() {
  return dispatch => {
    const promise = new Promise(function(resolve, reject) {
      _playerChannel.push('best')
        .receive('ok', resolve)
        .receive('error', reject)
        .receive('timeout', reject);
    });
    return promise.then(
      res => dispatch(sync.bestSuccess(res.data))
    );
  };
}

// Simple refresh without dispatching REQUEST or FAILURE events
export function refreshMe() {
  return dispatch => {
    const promise = new Promise(function(resolve, reject) {
      _playerChannel.push('fetch')
        .receive('ok', resolve)
        .receive('error', reject)
        .receive('timeout', reject);
    });
    return promise.then(
      me => dispatch(sync.loadMeSuccess(me)),
      e => {}
    );
  };
}

export function goReady() {
  return dispatch => {
    dispatch(sync.ready());
    return new Promise(function(resolve, reject) {
      _playerChannel.push('ready')
        .receive('ok', resolve)
        .receive('error', reject);
    });
  };
}

export function goBusy() {
  return dispatch => {
    dispatch(sync.busy());
    return new Promise(function(resolve, reject) {
      _playerChannel.push('busy')
        .receive('ok', resolve)
        .receive('error', reject);
    });
  };
}

export function loadGame() {
  return (dispatch, getState) => {
    dispatch(sync.loadGameRequest());
    const promise = new Promise(function(resolve, reject) {
      _gameChannel.push('fetch')
        .receive('ok', resolve)
        .receive('error', reject)
        .receive('timeout', reject);
    });
    return promise.then(
      res => {
        const {me} = getState();
        dispatch(sync.loadOpponentSuccess(res.opponent));
        dispatch(sync.loadGameSuccess(_formatInitGame(res.game, me, res.opponent)));
        dispatch(sync.gameServerHistory(_formatInitHistory(res.game, me)));
        startFrom(dispatch, res.game);
      },
      e => dispatch(sync.loadGameFailure())
    );
  };
}

export function gameThrow(shape) {
  return dispatch => {
    const promise = new Promise(function(resolve, reject) {
      dispatch(sync.gameThrowRequest(shape));
      // 1s timeout
      _gameChannel.push('throw', {shape: shape}, 1000)
        .receive('ok', resolve)
        .receive('error', reject)
        .receive('timeout', reject);
    });

    return promise.then(
      e => dispatch(sync.gameThrowSuccess()),
      e => dispatch(sync.gameThrowFailure())
    );
  };
}

const consumeWells = function(dispatch, game) {
  if(game.prevRound.myShape === WELL) dispatch(sync.wellThrown());
  if(game.prevRound.opponentShape === WELL) dispatch(sync.opponentWellThrown());
}

// Format game fields so that it's centered on the client player (me VS opponent)
const _formatInitGame = function(game, me, opponent) {
  const index = game.player1_id === me.id ? 1 : 2;

  const output = {
    id: game.id,
    round: game.round,
    elapsed: game.elapsed,
    won: undefined,
    me: {
      index: index,
      wells: me.sheet.wells
    },
    opponent: {
      wells: opponent.sheet.wells
    },
    prevRound: {
      won: undefined,
      tie: undefined
    }
  };

  const myScoreLabel = index === 1 ? 'score1' : 'score2';
  if(myScoreLabel in game) output.me.score = game[myScoreLabel];

  const oppScoreLabel = index === 1 ? 'score2' : 'score1';
  if(oppScoreLabel in game) output.opponent.score = game[oppScoreLabel];

  return output;
}

const _formatInitHistory = function(game, me) {
  const index = game.player1_id === me.id ? 1 : 2;
  const output = {};

  const myHistoryLabel = index === 1 ? 'history1' : 'history2';
  if(myHistoryLabel in game) output.myHistory = game[myHistoryLabel];

  const oppHistoryLabel = index === 1 ? 'history2' : 'history1';
  if(oppHistoryLabel in game) output.oppHistory = game[oppHistoryLabel];

  return output;
}


const _formatRoundGame = function(game, diff) {
  const output = Object.assign({}, game);
  const index = game.me.index;

  if('round' in diff) output.round = diff.round;
  if('prev_winner' in diff) output.prevRound.won = diff.prev_winner === index;
  if('prev_winner' in diff) output.prevRound.tie = diff.prev_winner === 0;
  if('winner' in diff) output.won = diff.winner === index;

  const myScoreLabel = index === 1 ? 'score1' : 'score2';
  if(myScoreLabel in diff) output.me.score = diff[myScoreLabel];

  const oppScoreLabel = index === 1 ? 'score2' : 'score1';
  if(oppScoreLabel in diff) output.opponent.score = diff[oppScoreLabel];

  if(diff.prev_shapes !== undefined) {
    const arrayIndex = index - 1;
    output.prevRound.myShape = diff.prev_shapes[arrayIndex];
    output.prevRound.opponentShape = diff.prev_shapes[1 - arrayIndex];
  }

  output.me.shape = undefined;

  return output;
}
