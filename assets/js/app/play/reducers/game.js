import * as sequencer from '../actions/sequencer';

const initialState = {
  fetching: false,
  fetched: false,
  joinAsked: false,
  ended: false,
  aborted: false,
  step: sequencer.GAME_SLEEP,
  wellWon: false
};

const historyToWells = (history) => (
  history.replace(/[^w]/g, "").length
);

const game = (state = initialState, action) => {
  switch (action.type) {
    case 'EXIT_SUCCESS':
      return {...initialState};
    case 'LOAD_GAME_REQUEST':
      return {...state, fetching: true, fetched: false}
    case 'LOAD_GAME_SUCCESS':
      return {
        ...state,
        ...action.payload,
        fetching: false,
        fetched: true
      };
    case 'LOAD_GAME_FAILURE':
      return {
        ...state,
        fetching: false,
        fetched: false
      };
    case 'GAME_SERVER_JOIN_QUERY':
      return {
        ...state,
        id: action.payload.id,
        joinAsked: true
      };
    case 'GAME_SERVER_NEW_ROUND':
      return {...state, ...action.payload};
    case 'GAME_CLIENT_NEW_STEP':
      return {
        ...state,
        step: action.payload
      };
    case 'GAME_SERVER_END':
      return {
        ...state,
        ...action.payload,
        joinAsked: false,
        ended: true
      };
    case 'GAME_CLIENT_RESET':
      return {...initialState};
    case 'GAME_SERVER_ABORTED':
      return {
        ...state,
        joinAsked: false,
        aborted: true
      };
    case 'GAME_SERVER_HISTORY': {
      const myConsumed = historyToWells(action.payload.myHistory);
      const oppConsumed = historyToWells(action.payload.oppHistory);
      const newState = Object.assign({}, state);
      newState.me.wells = state.me.wells - myConsumed;
      newState.opponent.wells = state.opponent.wells - oppConsumed;
      return newState;
    }
    case 'WELL_THROWN': {
      const newState = Object.assign({}, state);
      newState.me.wells = state.me.wells - 1;
      return newState;
    }
    case 'OPPONENT_WELL_THROWN': {
      const newState = Object.assign({}, state);
      newState.opponent.wells = state.opponent.wells - 1;
      return newState;
    }
    case 'WELL_WON': {
      return {
        ...state,
        wellWon: true
      };
    }
    default:
      return state
  }
};

export default game;
