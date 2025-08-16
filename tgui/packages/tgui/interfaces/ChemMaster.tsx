import { Component, ReactNode, MouseEvent } from 'react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Slider,
  Tabs,
  Image,
} from '../components';
import { Window } from '../layouts';
import { BeakerContents } from './common/BeakerContents';
import {
  ComplexModal,
  modalOpen,
  modalRegisterBodyOverride,
  ModalType,
} from './common/ComplexModal';
import { BooleanLike, classes } from 'common/react';
import { BoxProps } from '../components/Box';
import { computeBoxProps } from 'common/ui';

const transferAmounts = [1, 5, 10];

type ChemicalModalData = {
  beaker: string;
  analysis: Analysis;
};

type Analysis = {
  blood_type: string;
  blood_dna: string;
  idx: string;
  name: string;
  desc: string;
};

const analyzeModalBodyOverride = (
  modal: ModalType<ChemicalModalData>
): ReactNode => {
  const { act, data } = useBackend<ChemMasterData>();
  const result = modal.args.analysis;
  return (
    <Stack.Item>
      <Section title={data.condi ? 'Анализ вещества' : 'Анализ реагента'}>
        <Box mx="0.5rem">
          <LabeledList>
            <LabeledList.Item label="Название">{result.name}</LabeledList.Item>
            <LabeledList.Item label="Описание">
              {(result.desc || '').length > 0 ? result.desc : 'Н/Д'}
            </LabeledList.Item>
            {result.blood_type && (
              <>
                <LabeledList.Item label="Группа крови">
                  {result.blood_type}
                </LabeledList.Item>
                <LabeledList.Item
                  label="ДНК-код"
                  className="LabeledList__breakContents"
                >
                  {result.blood_dna}
                </LabeledList.Item>
              </>
            )}
            {!data.condi && (
              <Button
                icon={data.printing ? 'spinner' : 'print'}
                disabled={data.printing}
                iconSpin={!!data.printing}
                ml="0.5rem"
                onClick={() =>
                  act('print', {
                    idx: result.idx,
                    beaker: modal.args.beaker,
                  })
                }
              >
                Печать
              </Button>
            )}
          </LabeledList>
        </Box>
      </Section>
    </Stack.Item>
  );
};

interface ProductionItemSprite {
  id: number;
  sprite: string;
}

interface StaticProductionData {
  name: string;
  icon: string;
  max_items_amount: number;
  max_units_per_item: number;
  sprites?: ProductionItemSprite[];
}

interface NonStaticProductionData {
  set_name?: string;
  set_items_amount: number;
  set_sprite?: number;
  placeholder_name?: string;
}

type ProductionData = StaticProductionData &
  NonStaticProductionData & { id: string };

enum TransferMode {
  ToDisposals = 0,
  ToBeaker = 1,
}

type ReagentData = {
  description: string;
} & Chemical;

interface ContainerStyle {
  color: string;
  name: string;
}

interface ChemMasterData {
  // ui_static
  maxnamelength: number;
  static_production_data: Record<string, StaticProductionData>;
  containerstyles: ContainerStyle[];

  condi: BooleanLike;
  loaded_pill_bottle: BooleanLike;
  loaded_pill_bottle_style?: string;
  beaker: BooleanLike;
  beaker_reagents: ReagentData[];
  buffer_reagents: ReagentData[];
  mode: TransferMode;
  printing: BooleanLike;
  modal?: unknown;
  production_mode: string;
  production_data: Record<string, NonStaticProductionData>;
}

export const ChemMaster = (props: unknown) => {
  return (
    <Window width={575} height={650}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <ChemMasterBeaker />
          <ChemMasterBuffer />
          <ChemMasterProduction />
          <ChemMasterCustomization />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ChemMasterBeaker = (props: {}) => {
  const { act, data } = useBackend<ChemMasterData>();
  const { beaker, beaker_reagents, buffer_reagents } = data;
  const bufferNonEmpty = buffer_reagents.length > 0;
  return (
    <Stack.Item grow>
      <Section
        title="Ёмкость"
        fill
        scrollable
        buttons={
          bufferNonEmpty ? (
            <Button.Confirm icon="eject" onClick={() => act('eject')}>
              Извлечь ёмкость и очистить буфер
            </Button.Confirm>
          ) : (
            <Button
              icon="eject"
              disabled={!beaker}
              onClick={() => act('eject')}
            >
              Извлечь ёмкость и очистить буфер
            </Button>
          )
        }
      >
        {beaker ? (
          <BeakerContents
            beakerLoaded
            beakerContents={beaker_reagents}
            buttons={(chemical, i) => (
              <Box mb={i < beaker_reagents.length - 1 && '2px'}>
                <Button
                  mb="0"
                  onClick={() =>
                    modalOpen('analyze', {
                      idx: i + 1,
                      beaker: 1,
                    })
                  }
                >
                  Анализ
                </Button>
                {transferAmounts.map((am, j) => (
                  <Button
                    key={j}
                    mb="0"
                    onClick={() =>
                      act('add', {
                        id: chemical.id,
                        amount: am,
                      })
                    }
                  >
                    {am}
                  </Button>
                ))}
                <Button
                  mb="0"
                  onClick={() =>
                    act('add', {
                      id: chemical.id,
                      amount: chemical.volume,
                    })
                  }
                >
                  Всё
                </Button>
                <Button
                  mb="0"
                  onClick={() =>
                    modalOpen('addcustom', {
                      id: chemical.id,
                    })
                  }
                >
                  Задать объём...
                </Button>
              </Box>
            )}
          />
        ) : (
          <Box color="label">Ёмкость отсутствует.</Box>
        )}
      </Section>
    </Stack.Item>
  );
};

const ChemMasterBuffer = (props: {}) => {
  const { act, data } = useBackend<ChemMasterData>();
  const { mode, buffer_reagents } = data;
  return (
    <Stack.Item grow>
      <Section
        title="Буфер"
        fill
        scrollable
        buttons={
          <Box color="label">
            Перенести в&nbsp;
            <Button
              icon={mode ? 'flask' : 'trash'}
              color={!mode && 'bad'}
              onClick={() => act('toggle')}
            >
              {mode ? 'Ёмкость' : 'Слив'}
            </Button>
          </Box>
        }
      >
        {buffer_reagents.length > 0 ? (
          <BeakerContents
            beakerLoaded
            beakerContents={buffer_reagents}
            buttons={(chemical, i) => (
              <Box mb={i < buffer_reagents.length - 1 && '2px'}>
                <Button
                  mb="0"
                  onClick={() =>
                    modalOpen('analyze', {
                      idx: i + 1,
                      beaker: 0,
                    })
                  }
                >
                  Анализ
                </Button>
                {transferAmounts.map((am, i) => (
                  <Button
                    key={i}
                    mb="0"
                    onClick={() =>
                      act('remove', {
                        id: chemical.id,
                        amount: am,
                      })
                    }
                  >
                    {am}
                  </Button>
                ))}
                <Button
                  mb="0"
                  onClick={() =>
                    act('remove', {
                      id: chemical.id,
                      amount: chemical.volume,
                    })
                  }
                >
                  Всё
                </Button>
                <Button
                  mb="0"
                  onClick={() =>
                    modalOpen('removecustom', {
                      id: chemical.id,
                    })
                  }
                >
                  Задать объём...
                </Button>
              </Box>
            )}
          />
        ) : (
          <Box color="label">Буфер пуст.</Box>
        )}
      </Section>
    </Stack.Item>
  );
};

const ChemMasterProduction = (props: {}) => {
  const { data } = useBackend<ChemMasterData>();
  const { buffer_reagents } = data;
  if (buffer_reagents.length === 0) {
    return (
      <Stack.Item>
        <Section title="Продукция">
          <Stack fill>
            <Stack.Item grow align="center" textAlign="center" color="label">
              <Icon name="tint-slash" mb="0.5rem" size={5} />
              <br />
              Буфер пуст.
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    );
  }

  return (
    <Stack.Item>
      <Section fill title="Продукция">
        <ChemMasterProductionTabs />
      </Section>
    </Stack.Item>
  );
};

const ChemMasterProductionTabs = (props: {}) => {
  const { act, data } = useBackend<ChemMasterData>();
  const { production_mode, production_data, static_production_data } = data;
  const decideTab = (mode: ChemMasterData['production_mode']) => {
    let static_data = static_production_data[mode];
    let nonstatic_data = production_data[mode];
    if (static_data !== undefined && nonstatic_data !== undefined) {
      const productionData = {
        ...static_data,
        ...nonstatic_data,
        id: mode,
      };
      return <ChemMasterProductionGeneric productionData={productionData} />;
    }

    return 'UNKNOWN INTERFACE';
  };
  return (
    <>
      <Tabs>
        {Object.entries(static_production_data).map(([id, { name, icon }]) => {
          return (
            <Tabs.Tab
              key={name}
              icon={icon}
              selected={production_mode === id}
              onClick={() =>
                act('set_production_mode', { production_mode: id })
              }
            >
              {name}
            </Tabs.Tab>
          );
        })}
      </Tabs>
      {decideTab(production_mode)}
    </>
  );
};

type ChemMasterNameInputProps = {
  placeholder: string;
  fluid: boolean;
  value: string;
  onMouseUp?: (MouseEvent) => void;
  onChange?: (e, value) => void;
} & BoxProps;

class ChemMasterNameInput extends Component<
  ChemMasterNameInputProps & BoxProps
> {
  constructor(props: ChemMasterNameInputProps) {
    super(props);
  }

  handleMouseUp = (e: MouseEvent<HTMLDivElement>) => {
    const { placeholder, onMouseUp } = this.props;
    const target = e.target as HTMLInputElement;

    // Middle-click button
    if (e.button === 1) {
      target.value = placeholder;
      target.select();
    }

    if (onMouseUp) {
      onMouseUp(e);
    }
  };

  render() {
    const { data } = useBackend<ChemMasterData>();
    const { maxnamelength } = data;

    return (
      <Input
        maxLength={maxnamelength}
        onMouseUp={this.handleMouseUp}
        {...computeBoxProps(this.props)}
      />
    );
  }
}

const ChemMasterProductionCommon = (props: {
  children: ReactNode | ReactNode[];
  productionData: ProductionData;
}) => {
  const { act, data } = useBackend<ChemMasterData>();
  const { children, productionData } = props;
  const { buffer_reagents = [] } = data;
  const { id, max_items_amount, set_name, set_items_amount, placeholder_name } =
    productionData;
  return (
    <LabeledList>
      {children}
      <LabeledList.Item label="Объём">
        <Slider
          value={set_items_amount}
          minValue={1}
          maxValue={max_items_amount}
          stepPixelSize={20}
          onChange={(e, value) =>
            act(`set_items_amount`, {
              production_mode: id,
              amount: value,
            })
          }
        />
      </LabeledList.Item>
      {set_name !== undefined && set_name !== null && (
        <LabeledList.Item label="Название">
          <ChemMasterNameInput
            fluid
            value={set_name}
            placeholder={placeholder_name}
            onChange={(e, value) =>
              act(`set_items_name`, {
                production_mode: id,
                name: value,
              })
            }
          />
        </LabeledList.Item>
      )}
      <LabeledList.Item>
        <Button
          fluid
          color="green"
          disabled={buffer_reagents.length <= 0}
          onClick={() => act(`create_items`, { production_mode: id })}
        >
          Создать
        </Button>
      </LabeledList.Item>
    </LabeledList>
  );
};

const SpriteStyleButton = (
  props: { icon: string; selected: boolean } & BoxProps
) => {
  const { icon, ...restProps } = props;
  return (
    <Button style={{ padding: '0', lineHeight: '0' }} {...restProps}>
      <Image fixBlur className={classes(['chem_master_large32x32', icon])} />
    </Button>
  );
};

const ChemMasterProductionGeneric = (props: {
  productionData: ProductionData;
}) => {
  const { act } = useBackend<ChemMasterData>();
  const { id: modeId, set_sprite, sprites } = props.productionData;
  let style_buttons: ReactNode;
  if (sprites && sprites.length > 0) {
    style_buttons = sprites.map(({ id, sprite }) => (
      <SpriteStyleButton
        key={id}
        icon={sprite}
        color="translucent"
        onClick={() =>
          act('set_sprite_style', { production_mode: modeId, style: id })
        }
        selected={set_sprite === id}
      />
    ));
  }
  return (
    <ChemMasterProductionCommon productionData={props.productionData}>
      {style_buttons && (
        <LabeledList.Item label="Тип">{style_buttons}</LabeledList.Item>
      )}
    </ChemMasterProductionCommon>
  );
};

const ChemMasterCustomization = (props: {}) => {
  const { act, data } = useBackend<ChemMasterData>();
  const { loaded_pill_bottle_style, containerstyles, loaded_pill_bottle } =
    data;

  const style_button_size = { width: '20px', height: '20px' };
  const style_buttons = containerstyles.map(({ color, name }) => {
    let selected = loaded_pill_bottle_style === color;
    return (
      <Button
        key={color}
        style={{
          position: 'relative',
          width: style_button_size.width,
          height: style_button_size.height,
        }}
        onClick={() => act('set_container_style', { style: color })}
        icon={selected && 'check'}
        iconStyle={{
          position: 'relative',
          zIndex: '1',
        }}
        tooltip={name}
        tooltipPosition="top"
      >
        {/* Required. Removing this causes non-selected elements to flow up */}
        {!selected && <div style={{ display: 'inline-block' }} />}
        <span
          className="Button"
          style={{
            display: 'inline-block',
            position: 'absolute',
            top: 0,
            left: 0,
            margin: 0,
            padding: 0,
            width: style_button_size.width,
            height: style_button_size.height,
            backgroundColor: color,
            opacity: 0.6,
            filter: 'alpha(opacity=60)',
          }}
        />
      </Button>
    );
  });
  return (
    <Stack.Item>
      <Section
        fill
        title="Кастомизация контейнера"
        buttons={
          <Button
            icon="eject"
            disabled={!loaded_pill_bottle}
            onClick={() => act('ejectp')}
          >
            Извлечь контейнер
          </Button>
        }
      >
        {!loaded_pill_bottle ? (
          <Box color="label">Контейнер отсутствует.</Box>
        ) : (
          <LabeledList>
            <LabeledList.Item label="Стиль">
              <Button
                style={{
                  width: style_button_size.width,
                  height: style_button_size.height,
                }}
                icon="tint-slash"
                onClick={() => act('clear_container_style')}
                selected={!loaded_pill_bottle_style}
                tooltip="По умолчанию"
                tooltipPosition="top"
              />
              {style_buttons}
            </LabeledList.Item>
          </LabeledList>
        )}
      </Section>
    </Stack.Item>
  );
};

modalRegisterBodyOverride('analyze', analyzeModalBodyOverride);
