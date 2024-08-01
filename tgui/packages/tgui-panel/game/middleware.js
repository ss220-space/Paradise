/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { pingSoft, pingSuccess } from '../ping/actions';
import {
  connectionLost,
  connectionRestored,
  roundRestarted,
  autoReconnect,
} from './actions';
import { selectGame } from './selectors';
import { CONNECTION_LOST_AFTER, AUTO_RECONNECT_AFTER } from './constants';

const withTimestamp = (action) => ({
  ...action,
  meta: {
    ...action.meta,
    now: Date.now(),
  },
});

export const gameMiddleware = (store) => {
  let lastPingedAt;
  setInterval(() => {
    const state = store.getState();
    if (!state) {
      return;
    }
    const game = selectGame(state);
    const pingsAreFailing =
      lastPingedAt && Date.now() >= lastPingedAt + CONNECTION_LOST_AFTER;
    const shouldAutoReconnect =
      game.autoReconnectAfter && Date.now() >= game.autoReconnectAfter;
    if (!game.connectionLostAt && pingsAreFailing) {
      store.dispatch(withTimestamp(connectionLost()));
    }
    if (game.connectionLostAt && !pingsAreFailing) {
      store.dispatch(withTimestamp(connectionRestored()));
    }
    if (shouldAutoReconnect) {
      store.dispatch(autoReconnect());
    }
  }, 1000);
  return (next) => (action) => {
    const { type } = action;

    if (type === pingSuccess.type || type === pingSoft.type) {
      lastPingedAt = Date.now();
      return next(action);
    }
    if (type === roundRestarted.type) {
      return next(withTimestamp(action));
    }
    if (type === autoReconnect.type) {
      Byond.command('.reconnect');
      return;
    }

    return next(action);
  };
};
