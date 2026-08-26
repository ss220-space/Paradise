import { ReactNode } from 'react';
import { useBackend } from '../backend';
import { declension_ru } from 'common/string';
import {
  Button,
  LabeledList,
  Section,
  Stack,
  NumberInput,
  Dimmer,
  Icon,
  Box,
  Modal,
  ByondUi,
  Dropdown,
  Table,
} from '../components';
import { classes } from 'common/react';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

type SkillManualsShopData = {
  cash: number;
  refresh_available: boolean;
  manuals: ManualData[];
};

type ManualData = {
  type: string;
  name: string;
  desc: string;
  price: number;
  amount: number;
};

export const SkillManualsShop = (props: unknown) => {
  const { act, data } = useBackend<SkillManualsShopData>();

  return (
    <Window width={600} height={600}>
      <Window.Content>
        <ComplexModal />
        <Stack fill vertical>
          <Stack.Item>
            <Box>
              <b>Баланс:</b> {data.cash} кредитов.
            </Box>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              scrollable
              fill
              title="Список товаров"
              buttons={
                <Button
                  icon="refresh"
                  disabled={!data.refresh_available}
                  color="green"
                  onClick={() => act('refresh')}
                >
                  Обновить ассортимент
                </Button>
              }
            >
              <Box>
                <Table p="0">
                  {data.manuals.map((manual, index) => (
                    <Table.Row
                      key={index}
                      className={index % 2 === 0 ? 'row-even' : 'row-odd'}
                    >
                      <Table.Cell
                        width="40%"
                        textAlign="left"
                        pt="5px"
                        pb="5px"
                        pl="10px"
                      >
                        {manual.name}
                      </Table.Cell>
                      <Table.Cell
                        width="40%"
                        textAlign="left"
                        pr="2%"
                        pt="5px"
                        pb="5px"
                      >
                        {manual.desc}
                      </Table.Cell>
                      <Table.Cell
                        width="10%"
                        textAlign="left"
                        pr="5px"
                        pt="5px"
                        pb="5px"
                        pl="10px"
                      >
                        {manual.amount} шт.
                      </Table.Cell>
                      <Table.Cell
                        width="10%"
                        textAlign="left"
                        pr="5px"
                        pt="5px"
                        pb="5px"
                        pl="10px"
                      >
                        <Button
                          icon="credit-card"
                          color="green"
                          disabled={manual.amount <= 0}
                          align="center"
                          onClick={() => act('purchase', { type: manual.type })}
                          width="100%"
                        >
                          {manual.price} кр.
                        </Button>
                      </Table.Cell>
                    </Table.Row>
                  ))}
                </Table>
              </Box>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
