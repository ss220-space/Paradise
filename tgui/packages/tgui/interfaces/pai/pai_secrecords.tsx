import { useBackend } from '../../backend';
import { RecordsProps, SimpleRecords } from '../common/SimpleRecords';

export const pai_secrecords = (props: unknown) => {
  const { data } = useBackend<PaiData<RecordsProps>>();
  return <SimpleRecords recordType="SEC" {...data.app_data} />;
};
