import { useState } from 'react';
import {
  Box,
  Button,
  Divider,
  NoticeBox,
  Section,
  Stack,
  Table,
  Tabs,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

const TABS = {
  FABRICATE: 'fabricate',
  MATERIALS: 'materials',
};

type NuclearRodFabricatorData = {
  resources: Resource[];
  matAmt: number;
  selectedRod: Rod;
};

type Rod = {
  materials: Record<string, number>;
  type_path: string;
  name: string;
  power_amount: number;
  power_amp_mod: number;
  heat_amount: number;
  heat_amp_mod: number;
  max_durability: number;
  heat_enrichment: number;
  heat_enrichment_requirement: number;
  power_enrichment: number;
  power_enrichment_requirement: number;
  neighbor_requirements: string[];
};

type Resource = {
  id: string;
  amount: number;
  sheets: number;
};

export const NuclearRodFabricator = (props) => {
  const { data, act } = useBackend<NuclearRodFabricatorData>();

  const categories = [
    { key: 'fuel_rods', title: 'Fuel Rods' },
    { key: 'moderator_rods', title: 'Moderator Rods' },
    { key: 'coolant_rods', title: 'Coolant Rods' },
  ];

  const [selectedRod, setSelectedRod] = useState<Rod>();
  const [hoveredRod, setHoveredRod] = useState<Rod>();
  const [activeTab, setActiveTab] = useState(TABS.FABRICATE);
  const [categoryTab, setCategoryTab] = useState('fuel_rods');

  return (
    <Window width={900} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={activeTab === TABS.FABRICATE}
                onClick={() => setActiveTab(TABS.FABRICATE)}
              >
                Производство
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === TABS.MATERIALS}
                onClick={() => setActiveTab(TABS.MATERIALS)}
              >
                Материалы
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          <Stack.Item grow>
            {activeTab === TABS.FABRICATE && (
              <Stack fill align="stretch">
                <Stack.Item width="50%">
                  <Section title={`Доступные варианты`} fill scrollable>
                    <Tabs>
                      <Tabs.Tab
                        icon="atom"
                        selected={categoryTab === 'fuel_rods'}
                        onClick={() => setCategoryTab('fuel_rods')}
                      >
                        Топливные
                      </Tabs.Tab>
                      <Tabs.Tab
                        icon="cubes"
                        selected={categoryTab === 'moderator_rods'}
                        onClick={() => setCategoryTab('moderator_rods')}
                      >
                        Замедляющие
                      </Tabs.Tab>
                      <Tabs.Tab
                        icon="snowflake"
                        selected={categoryTab === 'coolant_rods'}
                        onClick={() => setCategoryTab('coolant_rods')}
                      >
                        Охлаждающие
                      </Tabs.Tab>
                    </Tabs>

                    <Box mt={1}>
                      {(() => {
                        const list = data[categoryTab] || [];

                        if (list.length === 0) {
                          return (
                            <Box color="average" p={1}>
                              Нет{' '}
                              {categories
                                .find((c) => c.key === categoryTab)
                                ?.title.toLowerCase()}{' '}
                              в наличии.
                            </Box>
                          );
                        }

                        return list.map((rod, i) => (
                          <Box
                            key={i}
                            p={1}
                            mb={0.5}
                            style={{
                              cursor: 'pointer',
                              backgroundColor:
                                selectedRod?.type_path === rod.type_path
                                  ? 'rgba(80, 140, 255, 0.25)'
                                  : hoveredRod?.type_path === rod.type_path
                                    ? 'rgba(255,255,255,0.08)'
                                    : 'rgba(255,255,255,0.03)',
                              border: '1px solid rgba(255,255,255,0.08)',
                            }}
                            onClick={() => setSelectedRod(rod)}
                            onMouseEnter={() => setHoveredRod(rod)}
                            onMouseLeave={() => setHoveredRod(undefined)}
                          >
                            <Box bold>{rod.name}</Box>
                            <Box fontSize="0.85em" color="label">
                              {rod.desc}
                            </Box>
                          </Box>
                        ));
                      })()}
                    </Box>
                  </Section>
                </Stack.Item>

                <Stack.Item grow>
                  <Section title="Информация" fill>
                    {!selectedRod && (
                      <NoticeBox>
                        Пожалуйста, выберите вариант стержня.
                      </NoticeBox>
                    )}

                    {selectedRod && (
                      <Stack vertical fill>
                        {/* Rod Statistics */}
                        <Section title={selectedRod.name}>
                          <Table>
                            <Table.Row>
                              <Table.Cell bold>Генерация энергии:</Table.Cell>
                              <Table.Cell>
                                {(selectedRod.power_amount || 0) / 1000} KW
                              </Table.Cell>
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell bold>Усиление мощности:</Table.Cell>
                              <Table.Cell>
                                {selectedRod.power_amp_mod || 1}
                              </Table.Cell>
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell
                                colSpan={2}
                                style={{ paddingTop: '8px' }}
                              />
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell bold>Генерация тепла:</Table.Cell>
                              <Table.Cell>
                                {selectedRod.heat_amount || 0} Дж
                              </Table.Cell>
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell bold>
                                Усиление теплового потока:
                              </Table.Cell>
                              <Table.Cell>
                                {selectedRod.heat_amp_mod || 1}
                              </Table.Cell>
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell
                                colSpan={2}
                                style={{ paddingTop: '8px' }}
                              />
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell bold>
                                Продолжительность работы:
                              </Table.Cell>
                              <Table.Cell>
                                {selectedRod.max_durability || 0} циклов
                              </Table.Cell>
                            </Table.Row>
                            {selectedRod.heat_enrichment && (
                              <>
                                <Table.Row>
                                  <Table.Cell
                                    colSpan={2}
                                    style={{ paddingTop: '8px' }}
                                  />
                                </Table.Row>
                                <Table.Row>
                                  <Table.Cell bold>
                                    Тепловое обогащение:
                                  </Table.Cell>
                                  <Table.Cell>
                                    {selectedRod.heat_enrichment}
                                  </Table.Cell>
                                </Table.Row>
                                <Table.Row>
                                  <Table.Cell bold>
                                    Требование к обогащению теплом:
                                  </Table.Cell>
                                  <Table.Cell>
                                    {selectedRod.heat_enrichment_requirement ||
                                      0}
                                  </Table.Cell>
                                </Table.Row>
                              </>
                            )}
                            {selectedRod.power_enrichment && (
                              <>
                                <Table.Row>
                                  <Table.Cell
                                    colSpan={2}
                                    style={{ paddingTop: '8px' }}
                                  />
                                </Table.Row>
                                <Table.Row>
                                  <Table.Cell bold>
                                    Обогащение энергии:
                                  </Table.Cell>
                                  <Table.Cell>
                                    {selectedRod.power_enrichment}
                                  </Table.Cell>
                                </Table.Row>
                                <Table.Row>
                                  <Table.Cell bold>
                                    Требования к обогащению энергии:
                                  </Table.Cell>
                                  <Table.Cell>
                                    {selectedRod.power_enrichment_requirement ||
                                      0}
                                  </Table.Cell>
                                </Table.Row>
                              </>
                            )}
                          </Table>

                          {selectedRod.neighbor_requirements &&
                          selectedRod.neighbor_requirements.length > 0 ? (
                            <>
                              <Box mt={1} bold>
                                Требования к соседям:
                              </Box>
                              <Box ml={2}>
                                {selectedRod.neighbor_requirements.map(
                                  (requirement, idx) => (
                                    <Box key={idx}>{requirement}</Box>
                                  ),
                                )}
                              </Box>
                            </>
                          ) : (
                            <>
                              <Box mt={1} bold>
                                Требования к соседям:
                              </Box>
                              <Box ml={2}>Нет</Box>
                            </>
                          )}
                        </Section>

                        <Divider />

                        <Section title="Необходимые материалы">
                          {!selectedRod.materials ||
                          Object.keys(selectedRod.materials).length === 0 ? (
                            <Box color="average">Материалы не требуются.</Box>
                          ) : (
                            <Table>
                              {Object.entries(selectedRod.materials).map(
                                ([matName, matAmt], i) => {
                                  // Check if we have enough of this material
                                  const availableResource = Object.entries(
                                    data.resources || {},
                                  ).find(
                                    ([resName, resData]) => resName === matName,
                                  );
                                  const availableAmount = availableResource
                                    ? availableResource[1].amount
                                    : 0;
                                  const hasEnough = availableAmount >= matAmt;

                                  return (
                                    <Table.Row key={i}>
                                      <Table.Cell
                                        bold
                                        className={
                                          !hasEnough ? 'color-red' : null
                                        }
                                      >
                                        {matName}
                                      </Table.Cell>
                                      <Table.Cell
                                        className={
                                          !hasEnough ? 'color-red' : null
                                        }
                                      >
                                        {matAmt}
                                      </Table.Cell>
                                      <Table.Cell
                                        className={
                                          !hasEnough ? 'color-red' : null
                                        }
                                      >
                                        ({Math.round(matAmt / 2000)} листов)
                                      </Table.Cell>
                                    </Table.Row>
                                  );
                                },
                              )}
                            </Table>
                          )}
                        </Section>

                        <Divider />

                        {/* Fabricate Button */}
                        <Button
                          icon="wrench"
                          color="good"
                          onClick={() =>
                            act('fabricate_rod', {
                              type_path: selectedRod.type_path,
                            })
                          }
                        >
                          Создать
                        </Button>
                      </Stack>
                    )}
                  </Section>
                </Stack.Item>
              </Stack>
            )}

            {activeTab === TABS.MATERIALS && (
              <Section title="Хранилище материалов" fill>
                {!data.resources || Object.keys(data.resources).length === 0 ? (
                  <Box color="average">Материалы не загружены.</Box>
                ) : (
                  <Table>
                    {Object.entries(data.resources).map(
                      ([resName, resData], i) => (
                        <Table.Row key={i}>
                          <Table.Cell bold>{resName}</Table.Cell>
                          <Table.Cell>{resData.amount} ед.</Table.Cell>
                          <Table.Cell>({resData.sheets} листов)</Table.Cell>
                          <Table.Cell>
                            <Button
                              onClick={() =>
                                act('eject_material', {
                                  id: resData.id,
                                  amount: '1',
                                })
                              }
                            >
                              1
                            </Button>
                            <Button
                              onClick={() =>
                                act('eject_material', {
                                  id: resData.id,
                                  amount: 'custom',
                                })
                              }
                            >
                              C
                            </Button>
                            {resData.sheets >= 5 && (
                              <Button
                                onClick={() =>
                                  act('eject_material', {
                                    id: resData.id,
                                    amount: '5',
                                  })
                                }
                              >
                                5
                              </Button>
                            )}
                            <Button
                              onClick={() =>
                                act('eject_material', {
                                  id: resData.id,
                                  amount: resData.sheets.toString(),
                                })
                              }
                            >
                              Всё
                            </Button>
                          </Table.Cell>
                        </Table.Row>
                      ),
                    )}
                  </Table>
                )}
              </Section>
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
