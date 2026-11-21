import { type RefObject, useEffect, useRef, useState } from 'react';
import { RadarLine } from './RadarMotion';
import { radarClickWorld } from './radarInterpolation';

type Weapon = {
  id: string;
  x: number;
  y: number;
  heading: number;
  arc: number;
};

export const WeaponAimPreview = (props: {
  scope: RefObject<HTMLDivElement | null>;
  weapons: Weapon[];
  fillViewport?: boolean;
}) => {
  const [cursor, setCursor] = useState<number[] | null>(null);
  const pending = useRef(0);
  useEffect(() => {
    const element = props.scope.current;
    if (!element) return;
    let next: number[] | null = null;
    const update = () => {
      if (!pending.current)
        pending.current = requestAnimationFrame(() => {
          pending.current = 0;
          setCursor(next);
        });
    };
    const move = (event: MouseEvent) => {
      const bounds = element.getBoundingClientRect();
      const side = props.fillViewport
        ? bounds.width
        : Math.min(bounds.width, bounds.height);
      next = [
        ((event.clientX - bounds.left - bounds.width / 2) * 2) / side,
        ((event.clientY - bounds.top - bounds.height / 2) * 2) / side,
      ];
      if (
        Math.hypot(...next) > 1 ||
        (event.target as Element).closest(
          'input,select,textarea,.OvermapRadar__controls,.OvermapRadar__bands',
        )
      )
        next = null;
      update();
    };
    const leave = () => {
      next = null;
      update();
    };
    element.addEventListener('mousemove', move);
    element.addEventListener('mouseleave', leave);
    return () => {
      element.removeEventListener('mousemove', move);
      element.removeEventListener('mouseleave', leave);
      cancelAnimationFrame(pending.current);
      pending.current = 0;
    };
  }, [props.scope, props.fillViewport]);
  if (!cursor) return null;
  return (
    <g pointerEvents="none">
      {props.weapons.map((weapon) => (
        <RadarLine
          key={weapon.id}
          points={(v) => {
            const world = v.frame.world;
            if (!world) return;
            const target = radarClickWorld(
              cursor,
              v.radius,
              v.rotation,
              world,
              [v.offsetX, v.offsetY],
            );
            const angle = (v.frame.facing * Math.PI) / 180;
            const x = weapon.x * Math.cos(angle) + weapon.y * Math.sin(angle);
            const y = weapon.y * Math.cos(angle) - weapon.x * Math.sin(angle);
            const bearing =
              (Math.atan2(target[0] - world[0] - x, target[1] - world[1] - y) *
                180) /
              Math.PI;
            const difference =
              ((((bearing - weapon.heading - v.frame.facing) % 360) + 540) %
                360) -
              180;
            if (Math.abs(difference) <= weapon.arc / 2) {
              const origin = v.worldPoint(world[0] + x, world[1] + y);
              return [
                origin[0],
                origin[1],
                cursor[0] * v.radius,
                cursor[1] * v.radius,
              ];
            }
          }}
          stroke="#ffe0a6"
          strokeOpacity={0.85}
          strokeWidth={1}
          strokeDasharray="5 3"
          vectorEffect="non-scaling-stroke"
        />
      ))}
    </g>
  );
};
