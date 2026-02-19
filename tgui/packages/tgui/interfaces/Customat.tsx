import { useBackend } from '../backend';
import {
  Box,
  Button,
  Section,
  Stack,
  Table,
  DmIcon,
  Icon,
} from '../components';
import { Window } from '../layouts';

type CustomatRowProps = {
  product: Product;
};

type Product = {
  name: string;
  desc: string;
  stock: number;
  Key: string;
  price: number;
  icon: string;
  icon_state: string;
};

const CustomatRow = (props: CustomatRowProps) => {
  const { act, data } = useBackend<CustomatData>();
  const { product } = props;
  const { userMoney, vend_ready } = data;
  const free = product.price === 0;
  let buttonText = 'ERROR!';
  let rowIcon = '';
  if (free) {
    buttonText = 'БЕСПЛАТНО';
    rowIcon = 'arrow-circle-down';
  } else {
    buttonText = product.price.toString();
    rowIcon = 'shopping-cart';
  }
  let buttonDisabled =
    !vend_ready || product.stock === 0 || (!free && product.price > userMoney);
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
        <Box color={(product.stock <= 0 && 'bad') || 'good'}>
          {product.stock} в наличии
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
              'Key': product.Key,
            })
          }
        >
          {buttonText}
        </Button>
      </Table.Cell>
    </Table.Row>
  );
};

type CustomatData = {
  guestNotice: string;
  userMoney: number;
  user: User;
  products: Product[];
  panel_open: boolean;
  speaker: boolean;
  vend_ready: boolean;
};

type User = {
  name: string;
  job: string;
};

export const Customat = (props: unknown) => {
  const { act, data } = useBackend<CustomatData>();
  const { guestNotice, userMoney, user, products, panel_open, speaker } = data;

  return (
    <Window width={470} height={600} title="Кастомат">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
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
                {products.map((product) => (
                  <CustomatRow key={product.name} product={product} />
                ))}
              </Table>
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
