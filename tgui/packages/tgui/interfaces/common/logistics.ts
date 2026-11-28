// Keep these values in sync with code/__DEFINES/logistics.dm.
export const LOGISTICS_MODE_SEND = 1;
export const LOGISTICS_MODE_RECEIVE = 2;

export type LogisticsMode =
  | typeof LOGISTICS_MODE_SEND
  | typeof LOGISTICS_MODE_RECEIVE;
