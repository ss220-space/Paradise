import {
  type MouseEvent,
  type ReactNode,
  useEffect,
  useId,
  useMemo,
  useRef,
  useState,
  type WheelEvent,
} from 'react';
import { Icon } from 'tgui-core/components';
import { classes } from 'tgui-core/react';
import { overmapKindIcon, overmapKindLabel } from './OvermapChrome';
import { type RadarDock, radarClickWorld } from './radarInterpolation';
import { GEOMETRY_FADE, GEOMETRY_FULL, radarWheelZoom } from './radarZoom';
import { useRadarInterpolation } from './useRadarInterpolation';
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
  distance?: number;
  closing?: number;
  docked?: boolean;
};

export type RadarEngine = [number, number, number, number];

export type RadarProjectile = {
  id: string;
  x: number;
  y: number;
  angle: number;
};

export type RadarObject = {
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

const EMPTY_OBJECTS: RadarObject[] = [];

export type GalaxySector = {
  distances?: Record<string, number>;
  id: string;
  name: string;
  kind: string;
  x: number;
  y: number;
  links: string[];
  signal_links?: string[];
  contacts: number;
  distress: boolean | number;

  unknown?: boolean;
};

export type GalaxyMap = {
  revision: number;
  sectors: GalaxySector[];
  center?: string;
  transits?: {
    id: string;
    from: string;
    to: string;
    progress: number;
    remaining: number;
    own: boolean | number;
  }[];
};

const NOZZLE_VECTORS: Record<number, number[]> = {
  1: [0, 1],
  2: [0, -1],
  4: [1, 0],
  8: [-1, 0],
};

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
  cellSpan: number = RADAR_TILE_SPAN,
) =>
  metres >= cellSpan
    ? `${(metres / cellSpan).toFixed(2)} кл.`
    : `${Math.round(metres)} м`;

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

const shipFrameFraction = (
  x: number,
  y: number,
  radius: number,
  followHeading: boolean,
  facing: number,
): [number, number] => {
  if (followHeading) {
    return [x / radius, -y / radius];
  }
  const rad = (facing * Math.PI) / 180;
  const screenX = x * Math.cos(rad) + y * Math.sin(rad);
  const screenY = x * Math.sin(rad) - y * Math.cos(rad);
  return [screenX / radius, screenY / radius];
};

const worldFrameFraction = (
  x: number,
  y: number,
  radius: number,
  followHeading: boolean,
  facing: number,
): [number, number] => {
  if (!followHeading) {
    return [x / radius, -y / radius];
  }
  const rad = (facing * Math.PI) / 180;
  const screenX = x * Math.cos(rad) - y * Math.sin(rad);
  const screenY = -(x * Math.sin(rad) + y * Math.cos(rad));
  return [screenX / radius, screenY / radius];
};

const RadarEngines = (props: { engines: RadarEngine[] }) => (
  <>
    {props.engines.map(([x, y, dir, firing], index) => {
      const [dx, dy] = NOZZLE_VECTORS[dir] || [0, -1];
      return (
        <g key={index}>
          {!!firing && (
            <line
              className="OvermapRadar__burn"
              x1={x + dx * 0.6}
              y1={y + dy * 0.6}
              x2={x + dx * 2.6}
              y2={y + dy * 2.6}
            />
          )}
          <circle
            className={
              firing
                ? 'OvermapRadar__engine OvermapRadar__engine--firing'
                : 'OvermapRadar__engine'
            }
            cx={x + dx * 0.5}
            cy={y + dy * 0.5}
            r={0.35}
          />
        </g>
      );
    })}
  </>
);

export type RadarScatterChunk = {
  x: number;
  y: number;
  carp: boolean | number;
  runs: number[];
};

const ScatterLayer = (props: {
  chunks: RadarScatterChunk[];
  world?: number[];
  facing: number;
  followHeading: boolean;
  opacity: number;
}) => {
  const { chunks, world, facing, followHeading, opacity } = props;
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
    <g
      opacity={opacity}
      transform={`scale(1 -1) rotate(${followHeading ? facing : 0}) translate(${-(world?.[0] || 0)} ${-(world?.[1] || 0)})`}
    >
      <path d={paths[0]} fill="#bfa58d" />
      <path d={paths[1]} fill="#77cdab" />
    </g>
  );
};

const GeometryLayer = (props: {
  terrain?: RadarTerrain | null;
  shapes: Record<string, RadarShape>;
  contacts: RadarContact[];
  world?: number[];
  facing: number;
  followHeading: boolean;
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
    followHeading,
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

  const shift =
    terrain && world ? [terrain.x - world[0], terrain.y - world[1]] : [0, 0];
  const worldRotation = followHeading ? facing : 0;

  const frameRotation = followHeading ? 0 : -facing;
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
    <g
      className="OvermapRadar__bloom"
      opacity={opacity}
      transform="scale(1 -1)"
    >
      {!!terrain && (
        <g transform={`rotate(${worldRotation})`}>
          <g transform={`translate(${shift[0]} ${shift[1]})`}>
            <path className="OvermapRadar__floor" d={paths.floors} />
            <path className="OvermapRadar__frame" d={paths.frames} />
            <path className="OvermapRadar__wall" d={paths.walls} />
            <path className="OvermapRadar__collar" d={paths.docks} />
          </g>
        </g>
      )}
      <g transform={`rotate(${frameRotation})`}>
        {drifters.map((drifter, index) => (
          <g key={index} transform={`translate(${drifter[0]} ${drifter[1]})`}>
            {drifter[2] ? (
              <circle r={0.5} fill="#ff4545" />
            ) : (
              <circle className="OvermapRadar__drifter" r={2} />
            )}
          </g>
        ))}
        {contacts.map((contact) => {
          const {
            hull = '',
            collars = '',
            known = false,
          } = hulls.get(contact.id) || {};
          const tone = contact.own
            ? 'OvermapRadar__hull--own'
            : contact.docked
              ? 'OvermapRadar__hull--docked'
              : 'OvermapRadar__hull--other';
          return (
            <g
              key={contact.id}
              transform={`translate(${contact.x} ${contact.y}) rotate(${-(contact.rot || 0)})`}
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
            </g>
          );
        })}
        <RadarEngines engines={engines} />
      </g>
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
  objects: RadarObject[];
  self: number[];
  cellSpan: number;
  rotation: number;
  offset: [number, number];
  sensorReach: number;
  soft?: boolean;
}) => {
  const { fields, self, cellSpan, rotation, offset, sensorReach, soft } = props;
  const prefix = useId().replace(/:/g, '');
  const paths = useMemo(
    () => fields.map((field) => cloudPath(field.contours || [], cellSpan)),
    [fields, cellSpan],
  );
  return (
    <g
      transform={`scale(1 -1) rotate(${rotation}) translate(${-offset[0]} ${-offset[1]})`}
    >
      <defs>
        <filter
          id={`${prefix}-soft`}
          x="-30%"
          y="-30%"
          width="160%"
          height="160%"
        >
          <feGaussianBlur stdDeviation={cellSpan * 0.018} />
        </filter>
        <radialGradient id={`${prefix}-scan`}>
          <stop offset="0%" stopColor="white" />
          <stop offset="75%" stopColor="white" />
          <stop offset="100%" stopColor="white" stopOpacity="0" />
        </radialGradient>
      </defs>
      <g transform={`translate(${-self[0] * cellSpan} ${-self[1] * cellSpan})`}>
        {fields.map((field, index) => {
          const path = paths[index];
          if (!path) return null;
          const mask = `${prefix}-cloud-${index}`;
          const vertices = field.contours || [];
          const xs = vertices.flatMap((ring) =>
            ring.filter((_, i) => i % 2 === 0),
          );
          const ys = vertices.flatMap((ring) =>
            ring.filter((_, i) => i % 2 === 1),
          );
          const minX = Math.min(...xs) * cellSpan - 1;
          const minY = Math.min(...ys) * cellSpan - 1;
          const width = Math.max(...xs) * cellSpan - minX + 1;
          const height = Math.max(...ys) * cellSpan - minY + 1;
          const tone = field.scanned
            ? field.kind === 'emp'
              ? '#589bff'
              : field.kind === 'carp'
                ? '#64dba0'
                : '#d3a576'
            : '#ee626c';
          return (
            <g key={index}>
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
                    <circle
                      cx={self[0] * cellSpan}
                      cy={self[1] * cellSpan}
                      r={sensorReach * cellSpan}
                      fill={`url(#${prefix}-scan)`}
                    />
                  )}
                </mask>
              </defs>
              <g
                mask={soft ? undefined : `url(#${mask})`}
                filter={soft ? `url(#${prefix}-soft)` : undefined}
              >
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
                <path
                  d={path}
                  fillRule="evenodd"
                  fill="none"
                  stroke={tone}
                  strokeOpacity={soft ? 0 : 0.5}
                  strokeWidth={1}
                  vectorEffect="non-scaling-stroke"
                />
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
      </g>
    </g>
  );
};

const SensorPeel = (props: {
  peel: RadarPeel;
  x: number;
  y: number;
  cellSpan: number;
}) => {
  const { peel, x, y, cellSpan } = props;
  const delay = useRef(-peel.age % peel.period).current;
  return (
    <g transform={`translate(${x} ${y})`}>
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
    </g>
  );
};

const POINT_OBJECT_HALF = 0.12;

const ObjectLayer = (props: {
  showSelf?: boolean;
  outlines?: Record<string, string>;
  objects: RadarObject[];
  self?: number[];
  cellSpan: number;
  radius: number;
  rotation: number;
  offset: [number, number];
}) => {
  const { objects, self, cellSpan, radius, rotation, offset } = props;
  const built = useMemo(
    () =>
      objects
        .filter(
          (object) =>
            (!object.is_self || props.showSelf) && object.kind !== 'hazard',
        )
        .map((object, index) => {
          const size = Math.max(object.size || 1, 1);
          const cx = (object.x + size / 2 - 0.5 - (self?.[0] ?? 0)) * cellSpan;
          const cy = (object.y + size / 2 - 0.5 - (self?.[1] ?? 0)) * cellSpan;
          return {
            object,
            index,
            cx,
            cy,
            size,
            color: object.color || '#8fd0ff',

            opacity: Math.max(object.visibility ?? 1, 0.3),
          };
        }),
    [objects, self, cellSpan, props.showSelf],
  );
  if (!built.length) {
    return null;
  }
  const labelSize = Math.max(radius / 40, 9);
  return (
    <g transform="scale(1 -1)">
      <g transform={`rotate(${rotation})`}>
        <g
          className="OvermapRadar__objectLayer"
          transform={`translate(${-offset[0]} ${-offset[1]})`}
        >
          {built.map(({ object, index, cx, cy, size, color, opacity }) => {
            if (object.kind === 'planet') {
              const planetRadius = (size / 2) * cellSpan;
              return (
                <g key={`${object.name}-${index}`} opacity={opacity}>
                  <circle
                    className="OvermapRadar__planet"
                    cx={cx}
                    cy={cy}
                    r={planetRadius}
                    style={{ fill: color, stroke: color }}
                  />
                  <g
                    transform={`translate(${cx} ${cy - planetRadius - labelSize}) scale(1 -1)`}
                  >
                    <text
                      className="OvermapRadar__objectName"
                      fontSize={labelSize}
                      textAnchor="middle"
                    >
                      {object.name}
                    </text>
                  </g>
                </g>
              );
            }
            const half = Math.max(
              radius / 45,
              Math.min(size * cellSpan * 0.12, radius / 24),
            );
            const point = object.kind === 'relay' || object.kind === 'portal';
            const span = point
              ? Math.min(cellSpan * POINT_OBJECT_HALF, radius / 30)
              : half;

            const unknown = object.kind === 'unknown';
            const shape = point
              ? `M${cx} ${cy - span}L${cx + span} ${cy}L${cx} ${cy + span}L${cx - span} ${cy}Z`
              : null;
            return (
              <g
                key={`${object.kind}-${object.name}-${index}`}
                opacity={opacity}
              >
                {shape ? (
                  <path
                    className="OvermapRadar__objectShape"
                    d={shape}
                    style={{ fill: color, stroke: color }}
                  />
                ) : object.id && props.outlines?.[object.id] ? (
                  <path
                    className="OvermapRadar__objectShape"
                    d={props.outlines[object.id]}
                    transform={`translate(${cx} ${cy}) rotate(${-(object.facing || 0)})`}
                    style={{ fill: 'none', stroke: color }}
                    strokeWidth={1.2}
                    vectorEffect="non-scaling-stroke"
                  />
                ) : object.extent ? (
                  <ellipse
                    className="OvermapRadar__objectShape"
                    cx={cx}
                    cy={cy}
                    rx={Math.max(object.extent[0] / 2, radius / 100)}
                    ry={Math.max(object.extent[1] / 2, radius / 100)}
                    style={{ fill: color, stroke: color }}
                  />
                ) : (
                  <circle
                    className={classes([
                      'OvermapRadar__objectShape',
                      object.kind === 'ruin' &&
                        'OvermapRadar__objectShape--ruin',
                      unknown && 'OvermapRadar__objectShape--unknown',
                    ])}
                    cx={cx}
                    cy={cy}
                    r={span}
                    style={unknown ? undefined : { fill: color, stroke: color }}
                  />
                )}
                {!!object.distress && (
                  <circle
                    className="OvermapRadar__objectAlarm"
                    cx={cx}
                    cy={cy}
                    r={span * 1.5}
                  />
                )}
              </g>
            );
          })}
        </g>
      </g>
    </g>
  );
};

const SectorLayer = (props: {
  sectorSize: number;
  cellSpan: number;
  self?: number[];
  radius: number;
  opacity: number;
  rotation: number;
  offset: [number, number];
  dest?: number[];
}) => {
  const {
    sectorSize,
    cellSpan,
    self,
    radius,
    opacity,
    rotation,
    offset,
    dest,
  } = props;
  const step = radius > cellSpan * 7 ? 5 : 1;
  const grid = useMemo(() => {
    if (!self || sectorSize <= 0) {
      return [];
    }
    const built: ReactNode[] = [];
    const lowX = (0 - self[0]) * cellSpan;
    const highX = (sectorSize - self[0]) * cellSpan;
    const lowY = (0 - self[1]) * cellSpan;
    const highY = (sectorSize - self[1]) * cellSpan;
    const labelSize = Math.max(radius / 46, 8);
    for (let cell = 0; cell <= sectorSize; cell += step) {
      const major = cell % 5 === 0;
      const x = (cell - self[0]) * cellSpan;
      const y = (cell - self[1]) * cellSpan;
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
  }, [self, sectorSize, cellSpan, radius, step]);
  if (opacity <= 0.01 || !self || sectorSize <= 0) {
    return null;
  }
  const destX = dest ? (dest[0] - self[0]) * cellSpan : 0;
  const destY = dest ? (dest[1] - self[1]) * cellSpan : 0;
  return (
    <g opacity={opacity} transform="scale(1 -1)">
      <g transform={`rotate(${rotation})`}>
        <g
          className="OvermapRadar__bloom"
          transform={`translate(${-offset[0]} ${-offset[1]})`}
        >
          <rect
            className="OvermapRadar__cellArea"
            x={(0 - self[0]) * cellSpan}
            y={(0 - self[1]) * cellSpan}
            width={sectorSize * cellSpan}
            height={sectorSize * cellSpan}
          />
          {grid}
          {!!dest && (
            <g
              className="OvermapRadar__destMark"
              transform={`translate(${destX} ${destY})`}
            >
              <line
                className="OvermapRadar__destRoute"
                x1={-destX}
                y1={-destY}
                x2={0}
                y2={0}
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
        </g>
      </g>
    </g>
  );
};

const GalaxyLayer = (props: {
  galaxy: GalaxyMap;
  sectorId?: string;
  radius: number;
  opacity: number;

  slot: number;
  rotation: number;
}) => {
  const { galaxy, sectorId, radius, opacity, slot } = props;
  const [selectedId, setSelectedId] = useState<string | undefined>(sectorId);
  const [flightAge, setFlightAge] = useState(0);
  useEffect(() => {
    setFlightAge(0);
    if (!galaxy.transits?.length) return;
    const started = performance.now();
    let animation = 0;
    const tick = (now: number) => {
      setFlightAge(now - started);
      animation = requestAnimationFrame(tick);
    };
    animation = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(animation);
  }, [galaxy.transits]);
  const nodes = useMemo(() => {
    const sectors = galaxy.sectors;
    const center = sectors.find((sector) => sector.id === galaxy.center);
    const centerX = center?.x || 0;
    const centerY = center?.y || 0;
    const extent = Math.max(
      1,
      ...sectors.map((sector) =>
        Math.max(Math.abs(sector.x - centerX), Math.abs(sector.y - centerY)),
      ),
    );
    const scale = (slot * 2.4 * 1.15 * 0.72) / extent;
    return sectors.map((sector) => ({
      sector,
      x: (sector.x - centerX) * scale,
      y: -(sector.y - centerY) * scale,
    }));
  }, [galaxy, slot]);
  if (!nodes.length || opacity <= 0) return null;
  const selected =
    nodes.find((node) => node.sector.id === selectedId) ||
    nodes.find((node) => node.sector.id === sectorId);
  const byId = new Map(nodes.map((node) => [node.sector.id, node]));
  const dot = radius * 0.017;
  return (
    <g className="OvermapGalaxy" opacity={opacity}>
      <ellipse
        className="OvermapGalaxy__orbit"
        rx={radius * 0.85}
        ry={radius * 0.43}
        transform="rotate(-28)"
      />
      <ellipse
        className="OvermapGalaxy__orbit"
        rx={radius * 0.67}
        ry={radius * 0.26}
        transform="rotate(-28)"
      />
      {Array.from({ length: 70 }, (_, index) => (
        <circle
          key={index}
          className="OvermapGalaxy__star"
          cx={Math.sin(index * 127.1) * radius * 0.94}
          cy={Math.cos(index * 311.7) * radius * 0.9}
          r={radius * (index % 5 === 0 ? 0.002 : 0.001)}
        />
      ))}
      {nodes.flatMap((node) =>
        node.sector.links.map((id) => {
          const target = byId.get(id);
          if (!target || id < node.sector.id) return null;
          const active = node === selected || target === selected;
          const signal =
            node.sector.signal_links?.includes(id) ||
            target.sector.signal_links?.includes(node.sector.id);
          const midX = (node.x + target.x) / 2;
          const midY = (node.y + target.y) / 2 - radius * 0.07;
          return (
            <g key={`${node.sector.id}-${id}`}>
              <path
                className={classes([
                  'OvermapGalaxy__route',
                  active && 'OvermapGalaxy__route--active',
                  !signal && 'OvermapGalaxy__route--uncertain',
                ])}
                d={`M${node.x} ${node.y} Q${midX} ${midY} ${target.x} ${target.y}`}
              />
              <text
                x={midX}
                y={(node.y + target.y) / 2 - radius * 0.035}
                fontSize={radius * 0.018}
                fill="#8fa8c2"
                textAnchor="middle"
              >
                {node.sector.distances?.[id] ||
                  target.sector.distances?.[node.sector.id] ||
                  ''}
              </text>
            </g>
          );
        }),
      )}
      {galaxy.transits?.map((flight) => {
        const from = byId.get(flight.from);
        const to = byId.get(flight.to);
        if (!from || !to) return null;
        const t = Math.min(
          1,
          flight.progress +
            ((1 - flight.progress) * flightAge) / Math.max(flight.remaining, 1),
        );
        const u = 1 - t;
        const midX = (from.x + to.x) / 2;
        const midY = (from.y + to.y) / 2 - radius * 0.07;
        const x = u * u * from.x + 2 * u * t * midX + t * t * to.x;
        const y = u * u * from.y + 2 * u * t * midY + t * t * to.y;
        const angle =
          (Math.atan2(
            u * (midY - from.y) + t * (to.y - midY),
            u * (midX - from.x) + t * (to.x - midX),
          ) *
            180) /
          Math.PI;
        const size = radius * 0.012;
        return (
          <path
            key={flight.id}
            d={`M${size} 0L${-size} ${size * 0.7}L${-size * 0.5} 0L${-size} ${-size * 0.7}Z`}
            transform={`translate(${x} ${y}) rotate(${angle})`}
            fill={flight.own ? '#76ffc1' : '#f3ba85'}
          >
            <title>{flight.own ? 'Ваш корабль' : 'Корабль в переходе'}</title>
          </path>
        );
      })}
      {nodes.map((node) => {
        const current = node.sector.id === sectorId;
        const picked = node === selected;
        const unknown = node.sector.unknown;
        return (
          <g
            key={node.sector.id}
            transform={`translate(${node.x} ${node.y})`}
            className={classes([
              'OvermapGalaxy__node',
              current && 'OvermapGalaxy__node--current',
              picked && 'OvermapGalaxy__node--selected',
              unknown && 'OvermapGalaxy__node--unknown',
            ])}
            role="button"
            tabIndex={0}
            aria-label={node.sector.name}
            onClick={() => setSelectedId(node.sector.id)}
            onKeyDown={(event) => {
              if (event.key === 'Enter' || event.key === ' ')
                setSelectedId(node.sector.id);
            }}
          >
            <title>{unknown ? 'Неизвестный сектор' : node.sector.name}</title>
            <circle r={dot * 3.4} fill="transparent" />
            <circle className="OvermapGalaxy__halo" r={dot * 2.2} />
            <path
              className="OvermapGalaxy__bracket"
              d={`M${-dot * 2.7} ${-dot}v${-dot}h${dot} M${dot * 2.7} ${dot}v${dot}h${-dot}`}
            />
            <circle
              className="OvermapGalaxy__core"
              r={unknown ? dot * 0.5 : dot}
            />
            {!!node.sector.distress && (
              <circle r={dot * 3} className="OvermapGalaxy__distress" />
            )}
            <text
              className="OvermapGalaxy__name"
              x={dot * 3.4}
              y={dot * 0.4}
              fontSize={radius / 37}
            >
              {unknown ? 'НЕИЗВЕСТНО' : node.sector.name}
            </text>
            {current && (
              <text
                className="OvermapGalaxy__here"
                x={dot * 3.4}
                y={dot * 2.4}
                fontSize={radius / 49}
              >
                ТЕКУЩИЙ СЕКТОР
              </text>
            )}
          </g>
        );
      })}
      <text
        className="OvermapGalaxy__heading"
        x={-radius * 0.89}
        y={-radius * 0.83}
        fontSize={radius / 33}
      >
        МЕЖСЕКТОРНАЯ СЕТЬ
      </text>
      {!!selected && (
        <text
          className="OvermapGalaxy__detail"
          x={-radius * 0.89}
          y={radius * 0.89}
          fontSize={radius / 38}
        >
          {selected.sector.unknown
            ? 'Сигнатура не исследована'
            : `${selected.sector.name} · связей ${selected.sector.links.length}${selected.sector.distress ? ' · SOS' : ''}`}
        </text>
      )}
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
  facing: number;
  followHeading: boolean;
  onToggle: () => void;
}) => {
  const { facing, followHeading, onToggle } = props;
  const northAngle = followHeading ? -facing : 0;
  const shipAngle = followHeading ? 0 : facing;
  return (
    <button
      type="button"
      className="OvermapRadar__compass"
      title={'Переключить режим.'}
      onClick={onToggle}
    >
      <svg viewBox="-50 -50 100 100">
        <circle className="OvermapRadar__compassRing" r={44} />
        <g transform={`rotate(${northAngle})`}>
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
        </g>
        <g transform={`rotate(${shipAngle})`}>
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
        </g>
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

  slot: number;
  galaxy: boolean;
}) => {
  const { radius, cellSpan, slot, galaxy } = props;
  return (
    <div className="OvermapRadar__ruler">
      <div className="OvermapRadar__rulerBar">
        <span className="OvermapRadar__rulerTick" />
        <span className="OvermapRadar__rulerLine" />
        <span className="OvermapRadar__rulerTick" />
      </div>
      <span className="OvermapRadar__rulerLabel">
        {galaxy
          ? `${(radius / slot).toFixed(1)} сектора`
          : formatRadarDistance(radius / 2, cellSpan)}
      </span>
    </div>
  );
};

const RadarZoom = (props: {
  radius: number;
  onZoom: (radius: number) => void;
  threshold: number;

  ceiling: number;

  sectorSpan: number;
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
    <div className="OvermapRadar__zoom">
      <button
        type="button"
        className="OvermapRadar__zoomButton"
        title="Приблизить"
        onClick={() => nudge(false)}
      >
        +
      </button>
      <button
        type="button"
        className="OvermapRadar__zoomButton"
        title="Отдалить"
        onClick={() => nudge(true)}
      >
        −
      </button>
      {}
      <button
        type="button"
        className="OvermapRadar__zoomButton OvermapRadar__zoomButton--band"
        title={radius > threshold ? 'сектор' : 'глобально'}
        onClick={() =>
          onZoom(
            clampRadarZoom(
              radius > threshold ? sectorSpan * 0.5 : threshold * 1.15,
              ceiling,
            ),
          )
        }
      >
        {radius > threshold ? '◻' : '✦'}
      </button>
    </div>
  );
};

const MarkerOverlay = (props: {
  radius: number;
  cellSpan: number;
  followHeading: boolean;
  facing: number;
  contacts: RadarContact[];
  objects: RadarObject[];
  self?: number[];
  geometry: number;

  offset: [number, number];

  filter: string;
}) => {
  const {
    radius,
    cellSpan,
    followHeading,
    facing,
    contacts,
    objects,
    self,
    geometry,
    offset,
    filter,
  } = props;
  const place = (x: number, y: number) => {
    const [fx, fy] = shipFrameFraction(x, y, radius, followHeading, facing);
    return {
      left: `${50 + fx * 50}%`,
      top: `${50 + fy * 50}%`,
      hidden: Math.abs(fx) > 1.05 || Math.abs(fy) > 1.05,
    };
  };
  const placeWorld = (x: number, y: number) => {
    const [fx, fy] = worldFrameFraction(x, y, radius, followHeading, facing);
    return {
      left: `${50 + fx * 50}%`,
      top: `${50 + fy * 50}%`,
      hidden: Math.abs(fx) > 1.05 || Math.abs(fy) > 1.05,
    };
  };
  const selfSpot = placeWorld(-offset[0], -offset[1]);
  const markers: ReactNode[] = [
    <div
      key="self"
      className="OvermapRadar__marker OvermapRadar__marker--self"
      style={{ left: selfSpot.left, top: selfSpot.top }}
    >
      <span
        className="OvermapRadar__self"
        style={{ transform: `rotate(${followHeading ? 0 : facing}deg)` }}
      />
      <span className="OvermapRadar__markerLabel">вы</span>
    </div>,
  ];

  if (geometry < 0.9) {
    for (const object of objects) {
      if (object.is_self || object.kind === 'hazard') {
        continue;
      }

      const spot = placeWorld(
        (object.x +
          Math.max(object.size || 1, 1) / 2 -
          0.5 -
          (self?.[0] ?? 0)) *
          cellSpan -
          offset[0],
        (object.y +
          Math.max(object.size || 1, 1) / 2 -
          0.5 -
          (self?.[1] ?? 0)) *
          cellSpan -
          offset[1],
      );
      if (spot.hidden) {
        continue;
      }
      markers.push(
        <div
          key={`${object.kind}-${object.name}-${object.x}-${object.y}`}
          className={classes([
            'OvermapRadar__marker',
            filter !== 'all' &&
              object.kind !== filter &&
              'OvermapRadar__marker--dim',
          ])}
          style={{
            left: spot.left,
            top: spot.top,
            opacity: Math.max(object.visibility ?? 1, 0.3),
          }}
          title={`${object.name} (${object.x}:${object.y})`}
        >
          <Icon
            name={overmapKindIcon(object.kind)}
            className={
              object.distress
                ? 'OvermapRadar__markerIcon OvermapRadar__markerIcon--sos'
                : 'OvermapRadar__markerIcon'
            }
            style={{ color: object.color || undefined }}
          />
          <span className="OvermapRadar__markerLabel">
            {object.name}
            <em>{overmapKindLabel(object.kind)}</em>
          </span>
        </div>,
      );
    }
  }
  if (geometry > 0.5) {
    for (const contact of contacts) {
      if (contact.own || (contact.distance || 0) > radius) {
        continue;
      }
      const spot = place(contact.x, contact.y);
      if (spot.hidden) {
        continue;
      }
      markers.push(
        <div
          key={contact.id}
          className="OvermapRadar__marker OvermapRadar__marker--contact"
          style={{ left: spot.left, top: spot.top }}
        >
          <Icon name="shuttle-space" className="OvermapRadar__markerIcon" />
          <span className="OvermapRadar__markerLabel">
            {contact.name}
            <em>{formatRadarDistance(contact.distance || 0)}</em>
          </span>
        </div>,
      );
    }
  }
  return <div className="OvermapRadar__overlay">{markers}</div>;
};

export const OvermapRadar = (props: {
  outlines?: Record<string, string>;
  showSelf?: boolean;
  shapes: Record<string, RadarShape>;
  contacts: RadarContact[];
  drifters: number[][];
  projectiles?: RadarProjectile[];
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
  overlay?: ReactNode;
  onSelectObject?: (id: string) => void;
  onSelectPoint?: (x: number, y: number) => void;
  scatter?: RadarScatterChunk[];
  peels?: RadarPeel[];
  dockTargets?: RadarDock[];
  dockPreview?: { x: number; y: number; facing: number; tiles: number[] };
  onSelectDock?: (id: string) => void;
  tick?: number;
  epoch?: number;
  locked?: boolean;
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
    galaxy,
    radius: requestedRadius = 64,
    onZoom,
    onReach,
    followHeading = true,
    onToggleFollow,
    dest,
    filter = 'all',
    hazardFields = [],
  } = props;
  const scope = useRef<HTMLDivElement>(null);
  const requestedReach = useRef<number | undefined>(undefined);
  const sectorSpan = Math.max(cellSpan * sectorSize, cellSpan * 4);
  const radius = props.locked
    ? galaxyBandFor(sectorSpan) * 1.15
    : requestedRadius;
  const {
    contacts,
    drifters,
    facing,
    world,
    self,
    objects,
    dockTargets,
    projectiles,
  } = useRadarInterpolation({
    tick: props.tick,
    epoch: props.epoch,
    sectorId,
    cellSpan,
    contacts: rawContacts,
    drifters: rawDrifters,
    facing: rawFacing,
    world: rawWorld,
    self: rawSelf,
    objects: rawObjects || EMPTY_OBJECTS,
    dockTargets: props.dockTargets,
    projectiles: props.projectiles,
  });
  const geometry = geometryOpacity(radius);

  const galaxySlot = galaxySlotFor(sectorSpan);
  const galaxyBandRadius = galaxyBandFor(sectorSpan);
  const zoomCeiling = radarZoomCeiling(sectorSpan);
  const galaxyBand = !!props.locked || radius > galaxyBandRadius;
  const rotation = followHeading ? facing : 0;
  const nearBand = !galaxyBand && radius <= BAND_GEOMETRY_FULL;

  const drift = Math.max(
    0,
    Math.min(1, (radius - sectorSpan * 0.35) / (sectorSpan * 0.45)),
  );
  const offset: [number, number] = self
    ? [
        ((sectorSize + 1) / 2 - self[0]) * cellSpan * drift,
        ((sectorSize + 1) / 2 - self[1]) * cellSpan * drift,
      ]
    : [0, 0];

  const chartOffset = offset;

  const reach =
    geometry > 0.01
      ? Math.min(128, Math.max(32, Math.round(radius * 1.1)))
      : 32;
  useEffect(() => {
    if (!onReach) {
      requestedReach.current = undefined;
      return;
    }
    if (requestedReach.current === reach) return;
    requestedReach.current = reach;
    onReach(reach);
  }, [onReach, reach]);
  const north =
    followHeading && !galaxyBand ? ((-facing % 360) + 360) % 360 : 0;
  const labelSize = radius / 20;

  const hatchPitch = cellSpan * 0.2;
  const wheel = (event: WheelEvent<HTMLDivElement>) => {
    if (!onZoom || props.locked) {
      return;
    }
    event.preventDefault();
    onZoom(
      clampRadarZoom(
        radarWheelZoom(radius, event.deltaY > 0, galaxyBandRadius),
        zoomCeiling,
      ),
    );
  };
  const selectPoint = (event: MouseEvent<HTMLDivElement>, firing: boolean) => {
    if (galaxyBand || props.overlay || !props.onSelectPoint || !world) return;
    if (
      (event.target as Element).closest(
        firing
          ? 'input,select,textarea,.OvermapRadar__controls,.OvermapRadar__bands'
          : 'button,input,select,textarea,.OvermapRadar__controls',
      )
    )
      return;
    const bounds = event.currentTarget.getBoundingClientRect();
    const side = Math.min(bounds.width, bounds.height);
    const screen = [
      ((event.clientX - bounds.left - bounds.width / 2) * 2) / side,
      ((event.clientY - bounds.top - bounds.height / 2) * 2) / side,
    ];
    if (Math.hypot(...screen) > 1) return;
    const point = radarClickWorld(screen, radius, rotation, world, chartOffset);
    if (firing) event.stopPropagation();
    props.onSelectPoint(point[0], point[1]);
  };
  return (
    <div className="OvermapRadar" onWheel={wheel}>
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
            onClick={() => onZoom(Math.max(220, sectorSpan * 0.55))}
          >
            Сектор
          </button>
          <button
            type="button"
            className={galaxyBand ? 'selected' : ''}
            onClick={() => onZoom(galaxyBandRadius * 1.15)}
          >
            Глобально
          </button>
        </div>
      )}
      <div
        className="OvermapRadar__scope"
        ref={scope}
        onClickCapture={(event) => {
          if (props.weaponArcs?.length) selectPoint(event, true);
        }}
        onClick={(event) => selectPoint(event, false)}
      >
        {!galaxyBand && (
          <svg
            className="OvermapRadar__peels"
            viewBox={`${-radius} ${-radius} ${radius * 2} ${radius * 2}`}
          >
            {!nearBand &&
              props.peels?.map((peel) => {
                const own =
                  peel.id === contacts.find((contact) => contact.own)?.id;
                const [px, py] = worldFrameFraction(
                  (own ? 0 : (peel.x - (self?.[0] || 0)) * cellSpan) -
                    chartOffset[0],
                  (own ? 0 : (peel.y - (self?.[1] || 0)) * cellSpan) -
                    chartOffset[1],
                  radius,
                  followHeading,
                  facing,
                );
                return (
                  <SensorPeel
                    key={peel.id}
                    peel={peel}
                    x={px * radius}
                    y={py * radius}
                    cellSpan={cellSpan}
                  />
                );
              })}
          </svg>
        )}
        {!!props.onSelectObject &&
          !galaxyBand &&
          hazardFields
            .filter((field) => field.id)
            .map((field) => {
              const cell = field.cells[0];
              if (!cell) return null;
              const [px, py] = worldFrameFraction(
                (cell[0] - (self?.[0] || 0)) * cellSpan - chartOffset[0],
                (cell[1] - (self?.[1] || 0)) * cellSpan - chartOffset[1],
                radius,
                followHeading,
                facing,
              );
              return (
                <button
                  type="button"
                  key={field.id}
                  title="Выбрать облако для сканирования"
                  className="OvermapRadar__pick"
                  style={{ left: `${50 + px * 50}%`, top: `${50 + py * 50}%` }}
                  onClick={() => props.onSelectObject?.(field.id!)}
                />
              );
            })}
        {nearBand &&
          dockTargets?.map((dock) => {
            const [px, py] = worldFrameFraction(
              dock.x - (world?.[0] || 0) - chartOffset[0],
              dock.y - (world?.[1] || 0) - chartOffset[1],
              radius,
              followHeading,
              facing,
            );
            if (Math.abs(px) > 1 || Math.abs(py) > 1) return null;
            return (
              <button
                type="button"
                key={dock.id}
                title={`${dock.own ? 'Свой шлюз' : 'Стыковка'}: ${dock.name}${dock.available === false || dock.available === 0 ? ' · недоступен' : ''}`}
                className={classes([
                  'OvermapRadar__pick',
                  'OvermapRadar__pick--dock',
                  dock.own && 'OvermapRadar__pick--own',
                  dock.selected && 'OvermapRadar__pick--selected',
                ])}
                disabled={dock.available === false || dock.available === 0}
                style={{ left: `${50 + px * 50}%`, top: `${50 + py * 50}%` }}
                onClick={() => props.onSelectDock?.(dock.id)}
              >
                <Icon name="anchor" />
              </button>
            );
          })}
        {!!props.dockPreview && nearBand && (
          <svg
            className="OvermapRadar__approach"
            viewBox={`${-radius} ${-radius} ${radius * 2} ${radius * 2}`}
          >
            {(() => {
              const preview = props.dockPreview!;
              const [px, py] = worldFrameFraction(
                preview.x - (world?.[0] || 0) - chartOffset[0],
                preview.y - (world?.[1] || 0) - chartOffset[1],
                radius,
                followHeading,
                facing,
              );
              return (
                <g
                  transform={`translate(${px * radius} ${py * radius}) rotate(${preview.facing - (followHeading ? facing : 0)}) scale(1 -1)`}
                >
                  <path
                    d={cellsPath(preview.tiles || [])}
                    fill="rgba(70,150,255,0.3)"
                    stroke="#68b5ff"
                    strokeWidth={0.1}
                  />
                </g>
              );
            })()}
          </svg>
        )}
        {!!props.onSelectObject &&
          !galaxyBand &&
          objects
            .filter((object) => object.id && !object.is_self)
            .map((object) => {
              const [px, py] = worldFrameFraction(
                (object.x +
                  Math.max(object.size || 1, 1) / 2 -
                  0.5 -
                  (self?.[0] || 0)) *
                  cellSpan -
                  chartOffset[0],
                (object.y +
                  Math.max(object.size || 1, 1) / 2 -
                  0.5 -
                  (self?.[1] || 0)) *
                  cellSpan -
                  chartOffset[1],
                radius,
                followHeading,
                facing,
              );
              if (Math.abs(px) > 1 || Math.abs(py) > 1) return null;
              return (
                <button
                  type="button"
                  key={object.id}
                  title={object.name}
                  className="OvermapRadar__pick"
                  style={{ left: `${50 + px * 50}%`, top: `${50 + py * 50}%` }}
                  onClick={() => props.onSelectObject?.(object.id!)}
                />
              );
            })}
        <svg
          className="OvermapRadar__svg"
          viewBox={`${-radius} ${-radius} ${radius * 2} ${radius * 2}`}
          preserveAspectRatio="xMidYMid meet"
        >
          <defs>
            <filter
              id="overmap-radar-bloom"
              x="-20%"
              y="-20%"
              width="140%"
              height="140%"
            >
              <feGaussianBlur stdDeviation={radius / 90} result="blur" />
              <feMerge>
                <feMergeNode in="blur" />
                <feMergeNode in="SourceGraphic" />
              </feMerge>
            </filter>
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
          {!galaxyBand && (
            <g className="OvermapRadar__furniture">
              <RadarRim radius={radius} />
            </g>
          )}
          {galaxyBand ? (
            <GalaxyLayer
              galaxy={galaxy || { revision: 0, sectors: [] }}
              sectorId={sectorId}
              radius={radius}
              opacity={1}
              slot={galaxySlot}
              rotation={rotation}
            />
          ) : (
            <>
              {
                <HazardLayer
                  soft={geometry > 0.01}
                  sensorReach={Math.max(
                    0,
                    ...(props.peels || [])
                      .filter(
                        (peel) =>
                          peel.id ===
                          contacts.find((contact) => contact.own)?.id,
                      )
                      .map((peel) => peel.range),
                  )}
                  fields={hazardFields}
                  objects={objects}
                  self={self || [0, 0]}
                  cellSpan={cellSpan}
                  rotation={rotation}
                  offset={chartOffset}
                />
              }
              {geometry > 0.01 && !!props.scatter && (
                <ScatterLayer
                  chunks={props.scatter}
                  world={world}
                  facing={facing}
                  followHeading={followHeading}
                  opacity={geometry}
                />
              )}
              <GeometryLayer
                terrain={terrain}
                shapes={shapes}
                contacts={contacts}
                world={world}
                facing={facing}
                followHeading={followHeading}
                drifters={drifters}
                engines={engines}
                opacity={geometry}
                activeDock={dockTargets?.find(
                  (dock) => dock.own && dock.selected,
                )}
              />
              {!!props.weaponArcs?.length && rawWorld && (
                <g
                  transform={`scale(1 -1) rotate(${rotation}) translate(${-chartOffset[0]} ${-chartOffset[1]}) rotate(${-facing})`}
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
                </g>
              )}
              {!!props.weaponArcs?.length && world && !props.overlay && (
                <WeaponAimPreview
                  scope={scope}
                  weapons={props.weaponArcs}
                  radius={radius}
                  rotation={rotation}
                  facing={facing}
                  world={world}
                  offset={chartOffset}
                />
              )}
              {world && (
                <g
                  transform={`scale(1 -1) rotate(${rotation}) translate(${-chartOffset[0]} ${-chartOffset[1]})`}
                  opacity={0.9}
                  pointerEvents="none"
                >
                  {(projectiles || []).map((shot) => {
                    const size = Math.max(0.25, radius * 0.009);
                    return (
                      <g
                        key={shot.id}
                        transform={`translate(${shot.x - world[0]} ${shot.y - world[1]}) rotate(${-shot.angle})`}
                      >
                        <path
                          d={`M 0 ${-size * 2} L 0 0`}
                          stroke="#ff9d45"
                          strokeWidth={3}
                          opacity={0.3}
                          vectorEffect="non-scaling-stroke"
                        />
                        <path
                          d={`M 0 ${-size * 1.5} L 0 0 M ${-size * 0.3} ${-size * 0.5} L 0 0 L ${size * 0.3} ${-size * 0.5}`}
                          stroke="#ffe6af"
                          strokeWidth={1.5}
                          vectorEffect="non-scaling-stroke"
                          fill="none"
                        />
                      </g>
                    );
                  })}
                </g>
              )}
              <ObjectLayer
                showSelf={props.showSelf}
                outlines={props.outlines}
                objects={objects}
                self={self}
                cellSpan={cellSpan}
                radius={radius}
                rotation={rotation}
                offset={chartOffset}
              />
              <SectorLayer
                sectorSize={sectorSize}
                cellSpan={cellSpan}
                self={self}
                radius={radius}
                opacity={1}
                rotation={rotation}
                offset={chartOffset}
                dest={dest}
              />
            </>
          )}
          {!galaxyBand && (
            <text
              className="OvermapRadar__north"
              x={Math.sin((north * Math.PI) / 180) * radius * 0.86}
              y={-Math.cos((north * Math.PI) / 180) * radius * 0.86}
              fontSize={labelSize * 1.3}
              textAnchor="middle"
              dominantBaseline="middle"
            >
              N
            </text>
          )}
        </svg>
        {!galaxyBand && (
          <MarkerOverlay
            radius={radius}
            cellSpan={cellSpan}
            followHeading={followHeading}
            facing={facing}
            contacts={contacts}
            objects={objects}
            self={self}
            geometry={geometry}
            offset={offset}
            filter={filter}
          />
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
        <span className="OvermapRadar__band">
          {bandName(radius, galaxyBand, BAND_GEOMETRY_FULL)}
          {galaxyBand && galaxy?.sectors?.length
            ? ` · узлов ${galaxy.sectors.length}`
            : ''}
        </span>
        {!!onToggleFollow && !galaxyBand && (
          <RadarCompass
            facing={followHeading ? 0 : facing}
            followHeading={followHeading}
            onToggle={onToggleFollow}
          />
        )}
        <div className="OvermapRadar__controls">
          {!!onZoom && !props.locked && (
            <RadarZoom
              radius={radius}
              onZoom={onZoom}
              threshold={galaxyBandRadius}
              ceiling={zoomCeiling}
              sectorSpan={sectorSpan}
            />
          )}
          {!galaxyBand && (
            <RadarRuler
              radius={radius}
              cellSpan={cellSpan}
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
