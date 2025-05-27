import type { ReactNode } from 'react';
import { Box } from './Box';
import { Button } from './Button';

type DialogProps = {
  /** The content of the dialog. */
  children: ReactNode;
  /** The height of the dialog. */
  height?: string;
  /** The function to call when close is clicked */
  onClose: () => void;
  /** The title of the dialog. */
  title: ReactNode;
  /** The width of the dialog. */
  width?: string;
};

/**
 * ## Dialog
 * A themed dialog for user interaction.
 *
 * @example
 * ```tsx
 * <Dialog title="Dialog Title" onClose={() => {}}>
 *   <div>Dialog Content</div>
 * </Dialog>
 * ```
 */
export const Dialog = (props: DialogProps) => {
  const { title, onClose, children, width, height } = props;

  return (
    <div className="Dialog">
      <Box className="Dialog__content" width={width || '370px'} height={height}>
        <div className="Dialog__header">
          <div className="Dialog__title">{title}</div>
          <Box mr={2}>
            <Button
              color="transparent"
              icon="window-close-o"
              lineHeight="22px"
              mr="-3px"
              onClick={onClose}
              textAlign="center"
              tooltip="Close"
              tooltipPosition="bottom-start"
              width="26px"
            />
          </Box>
        </div>
        {children}
      </Box>
    </div>
  );
};

type DialogButtonProps = {
  children: any;
  onClick: () => void;
};

const DialogButton = (props: DialogButtonProps) => {
  const { onClick, children } = props;
  return (
    <Button
      onClick={onClick}
      className="Dialog__button"
      verticalAlignContent="middle"
    >
      {children}
    </Button>
  );
};

Dialog.Button = DialogButton;
