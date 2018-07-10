const initialState = {
  fetching: false,
  fetched: false
};

const opponent = (state = initialState, action) => {
  switch (action.type) {
    case 'EXIT_SUCCESS':
      return {...initialState};
    case 'LOAD_GAME_REQUEST':
      return {...state, fetching: true, fetched: false}
    case 'LOAD_OPPONENT_SUCCESS':
      return {
        ...state,
        ...action.payload,
        fetching: false,
        fetched: true
      };
    case 'LOAD_GAME_FAILURE':
      return {
        fetching: false,
        fetched: false
      };
    case 'GAME_CLIENT_RESET':
      return {...initialState};
    case 'OPPONENT_WELL_THROWN':
      const sheet = Object.assign({}, state.sheet);
      sheet.wells = sheet.wells - 1;
      return {...state, sheet};
    default:
      return state
  }
};

export default opponent;
