import { Key } from 'react';
import { useBackend } from '../../backend';
import { LabeledList, Box } from '../../components';

type JanitorInfo = {
  user_loc: Location;
  mops: Mop[];
  buckets: Bucket[];
  cleanbots: Cleanbot[];
  carts: Cart[];
  keys: Location[];
  janicarts: Location[];
};

type JanitorData = { janitor: JanitorInfo };

type Mop = { status: string } & Location;

type Cleanbot = Mop;

type Cart = Bucket;

type Bucket = { volume: number; max_volume: number } & Location;
type Location = {
  x: number;
  y: number;
  dir: string;
} & Key;

export const pda_janitor = (props: unknown) => {
  const { data } = useBackend<JanitorData>();
  const { janitor } = data;

  const { user_loc, mops, buckets, cleanbots, carts, keys, janicarts } =
    janitor;

  return (
    <LabeledList>
      <LabeledList.Item label="Текущая локация">
        {user_loc.x},{user_loc.y}
      </LabeledList.Item>
      {mops && (
        <LabeledList.Item label="Локации швабр">
          {mops.map((m) => (
            <Box key={m}>
              {m.x},{m.y} ({m.dir}) - {m.status}
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {buckets && (
        <LabeledList.Item label="Локации вёдер">
          {buckets.map((b) => (
            <Box key={b}>
              {b.x},{b.y} ({b.dir}) - [{b.volume}/{b.max_volume}]
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {cleanbots && (
        <LabeledList.Item label="Локации уборочных дронов">
          {cleanbots.map((c) => (
            <Box key={c}>
              {c.x},{c.y} ({c.dir}) - {c.status}
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {carts && (
        <LabeledList.Item label="Локации тележек">
          {carts.map((c) => (
            <Box key={c}>
              {c.x},{c.y} ({c.dir}) - [{c.volume}/{c.max_volume}]
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {keys && (
        <LabeledList.Item label="Локации ключей уборочных машин">
          {keys.map((c) => (
            <Box key={c}>
              {c.x},{c.y} ({c.dir})
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {janicarts && (
        <LabeledList.Item label="Локации уборочных машин">
          {janicarts.map((c) => (
            <Box key={c}>
              {c.x},{c.y} ({c.dir})
            </Box>
          ))}
        </LabeledList.Item>
      )}
    </LabeledList>
  );
};
