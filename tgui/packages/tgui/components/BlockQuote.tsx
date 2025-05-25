/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { Box, type BoxProps } from './Box';

/**
 * ## BlockQuote
 * Just a block quote, just like this example in markdown:
 * > Here's an example of a block quote.
 */
export const BlockQuote = (props: BoxProps) => {
  const { className, ...rest } = props;

  return <Box className={classes(['BlockQuote', className])} {...rest} />;
};
