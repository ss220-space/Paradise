import { Placement } from '@popperjs/core';

import { TabBay, TabDrop, TabPod } from './Tabs';
import { PodDelay, PodEffect } from './types';

export const POD_GREY = {
  color: 'grey',
} as const;

export const TABPAGES = [
  {
    title: 'Просмотр капсулы',
    component: TabPod,
  },
  {
    title: 'Просмотр ангара',
    component: TabBay,
  },
  {
    title: 'Просмотр места выгрузки.',
    component: TabDrop,
  },
] as const;

type Option = {
  title: string;
  key?: string;
  icon?: string;
};

export const REVERSE_OPTIONS: Option[] = [
  {
    title: 'Мобы',
    key: 'Mobs',
    icon: 'user',
  },
  {
    title: 'Не закреплённые\nОбъекты',
    key: 'Unanchored',
    icon: 'cube',
  },
  {
    title: 'Закреплённые\nОбъекты',
    key: 'Anchored',
    icon: 'anchor',
  },
  {
    title: 'Мехи',
    key: 'Mecha',
    icon: 'truck',
  },
];

export const DELAYS: PodDelay[] = [
  {
    title: 'Pre',
    tooltip: 'Время до прибытия капсулы на станцию',
  },
  {
    title: 'Fall',
    tooltip: 'Продолжительность анимации\n падения капсул',
  },
  {
    title: 'Open',
    tooltip: 'Время, необходимое капсуле для открытия после приземления',
  },
  {
    title: 'Exit',
    tooltip: 'Время до отлета капсулы\nпосле открытия',
  },
];

export const REV_DELAYS: PodDelay[] = [
  {
    title: 'Pre',
    tooltip: 'Время до появления капсулы над точкой высадки',
  },
  {
    title: 'Fall',
    tooltip: 'Продолжительность анимации\n падения капсул',
  },
  {
    title: 'Open',
    tooltip: 'Время, необходимое капсуле для открытия после приземления',
  },
  {
    title: 'Exit',
    tooltip: 'Время до отлета капсулы\nпосле открытия',
  },
];

export const SOUNDS = [
  {
    title: 'Fall',
    act: 'fallingSound',
    tooltip:
      'Воспроизводится, пока капсула падает, и заканчивается\nкогда капсула приземляется',
  },
  {
    title: 'Land',
    act: 'landingSound',
    tooltip: 'Воспроизводится после приземления капсулы',
  },
  {
    title: 'Open',
    act: 'openingSound',
    tooltip: 'Воспроизводится при открытии капсулы',
  },
  {
    title: 'Exit',
    act: 'leavingSound',
    tooltip: 'Воспроизводится, когда капсула улетает',
  },
];

export const BAYS = [
  { title: '1' },
  { title: '2' },
  { title: '3' },
  { title: '4' },
  { title: 'ЕРТ' },
] as const;

export const EFFECTS_LOAD: PodEffect[] = [
  {
    act: 'launchAll',
    choiceNumber: 0,
    icon: 'globe',
    selected: 'launchChoice',
    title: 'Запустить со всех турфов',
  },
  {
    act: 'launchOrdered',
    choiceNumber: 1,
    icon: 'sort-amount-down-alt',
    selected: 'launchChoice',
    title: 'Запустить с турфов по порядку',
  },
  {
    act: 'launchRandomTurf',
    choiceNumber: 2,
    icon: 'dice',
    selected: 'launchChoice',
    title: 'Выбрать рандомный турф',
  },
  {
    divider: true,
  },
  {
    act: 'launchWholeTurf',
    choiceNumber: 0,
    icon: 'expand',
    selected: 'launchRandomItem',
    title: 'Запустить все содержимое турфа',
  },
  {
    act: 'launchRandomItem',
    choiceNumber: 1,
    icon: 'dice',
    selected: 'launchRandomItem',
    title: 'Выбрать случайный объект',
  },
  {
    divider: true,
  },
  {
    act: 'launchClone',
    icon: 'clone',
    soloSelected: 'launchClone',
    title: 'Копировать объект',
  },
];

export const EFFECTS_NORMAL: PodEffect[] = [
  {
    act: 'effectTarget',
    icon: 'user-check',
    soloSelected: 'effectTarget',
    title: 'Особая цель',
  },
  {
    act: 'effectBluespace',
    choiceNumber: 0,
    icon: 'hand-paper',
    selected: 'effectBluespace',
    title: 'Капсула остается',
  },
  {
    act: 'effectStealth',
    icon: 'user-ninja',
    soloSelected: 'effectStealth',
    title: 'Скрытно',
  },
  {
    act: 'effectQuiet',
    icon: 'volume-mute',
    soloSelected: 'effectQuiet',
    title: 'Тихо',
  },
  {
    act: 'effectMissile',
    icon: 'rocket',
    soloSelected: 'effectMissile',
    title: 'Режим ракеты',
  },
  {
    act: 'effectBurst',
    icon: 'certificate',
    soloSelected: 'effectBurst',
    title: 'Запуск кластера',
  },
  {
    act: 'effectCircle',
    icon: 'ruler-combined',
    soloSelected: 'effectCircle',
    title: 'Любой угол спуска',
  },
  {
    act: 'effectAnnounce',
    choiceNumber: 0,
    icon: 'ghost',
    selected: 'effectAnnounce',
    title:
      'Нет оповещения призраков\n(если вы не хотите\nразвлекать скучающих призраков)',
  },
];

export const EFFECTS_HARM: PodEffect[] = [
  {
    act: 'explosionCustom',
    choiceNumber: 1,
    icon: 'bomb',
    selected: 'explosionChoice',
    title: 'Настраиваемый взрыв',
  },
  {
    act: 'explosionBus',
    choiceNumber: 2,
    icon: 'bomb',
    selected: 'explosionChoice',
    title: 'Админабуз-взрыв\nИ что они сделают, забанят тебя?',
  },
  {
    divider: true,
  },
  {
    act: 'damageCustom',
    choiceNumber: 1,
    icon: 'skull',
    selected: 'damageChoice',
    title: 'Настраиваемый урон',
  },
  {
    act: 'damageGib',
    choiceNumber: 2,
    icon: 'skull-crossbones',
    selected: 'damageChoice',
    title: 'Гиб',
  },
  {
    divider: true,
  },
  {
    act: 'effectShrapnel',
    details: true,
    icon: 'cloud-meatball',
    soloSelected: 'effectShrapnel',
    title: 'Облако снарядов',
  },
  {
    act: 'effectStun',
    icon: 'sun',
    soloSelected: 'effectStun',
    title: 'Стан',
  },
  {
    act: 'effectLimb',
    icon: 'socks',
    soloSelected: 'effectLimb',
    title: 'Потеря конечности',
  },
  {
    act: 'effectOrgans',
    icon: 'book-dead',
    soloSelected: 'effectOrgans',
    title: 'Разлет всех органов',
  },
];

type Effect = {
  list: typeof EFFECTS_LOAD | typeof EFFECTS_NORMAL | typeof EFFECTS_HARM;
  label: string;
  alt_label?: string;
  tooltipPosition: Placement;
};

export const EFFECTS_ALL: Effect[] = [
  {
    list: EFFECTS_LOAD,
    label: 'Загрузить из',
    alt_label: 'Загрузка',
    tooltipPosition: 'right',
  },
  {
    list: EFFECTS_NORMAL,
    label: 'Обычные Эффекты',
    tooltipPosition: 'bottom',
  },
  {
    list: EFFECTS_HARM,
    label: 'Вредные эффекты',
    tooltipPosition: 'bottom',
  },
];
