import { useState } from 'react';
import { useBackend } from '../backend';
import { createSearch, declension_ru } from 'common/string';
import {
  Box,
  Button,
  Section,
  Stack,
  Icon,
  Input,
  NoticeBox,
  ImageButton,
} from '../components';
import { Window } from '../layouts';
import { getLayoutState, LAYOUT, LayoutToggle } from 'common/LayoutToggle';

type VendingData = {
  all_products_free: boolean;
  onstation: boolean;
  vend_ready: boolean;
  user: UserData;
  product_records?: ProductRecord[];
  premium_records?: ProductRecord[];
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

type ProductRecord = {
  is_hidden: boolean;
  req_coin: boolean;
  price: number;
  name: string;
  desc: string;
  max_amount: number;
  ref: string;
  category: string;
  icon?: string;
  icon_state?: string;
};

type UserData = {
  name: string;
  job: string;
  cash: number;
};

type ProductDisplayProps = {
  inventory: ProductRecord[];
  stockSearch: string;
  setStockSearch: (search: string) => void;
  selectedCategory: string | null;
};

export const Vending = (_props: unknown) => {
  const { act, data } = useBackend<VendingData>();
  const {
    onstation,
    product_records = [],
    premium_records = [],
    hidden_records = [],
    categories,
    inserted_item_name,
    panel_open,
    speaker,
  } = data;

  const [selectedCategory, setSelectedCategory] = useState(
    Object.keys(categories)[0]
  );

  const [stockSearch, setStockSearch] = useState('');
  const stockSearchFn = createSearch(
    stockSearch,
    (item: ProductRecord) => item.name
  );

  let inventory: ProductRecord[];

  inventory = [...product_records, ...premium_records];
  if (data.extended_inventory) {
    inventory = [...inventory, ...hidden_records];
  }

  // Just in case we still have undefined values in the list
  inventory = inventory.filter((item) => !!item);

  if (stockSearch.length >= 1) {
    inventory = inventory.filter(stockSearchFn);
  }

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
          {!!onstation && (
            <Stack.Item>
              <UserDetails />
            </Stack.Item>
          )}
          {!!inserted_item_name && (
            <Stack.Item>
              <Button fluid icon="eject" onClick={() => act('eject_item', {})}>
                Извлечь предмет
              </Button>
              <Box>{inserted_item_name}</Box>
            </Stack.Item>
          )}
          {!!panel_open && (
            <Stack.Item>
              <Button
                icon={speaker ? 'check' : 'volume-mute'}
                selected={speaker}
                textAlign="left"
                onClick={() => act('toggle_voice', {})}
              >
                Динамик
              </Button>
            </Stack.Item>
          )}

          <Stack.Item grow>
            <ProductDisplay
              inventory={inventory}
              stockSearch={stockSearch}
              setStockSearch={setStockSearch}
              selectedCategory={selectedCategory}
            />
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
        </Stack>
      </Window.Content>
    </Window>
  );
};

/** Displays user details if an ID is present */
export const UserDetails = (props) => {
  const { data } = useBackend<VendingData>();
  const { user } = data;

  return (
    <NoticeBox m={0} color={user && 'blue'}>
      <Stack align="center">
        <Stack.Item>
          <Icon name="id-card" size={1.5} />
        </Stack.Item>
        <Stack.Item>
          {user ? `${user.name} | ${user.job}` : 'Пользователь не определён'}
        </Stack.Item>
      </Stack>
    </NoticeBox>
  );
};

/** Displays products in a section, with user balance at top */
const ProductDisplay = (props: ProductDisplayProps) => {
  const { data } = useBackend<VendingData>();
  const { inventory, stockSearch, setStockSearch, selectedCategory } = props;
  const { stock, user, all_products_free } = data;
  const [toggleLayout, setToggleLayout] = useState(() =>
    getLayoutState(LAYOUT.Grid)
  );

  return (
    <Section
      fill
      scrollable
      title="Продукция"
      buttons={
        <Stack>
          {!all_products_free && user && (
            <Stack.Item fontSize="16px" color="green">
              <b>{(user && user.cash) || 0}</b> кредит
              {declension_ru(user.cash, '', 'а', 'ов')}
            </Stack.Item>
          )}
          <Stack.Item>
            <Input
              onChange={setStockSearch}
              placeholder="Поиск..."
              value={stockSearch}
            />
          </Stack.Item>
          <LayoutToggle state={toggleLayout} setState={setToggleLayout} />
        </Stack>
      }
    >
      {inventory
        .filter((product) => {
          if (!stockSearch && 'category' in product) {
            return product.category === selectedCategory;
          } else {
            return true;
          }
        })
        .map((product) => (
          <Product
            key={product.name}
            fluid={toggleLayout === LAYOUT.List}
            product={product}
            productStock={stock[product.name]}
          />
        ))}
    </Section>
  );
};

/**
 * An individual listing for an item.
 */
const Product = (props) => {
  const { act, data } = useBackend<VendingData>();
  const { product, productStock, fluid } = props;
  const { all_products_free, user, vend_ready } = data;

  const free = all_products_free || product.price === 0;
  const remaining = productStock;
  const disabled =
    !vend_ready ||
    remaining === 0 ||
    (!all_products_free && !user) ||
    (!all_products_free && !free && product.price > (user && user.cash));

  const baseProps = {
    base64: product.image,
    dmIcon: product.icon,
    dmIconState: product.icon_state,
    disabled: disabled,
    tooltipPosition: 'bottom',
    product: product,
    remaining: remaining,
    onClick: () => {
      act('vend', {
        'ref': product.ref,
      });
    },
  };

  const priceProps = {
    product: product,
    free: free,
  };

  return fluid ? (
    <ProductList {...baseProps} {...priceProps} />
  ) : (
    <ProductGrid {...baseProps} {...priceProps} />
  );
};

const ProductGrid = (props) => {
  const { product, remaining, ...baseProps } = props;
  const { ...priceProps } = props;

  return (
    <ImageButton
      {...baseProps}
      tooltip={`${product.name}. ${product.desc}`}
      buttonsAlt={
        <Stack fontSize={0.9}>
          <Stack.Item grow textAlign={'left'}>
            <ProductPrice {...priceProps} />
          </Stack.Item>
          <Stack.Item fontSize={1} color={'lightgray'}>
            x{remaining}
          </Stack.Item>
        </Stack>
      }
    >
      {product.name}
    </ImageButton>
  );
};

const ProductList = (props) => {
  const { product, remaining, ...baseProps } = props;
  const { ...priceProps } = props;

  return (
    <ImageButton {...baseProps} tooltip={product.desc} fluid imageSize={64}>
      <Stack textAlign={'right'} fontSize={1} align="center">
        <Stack.Item grow textAlign={'left'}>
          {product.name}
        </Stack.Item>
        <Stack.Item width={10} color={'lightgray'}>
          <b>{remaining}</b> в наличии
        </Stack.Item>
        <Stack.Item width={6}>
          <ProductPrice {...priceProps} />
        </Stack.Item>
      </Stack>
    </ImageButton>
  );
};

/** The main button to purchase an item. */
const ProductPrice = (props) => {
  const { product, free } = props;

  let standardPrice = free ? '0' : product.price;

  return (
    <Stack.Item color={free ? 'green' : 'gold'}>
      <b>{standardPrice}</b> кр.
    </Stack.Item>
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
