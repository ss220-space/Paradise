import { useBackend } from '../../backend';
import { Signaler, SignalerProps } from '../common/Signaler';

export const pai_signaler = (props: unknown) => {
  const { data } = useBackend<PaiData<SignalerProps>>();
  return <Signaler {...data.app_data} />;
};
