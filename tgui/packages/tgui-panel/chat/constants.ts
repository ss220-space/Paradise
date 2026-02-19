/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

export const MAX_VISIBLE_MESSAGES = 2500;
export const MAX_PERSISTED_MESSAGES = 1000;
export const MESSAGE_SAVE_INTERVAL = 10000;
export const MESSAGE_PRUNE_INTERVAL = 60000;
export const COMBINE_MAX_TIME_WINDOW = 5000;
export const COMBINE_MAX_MESSAGES = 5;
export const IMAGE_RETRY_DELAY = 250;
export const IMAGE_RETRY_LIMIT = 10;
export const IMAGE_RETRY_MESSAGE_AGE = 60000;

// Default message type
export const MESSAGE_TYPE_UNKNOWN = 'unknown';

// Internal message type
export const MESSAGE_TYPE_INTERNAL = 'internal';

// Must match the set of defines in code/__DEFINES/chat.dm
export const MESSAGE_TYPE_SYSTEM = 'system';
export const MESSAGE_TYPE_LOCALCHAT = 'localchat';
export const MESSAGE_TYPE_RADIO = 'radio';
export const MESSAGE_TYPE_INFO = 'info';
export const MESSAGE_TYPE_WARNING = 'warning';
export const MESSAGE_TYPE_DEADCHAT = 'deadchat';
export const MESSAGE_TYPE_OOC = 'ooc';
export const MESSAGE_TYPE_ADMINPM = 'adminpm';
export const MESSAGE_TYPE_MENTORPM = 'mentorpm';
export const MESSAGE_TYPE_COMBAT = 'combat';
export const MESSAGE_TYPE_ADMINCHAT = 'adminchat';
export const MESSAGE_TYPE_MENTORCHAT = 'mentorchat';
export const MESSAGE_TYPE_DEVCHAT = 'devchat';
export const MESSAGE_TYPE_EVENTCHAT = 'eventchat';
export const MESSAGE_TYPE_ADMINLOG = 'adminlog';
export const MESSAGE_TYPE_ATTACKLOG = 'attacklog';
export const MESSAGE_TYPE_DEBUG = 'debug';

// Metadata for each message type
export const MESSAGE_TYPES = [
  // Always-on types
  {
    type: MESSAGE_TYPE_SYSTEM,
    name: 'Системные сообщения',
    description: 'Сообщения от клиента. Всегда включено.',
    selector: '.boldannounceooc',
    important: true,
  },
  // Basic types
  {
    type: MESSAGE_TYPE_LOCALCHAT,
    name: 'Рядом',
    description: 'IC-сообщения от окружения персонажа (речь, эмоции и т.д.).',
    selector: '.say, .emote',
  },
  {
    type: MESSAGE_TYPE_RADIO,
    name: 'Радио',
    description: 'Сообщения по всем каналам радио-связи.',
    selector:
      '.alert, .syndradio, .centradio, .airadio, .entradio, .comradio, .secradio, .prisradio, .engradio, .medradio, .sciradio, .supradio, .srvradio, .expradio, .radio, .deptradio, .newscaster, .taipan, .sovradio, .spider_clan',
  },
  {
    type: MESSAGE_TYPE_INFO,
    name: 'Информация',
    description: 'Второстепенные сообщения от игры и объектов',
    selector: '.notice:not(.pm), .adminnotice, .sinister, .cult',
  },
  {
    type: MESSAGE_TYPE_WARNING,
    name: 'Предупреждения',
    description: 'Важные сообщения от игры и объектов',
    selector:
      '.warning:not(.pm), .critical, .userdanger, .italics, .boldannounceic, .boldwarning',
  },
  {
    type: MESSAGE_TYPE_DEADCHAT,
    name: 'Чат мёртвых',
    description: 'Все сообщения от призраков.',
    selector: '.deadsay',
  },
  {
    type: MESSAGE_TYPE_OOC,
    name: 'OOC',
    description: 'Все сообщения из OOC-чата.',
    selector: '.ooc, .adminooc, .interface',
  },
  {
    type: MESSAGE_TYPE_ADMINPM,
    name: 'Админ-ЛС',
    description: 'Общение с администрацией (adminhelp)',
    selector: '.adminpm, .adminhelp, .adminticket, .adminticketalt',
  },
  {
    type: MESSAGE_TYPE_MENTORPM,
    name: 'Ментор-ЛС',
    description: 'Общение с менторами (mentorhelp)',
    selector: '.mentorpm, .mentorhelp',
  },
  {
    type: MESSAGE_TYPE_COMBAT,
    name: 'Боевые сообщения',
    description: 'Удары, выстрелы и т.д.',
    selector: '.danger',
  },
  {
    type: MESSAGE_TYPE_UNKNOWN,
    name: 'Остальное',
    description:
      'Всё, что не было отсортировано по другим вкладкам. Всегда включено.',
  },
  // Admin stuff
  {
    type: MESSAGE_TYPE_ADMINCHAT,
    name: 'Админ-чат',
    description: 'ASAY сообщения',
    selector: '.admin_channel, .adminsay',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_MENTORCHAT,
    name: 'Ментор-чат',
    description: 'MSAY сообщения',
    selector: '.mentor_channel',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_DEVCHAT,
    name: 'Разраб-чат',
    description: 'DEVSAY сообщения',
    selector: '.dev_channel',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_ADMINLOG,
    name: 'Admin Log',
    description:
      'ADMIN LOG: Vasya the Pedalique has jumped to coordinates X, Y, Z',
    selector: '.log_message',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_ATTACKLOG,
    name: 'Attack Log',
    description: 'Vasya the Pedalique has shot Rob Uster',
    admin: true,
  },
  {
    type: MESSAGE_TYPE_DEBUG,
    name: 'Debug Log',
    description: 'DEBUG: SSPlanets subsystem Recover().',
    selector: '.pr_announce, .debug',
    admin: true,
  },
];
