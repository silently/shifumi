const initialState = {
  joined: false,
  joining: false
};

const playerChannel = (state = initialState, action) => {
  switch (action.type) {
    case 'EXIT_SUCCESS':
      return {...initialState};
    case 'PLAYER_CHANNEL_REQUEST':
      return {joined: false, joining: true};
    case 'PLAYER_CHANNEL_SUCCESS':
      return {joined: true, joining: false};
    case 'PLAYER_CHANNEL_FAILURE':
      return {...initialState};
    default:
      return state;
  }
};

export default playerChannel;
