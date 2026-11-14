import { useEffect, useLayoutEffect, useRef, useState } from 'react';

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

const paths = new Map<string, Path2D>();
const pathFor = (kind: string) => {
  let path = paths.get(kind);
  if (!path) {
    path = new Path2D(sprites[kind].path);
    paths.set(kind, path);
  }
  return path;
};

export const RadarProjectiles = (props: {
  shots: RadarProjectile[];
  world: number[];
  radius: number;
  rotation: number;
  offset: [number, number];
}) => {
  const canvas = useRef<HTMLCanvasElement>(null);
  const [viewport, setViewport] = useState({ width: 640, height: 640 });
  useEffect(() => {
    const element = canvas.current;
    if (!element) return;
    const observer = new ResizeObserver(([entry]) => {
      const { width, height } = entry.contentRect;
      if (width && height) setViewport({ width, height });
    });
    observer.observe(element);
    return () => observer.disconnect();
  }, []);
  useLayoutEffect(() => {
    const element = canvas.current;
    const ctx = element?.getContext('2d');
    if (!element || !ctx) return;
    const { width, height } = viewport;
    const density = Math.min(window.devicePixelRatio || 1, 2);
    const pixelWidth = Math.round(width * density);
    const pixelHeight = Math.round(height * density);
    if (element.width !== pixelWidth || element.height !== pixelHeight) {
      element.width = pixelWidth;
      element.height = pixelHeight;
    }
    ctx.setTransform(density, 0, 0, density, 0, 0);
    ctx.clearRect(0, 0, width, height);
    ctx.translate(width / 2, height / 2);
    const scale = Math.min(width, height) / (2 * props.radius);
    ctx.scale(scale, -scale);
    ctx.rotate((props.rotation * Math.PI) / 180);
    ctx.translate(-props.offset[0], -props.offset[1]);
    ctx.globalAlpha = 0.9;
    ctx.lineJoin = 'round';
    const size = Math.max(0.12, props.radius * 0.006);
    for (const shot of props.shots) {
      const x = shot.x - props.world[0];
      const y = shot.y - props.world[1];
      if (
        Math.hypot(x - props.offset[0], y - props.offset[1]) >
        props.radius + size * 8
      )
        continue;
      const kind = shot.kind && sprites[shot.kind] ? shot.kind : 'light';
      const sprite = sprites[kind];
      const glyphScale = size * sprite.scale;
      ctx.save();
      ctx.translate(x, y);
      ctx.rotate((-shot.angle * Math.PI) / 180);
      ctx.scale(glyphScale, glyphScale);
      ctx.strokeStyle = sprite.color;
      ctx.fillStyle = sprite.color;
      ctx.lineWidth = 1.25 / (scale * glyphScale);
      ctx.stroke(pathFor(kind));
      if (kind === 'medium' || kind === 'heavy' || kind === 'capital')
        ctx.fill(pathFor(kind));
      ctx.globalAlpha = 0.225;
      ctx.lineWidth = 2 / (scale * glyphScale);
      ctx.beginPath();
      ctx.moveTo(0, -1);
      ctx.lineTo(0, -3.5);
      ctx.stroke();
      ctx.restore();
    }
  }, [
    props.shots,
    props.world,
    props.radius,
    props.rotation,
    props.offset,
    viewport,
  ]);
  return (
    <canvas
      ref={canvas}
      className="OvermapRadar__projectiles"
      aria-hidden="true"
    />
  );
};
