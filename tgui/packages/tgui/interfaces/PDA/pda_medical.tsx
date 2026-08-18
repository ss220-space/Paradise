import { useBackend } from '../../backend';
import { type RecordsProps, SimpleRecords } from '../common/SimpleRecords';

export const pda_medical = (props: unknown) => {
  const { data } = useBackend<RecordsProps>();
  return <SimpleRecords recordType="MED" {...data} />;
};
