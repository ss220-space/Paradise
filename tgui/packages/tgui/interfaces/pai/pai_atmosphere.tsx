import { useBackend } from '../../backend';
import { AtmosScan, AtmosScanData } from '../common/AtmosScan';

export const pai_atmosphere = (props: unknown) => {
  const { data } = useBackend<PaiData<AtmosScanData>>();

  return <AtmosScan {...data.app_data} />;
};
