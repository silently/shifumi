function makeActionCreator(type, ...argNames) {
  return function (...args) {
    let action = {type}
    argNames.forEach((arg, index) => {
      action[argNames[index]] = args[index]
    })
    return action
  }
}

export const loadAvatarRequest = makeActionCreator('LOAD_AVATAR_REQUEST');
export const loadAvatarSuccess = makeActionCreator('LOAD_AVATAR_SUCCESS', 'payload');
export const loadAvatarFailure = makeActionCreator('LOAD_AVATAR_FAILURE');

export const updateAvatarRequest = makeActionCreator('UPDATE_AVATAR_REQUEST');
export const updateAvatarSuccess = makeActionCreator('UPDATE_AVATAR_SUCCESS', 'payload');
export const updateAvatarFailure = makeActionCreator('UPDATE_AVATAR_FAILURE', 'payload');
