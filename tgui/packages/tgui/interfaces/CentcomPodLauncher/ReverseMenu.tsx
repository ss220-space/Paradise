import { useBackend } from '../../backend';
import { Button, Section, Stack } from '../../components';
import { REVERSE_OPTIONS } from './constants';
import { useTab } from './hooks';
import { PodLauncherData } from './types';

export const ReverseMenu = (props, context) => {
  const { act, data } = useBackend<PodLauncherData>(context);
  const {
    customDropoff,
    effectReverse,
    picking_dropoff_turf,
    reverse_option_list,
  } = data;

  const [tab, setTab] = useTab(context);

  return (
    <Section
      buttons={
        <Button
          icon={effectReverse ? 'toggle-on' : 'toggle-off'}
          onClick={() => {
            act('effectReverse');
            if (tab === 2) {
              setTab(1);
              act('tabSwitch', { tabIndex: 1 });
            }
          }}
          selected={effectReverse}
          tooltip={`
            Не отправляет товары.
            После приземления возвращается в
            стартовый турф (или ангар
            если ничего не указано).`}
        />
      }
      fill
      title="Возвращаемый"
    >
      {!!effectReverse && (
        <Stack fill vertical>
          <Stack.Item maxHeight="20px">
            <Button
              disabled={!effectReverse}
              onClick={() => act('pickDropoffTurf')}
              selected={picking_dropoff_turf}
              tooltip={`
                Куда возвращаемые капсулы
                летят после приземления`}
              tooltipPosition="bottom-end"
            >
              Точка возвращания
            </Button>
            <Button
              disabled={!customDropoff}
              icon="trash"
              inline
              onClick={() => {
                act('clearDropoffTurf');
                if (tab === 2) {
                  setTab(1);
                  act('tabSwitch', { tabIndex: 1 });
                }
              }}
              tooltip={`
                Очищает пользовательскую точку возврата. Возвращаемые капсулы будут
                вместо этого отправляться в
                выбранный ангар.`}
              tooltipPosition="bottom"
            />
          </Stack.Item>
          <Stack.Divider />
          <Stack.Item maxHeight="20px">
            {REVERSE_OPTIONS.map((option, i) => (
              <Button
                disabled={!effectReverse}
                key={i}
                icon={option.icon}
                inline
                onClick={() =>
                  act('reverseOption', {
                    reverseOption: option.key || option.title,
                  })
                }
                selected={
                  option.key
                    ? reverse_option_list[option.key]
                    : reverse_option_list[option.title]
                }
                tooltip={option.title}
              />
            ))}
          </Stack.Item>
        </Stack>
      )}
    </Section>
  );
};
