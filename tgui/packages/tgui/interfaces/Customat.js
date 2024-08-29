import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

const VendingRow = (props, context) => {
  const { act, data } = useBackend(context);
  const { product, productStock, productImage } = props;
  const {
    chargesMoney,
    user,
    userMoney,
    vend_ready,
    inserted_item_name,
  } = data;
  const free = !chargesMoney || product.price === 0;
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
    !vend_ready ||
    productStock === 0 ||
    (!free && product.price > userMoney);
  return (
    <Table.Row>
      <Table.Cell collapsing>
        <img
          src={`data:image/jpeg;base64,${productImage}`}
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
        <Box
          color={
            (productStock <= 0 && 'bad') ||
            'good'
          }
        >
          {productStock} in stock
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
              'inum': product.inum,
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
    user,
    guestNotice,
    userMoney,
    chargesMoney,
    products = [],
    stock,
    vend_ready,
    inserted_item_name,
    panel_open,
    speaker,
    imagelist,
  } = data;
  let inventory;

  inventory = [...products];
  // Just in case we still have undefined values in the list
  inventory = inventory.filter((item) => !!item);
  return (
    <Window
      width={470}
      height={100 + Math.min(products.length * 38, 500)}
      title="Customat"
    >
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            {!!chargesMoney && (
              <Section title="User">
                {(user && (
                  <Box>
                    Welcome, <b>{user.name}</b>,{' '}
                    <b>{user.job || 'Unemployed'}</b>
                    !
                    <br />
                    Your balance is <b>{userMoney} credits</b>.
                  </Box>
                )) || <Box color="light-grey">{guestNotice}</Box>}
              </Section>
            )}
            {!!inserted_item_name && (
              <Section
                title="Item"
                buttons={
                  <Button
                    fluid
                    icon="eject"
                    content="Eject Item"
                    onClick={() => act('eject_item', {})}
                  />
                }
              >
                <Box>{inserted_item_name}</Box>
              </Section>
            )}
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
                {inventory.map((product) => (
                  <VendingRow
                    key={product.name}
                    product={product}
                    productStock={stock[product.name]}
                    productImage={imagelist[product.key]}
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
