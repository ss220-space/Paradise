import { useBackend } from '../../backend';
import { AtmosScan, AtmosScanData } from '../common/AtmosScan';

export const pda_atmos_scan = (props: unknown) => {
  const { data } = useBackend<AtmosScanData>();
  return <AtmosScan {...data} />;
};
