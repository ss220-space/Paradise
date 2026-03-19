import { Box, Button, LabeledList, NoticeBox, Section } from '../components';
import { decodeHtmlEntities } from 'common/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

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
    <Window title="Дистанционное управление ботами" width={500} height={500}>
      <Window.Content scrollable>
        <RemoteRobotControlContent />
      </Window.Content>
    </Window>
  );
};

export const RemoteRobotControlContent = (props) => {
  const { act, data } = useBackend<Data>();
  const { robots = [] } = data;
  if (!robots.length) {
    return (
      <Section>
        <NoticeBox textAlign="center">Ботов не обнаружено</NoticeBox>
      </Section>
    );
  }
  return robots.map((robot) => {
    return (
      <Section
        key={robot.ref}
        title={`${robot.name} (${robot.model})`}
        buttons={
          <>
            <Button
              icon="tools"
              onClick={() =>
                act('interface', {
                  ref: robot.ref,
                })
              }
            >
              Интерфейс
            </Button>
            <Button
              icon="phone-alt"
              onClick={() =>
                act('callbot', {
                  ref: robot.ref,
                })
              }
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
                decodeHtmlEntities(robot.mode) === 'Inactive'
                  ? 'bad'
                  : decodeHtmlEntities(robot.mode) === 'Idle'
                    ? 'average'
                    : 'good'
              }
            >
              {decodeHtmlEntities(robot.mode)}
            </Box>{' '}
            {(robot.hacked && (
              <Box inline color="bad">
                (ВЗЛОМАН)
              </Box>
            )) ||
              ''}
          </LabeledList.Item>
          <LabeledList.Item label="Локация">{robot.location}</LabeledList.Item>
        </LabeledList>
      </Section>
    );
  });
};
