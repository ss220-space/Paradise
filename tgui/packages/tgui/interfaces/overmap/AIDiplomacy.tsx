import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  LabeledList,
  Stack,
} from 'tgui-core/components';

export type AIRelation = { id: string; relation: number };
export type AIRelationOption = { id: string; name: string };
export type AIDiplomacyValue = {
  friends: string[];
  enemies: string[];
  relations: AIRelation[];
};

export const AIDiplomacy = ({
  value,
  factions,
  contacts,
  onChange,
}: {
  value: AIDiplomacyValue;
  factions: Record<string, string>;
  contacts: AIRelationOption[];
  onChange: (value: AIDiplomacyValue) => void;
}) => {
  const [contact, setContact] = useState('');
  const toggle = (list: 'friends' | 'enemies', id: string) => {
    const other = list === 'friends' ? 'enemies' : 'friends';
    onChange({
      ...value,
      [list]: value[list].includes(id)
        ? value[list].filter((item) => item !== id)
        : [...value[list], id],
      [other]: value[other].filter((item) => item !== id),
    });
  };
  const add = (relation: number) => {
    if (!contacts.some((item) => item.id === contact)) return;
    onChange({
      ...value,
      relations: [
        ...value.relations.filter((item) => item.id !== contact),
        { id: contact, relation },
      ],
    });
  };
  return (
    <LabeledList>
      {(['friends', 'enemies'] as const).map((list) => (
        <LabeledList.Item
          key={list}
          label={
            list === 'friends' ? 'Дружественные фракции' : 'Враждебные фракции'
          }
        >
          {Object.entries(factions).map(([id, label]) => (
            <Button.Checkbox
              key={id}
              checked={value[list].includes(id)}
              onClick={() => toggle(list, id)}
            >
              {label}
            </Button.Checkbox>
          ))}
        </LabeledList.Item>
      ))}
      <LabeledList.Item label="Отдельные суда и соединения">
        <Dropdown
          fluid
          selected={contact}
          displayText={contacts.find((item) => item.id === contact)?.name}
          placeholder="Выберите судно или соединение"
          options={contacts.map((item) => ({
            value: item.id,
            displayText: item.name,
          }))}
          onSelected={setContact}
        />
        <Button
          mt={0.5}
          disabled={!contact}
          color="good"
          onClick={() => add(1)}
        >
          Добавить друга
        </Button>
        <Button
          mt={0.5}
          disabled={!contact}
          color="bad"
          onClick={() => add(-1)}
        >
          Добавить врага
        </Button>
        {value.relations.map((entry) => (
          <Stack key={entry.id} align="center" mt={0.5}>
            <Stack.Item grow color={entry.relation > 0 ? 'good' : 'bad'}>
              {entry.relation > 0 ? 'Друг' : 'Враг'} ·{' '}
              {contacts.find((item) => item.id === entry.id)?.name || entry.id}
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="trash"
                onClick={() =>
                  onChange({
                    ...value,
                    relations: value.relations.filter(
                      (item) => item.id !== entry.id,
                    ),
                  })
                }
              >
                Убрать
              </Button>
            </Stack.Item>
          </Stack>
        ))}
        <Box color="label" mt={0.5}>
          Отдельные отношения имеют приоритет над фракцией. Обстрел союзников
          добавляет агрессора в список врагов: после 9 попаданий от друга или 3
          от нейтрального контакта. Для нейтрального соединения — после 3.
          Попадания внутри своего соединения не учитываются.
        </Box>
      </LabeledList.Item>
    </LabeledList>
  );
};
