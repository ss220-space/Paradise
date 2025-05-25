type Frequency = {
  frequency: number;
  minFrequency: number;
  maxFrequency: number;
};

type Radio = {
  broadcasting: boolean;
} & Frequency;

type Chemical = {
  id: string | number;
  name: string;
  volume: number;
  reagentColor: string;
};

type BotControlsData = {
  locked: boolean;
  noaccess: boolean;
  maintpanel: boolean;
  on: boolean;
  autopatrol: boolean;
  canhack: boolean;
  emagged: boolean;
  remote_disabled: boolean;
  painame: string;
};

type BeakerData = {
  isBeakerLoaded: boolean;
  beakerCurrentVolume: number;
  beakerMaxVolume: number;
  beakerContents: Chemical[];
};

type Occupant = {
  name: string;
  health: number;
  maxHealth: number;
  bodyTemperature: number;
  stat: number;
};

type LoginState = {
  logged_in: boolean;
};

type DetailsPaneData = {
  canapprove: boolean;
  requests: CargoRequest[];
  orders: CargoRequest[];
};

type CargoRequest = {
  ordernum: number;
  supply_type: string;
  orderedby: string;
  comment: string;
  pack_techs: string;
};

type CataloguePaneData = {
  categories: Category[];
  supply_packs: SupplyPack[];
};

type Category = {
  name: string;
  category: string;
};

type SupplyPack = { name: string; cat: string };

type SearchTextProps = Partial<{
  searchText: string;
  setSearchText: React.Dispatch<React.SetStateAction<string>>;
}>;

type SortOrderProps = Partial<{
  sortOrder: boolean;
  setSortOrder: React.Dispatch<React.SetStateAction<boolean>>;
}>;

type SordIdProps = Partial<{
  sortId: string;
  setSortId: React.Dispatch<React.SetStateAction<string>>;
}>;

type TabIndexProps = Partial<{
  tabIndex: number;
  setTabIndex: React.Dispatch<React.SetStateAction<number>>;
}>;

type SortTypeProps = Partial<{
  sortType: string;
  setSortType: React.Dispatch<React.SetStateAction<string>>;
}>;
