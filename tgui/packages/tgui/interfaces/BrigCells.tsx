import { Window } from '../layouts';
import { TimeDisplay, Button, Section, Stack, Table } from '../components';
import { useBackend } from '../backend';

type Cell = {
  cell_id: string;
  occupant: string;
  crimes: string;
  brigged_by: string;
  time_left_seconds: number;
  time_set_seconds: number;
  ref: string;
};

type CellsData = {
  cells: Cell[];
};

type CellData = {
  cell: Cell;
};

const BrigCellsTableRow = ({ cell }: CellData) => {
  const { act } = useBackend();
  const {
    cell_id,
    occupant,
    crimes,
    brigged_by,
    time_left_seconds,
    time_set_seconds,
    ref,
  } = cell;

  let className = '';
  if (time_left_seconds > 0) {
    className += ' BrigCells__listRow--active';
  }

  const release = () => {
    act('release', { ref, occupant });
  };

  const minsec = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = Math.floor(seconds % 60);
    return `${String(mins).padStart(2, '0')}:${String(secs).padStart(2, '0')}`;
  };

  return (
    <Table.Row className={className}>
      <Table.Cell style={{ textAlign: 'center' }}>{cell_id}</Table.Cell>
      <Table.Cell style={{ textAlign: 'center' }}>{occupant}</Table.Cell>
      <Table.Cell style={{ textAlign: 'center' }}>{crimes}</Table.Cell>
      <Table.Cell style={{ textAlign: 'center' }}>{brigged_by}</Table.Cell>
      <Table.Cell style={{ textAlign: 'center' }}>
        {minsec(time_set_seconds)}
      </Table.Cell>
      <Table.Cell style={{ textAlign: 'center' }}>
        {minsec(time_left_seconds)}
      </Table.Cell>
      <Table.Cell style={{ textAlign: 'center' }}>
        <Button onClick={release}>Выпустить</Button>
      </Table.Cell>
    </Table.Row>
  );
};

const BrigCellsTable = ({ cells }: CellsData) => (
  <Table
    className="BrigCells__list"
    style={{
      borderCollapse: 'collapse',
    }}
  >
    <Table.Row>
      <Table.Cell header style={{ width: '100px', textAlign: 'center' }}>
        Камера
      </Table.Cell>
      <Table.Cell header style={{ width: '150px', textAlign: 'center' }}>
        Заключённый
      </Table.Cell>
      <Table.Cell header style={{ width: '200px', textAlign: 'center' }}>
        Обвинения
      </Table.Cell>
      <Table.Cell header style={{ width: '180px', textAlign: 'center' }}>
        Произвёл заключение
      </Table.Cell>
      <Table.Cell header style={{ width: '80px', textAlign: 'center' }}>
        Срок
      </Table.Cell>
      <Table.Cell header style={{ width: '80px', textAlign: 'center' }}>
        Осталось
      </Table.Cell>
      <Table.Cell header style={{ width: '100px', textAlign: 'center' }}>
        Выпустить
      </Table.Cell>
    </Table.Row>
    {cells.map((cell) => (
      <BrigCellsTableRow key={cell.ref} cell={cell} />
    ))}
  </Table>
);

export const BrigCells = (properties) => {
  const { data } = useBackend<CellsData>();
  const uniqueCells: Cell[] = Array.from(
    new Map(data.cells.map((cell: Cell) => [cell.cell_id, cell])).values()
  );

  return (
    <Window theme="security" width={800} height={330}>
      <Window.Content>
        <Stack fill vertical>
          <Section fill scrollable>
            <BrigCellsTable cells={uniqueCells} />
          </Section>
        </Stack>
      </Window.Content>
    </Window>
  );
};
