/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { type CSSProperties, type ReactNode, useState } from 'react';
import { Box, type BoxProps } from './Box';
import { Button } from './Button';

type Props = Partial<{
  /** Buttons or other content to render inline with the button */
  buttons: ReactNode;
  /** Top margin of the child nodes, defaulted to 1 */
  child_mt: number;
  /** Icon to display with the collapsible */
  icon: string;
  /** Whether the collapsible is open */
  open: boolean;
  /** Text to display on the button for collapsing */
  title: ReactNode;
  /** Custom styles for the child nodes */
  childStyles: CSSProperties;
}> &
  BoxProps;

export type CollapsibleProps = Props;

/**
 * ## Collapsible
 * Displays contents when open, acts as a fluid button when closed.
 *
 * Click to toggle, closed by default.
 */
export const Collapsible = (props: Props) => {
  const {
    children,
    child_mt = 1,
    childStyles,
    color,
    title,
    buttons,
    icon,
    ...rest
  } = props;
  const [open, setOpen] = useState(props.open);

  return (
    <Box mb={1}>
      <div className="Table">
        <div className="Table__cell">
          <Button
            fluid
            color={color}
            icon={icon ? icon : open ? 'chevron-down' : 'chevron-right'}
            onClick={() => setOpen(!open)}
            {...rest}
          >
            {title}
          </Button>
        </div>
        {buttons && (
          <div className="Table__cell Table__cell--collapsing">{buttons}</div>
        )}
      </div>
      {open && (
        <Box mt={child_mt} style={childStyles}>
          {children}
        </Box>
      )}
    </Box>
  );
};
