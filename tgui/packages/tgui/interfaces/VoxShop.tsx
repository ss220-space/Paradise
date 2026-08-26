import { useState } from 'react';
import { Box, Button, Section, Stack, Tabs } from 'tgui/components';
import { decodeHtmlEntities } from 'common/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { ComplexModal } from './common/ComplexModal';

const PickTab = (index) => {
  switch (index) {
    case 0:
      return <ItemsPage />;
    case 1:
      return <CartPage />;
    default:
      return 'ОШИБКА, СООБЩИТЕ РАЗРАБОТЧИКУ';
  }
};

type VoxShopData = {
  cart: Item[];
  cash: number;
  cart_price: number;
  cats: Category[];
};

type Item = {
  name: string;
};

type Category = {
  items: Item[];
  cat: string;
};

export const VoxShop = (_props: never) => {
  const { data } = useBackend<VoxShopData>();
  const { cart } = data;

  const [tabIndex, setTabIndex] = useState(0);

  return (
    <Window width={900} height={600} theme="abductor">
      <ComplexModal />
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                key="PurchasePage"
                selected={tabIndex === 0}
                onClick={() => {
                  setTabIndex(0);
                }}
                icon="store"
              >
                Торговля
              </Tabs.Tab>
              <Tabs.Tab
                key="Cart"
                selected={tabIndex === 1}
                onClick={() => {
                  setTabIndex(1);
                }}
                icon="shopping-cart"
              >
                Корзина {cart && cart.length ? '(' + cart.length + ')' : ''}
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>{PickTab(tabIndex)}</Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ItemsPage = () => {
  const { data } = useBackend<VoxShopData>();
  const { cash, cats } = data;

  // Default to first
  const [shopItems, setShopItems] = useState(cats[0].items);
  const [showDesc, setShowDesc] = useState(true);

  return (
    <Stack fill vertical>
      <Stack vertical>
        <Stack.Item>
          <Section
            title={'Средства: ' + cash + 'к'}
            buttons={
              <Button.Checkbox
                checked={showDesc}
                onClick={() => setShowDesc(!showDesc)}
              >
                Подробности
              </Button.Checkbox>
            }
          />
        </Stack.Item>
      </Stack>
      <Stack fill mt={0.3}>
        <Stack.Item width="30%">
          <Section fill scrollable>
            <Tabs vertical>
              {cats.map((c, index) => (
                <Tabs.Tab
                  key={index}
                  selected={c.items === shopItems}
                  onClick={() => {
                    setShopItems(c.items);
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
              {shopItems.map((i) => (
                <Stack.Item
                  key={decodeHtmlEntities(i.name)}
                  p={1}
                  backgroundColor={'rgba(255, 0, 0, 0.1)'}
                >
                  <ShopItem
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

const CartPage = () => {
  const { act, data } = useBackend<VoxShopData>();
  const { cart, cash, cart_price } = data;

  const [showDesc, setShowDesc] = useState(false);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={'Средства: ' + cash + 'к'}
          buttons={
            <>
              <Button.Checkbox
                checked={showDesc}
                onClick={() => setShowDesc(!showDesc)}
              >
                Подробности
              </Button.Checkbox>
              <Button
                icon="trash"
                onClick={() => act('empty_cart')}
                disabled={!cart}
              >
                Очистить
              </Button>
              <Button
                icon="shopping-cart"
                onClick={() => act('purchase_cart')}
                disabled={!cart || cart_price > cash}
              >
                {'Оплатить (' + cart_price + 'к)'}
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
                  <ShopItem
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
    </Stack>
  );
};

const ShopItem = (props) => {
  const { i, showDecription = 1, buttons = <ShopItemButtons i={i} /> } = props;

  return (
    <Section title={decodeHtmlEntities(i.name)} buttons={buttons}>
      {showDecription ? <Box italic>{decodeHtmlEntities(i.desc)}</Box> : null}
      {showDecription ? (
        <Box italic>{decodeHtmlEntities(i.content)}</Box>
      ) : null}
    </Section>
  );
};

const ShopItemButtons = (props) => {
  const { act, data } = useBackend<VoxShopData>();
  const { i } = props;
  const { cash } = data;

  return (
    <Button
      icon="shopping-cart"
      color={i.limit !== -1 && 'red'}
      tooltip="Добавить товар в корзину, увеличив общее число данного товара. Цена товара меняется в зависимости от полученных ценностей в Расчичетчикике."
      tooltipPosition="left"
      onClick={() =>
        act('add_to_cart', {
          item: i.obj_path,
        })
      }
      disabled={
        i.cost > cash ||
        (i.limit !== -1 && i.purchased >= i.limit) ||
        i.is_time_available === false
      }
    >
      {'Добавить в корзину (' + i.cost + ' Кикиридитов)'}
    </Button>
  );
};

const CartButtons = (props) => {
  const { act } = useBackend();
  const { i } = props;

  return (
    <Stack>
      <Button
        icon="times"
        tooltip="Убрать из корзины."
        tooltipPosition="left"
        onClick={() =>
          act('remove_from_cart', {
            item: i.obj_path,
          })
        }
      >
        {'(' + i.cost * i.amount + 'к)'}
      </Button>
      <Button
        icon="minus"
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
        tooltip={i.limit === 0 && 'Discount already redeemed!'}
        onClick={() =>
          act('set_cart_item_quantity', {
            item: i.obj_path,
            quantity: ++i.amount,
          })
        }
        disabled={i.limit !== -1 && i.amount >= i.limit}
      />
    </Stack>
  );
};
