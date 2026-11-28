import {
  type CSSProperties,
  type MouseEvent,
  memo,
  type ReactNode,
  type RefObject,
  useCallback,
  useEffect,
  useId,
  useLayoutEffect,
  useMemo,
  useRef,
  useState,
  type WheelEvent,
} from 'react';
import { createPortal } from 'react-dom';
import { Icon } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import type { GalaxyMap } from './galaxyTypes';
import { MapControls } from './MapControls';
import { MapRuler } from './MapRuler';
import { formatMetricDistance } from './mapDistance';
import { OvermapGalaxy } from './OvermapGalaxy';
import { RadarContacts } from './RadarContacts';
import { type RadarEngine, RadarEngines } from './RadarEngines';
import {
  RadarButton,
  RadarGroup,
  RadarLine,
  RadarMotion,
  RadarMotionContext,
  type RadarView,
  radarChartOffset,
  radarView,
} from './RadarMotion';
import { RadarProjectiles } from './RadarProjectiles';
import { type RadarWeapon, RadarWeapons } from './RadarWeapons';
import {
  mergeRadarPoses,
  type RadarDock,
  type RadarFrame,
  radarClickWorld,
} from './radarInterpolation';
import { GEOMETRY_FADE, GEOMETRY_FULL, radarWheelZoom } from './radarZoom';
import { useRadarInterpolation } from './useRadarInterpolation';
import { useSectorPan } from './useSectorPan';
import { WeaponAimPreview } from './WeaponAimPreview';

export type RadarPeel = {
  id: string;
  x: number;
  y: number;
  range: number;
  short: boolean;
  age: number;
  period: number;
};

export type RadarShape = {
  revision?: number;
  tiles: number[];
  collars: number[];
};

export type RadarTerrain = {
  revision?: string;
  x: number;
  y: number;
  walls: number[];
  frames: number[];
  floors: number[];
  docks?: number[];
};

export type RadarContact = {
  id: string;
  name?: string;
  x: number;
  y: number;
  rot: number;
  own?: boolean;
  destroyed?: boolean;
  distance?: number;
  closing?: number;
  docked?: boolean;
};

export type { RadarEngine } from './RadarEngines';

export type RadarProjectile = {
  kind?: string;
  id: string;
  x: number;
  y: number;
  angle: number;
};

export type RadarObject = {
  destroyed?: boolean | number;
  facing?: number;
  extent?: number[];
  id?: string;
  name: string;
  kind: string;
  x: number;
  y: number;
  color?: string | null;
  is_self?: boolean | number;
  heading?: number;
  distress?: boolean | number;
  size?: number;
  leads_to?: string | null;

  visibility?: number;

  scanned?: boolean;

  hazard_kind?: string | null;
};

export type RadarPose = { id: string; x: number; y: number; facing?: number };
const EMPTY_OBJECTS: RadarObject[] = [];
const MemoizedGalaxy = memo(OvermapGalaxy);

export type { GalaxyMap, GalaxySector } from './galaxyTypes';

export const RADAR_TILE_SPAN = 100;

export const GALAXY_SLOT = 2500;

export const RADAR_ZOOM_MIN = 12;
export const RADAR_ZOOM_MAX = 20000;
export const RADAR_ZOOM_STEP = 1.18;

const BAND_GEOMETRY_FULL = GEOMETRY_FULL;
const BAND_GEOMETRY_FADE = GEOMETRY_FADE;

const galaxySlotFor = (sectorSpan: number) =>
  Math.max(GALAXY_SLOT, sectorSpan * 0.6);
const galaxyBandFor = (sectorSpan: number) => galaxySlotFor(sectorSpan) * 2.4;

const dampedZoom = (factor: number, radius: number, threshold: number) => {
  const start = threshold * 0.55;
  const t = Math.max(0, Math.min(1, (radius - start) / (threshold - start)));
  const damp = 1 - 0.8 * t;
  return 1 + (factor - 1) * damp;
};

const RADAR_ZOOM_STEP_MID = 1.3;
const zoomStepFor = (radius: number, threshold: number) =>
  radius < BAND_GEOMETRY_FADE || radius > threshold * 0.5
    ? RADAR_ZOOM_STEP
    : RADAR_ZOOM_STEP_MID;

export const clampRadarZoom = (radius: number, ceiling = RADAR_ZOOM_MAX) =>
  Math.min(ceiling, Math.max(RADAR_ZOOM_MIN, Math.round(radius)));

export const radarZoomCeiling = (sectorSpan: number) =>
  Math.max(RADAR_ZOOM_MAX, Math.round(galaxyBandFor(sectorSpan) * 1.4));

const cellsPath = (cells: number[]) => {
  let path = '';
  for (let i = 0; i + 1 < cells.length; i += 2) {
    path += `M${cells[i] / 2 - 0.5} ${cells[i + 1] / 2 - 0.5}h1v1h-1z`;
  }
  return path;
};

const runsPath = (runs: number[], inset = 0) => {
  let path = '';
  for (let i = 0; i + 2 < runs.length; i += 3) {
    path += `M${runs[i] - 0.5} ${runs[i + 1] - 0.5 + inset}h${runs[i + 2]}v${
      1 - inset * 2
    }h${-runs[i + 2]}z`;
  }
  return path;
};

export const formatRadarDistance = (
  metres: number,
  _cellSpan = RADAR_TILE_SPAN,
) => formatMetricDistance(metres);

const geometryOpacity = (radius: number) =>
  Math.max(
    0,
    Math.min(
      1,
      (BAND_GEOMETRY_FADE - radius) / (BAND_GEOMETRY_FADE - BAND_GEOMETRY_FULL),
    ),
  );

const bandName = (
  radius: number,
  galaxyBand: boolean,
  geometryFull: number,
) => {
  if (galaxyBand) {
    return 'глобально';
  }
  if (radius <= geometryFull) {
    return 'окружение';
  }
  return 'сектор';
};

export type RadarScatterChunk = {
  x: number;
  y: number;
  carp: boolean | number;
  runs: number[];
};

const ScatterLayer = (props: {
  chunks: RadarScatterChunk[];
  opacity: number;
}) => {
  const { chunks, opacity } = props;
  const paths = useMemo(() => {
    const paths = ['', ''];
    for (const chunk of chunks) {
      const inset = chunk.carp ? 0.25 : 0;
      for (let i = 0; i + 2 < chunk.runs.length; i += 3) {
        const x = chunk.x + chunk.runs[i] - 0.5 + inset;
        const y = chunk.y + chunk.runs[i + 1] - 0.5 + inset;
        const width = chunk.runs[i + 2] - inset * 2;
        paths[chunk.carp ? 1 : 0] +=
          `M${x} ${y}h${width}v${1 - inset * 2}h${-width}z`;
      }
    }
    return paths;
  }, [chunks]);
  return (
    <RadarGroup
      opacity={opacity}
      pose={(v) =>
        `scale(1 -1) rotate(${v.rotation}) translate(${-v.worldX} ${-v.worldY})`
      }
    >
      <path d={paths[0]} fill="#bfa58d" />
      <path d={paths[1]} fill="#77cdab" />
    </RadarGroup>
  );
};

const GeometryLayer = (props: {
  terrain?: RadarTerrain | null;
  shapes: Record<string, RadarShape>;
  contacts: RadarContact[];
  world?: number[];
  facing: number;
  drifters: number[][];
  engines: RadarEngine[];
  opacity: number;
  activeDock?: RadarDock;
}) => {
  const {
    terrain,
    shapes,
    contacts,
    world,
    facing,
    drifters,
    engines,
    opacity,
    activeDock,
  } = props;
  const paths = useMemo(
    () => ({
      floors: terrain ? runsPath(terrain.floors) : '',
      frames: terrain ? runsPath(terrain.frames, 0.3) : '',
      walls: terrain ? runsPath(terrain.walls) : '',
      docks: terrain ? cellsPath(terrain.docks || []) : '',
    }),
    [terrain?.revision ?? terrain],
  );
  const terrainPaths = useMemo(
    () => (
      <>
        <path className="OvermapRadar__floor" d={paths.floors} />
        <path className="OvermapRadar__frame" d={paths.frames} />
        <path className="OvermapRadar__wall" d={paths.walls} />
        <path className="OvermapRadar__collar" d={paths.docks} />
      </>
    ),
    [paths],
  );
  const hullCache = useRef(
    new Map<
      string,
      { revision?: number; hull: string; collars: string; known: boolean }
    >(),
  );
  const hulls = useMemo(() => {
    const next = new Map<
      string,
      { revision?: number; hull: string; collars: string; known: boolean }
    >();
    for (const [id, shape] of Object.entries(shapes)) {
      if (!shape) continue;
      const cached = hullCache.current.get(id);
      next.set(
        id,
        cached &&
          shape.revision !== undefined &&
          cached.revision === shape.revision
          ? cached
          : {
              revision: shape.revision,
              hull: cellsPath(shape.tiles || []),
              collars: cellsPath(shape.collars || []),
              known: true,
            },
      );
    }
    hullCache.current = next;
    return next;
  }, [shapes]);
  if (opacity <= 0.01) {
    return null;
  }

  const angle = (facing * Math.PI) / 180;
  const dockX = (activeDock?.x || 0) - (world?.[0] || 0);
  const dockY = (activeDock?.y || 0) - (world?.[1] || 0);
  const activeCollar = activeDock
    ? cellsPath([
        (activeDock.hull_x ??
          dockX * Math.cos(angle) - dockY * Math.sin(angle)) * 2,
        (activeDock.hull_y ??
          dockY * Math.cos(angle) + dockX * Math.sin(angle)) * 2,
      ])
    : '';
  return (
    <g opacity={opacity} transform="scale(1 -1)">
      {!!terrain && (
        <RadarGroup
          pose={(v) =>
            `rotate(${v.rotation}) translate(${terrain.x - v.worldX} ${terrain.y - v.worldY})`
          }
        >
          {terrainPaths}
        </RadarGroup>
      )}
      <RadarGroup
        pose={(v) =>
          `rotate(${v.rotation}) translate(${-v.offsetX} ${-v.offsetY}) rotate(${-v.frame.facing})`
        }
      >
        {drifters.map((drifter, index) => (
          <RadarGroup
            key={index}
            pose={(v) => {
              const point = v.frame.drifters[index] ?? drifter;
              return `translate(${point[0]} ${point[1]})`;
            }}
          >
            {drifter[2] ? (
              <circle r={0.5} fill="#ff4545" />
            ) : (
              <circle className="OvermapRadar__drifter" r={2} />
            )}
          </RadarGroup>
        ))}
        {contacts.map((contact) => {
          const {
            hull = '',
            collars = '',
            known = false,
          } = hulls.get(contact.id) || {};
          const tone = contact.destroyed
            ? 'OvermapRadar__hull--destroyed'
            : contact.own
              ? 'OvermapRadar__hull--own'
              : contact.docked
                ? 'OvermapRadar__hull--docked'
                : 'OvermapRadar__hull--other';
          return (
            <RadarGroup
              key={contact.id}
              pose={(v) => {
                const item = v.index.contacts.get(contact.id) ?? contact;
                return `translate(${item.x} ${item.y}) rotate(${-item.rot})`;
              }}
            >
              {known ? (
                <>
                  <path className={`OvermapRadar__hull ${tone}`} d={hull} />
                  <path
                    className="OvermapRadar__collar"
                    d={collars}
                    opacity={contact.own && activeDock ? 0.4 : 1}
                  />
                  {!!contact.own && !!activeDock && (
                    <path className="OvermapRadar__collar" d={activeCollar} />
                  )}
                </>
              ) : (
                <circle className={`OvermapRadar__hull ${tone}`} r={2.5} />
              )}
              {!!contact.destroyed && (
                <path
                  className="OvermapRadar__destroyedMark"
                  d="M-4 -4L4 4M-4 4L4 -4"
                  stroke="#aaaaaa"
                  strokeWidth={2}
                  vectorEffect="non-scaling-stroke"
                  fill="none"
                />
              )}
            </RadarGroup>
          );
        })}
        <RadarEngines engines={engines} />
      </RadarGroup>
    </g>
  );
};

export type HazardField = {
  id?: string;
  kind: string | null;
  density: number;
  cells: number[][];
  contours?: number[][];
  scanned: boolean | number;
  visibility: number;
};

const HAZARD_HATCH_STEPS = 3;
const hatchStepFor = (density: number) =>
  density >= 5 ? 3 : density >= 3 ? 2 : 1;
const HAZARD_HATCH_FLAVOURS = ['asteroid', 'emp', 'carp'] as const;
export const hazardHatchId = (kind: string | null, step: number) =>
  `overmap-hazard-hatch-${kind || 'plain'}-${step}`;

const cloudPath = (rings: number[][], span: number) =>
  rings
    .map((ring) => {
      const count = ring.length / 2;
      if (count < 3) return '';
      const point = (i: number) => [
        ring[(i % count) * 2] * span,
        ring[(i % count) * 2 + 1] * span,
      ];
      const last = point(count - 1);
      const first = point(0);
      let path = `M${(last[0] + first[0]) / 2} ${(last[1] + first[1]) / 2}`;
      for (let i = 0; i < count; i++) {
        const here = point(i);
        const next = point(i + 1);
        path += `Q${here[0]} ${here[1]} ${(here[0] + next[0]) / 2} ${(here[1] + next[1]) / 2}`;
      }
      return `${path}Z`;
    })
    .join('');

const HazardLayer = (props: {
  fields: HazardField[];
  contours?: number[][][];
  radius: number;
  self: number[];
  cellSpan: number;
  rotation: number;
  offset: [number, number];
  sensorReach: number;
  soft?: boolean;
}) => {
  const { fields, self, cellSpan, rotation, offset, sensorReach, soft } = props;
  const centerX = self[0] * cellSpan + offset[0];
  const centerY = self[1] * cellSpan + offset[1];
  const angle = (rotation * Math.PI) / 180;
  const reach =
    props.radius * (Math.abs(Math.cos(angle)) + Math.abs(Math.sin(angle))) +
    cellSpan * 0.08;
  const prefix = useId().replace(/:/g, '');
  const outlines = useMemo(
    () => props.contours ?? fields.map((field) => field.contours || []),
    [props.contours, fields],
  );
  const geometry = useMemo(
    () =>
      outlines.map((contours, index) => {
        let minX = Infinity;
        let minY = Infinity;
        let maxX = -Infinity;
        let maxY = -Infinity;
        for (const ring of contours) {
          for (let i = 0; i + 1 < ring.length; i += 2) {
            minX = Math.min(minX, ring[i] * cellSpan);
            minY = Math.min(minY, ring[i + 1] * cellSpan);
            maxX = Math.max(maxX, ring[i] * cellSpan);
            maxY = Math.max(maxY, ring[i + 1] * cellSpan);
          }
        }
        return {
          index,
          path: cloudPath(contours, cellSpan),
          minX: minX - 1,
          minY: minY - 1,
          width: maxX - minX + 2,
          height: maxY - minY + 2,
        };
      }),
    [outlines, cellSpan],
  );
  const visible = geometry.filter(
    ({ index, path, minX, minY, width, height }) =>
      fields[index] &&
      path &&
      minX <= centerX + reach &&
      minX + width >= centerX - reach &&
      minY <= centerY + reach &&
      minY + height >= centerY - reach,
  );
  if (!visible.length) return null;
  const edge = props.radius + cellSpan * 0.08;
  return (
    <g filter={soft ? `url(#${prefix}-soft)` : undefined}>
      <defs>
        {soft ? (
          <filter
            id={`${prefix}-soft`}
            filterUnits="userSpaceOnUse"
            x={-edge}
            y={-edge}
            width={edge * 2}
            height={edge * 2}
          >
            <feGaussianBlur stdDeviation={cellSpan * 0.018} />
          </filter>
        ) : (
          <radialGradient id={`${prefix}-scan`}>
            <stop offset="0%" stopColor="white" />
            <stop offset="75%" stopColor="white" />
            <stop offset="100%" stopColor="white" stopOpacity="0" />
          </radialGradient>
        )}
      </defs>
      <RadarGroup
        pose={(v) =>
          `scale(1 -1) rotate(${v.rotation}) translate(${-v.sectorX} ${-v.sectorY})`
        }
      >
        {visible.map(({ index, path, minX, minY, width, height }) => {
          const field = fields[index];
          const mask = `${prefix}-cloud-${index}`;
          const tone = field.scanned
            ? field.kind === 'emp'
              ? '#589bff'
              : field.kind === 'carp'
                ? '#64dba0'
                : '#d3a576'
            : '#ee626c';
          return (
            <g key={index}>
              {!soft && (
                <defs>
                  <mask
                    id={mask}
                    maskUnits="userSpaceOnUse"
                    x={minX}
                    y={minY}
                    width={width}
                    height={height}
                  >
                    {!!field.scanned && (
                      <path
                        d={path}
                        fill="white"
                        fillRule="evenodd"
                        opacity={0.35}
                      />
                    )}
                    {sensorReach > 0 && (
                      <RadarGroup
                        pose={(v) =>
                          `translate(${v.sectorX - v.offsetX} ${v.sectorY - v.offsetY})`
                        }
                      >
                        <circle
                          r={sensorReach * cellSpan}
                          fill={`url(#${prefix}-scan)`}
                        />
                      </RadarGroup>
                    )}
                  </mask>
                </defs>
              )}
              <g mask={soft ? undefined : `url(#${mask})`}>
                <path
                  d={path}
                  fillRule="evenodd"
                  fill={tone}
                  opacity={
                    soft
                      ? 0.12 + field.density * 0.012
                      : 0.25 + Math.min(field.density, 6) * 0.045
                  }
                />
                {!soft && (
                  <path
                    d={path}
                    fillRule="evenodd"
                    fill="none"
                    stroke={tone}
                    strokeOpacity={0.5}
                    strokeWidth={1}
                    vectorEffect="non-scaling-stroke"
                  />
                )}
                {!!field.scanned && !soft && (
                  <path
                    d={path}
                    fillRule="evenodd"
                    fill={`url(#${hazardHatchId(field.kind, hatchStepFor(field.density))})`}
                    opacity={0.65}
                  />
                )}
              </g>
            </g>
          );
        })}
      </RadarGroup>
    </g>
  );
};

const SensorPeel = (props: {
  peel: RadarPeel;
  own: boolean;
  cellSpan: number;
}) => {
  const { peel, own, cellSpan } = props;
  const delay = useRef(-peel.age % peel.period).current;
  return (
    <RadarGroup
      pose={(v) => {
        const point = own ? v.hullPoint(0, 0) : v.sectorPoint(peel.x, peel.y);
        return `translate(${point[0]} ${point[1]})`;
      }}
    >
      <circle
        className="OvermapRadar__peel"
        r={peel.range * cellSpan}
        fill="none"
        stroke={peel.short ? '#70e7b8' : '#68b5ff'}
        vectorEffect="non-scaling-stroke"
        style={{
          animationDuration: `${peel.period}s`,
          animationDelay: `${delay}s`,
        }}
      />
    </RadarGroup>
  );
};

const SectorLayer = (props: {
  sectorSize: number;
  cellSpan: number;
  self?: number[];
  radius: number;
  opacity: number;
  dest?: number[];
}) => {
  const { sectorSize, cellSpan, self, radius, opacity, dest } = props;
  const step = radius > cellSpan * 7 ? 5 : 1;
  const grid = useMemo(() => {
    if (sectorSize <= 0) {
      return [];
    }
    const built: ReactNode[] = [];
    const lowX = 0;
    const highX = sectorSize * cellSpan;
    const lowY = 0;
    const highY = sectorSize * cellSpan;
    const labelSize = Math.max(radius / 46, 8);
    for (let cell = 0; cell <= sectorSize; cell += step) {
      const major = cell % 5 === 0;
      const x = cell * cellSpan;
      const y = cell * cellSpan;
      built.push(
        <line
          key={`x${cell}`}
          className={major ? 'OvermapRadar__cell--major' : 'OvermapRadar__cell'}
          x1={x}
          y1={lowY}
          x2={x}
          y2={highY}
        />,
        <line
          key={`y${cell}`}
          className={major ? 'OvermapRadar__cell--major' : 'OvermapRadar__cell'}
          x1={lowX}
          y1={y}
          x2={highX}
          y2={y}
        />,
      );
      if (major && cell > 0) {
        built.push(
          <g
            key={`lx${cell}`}
            transform={`translate(${x} ${lowY}) scale(1 -1)`}
          >
            <text
              className="OvermapRadar__cellLabel"
              y={-labelSize * 0.6}
              fontSize={labelSize}
              textAnchor="middle"
            >
              {cell}
            </text>
          </g>,
          <g
            key={`ly${cell}`}
            transform={`translate(${lowX} ${y}) scale(1 -1)`}
          >
            <text
              className="OvermapRadar__cellLabel"
              x={-labelSize * 0.4}
              fontSize={labelSize}
              textAnchor="end"
              dominantBaseline="middle"
            >
              {cell}
            </text>
          </g>,
        );
      }
    }
    return built;
  }, [sectorSize, cellSpan, radius, step]);
  if (opacity <= 0.01 || !self || sectorSize <= 0) {
    return null;
  }
  return (
    <g opacity={opacity} transform="scale(1 -1)">
      <RadarGroup pose={(v) => `rotate(${v.rotation})`}>
        <RadarGroup pose={(v) => `translate(${-v.sectorX} ${-v.sectorY})`}>
          <rect
            className="OvermapRadar__cellArea"
            x={0}
            y={0}
            width={sectorSize * cellSpan}
            height={sectorSize * cellSpan}
          />
          {grid}
          {!!dest && (
            <g
              className="OvermapRadar__destMark"
              transform={`translate(${dest[0] * cellSpan} ${dest[1] * cellSpan})`}
            >
              <RadarLine
                className="OvermapRadar__destRoute"
                points={(v) => [
                  ((v.frame.self?.[0] ?? dest[0]) - dest[0]) * cellSpan,
                  ((v.frame.self?.[1] ?? dest[1]) - dest[1]) * cellSpan,
                  0,
                  0,
                ]}
              />
              <circle className="OvermapRadar__destRing" r={cellSpan * 0.3} />
              <line
                className="OvermapRadar__destCross"
                x1={-cellSpan * 0.45}
                y1={0}
                x2={cellSpan * 0.45}
                y2={0}
              />
              <line
                className="OvermapRadar__destCross"
                x1={0}
                y1={-cellSpan * 0.45}
                x2={0}
                y2={cellSpan * 0.45}
              />
            </g>
          )}
        </RadarGroup>
      </RadarGroup>
    </g>
  );
};

const RadarRim = (props: { radius: number }) => {
  const { radius } = props;
  const ticks = useMemo(() => {
    const built: ReactNode[] = [];
    for (let angle = 0; angle < 360; angle += 15) {
      const major = angle % 45 === 0;
      const inner = radius * (major ? 0.92 : 0.96);
      const rad = (angle * Math.PI) / 180;
      built.push(
        <line
          key={angle}
          className={
            major
              ? 'OvermapRadar__tick OvermapRadar__tick--major'
              : 'OvermapRadar__tick'
          }
          x1={Math.sin(rad) * inner}
          y1={Math.cos(rad) * inner}
          x2={Math.sin(rad) * radius}
          y2={Math.cos(rad) * radius}
        />,
      );
    }
    return built;
  }, [radius]);
  return (
    <>
      {[0.25, 0.5, 0.75].map((ring) => (
        <circle key={ring} className="OvermapRadar__ring" r={radius * ring} />
      ))}
      <circle
        className="OvermapRadar__ring OvermapRadar__ring--edge"
        r={radius}
      />
      <line
        className="OvermapRadar__spoke"
        x1={-radius}
        y1={0}
        x2={radius}
        y2={0}
      />
      <line
        className="OvermapRadar__spoke"
        x1={0}
        y1={-radius}
        x2={0}
        y2={radius}
      />
      {ticks}
    </>
  );
};

const RadarCompass = (props: {
  followHeading: boolean;
  onToggle: () => void;
}) => {
  const { followHeading, onToggle } = props;
  return (
    <button
      type="button"
      className="OvermapRadar__compass"
      title={'Переключить режим.'}
      onClick={onToggle}
    >
      <svg viewBox="-50 -50 100 100">
        <circle className="OvermapRadar__compassRing" r={44} />
        <RadarGroup pose={(v) => `rotate(${-v.rotation})`}>
          <polygon
            className="OvermapRadar__compassNorth"
            points="0,-40 7,-25 -7,-25"
          />
          <text
            className="OvermapRadar__compassLabel"
            y={-29}
            textAnchor="middle"
          >
            N
          </text>
        </RadarGroup>
        <RadarGroup pose={(v) => `rotate(${v.frame.facing - v.rotation})`}>
          <line
            className="OvermapRadar__compassSpoke"
            x1={0}
            y1={14}
            x2={0}
            y2={-22}
          />
          <polygon
            className="OvermapRadar__compassShip"
            points="0,-24 9,14 0,6 -9,14"
          />
        </RadarGroup>
      </svg>
      <span className="OvermapRadar__compassState">
        {followHeading ? 'курс' : 'север'}
      </span>
    </button>
  );
};

const RadarRuler = (props: {
  radius: number;
  cellSpan: number;
  side: number;

  slot: number;
  galaxy: boolean;
}) => {
  const { radius, cellSpan, slot, galaxy } = props;
  return (
    <MapRuler
      label={
        galaxy
          ? `${(radius / slot).toFixed(1)} сектора`
          : formatRadarDistance((radius * 2 * 120) / props.side, cellSpan)
      }
    />
  );
};

const RadarZoom = (props: {
  radius: number;
  onZoom: (radius: number) => void;
  threshold: number;

  ceiling: number;

  sectorSpan: number;
  onGalaxy: () => void;
}) => {
  const { radius, onZoom, threshold, ceiling, sectorSpan } = props;
  const nudge = (outward: boolean) => {
    const step = dampedZoom(
      outward
        ? zoomStepFor(radius, threshold)
        : 1 / zoomStepFor(radius, threshold),
      radius,
      threshold,
    );
    onZoom(clampRadarZoom(radius * step, ceiling));
  };
  return (
    <MapControls
      onIn={() => nudge(false)}
      onOut={() => nudge(true)}
      onBand={() =>
        radius > threshold
          ? onZoom(clampRadarZoom(sectorSpan * 0.5, ceiling))
          : props.onGalaxy()
      }
      bandTitle={radius > threshold ? 'Сектор' : 'Галактика'}
      band={radius > threshold ? '◻' : '✦'}
    />
  );
};

type OvermapRadarProps = {
  panSector?: boolean;
  fillViewport?: boolean;
  onFacingChange?: (facing: number | null) => void;
  clickTarget?: { id?: string; x?: number; y?: number };
  onFirePoint?: (x: number, y: number) => void;
  outlines?: Record<string, string>;
  showSelf?: boolean;
  shapes: Record<string, RadarShape>;
  contacts: RadarContact[];
  drifters: number[][];
  projectiles?: RadarProjectile[];
  weapons?: RadarWeapon[];
  onSelectWeapon?: (id: string) => void;
  weaponArcs?: {
    id: string;
    x: number;
    y: number;
    heading: number;
    arc: number;
  }[];
  facing: number;
  terrain?: RadarTerrain | null;
  world?: number[];
  engines: RadarEngine[];
  objects?: RadarObject[];
  poses?: RadarPose[] | null;
  self?: number[];
  sectorSize?: number;

  cellSpan?: number;
  sectorId?: string;
  galaxy?: GalaxyMap | null;

  radius?: number;
  onZoom?: (radius: number) => void;

  onReach?: (reach: number) => void;
  followHeading?: boolean;
  onToggleFollow?: () => void;

  dest?: number[];

  filter?: string;

  hazardFields?: HazardField[];
  hazardContours?: number[][][];
  overlay?: ReactNode;
  onSelectObject?: (id: string) => void;
  selectOnDoubleClick?: boolean;
  onSelectPoint?: (x: number, y: number) => void;
  scatter?: RadarScatterChunk[];
  peels?: RadarPeel[];
  dockTargets?: RadarDock[];
  dockPreview?: { x: number; y: number; facing: number; tiles: number[] };
  onSelectDock?: (id: string) => void;
  tick?: number;
  epoch?: number;
  locked?: boolean;
  docked?: boolean;
};

export const OvermapRadar = (props: OvermapRadarProps) => {
  const {
    sectorSize = 0,
    cellSpan = RADAR_TILE_SPAN,
    sectorId,
    galaxy,
    radius: requestedRadius = 64,
    onZoom,
    onReach,
  } = props;
  const [galaxyEntry, setGalaxyEntry] = useState<'close' | 'overview'>(
    'overview',
  );
  const [galaxyReset, setGalaxyReset] = useState(0);
  const scope = useRef<HTMLDivElement>(null);
  const displayed = useRef<RadarView | null>(null);
  const [viewport, setViewport] = useState({ side: 640, height: 640 });
  const { side: scopeSide } = viewport;
  useEffect(() => {
    if (!scope.current) return;
    const observer = new ResizeObserver(([entry]) => {
      const { width, height } = entry.contentRect;
      if (!width || !height) return;
      const side = props.fillViewport ? width : Math.min(width, height);
      setViewport({ side, height: Math.min(side, height) });
    });
    observer.observe(scope.current);
    return () => observer.disconnect();
  }, [props.fillViewport]);
  const reachCallback = useRef(onReach);
  useLayoutEffect(() => {
    reachCallback.current = onReach;
  }, [onReach]);
  const sectorSpan = Math.max(cellSpan * sectorSize, cellSpan * 4);
  const radius = props.locked
    ? galaxyBandFor(sectorSpan) * 1.15
    : requestedRadius;
  const galaxyBand = !!props.locked || radius > galaxyBandFor(sectorSpan);
  const canPan =
    !!props.panSector && !galaxyBand && radius > BAND_GEOMETRY_FULL;
  const { center, resetCenter, handlers } = useSectorPan(
    canPan,
    sectorId,
    displayed,
  );
  useEffect(() => {
    if (!galaxyBand) return;
    Byond.sendMessage('radar/galaxy', { open: 1 });
    return () => Byond.sendMessage('radar/galaxy', { open: 0 });
  }, [galaxyBand]);
  const geometry = geometryOpacity(radius);

  const galaxySlot = galaxySlotFor(sectorSpan);
  const galaxyBandRadius = galaxyBandFor(sectorSpan);
  const zoomCeiling = radarZoomCeiling(sectorSpan);
  const reach =
    geometry > 0.01
      ? Math.min(128, Math.max(32, Math.round(radius * 1.1)))
      : 32;
  const canRequestReach = !!onReach;
  useEffect(() => {
    if (!canRequestReach) return;
    const timer = window.setTimeout(() => reachCallback.current?.(reach), 120);
    return () => window.clearTimeout(timer);
  }, [canRequestReach, reach]);
  const wheel = (event: WheelEvent<HTMLDivElement>) => {
    if (!onZoom || props.locked) {
      return;
    }
    event.preventDefault();
    if (!galaxyBand) setGalaxyEntry('close');
    onZoom(
      clampRadarZoom(
        radarWheelZoom(radius, event.deltaY > 0, galaxyBandRadius),
        zoomCeiling,
      ),
    );
  };
  const selectPoint = (event: MouseEvent<HTMLDivElement>, firing: boolean) => {
    const view = displayed.current;
    if (
      galaxyBand ||
      props.overlay ||
      !props.onSelectPoint ||
      !view?.frame.world
    )
      return;
    if (
      (event.target as Element).closest(
        firing
          ? 'input,select,textarea,.OvermapRadar__weapon,.OvermapRadar__controls,.OvermapRadar__bands'
          : 'button,input,select,textarea,.OvermapRadar__controls',
      )
    )
      return;
    const bounds = (
      scope.current || event.currentTarget
    ).getBoundingClientRect();
    const side = props.fillViewport
      ? bounds.width
      : Math.min(bounds.width, bounds.height);
    const screen = [
      ((event.clientX - bounds.left - bounds.width / 2) * 2) / side,
      ((event.clientY - bounds.top - bounds.height / 2) * 2) / side,
    ];
    if (!props.fillViewport && Math.hypot(...screen) > 1) return;
    const point = radarClickWorld(
      screen,
      view.radius,
      view.rotation,
      view.frame.world,
      [view.offsetX, view.offsetY],
    );
    if (firing && props.onFirePoint) {
      props.onFirePoint(point[0], point[1]);
    } else {
      if (firing) event.stopPropagation();
      props.onSelectPoint(point[0], point[1]);
    }
  };
  return (
    <div
      className={classes([
        'OvermapRadar',
        props.fillViewport && 'OvermapRadar--fill',
      ])}
      onWheel={wheel}
    >
      {!!onZoom && !props.locked && (
        <div className="OvermapRadar__bands">
          <button
            type="button"
            className={
              !galaxyBand && radius <= BAND_GEOMETRY_FULL ? 'selected' : ''
            }
            onClick={() => onZoom(64)}
          >
            Ближний
          </button>
          <button
            type="button"
            className={
              !galaxyBand && radius > BAND_GEOMETRY_FULL ? 'selected' : ''
            }
            onClick={() => {
              resetCenter();
              onZoom(Math.max(220, sectorSpan * 0.55));
            }}
          >
            Сектор
          </button>
          <button
            type="button"
            className={galaxyBand ? 'selected' : ''}
            onClick={() => {
              setGalaxyEntry('overview');
              setGalaxyReset((value) => value + 1);
              onZoom(galaxyBandRadius * 1.15);
            }}
          >
            Глобально
          </button>
        </div>
      )}
      <div
        className="OvermapRadar__scope"
        onClickCapture={(event) => {
          if (!props.selectOnDoubleClick && props.weaponArcs?.length)
            selectPoint(event, true);
        }}
        onClick={(event) => {
          if (!props.selectOnDoubleClick) selectPoint(event, false);
        }}
        onDoubleClick={(event) => {
          if (props.selectOnDoubleClick) selectPoint(event, false);
        }}
      >
        <div
          className={classes([
            'OvermapRadar__scene',
            canPan && 'OvermapRadar__scene--pannable',
          ])}
          ref={scope}
          {...handlers}
        >
          {!galaxyBand && (
            <RadarScene
              data={props}
              radius={radius}
              scope={scope}
              side={scopeSide}
              height={viewport.height}
              displayed={displayed}
              center={center}
            />
          )}
        </div>
        {galaxyBand && (
          <MemoizedGalaxy
            key={galaxyReset}
            galaxy={galaxy || { revision: 0, sectors: [] }}
            sectorId={sectorId}
            entry={galaxyEntry}
            onSector={
              !props.locked && onZoom
                ? () => onZoom(Math.max(220, sectorSpan * 0.55))
                : undefined
            }
          />
        )}
        {!galaxyBand && props.docked && (
          <div className="OvermapRadar__docked">СОСТЫКОВАН</div>
        )}
        {galaxyBand && !(galaxy?.sectors || []).length && (
          <div className="OvermapRadar__galaxyEmpty">
            <Icon name="circle-info" />
            <span>
              сервер не прислал данные о секторах — галактическую карту не из
              чего собрать
            </span>
          </div>
        )}
        <span
          className="OvermapRadar__band"
          style={galaxyBand ? { display: 'none' } : undefined}
        >
          {bandName(radius, galaxyBand, BAND_GEOMETRY_FULL)}
          {galaxyBand && galaxy?.sectors?.length
            ? ` · узлов ${galaxy.sectors.length}`
            : ''}
        </span>
        <div className="OvermapRadar__controls">
          {!!onZoom && !props.locked && !galaxyBand && (
            <RadarZoom
              radius={radius}
              onZoom={(value) => {
                setGalaxyEntry('close');
                onZoom(value);
              }}
              onGalaxy={() => {
                setGalaxyEntry('overview');
                setGalaxyReset((value) => value + 1);
                onZoom(galaxyBandRadius * 1.15);
              }}
              threshold={galaxyBandRadius}
              ceiling={zoomCeiling}
              sectorSpan={sectorSpan}
            />
          )}
          {!galaxyBand && (
            <RadarRuler
              radius={radius}
              cellSpan={cellSpan}
              side={scopeSide}
              slot={galaxySlot}
              galaxy={false}
            />
          )}
        </div>
        {props.overlay}
      </div>
    </div>
  );
};

const RadarScene = ({
  data: props,
  radius,
  scope,
  side,
  height,
  displayed,
  center,
}: {
  data: OvermapRadarProps;
  radius: number;
  scope: RefObject<HTMLDivElement | null>;
  side: number;
  height: number;
  displayed: { current: RadarView | null };
  center?: [number, number];
}) => {
  const {
    shapes,
    contacts: rawContacts,
    drifters: rawDrifters,
    facing: rawFacing,
    terrain,
    world: rawWorld,
    engines,
    objects: rawObjects,
    self: rawSelf,
    sectorSize = 0,
    cellSpan = RADAR_TILE_SPAN,
    sectorId,
    followHeading = true,
    onToggleFollow,
    onFacingChange,
    dest,
    filter = 'all',
    hazardFields = [],
  } = props;
  const geometry = geometryOpacity(radius);
  const posedObjects = useMemo(
    () => mergeRadarPoses(rawObjects || EMPTY_OBJECTS, props.poses),
    [rawObjects, props.poses],
  );
  const [motion] = useState(() => new RadarMotion());
  const sample: RadarFrame = useMemo(
    () => ({
      tick: props.tick,
      epoch: props.epoch,
      sectorId,
      cellSpan,
      contacts: rawContacts,
      drifters: rawDrifters,
      facing: rawFacing,
      world: rawWorld,
      self: rawSelf,
      objects: posedObjects,
      dockTargets: props.dockTargets,
      projectiles: props.projectiles,
    }),
    [
      props.tick,
      props.epoch,
      sectorId,
      cellSpan,
      rawContacts,
      rawDrifters,
      rawFacing,
      rawWorld,
      rawSelf,
      posedObjects,
      props.dockTargets,
      props.projectiles,
    ],
  );
  const draw = useCallback(
    (frame: RadarFrame) => {
      const view = radarView(
        frame,
        radius,
        side,
        height,
        sectorSize,
        followHeading,
        center,
      );
      displayed.current = view;
      motion.draw(view);
      onFacingChange?.(frame.facing);
    },
    [
      motion,
      displayed,
      center,
      radius,
      side,
      height,
      sectorSize,
      followHeading,
      onFacingChange,
    ],
  );
  useRadarInterpolation(sample, draw);
  useLayoutEffect(() => () => onFacingChange?.(null), [onFacingChange]);
  const {
    contacts,
    drifters,
    facing,
    world,
    self,
    objects,
    dockTargets,
    projectiles,
  } = sample;
  const compass = onToggleFollow && (
    <RadarCompass followHeading={followHeading} onToggle={onToggleFollow} />
  );
  const rotation = followHeading ? facing : 0;
  const nearBand = radius <= BAND_GEOMETRY_FULL;
  const previewTiles = props.dockPreview?.tiles;
  const previewPath = useMemo(
    () => previewTiles && cellsPath(previewTiles),
    [previewTiles],
  );

  const chartOffset = radarChartOffset(
    self,
    sectorSize,
    cellSpan,
    radius,
    center,
  );

  const clicked = props.clickTarget;
  const verticalRadius = (radius * height) / side;
  const viewBox = `${-radius} ${-verticalRadius} ${radius * 2} ${verticalRadius * 2}`;
  return (
    <RadarMotionContext.Provider value={motion}>
      <svg className="OvermapRadar__peels" viewBox={viewBox}>
        {!nearBand &&
          props.peels?.map((peel) => {
            const own = peel.id === contacts.find((contact) => contact.own)?.id;
            return (
              <SensorPeel
                key={peel.id}
                peel={peel}
                own={own}
                cellSpan={cellSpan}
              />
            );
          })}
      </svg>
      {!!props.onSelectObject &&
        hazardFields
          .filter((field) => field.id)
          .map((field) => {
            const cell = field.cells[0];
            if (!cell) return null;
            return (
              <RadarButton
                point={(v) => v.sectorPoint(cell[0], cell[1])}
                key={field.id}
                title="Выбрать облако для сканирования"
                className="OvermapRadar__pick"
                onClick={() => {
                  if (!props.selectOnDoubleClick)
                    props.onSelectObject?.(field.id!);
                }}
                onDoubleClick={(event) => {
                  if (props.selectOnDoubleClick) {
                    event.stopPropagation();
                    props.onSelectObject?.(field.id!);
                  }
                }}
              />
            );
          })}
      {radius < BAND_GEOMETRY_FADE &&
        dockTargets?.map((dock) => {
          return (
            <RadarButton
              point={(v) => {
                const target = v.index.docks.get(dock.id);
                if (target) return v.worldPoint(target.x, target.y);
              }}
              key={dock.id}
              title={`${dock.own ? 'Свой шлюз' : 'Стыковка'}: ${dock.name}${dock.available === false || dock.available === 0 ? ' · недоступен' : ''}`}
              className={classes([
                'OvermapRadar__pick',
                'OvermapRadar__pick--dock',
                dock.own && 'OvermapRadar__pick--own',
                dock.selected && 'OvermapRadar__pick--selected',
              ])}
              disabled={dock.available === false || dock.available === 0}
              onClick={(event) => {
                event.stopPropagation();
                if (!props.selectOnDoubleClick) props.onSelectDock?.(dock.id);
              }}
              onDoubleClick={(event) => {
                if (props.selectOnDoubleClick) {
                  event.stopPropagation();
                  props.onSelectDock?.(dock.id);
                }
              }}
            >
              <Icon name="anchor" />
            </RadarButton>
          );
        })}
      {!!props.dockPreview && radius < BAND_GEOMETRY_FADE && (
        <svg className="OvermapRadar__approach" viewBox={viewBox}>
          <RadarGroup
            pose={(v) => {
              const preview = props.dockPreview!;
              const [x, y] = v.worldPoint(preview.x, preview.y);
              return `translate(${x} ${y}) rotate(${preview.facing - v.rotation}) scale(1 -1)`;
            }}
          >
            <path
              d={previewPath}
              fill="rgba(70,150,255,0.3)"
              stroke="#68b5ff"
              strokeWidth={0.1}
            />
          </RadarGroup>
        </svg>
      )}
      <svg
        className="OvermapRadar__svg"
        style={
          { '--radar-stroke': `${(2 * radius) / side}px` } as CSSProperties
        }
        viewBox={viewBox}
        preserveAspectRatio="xMidYMid meet"
      >
        <RadarDefinitions cellSpan={cellSpan} />
        <g className="OvermapRadar__furniture">
          <MemoizedRadarRim radius={radius} />
        </g>
        <HazardLayer
          soft={geometry > 0.01}
          sensorReach={Math.max(
            0,
            ...(props.peels || [])
              .filter(
                (peel) =>
                  peel.id === contacts.find((contact) => contact.own)?.id,
              )
              .map((peel) => peel.range),
          )}
          fields={hazardFields}
          contours={props.hazardContours}
          radius={radius}
          self={self || [0, 0]}
          cellSpan={cellSpan}
          rotation={rotation}
          offset={chartOffset}
        />
        {geometry > 0.01 && !!props.scatter && (
          <ScatterLayer chunks={props.scatter} opacity={geometry} />
        )}
        <GeometryLayer
          terrain={terrain}
          shapes={shapes}
          contacts={contacts}
          world={world}
          facing={facing}
          drifters={drifters}
          engines={engines}
          opacity={geometry}
          activeDock={dockTargets?.find((dock) => dock.own && dock.selected)}
        />
        {!!props.weaponArcs?.length && rawWorld && (
          <RadarGroup
            pose={(v) =>
              `scale(1 -1) rotate(${v.rotation}) translate(${-v.offsetX} ${-v.offsetY}) rotate(${-v.frame.facing})`
            }
            pointerEvents="none"
          >
            {props.weaponArcs.map((weapon) => {
              const half = (weapon.arc * Math.PI) / 360;
              const reach = radius * 1.5;
              const edge = Math.sin(half) * reach;
              const forward = Math.cos(half) * reach;
              return (
                <path
                  key={weapon.id}
                  transform={`translate(${weapon.x} ${weapon.y}) rotate(${-weapon.heading})`}
                  d={`M 0 0 L ${-edge} ${forward} A ${reach} ${reach} 0 0 0 ${edge} ${forward} Z`}
                  fill="#ffb15a"
                  fillOpacity={0.09}
                  stroke="#ffc17c"
                  strokeOpacity={0.6}
                  strokeWidth={1}
                  vectorEffect="non-scaling-stroke"
                />
              );
            })}
          </RadarGroup>
        )}
        {!!props.weaponArcs?.length && world && !props.overlay && (
          <WeaponAimPreview
            scope={scope}
            weapons={props.weaponArcs}
            fillViewport={props.fillViewport}
          />
        )}
        <SectorLayer
          sectorSize={sectorSize}
          cellSpan={cellSpan}
          self={self}
          radius={radius}
          opacity={1}
          dest={dest}
        />
        {clicked && self && (
          <RadarGroup
            pose={(v) => {
              const point =
                (clicked.id && v.objectPoint(clicked.id)) ||
                (clicked.x != null &&
                  clicked.y != null &&
                  v.sectorPoint(clicked.x, clicked.y));
              return point ? `translate(${point[0]} ${point[1]})` : 'scale(0)';
            }}
          >
            <circle
              className="OvermapRadar__clickMarker"
              r={radius / 150}
              fill="#a9afb8"
              stroke="#e0e3e8"
              strokeWidth={1}
              vectorEffect="non-scaling-stroke"
              pointerEvents="none"
            />
          </RadarGroup>
        )}
        <RadarGroup
          pose={(v) =>
            `rotate(${-v.rotation}) translate(0 ${-radius * 0.86}) rotate(${v.rotation})`
          }
        >
          <text
            className="OvermapRadar__north"
            fontSize={radius * 0.065}
            textAnchor="middle"
            dominantBaseline="middle"
          >
            N
          </text>
        </RadarGroup>
      </svg>
      <RadarContacts
        outlines={props.outlines}
        geometry={geometry}
        filter={filter}
        showSelf={props.showSelf}
      />
      {!!world && !!projectiles?.length && <RadarProjectiles />}
      {props.onSelectObject &&
        objects.map((object) => {
          if (object.is_self || !object.id) return null;
          const id = object.id;
          return (
            <RadarButton
              key={id}
              className="OvermapRadar__pick"
              point={(v) => v.objectPoint(id)}
              title={object.name}
              onClick={() => {
                if (!props.selectOnDoubleClick) props.onSelectObject?.(id);
              }}
              onDoubleClick={(event) => {
                if (props.selectOnDoubleClick) {
                  event.stopPropagation();
                  props.onSelectObject?.(id);
                }
              }}
            />
          );
        })}
      <RadarWeapons
        weapons={props.weapons || []}
        onSelect={props.locked ? undefined : props.onSelectWeapon}
      />
      {compass && props.fillViewport && scope.current?.parentElement
        ? createPortal(compass, scope.current.parentElement)
        : compass}
    </RadarMotionContext.Provider>
  );
};

const RadarDefinitions = memo(({ cellSpan }: { cellSpan: number }) => {
  const hatchPitch = cellSpan * 0.2;
  return (
    <defs>
      {HAZARD_HATCH_FLAVOURS.map((flavour) =>
        Array.from({ length: HAZARD_HATCH_STEPS }, (_, stepIndex) => {
          const step = stepIndex + 1;
          const pitch = hatchPitch / step;
          return (
            <pattern
              key={flavour + step}
              id={hazardHatchId(flavour, step)}
              patternUnits="userSpaceOnUse"
              width={pitch}
              height={pitch}
              patternTransform="rotate(45)"
            >
              <line
                className={`OvermapRadar__hatch OvermapRadar__hatch--${flavour}`}
                x1={0}
                y1={0}
                x2={0}
                y2={pitch}
                strokeWidth={Math.max(pitch * 0.34, 1)}
              />
            </pattern>
          );
        }),
      )}
    </defs>
  );
});

const MemoizedRadarRim = memo(RadarRim);
