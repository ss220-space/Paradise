import { useBackend } from '../backend';
import {
  Button,
  DmIcon,
  LabeledList,
  Section,
  Table,
  Dropdown,
  Flex,
  Icon,
  Box,
} from '../components';
import { Window } from '../layouts';

type SelectableTileProps = {
  icon: string;
  icon_state: string;
  direction?: number;
  isSelected: boolean;
  onSelect: () => void;
};

const SelectableTile = (props: SelectableTileProps) => {
  const { icon, icon_state, direction, isSelected, onSelect } = props;
  return (
    <DmIcon
      icon={icon}
      icon_state={icon_state}
      direction={direction}
      onClick={onSelect}
      style={{
        borderStyle: (isSelected && 'solid') || 'none',
        borderWidth: '2px',
        borderColor: 'orange',
        padding: (isSelected && '0px') || '2px',
      }}
    />
  );
};

const Dir = {
  NORTH: 1,
  SOUTH: 2,
  EAST: 4,
  WEST: 8,
};

type FloorPainterData = {
  availableStyles: string[];
  selectedStyle: string;
  selectedDir: number;
  icon: string;
};

export const FloorPainter = (props: unknown) => {
  const { act, data } = useBackend<FloorPainterData>();
  const { availableStyles, selectedStyle, selectedDir, icon } = data;
  return (
    <Window width={405} height={475}>
      <Window.Content scrollable>
        <Section title="Decal setup">
          <Flex>
            <Flex.Item>
              <Button
                py={0.15}
                icon="chevron-left"
                onClick={() => act('cycle_style', { offset: -1 })}
              />
            </Flex.Item>
            <Flex.Item ml={0.15} mr={0.2}>
              <Dropdown
                options={availableStyles}
                selected={selectedStyle}
                width="150px"
                height="20px"
                noChevron
                onSelected={(val) => act('select_style', { style: val })}
              />
            </Flex.Item>
            <Flex.Item>
              <Button
                py={0.15}
                icon="chevron-right"
                onClick={() => act('cycle_style', { offset: 1 })}
              />
            </Flex.Item>
          </Flex>

          <Box mt="5px" mb="5px">
            <Flex
              overflowY="auto" // scroll
              maxHeight="239px" // a bit more than half of all tiles fit in this box at once.
              wrap="wrap"
            >
              {availableStyles.map((style) => (
                <Flex.Item key={style}>
                  <SelectableTile
                    icon={icon}
                    icon_state={style}
                    isSelected={selectedStyle === style}
                    onSelect={() => act('select_style', { style: style })}
                  />
                </Flex.Item>
              ))}
            </Flex>
          </Box>

          <LabeledList>
            <LabeledList.Item label="Direction">
              <Table style={{ display: 'inline' }}>
                {[Dir.NORTH, null, Dir.SOUTH].map((latitude) => (
                  <Table.Row key={latitude}>
                    {[latitude + Dir.WEST, latitude, latitude + Dir.EAST].map(
                      (dir) => (
                        <Table.Cell
                          key={dir}
                          style={{
                            verticalAlign: 'middle',
                            textAlign: 'center',
                          }}
                        >
                          {dir === null ? (
                            <Icon name="arrows-alt" size={3} />
                          ) : (
                            <SelectableTile
                              icon={icon}
                              icon_state={selectedStyle}
                              direction={dir}
                              isSelected={dir === selectedDir}
                              onSelect={() =>
                                act('select_direction', { direction: dir })
                              }
                            />
                          )}
                        </Table.Cell>
                      )
                    )}
                  </Table.Row>
                ))}
              </Table>
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
