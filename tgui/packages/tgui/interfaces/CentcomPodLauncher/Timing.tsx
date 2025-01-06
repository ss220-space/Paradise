import { useBackend } from '../../backend';
import { Button, Divider, Section } from '../../components';
import { DELAYS, REV_DELAYS } from './constants';
import { DelayHelper } from './DelayHelper';
import { PodLauncherData } from './types';

export const Timing = (props, context) => {
  const { act, data } = useBackend<PodLauncherData>(context);
  const { custom_rev_delay, effectReverse } = data;

  return (
    <Section
      buttons={
        <>
          <Button
            color="transparent"
            icon="undo"
            onClick={() => act('resetTiming')}
            tooltip={`
            Сбросить тайминги
            /задержки капсул`}
            tooltipPosition="bottom-end"
          />
          <Button
            color="transparent"
            disabled={!effectReverse}
            icon={custom_rev_delay === 1 ? 'toggle-on' : 'toggle-off'}
            onClick={() => act('toggleRevDelays')}
            selected={custom_rev_delay}
            tooltip={`
            Переключить задержки возврата
            Примечание: при включенной опции переключатели
            обращают вспять задержки капсул`}
            tooltipPosition="bottom-end"
          />
        </>
      }
      title="Время"
    >
      {!custom_rev_delay ? (
        <DelayHelper delay_list={DELAYS} />
      ) : (
        <DelayHelper delay_list={REV_DELAYS} reverse />
      )}
    </Section>
  );
};
