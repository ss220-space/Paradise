import { createSearch } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  NoticeBox,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { TableCell } from '../components/Table';
import { Window } from '../layouts';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';

const Titles = {
  0: 'Антагонисты',
  1: 'Цели',
  2: 'СБ',
  3: 'Особо ценные предметы',
  default: 'Что-то не так, пора писать баг репорт!',
};

const MenuTabs = {
  0: () => <AntagList />,
  1: () => <Objectives />,
  2: () => <Security />,
  3: () => <HighValueItems />,
  default: () => 'Что-то не так, пора писать баг репорт!',
};

const PickTitle = (index) => Titles[index] || Titles.default;

const PickTab = (index) => MenuTabs[index] || MenuTabs.default;

export const AdminAntagMenu = (properties, context) => {
  const { act, data } = useBackend(context);
  const { loginState, currentPage } = data;
  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  return (
    <Window width={800} height={600} title={'Меню спец-ролей'}>
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                key="Antagonists"
                selected={tabIndex === 0}
                onClick={() => {
                  setTabIndex(0);
                }}
                icon="user"
              >
                Антагонисты
              </Tabs.Tab>
              <Tabs.Tab
                key="Objectives"
                selected={tabIndex === 1}
                onClick={() => {
                  setTabIndex(1);
                }}
                icon="people-robbery"
              >
                Цели
              </Tabs.Tab>
              <Tabs.Tab
                key="Security"
                selected={tabIndex === 2}
                onClick={() => {
                  setTabIndex(2);
                }}
                icon="handcuffs"
              >
                СБ
              </Tabs.Tab>
              <Tabs.Tab
                key="HighValueItems"
                selected={tabIndex === 3}
                onClick={() => {
                  setTabIndex(3);
                }}
                icon="lock"
              >
                Особо ценные предметы
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            <Section
              title={PickTitle(tabIndex)}
              fill
              scrollable
              buttons={
                <Stack fill>
                  <Input
                    placeholder="Искать..."
                    width="300px"
                    onInput={(e, value) => setSearchText(value)}
                  />
                  <Button icon="sync" onClick={() => act('refresh')}>
                    Обновить
                  </Button>
                </Stack>
              }
            >
              {PickTab(tabIndex)()}
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const AntagList = (properties, context) => {
  const { act, data } = useBackend(context);
  const { antagonists } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortId, _setSortId] = useLocalState(context, 'sortId', 'antag_names');
  const [sortOrder, _setSortOrder] = useLocalState(context, 'sortOrder', true);

  const keys = Object.keys(antagonists);
  if (!keys || keys.length === 0) {
    return <div>Нет антагонистов.</div>;
  }

  const antagArray = keys.map((key) => ({ key, ...antagonists[key] }));

  return (
    <Table className="AdminAntagMenu__list">
      <Table.Row bold>
        <SortButton id="name">Имя существа</SortButton>
        <SortButton id="">Кнопки</SortButton>
        <SortButton id="antag_names">Тип(-ы) антагонистов</SortButton>
        <SortButton id="status">Статус</SortButton>
      </Table.Row>
      {antagArray
        .filter(
          createSearch(searchText, ({ key, name, status, antag_names }) => {
            return name + '|' + status + '|' + antag_names.join(', ');
          })
        )
        .sort((a, b) => {
          const i = sortOrder ? 1 : -1;
          if (a[sortId] === undefined || a[sortId] === null) {
            return i;
          }
          if (b[sortId] === undefined || b[sortId] === null) {
            return -1 * i;
          }
          if (typeof a[sortId] === 'number') {
            return (a[sortId] - b[sortId]) * i;
          }
          let firstValue = a[sortId];
          let secondValue = b[sortId];
          if (sortId === 'antag_names') {
            firstValue = a[sortId].join(', ');
            secondValue = b[sortId].join(', ');
          }
          return firstValue.localeCompare(secondValue) * i;
        })
        .map(
          (
            {
              key,
              name,
              body_destroyed,
              is_hijacker,
              antag_mind_uid,
              ckey,
              status,
              antag_names,
            },
            index
          ) => (
            <Table.Row key={index}>
              <Table.Cell collapsing>
                {!body_destroyed ? (
                  <Button
                    color={is_hijacker || !name ? 'red' : ''}
                    tooltip={is_hijacker ? 'Угонщик шаттла' : ''}
                    onClick={() =>
                      act('show_player_panel', {
                        mind_uid: antag_mind_uid,
                      })
                    }
                  >
                    {name ? name : '??? (НЕТ ИМЕНИ)'}
                  </Button>
                ) : (
                  name
                )}
              </Table.Cell>
              <Table.Cell collapsing>
                <Button
                  onClick={() => {
                    act('pm', {
                      ckey,
                    });
                  }}
                >
                  PM
                </Button>
                <Button
                  onClick={() => {
                    act('follow', {
                      datum_uid: antag_mind_uid,
                    });
                  }}
                >
                  FLW
                </Button>
                <Button
                  onClick={() => {
                    act('obs', {
                      mind_uid: antag_mind_uid,
                    });
                  }}
                >
                  OBS
                </Button>
                <Button
                  onClick={() => {
                    act('tp', {
                      mind_uid: antag_mind_uid,
                    });
                  }}
                >
                  TP
                </Button>
              </Table.Cell>
              <Table.Cell>{antag_names.join(', ')}</Table.Cell>
              <Table.Cell>
                <Box color={status ? 'red' : 'grey'}>
                  {status ? status : 'Жив'}
                </Box>
              </Table.Cell>
            </Table.Row>
          )
        )}
    </Table>
  );
};

const Objectives = (properties, context) => {
  const { act, data } = useBackend(context);
  const { objectives } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortId, _setSortId] = useLocalState(context, 'sortId2', 'target_name');
  const [sortOrder, _setSortOrder] = useLocalState(context, 'sortOrder', true);
  if (!objectives.length) {
    return 'Нет целей!';
  }
  return (
    <Table className="AdminAntagMenu__list">
      <Table.Row bold>
        <SortButton sort_group="sortId2" id="obj_name">
          Имя
        </SortButton>
        <SortButton sort_group="sortId2" id="target_name">
          Цель
        </SortButton>
        <SortButton sort_group="sortId2" id="status">
          Статус
        </SortButton>
        <SortButton sort_group="sortId2" id="owner_name">
          Хозяин
        </SortButton>
      </Table.Row>
      {objectives
        .filter(
          createSearch(searchText, (objective) => {
            return (
              objective.obj_name +
              '|' +
              objective.target_name +
              '|' +
              (objective.status ? 'success' : 'incompleted') +
              '|' +
              objective.owner_name
            );
          })
        )
        .sort((a, b) => {
          const i = sortOrder ? 1 : -1;
          if (
            a[sortId] === undefined ||
            a[sortId] === null ||
            (sortId === 'target_name' && a.no_target)
          ) {
            return i;
          }
          if (
            b[sortId] === undefined ||
            b[sortId] === null ||
            (sortId === 'target_name' && b.no_target)
          ) {
            return -1 * i;
          }
          if (typeof a[sortId] === 'number') {
            return (a[sortId] - b[sortId]) * i;
          }
          return a[sortId].localeCompare(b[sortId]) * i;
        })
        .map((objective, index) => (
          <Table.Row key={index}>
            <Table.Cell>
              <Button
                tooltip={objective.obj_desc}
                onClick={() =>
                  act('vv', {
                    uid: objective.obj_uid,
                  })
                }
              >
                {objective.obj_name}
              </Button>
            </Table.Cell>
            <Table.Cell>
              {objective.no_target
                ? ''
                : objective.track.length
                  ? objective.track.map((target, index) => (
                      <Button
                        key={index}
                        onClick={() =>
                          act('follow', {
                            datum_uid: target,
                          })
                        }
                      >
                        {objective.target_name}{' '}
                        {objective.track.length > 1
                          ? '(' + (parseInt(index, 10) + 1) + ')'
                          : ''}
                      </Button>
                    ))
                  : objective.target_name + ' (не найдено)'}
            </Table.Cell>
            <Table.Cell>
              <Box color={objective.status ? 'green' : 'grey'}>
                {objective.status ? 'Успешно' : 'Незавершено'}
              </Box>
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                onClick={() => {
                  act('obj_owner', {
                    owner_uid: objective.owner_uid,
                  });
                }}
              >
                {objective.owner_name}
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
    </Table>
  );
};

const Security = (properties, context) => {
  const { act, data } = useBackend(context);
  const { security } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortId, _setSortId] = useLocalState(context, 'sortId3', 'health');
  const [sortOrder, _setSortOrder] = useLocalState(context, 'sortOrder', true);

  const getColor = (officer) => {
    if (officer.status === 2) {
      return 'red';
    }
    if (officer.status === 1) {
      return 'orange';
    }
    if (officer.broken_bone || officer.internal_bleeding) {
      return 'yellow';
    }
    return 'grey';
  };
  const getStatus = (officer) => {
    if (officer.status === 2) {
      return 'Мёртв';
    }
    if (officer.status === 1) {
      return 'Без сознания';
    }
    if (officer.broken_bone && officer.internal_bleeding) {
      return 'Сломана кость, ВК';
    }
    if (officer.broken_bone) {
      return 'Сломана кость';
    }
    if (officer.internal_bleeding) {
      return 'ВК';
    }
    return 'Жив';
  };

  if (!security.length) {
    return 'Нету СБ!';
  }
  return (
    <Table className="AdminAntagMenu__list">
      <Table.Row bold>
        <SortButton sort_group="sortId3" id="name">
          Имя
        </SortButton>
        <SortButton sort_group="sortId3" id="role">
          Должность
        </SortButton>
        <SortButton sort_group="sortId3" id="status">
          Статус
        </SortButton>
        <SortButton sort_group="sortId3" id="antag">
          Антагонист
        </SortButton>
        <SortButton sort_group="sortId3" id="health">
          Здоровье
        </SortButton>
      </Table.Row>
      {security
        .filter(
          createSearch(searchText, (officer) => {
            return (
              officer.name +
              '|' +
              officer.role +
              '|' +
              getStatus(officer) +
              '|' +
              officer.antag
            );
          })
        )
        .sort((a, b) => {
          const i = sortOrder ? 1 : -1;
          if (a[sortId] === undefined || a[sortId] === null) {
            return i;
          }
          if (b[sortId] === undefined || b[sortId] === null) {
            return -1 * i;
          }
          if (typeof a[sortId] === 'number') {
            return (a[sortId] - b[sortId]) * i;
          }
          return a[sortId].localeCompare(b[sortId]) * i;
        })
        .map((officer, index) => (
          <Table.Row key={index}>
            <Table.Cell collapsing>
              <Button
                onClick={() =>
                  act('show_player_panel', {
                    mind_uid: officer.mind_uid,
                  })
                }
              >
                {officer.name}
              </Button>
            </Table.Cell>
            <Table.Cell collapsing>{officer.role}</Table.Cell>
            <Table.Cell collapsing>
              <Box color={getColor(officer)}>{getStatus(officer)}</Box>
            </Table.Cell>
            <Table.Cell collapsing>
              {officer.antag ? (
                <Button
                  textColor="red"
                  translucent
                  onClick={() => {
                    act('tp', {
                      mind_uid: officer.mind_uid,
                    });
                  }}
                >
                  {officer.antag}
                </Button>
              ) : (
                ''
              )}
            </Table.Cell>
            <Table.Cell>
              <ProgressBar
                minValue={0}
                value={officer.health / officer.max_health}
                maxValue={1}
                ranges={{
                  good: [0.6, Infinity],
                  average: [0, 0.6],
                  bad: [-Infinity, 0],
                }}
              >
                {officer.health}
              </ProgressBar>
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                onClick={() => {
                  act('pm', {
                    ckey: officer.ckey,
                  });
                }}
              >
                PM
              </Button>
              <Button
                onClick={() => {
                  act('follow', {
                    datum_uid: officer.mind_uid,
                  });
                }}
              >
                FLW
              </Button>
              <Button
                onClick={() => {
                  act('obs', {
                    mind_uid: officer.mind_uid,
                  });
                }}
              >
                OBS
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
    </Table>
  );
};

const HighValueItems = (properties, context) => {
  const { act, data } = useBackend(context);
  const { high_value_items } = data;
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const [sortId, _setSortId] = useLocalState(context, 'sortId4', 'person');
  const [sortOrder, _setSortOrder] = useLocalState(context, 'sortOrder', true);
  if (!high_value_items.length) {
    return 'Нет особо ценных предметов!';
  }
  return (
    <Table className="AdminAntagMenu__list">
      <Table.Row bold>
        <SortButton sort_group="sortId4" id="name">
          Имя
        </SortButton>
        <SortButton sort_group="sortId4" id="person">
          Носитель
        </SortButton>
        <SortButton sort_group="sortId4" id="loc">
          Местоположение
        </SortButton>
        <SortButton sort_group="sortId4" id="admin_z">
          Админский Z-уровень
        </SortButton>
      </Table.Row>
      {high_value_items
        .filter(
          createSearch(searchText, (item) => {
            return item.name + '|' + item.loc;
          })
        )
        .sort((a, b) => {
          const i = sortOrder ? 1 : -1;
          if (a[sortId] === undefined || a[sortId] === null) {
            return i;
          }
          if (b[sortId] === undefined || b[sortId] === null) {
            return -1 * i;
          }
          if (typeof a[sortId] === 'number') {
            return (a[sortId] - b[sortId]) * i;
          }
          return a[sortId].localeCompare(b[sortId]) * i;
        })
        .map((item, index) => (
          <Table.Row key={index}>
            <Table.Cell>
              <Button
                tooltip={item.obj_desc}
                translucent={item.admin_z}
                onClick={() =>
                  act('vv', {
                    uid: item.uid,
                  })
                }
              >
                {item.name}
              </Button>
            </Table.Cell>
            <Table.Cell>
              <Box color={item.admin_z ? 'grey' : ''}>{item.person}</Box>
            </Table.Cell>
            <Table.Cell>
              <Box color={item.admin_z ? 'grey' : ''}>{item.loc}</Box>
            </Table.Cell>
            <Table.Cell>
              <Box color="grey">{item.admin_z ? 'Да' : 'Нет'}</Box>
            </Table.Cell>
            <Table.Cell collapsing>
              <Button
                onClick={() => {
                  act('follow', {
                    datum_uid: item.uid,
                  });
                }}
              >
                FLW
              </Button>
            </Table.Cell>
          </Table.Row>
        ))}
    </Table>
  );
};

const SortButton = (properties, context) => {
  const {
    id,
    sort_group = 'sortId',
    default_sort = 'antag_names',
    children,
  } = properties;
  const [sortId, setSortId] = useLocalState(context, sort_group, default_sort);
  const [sortOrder, setSortOrder] = useLocalState(context, 'sortOrder', true);
  return (
    <Table.Cell>
      <Button
        color={sortId !== id && 'transparent'}
        width="100%"
        onClick={() => {
          if (sortId === id) {
            setSortOrder(!sortOrder);
          } else {
            setSortId(id);
            setSortOrder(true);
          }
        }}
      >
        {children}
        {sortId === id && (
          <Icon name={sortOrder ? 'sort-up' : 'sort-down'} ml="0.25rem;" />
        )}
      </Button>
    </Table.Cell>
  );
};
