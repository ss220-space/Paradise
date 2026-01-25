import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Section, DmIcon, Button, Stack, NoticeBox, Tabs } from '../components';
import { toTitleCase } from 'common/string';

type Design = {
  name: string;
  desc: string;
  cost: Record<string, number>;
  id: string;
  categories: string[];
  icon: string;
  IconState: string;
};

type Material = {
  name: string;
  ref: string;
  amount: number;
};

type ComponentPrinterData = {
  designs: Record<string, Design>;
  materials: Material[];
  current_tab: number;
};

export const ComponentPrinter = (props) => {
  const { act, data } = useBackend<ComponentPrinterData>();
  const { designs } = data;

  return (
    <Window title={'Дубликатор печатных плат'} width={670} height={600}>
      <Window.Content>

        <Tabs>
          <Tabs.Tab
            selected={data.current_tab === 0}
            onClick={() => act('switch_tab', { tab: 0 })}
          >
            Printer
          </Tabs.Tab>
          <Tabs.Tab
            selected={data.current_tab === 1}
            onClick={() => act('switch_tab', { tab: 1 })}
          >
            Library
          </Tabs.Tab>
        </Tabs>

        {data.current_tab === 0 && (
        <Box>
          {Object.values(designs).length === 0 && (
            <Stack.Item mt={1} fontSize={1}>
              <NoticeBox info>Сохранённые схемы отсутствуют.</NoticeBox>
            </Stack.Item>
          )}
          {Object.values(designs).map((design) => (
            <Section key={design.id} style={{ position: 'relative'}}>
              <DmIcon
                icon={design.icon}
                icon_state={design.IconState}
                style={{
                  verticalAlign: 'middle',
                  width: '32px',
                  margin: '0px',
                  marginLeft: '0px',
                }}
              />
              <Button
                mr={1}
                icon="hammer"
                tooltip={design.desc}
                onClick={() =>
                  act('print', {
                    designId: design.id,
                  })
                }
              >
                {toTitleCase(design.name)}
              </Button>

              <Box style={{ display: 'inline' }}>
                {(design.cost &&
                  Object.keys(design.cost)
                    .map((mat) => toTitleCase(mat) + ': ' + design.cost[mat])
                    .join(', ')) || <Box>Ресурсы для печати не требуются.</Box>}
              </Box>
              <Box
                style={{
                  position: 'absolute',
                  right: '8px',
                  top: '8px',
                  display: 'flex',
                  gap: '5px',
                }}
              >
                <Button
                  icon="save"
                  onClick={() =>
                    act('export', {
                      designId: design.id,
                    })
                  }
                >
                  {toTitleCase("Export")}
                </Button>
                <Button
                  icon="trash-can"
                  onClick={() =>
                    act('del_design', {
                      designId: design.id,
                    })
                  }
                />
              </Box>
            </Section>
          ))}
        </Box>
        )}
        {data.current_tab === 1 && (
          <Box>
            <p>text</p>
          </Box>
        )}
      </Window.Content>
    </Window>
  );
};
