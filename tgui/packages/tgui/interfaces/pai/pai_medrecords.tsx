import { useBackend } from '../../backend';
import { type RecordsProps, SimpleRecords } from '../common/SimpleRecords';

export const pai_medrecords = (_props: unknown) => {
  const { data } = useBackend<PaiData<RecordsProps>>();
  return <SimpleRecords typeOfRecord="MED" {...data.app_data} />;
};
