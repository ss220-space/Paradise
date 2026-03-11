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
		['rscadd', 'add', 'adds'],
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
		['rscdel', 'del', 'dels'],
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
		['sound'],
		{
			placeholders: [
				'Добавлены/изменены/удалены какие-то аудио или звуковые эффекты.',
			],
		},
	],

	[
		['image'],
		{
			placeholders: [
				'Добавлены/изменены/удалены какие-то спрайты или изображения.',
			],
		},
	],

	[
		['map'],
		{
			placeholders: [
				'Добавлены/изменены/удалены какие-то карты или их содержимое.',
			],
		},
	],

	[
		['spellcheck', 'typo', 'local'],
		{
			placeholders: [
				'Исправлена какая-то очепятка.',
				'Произошла локализация на русский язык.',
			],
		},
	],

	[
		['balance'],
		{
			placeholders: ['Произошёл ребаланс.'],
		},
	],

	[
		['code_imp', 'code'],
		{
			placeholders: ['Изменён какой-то код.'],
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
