import {
  type ButtonHTMLAttributes,
  createContext,
  type ReactNode,
  type SVGProps,
  useContext,
  useLayoutEffect,
  useRef,
} from 'react';
import { indexRadarFrame, type RadarFrame } from './radarInterpolation';

export type RadarView = ReturnType<typeof radarView>;

export const radarChartOffset = (
  self: number[] | undefined,
  sectorSize: number,
  cellSpan: number,
  radius: number,
  center?: [number, number],
): [number, number] => {
  if (!self) return [0, 0];
  if (center)
    return [center[0] - self[0] * cellSpan, center[1] - self[1] * cellSpan];
  const span = Math.max(cellSpan * sectorSize, cellSpan * 4);
  const drift = Math.max(
    0,
    Math.min(1, (radius - span * 0.35) / (span * 0.45)),
  );
  return [
    ((sectorSize + 1) / 2 - self[0]) * cellSpan * drift,
    ((sectorSize + 1) / 2 - self[1]) * cellSpan * drift,
  ];
};

export const radarView = (
  frame: RadarFrame,
  radius: number,
  side: number,
  height: number,
  sectorSize: number,
  follow: boolean,
  center?: [number, number],
) => {
  const { world, self, cellSpan, facing } = frame;
  const index = indexRadarFrame(frame);
  const [offsetX, offsetY] = radarChartOffset(
    self,
    sectorSize,
    cellSpan,
    radius,
    center,
  );
  const rotation = follow ? facing : 0;
  const angle = (rotation * Math.PI) / 180;
  const cos = Math.cos(angle);
  const sin = Math.sin(angle);
  const worldX = (world?.[0] ?? 0) + offsetX;
  const worldY = (world?.[1] ?? 0) + offsetY;
  const sectorX = (self?.[0] ?? 0) * cellSpan + offsetX;
  const sectorY = (self?.[1] ?? 0) * cellSpan + offsetY;
  const project = (dx: number, dy: number) => [
    dx * cos - dy * sin,
    -dx * sin - dy * cos,
  ];
  const sectorPoint = (x: number, y: number) =>
    project(x * cellSpan - sectorX, y * cellSpan - sectorY);
  const objectPoint = (id: string) => {
    const object = index.objects.get(id);
    if (!object) return;
    const shift = (Math.max(1, object.size || 1) - 1) / 2;
    return sectorPoint(object.x + shift, object.y + shift);
  };
  const worldPoint = (x: number, y: number) => project(x - worldX, y - worldY);
  const relative = ((facing - rotation) * Math.PI) / 180;
  const hullCos = Math.cos(relative);
  const hullSin = Math.sin(relative);
  const origin = project(-offsetX, -offsetY);
  const hullPoint = (x: number, y: number) => [
    origin[0] + x * hullCos + y * hullSin,
    origin[1] + x * hullSin - y * hullCos,
  ];
  return {
    frame,
    index,
    worldX,
    worldY,
    sectorX,
    sectorY,
    offsetX,
    offsetY,
    rotation,
    radius,
    verticalRadius: (radius * height) / side,
    side,
    height,
    sectorPoint,
    objectPoint,
    worldPoint,
    hullPoint,
  };
};

type Painter = (view: RadarView) => void;

export class RadarMotion {
  private painters = new Set<Painter>();
  private current?: RadarView;
  private pending = new Set<Painter>();

  subscribe(paint: Painter) {
    this.painters.add(paint);
    if (this.current) {
      if (!this.pending.size) {
        queueMicrotask(() => {
          if (this.current) {
            for (const next of this.pending) next(this.current);
          }
          this.pending.clear();
        });
      }
      this.pending.add(paint);
    }
    return () => {
      this.pending.delete(paint);
      this.painters.delete(paint);
    };
  }

  draw(view: RadarView) {
    this.current = view;
    this.pending.clear();
    for (const paint of this.painters) paint(view);
  }
}

export const RadarMotionContext = createContext<RadarMotion | null>(null);

export function useRadarPaint(paint: Painter) {
  const motion = useContext(RadarMotionContext);
  useLayoutEffect(() => motion?.subscribe(paint), [motion, paint]);
}

export const RadarGroup = ({
  pose,
  children,
  ...props
}: {
  pose: (view: RadarView) => string;
  children: ReactNode;
  className?: string;
  opacity?: number;
  pointerEvents?: string;
}) => {
  const ref = useRef<SVGGElement>(null);
  const last = useRef('');
  useRadarPaint((view) => {
    const value = pose(view);
    if (ref.current && value !== last.current) {
      ref.current.setAttribute('transform', value);
      last.current = value;
    }
  });
  return (
    <g {...props} ref={ref}>
      {children}
    </g>
  );
};

export const RadarLine = ({
  points,
  ...props
}: Omit<SVGProps<SVGLineElement>, 'points'> & {
  points: (view: RadarView) => number[] | undefined;
}) => {
  const ref = useRef<SVGLineElement>(null);
  useRadarPaint((view) => {
    const node = ref.current;
    if (!node) return;
    const p = points(view);
    node.style.display = p ? '' : 'none';
    if (p) {
      node.setAttribute('x1', String(p[0]));
      node.setAttribute('y1', String(p[1]));
      node.setAttribute('x2', String(p[2]));
      node.setAttribute('y2', String(p[3]));
    }
  });
  return <line {...props} ref={ref} />;
};

export const RadarCanvas = ({
  className,
  draw,
}: {
  className: string;
  draw: (
    ctx: CanvasRenderingContext2D,
    view: RadarView,
    density: number,
  ) => void;
}) => {
  const ref = useRef<HTMLCanvasElement>(null);
  useRadarPaint((view) => {
    const element = ref.current;
    const ctx = element?.getContext('2d');
    if (!element || !ctx || !view.side) return;
    const density = Math.min(window.devicePixelRatio || 1, 2);
    const width = Math.max(1, Math.round(view.side * density));
    const height = Math.max(1, Math.round(view.height * density));
    if (element.width !== width) element.width = width;
    if (element.height !== height) element.height = height;
    ctx.resetTransform();
    ctx.clearRect(0, 0, width, height);
    ctx.setTransform(density, 0, 0, density, width / 2, height / 2);
    ctx.save();
    draw(ctx, view, density);
    ctx.restore();
  });
  return <canvas ref={ref} className={className} aria-hidden="true" />;
};

export const RadarButton = ({
  point,
  ...props
}: ButtonHTMLAttributes<HTMLButtonElement> & {
  point: (view: RadarView) => number[] | undefined;
}) => {
  const ref = useRef<HTMLButtonElement>(null);
  useRadarPaint((view) => {
    const node = ref.current;
    if (!node) return;
    const p = point(view);
    const visible =
      !!p &&
      Math.abs(p[0]) <= view.radius &&
      Math.abs(p[1]) <= view.verticalRadius;
    if (node.hidden === visible) node.hidden = !visible;
    if (visible) {
      const scale = view.side / (2 * view.radius);
      node.style.transform = `translate3d(${(p[0] * scale).toFixed(2)}px,${(p[1] * scale).toFixed(2)}px,0) translate(-50%,-50%)`;
    }
  });
  return <button type="button" {...props} ref={ref} />;
};
