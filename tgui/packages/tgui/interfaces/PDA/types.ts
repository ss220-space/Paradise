type Bot = {
  bots: BotData[];
  active: boolean;
  botstatus: BotStatusData;
};

type BotData = { Name: string; uid: string };

type BotStatusData = { mode: number; loca: string };
