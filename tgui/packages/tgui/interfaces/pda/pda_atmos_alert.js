import { useBackend } from "../../backend";
import { AtmosArertConsole } from '../AtmosAlertConsole';

export const pda_power = (props, context) => {
  const { act, data } = useBackend(context);

  return <AtmosArertConsole />;
};
