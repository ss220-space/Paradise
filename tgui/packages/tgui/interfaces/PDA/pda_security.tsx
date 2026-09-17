import { useBackend } from '../../backend';
import { type RecordsProps, SimpleRecords } from '../common/SimpleRecords';

export const pda_security = (_props: unknown) => {
  const { data } = useBackend<RecordsProps>();
  return <SimpleRecords typeOfRecord="SEC" {...data} />;
};
