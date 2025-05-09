import { useBackend } from '../backend';
import {
  Section,
  Button,
  NumberInput,
  Stack,
  NoticeBox,
  Icon,
} from '../components';
import { Window } from '../layouts';

type SmartfridgeData = {
  secure: boolean; // secure fridge notice
  can_dry: boolean; // dry section
  drying: boolean; // drying rack on/off.
  contents: Item[];
};

type Item = {
  display_name: string;
  quantity: number;
  vend: string;
};

export const Smartfridge = (_props: unknown) => {
  const { act, data } = useBackend<SmartfridgeData>();
  const { secure, can_dry, drying, contents } = data;
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
                  selected={drying}
                  onClick={() => act('drying')}
                >
                  {drying ? 'Начать сушку' : 'Закончить сушку'}
                </Button>
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
                  <Icon.Stack style={{ transform: 'translate(-30px, -50px)' }}>
                    <Icon name="cookie-bite" size={5} color="brown" />
                    <Icon
                      name="slash"
                      size={5}
                      color="red"
                      style={{ transform: 'translate(-5px, 0)' }}
                    />
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
                    <Stack key={item.display_name}>
                      <Stack.Item width="55%">{item.display_name}</Stack.Item>
                      <Stack.Item width="25%">
                        ({item.quantity} в наличии)
                      </Stack.Item>
                      <Stack.Item width={13}>
                        <Button
                          width={3}
                          icon="arrow-down"
                          tooltip="Взять одну штуку."
                          onClick={() =>
                            act('vend', { index: item.vend, amount: 1 })
                          }
                        >
                          1
                        </Button>
                        <NumberInput
                          width="40px"
                          minValue={0}
                          value={0}
                          maxValue={item.quantity}
                          step={1}
                          stepPixelSize={3}
                          onChange={(value) =>
                            act('vend', { index: item.vend, amount: value })
                          }
                        />
                        <Button
                          width={4}
                          icon="arrow-down"
                          tooltip="Взять всё."
                          tooltipPosition="bottom-start"
                          onClick={() =>
                            act('vend', {
                              index: item.vend,
                              amount: item.quantity,
                            })
                          }
                        >
                          Всё
                        </Button>
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
