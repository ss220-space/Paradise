import { Loader } from './common/Loader';
import { InputButtons } from './common/InputButtons';
import { Button, Section, Stack, Table } from '../components';
import { useBackend } from '../backend';
import { useState, useEffect } from 'react';
import { Window } from '../layouts';

type ListInputData = {
  items: string[];
  message: string;
  timeout: number;
  title: string;
};

export const RankedListInputModal = (_props: unknown) => {
  const { data } = useBackend<ListInputData>();
  const { items = [], message = '', timeout, title } = data;
  const [edittedItems, setEdittedItems] = useState<string[]>(items);

  // Dynamically changes the window height based on the message.
  const windowHeight = 330 + Math.ceil(message.length / 3);

  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Section className="ListInput__Section" fill title={message}>
          <Stack fill vertical>
            <Stack.Item grow>
              <ListDisplay
                filteredItems={edittedItems}
                setEdittedItems={setEdittedItems}
              />
            </Stack.Item>
            <Stack.Item mt={0.5}>
              <InputButtons input={edittedItems} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

type ListDisplayProps = {
  filteredItems: string[];
  setEdittedItems: React.Dispatch<React.SetStateAction<string[]>>;
};

/**
 * Displays the list of selectable items.
 * If a search query is provided, filters the items.
 */
const ListDisplay = (props: ListDisplayProps) => {
  const { filteredItems, setEdittedItems } = props;
  const [draggedIndex, setDraggedIndex] = useState<number | null>(null);
  const [targetIndex, setTargetIndex] = useState<number | null>(null);
  const [dragOffset, setDragOffset] = useState(0);

  useEffect(() => {
    const handleGlobalMouseUp = () => {
      if (draggedIndex !== null) {
        setDraggedIndex(null);
        setTargetIndex(null);
      }
    };

    window.addEventListener('mouseup', handleGlobalMouseUp);
    return () => window.removeEventListener('mouseup', handleGlobalMouseUp);
  }, [draggedIndex]);
  // Начало перетаскивания
  const handleGrab = (index: number, e: React.MouseEvent) => {
    setDraggedIndex(index);
    // Запоминаем позицию мыши относительно элемента
    const target = e.currentTarget as HTMLElement;
    const rect = target.getBoundingClientRect();
    setDragOffset(e.clientY - rect.top);
  };

  // Определение позиции при движении мыши
  const handleMouseMove = (e: React.MouseEvent) => {
    if (draggedIndex === null) return;

    // Находим элемент под курсором
    const elements = document.elementsFromPoint(e.clientX, e.clientY);
    const button = elements.find((el) => el.classList.contains('Button'));

    if (button) {
      const row = button.closest('.Table__row');
      if (row) {
        const index = Array.from(row.parentNode?.children || []).indexOf(row);
        if (index !== -1 && index !== draggedIndex) {
          setTargetIndex(index);
        }
      }
    }
  };

  // Завершение перетаскивания
  const handleRelease = () => {
    if (
      draggedIndex !== null &&
      targetIndex !== null &&
      draggedIndex !== targetIndex
    ) {
      const newItems = [...filteredItems];
      const [movedItem] = newItems.splice(draggedIndex, 1);
      newItems.splice(targetIndex, 0, movedItem);
      setEdittedItems(newItems);
    }
    setDraggedIndex(null);
    setTargetIndex(null);
  };

  return (
    <Section
      fill
      scrollable
      onMouseMove={handleMouseMove}
      onMouseUp={handleRelease}
      onMouseLeave={handleRelease}
    >
      <Table>
        {filteredItems.map((item, index) => (
          <Table.Row
            key={index}
            className={`Table__row ${targetIndex === index ? 'hovered-row' : ''}`}
          >
            <Button
              fluid
              py="0.25rem"
              color={index === draggedIndex ? 'blue' : 'transparent'}
              onMouseDown={(e) => handleGrab(index, e)}
              style={{
                cursor: draggedIndex === null ? 'grab' : 'grabbing',
                animation: 'none',
                transition: 'none',
                ...(index === draggedIndex && { opacity: 0.5 }),
                ...(targetIndex === index && {
                  borderTop: '2px solid #2185d0',
                  marginTop: '-2px',
                }),
              }}
              icon="grip-lines"
            >
              {item.replace(/^\w/, (c: string) => c.toUpperCase())}
            </Button>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
