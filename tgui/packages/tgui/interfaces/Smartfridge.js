import { useBackend } from '../backend';
import {
  Box,
  Section,
  Button,
  NumberInput,
  Stack,
  NoticeBox,
  Icon,
} from '../components';
import { Window } from '../layouts';

export const Smartfridge = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    secure, // secure fridge notice
    can_dry, // dry section
    drying, // drying rack on/off.
    contents,
  } = data;
  return (
    <Window width={500} height={500}>
      <Window.Content>
        <Stack fill vertical>
          {!!secure && (
            <NoticeBox>
              Требуется авторизация. Пожалуйста, предъявите свою ID-карту.
            </NoticeBox>
          )}
          <Section
            fill
            scrollable
            title={can_dry ? 'Сушильная стойка' : 'Содержимое'}
            buttons={
              !!can_dry && (
                <Button
                  width={11}
                  icon={drying ? 'power-off' : 'times'}
                  content={drying ? 'Начать сушку' : 'Закончить сушку'}
                  selected={drying}
                  onClick={() => act('drying')}
                />
              )
            }
          >
            {!contents && (
              <Stack fill>
                <Stack.Item
                  bold
                  grow
                  textAlign="center"
                  align="center"
                  color="average"
                >
                  <Icon.Stack>
                    <Icon name="cookie-bite" size={5} color="brown" />
                    <Icon name="slash" size={5} color="red" />
                  </Icon.Stack>
                  <br />
                  Хранилище пусто.
                </Stack.Item>
              </Stack>
            )}
            {!!contents &&
              contents
                .slice()
                .sort((a, b) => a.display_name.localeCompare(b.display_name))
                .map((item) => {
                  return (
                    <Stack key={item}>
                      <Stack.Item width="55%">{item.display_name}</Stack.Item>
                      <Stack.Item width="25%">
                        ({item.quantity} в наличии)
                      </Stack.Item>
                      <Stack.Item width={13}>
                        <Button
                          width={3}
                          icon="arrow-down"
                          tooltip="Взять одну штуку."
                          content="1"
                          onClick={() =>
                            act('vend', { index: item.vend, amount: 1 })
                          }
                        />
                        <NumberInput
                          width="40px"
                          minValue={0}
                          value={0}
                          maxValue={item.quantity}
                          step={1}
                          stepPixelSize={3}
                          onChange={(e, value) =>
                            act('vend', { index: item.vend, amount: value })
                          }
                        />
                        <Button
                          width={4}
                          icon="arrow-down"
                          content="Всё"
                          tooltip="Взять всё."
                          tooltipPosition="bottom-start"
                          onClick={() =>
                            act('vend', {
                              index: item.vend,
                              amount: item.quantity,
                            })
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  );
                })}
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
