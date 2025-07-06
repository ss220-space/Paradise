import { useBackend } from '../backend';
import { Box, Section, Button, LabeledList } from '../components';
import { Window } from '../layouts';

const DAMAGE_LOCALIZATION_MAP = new Map([
  ['upper body', 'Грудь'],
  ['lower body', 'Живот'],
  ['head', 'Голова'],
  ['left arm', 'Левая рука'],
  ['right arm', 'Правая рука'],
  ['left leg', 'Левая нога'],
  ['right leg', 'Правая нога'],
  ['left foot', 'Левая ступня'],
  ['right foot', 'Правая ступня'],
  ['left hand', 'Левая кисть'],
  ['right hand', 'Правая кисть'],
  ['monkey tail', 'Хвост обезьяны'],
  ['wolpin tail', 'Хвост вульпина'],
  ['unathi tail', 'Хвост унатха'],
  ['tajaran tail', 'Хвост таярана'],
  ['vulpkanin tail', 'Хвост вульпканина'],
  ['vox tail', 'Хвост вокса'],
  ['wryn tail', 'Хвост врина'],
  ['luam wings', 'Крылья луам'],
]);

const BLOOD_TYPE_MAP = new Map([
  ['Diona', 'Диона'],
  ['Human', 'Человек'],
  ['Drask', 'Драск'],
  ['Grey', 'Грей'],
  ['Vulpkanin', 'Вульпакин'],
  ['Tajaran', 'Таяран'],
  ['Skrell', 'Скрелл'],
  ['Nian', 'Ниан'],
  ['Unathi', 'Унатх'],
  ['Kidan', 'Кидан'],
  ['Wryn', 'Врин'],
  ['Vox', 'Вокс'],
]);

type HealthanalyzerData = {
  scan_data: ScanData;
  scan_title: string;
  theme: string;
  advanced: boolean;
  localize: boolean;
};

type ScanData = {
  status: string | number;
  damageLevels: DamageLevels;
  health: number;
  DRN: boolean;
  timeofdeath: string;
  bodyTemperatureC: number;
  bodyTemperatureF: number;
  pulse: number;
  pulse_status: number;
  bloodData: BloodData;
  genes: number;
  timetodefib: number;
  timetodefibText: string;
  heartCondition: string;
  damageLocalization: DamageLocalization[];
  fractureList: string[];
  infectedList: string[];
  extraFacture: boolean;
  extraBleeding: boolean;
  insuranceType: string;
  reqInsurance: number;
  insurance: number;
  brainDamage: number | string;
  bleed: boolean;
  staminaStatus: boolean;
  cloneStatus: number;
  brainWorms: boolean;
  diseases: Disease[];
  reagentList: Reagent[];
  addictionList: Addiction[];
  implantDetect: string[];
};

type DamageLocalization = {
  name: string;
  burn: number;
  brute: number;
};

type DamageLevels = {
  oxy: number;
  tox: number;
  burn: number;
  brute: number;
};

type BloodData = {
  blood_volume: number;
  blood_percent: number;
  blood_type: string;
  blood_species: string;
};

type Disease = {
  name: string;
  form: string;
  stage: number;
  max_stages: number;
  additional_info: string;
  cure_text: string;
};

type Reagent = {
  name: string;
  volume: number;
  overdosed: boolean;
};

type Addiction = {
  name: string;
  addiction_stage: number;
};

const DEAD_STATUS = 2;

export const Healthanalyzer = (props: unknown) => {
  const { data } = useBackend<HealthanalyzerData>();
  const { scan_data } = data;

  return (
    <Window
      width={500}
      height={450}
      theme={data.theme || ''}
      title={data.scan_title || 'Анализатор здоровья'}
    >
      <Window.Content scrollable>
        {renderContent(data, scan_data)}
      </Window.Content>
    </Window>
  );
};

const renderContent = (data: HealthanalyzerData, scan_data?: ScanData) => {
  if (!scan_data) {
    return (
      <Box textAlign="center" bold>
        Память анализатора здоровья успешно очищена
      </Box>
    );
  }

  if (scan_data.status === 'ERROR' || scan_data.status === 'FLOOR') {
    return <ScanErrorView />;
  }

  return <ScanResultView data={data} scan_data={scan_data} />;
};

const ScanErrorView = () => (
  <Box>
    <Section title="Повреждения">
      <LabeledList>
        <DamageTypeDisplay />
        <DamageLevelDisplay values={null} />
      </LabeledList>
    </Section>

    <Section title="Общее состояние">
      <LabeledList>
        <LabeledList.Item label="Оценка здоровья">
          <Box color="#c51e1e" bold>
            ОШИБКА
          </Box>
        </LabeledList.Item>
        <LabeledList.Item label="Температура тела">
          --- °C --- °F
        </LabeledList.Item>
        <LabeledList.Item label="Уровень крови">
          --- %, --- u, тип: ---, кровь расы: ---
        </LabeledList.Item>
        <LabeledList.Item label="Пульс">--- уд/мин</LabeledList.Item>
        <LabeledList.Item label="Гены">
          Генная структура не обнаружена
        </LabeledList.Item>
      </LabeledList>
    </Section>
  </Box>
);

const ScanResultView = ({
  data,
  scan_data,
}: {
  data: HealthanalyzerData;
  scan_data: ScanData;
}) => (
  <Box>
    <TopButtons />

    <Section title="Повреждения">
      <LabeledList>
        <DamageTypeDisplay />
        <DamageLevelDisplay values={scan_data.damageLevels} />
      </LabeledList>
    </Section>

    <StatusSection scan_data={scan_data} />

    {scan_data.status === DEAD_STATUS && (
      <DeathInfoSection scan_data={scan_data} />
    )}

    {scan_data.heartCondition === 'CRIT' && <HeartCriticalSection />}

    <DamageLocalizationSection scan_data={scan_data} localize={data.localize} />

    {scan_data.reagentList?.length > 0 && (
      <ReagentList reagents={scan_data.reagentList} />
    )}
    {scan_data.diseases?.length > 0 && (
      <DiseasesList diseases={scan_data.diseases} />
    )}
    {scan_data.addictionList?.length > 0 && (
      <AddictionList addictions={scan_data.addictionList} />
    )}
    {scan_data.implantDetect?.length > 0 && (
      <ImplantList implants={scan_data.implantDetect} />
    )}

    <InsuranceSection scan_data={scan_data} />
  </Box>
);

const DamageTypeDisplay = () => (
  <LabeledList.Item label="Тип повреждений">
    <Box>
      <span style={{ color: '#0080ff' }}>Удушье</span> /{' '}
      <span style={{ color: 'green' }}>Отравление</span> /{' '}
      <span style={{ color: '#FF8000' }}>Терм.</span> /{' '}
      <span style={{ color: 'red' }}>Мех.</span>
    </Box>
  </LabeledList.Item>
);

const DamageLevelDisplay = ({ values }: { values: DamageLevels | null }) => {
  const renderDamageValue = (type: keyof DamageLevels, color: string) => {
    if (!values) return <span style={{ color }}>?</span>;

    const value = values[type];
    if (value === 0) return null;

    return value > 0 ? (
      <span style={{ color, fontWeight: 'bold' }}>{value}</span>
    ) : (
      <span style={{ color }}>{value}</span>
    );
  };

  const hasOxy = values && values.oxy !== 0;
  const hasTox = values && values.tox !== 0;
  const hasBurn = values && values.burn !== 0;
  const hasBrute = values && values.brute !== 0;

  const elements = [];
  if (hasOxy) elements.push(renderDamageValue('oxy', '#0080ff'));
  if (hasTox) {
    if (elements.length > 0) elements.push(' - ');
    elements.push(renderDamageValue('tox', 'green'));
  }
  if (hasBurn) {
    if (elements.length > 0) elements.push(' - ');
    elements.push(renderDamageValue('burn', '#FF8000'));
  }
  if (hasBrute) {
    if (elements.length > 0) elements.push(' - ');
    elements.push(renderDamageValue('brute', 'red'));
  }

  if (elements.length === 0 && values) {
    return (
      <LabeledList.Item label="Степень повреждений">
        <Box color="green">Нет повреждений</Box>
      </LabeledList.Item>
    );
  }

  return (
    <LabeledList.Item label="Степень повреждений">
      <Box>{elements}</Box>
    </LabeledList.Item>
  );
};

const StatusSection = ({ scan_data }: { scan_data: ScanData }) => (
  <Section title="Состояние">
    <LabeledList>
      <HealthStatusItem scan_data={scan_data} />

      {scan_data.status === DEAD_STATUS && (
        <LabeledList.Item label="Время смерти">
          {scan_data.timeofdeath}
        </LabeledList.Item>
      )}

      <LabeledList.Item label="Температура тела">
        {scan_data.bodyTemperatureC} °C ({scan_data.bodyTemperatureF} °F)
      </LabeledList.Item>

      {scan_data.bloodData && <BloodDataItem bloodData={scan_data.bloodData} />}

      <PulseItem pulse={scan_data.pulse} status={scan_data.pulse_status} />
      <GenesItem genes={scan_data.genes} />
    </LabeledList>

    <StatusInfo scan_data={scan_data} />
  </Section>
);

const HealthStatusItem = ({ scan_data }: { scan_data: ScanData }) => {
  if (scan_data.status === DEAD_STATUS) {
    return (
      <LabeledList.Item label="Статус">
        <Box color="red" bold>
          Смерть{' '}
          {!!scan_data.DRN && <span style={{ fontWeight: 'bold' }}>[НР]</span>}
        </Box>
      </LabeledList.Item>
    );
  }

  return (
    <LabeledList.Item label="Статус">
      {scan_data.health > 0 ? (
        <Box>{scan_data.health}%</Box>
      ) : (
        <Box color="red" bold>
          {scan_data.health}%
        </Box>
      )}
    </LabeledList.Item>
  );
};

const BloodDataItem = ({ bloodData }: { bloodData: BloodData }) => {
  let bloodStatus = null;
  if (bloodData.blood_volume <= 501 && bloodData.blood_volume > 346) {
    bloodStatus = (
      <Box as="span" style={{ color: 'red', fontWeight: 'bold' }}>
        НИЗКИЙ{' '}
      </Box>
    );
  } else if (bloodData.blood_volume <= 346) {
    bloodStatus = (
      <Box as="span" style={{ color: 'red', fontWeight: 'bold' }}>
        КРИТИЧЕСКИЙ{' '}
      </Box>
    );
  }

  const parts = [
    `${bloodData.blood_percent} %`,
    `${bloodData.blood_volume} u`,
    `тип: ${bloodData.blood_type}`,
  ];

  if (bloodData.blood_species && bloodData.blood_species.trim() !== '') {
    const speciesName =
      BLOOD_TYPE_MAP.get(bloodData.blood_species) || bloodData.blood_species;
    parts.push(`кровь расы: ${speciesName}`);
  }

  return (
    <LabeledList.Item label="Уровень крови">
      {bloodStatus}
      {parts.join(', ')}.
    </LabeledList.Item>
  );
};

const PulseItem = ({ pulse, status }: { pulse: number; status: number }) => (
  <LabeledList.Item label="Пульс">
    <Box as="span" style={{ color: status === 2 ? '#0080ff' : 'red' }}>
      {pulse} уд/мин
    </Box>
  </LabeledList.Item>
);

const GenesItem = ({ genes }: { genes: number }) => {
  if (genes < 40) {
    return (
      <LabeledList.Item label="Гены">
        <Box color="red" bold>
          Критическая генная нестабильность.
        </Box>
      </LabeledList.Item>
    );
  }
  if (genes < 70) {
    return (
      <LabeledList.Item label="Гены">
        <Box color="red" bold>
          Тяжёлая генная нестабильность.
        </Box>
      </LabeledList.Item>
    );
  }
  if (genes < 85) {
    return (
      <LabeledList.Item label="Гены">
        <Box color="red">Незначительная генная нестабильность.</Box>
      </LabeledList.Item>
    );
  }
  return (
    <LabeledList.Item label="Гены">
      <Box>Генная структура стабильна.</Box>
    </LabeledList.Item>
  );
};

const DeathInfoSection = ({ scan_data }: { scan_data: ScanData }) => (
  <Section>
    <Box textAlign="center" bold color="red">
      Субъект умер {scan_data.timetodefib} назад
    </Box>
    <Box textAlign="center" bold color="red">
      {scan_data.timetodefibText}
    </Box>
  </Section>
);

const HeartCriticalSection = () => (
  <Section title="Внимание: Критическое состояние!" mt={2} mb={2} color="red">
    <LabeledList>
      <LabeledList.Item label="Название">
        <Box bold>Остановка сердца</Box>
      </LabeledList.Item>
      <LabeledList.Item label="Тип">
        <Box bold>Сердце пациента остановилось</Box>
      </LabeledList.Item>
      <LabeledList.Item label="Стадия">
        <Box bold>1/1</Box>
      </LabeledList.Item>
      <LabeledList.Item label="Лечение">
        <Box bold>Электрический шок</Box>
      </LabeledList.Item>
    </LabeledList>
  </Section>
);

const DamageLocalizationSection = ({
  scan_data,
  localize,
}: {
  scan_data: ScanData;
  localize: boolean;
}) => {
  const hasDamageInfo =
    (scan_data.damageLocalization?.length ?? 0) > 0 ||
    (scan_data.fractureList?.length ?? 0) > 0 ||
    (scan_data.infectedList?.length ?? 0) > 0 ||
    scan_data.extraFacture ||
    scan_data.extraBleeding;

  if (!hasDamageInfo) return null;

  if (localize) {
    return (
      <Section title="Локализация повреждений">
        {(scan_data.damageLocalization?.length ?? 0) > 0 && (
          <LocalizedDamageList
            damageList={scan_data.damageLocalization || []}
          />
        )}
        <FractureList fractures={scan_data.fractureList || []} />
        <InfectionList infections={scan_data.infectedList || []} />
        {scan_data.extraFacture && (
          <Box color="#c51e1e" mt={1}>
            Обнаружены переломы. Локализация невозможна.
          </Box>
        )}
        {scan_data.extraBleeding && (
          <Box color="#c51e1e" mt={1}>
            Обнаружено внутреннее кровотечение. Локализация невозможна.
          </Box>
        )}
      </Section>
    );
  }

  return (
    <Section title="Дополнительная информация">
      <FractureList fractures={scan_data.fractureList || []} />
      <InfectionList infections={scan_data.infectedList || []} />
      {scan_data.extraFacture && (
        <Box color="#c51e1e" mt={1}>
          Обнаружены переломы. Требуется подробное сканирование.
        </Box>
      )}
      {scan_data.extraBleeding && (
        <Box color="#c51e1e" mt={1}>
          Обнаружено внутреннее кровотечение. Локализация невозможна.
        </Box>
      )}
    </Section>
  );
};

const LocalizedDamageList = ({
  damageList,
}: {
  damageList: DamageLocalization[];
}) => (
  <LabeledList>
    {damageList.map((local, index) => (
      <LabeledList.Item
        key={index}
        label={DAMAGE_LOCALIZATION_MAP.get(local.name) || local.name}
      >
        <Box>
          <Box as="span" style={{ color: '#FF8000' }}>
            {local.burn}
          </Box>
          {' - '}
          <Box as="span" style={{ color: 'red' }}>
            {local.brute}
          </Box>
        </Box>
      </LabeledList.Item>
    ))}
  </LabeledList>
);

const FractureList = ({ fractures }: { fractures: string[] }) => {
  if (fractures.length === 0) return null;

  return (
    <Box>
      {fractures.map((fracture, index) => (
        <Box key={index} color="#c51e1e" mt={1}>
          {DAMAGE_LOCALIZATION_MAP.get(fracture) || fracture} – обнаружен
          перелом!
        </Box>
      ))}
    </Box>
  );
};

const InfectionList = ({ infections }: { infections: string[] }) => {
  if (infections.length === 0) return null;

  return (
    <Box>
      {infections.map((infection, index) => (
        <Box key={index} color="#c51e1e" mt={1}>
          Обнаружено заражение в {infection}.
        </Box>
      ))}
    </Box>
  );
};

const InsuranceSection = ({ scan_data }: { scan_data: ScanData }) => (
  <Section title="Страховка">
    <LabeledList>
      <LabeledList.Item label="Тип страховки">
        {scan_data.insuranceType}
      </LabeledList.Item>
      <LabeledList.Item label="Требуемое количество очков страховки">
        {scan_data.reqInsurance}
      </LabeledList.Item>
      {scan_data.insurance !== undefined && (
        <LabeledList.Item label="Текущее количество очков страховки">
          {scan_data.insurance}
        </LabeledList.Item>
      )}
    </LabeledList>
  </Section>
);

const TopButtons = (props: unknown) => {
  const { act, data } = useBackend<HealthanalyzerData>();

  return (
    <Section textAlign="center">
      <Box nowrap>
        <Button icon="trash" onClick={() => act('clear')}>
          Очистить
        </Button>
        <Button
          icon="map-marker-alt"
          onClick={() => act('localize')}
          selected={data.localize}
        >
          Локализация
        </Button>
        {data.advanced && (
          <>
            <Button icon="print" onClick={() => act('print')}>
              Печать отчёта
            </Button>
            <Button icon="file-invoice-dollar" onClick={() => act('insurance')}>
              Списать страховку
            </Button>
          </>
        )}
      </Box>
    </Section>
  );
};

/** Компонент с дополнительной информацией о состоянии */
const StatusInfo = ({ scan_data }: { scan_data: ScanData }) => {
  const {
    heartCondition,
    brainDamage,
    bleed,
    staminaStatus,
    cloneStatus,
    brainWorms,
  } = scan_data;

  return (
    <Box>
      {heartCondition === 'LESS' && (
        <Box color="#d82020" mt={1} bold>
          Сердце не обнаружено.
        </Box>
      )}
      {heartCondition === 'NECROSIS' && (
        <Box color="#d82020" mt={1} bold>
          Обнаружен некроз сердца.
        </Box>
      )}

      {brainDamage === 'LESS' ? (
        <Box color="#c51e1e" mt={1} bold>
          Мозг не обнаружен.
        </Box>
      ) : (
        typeof brainDamage === 'number' && (
          <>
            {brainDamage > 100 && (
              <Box color="#c51e1e" mt={1} bold>
                Мозг мёртв
              </Box>
            )}
            {brainDamage > 60 && brainDamage <= 100 && (
              <Box color="#c51e1e" mt={1} bold>
                Обнаружено серьёзное повреждение мозга.
              </Box>
            )}
            {brainDamage > 10 && brainDamage <= 60 && (
              <Box color="#c51e1e" mt={1}>
                Обнаружено значительное повреждение мозга.
              </Box>
            )}
          </>
        )
      )}

      {bleed && (
        <Box color="#c51e1e" mt={1} bold>
          Обнаружено кровотечение!
        </Box>
      )}

      {staminaStatus && (
        <Box color="#0080ff" mt={1} bold>
          Обнаружено истощение.
        </Box>
      )}

      {cloneStatus > 30 ? (
        <Box color="#c51e1e" mt={1} bold>
          Обнаружено серьёзное клеточное повреждение!
        </Box>
      ) : (
        cloneStatus > 0 && (
          <Box color="#c51e1e" mt={1}>
            Обнаружено незначительное клеточное повреждение.
          </Box>
        )
      )}

      {brainWorms && (
        <Box color="#c51e1e" mt={1} bold>
          Обнаружены отклонения в работе мозга.
        </Box>
      )}
    </Box>
  );
};

/** Список болезней */
const DiseasesList = ({ diseases }: { diseases: Disease[] }) => (
  <Box>
    {diseases.map((disease, index) => (
      <Section
        key={index}
        title={'Внимание: ' + disease.form}
        mt={2}
        mb={2}
        color="red"
      >
        <LabeledList>
          <LabeledList.Item label="Название">
            <Box bold>{disease.name}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Тип">
            <Box bold>{disease.additional_info}</Box>
          </LabeledList.Item>
          <LabeledList.Item label="Стадия">
            <Box bold>
              {disease.stage}/{disease.max_stages}
            </Box>
          </LabeledList.Item>
          <LabeledList.Item label="Лечение">
            <Box bold>{disease.cure_text}</Box>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    ))}
  </Box>
);

/** Список реагентов */
const ReagentList = ({ reagents }: { reagents: Reagent[] }) => (
  <Section title="Обнаружены вещества">
    <LabeledList>
      {reagents.map((reagent, index) => (
        <LabeledList.Item key={index} label={reagent.name}>
          <Box>
            {reagent.volume} ед.
            {reagent.overdosed && (
              <Box as="span" color="red" bold>
                {' '}
                - ПЕРЕДОЗИРОВКА!
              </Box>
            )}
          </Box>
        </LabeledList.Item>
      ))}
    </LabeledList>
  </Section>
);

/** Список зависимостей */
const AddictionList = ({ addictions }: { addictions: Addiction[] }) => (
  <Section title="Обнаружены зависимости">
    <LabeledList>
      {addictions.map((addiction, index) => (
        <LabeledList.Item key={index} label={addiction.name}>
          Стадия: {addiction.addiction_stage}/5
        </LabeledList.Item>
      ))}
    </LabeledList>
  </Section>
);

/** Список имплантов */
const ImplantList = ({ implants }: { implants: string[] }) => (
  <Section title="Обнаружены кибернетические модификации:">
    {implants.map((implant, index) => (
      <Box key={index} ml={1} bold>
        {implant}
      </Box>
    ))}
  </Section>
);
