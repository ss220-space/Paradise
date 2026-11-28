import {
  interpolateRadarFrame,
  type RadarFrame,
  radarFrameDiscontinuous,
  radarFrameStationary,
} from './radarInterpolation';

const CORRECTION_MS = 60;
const MAX_PREDICTION_MS = 750;
const CLOCK_WINDOW_MS = 1000;

export class RadarTimeline {
  private previous?: RadarFrame;
  private latest: RadarFrame;
  private arrivedAt: number;
  private sampleAt: number;
  private clockAt: number;
  private clockTick?: number;
  private rate = 1;
  private interval = 0;
  private moving = false;
  private correction?: { from: RadarFrame; to: RadarFrame };

  constructor(frame: RadarFrame, arrival: number) {
    this.latest = frame;
    this.sampleAt = this.arrivedAt = this.clockAt = arrival;
    this.clockTick = frame.tick;
  }

  push(frame: RadarFrame, arrival: number) {
    const elapsed = arrival - this.arrivedAt;
    const timed = frame.tick !== undefined && this.latest.tick !== undefined;
    const step = timed ? frame.tick! - this.latest.tick! : elapsed;
    const discontinuous = radarFrameDiscontinuous(this.latest, frame);
    if (
      step < 0 &&
      this.latest.epoch === frame.epoch &&
      this.latest.sectorId === frame.sectorId
    )
      return;
    if (
      discontinuous ||
      (step > 0 && (elapsed > CLOCK_WINDOW_MS || step > CLOCK_WINDOW_MS))
    ) {
      this.previous = undefined;
      this.correction = undefined;
      this.latest = frame;
      this.sampleAt = this.arrivedAt = this.clockAt = arrival;
      this.clockTick = frame.tick;
      this.rate = 1;
      this.moving = false;
      return;
    }
    if (step === 0) {
      this.latest = frame;
      this.moving =
        !!this.previous && !radarFrameStationary(this.previous, frame);
      if (this.correction)
        this.correction.to = this.predict(
          this.arrivedAt - this.sampleAt + CORRECTION_MS,
        );
      return;
    }

    const displayed = this.at(arrival);
    if (!this.previous || arrival - this.clockAt >= CLOCK_WINDOW_MS) {
      if (frame.tick !== undefined && this.clockTick !== undefined) {
        this.rate = Math.max(
          0.1,
          Math.min(2, (frame.tick - this.clockTick) / (arrival - this.clockAt)),
        );
      }
      this.clockAt = arrival;
      this.clockTick = frame.tick;
    }

    this.interval = timed ? step / this.rate : elapsed;
    const late =
      this.previous && timed
        ? Math.min(
            this.interval / 2,
            Math.max(0, arrival - this.sampleAt - this.interval),
          )
        : 0;
    this.sampleAt = arrival - late;
    this.previous = this.latest;
    this.latest = frame;
    this.arrivedAt = arrival;
    this.moving = !radarFrameStationary(this.previous, frame);
    this.correction =
      !this.moving || radarFrameStationary(displayed, this.predict(late))
        ? undefined
        : { from: displayed, to: this.predict(late + CORRECTION_MS) };
  }

  private predict(elapsed: number) {
    if (!this.previous || !this.moving || elapsed <= 0) return this.latest;
    const ahead = Math.min(elapsed, this.interval * 1.5, MAX_PREDICTION_MS);
    return interpolateRadarFrame(
      this.previous,
      this.latest,
      1 + ahead / this.interval,
      true,
    );
  }

  at(arrival: number, skipCorrection = false) {
    const elapsed = Math.max(0, arrival - this.arrivedAt);
    if (!skipCorrection && this.correction && elapsed < CORRECTION_MS) {
      return interpolateRadarFrame(
        this.correction.from,
        this.correction.to,
        elapsed / CORRECTION_MS,
      );
    }
    this.correction = undefined;
    return this.predict(arrival - this.sampleAt);
  }

  pending(arrival: number) {
    const elapsed = arrival - this.arrivedAt;
    return (
      (!!this.correction && elapsed < CORRECTION_MS) ||
      (this.moving &&
        arrival - this.sampleAt <
          Math.min(this.interval * 1.5, MAX_PREDICTION_MS))
    );
  }
}
