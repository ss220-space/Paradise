/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { autoReconnect, connectionLost } from './actions';
import { connectionRestored } from './actions';
import { roundRestarted } from './actions';
import { AUTO_RECONNECT_AFTER } from './constants';

const getRandomIntInclusive = (min, max) => {
  const minCeiled = Math.ceil(min);
  const maxFloored = Math.floor(max);
  return Math.floor(Math.random() * (maxFloored - minCeiled + 1) + minCeiled);
};

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
    return {
      ...state,
      roundRestartedAt: meta.now,
      autoReconnectAfter:
        // Add a random amount of time to the auto reconnect time
        // to avoid all clients reconnecting at the same time
        // from 0 to 15 seconds with 100ms step
        meta.now + AUTO_RECONNECT_AFTER + getRandomIntInclusive(0, 150) * 100,
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
