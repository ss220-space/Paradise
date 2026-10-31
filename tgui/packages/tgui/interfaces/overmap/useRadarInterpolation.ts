import { useEffect, useMemo, useRef, useState } from 'react';
import type { RadarFrame } from './radarInterpolation';
import { RadarTimeline } from './radarTimeline';

export const useRadarInterpolation = (input: RadarFrame) => {
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
  if (!timeline.current) {
    timeline.current = new RadarTimeline(sample, performance.now());
  }
  useEffect(() => {
    timeline.current!.push(sample, performance.now());
    if (animation.current) cancelAnimationFrame(animation.current);
    const tick = (time: number) => {
      setShown(timeline.current!.at(time));
      animation.current = timeline.current!.pending(time)
        ? requestAnimationFrame(tick)
        : 0;
    };
    animation.current = requestAnimationFrame(tick);
    return () => {
      if (animation.current) cancelAnimationFrame(animation.current);
      animation.current = 0;
    };
  }, [sample]);
  return shown;
};
