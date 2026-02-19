import { useBackend } from '../backend';
import { Box, Button, Flex, Section } from '../components';
import { Window } from '../layouts';

export const EvolutionMenu = (props: unknown) => {
  return (
    <Window width={480} height={574} theme="changeling">
      <Window.Content className="Layout__content--flexColumn" scrollable>
        <EvolutionPoints />
        <Abilities />
      </Window.Content>
    </Window>
  );
};

type EvolutionMenuData = {
  evo_points: number;
  can_respec: boolean;
  ability_list: Ability[];
  purchased_abilities: string[];
  view_mode: boolean;
};

type Ability = {
  name: string;
  power_path: string;
  cost: number;
  description: string;
  helptext: string;
};

const EvolutionPoints = (props: unknown) => {
  const { act, data } = useBackend<EvolutionMenuData>();
  const { evo_points, can_respec } = data;
  return (
    <Section title="Evolution Points" height={5.5}>
      <Flex>
        <Flex.Item mt={0.5} color="label">
          Points remaining:
        </Flex.Item>
        <Flex.Item mt={0.5} ml={2} bold color="#1b945c">
          {evo_points}
        </Flex.Item>
        <Flex.Item>
          <Button
            ml={2.5}
            disabled={!can_respec}
            icon="sync"
            onClick={() => act('readapt')}
          >
            Readapt
          </Button>
          <Button
            tooltip="By transforming a humanoid into a husk, \
              we gain the ability to readapt our chosen evolutions."
            tooltipPosition="bottom"
            icon="question-circle"
          />
        </Flex.Item>
      </Flex>
    </Section>
  );
};

const Abilities = (props: unknown) => {
  const { act, data } = useBackend<EvolutionMenuData>();
  const { evo_points, ability_list, purchased_abilities, view_mode } = data;
  return (
    <Section
      title="Abilities"
      flexGrow
      buttons={
        <>
          <Button
            icon={!view_mode ? 'check-square-o' : 'square-o'}
            selected={!view_mode}
            onClick={() =>
              act('set_view_mode', {
                mode: 0,
              })
            }
          >
            Compact
          </Button>
          <Button
            icon={view_mode ? 'check-square-o' : 'square-o'}
            selected={view_mode}
            onClick={() =>
              act('set_view_mode', {
                mode: 1,
              })
            }
          >
            Expanded
          </Button>
        </>
      }
    >
      {ability_list.map((ability, i) => (
        <Box key={i} p={0.5} mx={-1} className="candystripe">
          <Flex align="center">
            <Flex.Item ml={0.5} color="#dedede">
              {ability.name}
            </Flex.Item>
            {purchased_abilities.includes(ability.power_path) && (
              <Flex.Item ml={2} bold color="#1b945c">
                (Purchased)
              </Flex.Item>
            )}
            <Flex.Item mr={3} textAlign="right" grow={1}>
              <Box as="span" color="label">
                Cost:{' '}
              </Box>
              <Box as="span" bold color="#1b945c">
                {ability.cost}
              </Box>
            </Flex.Item>
            <Flex.Item textAlign="right">
              <Button
                mr={0.5}
                disabled={
                  ability.cost > evo_points ||
                  purchased_abilities.includes(ability.power_path)
                }
                onClick={() =>
                  act('purchase', {
                    power_path: ability.power_path,
                  })
                }
              >
                Evolve
              </Button>
            </Flex.Item>
          </Flex>
          {!!view_mode && (
            <Flex color="#8a8a8a" my={1} ml={1.5} width="95%">
              {ability.description + ' ' + ability.helptext}
            </Flex>
          )}
        </Box>
      ))}
    </Section>
  );
};
