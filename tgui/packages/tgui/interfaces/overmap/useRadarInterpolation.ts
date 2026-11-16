import { useEffect, useMemo, useRef, useState } from 'react';
import type { RadarFrame } from './radarInterpolation';
import { RadarTimeline } from './radarTimeline';

export const useRadarInterpolation = (
  input: RadarFrame,
  enabled = true,
  delay = 100,
) => {
  const sample = useMemo(
    () => input,
    [
      input.sectorId,
      input.tick,
      input.epoch,
      input.cellSpan,
      input.world,
      input.self,
      input.facing,
      input.contacts,
      input.objects,
      input.drifters,
      input.dockTargets,
      input.projectiles,
    ],
  );
  const [shown, setShown] = useState(sample);
  const timeline = useRef<RadarTimeline | null>(null);
  const animation = useRef(0);
  const timingDelay = useRef(delay);
  if (!timeline.current || timingDelay.current !== delay) {
    timeline.current = new RadarTimeline(sample, performance.now(), delay);
    timingDelay.current = delay;
  }
  useEffect(() => {
    timeline.current!.push(sample, performance.now());
    if (!enabled) {
      cancelAnimationFrame(animation.current);
      animation.current = 0;
      return;
    }
    const tick = (time: number) => {
      setShown(timeline.current!.at(time));
      animation.current = timeline.current!.pending(time)
        ? requestAnimationFrame(tick)
        : 0;
    };
    if (!animation.current) animation.current = requestAnimationFrame(tick);
  }, [sample, enabled, delay]);
  useEffect(() => {
    return () => {
      if (animation.current) cancelAnimationFrame(animation.current);
      animation.current = 0;
    };
  }, []);
  return enabled ? shown : sample;
};
