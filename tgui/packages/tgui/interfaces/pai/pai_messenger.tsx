import { useBackend } from '../../backend';
import {
  ActiveConversation,
  MessenderData,
  MessengerList,
} from '../pda/pda_messenger';

export const pai_messenger = (props: unknown) => {
  const { data } = useBackend<PaiData<MessenderData>>();
  const { active_convo } = data.app_data;

  if (active_convo) {
    return <ActiveConversation {...data.app_data} />;
  }
  return <MessengerList {...data.app_data} />;
};
