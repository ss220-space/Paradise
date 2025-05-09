import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Button,
  LabeledList,
  Box,
  Section,
  NoticeBox,
  Tabs,
  Icon,
  Table,
} from '../components';
import { Window } from '../layouts';

const PickTab = (index: number) => {
  switch (index) {
    case 0:
      return <ConfigPage />;
    case 1:
      return <LinkagePage />;
    case 2:
      return <FilteringPage />;
    default:
      return 'SOMETHING WENT VERY WRONG PLEASE AHELP';
  }
};

type TcommsCoreData = {
  ion: boolean;
  active: boolean;
  sectors_available: boolean;
  nttc_toggle_jobs: boolean;
  nttc_toggle_job_color: boolean;
  nttc_toggle_name_color: boolean;
  nttc_toggle_command_bold: boolean;
  nttc_job_indicator_type: string;
  nttc_setting_language: string;
  network_id: string;
  link_password: string;
  relay_entries: Relay[];
  filtered_users: string[];
};

type Relay = {
  addr: string;
  status: boolean;
  net_id: string;
  sector: string;
};

export const TcommsCore = (_props: unknown) => {
  const { data } = useBackend<TcommsCoreData>();
  const { ion } = data;
  const [tabIndex, setTabIndex] = useState(0);

  return (
    <Window width={900} height={600}>
      <Window.Content scrollable>
        {!!ion && <IonBanner />}
        <Tabs>
          <Tabs.Tab
            key="ConfigPage"
            selected={tabIndex === 0}
            onClick={() => setTabIndex(0)}
          >
            <Icon name="wrench" mr={0.5} />
            Configuration
          </Tabs.Tab>
          <Tabs.Tab
            key="LinkagePage"
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}
          >
            <Icon name="link" mr={0.5} />
            Device Linkage
          </Tabs.Tab>
          <Tabs.Tab
            key="FilterPage"
            selected={tabIndex === 2}
            onClick={() => setTabIndex(2)}
          >
            <Icon name="user-times" mr={0.5} />
            User Filtering
          </Tabs.Tab>
        </Tabs>
        {PickTab(tabIndex)}
      </Window.Content>
    </Window>
  );
};

const IonBanner = () => {
  // This entire thing renders on one line
  // Its just split in here to get past
  // the 80 char line limit
  return (
    <NoticeBox>
      ERROR: An Ionospheric overload has occured. Please wait for the machine to
      reboot. This cannot be manually done.
    </NoticeBox>
  );
};

const ConfigPage = (_properties) => {
  const { act, data } = useBackend<TcommsCoreData>();
  const {
    active,
    sectors_available,
    nttc_toggle_jobs,
    nttc_toggle_job_color,
    nttc_toggle_name_color,
    nttc_toggle_command_bold,
    nttc_job_indicator_type,
    nttc_setting_language,
    network_id,
  } = data;
  return (
    <>
      <Section title="Status">
        <LabeledList>
          <LabeledList.Item label="Machine Power">
            <Button
              selected={active}
              icon="power-off"
              onClick={() => act('toggle_active')}
            >
              {active ? 'On' : 'Off'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Sector Coverage">
            {sectors_available}
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Radio Configuration">
        <LabeledList>
          <LabeledList.Item label="Job Announcements">
            <Button
              selected={nttc_toggle_jobs}
              icon="user-tag"
              onClick={() => act('nttc_toggle_jobs')}
            >
              {nttc_toggle_jobs ? 'On' : 'Off'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Job Departmentalisation">
            <Button
              selected={nttc_toggle_job_color}
              icon="clipboard-list"
              onClick={() => act('nttc_toggle_job_color')}
            >
              {nttc_toggle_job_color ? 'On' : 'Off'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Name Departmentalisation">
            <Button
              selected={nttc_toggle_name_color}
              icon="user-tag"
              onClick={() => act('nttc_toggle_name_color')}
            >
              {nttc_toggle_name_color ? 'On' : 'Off'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Command Amplification">
            <Button
              selected={nttc_toggle_command_bold}
              icon="volume-up"
              onClick={() => act('nttc_toggle_command_bold')}
            >
              {nttc_toggle_command_bold ? 'On' : 'Off'}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Advanced">
        <LabeledList>
          <LabeledList.Item label="Job Announcement Format">
            <Button
              selected={!!nttc_job_indicator_type}
              icon="pencil-alt"
              onClick={() => act('nttc_job_indicator_type')}
            >
              {nttc_job_indicator_type ? nttc_job_indicator_type : 'Unset'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Language Conversion">
            <Button
              selected={!!nttc_setting_language}
              icon="globe"
              onClick={() => act('nttc_setting_language')}
            >
              {nttc_setting_language ? nttc_setting_language : 'Unset'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Network ID">
            <Button
              selected={!!network_id}
              icon="server"
              onClick={() => act('network_id')}
            >
              {network_id ? network_id : 'Unset'}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Maintenance">
        <Button icon="file-import" onClick={() => act('import')}>
          Import Configuration
        </Button>
        <Button icon="file-export" onClick={() => act('export')}>
          Export Configuration
        </Button>
      </Section>
    </>
  );
};

const LinkagePage = (_properties) => {
  const { act, data } = useBackend<TcommsCoreData>();
  const { link_password, relay_entries } = data;
  return (
    <Section title="Device Linkage">
      <LabeledList>
        <LabeledList.Item label="Linkage Password">
          <Button
            selected={!!link_password}
            icon="lock"
            onClick={() => act('change_password')}
          >
            {link_password ? link_password : 'Unset'}
          </Button>
        </LabeledList.Item>
      </LabeledList>

      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>Network Address</Table.Cell>
          <Table.Cell>Network ID</Table.Cell>
          <Table.Cell>Sector</Table.Cell>
          <Table.Cell>Status</Table.Cell>
          <Table.Cell>Unlink</Table.Cell>
        </Table.Row>
        {relay_entries.map((r) => (
          <Table.Row key={r.addr}>
            <Table.Cell>{r.addr}</Table.Cell>
            <Table.Cell>{r.net_id}</Table.Cell>
            <Table.Cell>{r.sector}</Table.Cell>
            <Table.Cell>
              {r.status ? (
                <Box color="green">Online</Box>
              ) : (
                <Box color="red">Offline</Box>
              )}
            </Table.Cell>
            <Table.Cell>
              <Button
                icon="unlink"
                onClick={() =>
                  act('unlink', {
                    addr: r.addr,
                  })
                }
              >
                Unlink
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const FilteringPage = (_properties) => {
  const { act, data } = useBackend<TcommsCoreData>();
  const { filtered_users } = data;
  return (
    <Section
      title="User Filtering"
      buttons={
        <Button icon="user-plus" onClick={() => act('add_filter')}>
          Add User
        </Button>
      }
    >
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell style={{ width: '90%' }}>User</Table.Cell>
          <Table.Cell style={{ width: '10%' }}>Actions</Table.Cell>
        </Table.Row>
        {filtered_users.map((u) => (
          <Table.Row key={u}>
            <Table.Cell>{u}</Table.Cell>
            <Table.Cell>
              <Button
                icon="user-times"
                onClick={() =>
                  act('remove_filter', {
                    user: u,
                  })
                }
              >
                Remove
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
