import { NoticeBox, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { useBackend } from '../backend';
import { OvermapFrame, OvermapRail } from './overmap/OvermapChrome';
import { OvermapScope, type OvermapScopeData } from './overmap/OvermapScope';
import { RadarViewport } from './overmap/RadarViewport';

type Data = OvermapScopeData & {
  linked: BooleanLike;
  vessel_name: string;
  status: string;
  x: number;
  y: number;
  sector_name: string;
  map_jammed: BooleanLike;
};

export const OvermapMonitor = () => {
  const { act, data } = useBackend<Data>();
  const { linked, vessel_name, status, x, y, sector_name, map_jammed } = data;
  return (
    <OvermapFrame
      title="Тактический радар"
      width={1040}
      height={820}
      linked={linked}
      onRelink={() => act('relink')}
      rail={
        <OvermapRail
          name={vessel_name || 'Тактический радар'}
          sector={sector_name}
          xy={linked ? `${x}:${y}` : undefined}
          lamps={[{ label: status || 'оффлайн', on: !!linked }]}
        />
      }
      actions={
        <div className="OvermapScopeLegend">
          <span>че сюда писать придумать надо</span>
        </div>
      }
    >
      <Section
        fill
        fitted
        className="OvermapMapSection OvermapScopePanel"
        title="Обстановка сектора"
      >
        <RadarViewport>
          {map_jammed && !data.radar_locked ? (
            <NoticeBox danger>Связь потеряна.</NoticeBox>
          ) : (
            <OvermapScope data={data} />
          )}
        </RadarViewport>
      </Section>
    </OvermapFrame>
  );
};
