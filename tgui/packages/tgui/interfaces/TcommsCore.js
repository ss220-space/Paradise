import { useBackend, useLocalState } from '../backend';
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

export const TcommsCore = (props) => {
  const { act, data } = useBackend();
  const { ion } = data;
  const [tabIndex, setTabIndex] = useLocalState('tabIndex', 0);

  const PickTab = (index) => {
    switch (index) {
      case 0:
        return <ConfigPage />;
      case 1:
        return <LinkagePage />;
      case 2:
        return <FilteringPage />;
      default:
        return 'ЧТО-ТО СЛОМАЛОСЬ, НАПИШИТЕ В #баг-репорты-v2';
    }
  };

  return (
    <Window width={900} height={600}>
      <Window.Content scrollable>
        {ion === 1 && <IonBanner />}
        <Tabs>
          <Tabs.Tab
            key="ConfigPage"
            selected={tabIndex === 0}
            onClick={() => setTabIndex(0)}
          >
            <Icon name="wrench" />
            Конфигурация
          </Tabs.Tab>
          <Tabs.Tab
            key="LinkagePage"
            selected={tabIndex === 1}
            onClick={() => setTabIndex(1)}
          >
            <Icon name="link" />
            Привязанные устройства
          </Tabs.Tab>
          <Tabs.Tab
            key="FilterPage"
            selected={tabIndex === 2}
            onClick={() => setTabIndex(2)}
          >
            <Icon name="user-times" />
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
  const { act, data } = useBackend();
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
              content={active ? 'Включено' : 'Выключено'}
              selected={active}
              icon="power-off"
              onClick={() => act('toggle_active')}
            />
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
              content={nttc_toggle_jobs ? 'Включено' : 'Выключено'}
              selected={nttc_toggle_jobs}
              icon="user-tag"
              onClick={() => act('nttc_toggle_jobs')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Выделение должностей по отделам">
            <Button
              content={nttc_toggle_job_color ? 'Включено' : 'Выключено'}
              selected={nttc_toggle_job_color}
              icon="clipboard-list"
              onClick={() => act('nttc_toggle_job_color')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Выделение имён по отделам">
            <Button
              content={nttc_toggle_name_color ? 'Включено' : 'Выключено'}
              selected={nttc_toggle_name_color}
              icon="user-tag"
              onClick={() => act('nttc_toggle_name_color')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Выделение должностей командования">
            <Button
              content={nttc_toggle_command_bold ? 'Включено' : 'Выключено'}
              selected={nttc_toggle_command_bold}
              icon="volume-up"
              onClick={() => act('nttc_toggle_command_bold')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Расширенные настройки">
        <LabeledList>
          <LabeledList.Item label="Формат отображения должностей">
            <Button
              content={
                nttc_job_indicator_type ? nttc_job_indicator_type : 'Не задано'
              }
              selected={nttc_job_indicator_type}
              icon="pencil-alt"
              onClick={() => act('nttc_job_indicator_type')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Перевод сообщений">
            <Button
              content={
                nttc_setting_language ? nttc_setting_language : 'Не задано'
              }
              selected={nttc_setting_language}
              icon="globe"
              onClick={() => act('nttc_setting_language')}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Сетевой идентификатор">
            <Button
              content={network_id ? network_id : 'Не задано'}
              selected={network_id}
              icon="server"
              onClick={() => act('network_id')}
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>

      <Section title="Техническое обслуживание">
        <Button
          content="Загрузить конфигурацию"
          icon="file-import"
          onClick={() => act('import')}
        />
        <Button
          content="Выгрузить конфигурацию"
          icon="file-export"
          onClick={() => act('export')}
        />
      </Section>
    </>
  );
};

const LinkagePage = (_properties) => {
  const { act, data } = useBackend();
  const { link_password, relay_entries } = data;
  return (
    <Section title="Привязка устройств">
      <LabeledList>
        <LabeledList.Item label="Пароль для привязки">
          <Button
            content={link_password ? link_password : 'Не задано'}
            selected={link_password}
            icon="lock"
            onClick={() => act('change_password')}
          />
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
              {r.status === 1 ? (
                <Box color="green">В сети</Box>
              ) : (
                <Box color="red">Не в сети</Box>
              )}
            </Table.Cell>
            <Table.Cell>
              <Button
                content="Отвязать"
                icon="unlink"
                onClick={() =>
                  act('unlink', {
                    addr: r.addr,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const FilteringPage = (_properties) => {
  const { act, data } = useBackend();
  const { filtered_users } = data;
  return (
    <Section
      title="Чёрный список пользователей"
      buttons={
        <Button
          content="Добавить пользователя"
          icon="user-plus"
          onClick={() => act('add_filter')}
        />
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
                content="Удалить"
                icon="user-times"
                onClick={() =>
                  act('remove_filter', {
                    user: u,
                  })
                }
              />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
