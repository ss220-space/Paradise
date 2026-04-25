import { useState } from 'react';
import { createSearch } from 'common/string';
import { useBackend } from '../backend';
import {
  Box,
  Icon,
  Input,
  LabeledList,
  Section,
  Stack,
  Table,
} from '../components';
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

// MARK: helpers

const clampByte = (value: number) => Math.max(0, Math.min(255, value | 0));

const pingColor = (ping: number) => {
  const red = clampByte(ping);
  const green = 255 - red;
  return `rgb(${red}, ${green}, 0)`;
};

const stripTags = (value: string) =>
  (value || '').replace(/<[^>]+>/g, '').trim();

type ProxyKind = 'true' | 'false' | 'whitelisted' | 'unknown';

const proxyKind = (raw: string): ProxyKind => {
  const text = stripTags(raw).toLowerCase();
  if (text === 'true') return 'true';
  if (text === 'false') return 'false';
  if (text === 'whitelisted') return 'whitelisted';
  return 'unknown';
};

const ProxyBadge = ({ value }: { value: string }) => {
  const kind = proxyKind(value);
  if (kind === 'unknown') return <Box color="label">—</Box>;
  const map = {
    true: { color: 'bad', label: 'proxy' },
    false: { color: 'good', label: 'clean' },
    whitelisted: { color: 'orange', label: 'whitelisted' },
  } as const;
  const meta = map[kind];
  return <Box color={meta.color}>{meta.label}</Box>;
};

const MobileBadge = ({ value }: { value: string }) => {
  if (value === 'true') return <Box color="average">mobile</Box>;
  if (value === 'false') return <Box color="label">no</Box>;
  return <Box color="label">—</Box>;
};

const STATUS_COLOR: Record<string, string> = {
  updated: 'good',
  admin: 'blue',
  pending: 'average',
  local: 'label',
  'no address': 'label',
};

const statusColor = (value: string) =>
  STATUS_COLOR[value] ?? (value.startsWith('api fail') ? 'bad' : 'bad');

const StatusBadge = ({ value }: { value: string | null }) => {
  if (!value) return <Box color="label">—</Box>;
  return <Box color={statusColor(value)}>{value}</Box>;
};

// MARK: focused view

const FocusedView = ({ row }: { row: GeoIPRow }) => (
  <Section
    title={
      <Stack align="center">
        <Stack.Item bold>{row.ckey}</Stack.Item>
        {row.name && row.name !== row.ckey && (
          <Stack.Item color="label">({row.name})</Stack.Item>
        )}
      </Stack>
    }
  >
    <LabeledList>
      <LabeledList.Item label="IP">{row.ip || '—'}</LabeledList.Item>
      <LabeledList.Item label="Country">
        {row.country
          ? `${row.country}${row.countryCode ? ` (${row.countryCode})` : ''}`
          : '—'}
      </LabeledList.Item>
      <LabeledList.Item label="Region">
        {row.regionName
          ? `${row.regionName}${row.region ? ` (${row.region})` : ''}`
          : '—'}
      </LabeledList.Item>
      <LabeledList.Item label="City">{row.city || '—'}</LabeledList.Item>
      <LabeledList.Item label="Timezone">
        {row.timezone || '—'}
      </LabeledList.Item>
      <LabeledList.Item label="ISP">{row.isp || '—'}</LabeledList.Item>
      <LabeledList.Item label="Mobile">
        <MobileBadge value={row.mobile} />
      </LabeledList.Item>
      <LabeledList.Item label="Proxy">
        <ProxyBadge value={row.proxy} />
      </LabeledList.Item>
      <LabeledList.Item label="Ping">
        <Box inline color={pingColor(row.ping)} bold mr={1}>
          <Icon name="circle" />
        </Box>
        {row.ping} (avg {row.avg_ping})
      </LabeledList.Item>
      <LabeledList.Item label="Status">
        <StatusBadge value={row.status} />
      </LabeledList.Item>
      {row.url && <LabeledList.Item label="URL">{row.url}</LabeledList.Item>}
    </LabeledList>
  </Section>
);

// MARK: full list view

const searchHaystack = (row: GeoIPRow) =>
  [
    row.ckey,
    row.name,
    row.ip,
    row.country,
    row.countryCode,
    row.region,
    row.regionName,
    row.city,
    row.isp,
  ]
    .filter(Boolean)
    .join('|');

const rowSeparatorStyle = (index: number) => ({
  borderTop: index === 0 ? 'none' : '1px solid hsla(0, 0%, 100%, 0.10)',
  backgroundColor: index % 2 ? 'hsla(0, 0%, 100%, 0.02)' : 'transparent',
});

const FullListView = ({ clients }: { clients: GeoIPRow[] }) => {
  const [searchText, setSearchText] = useState('');
  const visible = clients.filter(createSearch(searchText, searchHaystack));

  return (
    <Section
      title={`Clients: ${visible.length} / ${clients.length}`}
      buttons={
        <Input
          width="20em"
          placeholder="Search ckey, IP, location, ISP..."
          value={searchText}
          onChange={setSearchText}
        />
      }
    >
      <Table>
        <Table.Row header>
          <Table.Cell>Player</Table.Cell>
          <Table.Cell collapsing>Ping</Table.Cell>
          <Table.Cell collapsing>Avg</Table.Cell>
          <Table.Cell>IP</Table.Cell>
          <Table.Cell>Location</Table.Cell>
          <Table.Cell>ISP</Table.Cell>
          <Table.Cell collapsing>Mobile</Table.Cell>
          <Table.Cell collapsing>Proxy</Table.Cell>
          <Table.Cell collapsing>Status</Table.Cell>
        </Table.Row>
        {visible.map((row, index) => (
          <Table.Row key={row.ckey} style={rowSeparatorStyle(index)}>
            <Table.Cell>
              <Box dangerouslySetInnerHTML={{ __html: row.player_html }} />
            </Table.Cell>
            <Table.Cell collapsing>
              <Box inline color={pingColor(row.ping)} mr={1}>
                <Icon name="circle" />
              </Box>
              <Box inline bold>
                {row.ping}
              </Box>
            </Table.Cell>
            <Table.Cell collapsing bold>
              {row.avg_ping}
            </Table.Cell>
            <Table.Cell>{row.ip || '—'}</Table.Cell>
            <Table.Cell>
              {row.country ? (
                <Box>
                  <Box>
                    {row.country}
                    {row.countryCode && (
                      <Box inline color="label">
                        {' '}
                        ({row.countryCode})
                      </Box>
                    )}
                  </Box>
                  {(row.city || row.regionName) && (
                    <Box color="label" fontSize="0.9em">
                      {[row.city, row.regionName].filter(Boolean).join(', ')}
                    </Box>
                  )}
                </Box>
              ) : (
                '—'
              )}
            </Table.Cell>
            <Table.Cell>{row.isp || '—'}</Table.Cell>
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
      width={focused ? 460 : 890}
      height={focused ? 430 : 530}
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
