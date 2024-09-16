import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

const CustomatRow = (props, context) => {
  const { act, data } = useBackend(context);
  const { product } = props;
  const { user, userMoney, vend_ready } = data;
  const free = product.price === 0;
  let buttonText = 'ERROR!';
  let rowIcon = '';
  if (free) {
    buttonText = 'FREE';
    rowIcon = 'arrow-circle-down';
  } else {
    buttonText = product.price;
    rowIcon = 'shopping-cart';
  }
  let buttonDisabled =
    !vend_ready || product.stock === 0 || (!free && product.price > userMoney);
  return (
    <Table.Row>
      <Table.Cell collapsing>
        <img
          src={`data:image/jpeg;base64,${product.icon}`}
          style={{
            'vertical-align': 'middle',
            width: '32px',
            margin: '0px',
            'margin-left': '0px',
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
          content={buttonText}
          textAlign="left"
          onClick={() =>
            act('vend', {
              'Key': product.Key,
            })
          }
        />
      </Table.Cell>
    </Table.Row>
  );
};

export const Customat = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    guestNotice,
    userMoney,
    user,
    products,
    vend_ready,
    panel_open,
    speaker,
  } = data;

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
                  content="Speaker"
                  textAlign="left"
                  onClick={() => act('toggle_voice', {})}
                />
              </Section>
            )}
          </Stack.Item>
          <Stack.Item grow>
            <Section title="Products" fill scrollable>
              <Table>
                {products.map((product) => (
                  <CustomatRow
                    key={product.name}
                    product={product}
                    productStock={product.stock}
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
