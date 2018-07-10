const initialState = {
  joined: false,
  joining: false
};

const gameChannel = (state = initialState, action) => {
  switch (action.type) {
    case 'EXIT_SUCCESS':
      return {...initialState};
    case 'GAME_CHANNEL_REQUEST':
      return {joined: false, joining: true};
    case 'GAME_CHANNEL_SUCCESS':
      return {joined: true, joining: false};
    case 'GAME_CHANNEL_FAILURE':
      return {...initialState};
    case 'GAME_CHANNEL_LEAVE':
      return {...initialState};
    default:
      return state;
  }
};

export default gameChannel;
