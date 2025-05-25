import { Loader } from './common/Loader';
import { InputButtons } from './common/InputButtons';
import { Button, Section, Stack } from '../components';
import { useBackend } from '../backend';
import { useState, KeyboardEvent } from 'react';
import { Window } from '../layouts';
import { BooleanLike } from 'common/react';

type ListInputData = {
  init_value: string;
  items: CheckboxData[];
  message: string;
  timeout: number;
  title: string;
};

interface CheckboxData {
  key: string;
  checked: BooleanLike;
}
export const CheckboxListInputModal = (props: unknown) => {
  const { data } = useBackend<ListInputData>();
  const { items = [], message = '', timeout, title } = data;
  const [edittedItems, setEdittedItems] = useState<CheckboxData[]>(items);

  const windowHeight = 330 + Math.ceil(message.length / 3);

  const onClick = (new_item: CheckboxData | null = null) => {
    let updatedItems = [...edittedItems];
    updatedItems = updatedItems.map((item) =>
      item.key === new_item.key ? { ...item, checked: !new_item.checked } : item
    );
    setEdittedItems(updatedItems);
  };

  return (
    <Window title={title} width={325} height={windowHeight}>
      {timeout && <Loader value={timeout} />}
      <Window.Content>
        <Section className="ListInput__Section" fill title={message}>
          <Stack fill vertical>
            <Stack.Item grow>
              <ListDisplay filteredItems={edittedItems} onClick={onClick} />
            </Stack.Item>
            <Stack.Item mt={0.5}>
              <InputButtons input={edittedItems as any} />
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};

type ListDisplayProps = {
  filteredItems: CheckboxData[];
  onClick: (new_item: CheckboxData | null) => void;
};

/**
 * Displays the list of selectable items.
 * If a search query is provided, filters the items.
 */
const ListDisplay = (props: ListDisplayProps) => {
  const { filteredItems, onClick } = props;

  return (
    <Section fill scrollable>
      {filteredItems.map((item, index) => {
        return (
          <Button.Checkbox
            fluid
            key={index}
            onClick={() => onClick(item)}
            checked={item.checked}
            style={{
              animation: 'none',
              transition: 'none',
            }}
          >
            {item.key.replace(/^\w/, (c) => c.toUpperCase())}
          </Button.Checkbox>
        );
      })}
    </Section>
  );
};
