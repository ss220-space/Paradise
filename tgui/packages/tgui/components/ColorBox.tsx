import type { ReactNode } from 'react';
import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps } from 'common/ui';
import type { BoxProps } from './Box';

type Props = {
  content?: ReactNode;
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
  const { content, children, className, ...rest } = props;

  rest.color = content ? null : 'default';
  rest.backgroundColor = props.color || 'default';

  return (
    <div
      className={classes(['ColorBox', className, computeBoxClassName(rest)])}
      {...computeBoxProps(rest)}
    >
      {content || ''}
    </div>
  );
};
