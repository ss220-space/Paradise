import { useBackend } from '../../backend';
import { AtmosScan, type AtmosScanData } from '../common/AtmosScan';

export const pai_atmosphere = (_props: unknown) => {
  const { data } = useBackend<PaiData<AtmosScanData>>();

  return <AtmosScan {...data.app_data} />;
};
