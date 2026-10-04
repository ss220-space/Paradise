import { Box, Button, ByondUi, NoticeBox, Section, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { OvermapFrame, OvermapRail } from './overmap/OvermapChrome';

type ProgrammedRoute = {
  id: string;
  name: string;
  selected: BooleanLike;
};

type Data = {
  linked: BooleanLike;
  mapRef: string;
  map_zoom: number;
  map_tiles_x?: number;
  map_tiles_y?: number;
  map_px_w?: number;
  map_px_h?: number;
  vessel_name: string;
  status: string;
  x: number;
  y: number;
  sector_name: string;
  map_jammed: BooleanLike;
  programmed_locked?: BooleanLike;
  programmed_emagged?: BooleanLike;
  programmed_has_routes?: BooleanLike;
  programmed_busy?: BooleanLike;
  programmed_windup?: number;
  programmed_eta?: string;
  programmed_selected?: string;
  programmed_routes?: ProgrammedRoute[];
  request_only?: BooleanLike;
  recall_here?: BooleanLike;
};

export const OvermapShuttleRemote = () => {
  const { act, data } = useBackend<Data>();
  const {
    linked,
    mapRef,
    map_zoom,
    map_tiles_x = 19,
    map_tiles_y = 15,
    map_px_w = 608,
    map_px_h = 480,
    vessel_name,
    status,
    x,
    y,
    sector_name,
    map_jammed,
    programmed_emagged,
    programmed_has_routes,
    programmed_busy,
    programmed_windup,
    programmed_eta,
    programmed_selected,
    programmed_routes = [],
    request_only,
    recall_here,
  } = data;

  return (
    <OvermapFrame
      title="Запрос шаттла"
      width={map_px_w + 48}
      height={map_px_h + 240}
      linked={linked}
      rail={
        <OvermapRail
          name={vessel_name || 'Шаттл'}
          sector={sector_name}
          xy={linked ? `${x}:${y}` : undefined}
          lamps={[
            { label: status || 'оффлайн', on: !!linked },
            { label: 'маршрут', on: !!programmed_busy },
          ]}
        />
      }
    >
      <Stack fill vertical>
        <Stack.Item shrink={0}>
          <Section
            fitted
            className="OvermapMapSection"
            title={map_jammed ? 'Помехи' : `Карта шаттла ${map_tiles_x}×${map_tiles_y}`}
          >
            <div
              className="OvermapMinimap OvermapMinimap--exact"
              style={{ width: `${map_px_w}px`, height: `${map_px_h}px` }}
            >
              {map_jammed ? (
                <NoticeBox danger>Связь потеряна.</NoticeBox>
              ) : (
                <ByondUi
                  height={`${map_px_h}px`}
                  width={`${map_px_w}px`}
                  params={{
                    id: mapRef,
                    type: 'map',
                    zoom: map_zoom ?? 1,
                  }}
                />
              )}
            </div>
          </Section>
        </Stack.Item>
        <Stack.Item shrink={0}>
          <Section title={request_only ? 'Вызов' : 'Маршрут'}>
            {programmed_emagged ? (
              <NoticeBox>
                Прямое управление с консоли штурвала. Удалённые команды
                игнорируются.
              </NoticeBox>
            ) : request_only ? (
              <>
                <Button
                  icon="reply"
                  color="good"
                  disabled={!!programmed_busy || !!recall_here}
                  onClick={() => act('recall_here')}
                >
                  Вызвать к себе
                </Button>
                {!!recall_here && (
                  <Box mt={1} className="OvermapRail__meta">
                    Шаттл уже у этой площадки.
                  </Box>
                )}
                {!!programmed_busy && (
                  <Box mt={1} className="OvermapRail__meta">
                    {programmed_windup
                      ? `Отправление через ${programmed_windup} с`
                      : `В пути ${programmed_eta || ''}`}
                  </Box>
                )}
              </>
            ) : !programmed_has_routes ? (
              <NoticeBox>Нет заранее заготовленных маршрутов.</NoticeBox>
            ) : (
              <>
                <Stack vertical>
                  {programmed_routes.map((route) => (
                    <Stack.Item key={route.id}>
                      <Button
                        fluid
                        selected={
                          !!route.selected || programmed_selected === route.id
                        }
                        disabled={!!programmed_busy}
                        onClick={() =>
                          act('select_programmed', { id: route.id })
                        }
                      >
                        {route.name}
                      </Button>
                    </Stack.Item>
                  ))}
                </Stack>
                <Box mt={1.5}>
                  <Button
                    icon="play"
                    color="good"
                    disabled={!programmed_routes.length || !!programmed_busy}
                    onClick={() =>
                      act('execute_programmed', { id: programmed_selected })
                    }
                  >
                    Исполнить
                  </Button>
                </Box>
                {!!programmed_busy && (
                  <Box mt={1} className="OvermapRail__meta">
                    {programmed_windup
                      ? `Отправление через ${programmed_windup} с`
                      : `В пути ${programmed_eta || ''}`}
                  </Box>
                )}
              </>
            )}
          </Section>
        </Stack.Item>
      </Stack>
    </OvermapFrame>
  );
};
