/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Flex, type FlexProps } from './Flex';

/**
 *  ## LabeledControls
 * LabeledControls is a horizontal grid that is designed to hold various
 * controls, like [Knobs](https://github.com/tgstation/tgui-core/tree/main/lib/components/Knob.tsx)
 * or small [Buttons](https://github.com/tgstation/tgui-core/tree/main/lib/components/Button.tsx).
 *
 * Every item in this grid is labeled at the bottom.
 *
 * @example
 * ```tsx
 * <LabeledControls>
 *   <LabeledControls.Item label="Temperature"><Knob /></LabeledControls.Item>
 *   <LabeledControls.Item label="Submit"><Button /></LabeledControls.Item>
 * </LabeledControls>
 * ```
 */
export const LabeledControls = (props: FlexProps) => {
  const { children, wrap, ...rest } = props;

  return (
    <Flex
      mx={-0.5}
      wrap={wrap}
      align="stretch"
      justify="space-between"
      {...rest}
    >
      {children}
    </Flex>
  );
};

type ItemProps = {
  label: string;
} & FlexProps;

const LabeledControlsItem = (props: ItemProps) => {
  const { label, children, mx = 1, ...rest } = props;

  return (
    <Flex.Item mx={mx}>
      <Flex
        height="100%"
        direction="column"
        align="center"
        textAlign="center"
        justify="space-between"
        {...rest}
      >
        <Flex.Item />
        <Flex.Item>{children}</Flex.Item>
        <Flex.Item color="label">{label}</Flex.Item>
      </Flex>
    </Flex.Item>
  );
};

LabeledControls.Item = LabeledControlsItem;
