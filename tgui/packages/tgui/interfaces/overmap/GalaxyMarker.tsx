import { markerPath, validMarkerImage } from './galaxyGeometry.mjs';
import type { GalaxyMarkerStyle } from './galaxyTypes';

export const GalaxyMarker = ({
  marker: suppliedMarker,
  color,
  defaultShape = 'circle',
}: {
  marker?: GalaxyMarkerStyle | null;
  color: string;
  defaultShape?: string;
}) => {
  const marker = suppliedMarker ?? {};
  const shape = marker.shape || defaultShape;
  const r = marker.size ?? (defaultShape === 'circle' ? 3.5 : 5);
  const tint = marker.color || color;
  const path = markerPath(shape, r);
  const size = marker.imageSize ?? 32;
  return (
    <g
      opacity={marker.opacity ?? 1}
      transform={`rotate(${marker.rotation || 0})`}
    >
      {validMarkerImage(marker.image) ? (
        <image
          href={marker.image}
          x={-size / 2}
          y={-size / 2}
          width={size}
          height={size}
          preserveAspectRatio="xMidYMid meet"
        />
      ) : path ? (
        <path
          d={path}
          fill={shape === 'cross' ? 'none' : marker.fill || tint}
          stroke={tint}
          strokeWidth={marker.width ?? 1}
        />
      ) : (
        <circle
          r={r}
          fill={shape === 'ring' ? 'none' : marker.fill || tint}
          stroke={tint}
          strokeWidth={marker.width ?? 1}
        />
      )}
    </g>
  );
};
