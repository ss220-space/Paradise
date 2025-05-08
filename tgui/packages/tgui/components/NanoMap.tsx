import {
  useState,
  useRef,
  useEffect,
  ReactNode,
  MouseEventHandler,
} from 'react';
import { Box, Icon, Tooltip, Dropdown } from '.';
import { useBackend } from '../backend';
import { LabeledList } from './LabeledList';
import { Slider } from './Slider';
import { resolveAsset } from '../assets';
import { computeBoxProps } from 'common/ui';

const pauseEvent = (e: MouseEvent) => {
  if (e.stopPropagation) {
    e.stopPropagation();
  }
  if (e.preventDefault) {
    e.preventDefault();
  }
  e.cancelBubble = true;
  e.returnValue = false;
  return false;
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

  const [offsetX, setOffsetX] = useState(128);
  const [offsetY, setOffsetY] = useState(48);
  const [zCurrent, setZCurrent] = useState<number>(props.zCurrent);
  const [zoom, setZoom] = useState(1);
  const [dragging, setDragging] = useState(false);
  const origin = useRef({ x: null, y: null });

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (origin.current.x === null || origin.current.y === null) return;

      const deltaX = e.screenX - origin.current.x;
      const deltaY = e.screenY - origin.current.y;

      if (dragging) {
        setOffsetX((prev) => prev + deltaX);
        setOffsetY((prev) => prev + deltaY);
        origin.current.x = e.screenX;
        origin.current.y = e.screenY;
      } else {
        setDragging(true);
      }

      pauseEvent(e);
    };

    const handleMouseUp = (e: MouseEvent) => {
      setDragging(false);
      origin.current = { x: null, y: null };
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
      pauseEvent(e);
    };

    // Cleanup on unmount
    return () => {
      document.removeEventListener('mousemove', handleMouseMove);
      document.removeEventListener('mouseup', handleMouseUp);
    };
  }, [dragging]);

  const handleDragStart = (e: React.MouseEvent<HTMLDivElement>) => {
    origin.current = { x: e.screenX, y: e.screenY };
    document.addEventListener('mousemove', handleMouseMove);
    document.addEventListener('mouseup', handleMouseUp);
    pauseEvent(e.nativeEvent);
  };

  const handleMouseMove = (e: MouseEvent) => {
    const deltaX = e.screenX - origin.current.x;
    const deltaY = e.screenY - origin.current.y;

    if (dragging) {
      setOffsetX((prev) => prev + deltaX);
      setOffsetY((prev) => prev + deltaY);
      origin.current.x = e.screenX;
      origin.current.y = e.screenY;
    } else {
      setDragging(true);
    }

    pauseEvent(e);
  };

  const handleMouseUp = (e: MouseEvent) => {
    setDragging(false);
    origin.current = { x: null, y: null };
    document.removeEventListener('mousemove', handleMouseMove);
    document.removeEventListener('mouseup', handleMouseUp);
    pauseEvent(e);
  };

  const handleZoom = (_e: Event, value: number) => {
    setZoom((prevZoom) => {
      const newZoom = Math.min(Math.max(value, 1), 8);
      const zoomDiff = (newZoom - prevZoom) * 1.5;
      setOffsetX((prev) => prev - 262 * zoomDiff);
      setOffsetY((prev) => prev - 256 * zoomDiff);
      props.onZoom?.(_e, newZoom);
      return newZoom;
    });
  };

  const handleZChange = (value: number) => {
    props.setZCurrent(value);
    setZCurrent(value);
  };

  const mapUrl =
    config.map + '_nanomap_z' + (props.zLevels.indexOf(zCurrent) + 1) + '.png';

  const mapSize = 510 * zoom + 'px';

  const newStyle = {
    width: mapSize,
    height: mapSize,
    marginTop: offsetY + 'px',
    marginLeft: offsetX + 'px',
    overflow: 'hidden',
    position: 'relative',
    backgroundSize: 'cover',
    backgroundRepeat: 'no-repeat',
    textAlign: 'center',
    cursor: dragging ? 'move' : 'auto',
  };

  const mapStyle = {
    width: '100%',
    height: '100%',
    position: 'absolute',
    top: '50%',
    left: '50%',
    transform: 'translate(-50%, -50%)',
    '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
    imageRendering: 'pixelated',
  };

  return (
    <Box className="NanoMap__container">
      <Box onMouseDown={handleDragStart} {...computeBoxProps(newStyle)}>
        <img src={resolveAsset(mapUrl)} {...computeBoxProps(mapStyle)} />
        <Box>{props.children}</Box>
      </Box>
      <NanoMapZoomer zoom={zoom} onZoom={handleZoom} {...props} />
      <NanoMapZLeveler
        zCurrent={zCurrent}
        onZChange={handleZChange}
        {...props}
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
            onDragInput={(e, v) => props.onZoom(e, v)}
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
