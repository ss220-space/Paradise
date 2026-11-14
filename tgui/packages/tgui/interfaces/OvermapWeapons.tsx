import { useState } from 'react';
import { Box, Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import type { OvermapHelmData } from './OvermapHelm';
import { OvermapFrame } from './overmap/OvermapChrome';
import { OvermapRadar } from './overmap/OvermapRadar';

export const OvermapWeapons = () => {
  const { act, data } = useBackend<OvermapHelmData>();
  const [radius, setRadius] = useState(64);
  const [followHeading, setFollowHeading] = useState(true);
  const weapons = data.weapons || [];
  const selected = weapons.filter((weapon) => weapon.selected);
  return (
    <OvermapFrame
      title={`Управление оружием · ${data.vessel_name || ''}`}
      variant="weapons"
      width={1100}
      height={820}
      linked={data.linked}
      onRelink={() => act('relink')}
    >
      <Stack fill>
        <Stack.Item grow minWidth={0}>
          <Section
            className="OvermapRadarSection"
            title={data.sector_name}
            fill
          >
            {data.map_jammed && !data.radar_locked ? (
              <NoticeBox danger>Сигнал потерян: идёт переход.</NoticeBox>
            ) : (
              <OvermapRadar
                outlines={data.radar_outlines}
                locked={!!data.radar_locked}
                docked={!!data.radar_docked}
                tick={data.radar_tick}
                epoch={data.radar_epoch}
                shapes={data.radar_shapes || {}}
                contacts={data.radar || []}
                drifters={data.radar_drifters || []}
                projectiles={data.radar_projectiles || []}
                weapons={weapons}
                onSelectWeapon={(id) => act('select_weapon', { id })}
                weaponArcs={selected}
                facing={data.facing || 0}
                terrain={data.radar_terrain}
                world={data.radar_world}
                engines={data.radar_engines || []}
                poses={data.radar_poses}
                objects={data.objects}
                self={data.self_pos}
                sectorSize={data.sector_size}
                cellSpan={data.cell_span}
                sectorId={data.sector_id}
                galaxy={data.galaxy}
                radius={radius}
                onZoom={setRadius}
                onReach={(reach) => {
                  if (reach !== data.radar_reach)
                    act('helm_radar_reach', { reach });
                }}
                followHeading={followHeading}
                onToggleFollow={() => setFollowHeading(!followHeading)}
                peels={data.radar_peels}
                scatter={data.radar_scatter}
                hazardFields={data.hazard_fields || []}
                onSelectPoint={(x, y) => act('radar_point', { x, y })}
                onSelectObject={(id) => act('set_dest', { id })}
              />
            )}
          </Section>
        </Stack.Item>
        <Stack.Item width="25em">
          <Section title={`Орудия · ${weapons.length}`} fill scrollable>
            {!weapons.length && (
              <NoticeBox>На корпусе не обнаружены орудия.</NoticeBox>
            )}
            <Box mb={1} color="label">
              Выберите орудия и укажите цель на радаре. Обшивка своего корабля
              также останавливает выстрелы.
            </Box>
            {weapons.map((weapon) => (
              <Box key={weapon.id} mb={1}>
                <Button
                  fluid
                  selected={weapon.selected}
                  icon="crosshairs"
                  onClick={() => act('select_weapon', { id: weapon.id })}
                >
                  {weapon.name}
                </Button>
                <Box color="label">
                  Сектор {weapon.arc}° ·{' '}
                  {weapon.cooldown > 0
                    ? `перезарядка ${weapon.cooldown.toFixed(1)} с`
                    : 'готово'}
                </Box>
                {!!weapon.turret && (
                  <Button.Checkbox
                    checked={weapon.auto}
                    onClick={() => act('weapon_auto', { id: weapon.id })}
                  >
                    Автоматический огонь
                  </Button.Checkbox>
                )}
              </Box>
            ))}
          </Section>
        </Stack.Item>
      </Stack>
    </OvermapFrame>
  );
};
