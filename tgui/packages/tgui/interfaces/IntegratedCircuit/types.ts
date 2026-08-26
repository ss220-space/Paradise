import { CSSProperties, HTMLAttributes, MouseEvent } from 'react';

export interface LocationMap {
  [key: string]: { x: number; y: number; color?: string };
}

export interface PortType {
  name: string;
  color: string;
  datatype: string;
  ref: string;
  type: string;
  connected_to?: string[];
  current_data?: string;
  is_output?: boolean;
  datatype_data?: {
    composite_types?: string[];
  };
}

export interface ComponentType {
  name: string;
  x: number;
  y: number;
  index: number;
  category?: string;
  removable?: boolean;
  input_ports: PortType[];
  output_ports: PortType[];
  ui_alerts?: Record<string, string>;
  ui_buttons?: Record<string, string>;
  locations?: LocationMap;
}

export interface Variables {
  name: string;
  datatype: string;
  color: string;
  is_list?: boolean;
}

export interface IntegratedCircuitState {
  locations: LocationMap;
  selectedPort: {
    index: number;
    component_id: number;
    is_output: boolean;
    ref: string;
  } | null;
  mouseX: number | null;
  mouseY: number | null;
  zoom: number;
  backgroundX: number;
  backgroundY: number;
  variableMenuOpen: boolean;
  componentMenuOpen: boolean;
  draggingComponent?: any;
  draggingComponentPos?: { x: number; y: number };
  draggingOffsetX?: number;
  draggingOffsetY?: number;
  draggingVariable?: Variables | null;
  variableIsSetter?: boolean | null;
}

export interface IntegratedCircuitData {
  components: ComponentType[];
  display_name: string;
  examined_name: string;
  examined_desc: string;
  examined_notices: string[];
  examined_rel_x: number;
  examined_rel_y: number;
  screen_x: number;
  screen_y: number;
  grid_mode: boolean;
  is_admin: boolean;
  variables: Variables[];
  global_basic_types: string[];
  stored_designs: Record<string, string>;
}

export interface PortProps {
  port: PortType;
  portIndex?: number;
  componentId?: number;
  isOutput?: boolean;
  act?: (...args: any[]) => void;
  iconRef?: any;
  onPortMouseDown?: (
    portIndex: number,
    componentId: number,
    port: PortType,
    isOutput: boolean,
    event: MouseEvent
  ) => void;
  onPortMouseUp?: (
    portIndex: number,
    componentId: number,
    port: PortType,
    isOutput: boolean,
    event: MouseEvent
  ) => void;
  onPortRightClick?: (
    portIndex: number,
    componentId: number,
    port: PortType,
    isOutput: boolean,
    event: MouseEvent
  ) => void;
  onPortUpdated?: (port: PortType, iconRef: any) => void;
  onPortLoaded?: (port: PortType, iconRef: any) => void;
}

export interface ObjectComponentProps extends HTMLAttributes<HTMLDivElement> {
  act?: (action: string, payload: any) => void;
  gridMode?: boolean;
  zoom?: number;
  onPortMouseDown?: (
    portIndex: number,
    componentId: number,
    port: PortType,
    isOutput: boolean,
    event: MouseEvent
  ) => void;
  onPortMouseUp?: (
    portIndex: number,
    componentId: number,
    port: PortType,
    isOutput: boolean,
    event: MouseEvent
  ) => void;
  onPortRightClick?: (
    portIndex: number,
    componentId: number,
    port: PortType,
    isOutput: boolean,
    event: MouseEvent
  ) => void;
  onPortUpdated?: (port: PortType, iconRef: any) => void;
  onPortLoaded?: (port: PortType, iconRef: any) => void;
}

export interface ObjectComponentState {
  isDragging: boolean;
  dragPos: { x: number; y: number } | null;
  startPos: { x: number; y: number } | null;
  lastMousePos: { x: number; y: number } | null;
}

export interface DisplayComponentProps {
  component: ComponentType | any;
  top?: string;
  left?: string;
  fixedSize?: boolean;
  style?: CSSProperties;
  onDisplayUpdated?: (el: HTMLDivElement) => void;
  onDisplayLoaded?: (el: HTMLDivElement) => void;
}

export interface ComponentMenuProps {
  components?: string[];
  showAll?: boolean;
  onMouseDownComponent: (event: MouseEvent, component: any) => void;
  onClose: (e: MouseEvent) => void;
}

export interface ComponentMenuState {
  selectedTab: string;
  currentLimit: number;
  currentSearch: string;
  componentData?: any[];
}

export interface VariableMenuProps {
  variables: Variables[];
  types: string[];
  onRemoveVariable: (name: string) => void;
  onAddVariable: (
    variable_name: string,
    variable_type: string,
    variable_list_type: number,
    event: MouseEvent
  ) => void;
  handleMouseDownSetter;
  handleMouseDownGetter;
  onClose: (e: MouseEvent) => void;
}

export interface VariableMenuState {
  variable_name?: string;
  variable_type?: string;
  variable_list_type?: number;
}

export interface CircuitModuleData {
  input_ports: PortType[];
  output_ports: PortType[];
  global_port_types: string[];
}
