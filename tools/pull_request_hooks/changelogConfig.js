/**
 * A map of changelog phrases to meta-information.
 *
 * The first entry in the list is used in the changelog YML file as the key when
 * used, but other than that all entries are equivalent.
 *
 * placeholders - The default messages, if the changelog has this then we pretend it
 * doesn't exist.
 */
export const CHANGELOG_ENTRIES = [
	[
		['add', 'rscadd', 'adds'],
		{
			placeholders: [
				'Добавлены новые механики или изменения в игровом процессе.',
				'Добавлено что-то новое.',
			],
		},
	],

	[
		['bugfix', 'fix', 'fixes'],
		{
			placeholders: ['Исправлен какой-то баг.'],
		},
	],

	[
		['del', 'rscdel', 'dels'],
		{
			placeholders: ['Удалено что-то старое.'],
		},
	],

	[
		['qol'],
		{
			placeholders: ['Сделано что-то более простым в использовании.'],
		},
	],

	[
		['sound', 'soundadd', 'sounddel'],
		{
			placeholders: [
				'Добавлены/изменены/удалены какие-то аудио или звуковые эффекты.',
			],
		},
	],

	[
		['tgs'],
		{
			placeholders: ['Изменения, связанные с TGS.'],
		},
	],

	[
		['image', 'imageadd', 'imagedel'],
		{
			placeholders: [
				'Добавлены/изменены/удалены какие-то спрайты или изображения.',
			],
		},
	],

	[
		['map', 'mapping'],
		{
			placeholders: [
				'Добавлены/изменены/удалены какие-то карты или их содержимое.',
			],
		},
	],

	[
		['spellcheck', 'typo'],
		{
			placeholders: ['Исправлена какая-то очепятка.'],
		},
	],

	[
		['local'],
		{
			placeholders: ['Произошла локализация на русский язык.'],
		},
	],

	[
		['balance'],
		{
			placeholders: ['Произошёл ребаланс.'],
		},
	],

	[
		['expansion'],
		{
			placeholders: ['Крупное расширение существующего контента.'],
		},
	],

	[
		['code_imp', 'code'],
		{
			placeholders: [
				'Что-то добавлено в код, без изменения имеющихся механик.',
			],
		},
	],

	[
		['refactor'],
		{
			placeholders: ['Отрефакторен какой-то код.'],
		},
	],

	[
		['config'],
		{
			placeholders: ['Изменены какие-то настройки в конфиге.'],
		},
	],

	[
		['admin'],
		{
			placeholders: ['Изменено что-то связанное с администрацией.'],
		},
	],

	[
		['tweak'],
		{
			placeholders: [
				'Незначительно изменены или настроены существующие механики.',
			],
		},
	],

	[
		['experiment', 'experimental'],
		{
			placeholders: [
				'Экспериментальные изменения, которые могут повлиять на стабильность.',
			],
		},
	],

	[
		['server'],
		{
			placeholders: [
				'Изменено что-то связанное с серверной частью или Github.',
			],
		},
	],
];

// Valid changelog openers
export const CHANGELOG_OPEN_TAGS = [':cl:', '??'];

// Valid changelog closers
export const CHANGELOG_CLOSE_TAGS = ['/:cl:', '/ :cl:', ':/cl:', '/??', '/ ??'];

// Placeholder value for an author
export const CHANGELOG_AUTHOR_PLACEHOLDER_NAME = 'необязательное имя здесь';
