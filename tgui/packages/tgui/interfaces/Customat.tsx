import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Table, Image } from '../components';
import { Window } from '../layouts';

type CustomatRowProps = {
  product: Product;
};

type Product = {
  name: string;
  stock: number;
  Key: string;
  price: number;
  icon: string;
};

const CustomatRow = (props: CustomatRowProps) => {
  const { act, data } = useBackend<CustomatData>();
  const { product } = props;
  const { userMoney, vend_ready } = data;
  const free = product.price === 0;
  let buttonText = 'ERROR!';
  let rowIcon = '';
  if (free) {
    buttonText = 'FREE';
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
        <Image
          src={`data:image/jpeg;base64,${product.icon}`}
          style={{
            verticalAlign: 'middle',
            width: '32px',
            margin: '0px',
            marginLeft: '0px',
          }}
        />
      </Table.Cell>
      <Table.Cell bold>{product.name}</Table.Cell>
      <Table.Cell collapsing textAlign="center">
        <Box color={(product.stock <= 0 && 'bad') || 'good'}>
          {product.stock} in stock
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
    <Window width={470} height={600} title="Customat">
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="User">
              {(user && (
                <Box>
                  Welcome, <b>{user.name}</b>, <b>{user.job || 'Unemployed'}</b>
                  !
                  <br />
                  Your balance is <b>{userMoney} credits</b>.
                </Box>
              )) || <Box color="light-grey">{guestNotice}</Box>}
            </Section>
            {!!panel_open && (
              <Section title="Maintenance">
                <Button
                  icon={speaker ? 'check' : 'volume-mute'}
                  selected={speaker}
                  textAlign="left"
                  onClick={() => act('toggle_voice', {})}
                >
                  Speaker
                </Button>
              </Section>
            )}
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Products" fill scrollable>
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
