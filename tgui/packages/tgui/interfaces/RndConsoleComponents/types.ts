type ResearchLevel = {
  name: string;
  level: number;
  desc: string;
};

type Material = Partial<{
  id: string;
  name: string;
  amount: number;
  is_red: boolean;
}>;

type RndRouteData = Partial<{
  menu: ((n: number) => boolean) | number;
  submenu: ((n: number) => boolean) | number;
}>;

type RndData = Partial<
  {
    disk_type: string;
    linked_destroy: boolean;
    linked_lathe: boolean;
    linked_imprinter: boolean;
    tech_levels: ResearchLevel[];
  } & RndRouteData
>;
