import {
  interpolateRadarFrame,
  type RadarFrame,
  radarFrameDiscontinuous,
  radarFrameStationary,
} from './radarInterpolation';

export class RadarTimeline {
  private frames: { time: number; arrival: number; frame: RadarFrame }[];
  private timing: { time: number; arrival: number }[];
  private playhead: number;
  private renderedAt: number;
  private rate = 1;
  private readonly delay = 100;
  private readonly prediction = 300;

  constructor(frame: RadarFrame, arrival: number) {
    const time = frame.tick ?? arrival;
    this.frames = [{ frame, time, arrival }];
    this.timing = [{ time, arrival }];
    this.playhead = time - this.delay;
    this.renderedAt = arrival;
  }

  push(frame: RadarFrame, arrival: number) {
    const last = this.frames[this.frames.length - 1];
    const time = frame.tick ?? last.time + arrival - last.arrival;
    if (radarFrameDiscontinuous(last.frame, frame)) {
      this.frames = [{ frame, time, arrival }];
      this.timing = [{ time, arrival }];
      this.playhead = time - this.delay;
      this.renderedAt = arrival;
      this.rate = 1;
      return;
    }
    if (time < last.time) return;
    if (time === last.time) {
      last.frame = frame;
      return;
    }
    this.timing.push({ time, arrival });
    if (this.timing.length > 10) this.timing.shift();
    const first = this.timing[0];
    if (this.timing.length >= 4 && arrival > first.arrival) {
      const measured = Math.max(
        0.1,
        Math.min(2, (time - first.time) / (arrival - first.arrival)),
      );
      this.rate += (measured - this.rate) * 0.2;
    }
    this.frames.push({ frame, time, arrival });
    if (this.frames.length > 24) this.frames.shift();
  }

  at(arrival: number) {
    const last = this.frames[this.frames.length - 1];
    const target =
      last.time + (arrival - last.arrival) * this.rate - this.delay;
    const elapsed = Math.max(0, Math.min(100, arrival - this.renderedAt));
    const correction = Math.max(
      0.1,
      Math.min(1.3, 1 + (target - this.playhead) / 500),
    );
    this.playhead = Math.min(
      last.time + this.prediction,
      this.playhead + elapsed * this.rate * correction,
    );
    this.renderedAt = arrival;
    while (this.frames.length > 2 && this.frames[1].time <= this.playhead)
      this.frames.shift();
    const first = this.frames[0];
    if (this.playhead <= first.time) return first.frame;
    if (this.playhead >= last.time) {
      const previous = this.frames[this.frames.length - 2];
      if (!previous || radarFrameStationary(previous.frame, last.frame))
        return last.frame;
      return interpolateRadarFrame(
        previous.frame,
        last.frame,
        1 +
          Math.min(this.prediction, this.playhead - last.time) /
            Math.max(1, last.time - previous.time),
        true,
      );
    }
    const next = this.frames[1];
    return interpolateRadarFrame(
      first.frame,
      next.frame,
      (this.playhead - first.time) / (next.time - first.time),
    );
  }

  pending(_arrival: number) {
    const last = this.frames[this.frames.length - 1];
    const previous = this.frames[this.frames.length - 2];
    const moving =
      previous && !radarFrameStationary(previous.frame, last.frame);
    return this.playhead < last.time + (moving ? this.prediction : 0);
  }
}
