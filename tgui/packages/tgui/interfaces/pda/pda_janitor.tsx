import { Key } from 'react';
import { useBackend } from '../../backend';
import { LabeledList, Box } from '../../components';

type JanitorInfo = {
  user_loc: Location;
  mops: Mop[];
  buckets: Bucket[];
  cleanbots: Cleanbot[];
  carts: Cart[];
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

  const { user_loc, mops, buckets, cleanbots, carts } = janitor;

  return (
    <LabeledList>
      <LabeledList.Item label="Current Location">
        {user_loc.x},{user_loc.y}
      </LabeledList.Item>
      {mops && (
        <LabeledList.Item label="Mop Locations">
          {mops.map((m) => (
            <Box key={m}>
              {m.x},{m.y} ({m.dir}) - {m.status}
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {buckets && (
        <LabeledList.Item label="Mop Bucket Locations">
          {buckets.map((b) => (
            <Box key={b}>
              {b.x},{b.y} ({b.dir}) - [{b.volume}/{b.max_volume}]
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {cleanbots && (
        <LabeledList.Item label="Cleanbot Locations">
          {cleanbots.map((c) => (
            <Box key={c}>
              {c.x},{c.y} ({c.dir}) - {c.status}
            </Box>
          ))}
        </LabeledList.Item>
      )}
      {carts && (
        <LabeledList.Item label="Janitorial Cart Locations">
          {carts.map((c) => (
            <Box key={c}>
              {c.x},{c.y} ({c.dir}) - [{c.volume}/{c.max_volume}]
            </Box>
          ))}
        </LabeledList.Item>
      )}
    </LabeledList>
  );
};
