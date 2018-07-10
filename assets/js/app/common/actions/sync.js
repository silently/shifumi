function makeActionCreator(type, ...argNames) {
  return function (...args) {
    let action = {type}
    argNames.forEach((arg, index) => {
      action[argNames[index]] = args[index]
    })
    return action
  }
}

export const navigate = makeActionCreator('NAVIGATE', 'payload');

export const exitRequest = makeActionCreator('EXIT_REQUEST');
export const exitSuccess = makeActionCreator('EXIT_SUCCESS');
export const exitFailure = makeActionCreator('EXIT_FAILURE');
