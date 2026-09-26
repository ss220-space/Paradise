import { useBackend } from '../../backend';
import { Signaler, type SignalerProps } from '../common/Signaler';

export const pda_signaler = (props: unknown) => {
  const { data } = useBackend<SignalerProps>();
  return <Signaler {...data} />;
};
