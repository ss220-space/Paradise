import { useMemo, useState } from 'react';
import { useBackend } from '../backend';
import { Box, Button, Dropdown, Input, NoticeBox, ProgressBar, Section, Slider, Stack } from 'tgui-core/components';
import { NanoMap } from '../components';
import { Window } from '../layouts';

type Location = {
  name: string;
  x: number;
  y: number;
  z: number;
};

type PortalGunData = {
  fluidAmount: number;
  fluidCapacity: number;
  hasCanister: boolean;
  hasEntrance: boolean;
  hasExit: boolean;
  lifespan: number;
  locations: Location[];
  mode: 'pair' | 'location';
  requiredFluid: number;
  selectedLocation: string | null;
  stationLevelName: string[];
  stationLevelNum: number[];
};

export const PortalGun = (_props: unknown) => {
  const { act, data } = useBackend<PortalGunData>();
  const [zoom, setZoom] = useState(1);
  const [search, setSearch] = useState('');
  const [zCurrent, setZCurrent] = useState(data.stationLevelNum[0] ?? 1);
  const filteredLocations = useMemo(() => {
    const query = search.trim().toLocaleLowerCase();
    if (!query) {
      return data.locations;
    }
    return data.locations.filter((location) =>
      location.name.toLocaleLowerCase().includes(query)
    );
  }, [data.locations, search]);
  const portalStatus = data.hasExit
    ? 'Пара порталов активна'
    : data.hasEntrance
      ? 'Установите второй портал'
      : 'Порталы не открыты';
  const selectLocation = (locationName: string) => {
    const location = data.locations.find(
      (candidate) => candidate.name === locationName
    );
    if (location) {
      setZCurrent(location.z);
    }
    act('set_location', { location: locationName });
  };

  return (
    <Window width={900} height={650} theme="ntos">
      <Window.Content>
        <Stack fill>
          <Stack.Item width="290px">
            <Stack fill vertical>
              <Stack.Item>
                <Section title="Квантовый раствор">
                  {!data.hasCanister ? (
                    <NoticeBox danger>Картридж не установлен</NoticeBox>
                  ) : (
                    <ProgressBar
                      value={data.fluidAmount}
                      minValue={0}
                      maxValue={data.fluidCapacity || 100}
                      ranges={{
                        good: [40, Infinity],
                        average: [15, 40],
                        bad: [-Infinity, 15],
                      }}
                    >
                      {data.fluidAmount} / {data.fluidCapacity} ед.
                    </ProgressBar>
                  )}
                  <Button
                    fluid
                    mt={1}
                    icon="eject"
                    disabled={!data.hasCanister}
                    onClick={() => act('eject_canister')}
                  >
                    Извлечь картридж
                  </Button>
                </Section>
              </Stack.Item>

              <Stack.Item>
                <Section title="Режим">
                  <Stack>
                    <Stack.Item grow>
                      <Button
                        fluid
                        selected={data.mode === 'pair'}
                        icon="link"
                        onClick={() => act('set_mode', { mode: 'pair' })}
                      >
                        Парный
                      </Button>
                    </Stack.Item>
                    <Stack.Item grow>
                      <Button
                        fluid
                        selected={data.mode === 'location'}
                        icon="map-marker-alt"
                        onClick={() => act('set_mode', { mode: 'location' })}
                      >
                        Локация
                      </Button>
                    </Stack.Item>
                  </Stack>
                  <Box mt={1} color="label">
                    {data.mode === 'pair'
                      ? 'Два выстрела связывают две выбранные точки.'
                      : 'Один выстрел открывает проход в выбранную локацию.'}
                  </Box>
                </Section>
              </Stack.Item>

              <Stack.Item>
                <Section title="Время работы">
                  <Slider
                    value={data.lifespan}
                    minValue={10}
                    maxValue={120}
                    step={5}
                    stepPixelSize={4}
                    unit=" сек."
                    onChange={(_event, value) =>
                      act('set_lifespan', { lifespan: value })
                    }
                  />
                  <Box mt={1} color="label">
                    Следующий выстрел: {data.requiredFluid} ед. жидкости
                  </Box>
                </Section>
              </Stack.Item>

              <Stack.Item grow>
                <Section fill title="Состояние">
                  <NoticeBox info>{portalStatus}</NoticeBox>
                  {data.mode === 'location' && (
                    <Box mb={1}>
                      Назначение: {data.selectedLocation || 'не выбрано'}
                    </Box>
                  )}
                  <Button
                    fluid
                    icon="times-circle"
                    color="bad"
                    disabled={!data.hasEntrance && !data.hasExit}
                    onClick={() => act('close_portals')}
                  >
                    Закрыть порталы
                  </Button>
                </Section>
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item grow>
            {data.mode === 'location' ? (
              <Stack fill vertical>
                <Stack.Item>
                  <Stack>
                    <Stack.Item grow>
                      <Input
                        fluid
                        expensive
                        placeholder="Поиск локации..."
                        value={search}
                        onChange={setSearch}
                      />
                    </Stack.Item>
                    <Stack.Item width="260px">
                      <Dropdown
                        width="100%"
                        selected={data.selectedLocation || 'Выберите локацию'}
                        options={filteredLocations.map(
                          (location) => location.name
                        )}
                        onSelected={selectLocation}
                      />
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
                <Stack.Item grow>
                  <Section fill title="Карта назначения">
                    <Box height="540px" overflow="hidden">
                      <NanoMap
                        zLevels={data.stationLevelNum}
                        zNames={data.stationLevelName}
                        zCurrent={zCurrent}
                        setZCurrent={setZCurrent}
                        onZoom={(_event, value) => setZoom(value)}
                      >
                        {filteredLocations.map((location) => (
                          <NanoMap.MarkerIcon
                            key={location.name}
                            x={location.x}
                            y={location.y}
                            z={location.z}
                            z_current={zCurrent}
                            zoom={zoom}
                            icon="map-marker-alt"
                            color={
                              data.selectedLocation === location.name
                                ? 'green'
                                : 'blue'
                            }
                            bordered={data.selectedLocation === location.name}
                            tooltip={location.name}
                            onClick={() => selectLocation(location.name)}
                          />
                        ))}
                      </NanoMap>
                    </Box>
                  </Section>
                </Stack.Item>
              </Stack>
            ) : (
              <Section fill title="Парная настройка">
                <Stack fill align="center" justify="center" vertical>
                  <Stack.Item>
                    <Box fontSize="64px" color="green">
                      ◎ ─── ◎
                    </Box>
                  </Stack.Item>
                  <Stack.Item>
                    <Box fontSize="18px" textAlign="center">
                      Выстрелите в первую поверхность, затем во вторую.
                      <br />
                      Оба портала будут работать в двух направлениях.
                    </Box>
                  </Stack.Item>
                </Stack>
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
