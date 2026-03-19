import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Dropdown,
} from '../components';
import { decodeHtmlEntities } from 'common/string';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { useState, useMemo } from 'react';

interface RobotData {
  ref: string;
  name: string;
  model: string;
  mode: string;
  hacked: boolean;
  location: string;
}

interface Data {
  robots: RobotData[];
}

export const RemoteRobotControl = (props) => {
  return (
    <Window width={500} height={500}>
      <Window.Content scrollable>
        <RemoteRobotControlContent />
      </Window.Content>
    </Window>
  );
};

export const RemoteRobotControlContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { robots = [] } = data;

  const [selectedType, setSelectedType] = useState<string>('');

  const typeOptions = useMemo(() => {
    const types = robots.map((robot) => robot.model);
    return Array.from(new Set(types));
  }, [robots]);

  const filteredRobots = useMemo(() => {
    if (selectedType === '') return robots;
    return robots.filter((robot) => robot.model === selectedType);
  }, [robots, selectedType]);

  if (!robots.length) {
    return (
      <Section>
        <NoticeBox textAlign="center">Ботов не обнаружено</NoticeBox>
      </Section>
    );
  }

  return (
    <>
      <Section>
        <Dropdown
          options={[
            { value: '', displayText: 'Все' },
            ...typeOptions.map((type) => ({
              value: type,
              displayText: type,
            })),
          ]}
          selected={selectedType}
          onSelected={setSelectedType}
          width="100%"
          placeholder="Выбрать тип бота для сортировки..."
        />
      </Section>

      {filteredRobots.map((robot) => (
        <Section
          key={robot.ref}
          title={`${robot.name} (${robot.model})`}
          buttons={
            <>
              <Button
                icon="tools"
                onClick={() => act('interface', { ref: robot.ref })}
              >
                Интерфейс
              </Button>
              <Button
                icon="phone-alt"
                onClick={() => act('callbot', { ref: robot.ref })}
              >
                Вызвать
              </Button>
            </>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Статус">
              <Box
                inline
                color={
                  decodeHtmlEntities(robot.mode) === 'Отключён'
                    ? 'bad'
                    : decodeHtmlEntities(robot.mode) === 'Бездействие'
                      ? 'average'
                      : 'good'
                }
              >
                {decodeHtmlEntities(robot.mode)}
              </Box>{' '}
              {!!robot.hacked && (
                <Box inline color="bad">
                  (ВЗЛОМАН)
                </Box>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Локация">
              {robot.location}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
    </>
  );
};
