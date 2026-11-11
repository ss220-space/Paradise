export type GalaxyMarkerStyle = {
  shape?: string;
  color?: string;
  fill?: string;
  size?: number;
  width?: number;
  opacity?: number;
  rotation?: number;
  showLabel?: boolean | number;
  labelSize?: number;
  labelColor?: string;
  labelX?: number;
  labelY?: number;
  image?: string;
  imageSize?: number;
};
export type GalaxyGeneration = {
  hazards?: number;
  asteroids?: number;
  emp?: number;
  carp?: number;
  ruins?: number;
};
export type GalaxyStyle = {
  line?: string;
  width?: number;
  opacity?: number;
  fill?: string;
  fillOpacity?: number;
  hatch?: string;
  hatchOpacity?: number;
  hatchSpacing?: number;
};
export type GalaxyFaction = {
  id: string;
  name: string;
  color: string;
  style?: GalaxyStyle;
};
export type GalaxyTerritory = {
  id: string;
  name: string;
  faction: string;
  points: number[][];
  style?: GalaxyStyle;
};
export type GalaxyLink = GalaxyStyle & {
  id: string;
  from: string;
  to: string;
  state: string;
  access?: string;
  color: string;
  waypoints?: number[][];
  distance?: number;
};
export type GalaxyPoi = {
  marker?: GalaxyMarkerStyle | null;
  id: string;
  name: string;
  x: number;
  y: number;
  kind: string;
  color: string;
  description?: string;
};
export type GalaxySector = {
  marker?: GalaxyMarkerStyle | null;
  generation?: GalaxyGeneration | null;
  distances?: Record<string, number>;
  id: string;
  name: string;
  kind: string;
  x: number;
  y: number;
  links: string[];
  signal_links?: string[];
  contacts: number;
  distress: boolean | number;
  unknown?: boolean;
  faction?: string;
  description?: string;
  size?: number;
  cell_span?: number;
};
export type GalaxyMap = {
  revision: number;
  sectors: GalaxySector[];
  center?: string;
  name?: string;
  units?: string;
  factions?: GalaxyFaction[];
  territories?: GalaxyTerritory[];
  links?: GalaxyLink[];
  pois?: GalaxyPoi[];
  transits?: {
    id: string;
    from: string;
    to: string;

    path?: number[][] | null;
    progress: number;
    remaining: number;
    own: boolean | number;
  }[];
};
