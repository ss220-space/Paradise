import {
  type MouseEvent,
  type PointerEvent,
  type RefObject,
  useLayoutEffect,
  useRef,
  useState,
} from 'react';
import { radarScreenDelta } from './radarInterpolation';
import type { RadarView } from './RadarMotion';

export const useSectorPan = (
  enabled: boolean,
  sectorId: string | undefined,
  displayed: RefObject<RadarView | null>,
) => {
  const [center, setCenter] = useState<[number, number]>();
  const drag = useRef<{
    id: number;
    x: number;
    y: number;
    centerX: number;
    centerY: number;
  } | null>(null);
  const moved = useRef(false);

  useLayoutEffect(() => {
    drag.current = null;
    moved.current = false;
    setCenter(undefined);
  }, [enabled, sectorId]);

  const onPointerDown = (event: PointerEvent<HTMLDivElement>) => {
    if (event.button !== 0 || !event.isPrimary) return;
    moved.current = false;
    const view = displayed.current;
    const button = (event.target as Element).closest('button');
    if (!view?.frame.self || (button && !button.matches('.OvermapRadar__pick')))
      return;
    drag.current = {
      id: event.pointerId,
      x: event.clientX,
      y: event.clientY,
      centerX: view.sectorX,
      centerY: view.sectorY,
    };
    (button || event.currentTarget).setPointerCapture(event.pointerId);
  };
  const onPointerMove = (event: PointerEvent<HTMLDivElement>) => {
    const start = drag.current;
    const view = displayed.current;
    if (!start || start.id !== event.pointerId || !view) return;
    const dx = event.clientX - start.x;
    const dy = event.clientY - start.y;
    if (!moved.current && Math.hypot(dx, dy) <= 3) return;
    moved.current = true;
    const scale = (2 * view.radius) / view.side;
    const [x, y] = radarScreenDelta(dx * scale, dy * scale, view.rotation);
    setCenter([start.centerX - x, start.centerY - y]);
  };
  const endDrag = (event: PointerEvent<HTMLDivElement>) => {
    if (drag.current?.id === event.pointerId) drag.current = null;
  };
  const onClickCapture = (event: MouseEvent<HTMLDivElement>) => {
    if (event.detail && moved.current) {
      event.preventDefault();
      event.stopPropagation();
    }
  };

  return {
    center: enabled ? center : undefined,
    resetCenter: () => setCenter(undefined),
    handlers: enabled
      ? {
          onPointerDown,
          onPointerMove,
          onPointerUp: endDrag,
          onPointerCancel: endDrag,
          onLostPointerCapture: endDrag,
          onClickCapture,
        }
      : undefined,
  };
};
