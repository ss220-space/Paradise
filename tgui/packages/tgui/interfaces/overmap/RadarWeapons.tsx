import { useEffect, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';

export type RadarWeapon = {
  id: string;
  name: string;
  x: number;
  y: number;
  heading: number;
  selected: BooleanLike;
  cooldown: number;
  cooldown_total?: number;
};

export const RadarWeapons = (props: {
  weapons: RadarWeapon[];
  radius: number;
  facing: number;
  followHeading: boolean;
  offset: number[];
  onSelect?: (id: string) => void;
}) => {
  const [elapsed, setElapsed] = useState(0);
  useEffect(() => {
    const received = performance.now();
    setElapsed(0);
    if (!props.weapons.some((weapon) => weapon.cooldown > 0)) return;
    const timer = setInterval(
      () => setElapsed((performance.now() - received) / 1000),
      100,
    );
    return () => clearInterval(timer);
  }, [props.weapons]);
  const angle = (props.facing * Math.PI) / 180;
  const rotation = props.followHeading ? angle : 0;
  return (
    <div className="OvermapRadar__weapons">
      {props.weapons.map((weapon) => {
        const wx =
          weapon.x * Math.cos(angle) +
          weapon.y * Math.sin(angle) -
          props.offset[0];
        const wy =
          weapon.y * Math.cos(angle) -
          weapon.x * Math.sin(angle) -
          props.offset[1];
        const x =
          (wx * Math.cos(rotation) - wy * Math.sin(rotation)) / props.radius;
        const y =
          -(wx * Math.sin(rotation) + wy * Math.cos(rotation)) / props.radius;
        if (Math.abs(x) > 1 || Math.abs(y) > 1) return null;
        const cooldown = Math.max(0, weapon.cooldown - elapsed);
        const ready = cooldown <= 0;
        const progress = ready
          ? 1
          : Math.max(
              0,
              1 -
                cooldown /
                  Math.max(weapon.cooldown_total || weapon.cooldown, cooldown),
            );
        return (
          <button
            key={weapon.id}
            type="button"
            className={`OvermapRadar__weapon${weapon.selected ? ' OvermapRadar__weapon--selected' : ''}${ready ? ' OvermapRadar__weapon--ready' : ''}`}
            style={{
              left: `${50 + x * 50}%`,
              top: `${50 + y * 50}%`,
              pointerEvents: props.onSelect ? 'auto' : 'none',
            }}
            title={`${weapon.name}: ${ready ? 'готово' : `${cooldown.toFixed(1)} с`}`}
            onClick={(event) => {
              event.stopPropagation();
              props.onSelect?.(weapon.id);
            }}
            tabIndex={props.onSelect ? 0 : -1}
          >
            <svg viewBox="-13 -13 26 26">
              <circle
                r="11"
                fill="#071015"
                stroke="currentColor"
                opacity="0.7"
              />
              <circle
                r="11"
                fill="none"
                stroke="currentColor"
                strokeWidth="2"
                pathLength="1"
                strokeDasharray={`${progress} 1`}
                transform="rotate(-90)"
              />
              <g
                transform={`rotate(${weapon.heading + (props.followHeading ? 0 : props.facing)})`}
                fill="currentColor"
              >
                <path d="M-3 5V-3H-1V-9H1V-3H3V5Z" />
                <circle r="4" />
              </g>
            </svg>
            {!ready && <span>{cooldown.toFixed(1)}</span>}
          </button>
        );
      })}
    </div>
  );
};
