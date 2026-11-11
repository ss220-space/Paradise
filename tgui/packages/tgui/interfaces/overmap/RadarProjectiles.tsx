import { useId } from 'react';

import type { RadarProjectile } from './OvermapRadar';

const sprites: Record<string, { path: string; color: string; scale: number }> =
  {
    light: {
      path: 'M 0 0.9 L -.2 .35 L -.2 -1 L .2 -1 L .2 .35 Z',
      color: '#ffe6af',
      scale: 0.8,
    },
    medium: {
      path: 'M 0 1.1 L -.38 .4 L -.38 -1.1 L .38 -1.1 L .38 .4 Z',
      color: '#ffbc68',
      scale: 1,
    },
    heavy: {
      path: 'M 0 1.25 L -.6 .45 L -.6 -1.2 L .6 -1.2 L .6 .45 Z M -.6 -.65 L .6 -.65',
      color: '#ff8256',
      scale: 1.3,
    },
    capital: {
      path: 'M 0 1.5 L -.8 .4 L -.6 -1.4 L .6 -1.4 L .8 .4 Z M -.6 -.7 L .6 -.7',
      color: '#ff4e6a',
      scale: 1.7,
    },
    laser_light: { path: 'M 0 1.4 L 0 -1.5', color: '#ff6f6f', scale: 0.85 },
    laser_heavy: {
      path: 'M -.2 1.6 L -.2 -1.6 M .2 1.6 L .2 -1.6',
      color: '#ff4c80',
      scale: 1.15,
    },
    laser_capital: {
      path: 'M -.4 1.8 L -.4 -1.8 M 0 2 L 0 -2 M .4 1.8 L .4 -1.8',
      color: '#ff99d8',
      scale: 1.5,
    },
    ion: {
      path: 'M 0 1.2 L -.7 0 L 0 -1.2 L .7 0 Z M -.4 0 L .4 0',
      color: '#79cfff',
      scale: 1.2,
    },
    capital_ion: {
      path: 'M 0 1.5 L -1 0 L 0 -1.5 L 1 0 Z M -.45 .6 L .45 -.6 M -.45 -.6 L .45 .6',
      color: '#bc93ff',
      scale: 1.7,
    },
    capital_rail: {
      path: 'M 0 1.8 L -.45 .8 L -.45 -1.7 L .45 -1.7 L .45 .8 Z M -.9 .3 L -.9 -1 M .9 .3 L .9 -1',
      color: '#d6ffff',
      scale: 1.6,
    },
    missile: {
      path: 'M 0 1.4 L -.4 .65 L -.4 -.6 L -.85 -1.3 L 0 -1 L .85 -1.3 L .4 -.6 L .4 .65 Z',
      color: '#a8ed8b',
      scale: 1.2,
    },
    guided_missile: {
      path: 'M 0 1.4 L -.4 .65 L -.4 -.6 L -.85 -1.3 L 0 -1 L .85 -1.3 L .4 -.6 L .4 .65 Z M -.95 .75 L -1.2 1.1 M .95 .75 L 1.2 1.1',
      color: '#76ffdb',
      scale: 1.3,
    },
  };

export const RadarProjectiles = (props: {
  shots: RadarProjectile[];
  world: number[];
  radius: number;
}) => {
  const prefix = useId().replace(/:/g, '');
  const size = Math.max(0.12, props.radius * 0.006);
  return (
    <g pointerEvents="none">
      <defs>
        {Object.entries(sprites).map(([kind, sprite]) => (
          <g id={`${prefix}-${kind}`} key={kind}>
            <path
              d="M 0 -1 L 0 -3.5"
              opacity={0.25}
              strokeWidth={2}
              vectorEffect="non-scaling-stroke"
            />
            <path
              d={sprite.path}
              strokeWidth={1.25}
              strokeLinejoin="round"
              vectorEffect="non-scaling-stroke"
            />
          </g>
        ))}
      </defs>
      {props.shots.map((shot) => {
        const kind = shot.kind && sprites[shot.kind] ? shot.kind : 'light';
        const sprite = sprites[kind];
        return (
          <use
            key={shot.id}
            href={`#${prefix}-${kind}`}
            stroke={sprite.color}
            fill={
              kind === 'medium' || kind === 'heavy' || kind === 'capital'
                ? sprite.color
                : 'none'
            }
            transform={`translate(${shot.x - props.world[0]} ${shot.y - props.world[1]}) rotate(${-shot.angle}) scale(${size * sprite.scale})`}
          />
        );
      })}
    </g>
  );
};
