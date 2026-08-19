import { useBackend } from '../../backend';
import { type RecordsProps, SimpleRecords } from '../common/SimpleRecords';

export const pda_medical = (_props: unknown) => {
  const { data } = useBackend<RecordsProps>();
  return <SimpleRecords typeOfRecord="MED" {...data} />;
};
