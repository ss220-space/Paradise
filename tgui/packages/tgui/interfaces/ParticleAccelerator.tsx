import { useBackend } from '../backend';
import {
  Box,
  Button,
  Grid,
  LabeledList,
  Section,
  Stack,
  ImageButton,
  Table,
  Tooltip,
} from '../components';
import { capitalize } from 'common/string';
import { Window } from '../layouts';

const dir2text = (dir: number) => {
  switch (dir) {
    case 1:
      return 'north';
    case 2:
      return 'south';
    case 4:
      return 'east';
    case 8:
      return 'west';
    case 5:
      return 'northeast';
    case 6:
      return 'southeast';
    case 9:
      return 'northwest';
    case 10:
      return 'southwest';
  }
  return '';
};

type ParticleAcceleratorData = {
  assembled: boolean;
  power: number;
  strength: number;
  max_strength: number;
  orientation: string;
  icon: string;
  layout_1: Item[];
  layout_2: Item[];
  layout_3: Item[];
};

type Item = {
  name: string;
  status: string;
  dir: number;
  icon_state: string;
};

export const ParticleAccelerator = (_props: unknown) => {
  const { act, data } = useBackend<ParticleAcceleratorData>();
  const { assembled, power, strength, max_strength, orientation } = data;
  return (
    <Window
      width={395}
      height={
        assembled
          ? 160
          : orientation === 'north' || orientation === 'south'
            ? 540
            : 465
      }
    >
      <Window.Content scrollable>
        <Section
          title="Control Panel"
          buttons={
            <Button icon="sync" onClick={() => act('scan')}>
              Connect
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Status">
              <Box color={assembled ? 'good' : 'bad'}>
                {assembled ? 'Operational' : 'Error: Verify Configuration'}
              </Box>
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <Button
                icon={power ? 'power-off' : 'times'}
                selected={power}
                disabled={!assembled}
                onClick={() => act('power')}
              >
                {power ? 'On' : 'Off'}
              </Button>
            </LabeledList.Item>
            <LabeledList.Item label="Strength">
              <Button
                icon="backward"
                disabled={!assembled || strength === 0}
                onClick={() => act('remove_strength')}
                mr="4px"
              />
              {strength}
              <Button
                icon="forward"
                disabled={!assembled || strength === max_strength}
                onClick={() => act('add_strength')}
                ml="4px"
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {assembled ? (
          ''
        ) : (
          <Section
            title={
              orientation
                ? 'EM Acceleration Chamber Orientation: ' +
                  capitalize(orientation)
                : 'Place EM Acceleration Chamber Next To Console'
            }
          >
            {!orientation ? (
              ''
            ) : orientation === 'north' || orientation === 'south' ? (
              <LayoutVertical />
            ) : (
              <LayoutHorizontal />
            )}
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};

const LayoutHorizontal = (_props: unknown) => {
  const { data } = useBackend<ParticleAcceleratorData>();
  const { icon, layout_1, layout_2, layout_3, orientation } = data;
  return (
    <Table>
      <Table.Row width="40px">
        {(orientation === 'east' ? layout_1.reverse() : layout_3).map(
          (item) => (
            <Table.Cell key={item.name}>
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={Number(item.dir)}
                tooltip={
                  <span style={{ wordWrap: 'break-word' }}>
                    {item.name} <br /> {`Status: ${item.status}`}
                    <br />
                    {`Direction: ${dir2text(item.dir)}`}
                  </span>
                }
                tooltipPosition="right"
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor:
                    item.status === 'good'
                      ? 'green'
                      : item.status === 'Incomplete'
                        ? 'orange'
                        : 'red',
                  padding: '2px',
                }}
              />
            </Table.Cell>
          )
        )}
      </Table.Row>
      <Table.Row width="40px">
        {(orientation === 'east' ? layout_2.reverse() : layout_2).map(
          (item) => (
            <Table.Cell key={item.name}>
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={item.dir}
                tooltip={
                  <span style={{ wordWrap: 'break-word' }}>
                    {item.name} <br /> {`Status: ${item.status}`}
                    <br />
                    {`Direction: ${dir2text(item.dir)}`}
                  </span>
                }
                tooltipPosition="right"
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor:
                    item.status === 'good'
                      ? 'green'
                      : item.status === 'Incomplete'
                        ? 'orange'
                        : 'red',
                  padding: '2px',
                }}
              />
            </Table.Cell>
          )
        )}
      </Table.Row>
      <Table.Row width="40px">
        {(orientation === 'east' ? layout_3.reverse() : layout_1).map(
          (item) => (
            <Table.Cell key={item.name}>
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={item.dir}
                tooltip={
                  <span style={{ wordWrap: 'break-word' }}>
                    {item.name} <br /> {`Status: ${item.status}`}
                    <br />
                    {`Direction: ${dir2text(item.dir)}`}
                  </span>
                }
                tooltipPosition="right"
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor:
                    item.status === 'good'
                      ? 'green'
                      : item.status === 'Incomplete'
                        ? 'orange'
                        : 'red',
                  padding: '2px',
                }}
              />
            </Table.Cell>
          )
        )}
      </Table.Row>
    </Table>
  );
};

const LayoutVertical = (_props: unknown) => {
  const { data } = useBackend<ParticleAcceleratorData>();
  const { icon, layout_1, layout_2, layout_3, orientation } = data;
  return (
    <Grid>
      <Grid.Column width="40px">
        {(orientation === 'north' ? layout_1.reverse() : layout_3).map(
          (item) => (
            <Stack.Item grow key={item.name}>
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={item.dir}
                tooltip={
                  <span style={{ wordWrap: 'break-word' }}>
                    {item.name} <br /> {`Status: ${item.status}`}
                    <br />
                    {`Direction: ${dir2text(item.dir)}`}
                  </span>
                }
                tooltipPosition="right"
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor:
                    item.status === 'good'
                      ? 'green'
                      : item.status === 'Incomplete'
                        ? 'orange'
                        : 'red',
                  padding: '2px',
                }}
              />
            </Stack.Item>
          )
        )}
      </Grid.Column>
      <Grid.Column>
        {(orientation === 'north' ? layout_2.reverse() : layout_2).map(
          (item) => (
            <Stack.Item grow key={item.name}>
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={item.dir}
                tooltip={
                  <span style={{ wordWrap: 'break-word' }}>
                    {item.name} <br /> {`Status: ${item.status}`}
                    <br />
                    {`Direction: ${dir2text(item.dir)}`}
                  </span>
                }
                tooltipPosition="right"
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor:
                    item.status === 'good'
                      ? 'green'
                      : item.status === 'Incomplete'
                        ? 'orange'
                        : 'red',
                  padding: '2px',
                }}
              />
            </Stack.Item>
          )
        )}
      </Grid.Column>
      <Grid.Column width="40px">
        {(orientation === 'north' ? layout_3.reverse() : layout_1).map(
          (item) => (
            <Stack.Item grow key={item.name}>
              <ImageButton
                dmIcon={icon}
                dmIconState={item.icon_state}
                dmDirection={item.dir}
                tooltip={
                  <span style={{ wordWrap: 'break-word' }}>
                    {item.name} <br /> {`Status: ${item.status}`}
                    <br />
                    {`Direction: ${dir2text(item.dir)}`}
                  </span>
                }
                tooltipPosition="right"
                style={{
                  borderStyle: 'solid',
                  borderWidth: '2px',
                  borderColor:
                    item.status === 'good'
                      ? 'green'
                      : item.status === 'Incomplete'
                        ? 'orange'
                        : 'red',
                  padding: '2px',
                }}
              />
            </Stack.Item>
          )
        )}
      </Grid.Column>
    </Grid>
  );
};
