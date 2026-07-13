import type { Placement } from '@popperjs/core';
import { type CSSProperties, type ReactNode, useState } from 'react';
import { type BooleanLike, classes } from 'common/react';

import { Popper } from './Popper';

type Props = {
  /** Interacting with this element will open the floating element. */
  children: ReactNode;
  /** The content to display like floating. */
  content: ReactNode;
} & Partial<{
  /**
   * Where the content will be displayed, relative to children.
   * @default 'bottom'
   */
  placement: Placement;
  /** Classes which will be applied to the content. */
  contentClasses: string;
  /** Inline styles which will be applied to the content. */
  contentStyles: CSSProperties;
  /** Disables all interactions. */
  disabled: BooleanLike;
}>;

/**
 * ## Floating
 *
 * Floating lets you position elements so that they don't go out of the bounds
 * of the window. Click the children to toggle the content, click outside to
 * close it.
 *
 * Adapted from tgui-core's Floating to use this project's Popper, since
 * `@floating-ui/react` is not available here.
 */
export const Floating = (props: Props) => {
  const {
    children,
    content,
    placement = 'bottom',
    contentClasses,
    contentStyles,
    disabled,
  } = props;
  const [open, setOpen] = useState(false);

  return (
    <Popper
      isOpen={open}
      placement={placement}
      onClickOutside={() => setOpen(false)}
      content={
        <div
          className={classes(['Floating', contentClasses])}
          data-position={placement}
          style={contentStyles}
        >
          {content}
        </div>
      }
    >
      <div
        onClick={() => {
          if (!disabled) {
            setOpen((current) => !current);
          }
        }}
      >
        {children}
      </div>
    </Popper>
  );
};
