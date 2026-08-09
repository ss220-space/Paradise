import { useBackend } from '../backend';
import { Box, Button, ImageButton, Icon, Section, Stack } from '../components';
import { Window } from '../layouts';

export const CustomOutfit = (props) => {
  const { act, data } = useBackend();
  const hasBack = !!data.outfit?.back?.path;
  const implants = data.implants || [];
  const backpackItems = data.backpack_items || [];
  const augmentations = data.augmentations || [];
  const hasMindshield = data.mindshield;

  return (
    <Window title="Custom Outfit" width={900} height={625} theme="admin" fill>
      <Window.Content>
        <Stack>
          <Stack.Item grow>
            <Section fill title="Слоты" width={30}>
              <Stack vertical>
                <Stack.Item>
                  <Stack>
                    <OutfitSlot name="Headgear" icon="hard-hat" slot="head" />
                    <OutfitSlot name="Glasses" icon="glasses" slot="glasses" />
                    <OutfitSlot name="Ears" icon="headphones-alt" slot="l_ear" />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <OutfitSlot name="Neck" icon="stethoscope" slot="neck" />
                    <OutfitSlot name="Mask" icon="theater-masks" slot="mask" />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <OutfitSlot name="Uniform" icon="tshirt" slot="uniform" />
                    <OutfitSlot name="Suit" icon="user-tie" slot="suit" />
                    <OutfitSlot name="Gloves" icon="mitten" slot="gloves" />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <OutfitSlot
                      name="Suit Storage"
                      icon="briefcase-medical"
                      slot="suit_store"
                    />
                    <OutfitSlot name="Back" icon="shopping-bag" slot="back" />
                    <OutfitSlot name="ID" icon="id-card-o" slot="id" />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <OutfitSlot name="Belt" icon="band-aid" slot="belt" />
                    <OutfitSlot name="Left Hand" icon="hand-paper" slot="l_hand" />
                    <OutfitSlot name="Right Hand" icon="hand-paper" slot="r_hand" />
                  </Stack>
                </Stack.Item>
                <Stack.Item>
                  <Stack>
                    <OutfitSlot name="Shoes" icon="socks" slot="shoes" />
                    <OutfitSlot
                      name="Left Pocket"
                      icon="envelope-open-o"
                      iconRot={180}
                      slot="l_pocket"
                    />
                    <OutfitSlot
                      name="Right Pocket"
                      icon="envelope-open-o"
                      iconRot={180}
                      slot="r_pocket"
                    />
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item width={30}>
            <Section
              fill
              title="Результат"
              buttons={
                <>
                  <Button
                    icon="file-upload"
                    tooltip="Загрузить из файла"
                    tooltipPosition="left"
                    onClick={() => act('load')}
                  />
                  <Button
                    icon="copy"
                    tooltip="Скопировать из списка"
                    tooltipPosition="left"
                    onClick={() => act('copy')}
                  />
                  <Button
                    icon="plus"
                    tooltip="Сохранить в файл"
                    tooltipPosition="left"
                    onClick={() => act('save')}
                  />
                  <Button
                    icon="check"
                    color="good"
                    tooltip="Применить снаряжение на персонажа"
                    tooltipPosition="left"
                    onClick={() => act('apply')}
                  />
                </>
              }
            >
              <Box
                fill
                textAlign="center"
                color="label"
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                }}
              >
                <Stack fill vertical>
                  <Stack.Item>
                    <Stack fill>
                      <Stack.Item grow>
                        <Button
                          fluid
                          icon="shield"
                          iconColor={hasMindshield ? 'good' : 'gray'}
                          color={hasMindshield ? 'transparent' : 'transparent'}
                          content="Mindshield"
                          tooltip={hasMindshield ? 'Удалить имплант защиты разума' : 'Добавить имплант защиты разума'}
                          onClick={() => act('toggle_mindshield')}
                        />
                      </Stack.Item>
                      <Stack.Item grow>
                        <Button
                          fluid
                          icon="flask"
                          content="Chem implant"
                          tooltip="Скоро"
                          onClick={() => act('chem_implant')}
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                  <Stack.Item grow>
                    <Box>Здесь будет персонаж</Box>
                  </Stack.Item>
                </Stack>
              </Box>
            </Section>
          </Stack.Item>

          <Stack.Item width={20}>
            <Stack fill vertical>
              <Stack.Item grow>
                <Section title="Импланты">
                  <ItemGrid
                    items={implants}
                    onAdd={() => act('add_implant')}
                    onRemove={(item) => act('remove_implant', { ref: item.path })}
                    addTooltip="Добавить имплант"
                  />
                </Section>
                <Section title="Аугментации">
                  <Stack vertical>
                    {augmentations?.map((item) => (
                      <Button
                        key={item.zone}
                        fluid
                        color="transparent"
                        icon="robot"
                        content={`${item.zone_name} — ${item.company}`}
                        tooltip="Удалить аугментацию"
                        tooltipPosition="bottom-start"
                        onClick={() => act('remove_augmentation', { zone: item.zone })}
                      />
                    ))}
                    <Button
                      fluid
                      icon="plus"
                      content="Добавить аугментацию"
                      onClick={() => act('add_augmentation')}
                    />
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow>
                <Section fill title="Рюкзак">
                  <ItemGrid
                    items={backpackItems}
                    onAdd={() => act('add_backpack_item')}
                    onRemove={(item) => act('remove_item', { ref: item.path })}
                    addTooltip="Добавить предмет"
                    addDisabled={!hasBack}
                    addDisabledTooltip="Добавьте рюкзак"
                  />
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const OutfitSlot = ({ name, icon, iconRot, slot }) => {
  const { act, data } = useBackend();
  const currItem = data.outfit?.[slot];
  return (
    <Stack.Item grow basis={0}>
      <Stack vertical>
        <Stack.Item>
          <Box textAlign="center" fontSize={0.8} color="label" opacity={0.8}>
            <Icon name={icon} rotation={iconRot} mr={0.5} />
            {name}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box
            width="100%"
            height="48px"
            textAlign="center"
            style={{
              backgroundColor: 'rgba(0,0,0,0.3)',
              borderRadius: '4px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
            onClick={(e) => act('click', { slot })}
          >
            {currItem?.icon ? (
              <ImageButton
                imageSize={48}
                dmIcon={currItem.icon}
                dmIconState={currItem.icon_state}
                title={currItem.desc}
                onClick={() => act('clear', { slot })}
              />
            ) : (
              <Icon name={icon} rotation={iconRot} size={1.5} color="gray" />
            )}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box
            textAlign="center"
            fontSize={0.75}
            color={currItem ? 'label' : 'gray'}
            style={{
              overflow: 'hidden',
              whiteSpace: 'nowrap',
              textOverflow: 'ellipsis',
            }}
            title={currItem?.path}
          >
            {currItem?.name || '—'}
          </Box>
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
};

const ItemGrid = ({
  items,
  onAdd,
  onRemove,
  addTooltip,
  addDisabled,
  addDisabledTooltip,
}) => {
  const { act } = useBackend();
  return (
    <Stack wrap>
      {items?.map((item) => (
        <Stack.Item key={item.path} m={0.5}>
          <ImageButton
            width="48px"
            height="48px"
            imageSize={48}
            dmIcon={item.icon}
            dmIconState={item.icon_state}
            tooltip={item.name}
            style={{
              backgroundColor: 'rgba(0,0,0,0.3)',
              borderRadius: '4px',
            }}
            onClick={() => onRemove(item)}
          />
        </Stack.Item>
      ))}
      <Stack.Item m={0.5}>
        <Button
          width="48px"
          height="48px"
          icon="plus"
          tooltip={addDisabled ? addDisabledTooltip : addTooltip}
          tooltipPosition="bottom-start"
          disabled={addDisabled}
          style={{
            backgroundColor: 'rgba(0,0,0,0.3)',
            borderRadius: '4px',
            display: 'grid',
            placeItems: 'center',
            lineHeight: '48px',
          }}
          onClick={onAdd}
        />
      </Stack.Item>
    </Stack>
  );
};
