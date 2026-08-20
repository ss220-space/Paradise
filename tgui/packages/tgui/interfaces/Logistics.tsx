import { useMemo, useState } from 'react';
import { createSearch } from 'common/string';
import { useBackend } from '../backend';
import {
  Box,
  Button,
  DmIcon,
  Dropdown,
  Icon,
  Input,
  NumberInput,
  ProgressBar,
  Section,
  Stack,
} from '../components';
import { Window } from '../layouts';
import type { DropdownEntry } from '../components/Dropdown';

type Stock = {
  id: string;
  name: string;
  amount: number;
  icon?: string;
  icon_state?: string;
};

type Node = {
  uid: string;
  name: string;
  mode: string;
  self: boolean;
  icon?: string;
  icon_state?: string;
  fill_percent?: number | null;
  stock: Stock[];
  accepted: string[];
};

type BufferItem = {
  id: string;
  name: string;
  amount: number;
  icon?: string;
  icon_state?: string;
};

type DisplayStock = Stock & {
  available: number;
  local: number;
};

type LogisticsData = {
  name: string;
  mode: string;
  connected: boolean;
  allow_export: boolean;
  notify_status: boolean;
  sound_notify: boolean;
  uid: string;
  fill_percent: number | null;
  network_id: number | null;
  local_stock: Stock[];
  net_stock: Stock[];
  nodes: Node[];
};

const stockMap = (items: Stock[] = []) => {
  const result: Record<string, Stock> = {};
  for (const item of items) {
    result[item.id] = item;
  }
  return result;
};

const formatFill = (value: number | null | undefined) =>
  typeof value === 'number' ? `${value}%` : '—';

export const Logistics = (_props: unknown) => {
  const { act, data } = useBackend<LogisticsData>();
  const {
    name,
    mode,
    connected,
    allow_export,
    notify_status,
    sound_notify,
    fill_percent,
    network_id,
    local_stock = [],
    net_stock = [],
    nodes = [],
  } = data;

  const [searchText, setSearchText] = useState('');
  const [localOnly, setLocalOnly] = useState(false);
  const [sourceUid, setSourceUid] = useState('any');
  const [destUid, setDestUid] = useState('');
  const [buffer, setBuffer] = useState<BufferItem[]>([]);

  const sortedNodes = useMemo(() => {
    const copy = [...nodes];
    copy.sort((a, b) => {
      if (a.self === b.self) {
        return a.name.localeCompare(b.name);
      }
      return a.self ? -1 : 1;
    });
    return copy;
  }, [nodes]);

  const localMap = useMemo(() => stockMap(local_stock), [local_stock]);
  const netMap = useMemo(() => stockMap(net_stock), [net_stock]);
  const selectedSource =
    sourceUid === 'any' ? null : sortedNodes.find((n) => n.uid === sourceUid);
  const selectedDest = sortedNodes.find((n) => n.uid === destUid);
  const sourceMap = useMemo(
    () => stockMap(selectedSource?.stock || []),
    [selectedSource]
  );
  const destAccepted = useMemo(() => {
    const set = new Set(selectedDest?.accepted || []);
    return set;
  }, [selectedDest]);

  const displayStock: DisplayStock[] = useMemo(() => {
    const baseItems = localOnly
      ? local_stock
      : sourceUid === 'any'
        ? net_stock
        : selectedSource?.stock || [];
    return baseItems.map((item) => {
      const localItem = localMap[item.id];
      const available =
        sourceUid === 'any'
          ? netMap[item.id]?.amount || 0
          : sourceMap[item.id]?.amount || 0;
      return {
        id: item.id,
        name: item.name,
        amount: available,
        available,
        local: localItem?.amount || 0,
        icon:
          item.icon ||
          localItem?.icon ||
          sourceMap[item.id]?.icon ||
          netMap[item.id]?.icon,
        icon_state:
          item.icon_state ||
          localItem?.icon_state ||
          sourceMap[item.id]?.icon_state ||
          netMap[item.id]?.icon_state,
      };
    });
  }, [
    localOnly,
    local_stock,
    sourceUid,
    selectedSource,
    net_stock,
    localMap,
    netMap,
    sourceMap,
  ]);

  const searcher = createSearch<DisplayStock>(searchText, (item) => item.name);
  const filteredStock = displayStock.filter(searcher);

  const addToBuffer = (item: DisplayStock, amount: number) => {
    if (amount <= 0) {
      return;
    }
    setBuffer((prev) => {
      const existing = prev.find((entry) => entry.id === item.id);
      if (existing) {
        return prev.map((entry) =>
          entry.id === item.id
            ? { ...entry, amount: entry.amount + amount }
            : entry
        );
      }
      return [
        ...prev,
        {
          id: item.id,
          name: item.name,
          amount,
          icon: item.icon,
          icon_state: item.icon_state,
        },
      ];
    });
  };

  const setBufferAmount = (itemId: string, amount: number) => {
    if (amount <= 0) {
      setBuffer((prev) => prev.filter((entry) => entry.id !== itemId));
      return;
    }
    setBuffer((prev) =>
      prev.map((entry) =>
        entry.id === itemId ? { ...entry, amount } : entry
      )
    );
  };

  const removeFromBuffer = (itemId: string) => {
    setBuffer((prev) => prev.filter((entry) => entry.id !== itemId));
  };

  const createOrder = () => {
    if (!destUid || !buffer.length) {
      return;
    }
    const wanted: Record<string, number> = {};
    for (const entry of buffer) {
      wanted[entry.id] = entry.amount;
    }
    act('create_request', {
      source: sourceUid,
      dest: destUid,
      wanted: JSON.stringify(wanted),
    });
    setBuffer([]);
  };

  return (
    <Window title={`Логистика — ${name}`} width={820} height={820}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Section title="Статус">
              <Box className="Logistics__StatusGrid">
                <Box className="Logistics__StatusCell">
                  <Box color="label">Режим</Box>
                  <Box>
                    {mode === 'send' ? 'Отправка' : 'Приём'}{' '}
                    <Button
                      icon="info"
                      tooltip={
                        mode === 'send'
                          ? 'Режим отправка устанавливает высший приоритет на отправку заказов.'
                          : 'Режим приём устанавливает нисший приоритет на отправку заказов. Товар будет отправлен только в случае отсутствия в интерфейсах с режимом отправки.'
                      }
                      tooltipPosition="bottom"
                    />
                  </Box>
                </Box>
                <Box className="Logistics__StatusCell">
                  <Box color="label">Логистическая сеть</Box>
                  <Box>
                    {typeof network_id === 'number'
                      ? `#${network_id}`
                      : 'нет сети'}
                  </Box>
                </Box>
                <Box className="Logistics__StatusCell">
                  <Box color="label">Заполненность</Box>
                  <Box>{formatFill(fill_percent)}</Box>
                </Box>
                <Box className="Logistics__StatusCell">
                  <Button.Checkbox
                    checked={notify_status}
                    onClick={() => act('toggle_notify_status')}
                  >
                    Уведомлять о статусе заказа
                  </Button.Checkbox>
                </Box>

                <Box className="Logistics__StatusCell">
                  <Box color="label">Название</Box>
                  <Button icon="pen" onClick={() => act('set_name')}>
                    {name}
                  </Button>
                </Box>
                <Box className="Logistics__StatusCell">
                  <Box color="label">Экспорт</Box>
                  <Button.Checkbox
                    checked={allow_export}
                    onClick={() => act('toggle_export')}
                  >
                    Отправка
                  </Button.Checkbox>
                </Box>
                <Box className="Logistics__StatusCell">
                  <Box color="label">Подключение</Box>
                  <Box color={connected ? 'good' : 'bad'}>
                    {connected ? 'подключён' : 'не подключён'}
                  </Box>
                </Box>
                <Box className="Logistics__StatusCell">
                  <Button.Checkbox
                    checked={sound_notify}
                    onClick={() => act('toggle_sound_notify')}
                  >
                    Звуковое уведомление
                  </Button.Checkbox>
                </Box>
              </Box>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Section
              fill
              scrollable
              className="Logistics__Stock"
              title="Хранилище"
              buttons={
                <Stack>
                  <Stack.Item>
                    <Button
                      icon="warehouse"
                      selected={localOnly}
                      tooltip="Показать только предметы локального хранилища"
                      onClick={() => setLocalOnly(!localOnly)}
                    >
                      Локально
                    </Button>
                  </Stack.Item>
                  <Stack.Item>
                    <Input
                      width={14}
                      placeholder="Поиск..."
                      expensive
                      value={searchText}
                      onChange={setSearchText}
                    />
                  </Stack.Item>
                </Stack>
              }
            >
              <Box className="Logistics__Header">
                <Stack fill>
                  <Stack.Item grow>Предмет</Stack.Item>
                  <Stack.Item basis="15%" textAlign="center" color="label" bold>
                    Доступно
                  </Stack.Item>
                  <Stack.Item basis="15%" textAlign="center" color="label" bold>
                    Локально
                  </Stack.Item>
                  <Stack.Item basis="20%" textAlign="center" color="label" bold>
                    В буфер
                  </Stack.Item>
                </Stack>
              </Box>
              {filteredStock.length ? (
                filteredStock.map((item) => (
                  <StockLine
                    key={item.id}
                    item={item}
                    onAdd={(amount) => addToBuffer(item, amount)}
                  />
                ))
              ) : (
                <Box color="average" p={1}>
                  {searchText
                    ? 'Ничего не найдено.'
                    : localOnly
                      ? 'В локальном хранилище пусто.'
                      : 'Нет предметов для выбранного источника.'}
                </Box>
              )}
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Box className="Logistics__Bottom">
              <Box className="Logistics__BottomSide">
                <NodeColumn
                  title="Откуда"
                  allowAny
                  selected={sourceUid}
                  nodes={sortedNodes}
                  selfUid={data.uid}
                  onSelect={setSourceUid}
                />
              </Box>
              <Box className="Logistics__BottomCenter">
                <BufferColumn
                  buffer={buffer}
                  connected={connected}
                  canSubmit={!!destUid && !!buffer.length && connected}
                  destAccepted={destAccepted}
                  hasDest={!!selectedDest}
                  sourceLabel={
                    selectedSource?.name ||
                    (sourceUid === 'any' ? 'Any' : 'не выбран')
                  }
                  destLabel={selectedDest?.name || 'не выбран'}
                  onChange={setBufferAmount}
                  onRemove={removeFromBuffer}
                  onClear={() => setBuffer([])}
                  onSubmit={createOrder}
                />
              </Box>
              <Box className="Logistics__BottomSide">
                <NodeColumn
                  title="Куда"
                  allowAny={false}
                  selected={destUid}
                  nodes={sortedNodes}
                  selfUid={data.uid}
                  onSelect={setDestUid}
                />
              </Box>
            </Box>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const StockLine = (props: {
  item: DisplayStock;
  onAdd: (amount: number) => void;
}) => {
  const { item, onAdd } = props;
  return (
    <Box className="Logistics__Line">
      <Stack fill>
        <Stack.Item grow align="center">
          <Stack align="center">
            <Stack.Item>
              {!!item.icon && !!item.icon_state && (
                <DmIcon
                  icon={item.icon}
                  icon_state={item.icon_state}
                  style={{ width: '32px', height: '32px' }}
                />
              )}
            </Stack.Item>
            <Stack.Item>{item.name}</Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item
          basis="15%"
          textAlign="center"
          align="center"
          color="orange"
          bold={item.available >= 1}
        >
          {item.available.toLocaleString('en-US')}
        </Stack.Item>
        <Stack.Item
          basis="15%"
          textAlign="center"
          align="center"
          color="blue"
          bold={item.local >= 1}
        >
          {item.local.toLocaleString('en-US')}
        </Stack.Item>
        <Stack.Item
          basis="20%"
          textAlign="center"
          align="center"
          lineHeight="32px"
        >
          <NumberInput
            width="55%"
            value={0}
            minValue={0}
            step={1}
            maxValue={Math.max(item.available, 1000)}
            stepPixelSize={6}
            onChange={(value) => onAdd(value)}
          />
        </Stack.Item>
      </Stack>
    </Box>
  );
};

const NodeColumn = (props: {
  title: string;
  nodes: Node[];
  selected: string;
  allowAny: boolean;
  selfUid: string;
  onSelect: (uid: string) => void;
}) => {
  const { title, nodes, selected, allowAny, selfUid, onSelect } = props;
  const options: DropdownEntry[] = [
    ...(allowAny
      ? [{ value: 'any', displayText: 'Любой Источник' }]
      : []),
    ...nodes.map((node) => ({
      value: node.uid,
      displayText: node.self ? `${node.name} (это устройство)` : node.name,
    })),
  ];

  const selectedNode =
    selected === 'any' ? null : nodes.find((n) => n.uid === selected);
  const selectedLabel =
    options.find((opt) => opt.value === selected)?.displayText ||
    (allowAny ? 'Выберите источник' : 'Выберите назначение');
  const fillValue =
    typeof selectedNode?.fill_percent === 'number'
      ? selectedNode.fill_percent
      : null;
  const stockPreview = (selectedNode?.stock || []).slice(0, 3);

  return (
    <Box className="Logistics__Column">
      <Box bold mb={0.5}>
        {title}
      </Box>
      <Stack mb={0.5} align="center">
        <Stack.Item>
          {selected === 'any' ? (
            <Box className="Logistics__NodeIcon">
              <Icon name="globe" size={1.5} />
            </Box>
          ) : selectedNode?.icon && selectedNode.icon_state ? (
            <DmIcon
              icon={selectedNode.icon}
              icon_state={selectedNode.icon_state}
              style={{ width: '40px', height: '40px' }}
            />
          ) : (
            <Box className="Logistics__NodeIcon" color="label">
              —
            </Box>
          )}
        </Stack.Item>
        <Stack.Item grow>
          <Box>
            {selected === 'any'
              ? 'Any'
              : selectedNode?.name || 'Не выбран'}
          </Box>
          <Box color="label" fontSize="0.85em">
            {selected === 'any'
              ? 'любой источник'
              : selectedNode
                ? `${selectedNode.mode === 'send' ? 'отправка' : 'приём'} · ${formatFill(selectedNode.fill_percent)}`
                : 'выберите устройство'}
          </Box>
        </Stack.Item>
      </Stack>
      {fillValue !== null && (
        <ProgressBar
          value={fillValue / 100}
          ranges={{
            good: [0, 0.5],
            average: [0.5, 0.8],
            bad: [0.8, 1],
          }}
          mb={0.5}
        >
          {fillValue}%
        </ProgressBar>
      )}
      {!!stockPreview.length && (
        <Box color="label" fontSize="0.8em" mb={0.5}>
          {stockPreview
            .map((item) => `${item.name} ×${item.amount}`)
            .join(' · ')}
          {(selectedNode?.stock?.length || 0) > 3 ? ' …' : ''}
        </Box>
      )}
      <Dropdown
        fluid
        options={options}
        selected={selected || null}
        displayText={selectedLabel}
        onSelected={(value) => onSelect(String(value))}
        menuWidth="18rem"
        disabled={!options.length}
      />
      {!!selfUid && (
        <Button
          mt={0.5}
          fluid
          icon="crosshairs"
          disabled={selected === selfUid}
          onClick={() => onSelect(selfUid)}
        >
          Это устройство
        </Button>
      )}
    </Box>
  );
};

const BufferColumn = (props: {
  buffer: BufferItem[];
  connected: boolean;
  canSubmit: boolean;
  hasDest: boolean;
  destAccepted: Set<string>;
  sourceLabel: string;
  destLabel: string;
  onChange: (id: string, amount: number) => void;
  onRemove: (id: string) => void;
  onClear: () => void;
  onSubmit: () => void;
}) => {
  const {
    buffer,
    connected,
    canSubmit,
    hasDest,
    destAccepted,
    sourceLabel,
    destLabel,
    onChange,
    onRemove,
    onClear,
    onSubmit,
  } = props;

  return (
    <Box className="Logistics__Column Logistics__Column--buffer">
      <Box bold mb={0.5} textAlign="center">
        Буфер
      </Box>
      <Box color="label" fontSize="0.8em" textAlign="center" mb={0.5}>
        {sourceLabel} → {destLabel}
      </Box>
      {!connected ? (
        <Box color="bad" textAlign="center">
          Нет трубы на клетке.
        </Box>
      ) : (
        <>
          <Box className="Logistics__BufferList">
            {buffer.length ? (
              buffer.map((entry) => {
                const incompatible = hasDest && !destAccepted.has(entry.id);
                return (
                  <Box
                    key={entry.id}
                    className="Logistics__Line"
                    backgroundColor={incompatible ? 'bad' : undefined}
                    mb={0.5}
                  >
                    <Stack fill align="center">
                      <Stack.Item>
                        {!!entry.icon && !!entry.icon_state && (
                          <DmIcon
                            icon={entry.icon}
                            icon_state={entry.icon_state}
                            style={{ width: '24px', height: '24px' }}
                          />
                        )}
                      </Stack.Item>
                      <Stack.Item
                        grow
                        color={incompatible ? 'white' : undefined}
                      >
                        {entry.name}
                      </Stack.Item>
                      <Stack.Item>
                        <NumberInput
                          width={4}
                          minValue={1}
                          maxValue={1000}
                          step={1}
                          value={entry.amount}
                          onChange={(value) => onChange(entry.id, value)}
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          icon="times"
                          color="bad"
                          onClick={() => onRemove(entry.id)}
                        />
                      </Stack.Item>
                    </Stack>
                  </Box>
                );
              })
            ) : (
              <Box color="average" textAlign="center">
                Пусто
              </Box>
            )}
          </Box>
          <Box mt={0.5} textAlign="center">
            <Button icon="trash" disabled={!buffer.length} onClick={onClear}>
              Очистить
            </Button>
            <Button
              icon="paper-plane"
              color="good"
              disabled={!canSubmit}
              onClick={onSubmit}
            >
              Заказ
            </Button>
          </Box>
        </>
      )}
    </Box>
  );
};
