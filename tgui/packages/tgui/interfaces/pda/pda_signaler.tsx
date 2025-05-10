import { useBackend } from '../../backend';
import { Signaler, SignalerProps } from '../common/Signaler';

export const pda_signaler = (props: unknown) => {
  const { data } = useBackend<SignalerProps>();
  return <Signaler {...data} />;
};
