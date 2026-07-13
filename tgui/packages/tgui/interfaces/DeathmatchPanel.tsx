import {
  Button,
  Dropdown,
  Icon,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tooltip,
} from '../components';
import type { BooleanLike } from 'common/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Lobby = {
  name: string;
  players: number;
  max_players: number;
  map: string;
  playing: BooleanLike;
};

type Data = {
  hosting: BooleanLike;
  admin: BooleanLike;
  playing: string;
  lobbies: Lobby[];
};

export const DeathmatchPanel = (props) => {
  const { act, data } = useBackend<Data>();
  const { hosting } = data;

  return (
    <Window title="Deathmatch Lobbies" width={360} height={400}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <NoticeBox danger>
              Если ваше тело все еще в раунде, вы в теории сможете вернуться в
              него после игры, но это не гарантируется!
            </NoticeBox>
          </Stack.Item>
          <Stack.Item grow>
            <LobbyPane />
          </Stack.Item>
          <Stack.Item>
            <Button
              disabled={!!hosting}
              fluid
              textAlign="center"
              color="good"
              onClick={() => act('host')}
            >
              Создать лобби
            </Button>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const LobbyPane = (props) => {
  const { data } = useBackend<Data>();
  const { lobbies = [] } = data;

  return (
    <Section fill scrollable>
      <Table>
        <Table.Row header>
          <Table.Cell>Хост</Table.Cell>
          <Table.Cell>Карта</Table.Cell>
          <Table.Cell>
            <Tooltip content="Количество игроков">
              <Icon name="users" />
            </Tooltip>
          </Table.Cell>
          <Table.Cell align="center">
            <Icon name="hammer" />
          </Table.Cell>
        </Table.Row>

        {lobbies.length === 0 && (
          <Table.Row>
            <Table.Cell colSpan={4}>
              <NoticeBox textAlign="center">
                Лобби не найдены. Создайте новое!
              </NoticeBox>
            </Table.Cell>
          </Table.Row>
        )}

        {lobbies.map((lobby, index) => (
          <LobbyDisplay key={index} lobby={lobby} />
        ))}
      </Table>
    </Section>
  );
};

const LobbyDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { admin, playing, hosting } = data;
  const { lobby } = props;

  const isActive = (!!hosting || !!playing) && playing !== lobby.name;

  return (
    <Table.Row className="candystripe" key={lobby.name}>
      <Table.Cell>
        {!admin ? (
          lobby.name
        ) : (
          <Dropdown
            width={10}
            noChevron
            selected={lobby.name}
            options={['Закрыть лобби', 'Просмотр']}
            onSelected={(value) =>
              act('admin', {
                id: lobby.name,
                func: value,
              })
            }
          />
        )}
      </Table.Cell>
      <Table.Cell>{lobby.map}</Table.Cell>
      <Table.Cell collapsing>
        {lobby.players}/{lobby.max_players}
      </Table.Cell>
      <Table.Cell collapsing>
        {!lobby.playing ? (
          <Button
            disabled={isActive}
            color="good"
            onClick={() => act('join', { id: lobby.name })}
            width="100%"
            textAlign="center"
          >
            {playing === lobby.name ? 'войти' : 'зайти'}
          </Button>
        ) : (
          <Button
            disabled={isActive}
            color="good"
            onClick={() => act('spectate', { id: lobby.name })}
          >
            Spectate
          </Button>
        )}
      </Table.Cell>
    </Table.Row>
  );
};
