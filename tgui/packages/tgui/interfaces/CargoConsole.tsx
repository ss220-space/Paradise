import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { useBackend, useSharedState } from '../backend';
import { useState } from 'react';
import {
  Button,
  LabeledList,
  Box,
  Section,
  Dropdown,
  Input,
  Table,
  Modal,
  Stack,
} from '../components';
import { Window } from '../layouts';
import { createSearch, declension_ru } from 'common/string';

export const CargoConsole = (_props: unknown) => {
  const [contentsModal, setContentsModal] = useState<string[]>(null);
  const [contentsModalTitle, setContentsModalTitle] = useState<string>(null);

  return (
    <Window width={1000} height={800}>
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

export type ContentsModalProps = {
  contentsModal: string[];
  setContentsModal: React.Dispatch<React.SetStateAction<string[]>>;
  contentsModalTitle: string;
  setContentsModalTitle: React.Dispatch<React.SetStateAction<string>>;
};

const ContentsModal = (properties: ContentsModalProps) => {
  const {
    contentsModal,
    setContentsModal,
    contentsModalTitle,
    setContentsModalTitle,
  } = properties;

  if (contentsModal !== null && contentsModalTitle !== null) {
    return (
      <Modal
        maxWidth="75%"
        width={window.innerWidth + 'px'}
        maxHeight={window.innerHeight * 0.75 + 'px'}
        mx="auto"
      >
        <Box width="100%" bold>
          <h1>Содержимое {contentsModalTitle}:</h1>
        </Box>
        <Box>
          {contentsModal.map((i) => (
            // This needs keying. I hate it.
            <Box key={i}>- {i}</Box>
          ))}
        </Box>
        <Box m={2}>
          <Button
            onClick={() => {
              setContentsModal(null);
              setContentsModalTitle(null);
            }}
          >
            Close
          </Button>
        </Box>
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
  let statusText: string;
  let shuttleButtonText: string;
  if (!moving && !at_station) {
    statusText = 'Не на объекте';
    shuttleButtonText = 'Вызвать шаттл';
  } else if (!moving && at_station) {
    statusText = 'Пристыкован к объекту';
    shuttleButtonText = 'Вернуть шаттл';
  } else if (moving) {
    shuttleButtonText = 'В пути';
    statusText =
      'В пути к объекту (прилетит через ' +
      timeleft +
      ' минут' +
      declension_ru(timeleft, 'у', 'ы', '') +
      ')';
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

export type CataloguePaneProps = {
  setContentsModal: React.Dispatch<React.SetStateAction<string[]>>;
  setContentsModalTitle: React.Dispatch<React.SetStateAction<string>>;
};

const CataloguePane = (properties: CataloguePaneProps) => {
  const { act, data } = useBackend<CataloguePaneData>();
  const { categories, supply_packs } = data;

  const [category, setCategory] = useSharedState(
    'category',
    'Чрезвычайные ситуации'
  );

  const [searchText, setSearchText] = useSharedState('search_text', '');

  const { setContentsModal, setContentsModalTitle } = properties;

  const packSearch = createSearch<SupplyPack>(
    searchText,
    (crate) => crate.name
  );

  const cratesToShow = flow([
    (supply_packs) =>
      filter<SupplyPack>(
        supply_packs,
        (pack) =>
          pack.cat ===
          (filter(categories, (c) => c.name === category)[0].category ||
            searchText)
      ),
    (supply_packs) =>
      searchText ? filter<SupplyPack>(supply_packs, packSearch) : supply_packs,
    (supply_packs) =>
      sortBy<SupplyPack>(supply_packs, (pack) => pack.name.toLowerCase()),
  ])(supply_packs);

  let titleText = 'Перечень грузов для заказа';
  if (searchText) {
    titleText = 'Результаты поиска "' + searchText + '":';
  } else if (category) {
    titleText = 'Просмотр категории "' + category + '"';
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
            {cratesToShow.map((c) => (
              <Table.Row key={c.name}>
                <Table.Cell bold>
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
                      ? c.cost + ' очк' + declension_ru(c.cost, 'о', 'а', 'ов')
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
                <Table.Cell textAlign="right" pr={1}>
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
            ))}
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
