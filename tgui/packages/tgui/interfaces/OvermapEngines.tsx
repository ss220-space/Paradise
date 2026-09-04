import { Button, NoticeBox, NumberInput, Section } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import {
  OvermapFrame,
  OvermapList,
  OvermapRail,
  OvermapRow,
  OvermapStat,
  OvermapStats,
} from './overmap/OvermapChrome';

type EngineInfo = {
  name: string;
  ref: string;
  on: BooleanLike;
  thrust: number;
  limit: number;
  status: string;
};

type OvermapEnginesData = {
  linked: BooleanLike;
  vessel_name: string;
  global_on: BooleanLike;
  global_limit: number;
  total_thrust: number;
  mass: number;
  accel: number;
  engines: EngineInfo[];
};

export const OvermapEngines = () => {
  const { act, data } = useBackend<OvermapEnginesData>();
  const {
    linked,
    vessel_name,
    global_on,
    global_limit,
    total_thrust,
    mass = 0,
    accel = 0,
    engines = [],
  } = data;

  return (
    <OvermapFrame
      title="Engines"
      width={560}
      height={480}
      linked={linked}
      onRelink={() => act('relink')}
      rail={
        <OvermapRail
          name={vessel_name || 'Engines'}
          lamps={[
            { label: 'банк', on: !!global_on },
            { label: `${engines.length} уст.`, on: !!engines.length },
          ]}
        />
      }
      actions={
        linked ? (
          <Button
            icon="power-off"
            selected={!!global_on}
            onClick={() => act('global_toggle')}
          >
            {global_on ? 'Все вкл' : 'Все выкл'}
          </Button>
        ) : null
      }
    >
      <div className="OvermapPanel">
        <OvermapStats>
          <OvermapStat label="тяга" value={total_thrust} />
          <OvermapStat label="масса" value={`${mass} т`} />
          <OvermapStat label="тяга/масса" value={accel} />
          <OvermapStat label="лимит" value={`${global_limit}%`} />
        </OvermapStats>
        <div style={{ margin: '0.5em 0' }}>
          Глобальный лимит
          <NumberInput
            ml={1}
            width="70px"
            unit="%"
            value={global_limit}
            minValue={0}
            maxValue={100}
            step={5}
            onChange={(value) => act('set_global_limit', { value: value })}
          />
        </div>
        <Section fill scrollable title="Установки">
          <OvermapList>
            {engines.map((engine) => (
              <OvermapRow
                key={engine.ref}
                selected={!!engine.on}
                title={engine.name}
                meta={`${engine.status} · тяга ${engine.thrust}`}
              >
                <NumberInput
                  width="56px"
                  unit="%"
                  value={engine.limit}
                  minValue={0}
                  maxValue={100}
                  step={5}
                  onChange={(value) =>
                    act('set_engine_limit', {
                      ref: engine.ref,
                      value: value,
                    })
                  }
                />
                <Button
                  selected={!!engine.on}
                  onClick={() => act('toggle_engine', { ref: engine.ref })}
                >
                  {engine.on ? 'Вкл' : 'Выкл'}
                </Button>
              </OvermapRow>
            ))}
          </OvermapList>
          {!engines.length && <NoticeBox>Двигатели не найдены.</NoticeBox>}
        </Section>
      </div>
    </OvermapFrame>
  );
};
