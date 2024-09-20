import { Component } from 'inferno';
import { Box, Icon, Tooltip, Dropdown } from '.';
import { useBackend } from '../backend';
import { LabeledList } from './LabeledList';
import { Slider } from './Slider';
import { resolveAsset } from '../assets';

const pauseEvent = (e) => {
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

export class NanoMap extends Component {
  constructor(props) {
    super(props);

    // Auto center based on window size
    const Xcenter = window.innerWidth / 2 - 256;
    const Ycenter = window.innerHeight / 2 - 256;

    this.state = {
      offsetX: 128,
      offsetY: 48,
      transform: 'none',
      dragging: false,
      originX: null,
      originY: null,
      zoom: 1,
    };

    // Dragging
    this.handleDragStart = (e) => {
      this.ref = e.target;
      this.setState({
        dragging: false,
        originX: e.screenX,
        originY: e.screenY,
      });
      document.addEventListener('mousemove', this.handleDragMove);
      document.addEventListener('mouseup', this.handleDragEnd);
      pauseEvent(e);
    };

    this.handleDragMove = (e) => {
      this.setState((prevState) => {
        const state = { ...prevState };
        const newOffsetX = e.screenX - state.originX;
        const newOffsetY = e.screenY - state.originY;
        if (prevState.dragging) {
          state.offsetX += newOffsetX;
          state.offsetY += newOffsetY;
          state.originX = e.screenX;
          state.originY = e.screenY;
        } else {
          state.dragging = true;
        }
        return state;
      });
      pauseEvent(e);
    };

    this.handleDragEnd = (e) => {
      this.setState({
        dragging: false,
        originX: null,
        originY: null,
      });
      document.removeEventListener('mousemove', this.handleDragMove);
      document.removeEventListener('mouseup', this.handleDragEnd);
      pauseEvent(e);
    };

    this.handleZoom = (_e, value) => {
      this.setState((state) => {
        const newZoom = Math.min(Math.max(value, 1), 8);
        let zoomDiff = (newZoom - state.zoom) * 1.5;
        state.zoom = newZoom;
        state.offsetX = state.offsetX - 262 * zoomDiff;
        state.offsetY = state.offsetY - 256 * zoomDiff;
        if (props.onZoom) {
          props.onZoom(state.zoom);
        }
        return state;
      });
    };

    this.handleZChange = (value) => {
      props.setZCurrent(value);
    };
  }

  render() {
    const { config } = useBackend(this.context);
    const { dragging, offsetX, offsetY, zoom = 1 } = this.state;
    const { children } = this.props;

    const mapUrl =
      config.map +
      '_nanomap_z' +
      (this.props.zLevels.indexOf(this.props.z_current) + 1) +
      '.png';
    const mapSize = 510 * zoom + 'px';
    const newStyle = {
      width: mapSize,
      height: mapSize,
      'margin-top': offsetY + 'px',
      'margin-left': offsetX + 'px',
      'overflow': 'hidden',
      'position': 'relative',
      'background-size': 'cover',
      'background-repeat': 'no-repeat',
      'text-align': 'center',
      'cursor': dragging ? 'move' : 'auto',
    };
    const mapStyle = {
      width: '100%',
      height: '100%',
      position: 'absolute',
      top: '50%',
      left: '50%',
      transform: 'translate(-50%, -50%)',
      '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
      'image-rendering': 'pixelated',
    };

    return (
      <Box className="NanoMap__container">
        <Box style={newStyle} onMouseDown={this.handleDragStart}>
          <img src={resolveAsset(mapUrl)} style={mapStyle} />
          <Box>{children}</Box>
        </Box>
        <NanoMapZoomer zoom={zoom} onZoom={this.handleZoom} />
        <NanoMapZLeveler
          z_current={this.props.z_current}
          z_levels={this.props.zLevels}
          z_names={this.props.zNames}
          onZChange={this.handleZChange}
        />
      </Box>
    );
  }
}

const NanoMapMarker = (props, context) => {
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

const NanoMapZoomer = (props, context) => {
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

const NanoMapZLeveler = (props) => {
  if (props.z_levels.length === 1) {
    return;
  } else {
    return (
      <Box className="NanoMap__zlevel">
        <LabeledList>
          <LabeledList.Item label="Z-level">
            <Dropdown
              width="100%"
              selected={props.z_names[props.z_levels.indexOf(props.z_current)]}
              options={props.z_names}
              onSelected={(value) =>
                props.onZChange(props.z_levels[props.z_names.indexOf(value)])
              }
            />
          </LabeledList.Item>
        </LabeledList>
      </Box>
    );
  }
};
