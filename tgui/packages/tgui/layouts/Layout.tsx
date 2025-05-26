/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useEffect, useRef } from 'react';
import { Box } from 'tgui/components';
import { addScrollableNode, removeScrollableNode } from 'common/events';
import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps } from 'common/ui';

type BoxProps = React.ComponentProps<typeof Box>;

type Props = Partial<{
  theme: string;
}> &
  BoxProps;

export const Layout = (props: Props) => {
  const { className, theme = 'nanotrasen', children, ...rest } = props;
  document.documentElement.className = `theme-${theme}`;

  return (
    <div className={'theme-' + theme}>
      <div
        className={classes(['Layout', className, computeBoxClassName(rest)])}
        {...computeBoxProps(rest)}
      >
        {children}
      </div>
    </div>
  );
};

type ContentProps = Partial<{
  scrollable: boolean;
}> &
  BoxProps;

const LayoutContent = (props: ContentProps) => {
  const { className, scrollable, children, ...rest } = props;
  const node = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const self = node.current;

    if (self && scrollable) {
      addScrollableNode(self);
    }
    return () => {
      if (self && scrollable) {
        removeScrollableNode(self);
      }
    };
  }, []);

  return (
    <div
      className={classes([
        'Layout__content',
        scrollable && 'Layout__content--scrollable',
        className,
        computeBoxClassName(rest),
      ])}
      ref={node}
      {...computeBoxProps(rest)}
    >
      {children}
    </div>
  );
};

Layout.Content = LayoutContent;
