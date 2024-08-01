/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

const initialState = {
  visible: false,
  playing: false,
  muted: false,
  duration: 0,
};

export const audioReducer = (state = initialState, action) => {
  const { type, payload } = action;
  if (type === 'audio/playing') {
    return {
      ...state,
      visible: !state.muted,
      playing: true,
      duration: payload.duration,
    };
  }
  if (type === 'audio/stopped') {
    return {
      ...state,
      visible: false,
      playing: false,
    };
  }
  if (type === 'audio/playMusic') {
    return {
      ...state,
      meta: payload,
    };
  }
  if (type === 'audio/playWorldMusic') {
    return {
      ...state,
      meta: payload,
    };
  }
  if (type === 'audio/onMute') {
    return {
      ...state,
      muted: true,
      visible: false,
    };
  }
  if (type === 'audio/onUnmute') {
    return {
      ...state,
      muted: false,
    };
  }
  if (type === 'audio/toggle') {
    return {
      ...state,
      visible: !state.visible,
    };
  }
  return state;
};
