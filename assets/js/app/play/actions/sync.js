function makeActionCreator(type, ...argNames) {
  return function (...args) {
    let action = {type}
    argNames.forEach((arg, index) => {
      action[argNames[index]] = args[index]
    })
    return action
  }
}

// Connection actions
export const connectSocketRequest = makeActionCreator('CONNECT_SOCKET_REQUEST');
export const connectSocketSuccess = makeActionCreator('CONNECT_SOCKET_SUCCESS');
export const connectSocketFailure = makeActionCreator('CONNECT_SOCKET_FAILURE');
export const playerChannelRequest = makeActionCreator('PLAYER_CHANNEL_REQUEST');
export const playerChannelSuccess = makeActionCreator('PLAYER_CHANNEL_SUCCESS');
export const playerChannelFailure = makeActionCreator('PLAYER_CHANNEL_FAILURE');
export const gameChannelRequest = makeActionCreator('GAME_CHANNEL_REQUEST');
export const gameChannelSuccess = makeActionCreator('GAME_CHANNEL_SUCCESS');
export const gameChannelFailure = makeActionCreator('GAME_CHANNEL_FAILURE');
export const gameChannelLeave = makeActionCreator('GAME_CHANNEL_LEAVE');
export const updatePresence = makeActionCreator('UPDATE_PRESENCE', 'payload');
// Nickname
export const setNicknameRequest = makeActionCreator('SET_NICKNAME_REQUEST');
export const setNicknameSuccess = makeActionCreator('SET_NICKNAME_SUCCESS', 'payload');
export const setNicknameFailure = makeActionCreator('SET_NICKNAME_FAILURE', 'payload');
// Player pushes
export const loadMeRequest = makeActionCreator('LOAD_ME_REQUEST');
export const loadMeSuccess = makeActionCreator('LOAD_ME_SUCCESS', 'payload');
export const loadMeFailure = makeActionCreator('LOAD_ME_FAILURE');
export const ready = makeActionCreator('READY');
export const busy = makeActionCreator('BUSY');
export const wellThrown = makeActionCreator('WELL_THROWN');
export const opponentWellThrown = makeActionCreator('OPPONENT_WELL_THROWN');
export const bestLiveSuccess = makeActionCreator('BEST_LIVE_SUCCESS', 'payload');
export const bestSuccess = makeActionCreator('BEST_SUCCESS', 'payload');
// Game pushes
export const loadGameRequest = makeActionCreator('LOAD_GAME_REQUEST');
export const loadGameSuccess = makeActionCreator('LOAD_GAME_SUCCESS', 'payload');
export const loadGameFailure = makeActionCreator('LOAD_GAME_FAILURE');
export const loadOpponentSuccess = makeActionCreator('LOAD_OPPONENT_SUCCESS', 'payload');
// In game
export const gameServerJoinQuery = makeActionCreator('GAME_SERVER_JOIN_QUERY', 'payload');
export const gameServerHistory = makeActionCreator('GAME_SERVER_HISTORY', 'payload');
export const gameServerNewRound = makeActionCreator('GAME_SERVER_NEW_ROUND', 'payload');
export const gameServerEnd = makeActionCreator('GAME_SERVER_END', 'payload');
export const gameServerAborted = makeActionCreator('GAME_SERVER_ABORTED');
export const gameClientNewStep = makeActionCreator('GAME_CLIENT_NEW_STEP', 'payload');
export const gameClientReset = makeActionCreator('GAME_CLIENT_RESET');
export const wellWon = makeActionCreator('WELL_WON');// used only for summary effect
// Throw
export const gameThrowRequest = makeActionCreator('GAME_THROW_REQUEST', 'payload');
export const gameThrowSuccess = makeActionCreator('GAME_THROW_SUCCESS', 'payload');
export const gameThrowFailure = makeActionCreator('GAME_THROW_FAILURE', 'payload');
