import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Box,
  Section,
  Table,
  Tabs,
  Stack,
  Icon,
} from '../components';
import { Window } from '../layouts';
import { Access, AccessList } from './common/AccessList';
import { COLORS } from '../constants';
import { ReactNode } from 'react';

const deptCols = COLORS.department;

export const CardComputerLoginWarning = () => (
  <Section fill title="Warning">
    <Stack fill>
      <Stack.Item
        bold
        grow
        textAlign="center"
        fontSize={1.75}
        align="center"
        color="label"
      >
        <Icon.Stack style={{ transform: 'translate(-50px, -100px)' }}>
          <Icon name="user" size={5} color="gray" />
          <Icon
            name="slash"
            size={5}
            color="red"
            style={{ transform: 'translate(-15px, 0)' }}
          />
        </Icon.Stack>
        <br />
        Not logged in
      </Stack.Item>
    </Stack>
  </Section>
);

export const CardComputerNoCard = () => (
  <Section fill title="Card Missing">
    <Stack fill>
      <Stack.Item
        bold
        grow
        textAlign="center"
        fontSize={1.75}
        align="center"
        color="label"
      >
        <Icon.Stack style={{ transform: 'translate(-50px, -100px)' }}>
          <Icon name="id-card" size={5} color="gray" />
          <Icon
            name="slash"
            size={5}
            color="red"
            style={{ transform: 'translate(-5px, 0)' }}
          />
        </Icon.Stack>
        <br />
        No card to modify
      </Stack.Item>
    </Stack>
  </Section>
);

export const CardComputerNoRecords = () => (
  <Section fill title="Records">
    <Stack fill>
      <Stack.Item
        bold
        grow
        textAlign="center"
        fontSize={1.75}
        align="center"
        color="label"
      >
        <Icon.Stack>
          <Icon name="scroll" size={5} color="gray" />
          <Icon name="slash" size={5} color="red" />
        </Icon.Stack>
        <br />
        No records
      </Stack.Item>
    </Stack>
  </Section>
);

type CardComputerData = {
  mode: number;
  target_dept: boolean;
  scan_name: string;
  modify_name: string;
  modify_owner: string;
  authenticated: boolean;
  account_number: string;
  modify_lastlog: string;
  modify_rank: string;
  jobs_dept: string[];
  jobFormats: Record<string, string>;
  jobs_top: string[];
  jobs_engineering: string[];
  jobs_medical: string[];
  jobs_science: string[];
  jobs_security: string[];
  jobs_service: string[];
  jobs_karma: string[];
  jobs_supply: string[];
  jobs_civilian: string[];
  iscentcom: boolean;
  jobs_centcom: string[];
  modify_assignment: string;
  canterminate: boolean;
  card_skins: Skin[];
  current_skin: string;
  all_centcom_skins: Skin[];
  auth_or_ghost: boolean;
  cooldown_time: string;
  job_slots: JobSlot[];
  priority_jobs: string[];
  regions: Access[];
  selectedAccess: number[];
  records: JobRecord[];
  people_dept: DepRecord[];
};

type Skin = {
  skin: string;
  display_name: string;
};

type JobSlot = {
  title: string;
  is_priority: boolean;
  current_positions: number;
  total_positions: number;
  can_close: boolean;
  can_open: boolean;
  can_prioritize: boolean;
};

type JobRecord = {
  timestamp: string;
  transferee: string;
  oldvalue: string;
  newvalue: string;
  whodidit: string;
  reason: string;
  deletedby: string;
};

type DepRecord = {
  name: string;
  title: string;
  crimstat: string;
  buttontext: string;
  demotable: boolean;
};

export const CardComputer = (props: unknown) => {
  const { act, data } = useBackend<CardComputerData>();

  let menuBlock = (
    <Tabs>
      <Tabs.Tab
        icon="id-card"
        selected={data.mode === 0}
        onClick={() => act('mode', { mode: 0 })}
      >
        Job Transfers
      </Tabs.Tab>
      {!data.target_dept && (
        <Tabs.Tab
          icon="id-card"
          selected={data.mode === 2}
          onClick={() => act('mode', { mode: 2 })}
        >
          Access Modification
        </Tabs.Tab>
      )}
      <Tabs.Tab
        icon="folder-open"
        selected={data.mode === 1}
        onClick={() => act('mode', { mode: 1 })}
      >
        Job Management
      </Tabs.Tab>
      <Tabs.Tab
        icon="scroll"
        selected={data.mode === 3}
        onClick={() => act('mode', { mode: 3 })}
      >
        Records
      </Tabs.Tab>
      <Tabs.Tab
        icon="users"
        selected={data.mode === 4}
        onClick={() => act('mode', { mode: 4 })}
      >
        Department
      </Tabs.Tab>
    </Tabs>
  );

  let authBlock = (
    <Section title="Authentication">
      <LabeledList>
        <LabeledList.Item label="Login/Logout">
          <Button
            icon={data.scan_name ? 'sign-out-alt' : 'id-card'}
            selected={!!data.scan_name}
            onClick={() => act('scan')}
          >
            {data.scan_name ? 'Log Out: ' + data.scan_name : '-----'}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Card To Modify">
          <Button
            icon={data.modify_name ? 'eject' : 'id-card'}
            selected={!!data.modify_name}
            onClick={() => act('modify')}
          >
            {data.modify_name ? 'Remove Card: ' + data.modify_name : '-----'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );

  let bodyBlock: ReactNode;

  switch (data.mode) {
    case 0: // job transfer
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = <CardComputerLoginWarning />;
      } else if (!data.modify_name) {
        bodyBlock = <CardComputerNoCard />;
      } else {
        bodyBlock = (
          <>
            <Section title="Card Information">
              {!data.target_dept && (
                <>
                  <LabeledList.Item label="Registered Name">
                    <Button
                      icon={
                        !data.modify_owner || data.modify_owner === 'Unknown'
                          ? 'exclamation-triangle'
                          : 'pencil-alt'
                      }
                      selected={!!data.modify_name}
                      onClick={() => act('reg')}
                    >
                      {data.modify_owner}
                    </Button>
                  </LabeledList.Item>
                  <LabeledList.Item label="Account Number">
                    <Button
                      icon={
                        data.account_number
                          ? 'pencil-alt'
                          : 'exclamation-triangle'
                      }
                      selected={!!data.account_number}
                      onClick={() => act('account')}
                    >
                      {data.account_number ? data.account_number : 'None'}
                    </Button>
                  </LabeledList.Item>
                </>
              )}
              <LabeledList.Item label="Latest Transfer">
                {data.modify_lastlog || '---'}
              </LabeledList.Item>
            </Section>
            <Section
              title={
                data.target_dept ? 'Department Job Transfer' : 'Job Transfer'
              }
            >
              <LabeledList>
                {data.target_dept ? (
                  <LabeledList.Item label="Department">
                    {data.jobs_dept.map((v) => (
                      <Button
                        selected={data.modify_rank === v}
                        key={v}
                        color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                        onClick={() => act('assign', { assign_target: v })}
                      >
                        {v}
                      </Button>
                    ))}
                  </LabeledList.Item>
                ) : (
                  <>
                    <LabeledList.Item label="Special">
                      {data.jobs_top.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Engineering"
                      labelColor={deptCols.engineering}
                    >
                      {data.jobs_engineering.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Medical"
                      labelColor={deptCols.medical}
                    >
                      {data.jobs_medical.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Science"
                      labelColor={deptCols.science}
                    >
                      {data.jobs_science.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Security"
                      labelColor={deptCols.security}
                    >
                      {data.jobs_security.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Service"
                      labelColor={deptCols.service}
                    >
                      {data.jobs_service.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Supply"
                      labelColor={deptCols.supply}
                    >
                      {data.jobs_supply.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          key={v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                    <LabeledList.Item
                      label="Restricted"
                      labelColor={deptCols.procedure}
                    >
                      {data.jobs_karma.map((v) => (
                        <Button
                          selected={data.modify_rank === v}
                          color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                          key={v}
                          onClick={() => act('assign', { assign_target: v })}
                        >
                          {v}
                        </Button>
                      ))}
                    </LabeledList.Item>
                  </>
                )}
                <LabeledList.Item label="Civilian">
                  {data.jobs_civilian.map((v) => (
                    <Button
                      selected={data.modify_rank === v}
                      key={v}
                      color={data.jobFormats[v] ? data.jobFormats[v] : ''}
                      onClick={() => act('assign', { assign_target: v })}
                    >
                      {v}
                    </Button>
                  ))}
                </LabeledList.Item>
                {!!data.iscentcom && (
                  <LabeledList.Item
                    label="CentCom"
                    labelColor={deptCols.centcom}
                  >
                    {data.jobs_centcom.map((v) => (
                      <Button
                        selected={data.modify_rank === v}
                        key={v}
                        color={
                          data.jobFormats[v] ? data.jobFormats[v] : 'purple'
                        }
                        onClick={() => act('assign', { assign_target: v })}
                      >
                        {v}
                      </Button>
                    ))}
                  </LabeledList.Item>
                )}
                <LabeledList.Item label="Demotion">
                  <Button
                    disabled={
                      data.modify_assignment === 'Demoted' ||
                      data.modify_assignment === 'Terminated'
                    }
                    key="Demoted"
                    tooltip="Assistant access, 'demoted' title."
                    color="red"
                    icon="times"
                    onClick={() => act('demote')}
                  >
                    Demoted
                  </Button>
                </LabeledList.Item>
                {!!data.canterminate && (
                  <LabeledList.Item label="Non-Crew">
                    <Button
                      disabled={data.modify_assignment === 'Terminated'}
                      key="Terminate"
                      tooltip="Zero access. Not crew."
                      color="red"
                      icon="eraser"
                      onClick={() => act('terminate')}
                    >
                      Terminated
                    </Button>
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
            {!data.target_dept && (
              <Section title="Card Skins">
                {data.card_skins.map((v) => (
                  <Button
                    selected={data.current_skin === v.skin}
                    key={v.skin}
                    onClick={() => act('skin', { skin_target: v.skin })}
                  >
                    {v.display_name}
                  </Button>
                ))}
                {!!data.iscentcom && (
                  <Box>
                    {data.all_centcom_skins.map((v) => (
                      <Button
                        selected={data.current_skin === v.skin}
                        key={v.skin}
                        color="purple"
                        onClick={() => act('skin', { skin_target: v.skin })}
                      >
                        {v.display_name}
                      </Button>
                    ))}
                  </Box>
                )}
              </Section>
            )}
          </>
        );
      }
      break;
    case 1: // job slot management
      if (!data.auth_or_ghost) {
        bodyBlock = <CardComputerLoginWarning />;
      } else {
        bodyBlock = (
          <Stack fill vertical>
            <Section color={data.cooldown_time ? 'red' : ''}>
              Next Change Available:
              {data.cooldown_time ? data.cooldown_time : 'Now'}
            </Section>
            <Section fill scrollable title="Job Slots">
              <Table>
                <Table.Row height={2}>
                  <Table.Cell bold textAlign="center">
                    Title
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Used Slots
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Total Slots
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Free Slots
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Close Slot
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Open Slot
                  </Table.Cell>
                  <Table.Cell bold textAlign="center">
                    Priority
                  </Table.Cell>
                </Table.Row>
                {data.job_slots.map((slotData) => (
                  <Table.Row
                    key={slotData.title}
                    height={2}
                    className="candystripe"
                  >
                    <Table.Cell textAlign="center">
                      <Box color={slotData.is_priority ? 'green' : ''}>
                        {slotData.title}
                      </Box>
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {slotData.current_positions}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {slotData.total_positions}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {(slotData.total_positions >
                        slotData.current_positions && (
                        <Box color="green">
                          {slotData.total_positions -
                            slotData.current_positions}
                        </Box>
                      )) || <Box color="red">0</Box>}
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      <Button
                        disabled={!!data.cooldown_time || !slotData.can_close}
                        onClick={() =>
                          act('make_job_unavailable', { job: slotData.title })
                        }
                      >
                        -
                      </Button>
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      <Button
                        disabled={!!data.cooldown_time || !slotData.can_open}
                        onClick={() =>
                          act('make_job_available', { job: slotData.title })
                        }
                      >
                        +
                      </Button>
                    </Table.Cell>
                    <Table.Cell textAlign="center">
                      {(data.target_dept && (
                        <Box color="green">
                          {data.priority_jobs.indexOf(slotData.title) > -1
                            ? 'Yes'
                            : ''}
                        </Box>
                      )) || (
                        <Button
                          selected={slotData.is_priority}
                          disabled={
                            !!data.cooldown_time || !slotData.can_prioritize
                          }
                          onClick={() =>
                            act('prioritize_job', { job: slotData.title })
                          }
                        >
                          {slotData.is_priority ? 'Yes' : 'No'}
                        </Button>
                      )}
                    </Table.Cell>
                  </Table.Row>
                ))}
              </Table>
            </Section>
          </Stack>
        );
      }
      break;
    case 2: // access change
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = <CardComputerLoginWarning />;
      } else if (!data.modify_name) {
        bodyBlock = <CardComputerNoCard />;
      } else {
        bodyBlock = (
          <AccessList
            accesses={data.regions}
            selectedList={data.selectedAccess}
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
        );
      }
      break;
    case 3: // records
      if (!data.authenticated) {
        bodyBlock = <CardComputerLoginWarning />;
      } else if (!data.records.length) {
        bodyBlock = <CardComputerNoRecords />;
      } else {
        bodyBlock = (
          <Section
            fill
            scrollable
            title="Records"
            buttons={
              <Button
                icon="times"
                disabled={
                  !data.authenticated ||
                  data.records.length === 0 ||
                  data.target_dept
                }
                onClick={() => act('wipe_all_logs')}
              >
                Delete All Records
              </Button>
            }
          >
            <Table>
              <Table.Row height={2}>
                <Table.Cell bold>Crewman</Table.Cell>
                <Table.Cell bold>Old Rank</Table.Cell>
                <Table.Cell bold>New Rank</Table.Cell>
                <Table.Cell bold>Authorized By</Table.Cell>
                <Table.Cell bold>Time</Table.Cell>
                <Table.Cell bold>Reason</Table.Cell>
                {!!data.iscentcom && <Table.Cell bold>Deleted By</Table.Cell>}
              </Table.Row>
              {data.records.map((record) => (
                <Table.Row key={record.timestamp} height={2}>
                  <Table.Cell>{record.transferee}</Table.Cell>
                  <Table.Cell>{record.oldvalue}</Table.Cell>
                  <Table.Cell>{record.newvalue}</Table.Cell>
                  <Table.Cell>{record.whodidit}</Table.Cell>
                  <Table.Cell>{record.timestamp}</Table.Cell>
                  <Table.Cell>{record.reason}</Table.Cell>
                  {!!data.iscentcom && (
                    <Table.Cell>{record.deletedby}</Table.Cell>
                  )}
                </Table.Row>
              ))}
            </Table>
            {!!data.iscentcom && (
              <Box>
                <Button
                  icon="pencil-alt"
                  color="purple"
                  disabled={!data.authenticated || data.records.length === 0}
                  onClick={() => act('wipe_my_logs')}
                >
                  Delete MY Records
                </Button>
              </Box>
            )}
          </Section>
        );
      }
      break;
    case 4: // department
      if (!data.authenticated || !data.scan_name) {
        bodyBlock = <CardComputerLoginWarning />;
      } else {
        bodyBlock = (
          <Section fill scrollable title="Your Team">
            <Table>
              <Table.Row height={2}>
                <Table.Cell bold>Name</Table.Cell>
                <Table.Cell bold>Rank</Table.Cell>
                <Table.Cell bold>Sec Status</Table.Cell>
                <Table.Cell bold>Actions</Table.Cell>
              </Table.Row>
              {data.people_dept.map((record) => (
                <Table.Row key={record.title} height={2}>
                  <Table.Cell>{record.name}</Table.Cell>
                  <Table.Cell>{record.title}</Table.Cell>
                  <Table.Cell>{record.crimstat}</Table.Cell>
                  <Table.Cell>
                    <Button
                      disabled={!record.demotable}
                      onClick={() =>
                        act('remote_demote', { remote_demote: record.name })
                      }
                    >
                      {record.buttontext}
                    </Button>
                  </Table.Cell>
                </Table.Row>
              ))}
            </Table>
          </Section>
        );
      }
      break;
    default:
      bodyBlock = (
        <Section title="Warning" color="red">
          ERROR: Unknown Mode.
        </Section>
      );
  }

  return (
    <Window width={800} height={800}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>{authBlock}</Stack.Item>
          <Stack.Item>{menuBlock}</Stack.Item>
          <Stack.Item grow>{bodyBlock}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
