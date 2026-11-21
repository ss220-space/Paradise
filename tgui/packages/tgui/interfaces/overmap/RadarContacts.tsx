import { useEffect, useRef, useState } from 'react';
import { formatMetricDistance } from './mapDistance';
import { overmapKindIcon, overmapKindLabel } from './OvermapChrome';
import type { RadarObject } from './OvermapRadar';
import { RadarCanvas, type RadarView } from './RadarMotion';

const glyphs: Record<string, string> = {
  building: '\uf1ad',
  'shuttle-space': '\uf197',
  rocket: '\uf135',
  globe: '\uf0ac',
  'circle-half-stroke': '\uf042',
  mound: '\ue52d',
  'triangle-exclamation': '\uf071',
  'satellite-dish': '\uf7c0',
  'circle-question': '\uf059',
};
const radians = Math.PI / 180;
const fullCircle = Math.PI * 2;

type Label = { key: string; image: HTMLCanvasElement };

function makeLabel(
  ctx: CanvasRenderingContext2D,
  name: string,
  detail: string,
  kind: string,
  color: string,
  destroyed: boolean,
  density: number,
) {
  const font = '10px Verdana, sans-serif';
  ctx.font = font;
  const width =
    Math.ceil(
      Math.max(18, ctx.measureText(name).width, ctx.measureText(detail).width),
    ) + 4;
  const image = document.createElement('canvas');
  image.width = Math.ceil(width * density);
  image.height = Math.ceil(40 * density);
  const pen = image.getContext('2d')!;
  pen.scale(density, density);
  pen.translate(width / 2, 0);
  pen.textAlign = 'center';
  pen.fillStyle = color;
  pen.font = '900 14px "Font Awesome 6 Free"';
  pen.fillText(
    glyphs[overmapKindIcon(kind)] || glyphs['circle-question'],
    0,
    13,
  );
  pen.font = font;
  pen.shadowColor = '#000';
  pen.shadowBlur = 2;
  pen.fillStyle = '#a9bdca';
  pen.fillText(name, 0, 25);
  if (destroyed) {
    const length = pen.measureText(name).width;
    pen.fillRect(-length / 2, 21, length, 1);
  }
  pen.fillStyle = '#7fb6e8';
  pen.fillText(detail, 0, 37);
  return image;
}

function drawObject(
  ctx: CanvasRenderingContext2D,
  view: RadarView,
  object: RadarObject,
  point: number[],
  outline?: Path2D,
) {
  const { side, radius, rotation, frame } = view;
  const scale = side / (2 * radius);
  const size = Math.max(object.size || 1, 1);
  const span =
    object.kind === 'relay' || object.kind === 'portal'
      ? Math.min(frame.cellSpan * 0.12, radius / 30)
      : Math.max(
          radius / 45,
          Math.min(size * frame.cellSpan * 0.12, radius / 24),
        );
  const extent = Math.max(size * frame.cellSpan, ...(object.extent || []));
  if (
    Math.abs(point[0]) > radius + extent ||
    Math.abs(point[1]) > view.verticalRadius + extent
  )
    return;
  const color = object.color || '#8fd0ff';
  ctx.save();
  ctx.translate(point[0] * scale, point[1] * scale);
  ctx.scale(scale, -scale);
  ctx.rotate(rotation * radians);
  ctx.strokeStyle = color;
  ctx.fillStyle = color;
  ctx.lineWidth = 1 / scale;
  ctx.globalAlpha = Math.max(object.visibility ?? 1, 0.3);
  if (object.kind === 'planet') {
    const planetRadius = (size * frame.cellSpan) / 2;
    ctx.beginPath();
    ctx.arc(0, 0, planetRadius, 0, fullCircle);
    ctx.save();
    ctx.globalAlpha *= 0.4;
    ctx.fill();
    ctx.restore();
    ctx.stroke();
    ctx.scale(1, -1);
    ctx.textAlign = 'center';
    const fontSize = Math.max(radius / 40, 9);
    ctx.font = `${fontSize}px Consolas, monospace`;
    ctx.fillStyle = '#a8d4ff';
    ctx.fillText(object.name, 0, planetRadius + fontSize);
    ctx.restore();
    return;
  }
  if (outline) {
    ctx.save();
    ctx.rotate(-(object.facing || 0) * radians);
    ctx.lineWidth = 1.2 / scale;
    ctx.stroke(outline);
    ctx.restore();
  } else {
    ctx.beginPath();
    if (object.kind === 'portal' || object.kind === 'relay') {
      ctx.moveTo(0, -span);
      ctx.lineTo(span, 0);
      ctx.lineTo(0, span);
      ctx.lineTo(-span, 0);
      ctx.closePath();
    } else if (object.extent) {
      ctx.ellipse(
        0,
        0,
        Math.max(object.extent[0] / 2, radius / 100),
        Math.max(object.extent[1] / 2, radius / 100),
        0,
        0,
        fullCircle,
      );
    } else ctx.arc(0, 0, span, 0, fullCircle);
    ctx.save();
    if (object.kind === 'unknown') {
      ctx.strokeStyle = '#c8e1ff';
      ctx.setLineDash([4 / scale, 3 / scale]);
    } else {
      ctx.save();
      ctx.globalAlpha *= object.kind === 'ruin' ? 0.08 : 0.18;
      ctx.fill();
      ctx.restore();
      if (object.kind === 'ruin') ctx.setLineDash([3 / scale, 3 / scale]);
    }
    ctx.stroke();
    ctx.restore();
  }
  if (object.destroyed) {
    ctx.beginPath();
    ctx.lineWidth = 2 / scale;
    ctx.moveTo(-span, -span);
    ctx.lineTo(span, span);
    ctx.moveTo(-span, span);
    ctx.lineTo(span, -span);
    ctx.stroke();
  }
  if (object.distress) {
    ctx.beginPath();
    ctx.strokeStyle = '#ff8a8a';
    ctx.lineWidth = 1 / scale;
    ctx.setLineDash([2 / scale, 3 / scale]);
    ctx.arc(0, 0, span * 1.5, 0, fullCircle);
    ctx.stroke();
  }
  ctx.restore();
}

export const RadarContacts = ({
  outlines,
  geometry,
  showSelf,
  filter,
}: {
  outlines?: Record<string, string>;
  geometry: number;
  showSelf?: boolean;
  filter: string;
}) => {
  const objectLabels = useRef(new Map<string, Label>()).current;
  const contactLabels = useRef(new Map<string, Label>()).current;
  const paths = useRef(
    new Map<string, { source: string; path: Path2D }>(),
  ).current;
  const [, refresh] = useState(0);
  useEffect(() => {
    const fontsLoaded = () => {
      objectLabels.clear();
      contactLabels.clear();
      refresh((n) => n + 1);
    };
    document.fonts.addEventListener('loadingdone', fontsLoaded);
    return () => document.fonts.removeEventListener('loadingdone', fontsLoaded);
  }, [objectLabels, contactLabels]);
  return (
    <RadarCanvas
      className="OvermapRadar__contacts"
      draw={(ctx, v, density) => {
        const scale = v.side / (2 * v.radius);
        const visible = (point: number[]) =>
          Math.abs(point[0]) <= v.radius * 1.05 &&
          Math.abs(point[1]) <= v.verticalRadius + v.radius * 0.05;
        const label = (
          labels: Map<string, Label>,
          id: string,
          point: number[],
          name: string,
          detail: string,
          kind: string,
          color: string,
          destroyed: boolean,
          opacity: number,
        ) => {
          if (!visible(point)) return;
          const key = [name, detail, kind, color, destroyed, density].join(
            '\x00',
          );
          let cached = labels.get(id);
          if (cached?.key !== key) {
            cached = {
              key,
              image: makeLabel(
                ctx,
                name,
                detail,
                kind,
                color,
                destroyed,
                density,
              ),
            };
            labels.set(id, cached);
          }
          const width = cached.image.width / density;
          const height = cached.image.height / density;
          ctx.globalAlpha = opacity;
          ctx.drawImage(
            cached.image,
            point[0] * scale - width / 2,
            point[1] * scale - height / 2,
            width,
            height,
          );
          ctx.globalAlpha = 1;
        };
        for (const key of paths.keys()) if (!outlines?.[key]) paths.delete(key);
        for (const key of objectLabels.keys())
          if (!v.index.objects.has(key)) objectLabels.delete(key);
        for (const key of contactLabels.keys())
          if (!v.index.contacts.has(key)) contactLabels.delete(key);
        for (const object of v.frame.objects) {
          if (
            (object.is_self && showSelf === false) ||
            object.kind === 'hazard'
          )
            continue;
          const id = object.id || object.name;
          const shift = (Math.max(1, object.size || 1) - 1) / 2;
          const point = v.sectorPoint(object.x + shift, object.y + shift);
          const outline = outlines?.[id];
          let cache = paths.get(id);
          if (outline && cache?.source !== outline) {
            cache = { source: outline, path: new Path2D(outline) };
            paths.set(id, cache);
          }
          drawObject(ctx, v, object, point, outline ? cache?.path : undefined);
        }
        const own = v.hullPoint(0, 0);
        if (visible(own)) {
          ctx.save();
          ctx.translate(own[0] * scale, own[1] * scale);
          ctx.save();
          ctx.rotate((v.frame.facing - v.rotation) * radians);
          ctx.fillStyle = '#8fd0ff';
          ctx.beginPath();
          ctx.moveTo(0, -10);
          ctx.lineTo(6, 4);
          ctx.lineTo(-6, 4);
          ctx.closePath();
          ctx.fill();
          ctx.restore();
          ctx.fillStyle = '#a9bdca';
          ctx.font = '10px Verdana, sans-serif';
          ctx.textAlign = 'center';
          ctx.fillText('вы', 0, 15);
          ctx.restore();
        }
        if (geometry < 0.9) {
          for (const object of v.frame.objects) {
            if (object.is_self || object.kind === 'hazard') continue;
            const shift = (Math.max(1, object.size || 1) - 1) / 2;
            const point = v.sectorPoint(object.x + shift, object.y + shift);
            label(
              objectLabels,
              object.id || object.name,
              point,
              object.name,
              overmapKindLabel(object.kind),
              object.kind,
              object.color || (object.distress ? '#ff8a8a' : '#a8d4ff'),
              !!object.destroyed,
              (filter === 'all' || object.kind === filter ? 1 : 0.3) *
                Math.max(object.visibility ?? 1, 0.3),
            );
          }
        }
        if (geometry > 0.5) {
          for (const contact of v.frame.contacts) {
            if (contact.own || (contact.distance || 0) > v.radius) continue;
            label(
              contactLabels,
              contact.id,
              v.hullPoint(contact.x, contact.y),
              contact.name || '',
              formatMetricDistance(contact.distance || 0),
              'shuttle',
              '#a8d4ff',
              !!contact.destroyed,
              1,
            );
          }
        }
      }}
    />
  );
};
