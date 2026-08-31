import { ByondUi, NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { OvermapFrame, OvermapRail } from './overmap/OvermapChrome';

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
};

export const OvermapMonitor = () => {
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
  } = data;

  return (
    <OvermapFrame
      title="Монитор овермапы"
      width={map_px_w + 48}
      height={map_px_h + 96}
      linked={linked}
      onRelink={() => act('relink')}
      rail={
        <OvermapRail
          name={vessel_name || 'Монитор'}
          sector={sector_name}
          xy={linked ? `${x}:${y}` : undefined}
          lamps={[{ label: status || 'оффлайн', on: !!linked }]}
        />
      }
    >
      <Section
        fill
        fitted
        className="OvermapMapSection"
        title={`Только просмотр, ${map_tiles_x}×${map_tiles_y}`}
      >
        <div
          className="OvermapMinimap OvermapMinimap--exact"
          style={{ width: `${map_px_w}px`, height: `${map_px_h}px` }}
        >
          {map_jammed ? (
            <NoticeBox danger>Связь с овермапом потеряна.</NoticeBox>
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
    </OvermapFrame>
  );
};
