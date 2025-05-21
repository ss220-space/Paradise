import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';

import { createSearch, decodeHtmlEntities } from 'common/string';
import { Countdown } from '../components/Countdown';
import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Box,
  Button,
  Input,
  Section,
  Stack,
  Divider,
  Tabs,
  LabeledList,
  Icon,
} from '../components';
import { Window } from '../layouts';
import {
  ComplexModal,
  modalOpen,
  modalAnswer,
  modalRegisterBodyOverride,
} from './common/ComplexModal';

type PickTabProps = ShowDescProps & SearchTextProps;

type ShowDescProps = {
  showDesc: boolean;
  setShowDesc: React.Dispatch<React.SetStateAction<boolean>>;
};

const PickTab = (index: number, props: PickTabProps) => {
  switch (index) {
    case 0:
      return <ItemsPage {...props} />;
    case 1:
      return <CartPage {...props} />;
    case 2:
      return <ExploitableInfoPage />;
    default:
      return 'SOMETHING WENT VERY WRONG PLEASE AHELP';
  }
};

type UplinkData = {
  cart: Cart[];
  contractor: Contractor;
  crystals: number;
  cats: Category[];
  cart_price: number;
  lucky_numbers: LuckyNumber[];
  exploitable: ExploitableRecord[];
};

type Contractor = {
  available: boolean;
  accepted: boolean;
  affordable: boolean;
  is_admin_forced: boolean;
  available_offers: number;
  time_left: number;
};

type Category = {
  items: Item[];
  cat: string;
};

type Item = {
  name: string;
  desc: string;
  cost: number;
  hijack_only: boolean;
  obj_path: string;
  refundable: boolean;
};

type Cart = {
  name: string;
  obj_path: string;
  cost: number;
  amount: number;
  limit: number;
};

type LuckyNumber = {
  cat: string;
  item: string;
};

type ExploitableRecord = {
  name: string;
  age: number;
  fingerprint: string;
  rank: string;
  sex: string;
  species: string;
  exploit_record: string;
};

export const Uplink = (_props: unknown) => {
  const { act, data } = useBackend<UplinkData>();
  const { cart } = data;

  const [tabIndex, setTabIndex] = useState(0);
  const [searchText, setSearchText] = useState('');
  const [showDesc, setShowDesc] = useState(true);

  return (
    <Window width={900} height={700} theme="syndicate">
      <ComplexModal maxHeight={50} />
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                key="PurchasePage"
                selected={tabIndex === 0}
                onClick={() => {
                  setTabIndex(0);
                  setSearchText('');
                }}
                icon="store"
              >
                Магазин
              </Tabs.Tab>
              <Tabs.Tab
                key="Cart"
                selected={tabIndex === 1}
                onClick={() => {
                  setTabIndex(1);
                  setSearchText('');
                }}
                icon="shopping-cart"
              >
                Корзина {cart && cart.length ? '(' + cart.length + ')' : ''}
              </Tabs.Tab>
              <Tabs.Tab
                key="ExploitableInfo"
                selected={tabIndex === 2}
                onClick={() => {
                  setTabIndex(2);
                  setSearchText('');
                }}
                icon="user"
              >
                Информация
              </Tabs.Tab>
              {!!data.contractor && (
                <Tabs.Tab
                  key="BecomeContractor"
                  color={
                    !!data.contractor.available && !data.contractor.accepted
                      ? 'yellow'
                      : 'transparent'
                  }
                  onClick={() => modalOpen('become_contractor')}
                  icon="suitcase"
                >
                  Заключение контракта
                  {!data.contractor.is_admin_forced &&
                  !data.contractor.accepted ? (
                    data.contractor.available_offers > 0 ? (
                      <i>[Осталось:{data.contractor.available_offers}]</i>
                    ) : (
                      <i>[Предложения закончились]</i>
                    )
                  ) : (
                    ''
                  )}
                  {data.contractor.accepted ? (
                    <i>&nbsp;(Заключён)</i>
                  ) : !data.contractor.is_admin_forced &&
                    data.contractor.available_offers <= 0 ? (
                    ''
                  ) : (
                    <Countdown
                      timeLeft={data.contractor.time_left}
                      format={(v, f) => ' (' + f + ')'}
                    />
                  )}
                </Tabs.Tab>
              )}
              <Tabs.Tab
                key="LockUplink"
                // This cant ever be selected. Its just a close button.
                onClick={() => act('lock')}
                icon="lock"
              >
                Заблокировать
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {PickTab(tabIndex, {
              searchText,
              setSearchText,
              showDesc,
              setShowDesc,
            })}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemsPage = (properties: SearchTextProps & ShowDescProps) => {
  const { act, data } = useBackend<UplinkData>();
  const { crystals, cats } = data;
  // Default to first
  const [uplinkItems, setUplinkItems] = useState(cats[0].items);

  const { searchText, setSearchText, showDesc, setShowDesc } = properties;

  const SelectEquipment = (cat: Item[], searchText = '') => {
    const EquipmentSearch = createSearch<Item>(searchText, (item) => {
      let is_hijack = item.hijack_only ? '|' + 'hijack' : '';
      return item.name + '|' + item.desc + '|' + item.cost + 'tc' + is_hijack;
    });
    return flow([
      (cat: Item[]) => filter(cat, (item) => !!item?.name), // Make sure it has a name
      (cat: Item[]) => (searchText ? filter(cat, EquipmentSearch) : cat), // Search for anything
      (cat: Item[]) => sortBy(cat, (item) => item?.name), // Sort by name
    ])(cat);
  };
  const handleSearch = (value) => {
    setSearchText(value);
    if (value === '') {
      return setUplinkItems(cats[0].items);
    }
    setUplinkItems(
      SelectEquipment(cats.map((category) => category.items).flat(), value)
    );
  };

  return (
    <Stack fill vertical>
      <Stack vertical>
        <Stack.Item>
          <Section
            title={'Текущий баланс: ' + crystals + ' ' + 'ТК'}
            buttons={
              <>
                <Button.Checkbox
                  content="Показывать описание"
                  checked={showDesc}
                  onClick={() => setShowDesc(!showDesc)}
                />
                <Button
                  content="Случайный предмет"
                  icon="question"
                  onClick={() => act('buyRandom')}
                />
                <Button
                  content="Сделать возврат"
                  icon="undo"
                  onClick={() => act('refund')}
                />
              </>
            }
          >
            <Input
              fluid
              placeholder="Поиск..."
              onInput={(e, value) => {
                handleSearch(value);
              }}
              value={searchText}
            />
          </Section>
        </Stack.Item>
      </Stack>
      <Stack fill mt={0.3}>
        <Stack.Item width="26%">
          <Section fill scrollable>
            <Tabs vertical>
              {cats.map((c, index) => (
                <Tabs.Tab
                  key={index}
                  selected={searchText !== '' ? false : c.items === uplinkItems}
                  onClick={() => {
                    setUplinkItems(c.items);
                    setSearchText('');
                  }}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                  mb={0.5}
                  ml={0.5}
                >
                  {c.cat}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Stack.Item>
        <Stack.Item grow>
          <Section fill scrollable>
            <Stack vertical>
              {uplinkItems.map((i) => (
                <Stack.Item
                  key={decodeHtmlEntities(i.name)}
                  p={1}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                >
                  <UplinkItem
                    i={i}
                    showDecription={showDesc}
                    key={decodeHtmlEntities(i.name)}
                  />
                </Stack.Item>
              ))}
            </Stack>
          </Section>
        </Stack.Item>
      </Stack>
    </Stack>
  );
};

const CartPage = (properties: ShowDescProps) => {
  const { act, data } = useBackend<UplinkData>();
  const { cart, crystals, cart_price } = data;

  const { showDesc, setShowDesc } = properties;

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={'Текущий баланс: ' + crystals + ' ' + 'ТК'}
          buttons={
            <>
              <Button.Checkbox
                checked={showDesc}
                onClick={() => setShowDesc(!showDesc)}
              >
                Показывать описание
              </Button.Checkbox>
              <Button
                icon="trash"
                onClick={() => act('empty_cart')}
                disabled={!cart}
              >
                Очистить корзину
              </Button>
              <Button
                icon="shopping-cart"
                onClick={() => act('purchase_cart')}
                disabled={!cart || cart_price > crystals}
              >
                {'Купить корзину (' + cart_price + 'TC)'}
              </Button>
            </>
          }
        >
          <Stack vertical>
            {cart ? (
              cart.map((i) => (
                <Stack.Item
                  key={decodeHtmlEntities(i.name)}
                  p={1}
                  mr={1}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                >
                  <UplinkItem
                    i={i}
                    showDecription={showDesc}
                    buttons={<CartButtons i={i} />}
                  />
                </Stack.Item>
              ))
            ) : (
              <Box italic>Ваша корзина пуста!</Box>
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Advert {...properties} />
    </Stack>
  );
};
const Advert = (properties: ShowDescProps) => {
  const { act, data } = useBackend<UplinkData>();
  const { cats, lucky_numbers } = data;

  const { showDesc } = properties;

  return (
    <Stack.Item grow>
      <Section
        fill
        scrollable
        title="Рекомендуемые товары"
        buttons={
          <Button icon="dice" onClick={() => act('shuffle_lucky_numbers')}>
            Новые рекомендации
          </Button>
        }
      >
        <Stack wrap>
          {lucky_numbers
            .map((number) => cats[number.cat].items[number.item])
            .filter((item) => item !== undefined && item !== null)
            .map((item, index) => (
              <Stack.Item
                key={index}
                p={1}
                mb={1}
                ml={1}
                width={34}
                backgroundColor={'rgba(255, 0, 0, 0.15)'}
              >
                <UplinkItem grow i={item} showDecription={showDesc} />
              </Stack.Item>
            ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const UplinkItem = (props) => {
  const {
    i,
    showDecription = 1,
    buttons = <UplinkItemButtons i={i} />,
  } = props;

  return (
    <Section title={decodeHtmlEntities(i.name)}>
      {showDecription ? <Box italic>{decodeHtmlEntities(i.desc)}</Box> : null}
      <Box mt={2}>{buttons}</Box>
    </Section>
  );
};

type UplinkItemButtonsProps = {
  i: Item;
};

const UplinkItemButtons = (props: UplinkItemButtonsProps) => {
  const { act, data } = useBackend<UplinkData>();
  const { i } = props;
  const { crystals } = data;

  return (
    <>
      <Button
        icon="shopping-cart"
        color={i.hijack_only && 'red'}
        tooltip="Добавить в корзину"
        tooltipPosition="left"
        onClick={() =>
          act('add_to_cart', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      />
      <Button
        color={i.hijack_only && 'red'}
        // Yes I care this much about both of these being able to render at the same time
        tooltip={
          i.hijack_only &&
          'Только для агентов, имеющих цель — угон эвакуационного шаттла!'
        }
        tooltipPosition="left"
        onClick={() =>
          act('buyItem', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      >
        {'Купить (' +
          i.cost +
          ' ' +
          'ТК)' +
          (i.refundable ? ' [Возвращаемый]' : '')}
      </Button>
    </>
  );
};

type CartButtonsProps = {
  i: Cart;
};

const CartButtons = (props: CartButtonsProps) => {
  const { act } = useBackend();
  const { i } = props;

  return (
    <Stack>
      <Button
        icon="times"
        tooltip="Удалить из корзины"
        tooltipPosition="left"
        onClick={() =>
          act('remove_from_cart', {
            item: i.obj_path,
          })
        }
      >
        {'(' + i.cost * i.amount + ' ' + 'ТК)'}
      </Button>
      <Button
        icon="minus"
        tooltip={i.limit === 0 && 'Скидка уже активирована!'}
        ml="5px"
        onClick={() =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: --i.amount, // one lower
          })
        }
        disabled={i.amount <= 0}
      />
      <Button.Input
        width="45px"
        tooltipPosition="bottom-end"
        tooltip={i.limit === 0 && 'Скидка уже активирована!'}
        onCommit={(e, value) =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: value,
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit && i.amount <= 0}
      >
        {i.amount}
      </Button.Input>
      <Button
        mb={0.3}
        icon="plus"
        tooltipPosition="bottom-start"
        tooltip={i.limit === 0 && 'Скидка уже активирована!'}
        onClick={() =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: ++i.amount, // one higher
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit}
      />
    </Stack>
  );
};

const ExploitableInfoPage = (_properties) => {
  const { data } = useBackend<UplinkData>();
  const { exploitable = [] } = data;
  // Default to first
  const [selectedRecord, setSelectedRecord] = useState(exploitable[0]);

  const [searchText, setSearchText] = useState('');

  // Search for peeps
  const SelectMembers = (people: ExploitableRecord[], searchText = '') => {
    const MemberSearch = createSearch<ExploitableRecord>(
      searchText,
      (member: ExploitableRecord) => member?.name
    );
    return flow([
      (people: ExploitableRecord[]) =>
        // Null member filter
        filter(people, (member) => !!member?.name),
      // Optional search term
      (people: ExploitableRecord[]) =>
        searchText ? filter(people, MemberSearch) : people,
      // Slightly expensive, but way better than sorting in BYOND
      (people: ExploitableRecord[]) => sortBy(people, (member) => member?.name),
    ])(people);
  };

  const crew = SelectMembers(exploitable, searchText);

  return (
    <Section fill title="Записи об экипаже">
      <Stack fill>
        <Stack.Item width="30%">
          <Section fill scrollable>
            <Input
              fluid
              mb={1}
              placeholder="Поиск..."
              onInput={(e, value) => setSearchText(value)}
            />
            <Tabs vertical>
              {crew.map((r) => (
                <Tabs.Tab
                  key={r}
                  selected={r === selectedRecord}
                  onClick={() => setSelectedRecord(r)}
                >
                  {r?.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Stack.Item>
        <Divider vertical />
        <Stack.Item grow>
          <Section fill title={selectedRecord?.name} scrollable>
            <LabeledList>
              <LabeledList.Item label="Возраст">
                {selectedRecord.age}
              </LabeledList.Item>
              <LabeledList.Item label="Отпечаток пальцев">
                {selectedRecord.fingerprint}
              </LabeledList.Item>
              <LabeledList.Item label="Должность">
                {selectedRecord.rank}
              </LabeledList.Item>
              <LabeledList.Item label="Пол">
                {selectedRecord.sex}
              </LabeledList.Item>
              <LabeledList.Item label="Раса">
                {selectedRecord.species}
              </LabeledList.Item>
              <LabeledList.Item label="Записи">
                {selectedRecord.exploit_record}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

modalRegisterBodyOverride('become_contractor', (modal) => {
  const { data } = useBackend<UplinkData>();
  const { time_left } = data.contractor || {};
  const isAvailable = !!data?.contractor?.available;
  const isAffordable = !!data?.contractor?.affordable;
  const isAccepted = !!data?.contractor?.accepted;
  const { available_offers } = data.contractor || {};
  const isAdminForced = !!data?.contractor?.is_admin_forced;
  return (
    <Section
      height="65%"
      m="-1rem"
      pb="1rem"
      title={
        <>
          <Icon name="suitcase" />
          &nbsp; Заключение контракта
        </>
      }
    >
      <Box mx="0.8rem" mb="1rem">
        <b>
          Ваши достижения в службе Синдикату были отмечены, агент! Мы рады
          предложить вам уникальную возможность стать контрактником.
        </b>
        <br />
        <br />
        Мы предлагаем вам повышение до уровня контрактника всего за 100
        телекристаллов. Это позволит вам заключать контракты на похищение людей,
        получая за свою работу телекристаллы и кредиты.
        <br />
        Кроме того, вам будет выдан стандартный набор контрактника, специальный
        аплинк контрактника, руководство и три случайных недорогих предмета.
        <br />
        <br />
        Более подробные инструкции вы сможете найти в руководстве, которое
        прилагается к комплекту, если решите воспользоваться нашим предложением.
        {!isAdminForced ? (
          <Box>
            Не упустите возможность! Вы не единственный, кто получил это
            предложение. Количество доступных предложений ограничено, и если
            другие агенты примут их раньше вас, то у вас не останется
            возможности принять участие.
            <br />
            <b>Доступные предложения: {available_offers}</b>
          </Box>
        ) : (
          ''
        )}
      </Box>
      <Button.Confirm
        disabled={!isAvailable || isAccepted}
        italic={!isAvailable}
        bold={isAvailable}
        icon={isAvailable && !isAccepted && 'check'}
        color="good"
        position="absolute"
        right="1rem"
        bottom="-0.75rem"
        onClick={() => modalAnswer(modal.id, 1)}
      >
        {isAccepted ? (
          'Заключён'
        ) : isAvailable ? (
          [
            'Принять предложение',
            <Countdown
              key="countdown"
              timeLeft={time_left}
              format={(v, f) => ' (' + f + ')'}
            />,
          ]
        ) : !isAffordable ? (
          'Недостаточно ТК'
        ) : !data.contractor.is_admin_forced ? (
          data.contractor.available_offers > 0 ? (
            <i>[Осталось:{data.contractor.available_offers}]</i>
          ) : (
            <i>[Предложения закончились]</i>
          )
        ) : (
          'Срок действия предложения истек'
        )}
      </Button.Confirm>
    </Section>
  );
});
