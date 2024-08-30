import { classes } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, Section, Stack, Table } from '../components';
import { Window } from '../layouts';

const CustomatRow = (props, context) => {
  const { act, data } = useBackend(context);
  const { product, productStock, productImage } = props;
  const {
    user,
    userMoney,
    vend_ready,
  } = data;
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
              'key': product.key,
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
    products = [],
    user,
    stock,
    icons,
    vend_ready,
    panel_open,
    speaker,
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
                  <CustomatRow
                    key={product.key}
                    product={product}
                    productStock={stock[product.key]}
                    productImage={icons[product.key]}
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
