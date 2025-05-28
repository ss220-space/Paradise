import { useBackend } from '../backend';
import {
  Button,
  Section,
  ProgressBar,
  Stack,
  Tabs,
  Icon,
  Image,
} from '../components';
import { Window } from '../layouts';
import { ComplexModal, modalOpen } from './common/ComplexModal';
import { Access, AccessList } from './common/AccessList';

export const RCD = (_props: unknown) => {
  return (
    <Window width={480} height={670}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <MatterReadout />
          <ConstructionType />
          <AirlockSettings />
          <TypesAndAccess />
        </Stack>
      </Window.Content>
    </Window>
  );
};

type RCDData = {
  matter: number;
  max_matter: number;
  mode: string;
  door_name: string;
  electrochromic: boolean;
  airlock_glass: boolean;
  tab: number;
  locked: boolean;
  one_access: boolean;
  selected_accesses: number[];
  regions: Access[];
  door_types_ui_list;
  door_type: string;
};

const MatterReadout = (_props: unknown) => {
  const { data } = useBackend<RCDData>();
  const { matter, max_matter } = data;
  const good_matter = max_matter * 0.7;
  const average_matter = max_matter * 0.25;
  return (
    <Stack.Item>
      <Section title="Matter Storage">
        <ProgressBar
          ranges={{
            good: [good_matter, Infinity],
            average: [average_matter, good_matter],
            bad: [-Infinity, average_matter],
          }}
          value={matter}
          maxValue={max_matter}
        >
          <Stack.Item textAlign="center">
            {matter + ' / ' + max_matter + ' units'}
          </Stack.Item>
        </ProgressBar>
      </Section>
    </Stack.Item>
  );
};

const ConstructionType = () => {
  return (
    <Stack.Item>
      <Section title="Construction Type">
        <Stack>
          <ConstructionTypeCheckbox mode_type="Floors and Walls" />
          <ConstructionTypeCheckbox mode_type="Airlocks" />
          <ConstructionTypeCheckbox mode_type="Windows" />
          <ConstructionTypeCheckbox mode_type="Deconstruction" />
          <ConstructionTypeCheckbox mode_type="Firelocks" />
        </Stack>
      </Section>
    </Stack.Item>
  );
};

type ConstructionTypeCheckboxProps = {
  mode_type: string;
};

const ConstructionTypeCheckbox = (props: ConstructionTypeCheckboxProps) => {
  const { act, data } = useBackend<RCDData>();
  const { mode_type } = props;
  const { mode } = data;
  return (
    <Stack.Item grow textAlign="center">
      <Button
        fluid
        color="transparent"
        selected={mode === mode_type ? 1 : 0}
        onClick={() =>
          act('mode', {
            mode: mode_type,
          })
        }
      >
        {mode_type}
      </Button>
    </Stack.Item>
  );
};

const AirlockSettings = (_props: unknown) => {
  const { act, data } = useBackend<RCDData>();
  const { door_name, electrochromic, airlock_glass } = data;
  return (
    <Stack.Item>
      <Section title="Airlock Settings">
        <Stack textAlign="center">
          <Stack.Item grow>
            <Button
              fluid
              color="transparent"
              icon="pen-alt"
              onClick={() => modalOpen('renameAirlock')}
            >
              <>Rename: {<b>{door_name}</b>}</>
            </Button>
          </Stack.Item>
          <Stack.Item>
            {airlock_glass && (
              <Button
                fluid
                icon={electrochromic ? 'toggle-on' : 'toggle-off'}
                selected={electrochromic}
                onClick={() => act('electrochromic')}
              >
                Electrochromic
              </Button>
            )}
          </Stack.Item>
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const TypesAndAccess = (_props: unknown) => {
  const { act, data } = useBackend<RCDData>();
  const { tab, locked, one_access, selected_accesses, regions } = data;
  return (
    <>
      <Stack.Item textAlign="center">
        <Tabs fluid>
          <Tabs.Tab
            icon="cog"
            selected={tab === 1}
            onClick={() => act('set_tab', { tab: 1 })}
          >
            Airlock Types
          </Tabs.Tab>
          <Tabs.Tab
            selected={tab === 2}
            icon="list"
            onClick={() => act('set_tab', { tab: 2 })}
          >
            Airlock Access
          </Tabs.Tab>
        </Tabs>
      </Stack.Item>
      <Stack.Item grow>
        {tab === 1 ? (
          <Section fill scrollable title="Types">
            <Stack>
              <Stack.Item grow>
                <AirlockTypeList check_number={0} />
              </Stack.Item>
              <Stack.Item grow>
                <AirlockTypeList check_number={1} />
              </Stack.Item>
            </Stack>
          </Section>
        ) : tab === 2 && locked ? (
          <Section
            fill
            title="Access"
            buttons={
              <Button
                icon="lock-open"
                onClick={() =>
                  act('set_lock', {
                    new_lock: 'unlock',
                  })
                }
              >
                Unlock
              </Button>
            }
          >
            <Stack fill>
              <Stack.Item grow textAlign="center" align="center" color="label">
                <Icon name="lock" size={5} mb={3} />
                <br />
                Airlock access selection is currently locked.
              </Stack.Item>
            </Stack>
          </Section>
        ) : (
          <AccessList
            sectionButtons={[
              <Button
                icon="lock"
                key={1}
                onClick={() =>
                  act('set_lock', {
                    new_lock: 'lock',
                  })
                }
              >
                Lock
              </Button>,
            ]}
            usedByRcd
            rcdButtons={[
              <Button.Checkbox
                checked={one_access}
                key={1}
                onClick={() =>
                  act('set_one_access', {
                    access: 'one',
                  })
                }
              >
                One
              </Button.Checkbox>,
              <Button.Checkbox
                checked={!one_access}
                width={4}
                key={2}
                onClick={() =>
                  act('set_one_access', {
                    access: 'all',
                  })
                }
              >
                All
              </Button.Checkbox>,
            ]}
            accesses={regions}
            selectedList={selected_accesses}
            accessMod={(ref) =>
              act('set', {
                access: ref,
              })
            }
            grantAll={() => act('grant_all')}
            denyAll={() => act('clear_all')}
            grantDep={(ref) =>
              act('grant_region', {
                region: ref,
              })
            }
            denyDep={(ref) =>
              act('deny_region', {
                region: ref,
              })
            }
          />
        )}
      </Stack.Item>
    </>
  );
};

type AirlockTypeListProps = {
  check_number: number;
};

const AirlockTypeList = (props: AirlockTypeListProps) => {
  const { act, data } = useBackend<RCDData>();
  const { door_types_ui_list, door_type } = data;
  const { check_number } = props;
  // Filter either odd or even airlocks in the list, based on what `check_number` is.
  const doors_filtered = [];
  for (let i = 0; i < door_types_ui_list.length; i++) {
    if (i % 2 === check_number) {
      doors_filtered.push(door_types_ui_list[i]);
    }
  }
  return (
    <Stack.Item>
      {doors_filtered.map((entry, i) => (
        <Stack key={i} mb={0.5}>
          <Stack.Item grow>
            <Button.Checkbox
              fluid
              icon={null}
              color="translucent"
              checked={door_type === entry.type}
              onClick={() =>
                act('door_type', {
                  door_type: entry.type,
                })
              }
            >
              <Image
                src={`data:image/jpeg;base64,${entry.image}`}
                style={{
                  verticalAlign: 'middle',
                  width: '32px',
                  margin: '3px',
                  marginRight: '6px',
                  marginLeft: '-3px',
                }}
              />
              {entry.name}
            </Button.Checkbox>
          </Stack.Item>
        </Stack>
      ))}
    </Stack.Item>
  );
};
