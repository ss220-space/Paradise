import { useBackend } from '../../backend';
import { RecordsProps, SimpleRecords } from '../common/SimpleRecords';

export const pai_medrecords = (props: unknown) => {
  const { data } = useBackend<PaiData<RecordsProps>>();
  return <SimpleRecords recordType="MED" {...data.app_data} />;
};
