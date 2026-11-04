import { useLocalState } from '../../backend';
import {
  type GalaxyMap,
  type HazardField,
  OvermapRadar,
  type RadarContact,
  type RadarEngine,
  type RadarObject,
  type RadarPeel,
  type RadarProjectile,
  type RadarScatterChunk,
  type RadarShape,
  type RadarTerrain,
} from './OvermapRadar';

export type OvermapScopeData = {
  radar_outlines?: Record<string, string>;
  radar_show_self?: boolean | number;
  radar_locked?: boolean | number;
  radar_tick?: number;
  radar_epoch?: number;
  radar_shapes?: Record<string, RadarShape>;
  radar?: RadarContact[];
  radar_drifters?: number[][];
  radar_projectiles?: RadarProjectile[];
  radar_engines?: RadarEngine[];
  radar_terrain?: RadarTerrain;
  radar_world?: number[];
  radar_peels?: RadarPeel[];
  radar_scatter?: RadarScatterChunk[];
  objects?: RadarObject[];
  self_pos?: number[];
  sector_size?: number;
  cell_span?: number;
  sector_id?: string;
  galaxy?: GalaxyMap;
  facing?: number;
  hazard_fields?: HazardField[];
};

export const OvermapScope = ({ data }: { data: OvermapScopeData }) => {
  const [radius, setRadius] = useLocalState('scopeRadius', 1500);
  const [follow, setFollow] = useLocalState('scopeFollow', false);
  return (
    <OvermapRadar
      outlines={data.radar_outlines}
      showSelf={!!data.radar_show_self}
      locked={!!data.radar_locked}
      tick={data.radar_tick}
      epoch={data.radar_epoch}
      shapes={data.radar_shapes || {}}
      contacts={data.radar || []}
      drifters={data.radar_drifters || []}
      projectiles={data.radar_projectiles || []}
      engines={data.radar_engines || []}
      facing={data.facing || 0}
      terrain={data.radar_terrain}
      world={data.radar_world}
      objects={data.objects || []}
      self={data.self_pos}
      sectorSize={data.sector_size}
      cellSpan={data.cell_span}
      sectorId={data.sector_id}
      galaxy={data.galaxy}
      hazardFields={data.hazard_fields || []}
      peels={data.radar_peels}
      scatter={data.radar_scatter}
      radius={radius}
      onZoom={setRadius}
      followHeading={follow}
      onToggleFollow={() => setFollow(!follow)}
    />
  );
};
