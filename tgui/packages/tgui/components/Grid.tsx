/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import type { ComponentProps } from 'react';
import { Table } from 'tgui-core/components';

/** @deprecated */
export const Grid = (props: ComponentProps<typeof Table>) => {
  const { children, ...rest } = props;
  return (
    <Table {...rest}>
      <Table.Row>{children}</Table.Row>
    </Table>
  );
};

type GridColumnProps = {
  size?: number;
} & ComponentProps<typeof Table.Cell>;

/** @deprecated */
const GridColumn = (props: GridColumnProps) => {
  const { size = 1, style, ...rest } = props;
  return (
    <Table.Cell
      style={{
        width: `${size}%`,
        ...style,
      }}
      {...rest}
    />
  );
};

/** @deprecated */
Grid.Column = GridColumn;
