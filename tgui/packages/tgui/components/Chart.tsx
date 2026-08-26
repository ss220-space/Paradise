/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { type CSSProperties, useEffect, useRef, useState } from 'react';
import { zip } from 'common/collections';
import { Box, type BoxProps } from './Box';

type Props = {
  data: number[][];
} & Partial<{
  fillColor: string;
  rangeX: [number, number];
  rangeY: [number, number];
  strokeColor: string;
  strokeWidth: number;
}> &
  BoxProps;

type Point = number[];
type Range = [number, number];
type ViewBox = [number, number];

const normalizeData = (
  data: Point[],
  scale: number[],
  rangeX?: Range,
  rangeY?: Range
) => {
  if (data.length === 0) {
    return [];
  }

  const zipped = zip(...data);

  const min = zipped.map((p) => Math.min(...p));
  const max = zipped.map((p) => Math.max(...p));

  if (rangeX !== undefined) {
    min[0] = rangeX[0];
    max[0] = rangeX[1];
  }

  if (rangeY !== undefined) {
    min[1] = rangeY[0];
    max[1] = rangeY[1];
  }

  const normalized = data.map((point) =>
    zip(point, min, max, scale).map(
      ([value, min, max, scale]) => ((value - min) / (max - min)) * scale
    )
  );

  return normalized;
};

const dataToPolylinePoints = (data) => {
  let points = '';
  for (let i = 0; i < data.length; i++) {
    const point = data[i];
    points += `${point[0]},${point[1]} `;
  }
  return points;
};

const computedStyles: CSSProperties = {
  position: 'absolute',
  top: 0,
  left: 0,
  right: 0,
  bottom: 0,
  overflow: 'hidden',
};

export const Chart = (props: Props) => {
  const {
    data = [],
    rangeX,
    rangeY,
    fillColor = 'none',
    strokeColor = '#ffffff',
    strokeWidth = 2,
    ...rest
  } = props;

  const innerRef = useRef<HTMLDivElement>(null);
  const [viewBox, setViewBox] = useState<ViewBox>([600, 200]);

  const normalized = normalizeData(data, viewBox, rangeX, rangeY);
  // Push data outside viewBox and form a fillable polygon
  if (normalized.length > 0) {
    const first = normalized[0];
    const last = normalized[normalized.length - 1];
    normalized.push([viewBox[0] + strokeWidth, last[1]]);
    normalized.push([viewBox[0] + strokeWidth, -strokeWidth]);
    normalized.push([-strokeWidth, -strokeWidth]);
    normalized.push([-strokeWidth, first[1]]);
  }
  const points = dataToPolylinePoints(normalized);

  const handleResize = () => {
    const element = innerRef.current;
    if (!element) {
      return;
    }

    const rect = element.getBoundingClientRect();
    setViewBox([rect.width, rect.height]);
  };

  useEffect(() => {
    window.addEventListener('resize', handleResize);
    handleResize();

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);

  return (
    <Box position="relative" {...rest}>
      <div ref={innerRef} style={computedStyles}>
        <svg
          viewBox={`0 0 ${viewBox[0]} ${viewBox[1]}`}
          preserveAspectRatio="none"
          style={computedStyles}
        >
          <title>chart</title>
          <polyline
            transform={`scale(1, -1) translate(0, -${viewBox[1]})`}
            fill={fillColor}
            stroke={strokeColor}
            strokeWidth={strokeWidth}
            points={points}
          />
        </svg>
      </div>
    </Box>
  );
};

Chart.Line = Chart;
