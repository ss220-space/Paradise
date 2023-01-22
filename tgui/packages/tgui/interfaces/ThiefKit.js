import { useBackend } from '../backend';
import { LabeledList, Section, Button, Box } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';

export const ThiefKit = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    uses,
    possible_uses,
    kits,
    choosen_kits,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>

        <Section title="Доступные наборы:"
          buttons={(
            <Button
              content="Случайный набор"
              icon="question"
              disabled={uses >= possible_uses}
              onClick={() => act("randomKit")}
            />
          )}>

          <LabeledList>
            {kits && kits.map(i => (
              <LabeledList.Item key={i.type}
                label={i.name}
                buttons={(
                  <Section>
                    <Button
                      icon="upload"
                      content="Выбрать"
                      disabled={i.was_taken}
                      onClick={() =>
                        act("takeKit", {
                          item: i.type,
                        })}
                    />
                    <Button
                      icon="undo"
                      disabled={!i.was_taken}
                      onClick={() =>
                        act("undoKit", {
                          item: i.type,
                        })}
                    />
                  </Section>
                )}>
                <Box italic>{i.desc}</Box>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>

        <Section title="Выбранные наборы:">
          <LabeledList>
            {choosen_kits && choosen_kits.map(i => (
              <LabeledList.Item key={i.type}
                label={i.name}
                buttons={(
                  <Button
                    icon="undo"
                    content="Отменить выбор"
                    onClick={() =>
                      act("undoKit", {
                        item: i.type,
                      })}
                  />
                )}>
                <Box italic>{'  '}</Box>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>

        <Section>
          <Button
            content="Завершить выбор"
            color={uses < possible_uses ? 'grey' : 'good'}
            disabled={uses < possible_uses}
            onClick={() => act("open")}
          />
          <Button
            content="Очистить выбор"
            icon="undo"
            color={uses <= 0 ? 'grey' : (uses < possible_uses ? 'average' : 'bad')}
            disabled={uses <= 0}
            onClick={() => act("clear")}
          />
        </Section>

      </Window.Content>
    </Window>
  );
};
