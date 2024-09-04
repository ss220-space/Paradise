import { useBackend } from '../backend';
import { Button, LabeledList, Dropdown, Box, Section } from '../components';
import { Window } from '../layouts';

export const BrigTimer = (props, context) => {
  const { act, data } = useBackend(context);
  data.nameText = data.occupant;
  if (data.timing) {
    if (data.prisoner_hasrec) {
      data.nameText = <Box color="green">{data.occupant}</Box>;
    } else {
      data.nameText = <Box color="red">{data.occupant}</Box>;
    }
  }
  let nameIcon = 'pencil-alt';
  if (data.prisoner_name) {
    if (!data.prisoner_hasrec) {
      nameIcon = 'exclamation-triangle';
    }
  }
  let nameOptions = [];
  let i = 0;
  for (i = 0; i < data.spns.length; i++) {
    nameOptions.push(data.spns[i]);
  }
  return (
    <Window width={500} height={!data.timing ? 396 : 237}>
      <Window.Content>
        <Section title="Информация">
          <LabeledList>
            <LabeledList.Item label="Камера">{data.cell_id}</LabeledList.Item>
            <LabeledList.Item label="Заключённый">
              {data.nameText}
            </LabeledList.Item>
            <LabeledList.Item label="Обвинения">{data.crimes}</LabeledList.Item>
            <LabeledList.Item label="Сотрудник">
              {data.brigged_by}
            </LabeledList.Item>
            <LabeledList.Item label="Срок">{data.time_set}</LabeledList.Item>
            <LabeledList.Item label="Осталось">
              {data.time_left}
            </LabeledList.Item>
            <LabeledList.Item label="Действия">
              <>
                <Button
                  icon="lightbulb-o"
                  content="Флеш"
                  disabled={!data.isAllowed}
                  onClick={() => act('flash')}
                />
                <Button
                  icon="angle-up"
                  content="Добавить время"
                  disabled={!data.timing || !data.isAllowed}
                  onClick={() => act('add_timer')}
                />
                <Button
                  icon="sync"
                  content="Перезапустить таймер"
                  disabled={!data.timing || !data.isAllowed}
                  onClick={() => act('restart_timer')}
                />
                <Button
                  icon="eject"
                  content="Остановить таймер"
                  disabled={!data.timing || !data.isAllowed}
                  onClick={() => act('stop')}
                />
              </>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!data.timing && (
          <Section title="Новый заключённый">
            <LabeledList>
              <LabeledList.Item label="Имя">
                <Button
                  icon={nameIcon}
                  content={data.prisoner_name ? data.prisoner_name : '-----'}
                  disabled={!data.isAllowed}
                  onClick={() => act('prisoner_name')}
                />
                {!!data.spns.length && (
                  <Dropdown
                    disabled={!data.isAllowed || !data.spns.length}
                    options={data.spns}
                    width="250px"
                    onSelected={(value) =>
                      act('prisoner_name', {
                        prisoner_name: value,
                      })
                    }
                  />
                )}
              </LabeledList.Item>
              <LabeledList.Item label="Обвинения">
                <Button
                  icon="pencil-alt"
                  content={
                    data.prisoner_charge ? data.prisoner_charge : '-----'
                  }
                  disabled={!data.isAllowed}
                  onClick={() => act('prisoner_charge')}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Время">
                <Button
                  icon="pencil-alt"
                  content={data.prisoner_time ? data.prisoner_time : '-----'}
                  disabled={!data.isAllowed}
                  onClick={() => act('prisoner_time')}
                />
              </LabeledList.Item>
              <LabeledList.Item label="Начать">
                <Button
                  icon="gavel"
                  content="Назначить наказание"
                  disabled={
                    !data.prisoner_name ||
                    !data.prisoner_charge ||
                    !data.prisoner_time ||
                    data.prisoner_time < 0 ||
                    data.prisoner_time > 60 ||
                    !data.isAllowed
                  }
                  onClick={() => act('start')}
                />
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
