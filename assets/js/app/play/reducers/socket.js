const initialState = {
  connected: false,
  connecting: false,
  networkError: false
};

const socket = (state = initialState, action) => {
  switch (action.type) {
    case 'EXIT_SUCCESS':
      return {...initialState};
    case 'CONNECT_SOCKET_REQUEST':
      return {connected: false, connecting: true, networkError: false};
    case 'CONNECT_SOCKET_SUCCESS':
      return {connected: true, connecting: false, networkError: false};
    case 'CONNECT_SOCKET_FAILURE':
      return {connected: false, connecting: false, networkError: true};
    default:
      return state;
  }
};

export default socket;
