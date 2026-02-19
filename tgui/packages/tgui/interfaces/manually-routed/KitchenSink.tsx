import { useBackend } from '../../backend';
import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  ByondUi,
  Collapsible,
  Flex,
  Icon,
  Input,
  Knob,
  LabeledList,
  NumberInput,
  ProgressBar,
  Section,
  Slider,
  Tabs,
  Tooltip,
} from '../../components';
import { DraggableControl } from '../../components/DraggableControl';
import { Window } from '../../layouts';
import { Placement } from '@popperjs/core';

const COLORS_ARBITRARY = [
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
];

const COLORS_STATES = ['good', 'average', 'bad', 'black', 'white'];

const PAGES = [
  {
    title: 'Button',
    component: () => KitchenSinkButton,
  },
  {
    title: 'Box',
    component: () => KitchenSinkBox,
  },
  {
    title: 'ProgressBar',
    component: () => KitchenSinkProgressBar,
  },
  {
    title: 'Tabs',
    component: () => KitchenSinkTabs,
  },
  {
    title: 'Tooltip',
    component: () => KitchenSinkTooltip,
  },
  {
    title: 'Input / Control',
    component: () => KitchenSinkInput,
  },
  {
    title: 'Collapsible',
    component: () => KitchenSinkCollapsible,
  },
  {
    title: 'BlockQuote',
    component: () => KitchenSinkBlockQuote,
  },
  {
    title: 'ByondUi',
    component: () => KitchenSinkByondUi,
  },
  {
    title: 'Themes',
    component: () => KitchenSinkThemes,
  },
];

export const KitchenSink = (props: unknown) => {
  const [theme] = useState();
  const [pageIndex, setPageIndex] = useState(0);
  const PageComponent = PAGES[pageIndex].component();
  return (
    <Window theme={theme}>
      <Window.Content scrollable>
        <Section>
          <Flex>
            <Flex.Item>
              <Tabs vertical>
                {PAGES.map((page, i) => (
                  <Tabs.Tab
                    key={i}
                    selected={i === pageIndex}
                    onClick={() => setPageIndex(i)}
                  >
                    {page.title}
                  </Tabs.Tab>
                ))}
              </Tabs>
            </Flex.Item>
            <Flex.Item grow={1} basis={0}>
              <PageComponent />
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

const KitchenSinkButton = (props: unknown) => {
  return (
    <Box>
      <Box mb={1}>
        <Button>Simple</Button>
        <Button selected>Selected</Button>
        <Button disabled>Disabled</Button>
        <Button color="transparent">Transparent</Button>
        <Button icon="cog">Icon</Button>
        <Button icon="power-off" />
        <Button fluid>Fluid</Button>
        <Button my={1} lineHeight={2} minWidth={15} textAlign="center">
          With Box props
        </Button>
      </Box>
      <Box mb={1}>
        {COLORS_STATES.map((color) => (
          <Button key={color} color={color}>
            {color}
          </Button>
        ))}
        <br />
        {COLORS_ARBITRARY.map((color) => (
          <Button key={color} color={color}>
            {color}
          </Button>
        ))}
        <br />
        {COLORS_ARBITRARY.map((color) => (
          <Box inline mx="7px" key={color} color={color}>
            {color}
          </Box>
        ))}
      </Box>
    </Box>
  );
};

const KitchenSinkBox = (props: unknown) => {
  return (
    <Box>
      <Box bold>bold</Box>
      <Box italic>italic</Box>
      <Box opacity={0.5}>opacity 0.5</Box>
      <Box opacity={0.25}>opacity 0.25</Box>
      <Box m={2}>m: 2</Box>
      <Box textAlign="left">left</Box>
      <Box textAlign="center">center</Box>
      <Box textAlign="right">right</Box>
    </Box>
  );
};

const KitchenSinkProgressBar = (props: unknown) => {
  const [progress, setProgress] = useState(0.5);

  return (
    <Box>
      <ProgressBar
        ranges={{
          good: [0.5, Infinity],
          bad: [-Infinity, 0.1],
          average: [0, 0.5],
        }}
        minValue={-1}
        maxValue={1}
        value={progress}
      >
        Value: {Number(progress).toFixed(1)}
      </ProgressBar>
      <Box mt={1}>
        <Button onClick={() => setProgress(progress - 0.1)}>-0.1</Button>
        <Button onClick={() => setProgress(progress + 0.1)}>+0.1</Button>
      </Box>
    </Box>
  );
};

const KitchenSinkTabs = (props: unknown) => {
  const [tabIndex, setTabIndex] = useState<number>(0);
  const [vertical, setVertical] = useState<boolean>();
  const TAB_RANGE = [1, 2, 3, 4, 5];
  return (
    <Box>
      <Box mb={2}>
        <Button.Checkbox
          inline
          checked={vertical}
          onClick={() => setVertical(!vertical)}
        >
          vertical
        </Button.Checkbox>
      </Box>
      <Tabs vertical={vertical}>
        {TAB_RANGE.map((number, i) => (
          <Tabs.Tab
            key={i}
            selected={i === tabIndex}
            onClick={() => setTabIndex(i)}
          >
            Tab #{number}
          </Tabs.Tab>
        ))}
      </Tabs>
    </Box>
  );
};

const KitchenSinkTooltip = (props: unknown) => {
  const positions = [
    'top',
    'left',
    'right',
    'bottom',
    'bottom-start',
    'bottom-end',
  ];
  return (
    <>
      <Box>
        <Box inline position="relative" mr={1}>
          Box (hover me).
          <Tooltip content="Tooltip text." />
        </Box>
        <Button tooltip="Tooltip text.">Button</Button>
      </Box>
      <Box mt={1}>
        {positions.map((position) => (
          <Button
            key={position}
            color="transparent"
            tooltip="Tooltip text."
            tooltipPosition={position as Placement}
          >
            {position}
          </Button>
        ))}
      </Box>
    </>
  );
};

const KitchenSinkInput = (props: unknown) => {
  const [number, setNumber] = useState(0);

  const [text, setText] = useState('Sample text');

  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Input (onChange)">
          <Input value={text} onChange={setText} />
        </LabeledList.Item>
        <LabeledList.Item label="NumberInput (onChange)">
          <NumberInput
            animated
            width="40px"
            step={1}
            stepPixelSize={5}
            value={number}
            minValue={-100}
            maxValue={100}
            onChange={(value) => setNumber(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="NumberInput (onDrag)">
          <NumberInput
            animated
            width="40px"
            step={1}
            stepPixelSize={5}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(value) => setNumber(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Slider (onDrag)">
          <Slider
            step={1}
            stepPixelSize={5}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(e, value) => setNumber(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Knob (onDrag)">
          <Knob
            inline
            size={1}
            step={1}
            stepPixelSize={2}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(e, value) => setNumber(value)}
          />
          <Knob
            ml={1}
            inline
            bipolar
            size={1}
            step={1}
            stepPixelSize={2}
            value={number}
            minValue={-100}
            maxValue={100}
            onDrag={(e, value) => setNumber(value)}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Rotating Icon">
          <Box inline position="relative">
            <DraggableControl
              value={number}
              minValue={-100}
              maxValue={100}
              dragMatrix={[0, -1]}
              step={1}
              stepPixelSize={5}
              onDrag={(e, value) => setNumber(value)}
            >
              {(control) => (
                <Box onMouseDown={control.handleDragStart}>
                  <Icon
                    size={4}
                    color="yellow"
                    name="times"
                    rotation={control.displayValue * 4}
                  />
                  {control.inputElement}
                </Box>
              )}
            </DraggableControl>
          </Box>
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};

const KitchenSinkCollapsible = (props: unknown) => {
  return (
    <Collapsible title="Collapsible Demo" buttons={<Button icon="cog" />}>
      <Section>
        <BoxWithSampleText />
      </Section>
    </Collapsible>
  );
};

const BoxWithSampleText = (props) => {
  return (
    <Box {...props}>
      <Box italic>Jackdaws love my big sphinx of quartz.</Box>
      <Box mt={1} bold>
        The wide electrification of the southern provinces will give a powerful
        impetus to the growth of agriculture.
      </Box>
    </Box>
  );
};

const KitchenSinkBlockQuote = (props: unknown) => {
  return (
    <BlockQuote>
      <BoxWithSampleText />
    </BlockQuote>
  );
};

const KitchenSinkByondUi = (props: unknown) => {
  const { config } = useBackend();
  return (
    <Box>
      <Section title="Button">
        <ByondUi
          params={{
            type: 'button',
            parent: config.window.key,
            text: 'Button',
          }}
        />
      </Section>
    </Box>
  );
};

const KitchenSinkThemes = (props: unknown) => {
  const [theme, setTheme] = useState<string>();
  return (
    <Box>
      <LabeledList>
        <LabeledList.Item label="Use theme">
          <Input
            placeholder="theme_name"
            value={theme}
            expensive
            onChange={setTheme}
          />
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};
