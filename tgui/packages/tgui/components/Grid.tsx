/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { CellProps, Table, TableProps } from './Table';

/** @deprecated */
export const Grid = (props: TableProps) => {
  const { children, ...rest } = props;
  return (
    <Table {...rest}>
      <Table.Row>{children}</Table.Row>
    </Table>
  );
};

type GridColumnProps = {
  size?: number;
} & CellProps;

/** @deprecated */
const GridColumn = (props: GridColumnProps) => {
  const { size = 1, style, ...rest } = props;
  return (
    <Table.Cell
      style={{
        width: size + '%',
        ...style,
      }}
      {...rest}
    />
  );
};

/** @deprecated */
Grid.Column = GridColumn;
