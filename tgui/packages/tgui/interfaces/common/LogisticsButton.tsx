import { Button } from 'tgui-core/components';
import { useBackend } from '../../backend';

export const LogisticsButton = () => {
  const { act, data } = useBackend<{ logistics_enabled?: boolean }>();
  return (
    <Button
      icon="boxes"
      tooltip="Логистика"
      tooltipPosition="bottom"
      disabled={!data.logistics_enabled}
      onClick={() => act('open_logistics')}
    />
  );
};
