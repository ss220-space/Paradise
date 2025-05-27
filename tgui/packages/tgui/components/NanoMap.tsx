import {
  useState,
  useRef,
  useCallback,
  ReactNode,
  MouseEventHandler,
  useEffect,
  CSSProperties,
} from 'react';
import { Box, Icon, Tooltip, Button, Flex, Dropdown, Image, Stack } from '.';
import { useBackend } from '../backend';
import { LabeledList } from './LabeledList';
import { Slider } from './Slider';
import { resolveAsset } from '../assets';
import { Placement } from '@popperjs/core';

const MAP_SIZE = 510;
const HALF_SIZE = MAP_SIZE / 2;
/** At zoom = 1 */
const PIXELS_PER_TURF = 2;

const pauseEvent = (e: {
  stopPropagation: () => void;
  preventDefault: () => void;
}) => {
  e.stopPropagation();
  e.preventDefault();
};

type Props = Partial<{
  onZoom: (e: Event, n: number) => void;
  zCurrent: number;
  zLevels: number[];
  zNames: string[];
  offsetX: number;
  offsetY: number;
  onOffsetChange: (e: Event, v: Position) => void;
  onOffsetChangeEnded: (e: Event, v: Position) => void;
  zoom: number;
  children: ReactNode;
  setZCurrent: (z: number) => void;
}>;

type Position = {
  x: number;
  y: number;
};

export const NanoMap = (props: Props) => {
  const { config } = useBackend();

  const [position, setPosition] = useState<Position>({
    x: props.offsetX ?? 0,
    y: props.offsetY ?? 0,
  });
  const [zCurrent, setZCurrent] = useState<number>(props.zCurrent);
  const [zoom, setZoom] = useState(props.zoom ?? 1);
  const [dragging, setDragging] = useState(false);
  const dragStartPos = useRef({ x: HALF_SIZE, y: HALF_SIZE });

  // Обработчики событий мыши
  const handleMouseDown = useCallback(
    (e: React.MouseEvent<HTMLDivElement>) => {
      setDragging(true);
      dragStartPos.current = {
        x: e.clientX - position.x,
        y: e.clientY - position.y,
      };

      pauseEvent(e);
    },
    [position]
  );

  const handleMouseMove = useCallback(
    (e: MouseEvent) => {
      if (!dragging) return;

      setPosition({
        x: e.clientX - dragStartPos.current.x,
        y: e.clientY - dragStartPos.current.y,
      });
      props.onOffsetChange?.(e, position);
      pauseEvent(e);
    },
    [dragging]
  );

  const handleMouseUp = useCallback((e: MouseEvent) => {
    props?.onOffsetChangeEnded?.(e, position);
    setDragging(false);
  }, []);

  // Подписываемся на события мыши
  useEffect(() => {
    if (dragging) {
      document.addEventListener('mousemove', handleMouseMove);
      document.addEventListener('mouseup', handleMouseUp);
      return () => {
        document.removeEventListener('mousemove', handleMouseMove);
        document.removeEventListener('mouseup', handleMouseUp);
      };
    }
  }, [dragging, handleMouseMove, handleMouseUp]);

  const handleZoom = (_e: Event, value: number) => {
    const newZoom = Math.min(Math.max(value, 1), 8);
    props.onZoom?.(_e, newZoom);
    setZoom(newZoom);
  };

  const handleZChange = (value: number) => {
    props.setZCurrent(value);
    setZCurrent(value);
  };

  const handleReset = (e: Event) => {
    props.onOffsetChange?.(e, position);
    setPosition({ x: 0, y: 0 });
    handleZoom(e, 1);
  };

  const index = props.zLevels.indexOf(Number(zCurrent));
  console.log(typeof zCurrent); // Должно быть "number"
  console.log(props.zLevels.map((item) => typeof item)); // Должно быть ["number", "number", "number"]
  const mapUrl = config.map + '_nanomap_z' + (index + 1) + '.png';

  const newStyle = {
    width: `${MAP_SIZE * zoom}px`,
    height: `${MAP_SIZE * zoom}px`,
    position: 'relative',
    top: '50%',
    left: '50%',
    transform: `translate(${(-HALF_SIZE + position.x) * zoom}px, ${(-HALF_SIZE + position.y) * zoom}px)`,
    cursor: dragging ? 'move' : 'auto',
    userSelect: 'none', // Предотвращаем выделение текста при перетаскивании
  } as CSSProperties;

  const mapStyle = {
    width: '100%',
    height: '100%',
    position: 'absolute',
    left: 0,
  } as CSSProperties;

  return (
    <Box className="NanoMap__container">
      <Box onMouseDown={handleMouseDown} style={newStyle}>
        <Image src={resolveAsset(mapUrl)} style={mapStyle} />
        <Box>{props.children}</Box>
      </Box>
      <Stack className="NanoMap__options" vertical>
        <Stack.Item ml={0.5}>
          <NanoMapZoomer
            zoom={zoom}
            onZoom={handleZoom}
            onReset={handleReset}
          />
        </Stack.Item>
        <Stack.Item>
          <NanoMapZLeveler
            zCurrent={zCurrent}
            zNames={props.zNames}
            zLevels={props.zLevels}
            onZChange={handleZChange}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

export type NanoMakerProps = Partial<{
  x: number;
  y: number;
  z: number;
  z_current: number;
  zoom: number;
  tooltip: ReactNode;
  tooltipPosition: Placement;
  children: ReactNode;
  bordered: boolean;
  onClick: MouseEventHandler<HTMLDivElement>;
  onDblClick: MouseEventHandler<HTMLDivElement>;
}>;

const NanoMapMarker = (props: NanoMakerProps) => {
  const {
    x,
    y,
    z,
    z_current,
    zoom = 1,
    tooltip,
    tooltipPosition,
    bordered,
    onClick,
    onDblClick,
    children,
  } = props;
  if (z_current !== z) {
    return null;
  }
  const pixelsPerTurfAtZoom = PIXELS_PER_TURF * zoom;
  // For some reason the X and Y are offset by 1
  const rx = (x - 1) * pixelsPerTurfAtZoom;
  const ry = (y - 1) * pixelsPerTurfAtZoom;
  return (
    <Tooltip content={tooltip} position={tooltipPosition}>
      <div style={{ position: 'absolute', bottom: ry + 'px', left: rx + 'px' }}>
        <Box
          className={bordered ? 'NanoMap__marker__bordered' : 'NanoMap__marker'}
          lineHeight="0"
          width={pixelsPerTurfAtZoom + 'px'}
          height={pixelsPerTurfAtZoom + 'px'}
          onClick={onClick}
          onDoubleClick={onDblClick}
        >
          {children}
        </Box>
      </div>
    </Tooltip>
  );
};

NanoMap.Marker = NanoMapMarker;

type NanoMapMarkerIconProps = Partial<{
  icon: string;
  color: string;
  zoom: number;
}> &
  NanoMakerProps;

const NanoMapMarkerIcon = (props: NanoMapMarkerIconProps) => {
  const { icon, color, zoom, ...rest } = props;
  const markerSize = PIXELS_PER_TURF * zoom + 4 / Math.ceil(zoom / 4);
  return (
    <NanoMapMarker zoom={zoom} {...rest}>
      <Icon
        name={icon}
        color={color}
        fontSize={`${markerSize}px`}
        style={{
          position: 'relative',
          top: '50%',
          left: '50%',
          transform: 'translate(-50%, -50%)',
        }}
      />
    </NanoMapMarker>
  );
};

NanoMap.MarkerIcon = NanoMapMarkerIcon;

type ZoomerProps = Partial<{
  zoom: number;
  onZoom: (e: Event, n: number) => void;
  onReset: (e: Event) => void;
}>;

const NanoMapZoomer = (props: ZoomerProps) => {
  return (
    <Box className="NanoMap__zoomer">
      <LabeledList>
        <LabeledList.Item label="Zoom" labelStyle={{ verticalAlign: 'middle' }}>
          <Flex direction="row">
            <Slider
              minValue={1}
              maxValue={8}
              stepPixelSize={20}
              width={15.5}
              format={(v) => v + 'x'}
              value={props.zoom}
              onDrag={(e, v) => props.onZoom(e, v)}
            />
            <Button
              ml="0.5em"
              icon="sync"
              tooltip="Reset View"
              style={{ float: 'right' }}
              onClick={(e) => props.onReset?.(e)}
            />
          </Flex>
        </LabeledList.Item>
      </LabeledList>
    </Box>
  );
};

NanoMap.Zoomer = NanoMapZoomer;

type ZLevelerProps = {
  onZChange: (n: number) => any;
  zCurrent: number;
  zLevels: number[];
  zNames: string[];
};

const NanoMapZLeveler = (props: ZLevelerProps) => {
  if (props.zLevels.length === 1) {
    return;
  } else {
    return (
      <Box className="NanoMap__zlevel">
        <LabeledList>
          <LabeledList.Item label="Z-level">
            <Dropdown
              width="100%"
              selected={props.zNames[props.zLevels.indexOf(props.zCurrent)]}
              options={props.zNames}
              onSelected={(value) =>
                props.onZChange(props.zLevels[props.zNames.indexOf(value)])
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Box>
    );
  }
};
