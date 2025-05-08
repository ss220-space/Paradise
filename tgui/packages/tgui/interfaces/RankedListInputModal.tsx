import { Loader } from './common/Loader';
import { InputButtons } from './common/InputButtons';
import { Button, Section, Stack, Table } from '../components';
import { useBackend } from '../backend';
import { useState, DragEvent } from 'react';
import { Window } from '../layouts';

type ListInputData = {
  items: string[];
  message: string;
  timeout: number;
  title: string;
};

export const RankedListInputModal = (_props:unknown) => {
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

/**
 * Displays the list of selectable items.
 * If a search query is provided, filters the items.
 */
const ListDisplay = (props) => {
  const { filteredItems, setEdittedItems } = props;
  const [draggedItemIndex, setDraggedItemIndex] = useState<number | null>(null);

  // Handle the drag start event
  const handleDragStart = (index: number) => {
    setDraggedItemIndex(index);
  };

  // Handle the drag over event
  const handleDragOver = (event: DragEvent<HTMLDivElement>) => {
    event.preventDefault(); // Required to allow dropping
  };

  // Handle the drop event for items
  const handleDrop = (index: number | null = null) => {
    if (draggedItemIndex === null) return;

    const updatedItems = [...filteredItems];
    const draggedItem = updatedItems.splice(draggedItemIndex, 1)[0]; // Remove dragged item

    // If no index is provided, add the item to the end of the list (used for drop on section)
    if (index === null) {
      updatedItems.push(draggedItem);
    } else {
      updatedItems.splice(index, 0, draggedItem); // Insert dragged item at new position
    }

    setEdittedItems(updatedItems);
    setDraggedItemIndex(null); // Reset the dragged item index
  };

  return (
    <Section
      fill
      scrollable
      onDrop={() => handleDrop(null)} // Handle drop on Section
      onDragOver={handleDragOver} // Allow dropping on Section
    >
      <Table>
        {filteredItems.map((item, index) => (
          <Table.Row
            key={index}
            onDragStart={() => handleDragStart(index)}
            onDragOver={handleDragOver}
            onDrop={() => handleDrop(index)}
            style={{
              padding: '8px',
            }}
          >
            <Button
              fluid
              py="0.25rem"
              color="transparent"
              style={{
                animation: 'none',
                transition: 'none',
                cursor: 'move',
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
