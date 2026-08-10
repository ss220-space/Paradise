import { useBackend } from '../backend';
import { Box, Button, Icon, Image, ImageButton, Section, Stack } from '../components';
import { Window } from '../layouts';

const SLOT_ROWS = [
  [
    { name: 'Headgear', icon: 'hard-hat', slot: 'head' },
    { name: 'Glasses', icon: 'glasses', slot: 'glasses' },
    { name: 'Ears', icon: 'headphones-alt', slot: 'l_ear' },
  ],
  [
    { name: 'Neck', icon: 'stethoscope', slot: 'neck' },
    { name: 'Mask', icon: 'theater-masks', slot: 'mask' },
  ],
  [
    { name: 'Uniform', icon: 'tshirt', slot: 'uniform' },
    { name: 'Suit', icon: 'user-tie', slot: 'suit' },
    { name: 'Gloves', icon: 'mitten', slot: 'gloves' },
  ],
  [
    { name: 'Suit Storage', icon: 'briefcase-medical', slot: 'suit_store' },
    { name: 'Back', icon: 'shopping-bag', slot: 'back' },
    { name: 'ID', icon: 'id-card-o', slot: 'id' },
  ],
  [
    { name: 'Belt', icon: 'band-aid', slot: 'belt' },
    { name: 'Left Hand', icon: 'hand-paper', slot: 'l_hand' },
    { name: 'Right Hand', icon: 'hand-paper', slot: 'r_hand' },
  ],
  [
    { name: 'Shoes', icon: 'socks', slot: 'shoes' },
    { name: 'Left Pocket', icon: 'envelope-open-o', iconRot: 180, slot: 'l_pocket' },
    { name: 'Right Pocket', icon: 'envelope-open-o', iconRot: 180, slot: 'r_pocket' },
  ],
];

export const CustomOutfit = (props) => {
  const { act, data } = useBackend();
  const hasBack = !!data.outfit?.back?.path;
  const implants = data.implants || [];
  const backpackItems = data.backpack_items || [];
  const augmentations = data.augmentations || [];
  const hasMindshield = data.mindshield;
  const hasDental = data.has_dental_implant;
  const dentalList = data.dental_reagents || [];
  const dentalTooltip = hasDental
    ? dentalList.map((reagent) => `${reagent.name}: ${reagent.amount}u`).join('\n')
    : 'Добавить реагенты в зубной имплант';

  return (
    <Window title="Custom Outfit" width={900} height={625} theme="admin" fill>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={5} basis={0}>
            <Section fill scrollable title="Слоты">
              <Stack vertical>
                {SLOT_ROWS.map((row, row_index) => (
                  <Stack.Item key={row_index}>
                    <Stack>
                      {row.map((slot) => (
                        <OutfitSlot key={slot.slot} {...slot} />
                      ))}
                    </Stack>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow={4} basis={0}>
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
              <Stack fill vertical>
                <Stack.Item>
                  <Stack>
                    <Stack.Item grow basis={0}>
                      <Button
                        fluid
                        icon="pills"
                        iconColor={hasDental ? 'good' : 'gray'}
                        content="Зубной имплант"
                        tooltip={dentalTooltip}
                        onClick={() => act('dental_implant')}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item grow basis={0}>
                  <PreviewImage base64={data.preview_icon} />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow={3} basis={0}>
            <Stack fill vertical>
              <Stack.Item>
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
                      <Stack.Item key={item.zone}>
                        <Button
                          key={item.zone}
                          fluid
                          color="transparent"
                          icon="robot"
                          content={`${item.zone_name} — ${item.status_name}${item.company ? ` (${item.company})` : ''}`}
                          tooltip="Удалить аугментацию"
                          tooltipPosition="bottom-start"
                          onClick={() => act('remove_augmentation', { zone: item.zone })}
                        />
                      </Stack.Item>
                    ))}
                    <Stack.Item>
                      <Button
                        fluid
                        icon="plus"
                        content="Добавить аугментацию"
                        onClick={() => act('add_augmentation')}
                      />
                    </Stack.Item>
                  </Stack>
                </Section>
              </Stack.Item>
              <Stack.Item grow basis={0}>
                <Section fill scrollable title="Рюкзак">
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

const PreviewImage = ({ base64 }) => {
  if (!base64) {
    return (
      <Stack fill align="center" justify="center">
        <Stack.Item>
          <Box color="label">Нет данных</Box>
        </Stack.Item>
      </Stack>
    );
  }

  return (
    <Stack fill align="center" justify="center">
      <Stack.Item grow basis={0}>
        <Image
          width="100%"
          height="100%"
          src={`data:image/png;base64,${base64}`}
          style={{
            objectFit: 'contain',
            imageRendering: 'pixelated',
          }}
        />
      </Stack.Item>
    </Stack>
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
            height="48px"
            backgroundColor="rgba(0,0,0,0.3)"
            borderRadius="4px"
            onClick={() => act('click', { slot })}
          >
            <Stack fill align="center" justify="center">
              <Stack.Item>
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
              </Stack.Item>
            </Stack>
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box
            textAlign="center"
            fontSize={0.75}
            color={currItem ? 'label' : 'gray'}
            title={currItem?.name}
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
  return (
    <Stack wrap>
      {items?.map((item) => (
        <Stack.Item key={item.path} m={0.5}>
          <Box
            width="48px"
            height="48px"
            backgroundColor="rgba(0,0,0,0.3)"
            borderRadius="4px"
          >
            <Stack fill align="center" justify="center">
              <Stack.Item>
                <ImageButton
                  imageSize={48}
                  dmIcon={item.icon}
                  dmIconState={item.icon_state}
                  tooltip={item.name}
                  onClick={() => onRemove(item)}
                />
              </Stack.Item>
            </Stack>
          </Box>
        </Stack.Item>
      ))}
      <Stack.Item m={0.5}>
        <Box
          width="48px"
          height="48px"
          backgroundColor="rgba(0,0,0,0.3)"
          borderRadius="4px"
        >
          <Stack fill align="center" justify="center">
            <Stack.Item>
              <Button
                icon="plus"
                tooltip={addDisabled ? addDisabledTooltip : addTooltip}
                tooltipPosition="bottom-start"
                disabled={addDisabled}
                onClick={onAdd}
              />
            </Stack.Item>
          </Stack>
        </Box>
      </Stack.Item>
    </Stack>
  );
};
