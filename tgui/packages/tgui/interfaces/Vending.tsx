import { useState } from 'react';
import { useBackend } from '../backend';
import { capitalizeAll, createSearch } from 'common/string';
import {
  Box,
  DmIcon,
  Button,
  Section,
  Stack,
  Table,
  Icon,
} from '../components';
import { Window } from '../layouts';

type ProductRecord = {
  is_hidden: boolean;
  req_coin: boolean;
  price: number;
  name: string;
  desc: string;
  max_amount: number;
  ref: string;
  category: string;
  icon: string;
  icon_state: string;
};

type VendingRowProps = {
  product: ProductRecord;
  productStock: number;
  inventory: ProductRecord[];
  stockSearch: string;
  setStockSearch: (search: string) => void;
  selectedCategory: string | null;
  setSelectedCategory: (category: string) => void;
};

/** Displays products in a section */
const VendingRow = (props: VendingRowProps) => {
  const { act, data } = useBackend<VendingData>();
  const {
    product,
    inventory,
    productStock,
    stockSearch,
    setStockSearch,
    selectedCategory,
    setSelectedCategory,
  } = props;
  const { chargesMoney, userMoney, vend_ready, coin_name } = data;
  const free = !chargesMoney || product.price === 0;

  let buttonText = 'ОШИБКА';
  let rowIcon = '';

  let buttonDisabled =
    !vend_ready ||
    (!coin_name && product.req_coin) ||
    productStock === 0 ||
    (!free && product.price > userMoney);

  if (product.req_coin) {
    buttonText = 'МОНЕТА';
    rowIcon = 'circle';
  } else if (free) {
    buttonText = 'БЕСПЛАТНО';
    rowIcon = 'arrow-circle-down';
  } else {
    buttonText = product.price.toString();
    rowIcon = 'shopping-cart';
  }

  return (
    <Table.Row>
      <Table.Cell collapsing>
        <DmIcon
          verticalAlign="middle"
          icon={product.icon}
          icon_state={product.icon_state}
          fallback={<Icon p={0.66} name={'spinner'} size={2} spin />}
        />
      </Table.Cell>
      <Table.Cell bold>
        <Button multiLine color="translucent" tooltip={product.desc}>
          {product.name}
        </Button>
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Box
          color={
            (productStock <= 0 && 'bad') ||
            (productStock <= product.max_amount / 2 && 'average') ||
            'good'
          }
        >
          {productStock} в наличии
        </Box>
      </Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Button
          fluid
          disabled={buttonDisabled}
          icon={rowIcon}
          textAlign="left"
          onClick={() =>
            act('vend', {
              'ref': product.ref,
            })
          }
        >
          {buttonText}
        </Button>
      </Table.Cell>
    </Table.Row>
  );
};

type VendingData = {
  chargesMoney: number;
  userMoney: number;
  vend_ready: boolean;
  coin_name: string;
  user: User;
  guestNotice: string;
  product_records?: ProductRecord[];
  coin_records?: ProductRecord[];
  hidden_records?: ProductRecord[];
  extended_inventory: boolean;
  stock: Record<string, number>;
  categories: Record<string, Category>;
  inserted_item_name: string;
  panel_open: boolean;
  speaker: boolean;
};

type Category = {
  icon: string;
};

type User = {
  name: string;
  job: string;
};

export const Vending = (_props: unknown) => {
  const { act, data } = useBackend<VendingData>();
  const {
    user,
    guestNotice,
    userMoney,
    chargesMoney,
    product_records = [],
    coin_records = [],
    hidden_records = [],
    stock,
    categories,
    coin_name,
    inserted_item_name,
    panel_open,
    speaker,
  } = data;

  const [stockSearch, setStockSearch] = useState('');
  const stockSearchFn = createSearch(
    stockSearch,
    (item: ProductRecord) => item.name
  );

  const [selectedCategory, setSelectedCategory] = useState(
    Object.keys(categories)[0]
  );

  let inventory: ProductRecord[];

  inventory = [...product_records, ...coin_records];
  if (data.extended_inventory) {
    inventory = [...inventory, ...hidden_records];
  }

  if (stockSearch.length >= 2) {
    inventory = inventory.filter(stockSearchFn);
  }

  // Just in case we still have undefined values in the list
  inventory = inventory.filter((item) => !!item);

  const filteredCategories = Object.fromEntries(
    Object.entries(data.categories).filter(([categoryName]) => {
      return inventory.find((product) => {
        if ('category' in product) {
          return product.category === categoryName;
        } else {
          return false;
        }
      });
    })
  );

  return (
    <Window
      width={470}
      height={100 + Math.min(product_records.length * 38, 500)}
    >
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            {!!chargesMoney && (
              <Section title="Пользователь">
                {(user && (
                  <Box>
                    Здраствуйте, <b>{user.name}</b>,{' '}
                    <b>{user.job || 'Безработный'}</b>
                    !
                    <br />
                    Ваш баланс: <b>{userMoney} кр.</b>
                  </Box>
                )) || <Box color="light-grey">{guestNotice}</Box>}
              </Section>
            )}
            {!!coin_name && (
              <Section
                title="Монета"
                buttons={
                  <Button
                    fluid
                    icon="eject"
                    onClick={() => act('remove_coin', {})}
                  >
                    Извлечь монету
                  </Button>
                }
              >
                <Box>{coin_name}</Box>
              </Section>
            )}
            {!!inserted_item_name && (
              <Section
                title="Предмет"
                buttons={
                  <Button
                    fluid
                    icon="eject"
                    onClick={() => act('eject_item', {})}
                  >
                    Извлечь предмет
                  </Button>
                }
              >
                <Box>{inserted_item_name}</Box>
              </Section>
            )}
            {!!panel_open && (
              <Section title="Тех. обслуживание">
                <Button
                  icon={speaker ? 'check' : 'volume-mute'}
                  selected={speaker}
                  textAlign="left"
                  onClick={() => act('toggle_voice', {})}
                >
                  Динамик
                </Button>
              </Section>
            )}
          </Stack.Item>

          {stockSearch.length < 2 &&
            Object.keys(filteredCategories).length > 1 && (
              <Stack.Item>
                <CategorySelector
                  categories={filteredCategories}
                  selectedCategory={selectedCategory!}
                  onSelect={setSelectedCategory}
                />
              </Stack.Item>
            )}

          <Stack.Item grow>
            <Section title="Продукция" fill scrollable>
              <Table>
                {inventory
                  .filter((product) => {
                    if (!stockSearch && 'category' in product) {
                      return product.category === selectedCategory;
                    } else {
                      return true;
                    }
                  })
                  .map((product) => (
                    <VendingRow
                      key={product.name}
                      product={product}
                      inventory={inventory}
                      productStock={stock[product.name]}
                      stockSearch={stockSearch}
                      setStockSearch={setStockSearch}
                      selectedCategory={selectedCategory}
                      setSelectedCategory={setSelectedCategory}
                    />
                  ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const CATEGORY_COLORS = {
  Контрабанда: 'red',
  Премиум: 'yellow',
};

const CategorySelector = (props: {
  categories: Record<string, Category>;
  selectedCategory: string;
  onSelect: (category: string) => void;
}) => {
  const { categories, selectedCategory, onSelect } = props;

  return (
    <Section>
      {Object.entries(categories).map(([name, category]) => (
        <Button
          key={name}
          selected={name === selectedCategory}
          color={CATEGORY_COLORS[name]}
          icon={category.icon}
          onClick={() => onSelect(name)}
        >
          {name}
        </Button>
      ))}
    </Section>
  );
};
