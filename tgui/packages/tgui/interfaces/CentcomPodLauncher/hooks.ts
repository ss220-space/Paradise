import { useLocalState } from '../../backend';

export const useCompact = (context) => useLocalState(context, 'compact', false);

export const useTab = (context) => useLocalState(context, 'tab', 1);
