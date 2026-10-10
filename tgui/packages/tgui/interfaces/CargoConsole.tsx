import { declension_ru } from 'common/l10n';
import { sortBy } from 'es-toolkit';
import { useMemo, useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
  Dropdown,
  Icon,
  Input,
  LabeledList,
  Modal,
  Section,
  Stack,
  Table,
} from 'tgui-core/components';
import { flow } from 'tgui-core/fp';
import { capitalize, createSearch } from 'tgui-core/string';
import { useBackend, useSharedState } from '../backend';
import { Window } from '../layouts';

export type CargoPackContent = {
  name: string;
  name_en?: string | null;
  icon?: string | null;
  icon_state?: string | null;
};

type CargoSupplyPack = SupplyPack & {
  contents: CargoPackContent[];
  cost: number;
  creditsCost: number;
  ref: string;
  has_sale: boolean;
  is_enough_techs: boolean;
};

type CargoCatalogueData = {
  categories: Category[];
  supply_packs: CargoSupplyPack[];
};

export const CargoConsole = (_props: unknown) => {
  const [contentsModal, setContentsModal] = useState<CargoPackContent[]>([]);
  const [contentsModalTitle, setContentsModalTitle] = useState<string>('');

  return (
    <Window width={1000} height={800} theme="cargo">
      <Window.Content>
        <Stack fill vertical>
          <ContentsModal
            contentsModal={contentsModal}
            setContentsModal={setContentsModal}
            contentsModalTitle={contentsModalTitle}
            setContentsModalTitle={setContentsModalTitle}
          />
          <StatusPane />
          <CataloguePane
            setContentsModal={setContentsModal}
            setContentsModalTitle={setContentsModalTitle}
          />
          <DetailsPane />
        </Stack>
      </Window.Content>
    </Window>
  );
};

export type ContentsModalProps<T = string> = {
  contentsModal: T[];
  setContentsModal: React.Dispatch<React.SetStateAction<T[]>>;
  contentsModalTitle: string;
  setContentsModalTitle: React.Dispatch<React.SetStateAction<string>>;
};

const ContentsModal = (properties: ContentsModalProps<CargoPackContent>) => {
  const {
    contentsModal,
    setContentsModal,
    contentsModalTitle,
    setContentsModalTitle,
  } = properties;

  const groupedContents = useMemo(() => {
    const grouped = new Map<
      string,
      { content: CargoPackContent; count: number }
    >();

    for (const content of contentsModal) {
      const key = `${content.icon}|${content.icon_state}|${content.name}`;
      const existing = grouped.get(key);
      if (existing) {
        existing.count += 1;
      } else {
        grouped.set(key, { content, count: 1 });
      }
    }

    return sortBy(
      [...grouped.values()],
      [(entry) => entry.content.name.toLowerCase()],
    );
  }, [contentsModal]);

  const totalItems = contentsModal.length;

  if (contentsModal.length && contentsModalTitle !== '') {
    return (
      <Modal
        maxWidth="75%"
        width={`${window.innerWidth}px`}
        maxHeight={`${window.innerHeight * 0.75}px`}
        mx="auto"
      >
        <Section
          title={`Содержимое: ${contentsModalTitle}`}
          buttons={
            <Button
              icon="times"
              onClick={() => {
                setContentsModal([]);
                setContentsModalTitle('');
              }}
            >
              Закрыть
            </Button>
          }
        >
          <Box maxHeight="20rem" overflowY="auto" overflowX="hidden">
            <Table>
              {groupedContents.map(({ content, count }, index) => {
                const dividerStyle =
                  index < groupedContents.length - 1
                    ? {
                        borderBottom: 'var(--divider-border)',
                      }
                    : undefined;
                return (
                  <Table.Row
                    key={`${content.icon}|${content.icon_state}|${content.name}`}
                  >
                    <Table.Cell
                      collapsing
                      width="42px"
                      verticalAlign="middle"
                      style={dividerStyle}
                    >
                      {content.icon && content.icon_state ? (
                        <DmIcon
                          icon={content.icon}
                          icon_state={content.icon_state}
                          fallback={<Icon name="box" color="gray" />}
                          width="32px"
                          height="32px"
                        />
                      ) : (
                        <Icon name="box" color="gray" />
                      )}
                    </Table.Cell>
                    <Table.Cell verticalAlign="middle" style={dividerStyle}>
                      {capitalize(content.name)}
                    </Table.Cell>
                    <Table.Cell
                      collapsing
                      textAlign="right"
                      verticalAlign="middle"
                      style={dividerStyle}
                    >
                      {count > 1 && (
                        <Box color="good" bold>
                          {`× ${count} шт.`}
                        </Box>
                      )}
                    </Table.Cell>
                  </Table.Row>
                );
              })}
            </Table>
          </Box>
        </Section>
      </Modal>
    );
  } else {
    return;
  }
};

type StatusPaneData = {
  is_public: boolean;
  points: number;
  credits: number;
  timeleft: number;
  moving: boolean;
  at_station: boolean;
};

const StatusPane = (_properties) => {
  const { act, data } = useBackend<StatusPaneData>();
  const { is_public, points, credits, timeleft, moving, at_station } = data;

  // Shuttle status text
  let statusText: string = '';
  let shuttleButtonText: string = '';
  if (!moving && !at_station) {
    statusText = 'Не на объекте';
    shuttleButtonText = 'Вызвать шаттл';
  } else if (!moving && at_station) {
    statusText = 'Пристыкован к объекту';
    shuttleButtonText = 'Вернуть шаттл';
  } else if (moving) {
    shuttleButtonText = 'В пути';
    statusText = `В пути к объекту (прилетит через: ${timeleft})`;
  }

  return (
    <Stack.Item>
      <Section title="Статус">
        <LabeledList>
          <LabeledList.Item label="Очки снабжения">{points}</LabeledList.Item>
          <LabeledList.Item label="Кредиты">{credits}</LabeledList.Item>
          <LabeledList.Item label="Статус шаттла">
            {statusText}
          </LabeledList.Item>
          {!is_public && (
            <LabeledList.Item label="Управление">
              <Button disabled={moving} onClick={() => act('moveShuttle')}>
                {shuttleButtonText}
              </Button>
              <Button onClick={() => act('showMessages')}>
                Посмотреть сообщения ЦК
              </Button>
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

export type CataloguePaneProps<T = string> = {
  setContentsModal: React.Dispatch<React.SetStateAction<T[]>>;
  setContentsModalTitle: React.Dispatch<React.SetStateAction<string>>;
};

const CataloguePane = (properties: CataloguePaneProps<CargoPackContent>) => {
  const { act, data } = useBackend<CargoCatalogueData>();
  const { categories, supply_packs } = data;

  const [category, setCategory] = useSharedState(
    'category',
    'Чрезвычайные ситуации',
  );

  const [searchText, setSearchText] = useSharedState('search_text', '');

  const { setContentsModal, setContentsModalTitle } = properties;

  const packSearch = createSearch<CargoSupplyPack>(searchText, (crate) =>
    [
      crate.name,
      ...crate.contents.flatMap((content) => [
        content.name,
        content.name_en ?? '',
      ]),
    ].join('|'),
  );

  const targetCategory = !searchText
    ? categories.filter((c) => c.name === category)[0]?.category || category
    : null;

  const cratesToShow = flow([
    (supply_packs) =>
      supply_packs.filter((pack: CargoSupplyPack) => {
        if (searchText) {
          return true;
        }
        return pack.cat === targetCategory;
      }),
    (supply_packs) =>
      searchText ? supply_packs.filter(packSearch) : supply_packs,
    (supply_packs) =>
      sortBy<CargoSupplyPack>(supply_packs, [
        (pack) => pack.name.toLowerCase(),
      ]),
  ])(supply_packs);

  let titleText = 'Перечень грузов для заказа';
  if (searchText) {
    titleText = `Результаты поиска "${searchText}":`;
  } else if (category) {
    titleText = `Просмотр категории "${category}"`;
  }
  return (
    <Stack.Item>
      <Section
        title={titleText}
        buttons={
          <Dropdown
            width="190px"
            options={categories.map((r) => r.name)}
            selected={category}
            onSelected={(val) => setCategory(val)}
          />
        }
      >
        <Input
          fluid
          placeholder="Поиск"
          expensive
          onChange={setSearchText}
          mb={1}
        />
        <Box maxHeight={25} overflowY="auto" overflowX="hidden">
          <Table m="0.5rem">
            {cratesToShow.map((c, index) => {
              const firstContent = c.contents[0];
              const dividerStyle =
                index < cratesToShow.length - 1
                  ? { borderBottom: 'var(--divider-border)' }
                  : undefined;
              return (
                <Table.Row key={c.name}>
                  <Table.Cell
                    collapsing
                    width="42px"
                    verticalAlign="middle"
                    style={dividerStyle}
                  >
                    {firstContent?.icon && firstContent.icon_state ? (
                      <DmIcon
                        icon={firstContent.icon}
                        icon_state={firstContent.icon_state}
                        fallback={<Icon name="box" color="gray" />}
                        width="32px"
                        height="32px"
                      />
                    ) : (
                      <Icon name="box" color="gray" />
                    )}
                  </Table.Cell>
                  <Table.Cell bold verticalAlign="middle" style={dividerStyle}>
                    <Box
                      color={
                        !c.is_enough_techs
                          ? 'red'
                          : c.has_sale
                            ? 'good'
                            : 'default'
                      }
                    >
                      {c.name} (
                      {c.cost
                        ? `${c.cost} очк${declension_ru(c.cost, 'о', 'а', 'ов')}`
                        : ''}
                      {c.creditsCost && c.cost ? ' ' : ''}
                      {c.creditsCost
                        ? c.creditsCost +
                          ' Кредит' +
                          declension_ru(c.creditsCost, '', 'а', 'ов')
                        : ''}
                      )
                    </Box>
                  </Table.Cell>
                  <Table.Cell
                    textAlign="right"
                    pr={1}
                    verticalAlign="middle"
                    style={dividerStyle}
                  >
                    <Button
                      icon="shopping-cart"
                      onClick={() =>
                        act('order', {
                          crate: c.ref,
                          multiple: 0,
                        })
                      }
                    >
                      Заказать 1
                    </Button>
                    <Button
                      icon="cart-plus"
                      onClick={() =>
                        act('order', {
                          crate: c.ref,
                          multiple: 1,
                        })
                      }
                    >
                      Заказать несколько
                    </Button>
                    <Button
                      icon="search"
                      onClick={() => {
                        setContentsModal(c.contents);
                        setContentsModalTitle(c.name);
                      }}
                    >
                      Содержимое
                    </Button>
                  </Table.Cell>
                </Table.Row>
              );
            })}
          </Table>
        </Box>
      </Section>
    </Stack.Item>
  );
};

const DetailsPane = (_properties) => {
  const { act, data } = useBackend<DetailsPaneData>();
  const { requests, canapprove, orders } = data;
  return (
    <Section fill scrollable title="Details">
      <Box bold>Запросы</Box>
      <Table m="0.5rem">
        {requests.map((r) => (
          <Table.Row key={r.ordernum}>
            <Table.Cell>
              <Box>
                - №{r.ordernum}: {r.supply_type} для <b>{r.orderedby}</b>
              </Box>
              <Box italic>Причина: {r.comment}</Box>
              <Box italic>Требуемые тех. уровни: {r.pack_techs}</Box>
            </Table.Cell>
            <Stack.Item textAlign="right">
              <Button
                color="green"
                disabled={!canapprove}
                onClick={() =>
                  act('approve', {
                    ordernum: r.ordernum,
                  })
                }
              >
                Одобрить
              </Button>
              <Button
                color="red"
                onClick={() =>
                  act('deny', {
                    ordernum: r.ordernum,
                  })
                }
              >
                Отказать
              </Button>
            </Stack.Item>
          </Table.Row>
        ))}
      </Table>
      <Box bold>Утверждённые заказы</Box>
      <Table m="0.5rem">
        {orders.map((r) => (
          <Table.Row key={r.ordernum}>
            <Table.Cell>
              <Box>
                - №{r.ordernum}: {r.supply_type} для <b>{r.orderedby}</b>
              </Box>
              <Box italic>Причина: {r.comment}</Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
