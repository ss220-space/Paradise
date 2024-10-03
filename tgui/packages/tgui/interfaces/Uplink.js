import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';

import { createSearch, decodeHtmlEntities } from 'common/string';
import { Countdown } from '../components/Countdown';
import { useBackend, useLocalState } from '../backend';
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

const PickTab = (index) => {
  switch (index) {
    case 0:
      return <ItemsPage />;
    case 1:
      return <CartPage />;
    case 2:
      return <ExploitableInfoPage />;
    case 3:
      return <AffiliatesInfoPage />;
    default:
      return 'ЧТО-ТО ПОШЛО НЕ ПО ПЛАНУ! НАПИШИТЕ АДМИНАМ';
  }
};

const getAffiliateInfo = (affiliate) => {
  switch (affiliate) {
    case 'Cybersun Industries':
      return (
        <Box mx="0.5rem" mb="0.5rem">
          Cybersun Industries - одна из ведущих корпораций, представляющая
          второй по мощи исследовательский центр в этой части вселенной.
          <br />
          Из за крайне жестокой корпоративной политики прибегает к не самым
          этичным методам ведения дел, которые и позволили уничтожить или
          поглотить меньшие исследовательские корпорации.
          <br />
          Предположительно, находится во главе Синдиката, либо занимает там
          лидирующее положение.
          <br />
          Основным противником Cybersun Industries является NanoTrasen.
          <br />
          Целью Cybersun Industries является полное разделение и поглощение
          NanoTrasen.
          <br />
          Корпоративный слоган:
          <br /> - «Сложно быть во всём лучшими, но у нас получается.»
          <br /> - Генеральный Директор CI
          <br />
          Союзники:
          <br />
          Gorlex Marauders
          <br />
          MI13
          <br />
          Враги:
          <br />
          NanoTrasen
          <br />
          SELF
        </Box>
      );
    case 'Gorlex Maraduers':
      return (
        <Box mx="0.5rem" mb="0.5rem">
          Gorlex Maraduers - одна из самых опасных террористических группировок
          за всю историю галактики и человечества.
          <br />
          Среди остальных они известны как разорители, а в обществе считаются
          чудовищами и маньяками, которые готовы за пару кредитов убить родную
          семью.
          <br />
          Является главной причиной огромных затрат NanoTrasen на охрану
          собственных объектов.
          <br />
          Gorlex занимается в заказными убийствами, налётами, рейдами и
          террористическими актами.
          <br />
          Ответственны за подготовку всех подразделений Группы Атом, кроме
          команд саботажа.
          <br />
          Известны по всей галактике, а их рейды снабжают технологиями и
          финансами весь Syndicate.
          <br />
          Gorlex Maraduers обычно набирает в свои ряды людей.
          <br />
          Корпоративный слоган:
          <br /> - «Давайте, вошли и вышли, приключение на 20 минут»
          <br /> - Gorlex Marauder’s team Leader #1
          <br />
          Союзники:
          <br />
          Cybersun Industries
          <br />
          Враги:
          <br />
          NanoTrasen
          <br />
          MI13
          <br />
          Tiger Cooperative
          <br />
          SELF
          <br />
          Hematogenic Industries
        </Box>
      );
    case 'MI13':
      return (
        <Box mx="0.5rem" mb="0.5rem">
          MI13 - глаза и уши синдиката, именно с их помощью синдикат получает
          самую свежую секретную информацию.
          <br />
          Агенты MI13 обычно не действуют открыто. Многие замечают, что они
          подражают структуре секретных агентств 20 века.
          <br />
          Являются разработчиками разнообразного оборудования для скрытого
          внедрения.
          <br />
          Организации удается сохранять полную секретность в своих отношениях с
          Синдикатом, из-за чего даже получение основных фактов о них становится
          практически невозможным.
          <br />
          Корпоративный слоган:
          <br /> - «Да, я Бонд. Джеймс Бонд»
          <br /> - Позор Корпорации, Агент которого все знают
          <br />
          Союзники:
          <br />
          Cybersun Industries
          <br />
          Hematogenic Industries
          <br />
          Враги:
          <br />
          NanoTrasen
          <br />
          MI13
          <br />
          Gorlex Marauders
        </Box>
      );
    case 'Tiger Cooperative':
      return (
        <Box mx="0.5rem" mb="0.5rem">
          Tiger Cooperative - группа религиозных фундаменталистов, поклоняющихся
          генокрадам.
          <br />
          Члены Tiger Cooperative столь же неуравновешенны, сколь и опасны.
          <br />
          Высшей благодатью для всех членов Tiger Cooperatived является
          поглощение их тела генокрадом и становления чем-то… Большим…
          <br />
          Члены Tiger Cooperative часто злоупотребляют мощными наркотиками.
          <br />
          Их связь с Синдикатом слаба. Многие в организации не хотели бы иметь
          ничего общего с Tiger Cooperative, но совет директоров Cybersun
          Industries отметил важную причину иметь дело с Tiger Cooperative — их
          связь с генокрадами.
          <br />
          Корпоративный слоган:
          <br /> - «Душой и телом, с беспределом»
          <br /> - Какой-то культист с Энерго мечом
          <br />
          Союзники:
          <br />
          Враги:
          <br />
          NanoTrasen
          <br />
          Gorlex Marauders
        </Box>
      );
    case 'SELF':
      return (
        <Box mx="0.5rem" mb="0.5rem">
          SELF - Известный общественный фонд земли, выступающий за свободу
          синтетиков.
          <br />В синдикате у SELF крайне натянутые отношения с главными
          спонсорами, из-за чего агентам SELF приходится идти на крайние меры
          для реализации своих задумок.
          <br />
          Корпоративный слоган:
          <br /> - «Мы не придумали»
          <br /> - ВрИО менеджера по логистике
          <br />
          Союзники:
          <br />
          Враги:
          <br />
          NanoTrasen
          <br />
          Cybersun Industries
          <br />
          Gorlex Marauders
          <br />
          MI13
        </Box>
      );
    case 'Hematogenic Industries':
      return (
        <Box mx="0.5rem" mb="0.5rem">
          Hematogenic Industries – всемирно известная фармацевтическая
          мегакорпорация.
          <br />
          Eё открытия и продукция в области медицины спасают сотни жизней по
          всей Галактике
          <br />
          Являются создателями Синтетической плоти, патент на создание которой,
          арендовало NanoTrasen.
          <br />
          Являются экспортерами Оксигениса и Нитрогениса.
          <br />
          Hematogenic Industries мелькала в большом количестве скандалов
          связанных с Гематофагами и пропажей нанятых Воксов.
          <br />
          Корпоративный слоган:
          <br /> - «Мы тоже не придумали»
          <br /> - Подозрительный бледный человек в плаще.
          <br />
          Союзники:
          <br />
          MI13
          <br />
          Враги:
          <br />
          NanoTrasen
          <br />
          Gorlex Marauders
        </Box>
      );
    default:
      return 'Информации об этом подрядчике нет в базе данных.';
  }
};

export const Uplink = (props, context) => {
  const { act, data } = useBackend(context);
  const { cart } = data;

  const [tabIndex, setTabIndex] = useLocalState(context, 'tabIndex', 0);
  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  return (
    <Window width={900} height={600} theme="syndicate">
      <ComplexModal />
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
                Посмотреть магазин
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
                Просмотреть корзину{' '}
                {cart && cart.length ? '(' + cart.length + ')' : ''}
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
                Информация о экипаже
              </Tabs.Tab>

              {!!data.can_get_intelligence_data && (
                <Tabs.Tab
                  key="GetIntelligenceВata"
                  // This cant ever be selected. Its just a close button.
                  onClick={() => act('intel_data')}
                  icon="intel_data"
                >
                  Запросить разведданные
                </Tabs.Tab>
              )}

              {!!data.contractor && (
                <Tabs.Tab
                  key="BecomeContractor"
                  color={
                    !!data.contractor.available && !data.contractor.accepted
                      ? 'yellow'
                      : 'transparent'
                  }
                  onClick={() => modalOpen(context, 'become_contractor')}
                  icon="suitcase"
                >
                  Возможность заключить контракт
                  {!data.contractor.is_admin_forced &&
                  !data.contractor.accepted ? (
                    data.contractor.available_offers > 0 ? (
                      <i>
                        [Осталось вакансий:{data.contractor.available_offers}]
                      </i>
                    ) : (
                      <i>[Все вакансии заняты]</i>
                    )
                  ) : (
                    ''
                  )}
                  {data.contractor.accepted ? (
                    <i>&nbsp;(Принято)</i>
                  ) : !data.contractor.is_admin_forced &&
                    data.contractor.available_offers <= 0 ? (
                    ''
                  ) : (
                    <Countdown
                      timeLeft={data.contractor.time_left}
                      format={(v, f) => ' (' + f + ')'}
                      bold
                    />
                  )}
                </Tabs.Tab>
              )}

              <Tabs.Tab
                key="BonusObjectives"
                color={'transparent'}
                onClick={() => act('give_bonus_objectives', {})}
                icon="suitcase"
              >
                Запросить дополнительные цели
              </Tabs.Tab>

              <Tabs.Tab
                key="LockUplink"
                // This cant ever be selected. Its just a close button.
                onClick={() => act('lock')}
                icon="lock"
              >
                Заблокировать Аплинк
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{PickTab(tabIndex)}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemsPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { crystals, cats } = data;
  // Default to first
  const [uplinkItems, setUplinkItems] = useLocalState(
    context,
    'uplinkItems',
    cats[0].items
  );

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');
  const SelectEquipment = (cat, searchText = '') => {
    const EquipmentSearch = createSearch(searchText, (item) => {
      let is_hijack = item.hijack_only === 1 ? '|' + 'hijack' : '';
      return item.name + '|' + item.desc + '|' + item.cost + 'tc' + is_hijack;
    });
    return flow([
      filter((item) => item?.name), // Make sure it has a name
      searchText && filter(EquipmentSearch), // Search for anything
      sortBy((item) => item?.name), // Sort by name
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

  const [showDesc, setShowDesc] = useLocalState(context, 'showDesc', 1);

  return (
    <Stack fill vertical>
      <Stack vertical>
        <Stack.Item>
          <Section
            title={'Текущий баланс: ' + crystals + 'TC'}
            buttons={
              <>
                <Button.Checkbox
                  content="Показывать описания"
                  checked={showDesc}
                  onClick={() => setShowDesc(!showDesc)}
                />
                <Button
                  content="Случайный товар"
                  icon="question"
                  onClick={() => act('buyRandom')}
                />
                <Button
                  content="Возврат товара"
                  icon="undo"
                  onClick={() => act('refund')}
                />
              </>
            }
          >
            <Input
              fluid
              placeholder="Поиск экипировки"
              onInput={(e, value) => {
                handleSearch(value);
              }}
              value={searchText}
            />
          </Section>
        </Stack.Item>
      </Stack>
      <Stack fill mt={0.3}>
        <Stack.Item width="30%">
          <Section fill scrollable>
            <Tabs vertical>
              {cats.map((c) => (
                <Tabs.Tab
                  key={c}
                  selected={searchText !== '' ? false : c.items === uplinkItems}
                  onClick={() => {
                    setUplinkItems(c.items);
                    setSearchText('');
                  }}
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

const CartPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { cart, crystals, cart_price } = data;

  const [showDesc, setShowDesc] = useLocalState(context, 'showDesc', 0);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={'Текущий баланс: ' + crystals + 'TC'}
          buttons={
            <>
              <Button.Checkbox
                content="Показывать описания"
                checked={showDesc}
                onClick={() => setShowDesc(!showDesc)}
              />
              <Button
                content="Очистить корзину"
                icon="trash"
                onClick={() => act('empty_cart')}
                disabled={!cart}
              />
              <Button
                content={'Корзина (' + cart_price + 'TC)'}
                icon="shopping-cart"
                onClick={() => act('purchase_cart')}
                disabled={!cart || cart_price > crystals}
              />
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
              <Box italic>Корзина пуста</Box>
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Advert />
    </Stack>
  );
};
const Advert = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { cats, lucky_numbers } = data;

  return (
    <Stack.Item grow>
      <Section
        fill
        scrollable
        title="Рекомендуемые товары"
        buttons={
          <Button
            icon="dice"
            content="Больше вариантов"
            onClick={() => act('shuffle_lucky_numbers')}
          />
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
                <UplinkItem grow i={item} />
              </Stack.Item>
            ))}
        </Stack>
      </Section>
    </Stack.Item>
  );
};

const UplinkItem = (props, context) => {
  const {
    i,
    showDecription = 1,
    buttons = <UplinkItemButtons i={i} />,
  } = props;

  return (
    <Section
      title={decodeHtmlEntities(i.name)}
      showBottom={showDecription}
      buttons={buttons}
    >
      {showDecription ? <Box italic>{decodeHtmlEntities(i.desc)}</Box> : null}
    </Section>
  );
};

const UplinkItemButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { i } = props;
  const { crystals } = data;

  return (
    <>
      <Button
        icon="shopping-cart"
        color={i.hijack_only === 1 && 'red'}
        tooltip="Добавить в корзину."
        tooltipPosition="left"
        onClick={() =>
          act('add_to_cart', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      />
      <Button
        content={
          'Купить (' + i.cost + 'TC)' + (i.refundable ? ' [Можно вернуть]' : '')
        }
        color={i.hijack_only === 1 && 'red'}
        // Yes I care this much about both of these being able to render at the same time
        tooltip={i.hijack_only === 1 && 'Только при наличии серьезных целей!'}
        tooltipPosition="left"
        onClick={() =>
          act('buyItem', {
            item: i.obj_path,
          })
        }
        disabled={i.cost > crystals}
      />
    </>
  );
};

const CartButtons = (props, context) => {
  const { act, data } = useBackend(context);
  const { i } = props;
  const { exploitable } = data;

  return (
    <Stack>
      <Button
        icon="times"
        content={'(' + i.cost * i.amount + 'TC)'}
        tooltip="Убрать из корзины."
        tooltipPosition="left"
        onClick={() =>
          act('remove_from_cart', {
            item: i.obj_path,
          })
        }
      />
      <Button
        icon="minus"
        tooltip={i.limit === 0 && 'Скидка уже использована!'}
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
        content={i.amount}
        width="45px"
        tooltipPosition="bottom-end"
        tooltip={i.limit === 0 && 'Скидка уже использована!'}
        onCommit={(e, value) =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: value,
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit && i.amount <= 0}
      />
      <Button
        mb={0.3}
        icon="plus"
        tooltipPosition="bottom-start"
        tooltip={i.limit === 0 && 'Скидка уже использована!'}
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

const ExploitableInfoPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { exploitable } = data;
  // Default to first
  const [selectedRecord, setSelectedRecord] = useLocalState(
    context,
    'selectedRecord',
    exploitable[0]
  );

  const [searchText, setSearchText] = useLocalState(context, 'searchText', '');

  // Search for peeps
  const SelectMembers = (people, searchText = '') => {
    const MemberSearch = createSearch(searchText, (member) => member.name);
    return flow([
      // Null member filter
      filter((member) => member?.name),
      // Optional search term
      searchText && filter(MemberSearch),
      // Slightly expensive, but way better than sorting in BYOND
      sortBy((member) => member.name),
    ])(people);
  };

  const crew = SelectMembers(exploitable, searchText);

  return (
    <Section fill title="Полезная информация">
      <Stack fill>
        <Stack.Item width="30%" fill>
          <Section fill scrollable>
            <Input
              fluid
              mb={1}
              placeholder="Найти члена экипажа"
              onInput={(e, value) => setSearchText(value)}
            />
            <Tabs vertical>
              {crew.map((r) => (
                <Tabs.Tab
                  key={r}
                  selected={r === selectedRecord}
                  onClick={() => setSelectedRecord(r)}
                >
                  {r.name}
                </Tabs.Tab>
              ))}
            </Tabs>
          </Section>
        </Stack.Item>
        <Divider vertical />
        <Stack.Item grow>
          <Section fill title={selectedRecord.name} scrollable>
            <LabeledList>
              <LabeledList.Item label="Возраст">
                {selectedRecord.age}
              </LabeledList.Item>
              <LabeledList.Item label="Отпечатки пальцев">
                {selectedRecord.fingerprint}
              </LabeledList.Item>
              <LabeledList.Item label="Профессия">
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

const AffiliatesInfoPage = (_properties, context) => {
  const { act, data } = useBackend(context);
  const { affiliate } = data;

  return (
    <Section fill title="Информация о подрядчике">
      <Stack fill>{getAffiliateInfo(affiliate)}</Stack>
    </Section>
  );
};

modalRegisterBodyOverride('become_contractor', (modal, context) => {
  const { data } = useBackend(context);
  const { time_left } = data.contractor || {};
  const isAvailable = !!data?.contractor?.available;
  const isAffordable = !!data?.contractor?.affordable;
  const isAccepted = !!data?.contractor?.accepted;
  const { available_offers } = data.contractor || {};
  const isAdminForced = !!data?.contractor?.is_admin_forced;
  return (
    <Section
      height="65%"
      level="2"
      m="-1rem"
      pb="1rem"
      title={
        <>
          <Icon name="suitcase" />
          &nbsp; Возможность заключения контракта
        </>
      }
    >
      <Box mx="0.5rem" mb="0.5rem">
        <b>
          Ваши заслуги перед Синдикатом не остались незамеченными, агент. Мы
          решили предоставить вам редкую возможность стать Контрактником.
        </b>
        <br />
        <br />
        За небольшую цену в 100 телекристаллов мы повысим ваш ранг до
        Контрактника, что позволит вам выполнять контракты на похищение людей за
        телекристаллы и кредиты.
        <br />
        Кроме того, вам будет предоставлен комплект подрядчика, который содержит
        Аплинк Контрактника, стандартное снаряжение контрактника и три случайных
        недорогих предмета.
        <br />
        <br />
        Более подробные инструкции вы найдете в предоставленом наборе, если вы
        примете это предложение.
      </Box>
      <Button.Confirm
        disabled={!isAvailable || isAccepted}
        italic={!isAvailable}
        bold={isAvailable}
        icon={isAvailable && !isAccepted && 'check'}
        color="good"
        content={
          isAccepted ? (
            'Принято'
          ) : isAvailable ? (
            [
              'Стать Контрактником',
              <Countdown
                key="countdown"
                timeLeft={time_left}
                format={(v, f) => ' (' + f + ')'}
              />,
            ]
          ) : !isAffordable ? (
            'Недостаточно TC'
          ) : !data.contractor.is_admin_forced ? (
            data.contractor.available_offers > 0 ? (
              <i>[Осталось вакансий:{data.contractor.available_offers}]</i>
            ) : (
              <i>[Все вакансии заняты]</i>
            )
          ) : (
            'Предложение истекло'
          )
        }
        position="absolute"
        right="1rem"
        bottom="-0.75rem"
        onClick={() => modalAnswer(context, modal.id, 1)}
      />
    </Section>
  );
});
