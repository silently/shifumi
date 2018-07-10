const initialState = {
  path: window.location.pathname,
  csrfToken: window.csrfToken,
  logged: !!window.playerId,
  playerId: window.playerId,
  playerToken: window.playerToken,
  flash: window.flash,
  playersCount: parseInt(window.playersCount || 0)
};

const session = (state = initialState, action) => {
  switch (action.type) {
    case 'NAVIGATE':
      return {...state, path: action.payload};
    case 'EXIT_REQUEST':
      return {...state, exiting: true};
    case 'EXIT_SUCCESS':
      return {...state, exiting: false, logged: false};
    case 'EXIT_FAILURE':
      return {...state, exiting: false};
    default:
      return state;
  }
};

export default session;
