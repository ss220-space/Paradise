import { useLayoutEffect, useRef } from 'react';
import type { RadarFrame } from './radarInterpolation';
import { RadarTimeline } from './radarTimeline';

type DrawRadar = (frame: RadarFrame) => void;

const MAX_PAINT_GAP_MS = 100;
const FALLBACK_FRAME_MS = 1000 / 30;

export const useRadarInterpolation = (sample: RadarFrame, draw: DrawRadar) => {
  const update = useRef<(sample: RadarFrame, draw: DrawRadar) => void>(null);

  useLayoutEffect(() => {
    let clock: RadarTimeline;
    let lastSample: RadarFrame | undefined;
    let painter: DrawRadar;
    let lastPaint = -Infinity;
    let requestedAt = 0;
    let slowAnimation = false;
    let animation = 0;
    let fallback = 0;

    function schedule() {
      if (document.hidden) return;
      if (!animation) {
        requestedAt = performance.now();
        animation = requestAnimationFrame(tick);
      }
      if (!fallback && !document.hasFocus()) {
        fallback = window.setTimeout(checkAnimation, MAX_PAINT_GAP_MS);
      }
    }

    function paint(now: number, skipCorrection = false) {
      painter(clock.at(now, skipCorrection));
      lastPaint = now;
    }

    function tick() {
      const now = performance.now();
      slowAnimation = !!animation && now - requestedAt >= FALLBACK_FRAME_MS;
      animation = 0;
      paint(now);
      if (clock.pending(now)) schedule();
    }

    function checkAnimation() {
      fallback = 0;
      if (!animation || document.hidden || document.hasFocus()) return;
      const now = performance.now();
      if (now - requestedAt >= MAX_PAINT_GAP_MS) slowAnimation = true;
      if (slowAnimation && now - lastPaint >= FALLBACK_FRAME_MS - 1) {
        paint(now);
      }
      if (clock.pending(now)) {
        fallback = window.setTimeout(
          checkAnimation,
          slowAnimation ? FALLBACK_FRAME_MS : MAX_PAINT_GAP_MS,
        );
      }
    }

    function refresh() {
      cancelAnimationFrame(animation);
      window.clearTimeout(fallback);
      animation = 0;
      fallback = 0;
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
      window.clearTimeout(fallback);
      update.current = null;
      document.removeEventListener('visibilitychange', refresh);
    };
  }, []);

  useLayoutEffect(() => update.current?.(sample, draw), [sample, draw]);
};
