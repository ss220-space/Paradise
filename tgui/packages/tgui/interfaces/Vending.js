import { classes } from 'common/react';
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

const VendingRow = (props, context) => {
  const { act, data } = useBackend(context);
  const { product, productStock, productIcon, productIconState } = props;
  const {
    chargesMoney,
    user,
    userMoney,
    vend_ready,
    coin_name,
    inserted_item_name,
  } = data;
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
    buttonText = product.price;
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
          icon={productIcon}
          icon_state={productIconState}
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

export const Vending = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    user,
    guestNotice,
    userMoney,
    chargesMoney,
    product_records = [],
    coin_records = [],
    hidden_records = [],
    stock,
    vend_ready,
    coin_name,
    inserted_item_name,
    panel_open,
    speaker,
    imagelist,
  } = data;
  let inventory;

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
                    content="Извлечь монету"
                    onClick={() => act('remove_coin', {})}
                  />
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
                    content="Извлечь предмет"
                    onClick={() => act('eject_item', {})}
                  />
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
                  content="Динамик"
                  textAlign="left"
                  onClick={() => act('toggle_voice', {})}
                />
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
                    productIcon={product.icon}
                    productIconState={product.icon_state}
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
