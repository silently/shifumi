const initialState = {
  bestLive: undefined,
  best: undefined
};

const socket = (state = initialState, action) => {
  switch (action.type) {
    case 'BEST_LIVE_SUCCESS':
      return {...state, bestLive: action.payload};
    case 'BEST_SUCCESS':
      return {...state, best: action.payload};
    default:
      return state;
  }
};

export default socket;
