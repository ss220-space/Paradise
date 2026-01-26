import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  Flex,
  NumberInput,
  Section,
  Icon,
  Divider,
} from '../components';
import { Window } from '../layouts';
import { FlexProps } from '../components/Flex';
import { ReactNode } from 'react';
import { ButtonProps, ConfirmProps } from '../components/Button';
import { BoxProps } from '../components/Box';

type MultitoolData = {
  multitoolMenuId: string;
  buffer: boolean;
  bufferName: string;
  bufferTag: string;
  canBufferHaveTag: boolean;
  isAttachedAlreadyInBuffer: boolean;
  attachedName: string;
  attachedTag: string;
  attachedTags: string[];
  inputTag: string;
  outputTag: string;
  bufferFitsInput: boolean;
  bufferFitsOutput: boolean;
  doNotLinkAndNotify: boolean;
  sensors: Record<string, string>;
};

export const Multitool = (_props: unknown) => {
  const { act, data } = useBackend<MultitoolData>();
  const {
    multitoolMenuId,
    buffer,
    bufferName,
    bufferTag,
    canBufferHaveTag,
    isAttachedAlreadyInBuffer,
    attachedName,
  } = data;

  const addableToBuffer = !(multitoolMenuId === 'default_no_machine');

  const decideTabConfigurationMenu = (menuID: string) => {
    switch (menuID) {
      case 'default_no_machine':
        return <DefaultMtoolMenu />;
      case 'no_options':
        return <DefaultMtoolMenu />;
      case 'access_denied':
        return <AccessDeniedMtoolMenu />;
      case 'tag_only':
        return <TagMtoolMenu />;
      case 'multiple_tags':
        return <MultipleTagsMtoolMenu />;
      case 'frequency_and_tag':
        return (
          <>
            <FrequencyMtoolMenu />
            <TagMtoolMenu />
          </>
        );
      case 'air_sensor':
        return (
          <>
            <FrequencyMtoolMenu />
            <TagMtoolMenu />
            <AirSensorMtoolMenu />
          </>
        );
      case 'general_air_control':
        return (
          <>
            <FrequencyMtoolMenu />
            <AirControlMtoolMenu />
          </>
        );
      case 'large_tank_control':
        return (
          <>
            <FrequencyMtoolMenu />
            <TankControlMtoolMenu />
            <AirControlMtoolMenu />
          </>
        );
      default:
        return "WE SHOULDN'T BE HERE!";
    }
  };

  return (
    <Window width={510} height={420}>
      <Window.Content>
        <Flex direction="column" height="100%">
          <Flex.Item
            style={{
              overflowX: 'hidden',
              overflowY: 'auto',
            }}
            grow={1}
            shrink={1}
            basis={0}
          >
            <Section title="Configuration menu" py={0.3}>
              <MachineName
                iconName="tools"
                machineName={attachedName}
                noMachine={multitoolMenuId === 'default_no_machine'}
                noMachineText="No machine attached"
              />
              {decideTabConfigurationMenu(multitoolMenuId)}
            </Section>
          </Flex.Item>
          <Flex.Item grow={0} shrink={0}>
            <Divider />
          </Flex.Item>
          <Flex.Item grow={0} shrink={0}>
            <Section
              title="Multitool buffer"
              mb={0.9}
              py={0.3}
              buttons={
                <>
                  <Button
                    icon="save"
                    disabled={!addableToBuffer || isAttachedAlreadyInBuffer}
                    onClick={() => act('buffer_add')}
                  >
                    {isAttachedAlreadyInBuffer ? 'Added' : 'Add machine'}
                  </Button>
                  <Button
                    mr={1}
                    icon="times-circle"
                    color="red"
                    disabled={!buffer}
                    onClick={() => act('buffer_flush')}
                  >
                    Flush
                  </Button>
                </>
              }
            >
              <MachineName
                iconName="tools"
                machineName={bufferName}
                noMachine={!buffer}
                noMachineElem={<BoxNoData text={'<empty>'} />}
              />
              {!!buffer && (
                <LabeledListOneItem
                  mt={1.1}
                  label="ID tag"
                  compactLabel
                  wrapContent={
                    canBufferHaveTag ? (
                      <TextOrDefault
                        text={bufferTag}
                        defaultText={'<none>'}
                        color="silver"
                      />
                    ) : (
                      <Box
                        as="span"
                        fontSize="0.9rem"
                        color="red"
                        italic
                        nowrap
                      >
                        Not supported
                      </Box>
                    )
                  }
                />
              )}
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};

type MachineNameProps = {
  iconName: string;
  machineName: string;
  noMachine: boolean;
  noMachineText?: string;
  noMachineElem?: ReactNode;
};

const MachineName = (props: MachineNameProps) => {
  const { iconName, machineName, noMachine, noMachineText, noMachineElem } =
    props;

  const defaultName = 'Unknown machine';

  const nameDisplayed = noMachine
    ? noMachineText
    : machineName
      ? machineName
      : 'Unknown machine';

  const nameColorDifference = nameDisplayed === noMachineText;
  const nameFontDifference =
    nameDisplayed === noMachineText || nameDisplayed === defaultName;

  return noMachine && noMachineElem ? (
    noMachineElem
  ) : (
    <Flex mt={0.1} mb={1.9}>
      {!noMachine && (
        <Flex.Item grow={0} shrink={0} align="center">
          <Icon mr={1} size={1.1} name={iconName} />
        </Flex.Item>
      )}
      <Flex.Item grow={1} shrink={1} basis={0} wordWrap="break-word">
        <Box
          as="span"
          color={nameColorDifference ? 'label' : 'silver'}
          fontSize="1.1rem"
          bold
          italic={nameFontDifference}
          style={{
            wordWrap: 'break-word',
          }}
        >
          {nameDisplayed}
        </Box>
      </Flex.Item>
    </Flex>
  );
};

type BoxNoDataProps = {
  text: string;
};

const BoxNoData = (props: BoxNoDataProps) => {
  const { text } = props;
  return (
    <Box as="span" fontSize="0.9rem" color="yellow" italic nowrap>
      {text}
    </Box>
  );
};
type TextOrDefaultProps = {
  text: string;
  defaultText: string;
} & BoxProps;

const TextOrDefault = (props: TextOrDefaultProps) => {
  const { text, defaultText, ...rest } = props;
  return text ? (
    <Box as="span" style={{ wordWrap: 'break-word' }} {...rest}>
      {text}
    </Box>
  ) : (
    <BoxNoData text={defaultText} />
  );
};

type ConfirmOrNormalButtonProps = {
  noConfirm?: boolean;
} & (ButtonProps | ConfirmProps);

const ConfirmOrNormalButton = (props: ConfirmOrNormalButtonProps) => {
  const { noConfirm = false, ...rest } = props;
  return noConfirm ? <Button {...rest} /> : <Button.Confirm {...rest} />;
};

type LabeledListOneItemProps = Partial<{
  label: ReactNode;
  wrapContent: ReactNode;
  noWrapContent: ReactNode;
  compactLabel: boolean;
}> &
  FlexProps;

const LabeledListOneItem = (props: LabeledListOneItemProps) => {
  const {
    label,
    wrapContent,
    noWrapContent,
    compactLabel = false,
    ...rest
  } = props;
  return (
    <Flex my={0.5} mr="0.5%" spacing={1} align="center" {...rest}>
      <Flex.Item
        grow={compactLabel ? 0 : 1}
        shrink={0}
        textOverflow="ellipsis"
        overflow="hidden"
        basis={compactLabel ? 'auto' : 0}
        maxWidth={compactLabel ? 'none' : 20}
        color="label"
        nowrap
      >
        {label}
      </Flex.Item>
      <Flex.Item
        grow={1}
        shrink={1}
        basis={0}
        textAlign="center"
        wordWrap="break-word"
      >
        {wrapContent}
      </Flex.Item>
      <Flex.Item grow={0.1} />
      <Flex.Item grow={0} shrink={0} nowrap>
        {noWrapContent}
      </Flex.Item>
    </Flex>
  );
};

const DefaultMtoolMenu = (_props: unknown) => {
  return (
    <Box mt={1.5} fontSize="0.9rem" color="silver" italic>
      No options
    </Box>
  );
};

const AccessDeniedMtoolMenu = (_props: unknown) => {
  return (
    <Box fontSize="1.1rem" color="red" bold italic>
      ACCESS DENIED
    </Box>
  );
};

const TagMtoolMenu = (_props: unknown) => {
  const { act, data } = useBackend<MultitoolData>();
  const { attachedTag } = data;
  return (
    <LabeledListOneItem
      label="ID tag"
      wrapContent={
        <TextOrDefault
          text={attachedTag}
          defaultText={'<none>'}
          color="silver"
        />
      }
      noWrapContent={
        <>
          <Button icon="wrench" onClick={() => act('set_tag')}>
            Set
          </Button>
          <Button
            icon="times-circle"
            color="red"
            disabled={!attachedTag}
            onClick={() => act('clear_tag')}
          >
            Clear
          </Button>
        </>
      }
    />
  );
};

type MultitoolFreq = { canReset: boolean } & Frequency;

const FrequencyMtoolMenu = (_props: unknown) => {
  const { act, data } = useBackend<MultitoolFreq>();
  const { frequency, minFrequency, maxFrequency, canReset } = data;
  return (
    <LabeledListOneItem
      label="Frequency"
      noWrapContent={
        <>
          <NumberInput
            animated
            unit="kHz"
            step={0.1}
            stepPixelSize={10}
            minValue={minFrequency / 10}
            maxValue={maxFrequency / 10}
            value={frequency / 10}
            format={(value) => toFixed(value, 1)}
            onChange={(value) =>
              act('set_frequency', {
                frequency: value * 10,
              })
            }
          />
          <Button
            icon="undo"
            disabled={!canReset}
            tooltip="Reset"
            onClick={() => act('reset_frequency')}
          />
        </>
      }
    />
  );
};

const MultipleTagsMtoolMenu = (_props: unknown) => {
  const { act, data } = useBackend<MultitoolData>();
  const { attachedTags } = data;
  return (
    <Section
      mt={1.7}
      ml={0.5}
      mr={1}
      px={0.5}
      title="Linked tags"
      buttons={
        <Button
          mr={1}
          pl={2.1}
          icon="plus"
          iconPosition="right"
          onClick={() => act('add_tag')}
        >
          Add tag
        </Button>
      }
    >
      {attachedTags.map((tag, index) => (
        <LabeledListOneItem
          mr={0}
          key={index}
          label={<Icon name="wave-square" />}
          compactLabel
          wrapContent={
            <Flex align="center" spacing={1}>
              <Flex.Item
                grow={1}
                shrink={1}
                basis={0}
                color="silver"
                wordWrap="break-word"
              >
                {tag}
              </Flex.Item>
            </Flex>
          }
          noWrapContent={
            <Flex>
              <Flex.Item grow={0} shrink={0}>
                <Button
                  icon="minus"
                  color="red"
                  onClick={() =>
                    act('remove_tag', {
                      tag_index: index,
                    })
                  }
                />
              </Flex.Item>
            </Flex>
          }
        />
      ))}
    </Section>
  );
};
type AirSensorData = {
  bolts: boolean;
  pressureCheck: boolean;
  temperatureCheck: boolean;
  oxygenCheck: boolean;
  toxinsCheck: boolean;
  nitrogenCheck: boolean;
  carbonDioxideCheck: boolean;
};

const AirSensorMtoolMenu = (_props: unknown) => {
  const { act, data } = useBackend<AirSensorData>();
  const {
    bolts,
    pressureCheck,
    temperatureCheck,
    oxygenCheck,
    toxinsCheck,
    nitrogenCheck,
    carbonDioxideCheck,
  } = data;

  const checkButtons = [
    { bitflag: 1, checked: pressureCheck, label: 'Monitor pressure' },
    { bitflag: 2, checked: temperatureCheck, label: 'Monitor temperature' },
    { bitflag: 4, checked: oxygenCheck, label: 'Monitor oxygen concentration' },
    { bitflag: 8, checked: toxinsCheck, label: 'Monitor plasma concentration' },
    {
      bitflag: 16,
      checked: nitrogenCheck,
      label: 'Monitor nitrogen concentration',
    },
    {
      bitflag: 32,
      checked: carbonDioxideCheck,
      label: 'Monitor carbon dioxide concentration',
    },
  ];

  return (
    <>
      <LabeledListOneItem
        label="Floor bolts"
        noWrapContent={
          <Button
            icon={bolts ? 'check' : 'times'}
            selected={bolts}
            onClick={() => act('toggle_bolts')}
          >
            {bolts ? 'YES' : 'NO'}
          </Button>
        }
      />
      {checkButtons.map((currentButton) => (
        <LabeledListOneItem
          key={currentButton.bitflag}
          label={currentButton.label}
          noWrapContent={
            <Button.Checkbox
              checked={currentButton.checked}
              onClick={() =>
                act('toggle_flag', {
                  bitflag: currentButton.bitflag,
                })
              }
            />
          }
        />
      ))}
    </>
  );
};

const AirControlMtoolMenu = (_props: unknown) => {
  const { act, data } = useBackend<MultitoolData>();
  const { sensors } = data;

  return (
    <Section
      mt={1.7}
      ml={0.5}
      mr={1}
      px={0.5}
      title="Sensors"
      buttons={
        <Button
          mr={1}
          pl={2.1}
          icon="plus"
          iconPosition="right"
          onClick={() => act('add_sensor')}
        >
          Add sensor
        </Button>
      }
    >
      <LabeledListOneItem
        mr={0}
        compactLabel
        wrapContent={
          <Flex>
            <Flex.Item width={1} />
            <Flex.Item grow={1} shrink={1} basis={0} color="label" nowrap bold>
              ID tag
            </Flex.Item>
            <Flex.Item grow={1} shrink={1} basis={0} color="label" nowrap bold>
              Label
            </Flex.Item>
            <Flex.Item width={11.3} />
          </Flex>
        }
      />
      {Object.keys(sensors).map((sensorTag) => (
        <LabeledListOneItem
          mr={0}
          key={sensorTag}
          label={<Icon name="wave-square" />}
          compactLabel
          wrapContent={
            <Flex align="center" spacing={1}>
              <Flex.Item
                grow={1}
                shrink={1}
                basis={0}
                color="silver"
                wordWrap="break-word"
              >
                {sensorTag}
              </Flex.Item>
              {sensors[sensorTag] ? (
                <Flex.Item
                  grow={1}
                  shrink={1}
                  basis={0}
                  color="silver"
                  wordWrap="break-word"
                >
                  {sensors[sensorTag]}
                </Flex.Item>
              ) : (
                <Flex.Item
                  grow={1}
                  shrink={1}
                  basis={0}
                  fontSize="0.9rem"
                  color="yellow"
                  italic
                  nowrap
                >
                  {'<no label>'}
                </Flex.Item>
              )}
            </Flex>
          }
          noWrapContent={
            <Flex>
              <Flex.Item grow={0} shrink={0}>
                <Button
                  icon="edit"
                  onClick={() =>
                    act('change_label', {
                      sensor_tag: sensorTag,
                    })
                  }
                >
                  Label
                </Button>
                <Button
                  icon="times-circle"
                  color="orange"
                  disabled={!sensors[sensorTag]}
                  onClick={() =>
                    act('clear_label', {
                      sensor_tag: sensorTag,
                    })
                  }
                >
                  Label
                </Button>
              </Flex.Item>
              <Flex.Item width={0.5} />
              <Flex.Item grow={0} shrink={0}>
                <Button
                  px={1.2}
                  icon="minus"
                  color="red"
                  onClick={() =>
                    act('del_sensor', {
                      sensor_tag: sensorTag,
                    })
                  }
                />
              </Flex.Item>
            </Flex>
          }
        />
      ))}
    </Section>
  );
};

const TankControlMtoolMenu = (_props: unknown) => {
  const { act, data } = useBackend<MultitoolData>();
  const {
    inputTag,
    outputTag,
    bufferTag,
    bufferFitsInput,
    bufferFitsOutput,
    doNotLinkAndNotify,
  } = data;
  return (
    <>
      <LabeledListOneItem
        label="Input"
        wrapContent={
          <TextOrDefault
            text={inputTag}
            defaultText={'<none>'}
            color="silver"
          />
        }
        noWrapContent={
          <>
            <ConfirmOrNormalButton
              noConfirm={doNotLinkAndNotify || !inputTag}
              confirmContent="This will change the intput device. Confirm?"
              confirmColor="orange"
              content="Link buffer"
              icon="link"
              selected={inputTag && bufferTag === inputTag}
              disabled={!bufferFitsInput}
              onClick={() => act('link_input')}
            />
            <Button.Confirm
              confirmContent="This will unlink the intput device. Confirm?"
              confirmColor="orange"
              icon="unlink"
              color="red"
              disabled={!inputTag}
              onClick={() => act('unlink_input')}
            >
              Unlink
            </Button.Confirm>
          </>
        }
      />
      <LabeledListOneItem
        label="Output"
        wrapContent={
          <TextOrDefault
            text={outputTag}
            defaultText={'<none>'}
            color="silver"
          />
        }
        noWrapContent={
          <>
            <ConfirmOrNormalButton
              noConfirm={doNotLinkAndNotify || !outputTag}
              confirmContent="This will change the output device. Confirm?"
              confirmColor="orange"
              content="Link buffer"
              icon="link"
              selected={outputTag && bufferTag === outputTag}
              disabled={!bufferFitsOutput}
              onClick={() => act('link_output')}
            />
            <Button.Confirm
              confirmContent="This will unlink the output device. Confirm?"
              confirmColor="orange"
              icon="unlink"
              color="red"
              disabled={!outputTag}
              onClick={() => act('unlink_output')}
            >
              Unlink
            </Button.Confirm>
          </>
        }
      />
    </>
  );
};
