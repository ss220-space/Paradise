import {
  type MouseEvent as ReactMouseEvent,
  useCallback,
  useEffect,
  useRef,
  useState,
} from 'react';
import { Icon } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Pane } from '../layouts';

type MapMarker = {
  frames: string[];
  x: number;
  y: number;
  w: number;
  h: number;
  duration: number;
  is_self: boolean;
};

type MapImplantData = {
  map: string | null;
  markers: MapMarker[];
  size: number;
  z: number;
};

type DragState = {
  position: [number, number];
  pointer: [number, number];
};

const MAP_SCALE = 3;

const MarkerIcon = (props: { marker: MapMarker }) => {
  const { marker } = props;
  const [frame, setFrame] = useState(0);
  const frames = marker.frames || [];

  useEffect(() => {
    if (frames.length <= 1) {
      setFrame(0);
      return;
    }
    const frameDelay = Math.max(
      100,
      (Math.max(marker.duration, 0.1) * 1000) / frames.length,
    );
    const timer = setInterval(() => {
      setFrame((current) => (current + 1) % frames.length);
    }, frameDelay);
    return () => clearInterval(timer);
  }, [frames.length, marker.duration]);

  if (!frames.length) {
    return null;
  }

  return (
    <img
      className="minimap-marker"
      src={`data:image/png;base64,${frames[frame % frames.length]}`}
      draggable={false}
      style={{
        left: marker.x,
        bottom: marker.y,
        width: marker.w,
        height: marker.h,
        zIndex: marker.is_self ? 2 : 1,
      }}
    />
  );
};

export const MapImplant = () => {
  const { act, data } = useBackend<MapImplantData>();
  const dragState = useRef<DragState | null>(null);

  const movePane = useCallback((event: MouseEvent) => {
    const drag = dragState.current;
    if (!drag) {
      return;
    }
    event.preventDefault();
    const pixelRatio = window.devicePixelRatio || 1;
    const nextX = Math.round(
      drag.position[0] + (event.screenX - drag.pointer[0]) * pixelRatio,
    );
    const nextY = Math.round(
      drag.position[1] + (event.screenY - drag.pointer[1]) * pixelRatio,
    );
    Byond.winset(Byond.windowId, {
      pos: `${nextX},${nextY}`,
    });
  }, []);

  const endDrag = useCallback(() => {
    dragState.current = null;
    document.removeEventListener('mousemove', movePane);
    document.removeEventListener('mouseup', endDrag);
  }, [movePane]);

  useEffect(() => {
    return () => {
      document.removeEventListener('mousemove', movePane);
      document.removeEventListener('mouseup', endDrag);
    };
  }, [movePane, endDrag]);

  const startDrag = async (event: ReactMouseEvent<HTMLDivElement>) => {
    if (
      event.button !== 0 ||
      (event.target as HTMLElement).closest('button')
    ) {
      return;
    }
    event.preventDefault();
    const pointer: [number, number] = [event.screenX, event.screenY];
    const position = await Byond.winget(Byond.windowId, 'pos');
    dragState.current = {
      position: [position.x, position.y],
      pointer,
    };
    document.addEventListener('mousemove', movePane);
    document.addEventListener('mouseup', endDrag);
  };

  const mapSize = Math.max(1, data.size || 80);
  const displaySize = mapSize * MAP_SCALE;

  return (
    <Pane className="minimap-pane" theme="minimap">
      <Pane.Content fitted>
        <div className="minimap-shell">
          <div className="minimap-header" onMouseDown={startDrag}>
            <span className="minimap-header__title">MINIMAP</span>
            <span className="minimap-header__z">Z{data.z || '?'}</span>
            <button
              className="minimap-close"
              onClick={() => act('close')}
              title="Скрыть мини-карту"
            >
              <Icon name="times" />
            </button>
          </div>
          <div
            className="minimap-map-frame"
            style={{ width: displaySize, height: displaySize }}
          >
            <div
              className="minimap-map"
              style={{
                width: mapSize,
                height: mapSize,
                transform: `scale(${MAP_SCALE})`,
              }}
            >
              {data.map ? (
                <img
                  className="minimap-base"
                  src={`data:image/png;base64,${data.map}`}
                  draggable={false}
                />
              ) : (
                <div className="minimap-empty">НЕТ ДАННЫХ</div>
              )}
              {data.markers?.map((marker, index) => (
                <MarkerIcon key={index} marker={marker} />
              ))}
            </div>
          </div>
        </div>
      </Pane.Content>
    </Pane>
  );
};
