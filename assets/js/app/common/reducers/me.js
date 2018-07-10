// Load from localStorage
let persistedAvatar = localStorage.getItem('avatar') ? JSON.parse(localStorage.getItem('avatar')) : {};

// Inconsistent localStorage has to get cleaned up
if(persistedAvatar.player_id !== window.playerId) {
  localStorage.removeItem('avatar');
  persistedAvatar = {};
}

const initialAvatar = Object.assign(persistedAvatar, {
  fetched: false,
  fetching: false,
  updating: false,
  updated: false,
  errors: undefined
});

const initialState = {
  id: window.playerId,
  fetched: false,
  fetching: false,
  ready: false,
  nicknameNeeded: true,
  avatar: initialAvatar,
  sheet: {
    fetched: false,
    fetching: false
  }
};

const historyToWells = (history) => (
  history.replace(/[^w]/g, "").length
);

const me = (state = initialState, action) => {
  switch (action.type) {
    case 'EXIT_SUCCESS':
      return {...initialState};
    case 'LOAD_ME_REQUEST': {
      const avatar = {...state.avatar, fetched: false, fetching: true};
      const sheet = {...state.sheet, fetched: false, fetching: true};
      return {...state, avatar, sheet, fetched: false, fetching: true};
    }
    case 'LOAD_ME_SUCCESS': {
      const avatar = {...action.payload.avatar, player_id: state.id, fetched: true, fetching: false};
      const sheet = {...action.payload.sheet, fetched: true, fetching: false};
      const nicknameNeeded = !action.payload.avatar.nickname;
      return {...state, avatar, sheet, nicknameNeeded, fetched: true, fetching: false};
    }
    case 'LOAD_ME_FAILURE': {
      const avatar = {...state.avatar, fetched: false, fetching: false};
      const sheet = {...state.sheet, fetched: false, fetching: false};
      return {...state, avatar, sheet, nicknameNeeded: true, fetched: false, fetching: false};
    }
    case 'LOAD_AVATAR_REQUEST': {
      const avatar = {...state.avatar, fetched: false, fetching: true};
      return {...state, avatar};
    }
    case 'LOAD_AVATAR_SUCCESS': {
      const avatar = {...action.payload, fetched: true, fetching: false};
      const nicknameNeeded = !action.payload.nickname;
      return {...state, avatar, nicknameNeeded};
    }
    case 'LOAD_AVATAR_FAILURE': {
      const avatar = {...state.avatar, fetched: false, fetching: false};
      return {...state, avatar};
    }
    case 'UPDATE_AVATAR_REQUEST': {
      const avatar = {...state.avatar, errors: undefined, updated: false, updating: true};
      return {...state, avatar};
    }
    case 'UPDATE_AVATAR_SUCCESS': {
      const avatar = {...action.payload, updated: true, updating: false};
      return {...state, avatar};
    }
    case 'UPDATE_AVATAR_FAILURE': {
      const avatar = {...state.avatar, errors: action.payload, updated: false, updating: false};
      return {...state, avatar};
    }
    case 'SET_NICKNAME_SUCCESS': {
      const avatar = {...state.avatar, nickname: action.payload};
      const nicknameNeeded = !action.payload;
      return {...state, avatar, nicknameNeeded};
    }
    case 'SET_NICKNAME_FAILURE': {
      const avatar = Object.assign({}, action.payload);
      const nicknameNeeded = true;
      return {...state, avatar, nicknameNeeded};
    }
    case 'READY':
      return {...state, ready: true};
    case 'BUSY':
      return {...state, ready: false};
    case 'GAME_SERVER_JOIN_QUERY':
      return state.ready ? {...state, ready: false} : state;
    case 'WELL_THROWN':
      const sheet = Object.assign({}, state.sheet);
      sheet.wells = sheet.wells - 1;
      return {...state, sheet};
      case 'GAME_SERVER_HISTORY': {
        const sheet = Object.assign({}, state.sheet);
        const myConsumed = historyToWells(action.payload.myHistory);
        sheet.wells = sheet.wells - myConsumed;
        return {...state, sheet};
      }
    default:
      return state;
  }
};

export default me;
