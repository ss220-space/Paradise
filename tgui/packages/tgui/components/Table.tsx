/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { computeBoxClassName, computeBoxProps } from 'common/ui';
import type { BoxProps } from './Box';

type Props = Partial<{
  /** Collapses table to the smallest possible size. */
  collapsing: boolean;
}> &
  BoxProps;

export type TableProps = Props;

/**
 * ## Table
 * A straight forward mapping to a standard html table, which is slightly
 * simplified (does not need a `<tbody>` tag) and with sane default styles
 * (e.g. table width is 100% by default).
 *
 * @example
 * ```tsx
 * <Table>
 *   <Table.Row>
 *     <Table.Cell bold>Hello world!</Table.Cell>
 *     <Table.Cell collapsing color="label">
 *       Label
 *     </Table.Cell>
 *   </Table.Row>
 * </Table>
 * ```
 */
export const Table = (props: Props) => {
  const { className, collapsing, children, ...rest } = props;

  return (
    <table
      className={classes([
        'Table',
        collapsing && 'Table--collapsing',
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
    >
      <tbody>{children}</tbody>
    </table>
  );
};

type RowProps = Partial<{
  /** Whether this is a header cell. */
  header: boolean;
}> &
  BoxProps;

const TableRow = (props: RowProps) => {
  const { className, header, ...rest } = props;

  return (
    <tr
      className={classes([
        'Table__row',
        header && 'Table__row--header',
        className,
        computeBoxClassName(props),
      ])}
      {...computeBoxProps(rest)}
    />
  );
};

export type CellProps = Partial<{
  /** Additional columns for this cell to expand, assuming there is room. */
  colSpan: number;
  /** Collapses table cell to the smallest possible size,
  and stops any text inside from wrapping. */
  collapsing: boolean;
  /** Whether this is a header cell. */
  header: boolean;
  /** Rows for this cell to expand, assuming there is room. */
  rowSpan: number;
}> &
  BoxProps;

const TableCell = (props: CellProps) => {
  const { className, collapsing, colSpan, header, ...rest } = props;

  return (
    <td
      className={classes([
        'Table__cell',
        collapsing && 'Table__cell--collapsing',
        header && 'Table__cell--header',
        className,
        computeBoxClassName(props),
      ])}
      colSpan={colSpan}
      {...computeBoxProps(rest)}
    />
  );
};

/**
 * ## Table.Cell
 * A straight forward mapping to `<td>` element.
 */
Table.Cell = TableCell;
/**
 * ## Table.Row
 * A straight forward mapping to `<tr>` element.
 */
Table.Row = TableRow;
