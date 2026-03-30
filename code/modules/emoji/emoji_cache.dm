/**
 * # Emoji Cache
 * Чтобы добавить новое эмодзи:
 * 1. Добавьте иконку в icons\emoji.dmi (размер 48x48)
 * 2. Добавьте имя в список EMOJI_NAMES ниже (должно совпадать с icon_state)
 *
 * ## Использование:
 * ```dm
 * var/icon/emoji = emoji_cache_get_icon("roflcat", 32)
 * ```
 */

var/static/list/emoji_cache = list()

/**
 * Список имён эмодзи (триггер-слова)
 * Чтобы добавить эмодзи, впишите его имя в этот список
 */
var/static/list/EMOJI_NAMES = list(
	"1984",
	"clueless",
	"1head",
	"2head",
	"3head",
	"4head",
	"5head",
	"ache",
	"afacepalm",
	"aga",
	"alo",
	"arolf",
	"badguy",
	"bigkek",
	"keks",
	"blessrng",
	"catgigi",
	"catkerz",
	"catping",
	"catpong",
	"catrose",
	"cats",
	"catsmile",
	"4cb",
	"cemkaauf",
	"cemkae",
	"cemkashiza",
	"chad",
	"coolstorybob",
	"dogesmile",
	"shocked",
	"fearlul",
	"fuel",
	"gagaga",
	"hampter",
	"haveyouseenthiscat",
	"hss",
	"jokerge",
	"kekwat",
	"kotvshlyapi",
	"madge",
	"mericcat",
	"norm",
	"pizdez",
	"neodobryaem",
	"odobryaem",
	"peepo",
	"pepeangry",
	"pepepoint",
	"pepechad",
	"pepechill",
	"angryclown",
	"pepecoffe",
	"pepecoffe2",
	"pepecool",
	"pepecry",
	"pepedeal",
	"peepohug",
	"peepohug2",
	"pepekotya",
	"pepeok",
	"pepepizdec",
	"pepelist",
	"peperot",
	"pepesleep",
	"pepetoxic",
	"pepewut",
	"prayge",
	"ratge",
	"ratass",
	"ratgehat",
	"ratgesus",
	"sadge",
	"yepp",
	"paaa",
	"pog",
	"roflcat",
	"seemsgood",
	"shappy",
	"shlepa",
	"smilew",
	"smorch",
	"stoneface",
	"suki",
	"catahui",
	"goblin",
	"welder",
	"woo",
	"verymadge",
	"xmm",
	"mmx",
)

/**
 * Получить иконку эмодзи из кэша
 *
 * Arguments:
 * * emoji_name - имя эмодзи (например "roflcat")
 * * size - размер иконки в пикселях (по умолчанию: 32 для чата, 20 для runechat)
 *
 * Returns:
 * * icon - emoji, или null если emoji не найдено
 */
/proc/emoji_cache_get_icon(emoji_name, size = 32)
	if(!emoji_name)
		return null

	emoji_name = lowertext(emoji_name)
	var/cache_key = "[emoji_name]_[size]"
	var/icon/cached = emoji_cache[cache_key]

	if(cached)
		return cached

	cached = icon('icons/emoji.dmi', emoji_name)
	if(!cached)
		return null

	cached.Scale(size, size)
	emoji_cache[cache_key] = cached

	return cached

/**
 * Является ли слово триггер-словом эмодзи
 *
 * Arguments:
 * * word - слово для проверки
 *
 * Returns:
 * * TRUE если слово является триггером для эмодзи
 */
/proc/emoji_cache_is_emoji(word)
	if(!word)
		return FALSE

	return (lowertext(word) in EMOJI_NAMES)

/**
 * Получить список слов-триггеров эмодзи
 *
 * Returns:
 * * list - список слов-триггеров эмодзи
 */
/proc/emoji_cache_get_emoji_names()
	return EMOJI_NAMES

/**
 * Очистить кэш иконок (не влияет на список имён)
 */
/proc/emoji_cache_clear()
	emoji_cache.Cut()
