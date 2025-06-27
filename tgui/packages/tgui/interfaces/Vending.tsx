import { useBackend } from '../backend';
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

type VendingRowProps = {
  product: Product;
  productStock: number;
};

type Product = {
  req_coin: boolean;
  price: number;
  name: string;
  max_amount: number;
  inum: string;
  icon: string;
  icon_state: string;
};

const VendingRow = (props: VendingRowProps) => {
  const { act, data } = useBackend<VendingData>();
  const { product, productStock } = props;
  const { chargesMoney, userMoney, vend_ready, coin_name } = data;
  const free = !chargesMoney || product.price === 0;
  let buttonText = 'ОШИБКА';
  let rowIcon = '';
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
  let buttonDisabled =
    !vend_ready ||
    (!coin_name && product.req_coin) ||
    productStock === 0 ||
    (!free && product.price > userMoney);
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
      <Table.Cell bold>{product.name}</Table.Cell>
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
              'inum': product.inum,
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
  product_records?: Product[];
  coin_records?: Product[];
  hidden_records?: Product[];
  extended_inventory: boolean;
  stock: Record<string, number>;
  inserted_item_name: string;
  panel_open: boolean;
  speaker: boolean;
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
    coin_name,
    inserted_item_name,
    panel_open,
    speaker,
  } = data;
  let inventory: Product[];

  inventory = [...product_records, ...coin_records];
  if (data.extended_inventory) {
    inventory = [...inventory, ...hidden_records];
  }
  // Just in case we still have undefined values in the list
  inventory = inventory.filter((item) => !!item);
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
          <Stack.Item grow>
            <Section title="Продукция" fill scrollable>
              <Table>
                {inventory.map((product) => (
                  <VendingRow
                    key={product.name}
                    product={product}
                    productStock={stock[product.name]}
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
