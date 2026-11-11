export type RadarEngine = [
  x: number,
  y: number,
  exhaustDirection: number,
  firing: number,
  thrust?: number,
];

const NOZZLE_VECTORS: Record<number, number[]> = {
  1: [0, 1],
  2: [0, -1],
  4: [1, 0],
  8: [-1, 0],
};

export const RadarEngines = (props: { engines: RadarEngine[] }) => (
  <>
    {props.engines.map(([x, y, dir, firing, thrust], index) => {
      const strength = Math.max(0, Math.min(4, thrust ?? (firing ? 1 : 0)));
      const length = 0.6 + 4 * Math.sqrt(strength);
      const [dx, dy] = NOZZLE_VECTORS[dir] || [0, -1];
      return (
        <g key={index}>
          {!!firing && strength > 0 && (
            <line
              className="OvermapRadar__burn"
              x1={x + dx * 0.6}
              y1={y + dy * 0.6}
              x2={x + dx * length}
              y2={y + dy * length}
              style={{
                strokeWidth: 0.7 + Math.sqrt(strength),
                opacity: 0.35 + 0.65 * Math.min(1, strength),
              }}
            />
          )}
          <circle
            className={
              firing
                ? 'OvermapRadar__engine OvermapRadar__engine--firing'
                : 'OvermapRadar__engine'
            }
            cx={x + dx * 0.5}
            cy={y + dy * 0.5}
            r={0.35}
          />
        </g>
      );
    })}
  </>
);
