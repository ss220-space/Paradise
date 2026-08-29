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
    <Window width={850} height={600}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <Tabs>
              <Tabs.Tab
                selected={activeTab === TABS.FABRICATE}
                onClick={() => setActiveTab(TABS.FABRICATE)}
              >
                Fabricate
              </Tabs.Tab>
              <Tabs.Tab
                selected={activeTab === TABS.MATERIALS}
                onClick={() => setActiveTab(TABS.MATERIALS)}
              >
                Materials
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>

          <Stack.Item grow>
            {activeTab === TABS.FABRICATE && (
              <Stack fill align="stretch">
                <Stack.Item width="50%">
                  <Section title={`Available Designs`} fill scrollable>
                    <Tabs>
                      <Tabs.Tab
                        icon="atom"
                        selected={categoryTab === 'fuel_rods'}
                        onClick={() => setCategoryTab('fuel_rods')}
                      >
                        Fuel Rods
                      </Tabs.Tab>
                      <Tabs.Tab
                        icon="cubes"
                        selected={categoryTab === 'moderator_rods'}
                        onClick={() => setCategoryTab('moderator_rods')}
                      >
                        Moderator Rods
                      </Tabs.Tab>
                      <Tabs.Tab
                        icon="snowflake"
                        selected={categoryTab === 'coolant_rods'}
                        onClick={() => setCategoryTab('coolant_rods')}
                      >
                        Coolant Rods
                      </Tabs.Tab>
                    </Tabs>

                    <Box mt={1}>
                      {(() => {
                        const list = data[categoryTab] || [];

                        if (list.length === 0) {
                          return (
                            <Box color="average" p={1}>
                              No{' '}
                              {categories
                                .find((c) => c.key === categoryTab)
                                ?.title.toLowerCase()}{' '}
                              available.
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
                  <Section title="Rod Information" fill>
                    {!selectedRod && (
                      <NoticeBox>
                        Please select a rod design from the left.
                      </NoticeBox>
                    )}

                    {selectedRod && (
                      <Stack vertical fill>
                        {/* Rod Statistics */}
                        <Section title={selectedRod.name}>
                          <Table>
                            <Table.Row>
                              <Table.Cell bold>Power Generation:</Table.Cell>
                              <Table.Cell>
                                {(selectedRod.power_amount || 0) / 1000} KW
                              </Table.Cell>
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell bold>Power Amplification:</Table.Cell>
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
                              <Table.Cell bold>Heat Generation:</Table.Cell>
                              <Table.Cell>
                                {selectedRod.heat_amount || 0} joules
                              </Table.Cell>
                            </Table.Row>
                            <Table.Row>
                              <Table.Cell bold>Heat Amplification:</Table.Cell>
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
                              <Table.Cell bold>Lifespan:</Table.Cell>
                              <Table.Cell>
                                {selectedRod.max_durability || 0} cycles
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
                                  <Table.Cell bold>Heat Enrichment:</Table.Cell>
                                  <Table.Cell>
                                    {selectedRod.heat_enrichment}
                                  </Table.Cell>
                                </Table.Row>
                                <Table.Row>
                                  <Table.Cell bold>
                                    Heat Enrichment Requirement:
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
                                    Power Enrichment:
                                  </Table.Cell>
                                  <Table.Cell>
                                    {selectedRod.power_enrichment}
                                  </Table.Cell>
                                </Table.Row>
                                <Table.Row>
                                  <Table.Cell bold>
                                    Power Enrichment Requirement:
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
                                Neighbor Requirements:
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
                                Neighbor Requirements:
                              </Box>
                              <Box ml={2}>None</Box>
                            </>
                          )}
                        </Section>

                        <Divider />

                        <Section title="Required Materials">
                          {!selectedRod.materials ||
                          Object.keys(selectedRod.materials).length === 0 ? (
                            <Box color="average">No materials required.</Box>
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
                                        ({Math.round(matAmt / 2000)} sheets)
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
                          Fabricate
                        </Button>
                      </Stack>
                    )}
                  </Section>
                </Stack.Item>
              </Stack>
            )}

            {activeTab === TABS.MATERIALS && (
              <Section title="Material Storage" fill>
                {!data.resources || Object.keys(data.resources).length === 0 ? (
                  <Box color="average">No materials loaded.</Box>
                ) : (
                  <Table>
                    {Object.entries(data.resources).map(
                      ([resName, resData], i) => (
                        <Table.Row key={i}>
                          <Table.Cell bold>{resName}</Table.Cell>
                          <Table.Cell>{resData.amount} units</Table.Cell>
                          <Table.Cell>({resData.sheets} sheets)</Table.Cell>
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
                              All
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
