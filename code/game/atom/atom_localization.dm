/**
 * Возвращает русское название атома, склоненное для указанного падежа.
 *
 * Эта процедура обрабатывает склонение русских названий атомов по падежам.
 * Поиск подходящего склоненного имени выполняется в следующем порядке:
 * 1. Предопределенные русские названия атома (`ru_names`)
 * 2. Кэшированные русские названия из `get_ru_names_cached()`
 *
 * Если склоненная форма для указанного падежа не найдена (`null`), возвращает имя по умолчанию.
 *
 * Аргументы:
 * * `case_id` - Идентификатор падежа из дефайнов русского языка (напр. `[NOMINATIVE]`, `[GENITIVE]` и т.д.)
 */
/atom/proc/declent_ru(case_id)
	SHOULD_BE_PURE(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	if(case_id < NOMINATIVE || case_id > PREPOSITIONAL)
		stack_trace("declent_ru() called with invalid case_id '[case_id]'")
		return name
	var/alist/list_to_use = ru_names || get_ru_names_cached()
	if(length(list_to_use))
		return list_to_use[case_id] || name
	return name

/**
 * Получить варианты русского названия в грамматических падежах.
 *
 * Переопределите этот метод, чтобы вернуть ассоциативный список
 * с идентификаторами падежей и соответствующими русскими названиями.
 * Используется функцией `declent_ru()` для поиска названий по падежам.
 */
/atom/proc/get_ru_names()
	PROTECTED_PROC(TRUE)
	RETURN_TYPE(/alist)
	. = alist()

/**
 * Получить кешированные русские названия для данного типа атомов.
 *
 * Сначала проверяет глобальный кеш на наличие русских названий для данного типа.
 * Если не найдено, вызывает `get_ru_names()` и кеширует результат для последующих вызовов.
 */
/atom/proc/get_ru_names_cached()
	RETURN_TYPE(/alist)
	var/alist/names = GLOB.cached_ru_names[type]
	if(names)
		return names
	names = get_ru_names()
	if(!names)
		return
	if(!isalist(names))
		stack_trace("get_ru_names() for type [type] returned a plain '/list' instead of an '/alist'")
	GLOB.cached_ru_names[type] = names
	return names

/**
 * Перестраивает `ru_names`, добавляя `suffix` к каждому падежу базовых склонений.
 *
 * Используется при каждом переименовании по принципу "базовое имя + суффикс".
 * Базовые склонения берутся из `get_ru_names_cached()`, если у типа их нет, падеж заполняется `initial(name)`.
 */
/atom/proc/set_ru_names_suffix(suffix)
	PROTECTED_PROC(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	var/alist/names = get_ru_names_cached()
	var/has_names = length(names)
	ru_names = has_names ? names.Copy() : alist()
	for(var/case_id in NOMINATIVE to PREPOSITIONAL)
		ru_names[case_id] = "[has_names ? names[case_id] : initial(name)][suffix]"
