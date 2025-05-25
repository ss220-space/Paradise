import type { Placement } from '@popperjs/core';
import type { ReactNode } from 'react';
import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps } from 'common/ui';
import type { BoxProps } from './Box';
import { Tooltip } from './Tooltip';

type Props = {
  content?: ReactNode;
  /** A fancy, boxy tooltip, which appears when hovering over the button */
  tooltip?: ReactNode;
  /** Position of the tooltip. See [`Popper`](#Popper) for valid options. */
  tooltipPosition?: Placement;
} & BoxProps;

/**
 * ## ColorBox
 * Displays a 1-character wide colored square. Can be used as a status indicator,
 * or for visually representing a color.
 *
 * If you want to set a background color on an element, use a plain
 * [Box](https://github.com/tgstation/tgui-core/tree/main/lib/components/Box.tsx) instead.
 */
export const ColorBox = (props: Props) => {
  const {
    content,
    children,
    className,
    tooltip,
    tooltipPosition = 'auto',
    ...rest
  } = props;

  rest.color = content ? null : 'default';
  rest.backgroundColor = props.color || 'default';
  let result = content || children;

  result = (
    <div
      className={classes(['ColorBox', className, computeBoxClassName(rest)])}
      {...computeBoxProps(rest)}
    >
      {result || ''}
    </div>
  );

  if (tooltip) {
    result = (
      <Tooltip content={tooltip} position={tooltipPosition as Placement}>
        {result}
      </Tooltip>
    );
  }

  return result;
};
