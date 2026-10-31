export const GEOMETRY_FULL = 110;
export const GEOMETRY_FADE = 170;

export const radarWheelZoom = (
  radius: number,
  outward: boolean,
  galaxyBoundary: number,
) => {
  const direction = outward ? 1 : -1;
  const boundary = outward
    ? radius < GEOMETRY_FULL
      ? GEOMETRY_FULL
      : radius < galaxyBoundary
        ? galaxyBoundary
        : undefined
    : radius > galaxyBoundary
      ? galaxyBoundary
      : radius > GEOMETRY_FULL
        ? GEOMETRY_FULL
        : undefined;
  const proximity = boundary
    ? Math.min(1, Math.abs(Math.log(radius / boundary)) / Math.log(1.8))
    : 1;
  const speed = boundary ? 0.018 + 0.13 * proximity * proximity : 0.148;
  const next = radius * Math.exp(direction * speed);
  if (boundary && (radius - boundary) * (next - boundary) < 0) {
    return boundary;
  }
  return next;
};
