import { Icon, LabeledList, ProgressBar, Section } from 'tgui-core/components';
import { useBackend } from '../backend';
import { Window } from '../layouts';

interface ChamberData {
  chamber_down: boolean;
  linked: boolean;
  has_rod: boolean;
  rod_name?: string;
  durability_percent?: number;
  depleted?: boolean;
  is_fuel?: boolean;
  has_power?: boolean;
  power_output?: number;
  power_mod?: number;
  has_heat?: boolean;
  heat_output?: number;
  heat_mod?: number;
  has_power_enrichment?: boolean;
  has_heat_enrichment?: boolean;
  power_enriched?: boolean;
  heat_enriched?: boolean;
  power_enriching?: boolean;
  heat_enriching?: boolean;
}

export const ReactorChamber = () => {
  const { data } = useBackend<ChamberData>();
  const {
    chamber_down,
    linked,
    has_rod,
    rod_name,
    durability_percent = 0,
    depleted,
    is_fuel,
    has_power,
    power_output = 0,
    power_mod,
    has_heat,
    heat_output = 0,
    heat_mod,
    has_power_enrichment,
    has_heat_enrichment,
    power_enriched,
    heat_enriched,
    power_enriching,
    heat_enriching,
  } = data;

  // DM отдаёт TRUE/FALSE как 1/0 в JSON — нормализуем,
  // иначе «0 && …» рендерится текстом «0»
  const isChamberDown = !!chamber_down;
  const hasRod = !!has_rod;
  const isDepleted = !!depleted;
  const isLinked = !!linked;
  const isFuel = !!is_fuel;
  const canPowerEnrich = !!has_power_enrichment;
  const canHeatEnrich = !!has_heat_enrichment;
  const isPowerEnriching = !!power_enriching;
  const isHeatEnriching = !!heat_enriching;

  return (
    <Window width={430} height={500}>
      <Window.Content scrollable>
        {!isChamberDown && (
          <Section>Камера не опущена — данные недоступны.</Section>
        )}
        {isChamberDown && !hasRod && (
          <Section>В камере нет ядерного стержня.</Section>
        )}
        {isChamberDown && hasRod && (
          <>
            <Section title={rod_name}>
              <LabeledList>
                <LabeledList.Item label="Целостность">
                  <ProgressBar
                    value={durability_percent / 100}
                    ranges={{
                      good: [0.7, 1],
                      average: [0.3, 0.7],
                      bad: [-Infinity, 0.3],
                    }}
                  >
                    {`${durability_percent}%`}
                  </ProgressBar>
                </LabeledList.Item>
                {isDepleted && (
                  <LabeledList.Item label="Статус" color="bad">
                    Полностью исчерпан
                  </LabeledList.Item>
                )}
                {!isLinked && (
                  <LabeledList.Item label="Статус" color="bad">
                    Камера не подключена к реактору
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>

            <Section title="Энергия и тепло">
              <LabeledList>
                <LabeledList.Item label="Мощность">
                  {has_power ? `${power_output} кВт` : 'нет'}
                </LabeledList.Item>
                <LabeledList.Item label="Множитель мощности">
                  x {power_mod}
                </LabeledList.Item>
                <LabeledList.Item label="Тепловыделение">
                  {has_heat ? `${heat_output} Дж` : 'нет'}
                </LabeledList.Item>
                <LabeledList.Item label="Множитель тепла">
                  x {heat_mod}
                </LabeledList.Item>
              </LabeledList>
            </Section>

            {isFuel && (canPowerEnrich || canHeatEnrich) && (
              <Section title="Обогащение">
                <LabeledList>
                  {canPowerEnrich && (
                    <LabeledList.Item
                      label="Энергетическое"
                      color={power_enriched ? 'good' : undefined}
                    >
                      {power_enriched ? (
                        'Завершено'
                      ) : (
                        <>
                          Не завершено{' '}
                          {isPowerEnriching && (
                            <Icon name="circle-notch" spin color="label" />
                          )}
                        </>
                      )}
                    </LabeledList.Item>
                  )}
                  {canHeatEnrich && (
                    <LabeledList.Item
                      label="Тепловое"
                      color={heat_enriched ? 'good' : undefined}
                    >
                      {heat_enriched ? (
                        'Завершено'
                      ) : (
                        <>
                          Не завершено{' '}
                          {isHeatEnriching && (
                            <Icon name="circle-notch" spin color="label" />
                          )}
                        </>
                      )}
                    </LabeledList.Item>
                  )}
                </LabeledList>
              </Section>
            )}
          </>
        )}
      </Window.Content>
    </Window>
  );
};
