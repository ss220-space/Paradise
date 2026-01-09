import { useBackend } from '../backend';
import {
  Box,
  Button,
  ColorBox,
  Flex,
  Icon,
  Image,
  Input,
  LabeledList,
  Section,
  Table,
} from '../components';
import { Window } from '../layouts';

type ColorEntry = {
  index: Number;
  value: string;
};

type SpriteData = {
  finished: SpriteEntry;
  steps: Array<SpriteEntry>;
};

type SpriteEntry = {
  layer: string;
  result: string;
};

type GreyscaleMenuData = {
  greyscale_config: string;
  colors: Array<ColorEntry>;
  sprites: SpriteData;
  sprites_dir: string;
};

enum Direction {
  North = 'north',
  NorthEast = 'northeast',
  East = 'east',
  SouthEast = 'southeast',
  South = 'south',
  SouthWest = 'southwest',
  West = 'west',
  NorthWest = 'northwest',
}

const DirectionAbbreviation: Record<Direction, string> = {
  [Direction.North]: 'N',
  [Direction.NorthEast]: 'NE',
  [Direction.East]: 'E',
  [Direction.SouthEast]: 'SE',
  [Direction.South]: 'S',
  [Direction.SouthWest]: 'SW',
  [Direction.West]: 'W',
  [Direction.NorthWest]: 'NW',
};

const ConfigDisplay = (_props) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  return (
    <Section title="Config">
      <LabeledList>
        <LabeledList.Item label="Config Type">
          <Button icon="cogs" onClick={() => act('select_config')} />
          <Input
            value={data.greyscale_config}
            onChange={(value) =>
              act('load_config_from_string', { config_string: value })
            }
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const ColorDisplay = (_props: unknown) => {
  const { act, data } = useBackend<GreyscaleMenuData>();
  const colors = data.colors || [];
  return (
    <Section title="Colors">
      <LabeledList>
        <LabeledList.Item label="Full Color String">
          <Input
            value={colors.map((item) => item.value).join('')}
            onChange={(value) =>
              act('recolor_from_string', { color_string: value })
            }
          />
        </LabeledList.Item>
        {colors.map((item) => (
          <LabeledList.Item
            key={`colorgroup${item.index}${item.value}`}
            label={`Color Group ${item.index}`}
            color={item.value}
          >
            <ColorBox color={item.value} />{' '}
            <Button
              icon="palette"
              onClick={() => act('pick_color', { color_index: item.index })}
            />
            <Input
              value={item.value}
              onChange={(value) =>
                act('recolor', { color_index: item.index, new_color: value })
              }
            />
          </LabeledList.Item>
        ))}
      </LabeledList>
    </Section>
  );
};

const PreviewCompassSelect = (_props) => {
  return (
    <Section>
      <Flex mx="25%" fluid>
        <SingleDirection dir={Direction.NorthWest} />
        <SingleDirection dir={Direction.North} />
        <SingleDirection dir={Direction.NorthEast} />
      </Flex>
      <Flex mx="25%">
        <SingleDirection dir={Direction.West} />
        <Flex.Item grow={1} basis={0}>
          <Button lineHeight={3} m={-0.2} fluid>
            <Icon name="arrows-alt" size={1.5} m="20%" />
          </Button>
        </Flex.Item>
        <SingleDirection dir={Direction.East} />
      </Flex>
      <Flex mx="25%">
        <SingleDirection dir={Direction.SouthWest} />
        <SingleDirection dir={Direction.South} />
        <SingleDirection dir={Direction.SouthEast} />
      </Flex>
    </Section>
  );
};

const SingleDirection = (props) => {
  const { dir } = props;
  const { data, act } = useBackend<GreyscaleMenuData>();
  return (
    <Flex.Item grow={1} basis={0}>
      <Button
        disabled={`${dir}` === data.sprites_dir ? true : false}
        textAlign="center"
        onClick={() => act('change_dir', { new_sprite_dir: dir })}
        lineHeight={3}
        m={-0.2}
        fluid
      >
        {DirectionAbbreviation[dir]}
      </Button>
    </Flex.Item>
  );
};

const PreviewDisplay = (_props: unknown) => {
  const { data } = useBackend<GreyscaleMenuData>();
  return (
    <Section title={`Preview (${data.sprites_dir})`}>
      <PreviewCompassSelect />
      <Table>
        <Table.Row header>
          <Table.Cell textAlign="center">Step Layer</Table.Cell>
          <Table.Cell textAlign="center">Step Result</Table.Cell>
        </Table.Row>
        {data.sprites.steps.map((item) => (
          <Table.Row key={`${item.result}|${item.layer}`}>
            <Table.Cell width="50%">
              <SingleSprite source={item.result} />
            </Table.Cell>
            <Table.Cell width="50%">
              <SingleSprite source={item.layer} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

type SingleSpriteProps = {
  source: string;
};

const SingleSprite = (props: SingleSpriteProps) => {
  const { source } = props;
  return <Image src={source} width="100%" />;
};

export const GreyscaleModifyMenu = (_props: unknown) => {
  const { act } = useBackend<GreyscaleMenuData>();
  return (
    <Window title="Greyscale Modification" width={325} height={800}>
      <Window.Content scrollable>
        <ConfigDisplay />
        <ColorDisplay />
        <Button onClick={() => act('refresh_file')}>
          Refresh Icon File
        </Button>{' '}
        <Button onClick={() => act('apply')}>Apply</Button>
        <PreviewDisplay />
      </Window.Content>
    </Window>
  );
};
