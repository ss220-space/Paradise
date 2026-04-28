import { useMemo, useState } from 'react';
import { createSearch } from 'common/string';
import { useBackend } from '../backend';
import { Box, Icon, Input, LabeledList, Section, Table } from '../components';
import { Window } from '../layouts';

type GeoIPRow = {
  ckey: string;
  name: string;
  ping: number;
  avg_ping: number;
  url: string;
  ip: string;
  country: string;
  countryCode: string;
  region: string;
  regionName: string;
  city: string;
  timezone: string;
  isp: string;
  mobile: string;
  proxy: string;
  status: string;
  player_html: string;
};

type GeoIPData = {
  clients: GeoIPRow[];
  target_ckey: string | null;
};

const DASH = '—';

// MARK: helpers

const clampByte = (n: number) => Math.max(0, Math.min(255, n | 0));

const pingColor = (ping: number) => {
  const r = clampByte(ping);
  return `rgb(${r}, ${255 - r}, 0)`;
};

const stripTags = (value: string) =>
  (value || '').replace(/<[^>]+>/g, '').trim();

const formatPair = (primary: string, secondary: string) => {
  if (!primary) return '';
  return secondary ? `${primary} (${secondary})` : primary;
};

// MARK: presentational primitives

const Dash = () => (
  <Box color="label" as="span">
    {DASH}
  </Box>
);

const TextOrDash = ({ value }: { value: string | null | undefined }) =>
  value ? <Box as="span">{value}</Box> : <Dash />;

const PingValue = ({ ping }: { ping: number }) => (
  <>
    <Box inline color={pingColor(ping)} mr={1}>
      <Icon name="circle" />
    </Box>
    <Box inline bold>
      {ping}
    </Box>
  </>
);

const ProxyBadge = ({ value }: { value: string }) => {
  const kind = stripTags(value).toLowerCase();
  if (kind === 'true') return <Box color="bad">proxy</Box>;
  if (kind === 'false') return <Box color="good">clean</Box>;
  if (kind === 'whitelisted') return <Box color="orange">whitelisted</Box>;
  return <Dash />;
};

const MobileBadge = ({ value }: { value: string }) => {
  if (value === 'true') return <Box color="average">mobile</Box>;
  if (value === 'false') return <Box color="label">no</Box>;
  return <Dash />;
};

const STATUS_COLOR: Record<string, string> = {
  updated: 'good',
  admin: 'blue',
  pending: 'average',
  local: 'label',
  'no address': 'label',
};

const StatusBadge = ({ value }: { value: string | null }) => {
  if (!value) return <Dash />;
  return <Box color={STATUS_COLOR[value] ?? 'bad'}>{value}</Box>;
};

// MARK: focused view

const FocusedView = ({ row }: { row: GeoIPRow }) => (
  <Section
    title={
      row.name && row.name !== row.ckey ? `${row.ckey} (${row.name})` : row.ckey
    }
  >
    <LabeledList>
      <LabeledList.Item label="IP">
        <TextOrDash value={row.ip} />
      </LabeledList.Item>
      <LabeledList.Item label="Country">
        <TextOrDash value={formatPair(row.country, row.countryCode)} />
      </LabeledList.Item>
      <LabeledList.Item label="Region">
        <TextOrDash value={formatPair(row.regionName, row.region)} />
      </LabeledList.Item>
      <LabeledList.Item label="City">
        <TextOrDash value={row.city} />
      </LabeledList.Item>
      <LabeledList.Item label="Timezone">
        <TextOrDash value={row.timezone} />
      </LabeledList.Item>
      <LabeledList.Item label="ISP">
        <TextOrDash value={row.isp} />
      </LabeledList.Item>
      <LabeledList.Item label="Mobile">
        <MobileBadge value={row.mobile} />
      </LabeledList.Item>
      <LabeledList.Item label="Proxy">
        <ProxyBadge value={row.proxy} />
      </LabeledList.Item>
      <LabeledList.Item label="Ping">
        <PingValue ping={row.ping} />
      </LabeledList.Item>
      <LabeledList.Item label="Avg ping">
        <Box bold>{row.avg_ping}</Box>
      </LabeledList.Item>
      <LabeledList.Item label="Status">
        <StatusBadge value={row.status} />
      </LabeledList.Item>
      <LabeledList.Item label="URL">
        <TextOrDash value={row.url} />
      </LabeledList.Item>
    </LabeledList>
  </Section>
);

// MARK: full list view

const SEARCH_KEYS: (keyof GeoIPRow)[] = [
  'ckey',
  'name',
  'ip',
  'country',
  'countryCode',
  'region',
  'regionName',
  'city',
  'isp',
  'url',
];

const searchHaystack = (row: GeoIPRow) =>
  SEARCH_KEYS.map((key) => row[key])
    .filter(Boolean)
    .join('|');

const PlayerCell = ({ row }: { row: GeoIPRow }) => (
  <>
    <Box dangerouslySetInnerHTML={{ __html: row.player_html }} />
    {!!row.url && (
      <Box color="label" fontSize="0.85em" mt={0.25}>
        {row.url}
      </Box>
    )}
  </>
);

const LocationCell = ({ row }: { row: GeoIPRow }) => {
  if (!row.country) return <Dash />;
  const subline = [row.city, row.regionName].filter(Boolean).join(', ');
  return (
    <>
      <Box>
        {row.country}
        {row.countryCode && (
          <Box inline color="label">
            {' '}
            ({row.countryCode})
          </Box>
        )}
      </Box>
      {!!subline && (
        <Box color="label" fontSize="0.85em">
          {subline}
        </Box>
      )}
    </>
  );
};

const COLUMNS: { label: string; collapsing?: boolean }[] = [
  { label: 'Player' },
  { label: 'Ping', collapsing: true },
  { label: 'Avg', collapsing: true },
  { label: 'IP' },
  { label: 'Location' },
  { label: 'ISP' },
  { label: 'Mobile', collapsing: true },
  { label: 'Proxy', collapsing: true },
  { label: 'Status', collapsing: true },
];

const rowStyle = (index: number) => ({
  borderTop: index === 0 ? 'none' : '1px solid hsla(0, 0%, 100%, 0.08)',
  backgroundColor: index % 2 ? 'hsla(0, 0%, 100%, 0.02)' : 'transparent',
});

const FullListView = ({ clients }: { clients: GeoIPRow[] }) => {
  const [search, setSearch] = useState('');
  const sorted = useMemo(
    () => [...clients].sort((a, b) => a.ckey.localeCompare(b.ckey)),
    [clients]
  );
  const visible = useMemo(
    () => sorted.filter(createSearch(search, searchHaystack)),
    [sorted, search]
  );

  return (
    <Section
      title={`Clients: ${visible.length} / ${clients.length}`}
      buttons={
        <Input
          width="22em"
          placeholder="Search ckey, IP, location, ISP, URL..."
          value={search}
          onChange={setSearch}
        />
      }
    >
      <Table>
        <Table.Row header>
          {COLUMNS.map((col) => (
            <Table.Cell key={col.label} collapsing={col.collapsing}>
              {col.label}
            </Table.Cell>
          ))}
        </Table.Row>
        {visible.map((row, index) => (
          <Table.Row key={row.ckey} style={rowStyle(index)}>
            <Table.Cell>
              <PlayerCell row={row} />
            </Table.Cell>
            <Table.Cell collapsing>
              <PingValue ping={row.ping} />
            </Table.Cell>
            <Table.Cell collapsing bold>
              {row.avg_ping}
            </Table.Cell>
            <Table.Cell>
              <TextOrDash value={row.ip} />
            </Table.Cell>
            <Table.Cell>
              <LocationCell row={row} />
            </Table.Cell>
            <Table.Cell>
              <TextOrDash value={row.isp} />
            </Table.Cell>
            <Table.Cell collapsing>
              <MobileBadge value={row.mobile} />
            </Table.Cell>
            <Table.Cell collapsing>
              <ProxyBadge value={row.proxy} />
            </Table.Cell>
            <Table.Cell collapsing>
              <StatusBadge value={row.status} />
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

// MARK: root

export const AdminGeoIP = () => {
  const { data } = useBackend<GeoIPData>();
  const clients = data.clients || [];
  const focused = Boolean(data.target_ckey);
  const focusedRow = focused
    ? clients.find((row) => row.ckey === data.target_ckey)
    : null;

  return (
    <Window
      theme="admin"
      width={focused ? 460 : 920}
      height={focused ? 460 : 540}
      title={focused ? `GeoIP: ${data.target_ckey}` : 'GeoIP Report'}
    >
      <Window.Content scrollable>
        {focused ? (
          focusedRow ? (
            <FocusedView row={focusedRow} />
          ) : (
            <Section>
              <Box color="label">
                Client {data.target_ckey} is not connected.
              </Box>
            </Section>
          )
        ) : (
          <FullListView clients={clients} />
        )}
      </Window.Content>
    </Window>
  );
};
