import * as sync from './sync';
                                      // Round - Time
export const GAME_SLEEP = -1;         //
export const GAME_SPLASH_SCREEN = 0;  // R0    - T0
export const GAME_INTRO = 1;          // R0    - T2500
export const GAME_POST_INTRO = 2;     // R0    - T4500
export const GAME_PRE_START = 3;      // R0    - T10000
export const GAME_START = 4;          // R1    - T0
export const ROUND_RESULT = 5;        // R1+   - T500
export const ROUND_START = 6;         // R1+   - T1500
export const ROUND_FREEZE = 7;        // R1+   - T7500
export const ROUND_REVEAL = 8;        // R2+   - T0     (replace GAME_START since round 2)
export const GAME_REVEAL = 9;         // R?    - T0     (replace ROUND_REVEAL when game is over)
export const GAME_RESULT = 10;        // R?    - T500
export const GAME_SUMMARY = 11;       // R?    - T1500

export function startFrom(dispatch, game, serverSent, gameEnded) {
  planner(dispatch, findStep(game, serverSent, gameEnded));
}


// Private
const BEAT = 8000;
const SPLASH_DURATION = 2500;
const COUNTDOWN = 6000;
const RESULT_DISPLAY = 3000;
const GAP = 500;
// used on page load
const findStep = function(game, serverSent, gameEnded) {
  if(serverSent) {
    if(gameEnded) {
      return GAME_REVEAL;
    } else {
      return game.round === 1 ? GAME_START : ROUND_REVEAL;
    }
  } else {
    if(game.round === 0) {
      if(game.elapsed < SPLASH_DURATION) {
        return GAME_SPLASH_SCREEN;
      } else if(game.elapsed < SPLASH_DURATION + BEAT - COUNTDOWN - GAP) {
        return GAME_INTRO;
      } else if(game.elapsed < SPLASH_DURATION + BEAT - GAP) {
        return GAME_POST_INTRO;
      } else {
        return GAME_PRE_START;
      }
    } else if(game.ended) {
      if(game.elapsed < GAP) {
        return GAME_REVEAL;
      } else if(game.elapsed < 3 * GAP) {
        return GAME_RESULT;
      } else {
        return GAME_SUMMARY;
      }
    } else {
      if(game.elapsed < GAP) {
        if(game.round === 1) {
          return GAME_START;
        } else {
          return ROUND_REVEAL;
        }
      } else if(game.elapsed < 3 * GAP) {
        return ROUND_RESULT;
      } else if(game.elapsed < BEAT - GAP) {
        return ROUND_START;
      } else {
        return ROUND_FREEZE;
      }
    }
  }
};

let planned = null;
const planner = function(dispatch, step) {
  // override and clear potentially planned step
  if(planned) clearTimeout(planned);
  // launch immediate step
  dispatch(sync.gameClientNewStep(step));
  // plan next step, does not dispatch GAME_SPLASH_SCREEN, GAME_START,
  // ROUND_REVEAL or GAME_REVEAL: it's done server-side
  if(step === GAME_SPLASH_SCREEN) {
    planned = setTimeout(() => planner(dispatch, GAME_INTRO), SPLASH_DURATION);
  } else if(step === GAME_INTRO) {
    planned = setTimeout(() => planner(dispatch, GAME_POST_INTRO), BEAT - COUNTDOWN - GAP);
  } else if(step === GAME_POST_INTRO) {
    planned = setTimeout(() => planner(dispatch, GAME_PRE_START), BEAT / 2);
  } else if(step === GAME_START) {
    planned = setTimeout(() => planner(dispatch, ROUND_RESULT), GAP);
  } else if(step === ROUND_REVEAL) {
    planned = setTimeout(() => planner(dispatch, ROUND_RESULT), GAP);
  } else if(step === ROUND_RESULT) {
    planned = setTimeout(() => planner(dispatch, ROUND_START), GAP * 2);
  } else if (step === ROUND_START) {
    planned = setTimeout(() => planner(dispatch, ROUND_FREEZE), BEAT - GAP * 4);
  } else if (step === GAME_REVEAL) {
    planned = setTimeout(() => planner(dispatch, GAME_RESULT), GAP);
  } else if (step === GAME_RESULT) {
    planned = setTimeout(() => planner(dispatch, GAME_SUMMARY), RESULT_DISPLAY);
  }
};
