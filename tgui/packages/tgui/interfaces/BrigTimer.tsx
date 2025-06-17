import { ReactNode } from 'react';
import { useBackend } from '../backend';
import { Button, LabeledList, Dropdown, Box, Section } from '../components';
import { Window } from '../layouts';

type BrigTimerData = {
  nameText: ReactNode | string;
  occupant: string;
  timing: boolean;
  prisoner_hasrec: boolean;
  prisoner_name: string;
  cell_id: string;
  crimes: string;
  brigged_by: string;
  time_set: string;
  time_left: string;
  isAllowed: boolean;
  prisoner_charge: string;
  prisoner_time: number;
  spns: string[];
};

export const BrigTimer = (props: unknown) => {
  const { act, data } = useBackend<BrigTimerData>();
  data.nameText = data.occupant || '---';
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
    <Window width={500} height={!data.timing ? 430 : 280}>
      <Window.Content>
        <Section title="Информация о камере">
          <LabeledList>
            <LabeledList.Item label="Камера">{data.cell_id}</LabeledList.Item>
            <LabeledList.Item label="Заключённый">
              {data.nameText}
            </LabeledList.Item>
            <LabeledList.Item label="Обвинения">{data.crimes}</LabeledList.Item>
            <LabeledList.Item label="Заключил">
              {data.brigged_by}
            </LabeledList.Item>
            <LabeledList.Item label="Время заключения">
              {data.time_set}
            </LabeledList.Item>
            <LabeledList.Item label="Оставшееся время">
              {data.time_left}
            </LabeledList.Item>
            <LabeledList.Item label="Действия">
              <>
                <Button
                  icon="lightbulb-o"
                  disabled={!data.isAllowed}
                  onClick={() => act('flash')}
                >
                  Ослепить флешером
                </Button>
                <Button
                  icon="angle-up"
                  disabled={!data.timing || !data.isAllowed}
                  onClick={() => act('add_timer')}
                >
                  Добавить время
                </Button>
                <Button
                  icon="sync"
                  disabled={!data.timing || !data.isAllowed}
                  onClick={() => act('restart_timer')}
                >
                  Перезапустить таймер
                </Button>
                <Button
                  icon="eject"
                  disabled={!data.timing || !data.isAllowed}
                  onClick={() => act('stop')}
                >
                  Освободить заключённого
                </Button>
              </>
            </LabeledList.Item>
          </LabeledList>
        </Section>
        {!data.timing && (
          <Section title="Новый заключённый">
            <LabeledList>
              <LabeledList.Item label="Имя заключённого">
                <Button
                  icon={nameIcon}
                  disabled={!data.isAllowed}
                  onClick={() => act('prisoner_name')}
                >
                  {data.prisoner_name ? data.prisoner_name : '-----'}
                </Button>
                {!!data.spns.length && (
                  <Dropdown
                    disabled={!data.isAllowed || !data.spns.length}
                    options={data.spns}
                    selected={data.prisoner_name}
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
                  disabled={!data.isAllowed}
                  onClick={() => act('prisoner_charge')}
                >
                  {data.prisoner_charge ? data.prisoner_charge : '-----'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Время заключения">
                <Button
                  icon="pencil-alt"
                  disabled={!data.isAllowed}
                  onClick={() => act('prisoner_time')}
                >
                  {data.prisoner_time ? data.prisoner_time : '-----'}
                </Button>
              </LabeledList.Item>
              <LabeledList.Item label="Приговорить">
                <Button
                  icon="gavel"
                  disabled={
                    !data.prisoner_name ||
                    !data.prisoner_charge ||
                    !data.prisoner_time ||
                    data.prisoner_time < 0 ||
                    data.prisoner_time > 60 ||
                    !data.isAllowed
                  }
                  onClick={() => act('start')}
                >
                  Приговорить
                </Button>
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
