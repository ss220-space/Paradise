import { useDispatch, useSelector } from 'tgui/backend';

import { selectDonations } from './selectors';

export const useDonations = () => {
  const state = useSelector(selectDonations);
  const dispatch = useDispatch();
  return {
    ...state,
    toggle: () => dispatch({ type: 'audio/toggle' }),
  };
};
