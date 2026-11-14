import type { PointerEvent } from 'react';
import { useEffect, useId, useRef, useState } from 'react';
import { GalaxyMarker } from './GalaxyMarker';
import {
  entryCamera,
  lineDash,
  linkPoints,
  MAX_SCALE,
  niceStep,
  pointAlongPath,
  pointsPath,
  project,
  territoryStyle,
  unproject,
  zoomCamera,
} from './galaxyGeometry.mjs';
import type { GalaxyMap } from './galaxyTypes';
import { MapControls } from './MapControls';
import { MapRuler } from './MapRuler';
import {
  formatGalacticCoordinate,
  formatGalacticDistance,
} from './mapDistance';

type Camera = { x: number; y: number; scale: number };

export const OvermapGalaxy = ({
  galaxy,
  sectorId,
  entry = 'overview',
  onSector,
}: {
  galaxy: GalaxyMap;
  sectorId?: string;
  entry?: 'close' | 'overview';
  onSector?: () => void;
}) => {
  const container = useRef<HTMLDivElement>(null);
  const [viewport, setViewport] = useState({ width: 640, height: 640 });
  const [camera, setCamera] = useState<Camera | null>(null);
  const [selected, setSelected] = useState(sectorId);
  const [legend, setLegend] = useState(true);
  const [hidden, setHidden] = useState<string[]>([]);
  const [showPoi, setShowPoi] = useState(true);
  const [showLabels, setShowLabels] = useState(true);
  const [age, setAge] = useState(0);
  const drag = useRef<{ x: number; y: number; camera: Camera } | null>(null);
  const moved = useRef(false);
  const prefix = `galaxy-${useId().replace(/:/g, '')}`;
  const { width, height } = viewport;
  const view = camera || entryCamera(galaxy, width, height, sectorId, entry);
  useEffect(() => setCamera(null), [entry]);
  const factions = galaxy.factions || [];
  const systems = galaxy.sectors || [];
  const links = galaxy.links || [];
  const chosen = systems.find((s) => s.id === selected);
  const at = (point: number[]) => project(point, view, width, height);
  const visible = (faction?: string) => !faction || !hidden.includes(faction);
  const step = niceStep(85 / view.scale);
  const low = unproject([0, height], view, width, height);
  const high = unproject([width, 0], view, width, height);
  const gridX = Array.from(
    { length: Math.ceil(width / (step * view.scale)) + 2 },
    (_, i) => Math.floor(low[0] / step) * step + i * step,
  );
  const gridY = Array.from(
    { length: Math.ceil(height / (step * view.scale)) + 2 },
    (_, i) => Math.floor(low[1] / step) * step + i * step,
  );
  useEffect(() => {
    if (!container.current) return;
    const observer = new ResizeObserver(([entry]) => {
      const { width, height } = entry.contentRect;
      if (width && height) {
        setViewport({ width, height });
        if (width < 560) setLegend(false);
      }
    });
    observer.observe(container.current);
    return () => observer.disconnect();
  }, []);
  useEffect(() => {
    const element = container.current;
    if (!element) return;
    const wheel = (event: WheelEvent) => {
      event.preventDefault();
      event.stopPropagation();
      const bounds = element.getBoundingClientRect();
      const anchor = [event.clientX - bounds.left, event.clientY - bounds.top];
      const delta = Math.max(
        -500,
        Math.min(500, event.deltaY * (event.deltaMode === 1 ? 16 : 1)),
      );
      if (event.deltaY < 0 && onSector && view.scale >= MAX_SCALE) {
        onSector();
        return;
      }
      setCamera((previous) =>
        zoomCamera(
          previous || entryCamera(galaxy, width, height, sectorId, entry),
          Math.exp(-delta * 0.0015),
          anchor,
          width,
          height,
        ),
      );
    };
    element.addEventListener('wheel', wheel, { passive: false });
    return () => element.removeEventListener('wheel', wheel);
  }, [galaxy, width, height, sectorId, entry, view.scale, onSector]);
  useEffect(() => {
    setAge(0);
    if (!galaxy.transits?.length) return;
    const start = performance.now();
    let handle = 0;
    const animate = (now: number) => {
      setAge(now - start);
      handle = requestAnimationFrame(animate);
    };
    handle = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(handle);
  }, [galaxy.transits]);
  const localPoint = (clientX: number, clientY: number) => {
    const bounds = container.current!.getBoundingClientRect();
    return [clientX - bounds.left, clientY - bounds.top];
  };
  const zoom = (factor: number, anchor = [width / 2, height / 2]) =>
    setCamera(zoomCamera(view, factor, anchor, width, height));
  const pointerDown = (event: PointerEvent<SVGSVGElement>) => {
    if (event.button !== 0) return;
    moved.current = false;
    drag.current = { x: event.clientX, y: event.clientY, camera: view };
    event.currentTarget.setPointerCapture(event.pointerId);
  };
  const pointerMove = (event: PointerEvent<SVGSVGElement>) => {
    if (!drag.current) return;
    const dx = event.clientX - drag.current.x;
    const dy = event.clientY - drag.current.y;
    if (Math.hypot(dx, dy) > 3) moved.current = true;
    setCamera({
      ...drag.current.camera,
      x: drag.current.camera.x - dx / drag.current.camera.scale,
      y: drag.current.camera.y + dy / drag.current.camera.scale,
    });
  };
  return (
    <div
      className={`TacticalGalaxy${width < 560 ? ' TacticalGalaxy--compact' : ''}`}
      ref={container}
      onClick={(e) => e.stopPropagation()}
    >
      <svg
        className="TacticalGalaxy__canvas"
        viewBox={`0 0 ${width} ${height}`}
        role="img"
        aria-label="Тактическая карта галактики"
        onPointerDown={pointerDown}
        onPointerMove={pointerMove}
        onPointerUp={(e) => {
          if (drag.current && !moved.current) {
            const hit = document
              .elementFromPoint(e.clientX, e.clientY)
              ?.closest('[data-system]');
            if (hit) setSelected(hit.getAttribute('data-system') || undefined);
          }
          drag.current = null;
          e.currentTarget.releasePointerCapture(e.pointerId);
        }}
        onPointerCancel={() => {
          drag.current = null;
        }}
      >
        <defs>
          <pattern
            id={`${prefix}-stars`}
            patternUnits="userSpaceOnUse"
            width="147"
            height="131"
          >
            <circle cx="17" cy="21" r="0.65" fill="#7495bb" opacity="0.5" />
            <circle cx="93" cy="76" r="0.5" fill="#a5bad6" opacity="0.35" />
            <circle cx="135" cy="111" r="0.7" fill="#517b9b" opacity="0.35" />
          </pattern>
          {(galaxy.territories || []).map((territory) => {
            const style = territoryStyle(territory, factions);
            const color =
              factions.find((f) => f.id === territory.faction)?.color ||
              '#92abc7';
            const pitch = style.hatchSpacing;
            return (
              <pattern
                key={territory.id}
                id={`${prefix}-${territory.id}`}
                patternUnits="userSpaceOnUse"
                width={pitch}
                height={pitch}
                patternTransform={
                  style.hatch === 'diagonal' || style.hatch === 'cross'
                    ? 'rotate(45)'
                    : undefined
                }
              >
                {style.hatch === 'dots' ? (
                  <circle cx={pitch / 2} cy={pitch / 2} r="1" fill={color} />
                ) : (
                  <>
                    <path d={`M0 0H${pitch}`} stroke={color} />
                    {style.hatch === 'cross' && (
                      <path d={`M0 0V${pitch}`} stroke={color} />
                    )}
                  </>
                )}
              </pattern>
            );
          })}
        </defs>
        <rect width={width} height={height} fill={`url(#${prefix}-stars)`} />
        <g className="TacticalGalaxy__grid">
          {gridX.map((x) => (
            <g key={`x${x}`}>
              <path d={`M${at([x, 0])[0]} 0V${height}`} />
              <text x={at([x, 0])[0] + 4} y={height - 9}>
                {formatGalacticCoordinate(x)}
              </text>
            </g>
          ))}
          {gridY.map((y) => (
            <g key={`y${y}`}>
              <path d={`M0 ${at([0, y])[1]}H${width}`} />
              <text x="6" y={at([0, y])[1] - 5}>
                {formatGalacticCoordinate(y)}
              </text>
            </g>
          ))}
        </g>
        {(galaxy.territories || [])
          .filter((t) => visible(t.faction))
          .map((t) => {
            const style = territoryStyle(t, factions);
            const color =
              factions.find((f) => f.id === t.faction)?.color || '#92abc7';
            const points = t.points.map((p) => at(p).join(',')).join(' ');
            return (
              <g key={t.id}>
                <polygon
                  points={points}
                  fill={style.fill}
                  fillOpacity={style.fillOpacity}
                />
                {style.hatch !== 'none' && (
                  <polygon
                    points={points}
                    fill={`url(#${prefix}-${t.id})`}
                    opacity={style.hatchOpacity}
                  />
                )}
                <polygon
                  points={points}
                  fill="none"
                  stroke={color}
                  strokeWidth={style.width}
                  strokeOpacity={style.opacity}
                  strokeDasharray={lineDash(style.line)}
                />
                <title>{t.name}</title>
              </g>
            );
          })}
        {links
          .filter(() => !hidden.includes('paths'))
          .map((link) => {
            const points = linkPoints(link, systems).map(at);
            const active = link.from === selected || link.to === selected;
            return (
              <path
                key={link.id}
                d={pointsPath(points)}
                fill="none"
                stroke={link.color || '#85bad3'}
                strokeWidth={(link.width || 1.5) + (active ? 1 : 0)}
                strokeOpacity={link.opacity ?? 0.8}
                strokeDasharray={lineDash(
                  link.line || (link.state === 'closed' ? 'dashed' : 'solid'),
                )}
              >
                <title>
                  {link.id} ·{' '}
                  {link.state === 'closed'
                    ? 'Закрыт'
                    : link.state === 'unstable'
                      ? 'Нестабилен'
                      : 'Активен'}
                  {link.access === 'restricted' ? ' · ограничен IFF' : ''}
                  {link.distance ? ` · ${link.distance}` : ''}
                </title>
              </path>
            );
          })}
        {showPoi &&
          (galaxy.pois || []).map((poi) => {
            const [x, y] = at([poi.x, poi.y]);
            return (
              <g key={poi.id} transform={`translate(${x} ${y})`}>
                <GalaxyMarker
                  marker={poi.marker}
                  color={poi.color}
                  defaultShape="diamond"
                />
                {showLabels && !!(poi.marker?.showLabel ?? true) && (
                  <text
                    x={poi.marker?.labelX ?? 10}
                    y={poi.marker?.labelY ?? 4}
                    style={{ fontSize: poi.marker?.labelSize }}
                    fill={poi.marker?.labelColor || poi.color}
                    className="TacticalGalaxy__label"
                  >
                    {poi.name}
                  </text>
                )}
                <title>{poi.description || poi.name}</title>
              </g>
            );
          })}
        {systems
          .filter((s) => visible(s.faction))
          .map((system) => {
            const [x, y] = at([system.x, system.y]);
            const color =
              system.marker?.color ||
              factions.find((f) => f.id === system.faction)?.color ||
              '#c3d2e3';
            return (
              <g
                key={system.id}
                data-system={system.id}
                transform={`translate(${x} ${y})`}
                className="TacticalGalaxy__system"
                role="button"
                tabIndex={0}
                aria-label={system.name}
                onKeyDown={(e) => {
                  if (e.key === 'Enter' || e.key === ' ') {
                    e.preventDefault();
                    setSelected(system.id);
                  }
                }}
              >
                <circle r="15" fill="transparent" />
                {system.id === selected && (
                  <circle
                    r="11"
                    fill="none"
                    stroke="#ffdd8a"
                    strokeDasharray="3 3"
                  />
                )}
                {system.id === sectorId && (
                  <circle r="8" fill="none" stroke="#75f0bf" strokeWidth="2" />
                )}
                <GalaxyMarker
                  marker={system.marker}
                  color={color}
                  defaultShape={
                    system.kind === 'transit' ? 'diamond' : 'circle'
                  }
                />
                {!!system.distress && (
                  <path d="M-6 -9L0 -18L6 -9Z" fill="#ff697d" />
                )}
                {showLabels && !!(system.marker?.showLabel ?? true) && (
                  <text
                    x={system.marker?.labelX ?? 15}
                    y={system.marker?.labelY ?? 4}
                    style={{ fontSize: system.marker?.labelSize }}
                    fill={system.marker?.labelColor || color}
                    className="TacticalGalaxy__label"
                  >
                    {system.name}
                  </text>
                )}
                <title>
                  {`${system.name}${system.kind === 'transit' ? ' · транзитный сектор, вход недоступен' : system.id === sectorId ? ' · текущий сектор' : ''}`}
                </title>
              </g>
            );
          })}
        {(galaxy.transits || []).map((flight) => {
          const route = links.find(
            (l) =>
              (l.from === flight.from && l.to === flight.to) ||
              (l.to === flight.from && l.from === flight.to),
          );
          const points = flight.path?.length
            ? flight.path
            : route
              ? linkPoints(route, systems)
              : linkPoints({ from: flight.from, to: flight.to }, systems);
          if (points.length < 2) return null;
          if (!flight.path?.length && route && route.from !== flight.from)
            points.reverse();
          const point = pointAlongPath(
            points,
            Math.min(
              1,
              flight.progress +
                ((1 - flight.progress) * age) / Math.max(1, flight.remaining),
            ),
          );
          const [x, y] = at([point.x, point.y]);
          return (
            <path
              key={flight.id}
              transform={`translate(${x} ${y}) rotate(${point.angle})`}
              d="M7 0L-5 4L-3 0L-5 -4Z"
              fill={flight.own ? '#75f0bf' : '#f8ca8a'}
            >
              <title>
                {flight.own ? 'Ваш корабль в переходе' : 'Корабль в переходе'}
              </title>
            </path>
          );
        })}
      </svg>
      <div
        className="TacticalGalaxy__legend"
        onPointerDown={(e) => e.stopPropagation()}
      >
        <button
          type="button"
          onClick={() => setLegend(!legend)}
          className="TacticalGalaxy__heading"
        >
          {legend ? '−' : '+'} ЛЕГЕНДА <small>{systems.length} систем</small>
        </button>
        {legend && (
          <>
            {factions.map((f) => (
              <label key={f.id}>
                <input
                  type="checkbox"
                  checked={!hidden.includes(f.id)}
                  onChange={() =>
                    setHidden(
                      hidden.includes(f.id)
                        ? hidden.filter((id) => id !== f.id)
                        : [...hidden, f.id],
                    )
                  }
                />
                <i style={{ background: f.color }} />
                {f.name}
              </label>
            ))}
            <hr />
            <label>
              <input
                type="checkbox"
                checked={!hidden.includes('paths')}
                onChange={() =>
                  setHidden(
                    hidden.includes('paths')
                      ? hidden.filter((id) => id !== 'paths')
                      : [...hidden, 'paths'],
                  )
                }
              />
              Пути
            </label>
            <hr />
            <label>
              <input
                type="checkbox"
                checked={showPoi}
                onChange={() => setShowPoi(!showPoi)}
              />
              ◇ Точки интереса
            </label>
            <label>
              <input
                type="checkbox"
                checked={showLabels}
                onChange={() => setShowLabels(!showLabels)}
              />
              Системы
            </label>
          </>
        )}
      </div>
      <div className="TacticalGalaxy__tools">
        <MapControls
          onIn={() =>
            view.scale >= MAX_SCALE && onSector ? onSector() : zoom(1.25)
          }
          onOut={() => zoom(0.8)}
          onBand={onSector}
          bandTitle="Сектор"
          band="◻"
        />
      </div>
      {chosen && (
        <div className="TacticalGalaxy__inspector">
          <strong>{chosen.name}</strong>
          <span>
            {factions.find((f) => f.id === chosen.faction)?.name ||
              'Вне юрисдикции'}{' '}
            · {formatGalacticCoordinate(chosen.x)},{' '}
            {formatGalacticCoordinate(chosen.y)}
          </span>

          {chosen.description && <p>{chosen.description}</p>}
        </div>
      )}
      <div className="TacticalGalaxy__ruler">
        <MapRuler label={formatGalacticDistance(120 / view.scale)} />
      </div>
    </div>
  );
};
