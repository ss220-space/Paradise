// UI states, which are mirrored from the BYOND code.
export const UI_INTERACTIVE = 2;
export const UI_UPDATE = 1;
export const UI_DISABLED = 0;
export const UI_CLOSE = -1;

type Gas = {
  id: string;
  name: string;
  label: string;
  color: string;
};

// All game related colors are stored here
export const COLORS = {
  // Department colors
  department: {
    command: '#526aff',
    security: '#CF0000',
    medical: '#009190',
    science: '#993399',
    engineering: '#A66300',
    supply: '#9F8545',
    service: '#80A000',
    centcom: '#78789B',
    procedure: '#E3027A',
    other: '#C38312',
  },
  // Damage type colors
  damageType: {
    oxy: '#3498db',
    toxin: '#2ecc71',
    burn: '#e67e22',
    brute: '#e74c3c',
  },
} as const;

// Colors defined in CSS
export const CSS_COLORS = [
  'black',
  'white',
  'red',
  'orange',
  'yellow',
  'olive',
  'green',
  'teal',
  'blue',
  'violet',
  'purple',
  'pink',
  'brown',
  'grey',
  'good',
  'average',
  'bad',
  'label',
];

export type Channel = {
  name: string;
  freq: number;
  color: string;
};

export const RADIO_CHANNELS: Channel[] = [
  {
    name: 'Синдикат',
    freq: 1213,
    color: '#a52a2a',
  },
  {
    name: 'ДОС',
    freq: 1244,
    color: '#a52a2a',
  },
  {
    name: 'Красная команда',
    freq: 1215,
    color: '#ff4444',
  },
  {
    name: 'Синяя команда',
    freq: 1217,
    color: '#3434fd',
  },
  {
    name: 'ОБР',
    freq: 1345,
    color: '#2681a5',
  },
  {
    name: 'ССО',
    freq: 1341,
    color: '#2681a5',
  },
  {
    name: 'Снабжение',
    freq: 1347,
    color: '#b88646',
  },
  {
    name: 'Обслуживание',
    freq: 1349,
    color: '#6ca729',
  },
  {
    name: 'Наука',
    freq: 1351,
    color: '#c68cfa',
  },
  {
    name: 'Командование',
    freq: 1353,
    color: '#5177ff',
  },
  {
    name: 'Юриспруденция',
    freq: 1339,
    color: '#F70285',
  },
  {
    name: 'Медицина',
    freq: 1355,
    color: '#57b8f0',
  },
  {
    name: 'Медицина (ИТК)',
    freq: 1485,
    color: '#57b8f0',
  },
  {
    name: 'Инженерия',
    freq: 1357,
    color: '#f37746',
  },
  {
    name: 'Безопасность',
    freq: 1359,
    color: '#dd3535',
  },
  {
    name: 'Заключенные',
    freq: 1361,
    color: '#ff831a',
  },
  {
    name: 'Безопасность (ИТК)',
    freq: 1475,
    color: '#dd3535',
  },
  {
    name: 'ИИ',
    freq: 1343,
    color: '#d65d95',
  },
  {
    name: 'Общий',
    freq: 1459,
    color: '#1ecc43',
  },
  {
    name: 'СиндиТайпан',
    freq: 1227,
    color: '#ffec8b',
  },
  {
    name: 'СССП',
    freq: 1217,
    color: '#ffec8b',
  },
  {
    name: 'Клан Паука',
    freq: 1265,
    color: '#1ecc43',
  },
  {
    name: 'Альфа частота',
    freq: 1522,
    color: '#88910f',
  },
  {
    name: 'Бета частота',
    freq: 1532,
    color: '#1d83f7',
  },
  {
    name: 'Гамма частота',
    freq: 1542,
    color: '#d46549',
  },
  {
    name: 'Жучок',
    freq: 1251,
    color: '#776f96',
  },
] as const;

export const GASES = [
  {
    id: 'o2',
    name: 'Oxygen',
    label: 'O₂',
    color: 'blue',
    tlv: 'oxygen',
    scrubFlag: 1 << 0,
  },
  {
    id: 'n2',
    name: 'Nitrogen',
    label: 'N₂',
    color: 'yellow',
    tlv: 'nitrogen',
    scrubFlag: 1 << 1,
  },
  {
    id: 'co2',
    name: 'Carbon Dioxide',
    label: 'CO₂',
    color: 'grey',
    tlv: 'carbon_dioxide',
    scrubFlag: 1 << 2,
  },
  {
    id: 'plasma',
    name: 'Plasma',
    label: 'Plasma',
    color: 'pink',
    tlv: 'plasma',
    scrubFlag: 1 << 3,
  },
  {
    id: 'water_vapor',
    name: 'Water Vapor',
    label: 'H₂O',
    color: 'lightsteelblue',
    tlv: 'water_vapor',
    scrubFlag: 1 << 6,
  },
  {
    id: 'hypernoblium',
    name: 'Hyper-noblium',
    label: 'Hyper-nob',
    color: 'teal',
    tlv: 'hypernoblium',
    scrubFlag: 1 << 19,
  },
  {
    id: 'n2o',
    name: 'Nitrous Oxide',
    label: 'N₂O',
    color: 'bisque',
    tlv: 'nitrous_oxide',
    scrubFlag: 1 << 4,
  },
  {
    id: 'tritium',
    name: 'Tritium',
    label: 'Tritium',
    color: 'limegreen',
    tlv: 'tritium',
    scrubFlag: 1 << 7,
  },
  {
    id: 'bz',
    name: 'BZ',
    label: 'BZ',
    color: 'mediumpurple',
    tlv: 'bz',
    scrubFlag: 1 << 8,
  },
  {
    id: 'pluoxium',
    name: 'Pluoxium',
    label: 'Pluoxium',
    color: 'mediumslateblue',
    tlv: 'pluoxium',
    scrubFlag: 1 << 9,
  },
  {
    id: 'miasma',
    name: 'Miasma',
    label: 'Miasma',
    color: 'olive',
    tlv: 'miasma',
    scrubFlag: 1 << 10,
  },
  {
    id: 'freon',
    name: 'Freon',
    label: 'Freon',
    color: 'paleturquoise',
    tlv: 'freon',
    scrubFlag: 1 << 11,
  },
  {
    id: 'hydrogen',
    name: 'Hydrogen',
    label: 'H₂',
    color: 'white',
    tlv: 'hydrogen',
    scrubFlag: 1 << 5,
  },
  {
    id: 'healium',
    name: 'Healium',
    label: 'Healium',
    color: 'salmon',
    tlv: 'healium',
    scrubFlag: 1 << 13,
  },
  {
    id: 'proto_nitrate',
    name: 'Proto Nitrate',
    label: 'Proto-Nitrate',
    color: 'greenyellow',
    tlv: 'proto_nitrate',
    scrubFlag: 1 << 14,
  },
  {
    id: 'zauker',
    name: 'Zauker',
    label: 'Zauker',
    color: 'darkgreen',
    tlv: 'zauker',
    scrubFlag: 1 << 15,
  },
  {
    id: 'halon',
    name: 'Halon',
    label: 'Halon',
    color: 'purple',
    tlv: 'halon',
    scrubFlag: 1 << 16,
  },
  {
    id: 'helium',
    name: 'Helium',
    label: 'He',
    color: 'aliceblue',
    tlv: 'helium',
    scrubFlag: 1 << 17,
  },
  {
    id: 'antinoblium',
    name: 'Antinoblium',
    label: 'Anti-Noblium',
    color: 'maroon',
    tlv: 'antinoblium',
    scrubFlag: 1 << 18,
  },
  {
    id: 'nitrium',
    name: 'Nitrium',
    label: 'Nitrium',
    color: 'brown',
    tlv: 'nitrium',
    scrubFlag: 1 << 12,
  },
  {
    id: 'ab',
    name: 'Agent B',
    label: 'Agent B',
    color: 'purple',
    tlv: 'agent_b',
    scrubFlag: 0,
  },
] as const;

// Returns gas label based on gasId
export const getGasLabel = (gasId: string, fallbackValue?: string) => {
  const gasSearchString = gasId.toLowerCase();
  const gas = GASES.find(
    (gas) =>
      gas.tlv === gasSearchString || gas.name.toLowerCase() === gasSearchString
  );
  return gas?.label || fallbackValue || gasId;
};

// Returns gas color based on gasId
export const getGasColor = (gasId: string) => {
  const gasSearchString = gasId.toLowerCase();
  const gas = GASES.find(
    (gas) =>
      gas.tlv === gasSearchString || gas.name.toLowerCase() === gasSearchString
  );
  return gas?.color;
};

// Returns gas object based on gasId
export const getGasFromId = (gasId: string): Gas | undefined => {
  const gasSearchString = gasId.toLowerCase();
  const gas = GASES.find(
    (gas) =>
      gas.id === gasSearchString || gas.name.toLowerCase() === gasSearchString
  );
  return gas;
};

export const timeAgo = (ref_time: number, now_time: number) => {
  if (ref_time > now_time) {
    return 'in the future';
  }

  // deciseconds -> seconds
  ref_time = ref_time / 10;
  now_time = now_time / 10;

  const diff = now_time - ref_time;
  if (diff > 3600) {
    const hours = Math.round(diff / 3600);
    return hours + ' hour' + (hours === 1 ? '' : 's') + ' ago';
  } else if (diff > 60) {
    const mins = Math.round(diff / 60);
    return mins + ' minute' + (mins === 1 ? '' : 's') + ' ago';
  } else {
    const secs = Math.round(diff);
    return secs + ' second' + (secs === 1 ? '' : 's') + ' ago';
  }

  return 'just now';
};

export const JOBS_RU = {
  'Assistant': 'Ассистент',
  'Civilian': 'Гражданский',
  'Prisoner': 'Заключённый',
  'Captain': 'Капитан',
  'Head of Personnel': 'Глава персонала',
  'Head of Security': 'Глава Службы Безопасности',
  'Research Director': 'Директор НИО',
  'Chief Engineer': 'Главный инженер',
  'Chief Medical Officer': 'Главный врач',
  'Blueshield': 'Офицер "Синий щит"',
  'Magistrate': 'Магистрат',
  'Nanotrasen Representative': 'Представитель "Нанотрейзен"',
  'AI': 'Станционный ИИ',
  'Cyborg': 'Робот',
  'Personal AI': 'Персональный ИИ',
  'Warden': 'Смотритель',
  'Detective': 'Детектив',
  'Security Officer': 'Офицер',
  'Brig Physician': 'Бриг-медик',
  'Security Pod Pilot': 'Пилот СБ',
  'Station Engineer': 'Инженер',
  'Life Support Specialist': 'Атмосферный специалист',
  'Trainee Engineer': 'Инженер-стажёр',
  'Coroner': 'Патологоанатом',
  'Medical Doctor': 'Врач',
  'Paramedic': 'Парамедик',
  'Chemist': 'Химик',
  'Virologist': 'Вирусолог',
  'Psychiatrist': 'Психиатр',
  'Geneticist': 'Генетик',
  'Intern': 'Интерн',
  'Scientist': 'Учёный',
  'Roboticist': 'Робототехник',
  'Spacepod Technician': 'Челнок-инженер',
  'Student Scientist': 'Учёный-студент',
  'Quartermaster': 'Квартирмейстер',
  'Cargo Technician': 'Грузчик',
  'Shaft Miner': 'Шахтёр',
  'Mining Medic': 'Шахтёрский врач',
  'Explorer': 'Исследователь',
  'Bartender': 'Бармен',
  'Botanist': 'Ботаник',
  'Cook': 'Повар',
  'Chef': 'Шеф',
  'Janitor': 'Уборщик',
  'Clown': 'Клоун',
  'Mime': 'Мим',
  'Librarian': 'Библиотекарь',
  'Lawyer': 'Адвокат',
  'Chaplain': 'Священник',
  'Psychologist': 'Психолог',
};

export const DEPARTMENTS_RU = {
  'Command': 'Командование',
  'Legal': 'Юриспруденция',
  'Security': 'Безопасность',
  'Service': 'Обслуживание',
  'Cargo': 'Снабжение',
  'Science': 'Наука',
  'Medical': 'Медицина',
  'Silicon': 'Синтетики',
  'Engineering': 'Инженерия',
  'No Department': 'Без отдела',
  'Other': 'Другое',
};
