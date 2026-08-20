import { useState } from 'react';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  ColorBox,
  Input,
  NanoMap,
  Section,
  Stack,
  Tabs,
} from '../components';
import { Window } from '../layouts';

const STATUS_PENDING = 0;
const STATUS_ACTIVE = 1;
const STATUS_PAUSED = 2;

type WantedItem = {
  name: string;
  amount: number;
  original?: number;
};

type Request = {
  uid: string;
  num: number;
  status: number;
  net_id: number;
  net_name: string;
  net_color: string;
  source: string;
  dest: string;
  wanted: WantedItem[];
  creator?: string;
};

type NetNode = {
  uid: string;
  name: string;
  mode: string;
  allow_export: boolean;
  fill_percent?: number | null;
};

type Network = {
  uid: string;
  id: number;
  name: string;
  color: string;
  auto_execute: boolean;
  pipes: number;
  interfaces: number;
  requests: number;
  nodes: NetNode[];
};

type MapNode = {
  uid: string;
  name: string;
  mode: string;
  allow_export: boolean;
  net_id: number;
  net_color: string;
  x: number;
  y: number;
  z: number;
};

type MapPipe = {
  x1: number;
  y1: number;
  x2: number;
  y2: number;
  z: number;
  net_color: string;
};

type LogLine = {
  net_id: number;
  net_name: string;
  text: string;
};

type Archived = Request & {
  result?: string;
  finished_at?: string;
};

type LogisticsCoreData = {
  networks: Network[];
  requests: Request[];
  logs: LogLine[];
  archived: Archived[];
  map_nodes: MapNode[];
  map_pipes: MapPipe[];
  stationLevelNum: number[];
  stationLevelName: string[];
};

const PIXELS_PER_TURF = 2;

export const LogisticsCore = (_props: unknown) => {
  const { data } = useBackend<LogisticsCoreData>();
  const [tab, setTab] = useState(0);
  const levels = data.stationLevelNum || [];

  return (
    <Window width={1000} height={720}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                icon="clipboard-list"
                selected={tab === 0}
                onClick={() => setTab(0)}
              >
                Запросы
              </Tabs.Tab>
              <Tabs.Tab
                icon="map"
                selected={tab === 1}
                onClick={() => setTab(1)}
              >
                Карта
              </Tabs.Tab>
              <Tabs.Tab
                icon="network-wired"
                selected={tab === 2}
                onClick={() => setTab(2)}
              >
                Сети
              </Tabs.Tab>
              <Tabs.Tab
                icon="scroll"
                selected={tab === 3}
                onClick={() => setTab(3)}
              >
                Логи
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {tab === 0 && <RequestsTab />}
            {tab === 1 && <MapTab levels={levels} />}
            {tab === 2 && <NetworksTab />}
            {tab === 3 && <LogsTab />}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RequestsTab = () => {
  const { act, data } = useBackend<LogisticsCoreData>();
  const { requests = [] } = data;

  return (
    <Section fill scrollable title="Активные заказы">
      {!requests.length && (
        <Box color="average">Нет заказов в логистических сетях.</Box>
      )}
      {requests.map((request) => {
        const netRequests = requests.filter((r) => r.net_id === request.net_id);
        const localIndex = netRequests.findIndex((r) => r.uid === request.uid);
        return (
        <Box
          key={request.uid}
          mb={1}
          p={1}
          style={{
            border:
              request.status === STATUS_ACTIVE
                ? '2px solid #2ecc71'
                : '1px solid rgba(255,255,255,0.15)',
            borderRadius: '4px',
          }}
        >
          <Stack align="center">
            <Stack.Item>
              <Stack vertical>
                <Button
                  icon="arrow-up"
                  disabled={localIndex <= 0}
                  onClick={() =>
                    act('move_request', { uid: request.uid, dir: -1 })
                  }
                />
                <Button
                  icon="arrow-down"
                  disabled={localIndex >= netRequests.length - 1}
                  onClick={() =>
                    act('move_request', { uid: request.uid, dir: 1 })
                  }
                />
              </Stack>
            </Stack.Item>
            <Stack.Item grow>
              <Box>
                <ColorBox color={request.net_color} mr={1} />
                <b>Заказ #{request.num}</b> · {request.net_name} (#
                {request.net_id})
                {request.creator ? ` · ${request.creator}` : ''}
              </Box>
              <Box>
                {request.source} → {request.dest}
              </Box>
              <Box color="label">
                {request.wanted
                  .map((item) => `${item.name} ×${item.amount}`)
                  .join(', ')}
              </Box>
              <Box color="label" fontSize="0.85em">
                {request.status === STATUS_ACTIVE
                  ? 'Выполняется'
                  : request.status === STATUS_PAUSED
                    ? 'Пауза'
                    : 'Ожидает'}
              </Box>
            </Stack.Item>
            <Stack.Item>
              {(request.status === STATUS_PENDING ||
                request.status === STATUS_PAUSED) && (
                <Button
                  icon="play"
                  color="good"
                  onClick={() => act('execute_request', { uid: request.uid })}
                >
                  Выполнить
                </Button>
              )}
              {request.status === STATUS_ACTIVE && (
                <Button
                  icon="pause"
                  onClick={() => act('pause_request', { uid: request.uid })}
                >
                  Пауза
                </Button>
              )}
              <Button
                icon="times"
                color="bad"
                onClick={() => act('cancel_request', { uid: request.uid })}
              >
                Отмена
              </Button>
            </Stack.Item>
          </Stack>
        </Box>
        );
      })}
    </Section>
  );
};

const MapTab = (props: { levels: number[] }) => {
  const { act, data } = useBackend<LogisticsCoreData>();
  const { map_nodes = [], map_pipes = [], stationLevelNum = [], stationLevelName = [] } =
    data;
  const [zoom, setZoom] = useState(1);
  const [zCurrent, setZCurrent] = useState(props.levels[0] || stationLevelNum[0]);

  return (
    <Section fill title="Карта логистики">
      <Box height="100%" style={{ display: 'flex' }}>
        <NanoMap
          onZoom={(_e, value) => setZoom(value)}
          zLevels={stationLevelNum}
          zNames={stationLevelName}
          zCurrent={zCurrent}
          setZCurrent={setZCurrent}
        >
          {map_pipes
            .filter((pipe) => pipe.z === zCurrent)
            .map((pipe, index) => (
              <PipeSegment
                key={index}
                pipe={pipe}
                zoom={zoom}
                z_current={zCurrent}
              />
            ))}
          {map_nodes.map((node) => (
            <InterfaceMarker
              key={node.uid}
              node={node}
              zoom={zoom}
              z_current={zCurrent}
              onClick={() => act('rename_interface', { uid: node.uid })}
            />
          ))}
        </NanoMap>
      </Box>
    </Section>
  );
};

const PipeSegment = (props: {
  pipe: MapPipe;
  zoom: number;
  z_current: number;
}) => {
  const { pipe, zoom, z_current } = props;
  if (pipe.z !== z_current) {
    return null;
  }
  const ppt = PIXELS_PER_TURF * zoom;
  const mapPx = 510 * zoom;
  const x1 = (pipe.x1 - 1) * ppt + ppt / 2;
  const y1 = (pipe.y1 - 1) * ppt + ppt / 2;
  const x2 = (pipe.x2 - 1) * ppt + ppt / 2;
  const y2 = (pipe.y2 - 1) * ppt + ppt / 2;
  return (
    <svg
      style={{
        position: 'absolute',
        left: 0,
        bottom: 0,
        width: mapPx,
        height: mapPx,
        pointerEvents: 'none',
        overflow: 'visible',
      }}
    >
      <line
        x1={x1}
        y1={mapPx - y1}
        x2={x2}
        y2={mapPx - y2}
        stroke={pipe.net_color}
        strokeWidth={Math.max(2, zoom)}
        strokeLinecap="round"
        opacity={0.85}
      />
    </svg>
  );
};

const InterfaceMarker = (props: {
  node: MapNode;
  zoom: number;
  z_current: number;
  onClick: () => void;
}) => {
  const { node, zoom, z_current, onClick } = props;
  const size = Math.max(8, PIXELS_PER_TURF * zoom + 4);
  const isSend = node.mode === 'send';
  const filled = isSend || node.allow_export;

  return (
    <NanoMap.Marker
      x={node.x}
      y={node.y}
      z={node.z}
      z_current={z_current}
      zoom={zoom}
      tooltip={`${node.name} (${isSend ? 'отправка' : 'приём'})`}
      onClick={onClick}
    >
      <Box
        style={{
          width: `${size}px`,
          height: `${size}px`,
          backgroundColor: filled ? node.net_color : 'transparent',
          border: `2px solid ${node.net_color}`,
          borderRadius: isSend ? '2px' : '50%',
          position: 'relative',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
          boxSizing: 'border-box',
        }}
      />
    </NanoMap.Marker>
  );
};

const NetworksTab = () => {
  const { act, data } = useBackend<LogisticsCoreData>();
  const { networks = [] } = data;

  return (
    <Section fill scrollable title="Логистические сети">
      {!networks.length && (
        <Box color="average">Сетей пока нет. Постройте трубы.</Box>
      )}
      {networks.map((net) => (
        <Box
          key={net.uid}
          mb={1}
          p={1}
          style={{
            border: `1px solid ${net.color}`,
            borderRadius: '4px',
          }}
        >
          <Stack align="center">
            <Stack.Item>
              <ColorBox color={net.color} />
            </Stack.Item>
            <Stack.Item grow>
              <Box bold>
                {net.name} <Box inline color="label">#{net.id}</Box>
              </Box>
              <Box color="label">
                Труб: {net.pipes} · Интерфейсов: {net.interfaces} · Заказов:{' '}
                {net.requests}
              </Box>
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="pen"
                onClick={() => act('set_net_name', { uid: net.uid })}
              >
                Имя
              </Button>
              <Button.Checkbox
                checked={net.auto_execute}
                onClick={() => act('toggle_auto_execute', { uid: net.uid })}
              >
                Автовыполнение
              </Button.Checkbox>
            </Stack.Item>
          </Stack>
          <Stack mt={0.5} wrap>
            {(
              [
                '#e74c3c',
                '#e67e22',
                '#f1c40f',
                '#2ecc71',
                '#1abc9c',
                '#3498db',
                '#9b59b6',
                '#e91e63',
              ] as const
            ).map((color) => (
              <Stack.Item key={color}>
                <Button
                  selected={net.color === color}
                  onClick={() =>
                    act('set_net_color', { uid: net.uid, color })
                  }
                >
                  <ColorBox color={color} />
                </Button>
              </Stack.Item>
            ))}
          </Stack>
          {!!net.nodes?.length && (
            <Box mt={0.5} color="label">
              Узлы:{' '}
              {net.nodes
                .map(
                  (node) =>
                    `${node.name} (${node.mode === 'send' ? 'отправка' : 'приём'})`
                )
                .join(', ')}
            </Box>
          )}
        </Box>
      ))}
    </Section>
  );
};

const LogsTab = () => {
  const { data } = useBackend<LogisticsCoreData>();
  const { logs = [], archived = [] } = data;
  const [filter, setFilter] = useState('');

  const filteredLogs = logs.filter((line) =>
    `${line.net_name} ${line.text}`.toLowerCase().includes(filter.toLowerCase())
  );

  return (
    <Stack fill vertical>
      <Stack.Item grow basis="55%">
        <Section
          fill
          scrollable
          title="Журнал"
          buttons={
            <Input
              width={16}
              placeholder="Фильтр..."
              expensive
              value={filter}
              onChange={setFilter}
            />
          }
        >
          {!filteredLogs.length && (
            <Box color="average">Записей пока нет.</Box>
          )}
          {filteredLogs
            .slice()
            .reverse()
            .map((line, index) => (
              <Box key={index} mb={0.3}>
                <Box inline color="label">
                  [{line.net_name}]
                </Box>{' '}
                {line.text}
              </Box>
            ))}
        </Section>
      </Stack.Item>
      <Stack.Item grow basis="45%">
        <Section fill scrollable title="Завершённые заказы">
          {!archived.length && (
            <Box color="average">Ещё нет завершённых заказов.</Box>
          )}
          {archived.map((entry, index) => (
            <Box key={`${entry.uid}-${index}`} mb={0.5}>
              <ColorBox color={entry.net_color} mr={1} />
              <b>#{entry.num}</b> {entry.source} → {entry.dest} ·{' '}
              <Box inline color={entry.result === 'выполнен' ? 'good' : 'bad'}>
                {entry.result}
              </Box>
              <Box color="label" fontSize="0.85em">
                {entry.wanted
                  ?.map((item) => `${item.name} ×${item.original || item.amount}`)
                  .join(', ')}
                {entry.finished_at ? ` · ${entry.finished_at}` : ''}
              </Box>
            </Box>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
