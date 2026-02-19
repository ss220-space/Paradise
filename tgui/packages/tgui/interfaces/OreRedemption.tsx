import { classes } from 'common/react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Stack,
  Icon,
  LabeledList,
  NumberInput,
  Section,
  Tabs,
} from '../components';
import { Window } from '../layouts';
import { SectionProps } from '../components/Section';
import { useState } from 'react';

const formatPoints = (amt: number) => amt.toLocaleString('en-US') + ' ед.';

export const OreRedemption = (properties) => {
  const [tabIndex, setTabIndex] = useState(0);
  return (
    <Window width={490} height={700}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <IdDisk height="100%" />
          </Stack.Item>
          <Tabs>
            <Tabs.Tab selected={tabIndex === 0} onClick={() => setTabIndex(0)}>
              Листы материалов
            </Tabs.Tab>
            <Tabs.Tab selected={tabIndex === 1} onClick={() => setTabIndex(1)}>
              Сплавы
            </Tabs.Tab>
          </Tabs>
          {tabIndex === 0 && <Sheet mt={-2} />}
          {tabIndex === 1 && <Alloy mt={-2} />}
        </Stack>
      </Window.Content>
    </Window>
  );
};

type OreRedemptionData = {
  id: ID;
  points: number;
  disk: Disk;
  sheets: Ore[];
  alloys: Ore[];
};

type ID = {
  name: string;
  points: number;
  total_points: number;
};

type Disk = {
  name: string;
  design: string;
  compatible: boolean;
};

type Ore = {
  name: string;
  id: string;
  value: number;
  amount: number;
  description: string;
};

const IdDisk = (properties: SectionProps) => {
  const { act, data } = useBackend<OreRedemptionData>();
  const { id, points, disk } = data;
  const { ...rest } = properties;
  return (
    <Section {...rest}>
      <LabeledList>
        <LabeledList.Item label="ID-карта">
          {id ? (
            <Button
              selected
              bold
              verticalAlign="middle"
              icon="eject"
              tooltip="Извлечь ID-карту."
              onClick={() => act('eject_id')}
              style={{
                whiteSpace: 'pre-wrap',
              }}
            >
              {id.name}
            </Button>
          ) : (
            <Button
              icon="sign-in-alt"
              tooltip="Вставить ID-карту в вашей руке."
              onClick={() => act('insert_id')}
            >
              Вставить
            </Button>
          )}
        </LabeledList.Item>
        {id && (
          <LabeledList.Item label="Счёт шахтёрских очков">
            <Box bold>{formatPoints(id.points)}</Box>
          </LabeledList.Item>
        )}
        {id && (
          <LabeledList.Item label="Всего шахтёрских очков">
            <Box bold>{formatPoints(id.total_points)}</Box>
          </LabeledList.Item>
        )}
        <LabeledList.Item
          label="Буфер шахтёрских очков"
          color={points > 0 ? 'good' : 'grey'}
        >
          {formatPoints(points)}
        </LabeledList.Item>
        <LabeledList.Item>
          <Button
            disabled={!id}
            icon="hand-holding-usd"
            onClick={() => act('claim')}
          >
            Получить
          </Button>
        </LabeledList.Item>
      </LabeledList>
      <Divider />
      {disk ? (
        <LabeledList>
          <LabeledList.Item label="Дискета шаблона печати">
            <Button
              selected
              bold
              icon="eject"
              tooltip="Извлечь дискету."
              onClick={() => act('eject_disk')}
            >
              {disk.name}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Загруженный шаблон">
            <Box color={disk.design && (disk.compatible ? 'good' : 'bad')}>
              {disk.design || 'Н/Д'}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item>
            <Button
              disabled={!disk.design || !disk.compatible}
              icon="upload"
              tooltip="Загрузить шаблон печати в память машины."
              onClick={() => act('download')}
            >
              Загрузить
            </Button>
          </LabeledList.Item>
        </LabeledList>
      ) : (
        <Box color="label">Дискета шаблона печати отсутствует.</Box>
      )}
    </Section>
  );
};

/*
Manages titles under "Sheet"
*/

const Sheet = (properties: SectionProps) => {
  const { data } = useBackend<OreRedemptionData>();
  const { sheets } = data;
  const { ...rest } = properties;
  return (
    <Stack.Item grow height="20%">
      <Section fill scrollable className="OreRedemption__Ores" p="0" {...rest}>
        <OreHeader
          title="Листы материалов"
          columns={[
            ['Доступно', '20%'],
            ['Стоимость руды', '25%'],
            ['Переплавить', '10%'],
          ]}
        />
        {sheets.map((sheet) => (
          <SheetLine key={sheet.id} ore={sheet} />
        ))}
      </Section>
    </Stack.Item>
  );
};

/*
Manages titles under "Alloy"
*/

const Alloy = (properties: SectionProps) => {
  const { data } = useBackend<OreRedemptionData>();
  const { alloys } = data;
  const { ...rest } = properties;
  return (
    <Stack.Item grow>
      <Section fill scrollable className="OreRedemption__Ores" p="0" {...rest}>
        <OreHeader
          title="Сплавы"
          columns={[
            ['Рецепт', '30%'],
            ['Доступно', '15%'],
            ['Переплавить', '10%'],
          ]}
        />
        {alloys.map((alloy) => (
          <AlloyLine key={alloy.id} ore={alloy} />
        ))}
      </Section>
    </Stack.Item>
  );
};

type OreHeaderProps = {
  title: string;
  columns: string[][];
};

const OreHeader = (properties: OreHeaderProps) => {
  return (
    <Box className="OreHeader">
      <Stack fill>
        <Stack.Item grow>{properties.title}</Stack.Item>
        {properties.columns?.map((col) => (
          <Stack.Item
            key={col[0]}
            basis={col[1]}
            textAlign="center"
            color="label"
            bold
          >
            {col[0]}
          </Stack.Item>
        ))}
      </Stack>
    </Box>
  );
};

/*
 ********* SHEETS BOX PROPERTIES *********
 */

type SheetLineProps = {
  ore: Ore;
};

const SheetLine = (properties: SheetLineProps) => {
  const { act } = useBackend();
  const { ore } = properties;
  if (
    ore.value &&
    ore.amount <= 0 &&
    !(['metal', 'glass'].indexOf(ore.id) > -1)
  ) {
    return;
  }
  return (
    <Box className="SheetLine">
      <Stack fill>
        <Stack.Item basis="45%" align="middle">
          <Stack align="center">
            <Stack.Item className={classes(['materials32x32', ore.id])} />
            <Stack.Item>{ore.name}</Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item
          basis="20%"
          textAlign="center"
          color={ore.amount >= 1 ? 'good' : 'gray'}
          bold={ore.amount >= 1}
          align="center"
        >
          {ore.amount.toLocaleString('en-US')}
        </Stack.Item>
        <Stack.Item basis="20%" textAlign="center" align="center">
          {ore.value}
        </Stack.Item>
        <Stack.Item
          basis="20%"
          textAlign="center"
          align="center"
          lineHeight="32px"
        >
          <NumberInput
            width="40%"
            value={0}
            minValue={0}
            step={1}
            maxValue={Math.min(ore.amount, 50)}
            stepPixelSize={6}
            onChange={(value) =>
              act(ore.value ? 'sheet' : 'alloy', {
                'id': ore.id,
                'amount': value,
              })
            }
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

/*
 ********* ALLOYS BOX PROPERTIES *********
 */

type AlloyLineProps = {
  ore: Ore;
};

const AlloyLine = (properties: AlloyLineProps) => {
  const { act } = useBackend();
  const { ore } = properties;
  return (
    <Box className="SheetLine">
      <Stack fill>
        <Stack.Item basis="7%" align="middle">
          <Box className={classes(['alloys32x32', ore.id])} />
        </Stack.Item>
        <Stack.Item basis="30%" textAlign="middle" align="center">
          {ore.name}
        </Stack.Item>
        <Stack.Item
          basis="35%"
          textAlign="middle"
          color={ore.amount >= 1 ? 'good' : 'gray'}
          align="center"
        >
          {ore.description}
        </Stack.Item>
        <Stack.Item
          basis="10%"
          textAlign="center"
          color={ore.amount >= 1 ? 'good' : 'gray'}
          bold={ore.amount >= 1}
          align="center"
        >
          {ore.amount.toLocaleString('en-US')}
        </Stack.Item>
        <Stack.Item
          basis="20%"
          textAlign="center"
          align="center"
          lineHeight="32px"
        >
          <NumberInput
            width="40%"
            value={0}
            step={1}
            minValue={0}
            maxValue={Math.min(ore.amount, 50)}
            stepPixelSize={6}
            onChange={(value) =>
              act(ore.value ? 'sheet' : 'alloy', {
                'id': ore.id,
                'amount': value,
              })
            }
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};
