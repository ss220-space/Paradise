import { useLayoutEffect, useRef } from 'react';
import type { RadarFrame } from './radarInterpolation';
import { RadarTimeline } from './radarTimeline';

type DrawRadar = (frame: RadarFrame) => void;

const BACKGROUND_FRAME_MS = 1000 / 30;
const MAX_PAINT_GAP_MS = 100;

export const useRadarInterpolation = (sample: RadarFrame, draw: DrawRadar) => {
  const update = useRef<(sample: RadarFrame, draw: DrawRadar) => void>(null);

  useLayoutEffect(() => {
    let clock: RadarTimeline;
    let lastSample: RadarFrame | undefined;
    let painter: DrawRadar;
    let lastPaint = -Infinity;
    let focused = document.hasFocus();
    let animation = 0;
    let timer = 0;

    function schedule() {
      if (document.hidden || animation || timer) return;
      if (focused) animation = requestAnimationFrame(tick);
      else timer = window.setTimeout(tick, BACKGROUND_FRAME_MS);
    }

    function paint(now: number, skipCorrection = false) {
      painter(clock.at(now, skipCorrection));
      lastPaint = now;
    }

    function tick() {
      animation = timer = 0;
      const now = performance.now();
      paint(now);
      if (clock.pending(now)) schedule();
    }

    function cancel() {
      cancelAnimationFrame(animation);
      window.clearTimeout(timer);
      animation = timer = 0;
    }

    function refresh() {
      cancel();
      focused = document.hasFocus();
      if (!lastSample || document.hidden) return;
      tick();
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

    window.addEventListener('blur', refresh);
    window.addEventListener('focus', refresh);
    document.addEventListener('visibilitychange', refresh);
    return () => {
      cancel();
      update.current = null;
      window.removeEventListener('blur', refresh);
      window.removeEventListener('focus', refresh);
      document.removeEventListener('visibilitychange', refresh);
    };
  }, []);

  useLayoutEffect(() => update.current?.(sample, draw), [sample, draw]);
};
