/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { Box } from 'tgui/components';
import { classes } from 'common/react';

import { useBackend } from '../backend';
import { Layout } from './Layout';

type BoxProps = React.ComponentProps<typeof Box>;

type Props = Partial<{
  canSuspend: boolean;
  theme: string;
}> &
  BoxProps;

export const Pane = (props: Props) => {
  const { theme, canSuspend, children, className, ...rest } = props;
  const { suspended } = useBackend();

  const isSuspended = canSuspend && suspended;

  return (
    <Layout className={classes(['Window', className])} theme={theme} {...rest}>
      <Box fillPositionedParent>{!isSuspended && children}</Box>
    </Layout>
  );
};

type ContentProps = Partial<{
  fitted: boolean;
  scrollable: boolean;
}> &
  BoxProps;

const PaneContent = (props: ContentProps) => {
  const { className, fitted, children, ...rest } = props;

  return (
    <Layout.Content
      className={classes(['Window__content', className])}
      {...rest}
    >
      {fitted ? (
        children
      ) : (
        <div className="Window__contentPadding">{children}</div>
      )}
    </Layout.Content>
  );
};

Pane.Content = PaneContent;
