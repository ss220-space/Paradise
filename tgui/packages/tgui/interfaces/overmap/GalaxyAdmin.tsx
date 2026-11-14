import { useState } from 'react';
import {
  Box,
  Button,
  Dropdown,
  Input,
  LabeledList,
  NoticeBox,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../../backend';
import { GalaxyMarkerEditor } from './GalaxyMarkerEditor';
import type { GalaxyMap, GalaxyMarkerStyle } from './galaxyTypes';
import { OvermapGalaxy } from './OvermapGalaxy';

type System = {
  id: string;
  name: string;
  x: number;
  y: number;
  transit: BooleanLike;
  marker?: GalaxyMarkerStyle;
};
type Route = {
  id: string;
  from: string;
  to: string;
  enabled: BooleanLike;
  present: BooleanLike;
  style?: { color?: string; line?: string; width?: number; opacity?: number };
};
type Poi = {
  id: string;
  name: string;
  x: number;
  y: number;
  marker?: GalaxyMarkerStyle;
};
type Data = {
  galaxy?: {
    systems: System[];
    links: Route[];
    pois: Poi[];
    preview?: GalaxyMap;
  };
  galaxy_feedback?: string;
  galaxy_failed?: BooleanLike;
};

const Coordinates = (props: {
  x: number;
  y: number;
  onX: (value: number) => void;
  onY: (value: number) => void;
}) => (
  <Stack>
    <Stack.Item>
      X{' '}
      <NumberInput
        value={props.x}
        minValue={-100}
        maxValue={100}
        step={0.001}
        width="100px"
        onChange={props.onX}
      />
    </Stack.Item>
    <Stack.Item>
      Y{' '}
      <NumberInput
        value={props.y}
        minValue={-100}
        maxValue={100}
        step={0.001}
        width="100px"
        onChange={props.onY}
      />
    </Stack.Item>
    <Stack.Item>св. лет</Stack.Item>
  </Stack>
);

export const GalaxyAdmin = () => {
  const { act, data } = useBackend<Data>();
  const systems = data.galaxy?.systems || [];
  const physical = systems.filter((system) => !system.transit);
  const options = physical.map((system) => ({
    value: system.id,
    displayText: system.name,
  }));
  const [editId, setEditId] = useState('');
  const [name, setName] = useState('');
  const [x, setX] = useState(0);
  const [y, setY] = useState(0);
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [restricted, setRestricted] = useState(false);
  const [marker, setMarker] = useState<GalaxyMarkerStyle>({ shape: 'circle' });
  const [poiMarker, setPoiMarker] = useState<GalaxyMarkerStyle>({
    shape: 'diamond',
  });
  const [poiId, setPoiId] = useState('');
  const [routeId, setRouteId] = useState('');
  const [line, setLine] = useState('solid');
  const [lineColor, setLineColor] = useState('#b98cfa');
  const [lineWidth, setLineWidth] = useState(2);
  const [lineOpacity, setLineOpacity] = useState(0.85);
  const [poiName, setPoiName] = useState('');
  const [poiX, setPoiX] = useState(0);
  const [poiY, setPoiY] = useState(0);
  return (
    <>
      {!!data.galaxy_feedback && (
        <NoticeBox danger={!!data.galaxy_failed}>
          {data.galaxy_feedback}
        </NoticeBox>
      )}
      <Section
        title="Галактическая карта"
        buttons={
          <>
            <Button
              icon="map"
              selected={!!data.galaxy?.preview}
              onClick={() => act('galaxy_preview')}
            >
              {data.galaxy?.preview ? 'Скрыть карту' : 'Просмотр карты'}
            </Button>
            <Button icon="save" onClick={() => act('galaxy_save')}>
              Сохранить для следующих запусков
            </Button>
          </>
        }
      >
        <Box color="label">
          Изменения применяются к текущему раунду. Сохранение обновляет
          конфигурацию галактики.
        </Box>
      </Section>
      {!!data.galaxy?.preview && (
        <Section title="Просмотр галактической карты">
          <Box height="600px" position="relative">
            <OvermapGalaxy galaxy={data.galaxy.preview} />
          </Box>
        </Section>
      )}
      <Section title="Секторы">
        <LabeledList>
          <LabeledList.Item label="Сектор">
            <Dropdown
              width="100%"
              options={[{ value: '', displayText: 'Новый сектор' }, ...options]}
              selected={editId}
              displayText={
                physical.find((entry) => entry.id === editId)?.name ||
                'Новый сектор'
              }
              onSelected={(id) => {
                setEditId(id);
                const system = physical.find((entry) => entry.id === id);
                setName(system?.name || '');
                setMarker(system?.marker || { shape: 'circle' });
                setX(system?.x || 0);
                setY(system?.y || 0);
              }}
            />
          </LabeledList.Item>
          <LabeledList.Item label="Название">
            <Input fluid value={name} onChange={setName} />
          </LabeledList.Item>
          <LabeledList.Item label="Положение">
            <Coordinates x={x} y={y} onX={setX} onY={setY} />
          </LabeledList.Item>
        </LabeledList>
        <GalaxyMarkerEditor value={marker} onChange={setMarker} />
        <Box mt={1}>
          <Button
            icon={editId ? 'pen' : 'plus'}
            disabled={!name.trim()}
            onClick={() =>
              act(editId ? 'galaxy_edit_sector' : 'galaxy_add_sector', {
                id: editId,
                name,
                x,
                y,
                marker,
              })
            }
          >
            {editId ? 'Применить изменения' : 'Создать сектор'}
          </Button>
        </Box>
        <Box mt={1}>
          {systems.map((system) => (
            <Box key={system.id}>
              {system.name} · {system.x}, {system.y} св. лет
              {system.transit ? ' · транзит' : ''}
            </Box>
          ))}
        </Box>
      </Section>
      <Section title="Гиперпространственные связи">
        <Stack>
          <Stack.Item grow>
            <Dropdown
              fluid
              options={options}
              selected={from}
              displayText={physical.find((entry) => entry.id === from)?.name}
              placeholder="Первый сектор"
              onSelected={setFrom}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Dropdown
              fluid
              options={options}
              selected={to}
              displayText={physical.find((entry) => entry.id === to)?.name}
              placeholder="Второй сектор"
              onSelected={setTo}
            />
          </Stack.Item>
        </Stack>
        <Box mt={1}>
          <Button.Checkbox
            checked={restricted}
            onClick={() => setRestricted(!restricted)}
          >
            Ограниченный доступ
          </Button.Checkbox>
          <Button
            icon="link"
            disabled={!from || !to || from === to}
            onClick={() => act('galaxy_add_link', { from, to, restricted })}
          >
            Создать связь
          </Button>
        </Box>
        <Section mt={1} title="Оформление связи">
          <Dropdown
            fluid
            selected={routeId}
            displayText={
              (data.galaxy?.links || []).find((route) => route.id === routeId)
                ? `${data.galaxy!.links.find((route) => route.id === routeId)!.from} ↔ ${data.galaxy!.links.find((route) => route.id === routeId)!.to}`
                : undefined
            }
            placeholder="Выберите маршрут"
            options={(data.galaxy?.links || []).map((route) => ({
              value: route.id,
              displayText: `${route.from} ↔ ${route.to}`,
            }))}
            onSelected={(id) => {
              setRouteId(id);
              const style = data.galaxy?.links.find(
                (route) => route.id === id,
              )?.style;
              setLine(style?.line || 'solid');
              setLineColor(style?.color || '#b98cfa');
              setLineWidth(style?.width ?? 2);
              setLineOpacity(style?.opacity ?? 0.85);
            }}
          />
          <LabeledList>
            <LabeledList.Item label="Линия">
              <Dropdown
                selected={line}
                displayText={
                  {
                    solid: 'Сплошная',
                    dashed: 'Штриховая',
                    dotted: 'Точечная',
                    'dash-dot': 'Штрихпунктир',
                  }[line]
                }
                options={[
                  ['solid', 'Сплошная'],
                  ['dashed', 'Штриховая'],
                  ['dotted', 'Точечная'],
                  ['dash-dot', 'Штрихпунктир'],
                ].map(([value, displayText]) => ({ value, displayText }))}
                onSelected={setLine}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Цвет">
              <input
                type="color"
                value={lineColor}
                onChange={(event) => setLineColor(event.target.value)}
              />
              <Input width="100px" value={lineColor} onChange={setLineColor} />
            </LabeledList.Item>
            <LabeledList.Item label="Толщина">
              <NumberInput
                value={lineWidth}
                minValue={0.5}
                maxValue={8}
                step={0.5}
                onChange={setLineWidth}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Непрозрачность">
              <NumberInput
                value={lineOpacity}
                minValue={0}
                maxValue={1}
                step={0.05}
                onChange={setLineOpacity}
              />
            </LabeledList.Item>
          </LabeledList>
          <Button
            mt={1}
            icon="paint-brush"
            disabled={!routeId}
            onClick={() =>
              act('galaxy_edit_link', {
                id: routeId,
                line,
                color: lineColor,
                width: lineWidth,
                opacity: lineOpacity,
              })
            }
          >
            Применить оформление
          </Button>
        </Section>
        {(data.galaxy?.links || []).map((route) => (
          <Box key={route.id} mt={1}>
            <Button
              icon={route.enabled ? 'power-off' : 'play'}
              color={route.enabled ? 'good' : 'bad'}
              disabled={!route.present}
              onClick={() => act('galaxy_toggle_link', { id: route.id })}
            >
              {route.present
                ? route.enabled
                  ? 'Включён'
                  : 'Отключён'
                : 'Нет гипертрансляторов'}
            </Button>{' '}
            {route.from} ↔ {route.to}
          </Box>
        ))}
      </Section>
      <Section title="Точки интереса">
        <Dropdown
          fluid
          selected={poiId}
          displayText={
            data.galaxy?.pois.find((poi) => poi.id === poiId)?.name ||
            'Новая точка интереса'
          }
          options={[
            { value: '', displayText: 'Новая точка интереса' },
            ...(data.galaxy?.pois || []).map((poi) => ({
              value: poi.id,
              displayText: poi.name,
            })),
          ]}
          onSelected={(id) => {
            setPoiId(id);
            const poi = data.galaxy?.pois.find((entry) => entry.id === id);
            setPoiName(poi?.name || '');
            setPoiX((poi?.x || 0) / 1000);
            setPoiY((poi?.y || 0) / 1000);
            setPoiMarker(poi?.marker || { shape: 'diamond' });
          }}
        />
        <LabeledList>
          <LabeledList.Item label="Название">
            <Input fluid value={poiName} onChange={setPoiName} />
          </LabeledList.Item>
          <LabeledList.Item label="Положение">
            <Coordinates x={poiX} y={poiY} onX={setPoiX} onY={setPoiY} />
          </LabeledList.Item>
        </LabeledList>
        <GalaxyMarkerEditor value={poiMarker} onChange={setPoiMarker} />
        <Button
          mt={1}
          icon={poiId ? 'pen' : 'plus'}
          disabled={!poiName.trim()}
          onClick={() =>
            act(poiId ? 'galaxy_edit_poi' : 'galaxy_add_poi', {
              id: poiId,
              name: poiName,
              x: poiX,
              y: poiY,
              marker: poiMarker,
            })
          }
        >
          {poiId ? 'Обновить точку интереса' : 'Добавить точку интереса'}
        </Button>
        {(data.galaxy?.pois || []).map((poi) => (
          <Box key={poi.id} mt={1}>
            <Button
              icon="trash"
              color="bad"
              onClick={() => act('galaxy_remove_poi', { id: poi.id })}
            />{' '}
            {poi.name} · {poi.x / 1000}, {poi.y / 1000} св. лет
          </Box>
        ))}
      </Section>
    </>
  );
};
