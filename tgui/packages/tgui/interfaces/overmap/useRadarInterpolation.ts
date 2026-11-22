import { useLayoutEffect, useRef } from 'react';
import type { RadarFrame } from './radarInterpolation';
import { RadarTimeline } from './radarTimeline';

type DrawRadar = (frame: RadarFrame) => void;

const MAX_PAINT_GAP_MS = 100;

export const useRadarInterpolation = (sample: RadarFrame, draw: DrawRadar) => {
  const update = useRef<(sample: RadarFrame, draw: DrawRadar) => void>(null);

  useLayoutEffect(() => {
    let clock: RadarTimeline;
    let lastSample: RadarFrame | undefined;
    let painter: DrawRadar;
    let lastPaint = -Infinity;
    let animation = 0;

    function schedule() {
      if (!animation && !document.hidden) animation = requestAnimationFrame(tick);
    }

    function paint(now: number, skipCorrection = false) {
      painter(clock.at(now, skipCorrection));
      lastPaint = now;
    }

    function tick() {
      animation = 0;
      const now = performance.now();
      paint(now);
      if (clock.pending(now)) schedule();
    }

    function refresh() {
      cancelAnimationFrame(animation);
      animation = 0;
      if (lastSample && !document.hidden) tick();
    }

    update.current = (sample, draw) => {
      const viewChanged = painter !== draw;
      painter = draw;
      const now = performance.now();
      if (!lastSample) clock = new RadarTimeline(sample, now);
      else if (sample !== lastSample) clock.push(sample, now);
      lastSample = sample;
      const stale = document.hidden || now - lastPaint >= MAX_PAINT_GAP_MS;
      if (viewChanged || stale) {
        paint(now, stale);
        if (!clock.pending(now)) return;
      }
      schedule();
    };

    document.addEventListener('visibilitychange', refresh);
    return () => {
      cancelAnimationFrame(animation);
      update.current = null;
      document.removeEventListener('visibilitychange', refresh);
    };
  }, []);

  useLayoutEffect(() => update.current?.(sample, draw), [sample, draw]);
};
