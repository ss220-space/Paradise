/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import type { RefObject } from 'react';
import { classes } from 'common/react';
import { computeBoxClassName } from 'common/ui';
import {
  type FlexItemProps,
  type FlexProps,
  computeFlexClassName,
  computeFlexItemProps,
  computeFlexProps,
} from './Flex';

type Props = Partial<{
  /** Fills available space. */
  fill: boolean;
  /** Reverses the stack. */
  reverse: boolean;
  /** Flex column */
  vertical: boolean;
  /** Adds zebra striping to the stack. */
  zebra: boolean;
}> &
  FlexProps;

/**
 * ## Stack
 * A higher-level component that is based on
 * [Flex](https://github.com/tgstation/tgui-core/tree/main/lib/components/Flex.tsx).
 *
 * The main difference from `Flex`, is that this component automatically adds
 * spacing between all stack items, reducing the boilerplate that you have to write!
 *
 * Consists of two elements: `<Stack>` and `<Stack.Item>`.
 *
 * Stacks can be vertical by adding a `vertical` property.
 *
 * @example
 * ```tsx
 * <Stack vertical>
 *   <Stack.Item grow>Button description</Stack.Item>
 *   <Stack.Item>
 *     <Button>Perform an action</Button>
 *   </Stack.Item>
 * </Stack>
 * ```
 *
 * ### High level window layout
 * Stacks can be used for high level window layout.
 * Make sure to use the `fill` property.
 *
 * @example
 * ```tsx
 * <Window>
 *   <Window.Content>
 *     <Stack fill>
 *       <Stack.Item>
 *         <Section fill>Sidebar</Section>
 *       </Stack.Item>
 *       <Stack.Item grow>
 *         <Stack fill vertical>
 *           <Stack.Item grow>
 *             <Section fill scrollable>
 *               Main content
 *             </Section>
 *           </Stack.Item>
 *           <Stack.Item>
 *             <Section>Bottom pane</Section>
 *           </Stack.Item>
 *         </Stack>
 *       </Stack.Item>
 *     </Stack>
 *   </Window.Content>
 * </Window>
 * ```
 */
export const Stack = (props: Props) => {
  const { className, vertical, fill, reverse, zebra, ...rest } = props;

  const directionPrefix = vertical ? 'column' : 'row';
  const directionSuffix = reverse ? '-reverse' : '';

  return (
    <div
      className={classes([
        'Stack',
        fill && 'Stack--fill',
        vertical ? 'Stack--vertical' : 'Stack--horizontal',
        zebra && 'Stack--zebra',
        reverse && `Stack--reverse${vertical ? '--vertical' : ''}`,
        className,
        computeFlexClassName(props),
      ])}
      {...computeFlexProps({
        direction: `${directionPrefix}${directionSuffix}`,
        ...rest,
      })}
    />
  );
};

type StackItemProps = FlexItemProps &
  Partial<{
    innerRef: RefObject<HTMLDivElement>;
  }>;

const StackItem = (props: StackItemProps) => {
  const { className, innerRef, ...rest } = props;

  return (
    <div
      className={classes(['Stack__item', className, computeBoxClassName(rest)])}
      ref={innerRef}
      {...computeFlexItemProps(rest)}
    />
  );
};

Stack.Item = StackItem;

type StackDividerProps = FlexItemProps &
  Partial<{
    hidden: boolean;
  }>;

const StackDivider = (props: StackDividerProps) => {
  const { className, hidden, ...rest } = props;

  return (
    <div
      className={classes([
        'Stack__item',
        'Stack__divider',
        hidden && 'Stack__divider--hidden',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeFlexItemProps(rest)}
    />
  );
};

Stack.Divider = StackDivider;
