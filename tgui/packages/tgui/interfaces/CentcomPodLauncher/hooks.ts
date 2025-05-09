import { useLocalState } from '../../backend';

export const useCompact = () => useLocalState('compact', false);

export const useTab = () => useLocalState('tab', 1);
