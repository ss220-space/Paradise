import type {
  RadarContact,
  RadarObject,
  RadarProjectile,
  RadarPose,
} from './OvermapRadar';

export type RadarDock = {
  id: string;
  name: string;
  x: number;
  y: number;
  host_id?: string;
  hull_x?: number;
  hull_y?: number;
  available?: boolean | number;
  own?: boolean | number;
  selected?: boolean | number;
};

export const mergeRadarPoses = (
  objects: RadarObject[],
  poses?: RadarPose[] | null,
) => {
  if (!poses) return objects;
  const byId = new Map(poses.map((pose) => [pose.id, pose]));
  return objects.flatMap((object) => {
    const pose = object.id && byId.get(object.id);
    return pose ? [{ ...object, ...pose }] : [];
  });
};

export type RadarFrame = {
  tick?: number;
  epoch?: number;
  sectorId?: string;
  cellSpan: number;
  world?: number[];
  self?: number[];
  facing: number;
  contacts: RadarContact[];
  objects: RadarObject[];
  drifters: number[][];
  dockTargets?: RadarDock[];
  projectiles?: RadarProjectile[];
};

const blend = (a: number, b: number, fraction: number) =>
  a + (b - a) * fraction;

const angleBlend = (a: number, b: number, fraction: number) =>
  a + (((((b - a) % 360) + 540) % 360) - 180) * fraction;

const rotate = (x: number, y: number, facing: number): number[] => {
  const angle = (facing * Math.PI) / 180;
  return [
    x * Math.cos(angle) + y * Math.sin(angle),
    y * Math.cos(angle) - x * Math.sin(angle),
  ];
};

export const radarClickWorld = (
  screen: number[],
  radius: number,
  facing: number,
  world: number[],
  offset: number[],
): number[] => {
  const [x, y] = rotate(screen[0] * radius, -screen[1] * radius, facing);
  return [world[0] + offset[0] + x, world[1] + offset[1] + y];
};

export const radarToWorld = (point: number[], frame: RadarFrame): number[] => {
  const [x, y] = rotate(point[0], point[1], frame.facing);
  return [x + (frame.world?.[0] || 0), y + (frame.world?.[1] || 0)];
};

const toHull = (point: number[], frame: RadarFrame) =>
  rotate(
    point[0] - (frame.world?.[0] || 0),
    point[1] - (frame.world?.[1] || 0),
    -frame.facing,
  );

export const radarFrameDiscontinuous = (a: RadarFrame, b: RadarFrame) =>
  a.epoch !== b.epoch ||
  a.sectorId !== b.sectorId ||
  a.cellSpan !== b.cellSpan ||
  !!a.world !== !!b.world ||
  (!!a.world &&
    !!b.world &&
    Math.hypot(a.world[0] - b.world[0], a.world[1] - b.world[1]) > 64);

const sameItems = <T>(
  a: T[] | undefined,
  b: T[] | undefined,
  equal: (a: T, b: T) => boolean,
) =>
  (a?.length || 0) === (b?.length || 0) &&
  (!a?.length || a.every((item, index) => equal(item, b![index])));

export const radarFrameStationary = (a: RadarFrame, b: RadarFrame) =>
  !radarFrameDiscontinuous(a, b) &&
  (a.facing - b.facing) % 360 === 0 &&
  sameItems(a.world, b.world, (x, y) => x === y) &&
  sameItems(a.self, b.self, (x, y) => x === y) &&
  sameItems(
    a.contacts,
    b.contacts,
    (x, y) => x.id === y.id && x.x === y.x && x.y === y.y && x.rot === y.rot,
  ) &&
  sameItems(
    a.objects,
    b.objects,
    (x, y) =>
      x.id === y.id && x.x === y.x && x.y === y.y && x.facing === y.facing,
  ) &&
  sameItems(a.drifters, b.drifters, (x, y) => x[0] === y[0] && x[1] === y[1]) &&
  sameItems(
    a.projectiles,
    b.projectiles,
    (x, y) =>
      x.id === y.id && x.x === y.x && x.y === y.y && x.angle === y.angle,
  ) &&
  sameItems(
    a.dockTargets,
    b.dockTargets,
    (x, y) => x.id === y.id && x.x === y.x && x.y === y.y,
  );

type FrameIndex = {
  contacts: Map<string, RadarFrame['contacts'][number]>;
  objects: Map<string | undefined, RadarFrame['objects'][number]>;
  shots: Map<string, NonNullable<RadarFrame['projectiles']>[number]>;
  docks: Map<string, NonNullable<RadarFrame['dockTargets']>[number]>;
};
const frameIndexes = new WeakMap<RadarFrame, FrameIndex>();
const indexFrame = (frame: RadarFrame): FrameIndex => {
  let index = frameIndexes.get(frame);
  if (!index) {
    index = {
      contacts: new Map(frame.contacts.map((entry) => [entry.id, entry])),
      objects: new Map(frame.objects.map((entry) => [entry.id, entry])),
      shots: new Map(frame.projectiles?.map((entry) => [entry.id, entry])),
      docks: new Map(frame.dockTargets?.map((entry) => [entry.id, entry])),
    };
    frameIndexes.set(frame, index);
  }
  return index;
};

export const interpolateRadarFrame = (
  start: RadarFrame,
  target: RadarFrame,
  fraction: number,
  extrapolate = false,
): RadarFrame => {
  if ((!extrapolate && fraction >= 1) || radarFrameDiscontinuous(start, target))
    return target;
  const frame: RadarFrame = {
    ...target,
    facing: angleBlend(start.facing, target.facing, fraction),
    world: target.world?.map((value, index) =>
      blend(start.world?.[index] ?? value, value, fraction),
    ),
  };
  frame.self = target.self?.map(
    (value, index) =>
      value +
      ((frame.world?.[index] || 0) - (target.world?.[index] || 0)) /
        target.cellSpan,
  );
  const index = indexFrame(start);
  const previous = index.contacts;
  frame.contacts = target.contacts.map((contact) => {
    if (contact.own) return contact;
    const old = previous.get(contact.id);
    const end = radarToWorld([contact.x, contact.y], target);
    const begin = old ? radarToWorld([old.x, old.y], start) : end;
    const [x, y] = toHull(
      end.map((value, index) => blend(begin[index], value, fraction)),
      frame,
    );
    const rot =
      angleBlend(
        old ? old.rot + start.facing : contact.rot + target.facing,
        contact.rot + target.facing,
        fraction,
      ) - frame.facing;
    return { ...contact, x, y, rot };
  });
  frame.drifters = target.drifters.map((point) => [
    ...toHull(radarToWorld(point, target), frame),
    ...point.slice(2),
  ]);
  const oldShots = index.shots;
  frame.projectiles = target.projectiles?.map((shot) => {
    const old = oldShots.get(shot.id);
    return old
      ? {
          ...shot,
          x: blend(old.x, shot.x, fraction),
          y: blend(old.y, shot.y, fraction),
          angle: angleBlend(old.angle, shot.angle, fraction),
        }
      : shot;
  });
  const contacts = new Map(
    frame.contacts.map((contact) => [contact.id, contact]),
  );
  const oldDocks = index.docks;
  frame.dockTargets = target.dockTargets?.map((dock) => {
    if (dock.own && dock.hull_x !== undefined && dock.hull_y !== undefined) {
      const [x, y] = radarToWorld([dock.hull_x, dock.hull_y], frame);
      return { ...dock, x, y };
    }
    const host = dock.host_id ? contacts.get(dock.host_id) : undefined;
    if (host && dock.hull_x !== undefined && dock.hull_y !== undefined) {
      const center = radarToWorld([host.x, host.y], frame);
      const offset = rotate(dock.hull_x, dock.hull_y, host.rot + frame.facing);
      return { ...dock, x: center[0] + offset[0], y: center[1] + offset[1] };
    }
    const old = oldDocks.get(dock.id);
    return old
      ? {
          ...dock,
          x: blend(old.x, dock.x, fraction),
          y: blend(old.y, dock.y, fraction),
        }
      : dock;
  });
  const oldObjects = index.objects;

  frame.objects = target.objects.map((object) => {
    if (object.is_self && frame.self) {
      return { ...object, x: frame.self[0], y: frame.self[1] };
    }
    const contact = object.id && contacts.get(object.id);
    if (contact && frame.self && frame.world) {
      const point = radarToWorld([contact.x, contact.y], frame);
      return {
        ...object,
        x: frame.self[0] + (point[0] - frame.world[0]) / frame.cellSpan,
        y: frame.self[1] + (point[1] - frame.world[1]) / frame.cellSpan,
        facing: contact.rot + frame.facing,
      };
    }
    const old = object.id && oldObjects.get(object.id);
    return old
      ? {
          ...object,
          x: blend(old.x, object.x, fraction),
          y: blend(old.y, object.y, fraction),
          facing: angleBlend(old.facing || 0, object.facing || 0, fraction),
        }
      : object;
  });
  return frame;
};
