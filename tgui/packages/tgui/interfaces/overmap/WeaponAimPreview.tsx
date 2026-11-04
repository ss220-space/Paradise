import { type RefObject, useEffect, useRef, useState } from 'react';
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
  radius: number;
  rotation: number;
  facing: number;
  world: number[];
  offset: number[];
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
      const side = Math.min(bounds.width, bounds.height);
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
  }, [props.scope]);
  if (!cursor) return null;
  const target = radarClickWorld(
    cursor,
    props.radius,
    props.rotation,
    props.world,
    props.offset,
  );
  const tx = target[0] - props.world[0];
  const ty = target[1] - props.world[1];
  const angle = (props.facing * Math.PI) / 180;
  return (
    <g
      transform={`scale(1 -1) rotate(${props.rotation}) translate(${-props.offset[0]} ${-props.offset[1]})`}
      pointerEvents="none"
    >
      {props.weapons.map((weapon) => {
        const x = weapon.x * Math.cos(angle) + weapon.y * Math.sin(angle);
        const y = weapon.y * Math.cos(angle) - weapon.x * Math.sin(angle);
        const bearing = (Math.atan2(tx - x, ty - y) * 180) / Math.PI;
        const difference =
          ((((bearing - weapon.heading - props.facing) % 360) + 540) % 360) -
          180;
        if (Math.abs(difference) > weapon.arc / 2) return null;
        return (
          <line
            key={weapon.id}
            x1={x}
            y1={y}
            x2={tx}
            y2={ty}
            stroke="#ffe0a6"
            strokeOpacity={0.85}
            strokeWidth={1}
            strokeDasharray="5 3"
            vectorEffect="non-scaling-stroke"
          />
        );
      })}
    </g>
  );
};
