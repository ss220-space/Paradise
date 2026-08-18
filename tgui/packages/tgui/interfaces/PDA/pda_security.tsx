import { useBackend } from '../../backend';
import { type RecordsProps, SimpleRecords } from '../common/SimpleRecords';

export const pda_security = (props: unknown) => {
  const { data } = useBackend<RecordsProps>();
  return <SimpleRecords recordType="SEC" {...data} />;
};
