import {
  useState,
  useRef,
  useCallback,
  ReactNode,
  MouseEventHandler,
  useEffect,
  CSSProperties,
} from 'react';
import { Box, Icon, Tooltip, Dropdown, Image } from '.';
import { useBackend } from '../backend';
import { LabeledList } from './LabeledList';
import { Slider } from './Slider';
import { resolveAsset } from '../assets';

const pauseEvent = (e: {
  stopPropagation: () => void;
  preventDefault: () => void;
}) => {
  e.stopPropagation();
  e.preventDefault();
};

type Props = {
  onZoom?: (e: Event, n: number) => void;
  zCurrent: number;
  zLevels: number[];
  zNames: string[];
  children: ReactNode;
  setZCurrent?: (z: number) => void;
};

export const NanoMap = (props: Props) => {
  const { config } = useBackend();
  const containerRef = useRef<HTMLDivElement>(null);

  const [position, setPosition] = useState({ x: 128, y: 48 });
  const [zCurrent, setZCurrent] = useState<number>(props.zCurrent);
  const [zoom, setZoom] = useState(1);
  const [dragging, setDragging] = useState(false);
  const dragStartPos = useRef({ x: 0, y: 0 });

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

      pauseEvent(e);
    },
    [dragging]
  );

  const handleMouseUp = useCallback(() => {
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
    setZoom((prevZoom) => {
      const newZoom = Math.min(Math.max(value, 1), 8);
      const zoomDiff = (newZoom - prevZoom) * 1.5;
      setPosition((prev) => {
        return {
          x: prev.x - 262 * zoomDiff,
          y: prev.y - 256 * zoomDiff,
        };
      });
      props.onZoom?.(_e, newZoom);
      return newZoom;
    });
  };

  const handleZChange = (value: number) => {
    props.setZCurrent(value);
    setZCurrent(value);
  };

  const index = props.zLevels.findIndex((level) => +level === zCurrent);
  const mapUrl = config.map + '_nanomap_z' + (index + 1) + '.png';

  const newStyle = {
    width: `${510 * zoom}px`,
    height: `${510 * zoom}px`,
    position: 'relative',
    transform: `translate(${position.x}px, ${position.y}px)`,
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
      <NanoMapZoomer zoom={zoom} onZoom={handleZoom} />
      <NanoMapZLeveler
        zCurrent={zCurrent}
        zNames={props.zNames}
        zLevels={props.zLevels}
        onZChange={handleZChange}
      />
    </Box>
  );
};

type NanoMakerProps = {
  x: number;
  y: number;
  z: number;
  z_current: number;
  zoom: number;
  icon: string;
  tooltip: ReactNode;
  color: string;
  bordered?: boolean;
  onClick: MouseEventHandler<HTMLDivElement>;
};

const NanoMapMarker = (props: NanoMakerProps) => {
  const {
    x,
    y,
    z,
    z_current,
    zoom = 1,
    icon,
    tooltip,
    color,
    bordered,
    onClick,
  } = props;
  if (z_current !== z) {
    return null;
  }
  const rx = x * 2 * zoom - zoom - 3;
  const ry = y * 2 * zoom - zoom - 3;
  return (
    <div>
      <Tooltip content={tooltip}>
        <Box
          position="absolute"
          className={bordered ? 'NanoMap__marker__bordered' : 'NanoMap__marker'}
          lineHeight="0"
          bottom={ry + 'px'}
          left={rx + 'px'}
          onClick={onClick}
        >
          <Icon name={icon} color={color} fontSize="6px" />
        </Box>
      </Tooltip>
    </div>
  );
};

NanoMap.Marker = NanoMapMarker;

type ZoomerProps = {
  zoom: number;
  onZoom?: (e: Event, n: number) => void;
};

const NanoMapZoomer = (props: ZoomerProps) => {
  return (
    <Box className="NanoMap__zoomer">
      <LabeledList>
        <LabeledList.Item label="Zoom">
          <Slider
            minValue={1}
            maxValue={8}
            stepPixelSize={10}
            format={(v) => v + 'x'}
            value={props.zoom}
            onDrag={(e, v) => props.onZoom(e, v)}
          />
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
