const initialState = {
  playersCount: 0
};

const presenceChannel = (state = initialState, action) => {
  switch (action.type) {
    case 'UPDATE_PRESENCE':
      return {...state, playersCount: action.payload};
    default:
      return state;
  }
};

export default presenceChannel;
