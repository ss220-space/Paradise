import { useBackend } from '../../backend';
import { type RecordsProps, SimpleRecords } from '../common/SimpleRecords';

export const pai_secrecords = (_props: unknown) => {
  const { data } = useBackend<PaiData<RecordsProps>>();
  return <SimpleRecords typeOfRecord="SEC" {...data.app_data} />;
};
