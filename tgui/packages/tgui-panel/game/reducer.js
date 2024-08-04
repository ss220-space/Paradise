/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { autoReconnect, connectionLost } from './actions';
import { connectionRestored } from './actions';
import { roundRestarted } from './actions';
import { AUTO_RECONNECT_AFTER } from './constants';

const initialState = {
  // TODO: This is where round info should be.
  roundId: null,
  roundTime: null,
  roundRestartedAt: null,
  connectionLostAt: null,
  autoReconnectAfter: null,
};

export const gameReducer = (state = initialState, action) => {
  const { type, payload, meta } = action;
  if (type === roundRestarted.type) {
    const { autoreconnect, position } = payload;
    return {
      ...state,
      roundRestartedAt: meta.now,
      autoReconnectAfter:
        // Add a delay to the auto reconnect time to avoid all clients
        // reconnecting at the same time with 500ms step
        autoreconnect ? meta.now + AUTO_RECONNECT_AFTER + position * 500 : null,
    };
  }
  if (type === connectionLost.type) {
    return {
      ...state,
      connectionLostAt: meta.now,
    };
  }
  if (type === connectionRestored.type) {
    return {
      ...state,
      connectionLostAt: null,
    };
  }
  if (type === autoReconnect.type) {
    return {
      ...state,
      autoReconnectAfter: null,
    };
  }
  return state;
};
