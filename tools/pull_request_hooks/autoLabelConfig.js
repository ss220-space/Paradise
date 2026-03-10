/**
 * File Labels
 *
 * Add a label based on if a file is modified in the diff
 *
 * You can optionally set add_only to make the label one-way -
 * if the edit to the file is removed in a later commit,
 * the label will not be removed
 */
export const file_labels = {
	':octopus: GitHub': {
		filepaths: ['.github/'],
	},
	':cd: SQL': {
		filepaths: ['SQL/'],
	},
	':crab: Rust': {
		filepaths: ['rust/'],
	},
	':world_map: Изменение карты': {
		filepaths: ['_maps/'],
		file_extensions: ['.dmm'],
	},
	':hammer_and_wrench: Инструменты': {
		filepaths: ['tools/', '.vscode/', '.bin/', '.gemini/'],
	},
	':gear: Изменение конфига': {
		filepaths: ['config/', 'code/controllers/configuration/entries/'],
		add_only: true,
	},
	':art: Спрайты': {
		filepaths: ['icons/'],
		file_extensions: ['.dmi'],
		add_only: true,
	},
	':sound: Звук': {
		filepaths: ['sound/'],
		file_extensions: ['.ogg'],
		add_only: true,
	},
	':computer: TGUI': {
		filepaths: ['tgui/'],
		add_only: true,
	},
	':book: Документация': {
		file_extensions: ['.md'],
	},
};

/**
 * Title Labels
 *
 * Add a label based on keywords in the title
 */
export const title_labels = {
	//  Logging: {
	//    keywords: ["log", "logging"],
	//  },
	'Removal': {
		keywords: ['remove', 'delete', 'удалет', 'удалил'],
	},
	'Refactor': {
		keywords: ['refactor', 'рефактор'],
	},
	':scroll: Локализация': {
		keywords: ['local', 'локализация', 'перевод'],
	},
	//  "Unit Tests": {
	//    keywords: ["unit test"],
	//  },
	//  "April Fools": {
	//    keywords: ["[april fools]"],
	//  },
	':no_entry: Do Not Merge': {
		keywords: ['[dnm]', '[do not merge]'],
	},
	//  "GBP: No Update": {
	//    keywords: ["[no gbp]"],
	//  },
	':construction: Test Merge Only': {
		keywords: ['[tm only]', '[test merge only]'],
	},
};

/**
 * Changelog Labels
 *
 * Adds labels based on keywords in the changelog
 * TODO: use the existing changelog parser
 */
export const changelog_labels = {
	'Fix': {
		default_text: 'Исправлен какой-то баг.',
		keywords: ['fix', 'fixes', 'bugfix'],
	},
	'Quality of Life': {
		default_text: 'Сделалано что-то более простым в использовании.',
		keywords: ['qol', 'tweak'],
	},
	'Feature': {
		default_text: 'Добавлены новые механики или изменения в игровом процессе.',
		alt_default_text: 'Добавлено что-то новое.',
		keywords: ['add', 'adds', 'rscadd'],
	},
	'Removal': {
		default_text: 'Удалено что-то старое.',
		keywords: ['del', 'dels', 'rscdel'],
	},
	'Balance': {
		default_text: 'Произошёл ребаланс.',
		keywords: ['balance'],
	},
	'Code Improvement': {
		default_text: 'Изменён какой-то код.',
		keywords: ['code_imp', 'code'],
	},
	'Refactor': {
		default_text: 'Отрефакторен какой-то код.',
		keywords: ['refactor'],
	},
	'Administration': {
		default_text: 'Изменено что-то связанное с администрацией.',
		keywords: ['admin'],
	},
	':sound: Звук': {
		default_text:
			'Добавлены/изменены/удалены какие-то аудио или звуковые эффекты.',
		keywords: ['sound'],
	},
	':art: Спрайты': {
		default_text:
			'Добавлены/изменены/удалены какие-то спрайты или изображения.',
		keywords: ['image'],
	},
	':scroll: Локализация': {
		default_text: 'Исправлена какая-то очепятка.',
		keywords: ['typo', 'spellcheck', 'local'],
	},
	':gear: Изменение конфига': {
		default_text: 'Изменены какие-то настройки в конфиге.',
		keywords: ['config'],
	},
};
