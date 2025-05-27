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
      return 'ЧТО-ТО СЛОМАЛОСЬ, СООБЩИТЕ О БАГЕ';
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
            Конфигурация
          </Tabs.Tab>
          <Tabs.Tab
            key="LinkagePage"
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}
          >
            <Icon name="link" mr={0.5} />
            Привязанные устройств
          </Tabs.Tab>
          <Tabs.Tab
            key="FilterPage"
            selected={tabIndex === 2}
            onClick={() => setTabIndex(2)}
          >
            <Icon name="user-times" mr={0.5} />
            Чёрный список пользователей
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
      ОШИБКА: Зафиксирована ионосферная перегрузка. Пожалуйста, подождите до
      автоматической перезагрузки. Это действие нельзя сделать вручную.
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
      <Section title="Состояние">
        <LabeledList>
          <LabeledList.Item label="Питание">
            <Button
              selected={active}
              icon="power-off"
              onClick={() => act('toggle_active')}
            >
              {active ? 'Включено' : 'Выключено'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Доступные сектора">
            {sectors_available}
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Конфигурация радиосвязи">
        <LabeledList>
          <LabeledList.Item label="Отображение должностей">
            <Button
              selected={nttc_toggle_jobs}
              icon="user-tag"
              onClick={() => act('nttc_toggle_jobs')}
            >
              {nttc_toggle_jobs ? 'Включено' : 'Выключено'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Выделение должностей по отделам">
            <Button
              selected={nttc_toggle_job_color}
              icon="clipboard-list"
              onClick={() => act('nttc_toggle_job_color')}
            >
              {nttc_toggle_job_color ? 'Включено' : 'Выключено'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Выделение имён по отделам">
            <Button
              selected={nttc_toggle_name_color}
              icon="user-tag"
              onClick={() => act('nttc_toggle_name_color')}
            >
              {nttc_toggle_name_color ? 'Включено' : 'Выключено'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Выделение должностей командования">
            <Button
              selected={nttc_toggle_command_bold}
              icon="volume-up"
              onClick={() => act('nttc_toggle_command_bold')}
            >
              {nttc_toggle_command_bold ? 'Включено' : 'Выключено'}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Расширенные настройки">
        <LabeledList>
          <LabeledList.Item label="Формат отображения должностей">
            <Button
              selected={!!nttc_job_indicator_type}
              icon="pencil-alt"
              onClick={() => act('nttc_job_indicator_type')}
            >
              {nttc_job_indicator_type ? nttc_job_indicator_type : 'Не задано'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Перевод сообщений">
            <Button
              selected={!!nttc_setting_language}
              icon="globe"
              onClick={() => act('nttc_setting_language')}
            >
              {nttc_setting_language ? nttc_setting_language : 'Не задано'}
            </Button>
          </LabeledList.Item>
          <LabeledList.Item label="Сетевой идентификатор">
            <Button
              selected={!!network_id}
              icon="server"
              onClick={() => act('network_id')}
            >
              {network_id ? network_id : 'Не задано'}
            </Button>
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Техническое обслуживание">
        <Button icon="file-import" onClick={() => act('import')}>
          Загрузить конфигурацию
        </Button>
        <Button icon="file-export" onClick={() => act('export')}>
          Выгрузить конфигурацию
        </Button>
      </Section>
    </>
  );
};

const LinkagePage = (_properties) => {
  const { act, data } = useBackend<TcommsCoreData>();
  const { link_password, relay_entries } = data;
  return (
    <Section title="Привязка устройств">
      <LabeledList>
        <LabeledList.Item label="Пароль для привязки">
          <Button
            selected={!!link_password}
            icon="lock"
            onClick={() => act('change_password')}
          >
            {link_password ? link_password : 'Не задано'}
          </Button>
        </LabeledList.Item>
      </LabeledList>

      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell>Сетевой адрес</Table.Cell>
          <Table.Cell>Сетевой идентификатор</Table.Cell>
          <Table.Cell>Сектор</Table.Cell>
          <Table.Cell>Состояние</Table.Cell>
          <Table.Cell>Отвязать</Table.Cell>
        </Table.Row>
        {relay_entries.map((r) => (
          <Table.Row key={r.addr}>
            <Table.Cell>{r.addr}</Table.Cell>
            <Table.Cell>{r.net_id}</Table.Cell>
            <Table.Cell>{r.sector}</Table.Cell>
            <Table.Cell>
              {r.status ? (
                <Box color="green">В сети</Box>
              ) : (
                <Box color="red">Не в сети</Box>
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
                Отвязать
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
      title="Чёрный список пользователей"
      buttons={
        <Button icon="user-plus" onClick={() => act('add_filter')}>
          Добавить пользователя
        </Button>
      }
    >
      <Table m="0.5rem">
        <Table.Row header>
          <Table.Cell style={{ width: '90%' }}>Пользователь</Table.Cell>
          <Table.Cell style={{ width: '10%' }}>Действия</Table.Cell>
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
                Удалить
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
