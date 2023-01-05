import { useBackend } from '../backend';
import { LabeledList, Section, ProgressBar, Button } from '../components';
import { Window } from '../layouts';
import { Fragment } from 'inferno';

const stats = [
  ['good', 'Функционирует'],
  ['average', 'Критический'],
  ['bad', '@?&%ОШИБКА%&?@'],
];

export const BluespaceRiftServer = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    servers,
    scanners,
    brs_can_give_reward,
    brs_server_points_goal,
    brs_server_points_goal_max,
    brs_server_points_goal_percentage,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>

        <Section title="Исследование Разлома"
          buttons={(
            <Fragment>
              <Button
                icon="download"
                content="Стимуляция"
                onClick={() => act('luck')}
              />
              <Button
                icon="upload"
                content="Результат"
                disabled={brs_server_points_goal_percentage < 100 || !brs_can_give_reward}
                onClick={() => act('give_reward')}
              />
            </Fragment>
          )}>
          <ProgressBar
            color={brs_server_points_goal_percentage >= 100 ? 'good': 'average'}
            value={brs_server_points_goal}
            maxValue={brs_server_points_goal_max}>
            {brs_server_points_goal_percentage} %
          </ProgressBar>
        </Section>

        {
          <Section title="Сеть Серверов">
            <LabeledList>
              {servers.map(s => (
                <LabeledList.Item key={s.id} label={"Сервер #" + s.id} color={stats[s.stat][0]}>
                  {stats[s.stat][1] + ", "}
                  {s.active ? "Активный, " : "Неактивный, "}
                  {"Очков: " + s.points}
                  {" "}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        }

        {
          <Section title="Сеть Сканеров">
            <LabeledList>
              {scanners.map(s => (
                <LabeledList.Item key={s.id} label={"Сканнер #" + s.id} color={stats[s.stat][0]}>
                  {stats[s.stat][1] + ", "}
                  {s.toggle ? "Включен, " : "Отключен, "}
                  {s.active ? "Активный" : "Неактивный"}
                  {" "}
                </LabeledList.Item>
              ))}
            </LabeledList>
          </Section>
        }

      </Window.Content>
    </Window>
  );
};
