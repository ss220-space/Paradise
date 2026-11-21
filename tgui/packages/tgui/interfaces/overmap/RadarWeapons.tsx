import { useEffect, useState } from 'react';
import type { BooleanLike } from 'tgui-core/react';
import { RadarButton, RadarGroup } from './RadarMotion';

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
  return (
    <div className="OvermapRadar__weapons">
      {props.weapons.map((weapon) => {
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
          <RadarButton
            key={weapon.id}
            point={(v) => v.hullPoint(weapon.x, weapon.y)}
            className={`OvermapRadar__weapon${weapon.selected ? ' OvermapRadar__weapon--selected' : ''}${ready ? ' OvermapRadar__weapon--ready' : ''}`}
            style={{
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
              <RadarGroup
                pose={(v) =>
                  `rotate(${weapon.heading + v.frame.facing - v.rotation})`
                }
              >
                <g fill="currentColor">
                  <path d="M-3 5V-3H-1V-9H1V-3H3V5Z" />
                  <circle r="4" />
                </g>
              </RadarGroup>
            </svg>
            {!ready && <span>{cooldown.toFixed(1)}</span>}
          </RadarButton>
        );
      })}
    </div>
  );
};
