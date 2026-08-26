import { computeBoxProps } from 'common/ui';
import { Button, Icon, Table } from '../../components';
import { ButtonProps } from '../../components/Button';

type SortButtonProps = ButtonProps & SordIdProps & SortOrderProps;

export const SortButton = (properties: SortButtonProps) => {
  const { id, children } = properties;
  const { sortId, setSortId, sortOrder, setSortOrder } = properties;
  return (
    <Table.Cell>
      <Button
        color={sortId !== id && 'transparent'}
        width="100%"
        onClick={() => {
          if (sortId === id) {
            setSortOrder(!sortOrder);
          } else {
            setSortId(id);
            setSortOrder(true);
          }
        }}
        {...computeBoxProps(properties)}
      >
        {children}
        {sortId === id && (
          <Icon name={sortOrder ? 'sort-up' : 'sort-down'} ml="0.25rem;" />
        )}
      </Button>
    </Table.Cell>
  );
};
