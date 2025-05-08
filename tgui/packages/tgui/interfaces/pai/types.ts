type PaiData<T> = {
  app_data: T;
};

type Reagent = {
  id: string;
  title: string;
  overdosed: boolean;
  volume: number;
};

type Scan = { holder: boolean; dead: boolean; health: number };
