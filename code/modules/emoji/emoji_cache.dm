/**
 * # Emoji Cache
 * Чтобы добавить новое эмодзи:
 * 1. Добавьте иконку в icons\emoji.dmi (размер 48x48)
 * 2. Добавьте слово-триггер в config\emojis.txt (должно совпадать с icon_state)
 *
 * ## Использование:
 * ```dm
 * var/icon/emoji = GLOB.emoji_cache.get_icon("roflcat", 32)
 * ```
 */
/datum/emoji_cache
	var/static/list/emoji_cache = list()

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
/datum/emoji_cache/proc/get_icon(emoji_name, size = 32)
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
/datum/emoji_cache/proc/is_emoji(word)
	var/list/emoji_names = get_emoji_names()
	return (lowertext(word) in emoji_names)

/**
 * Получить список слов-триггеров эмодзи из конфига
 *
 * Returns:
 * * list - список слов-триггеров эмодзи
 */
/datum/emoji_cache/proc/get_emoji_names()
	return CONFIG_GET(str_list/emoji)

/**
 * Очистить кэш
 */
/datum/emoji_cache/proc/clear_cache()
	emoji_cache.Cut()

/**
 * Очистить кэш при удалении datum для предотвращения утечки памяти
 */
/datum/emoji_cache/Destroy()
	emoji_cache.Cut()
	return ..()

GLOBAL_DATUM_INIT(emoji_cache, /datum/emoji_cache, new)
