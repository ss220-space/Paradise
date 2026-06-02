/**
 * Обрабатывает гендерно-зависимую текстовую разметку в строке.
 *
 * Заменяет шаблоны `%(SINGLE,PLURAL)%` и `%(MALE,FEMALE,NEUTER,PLURAL)%` в сообщении
 * на соответствующую форму слова в зависимости от пола моба.
 *
 * Используйте `*` для пропуска конкретной формы рода (например, `%(*,FEMALE,*,PLURAL)%)`;
 * литеральные `*` в остальном тексте сообщения не затрагиваются.
 *
 * Обрабатывает все корректные шаблоны в строке. Некорректная разметка (без закрывающего `)%`
 * или с неверным числом частей) логируется и остаётся в строке как есть.
 *
 * Аргументы:
 * * `user` - Моб, чей пол определяет форму слов (использует NEUTER, если не моб)
 * * `message` - Строка с гендерной разметкой для обработки
 */
/proc/genderize_decode(mob/user, message)
	if(!istext(message))
		stack_trace("Invalid message argument in 'genderize_decode' proc: [message]")
		return message
	var/gender = ismob(user) ? user.gender : NEUTER
	while(TRUE)
		var/prefix = findtext_char(message, "%(")
		if(!prefix)
			break
		var/postfix = findtext_char(message, ")%", prefix + 2)
		if(!postfix)
			stack_trace("Genderize string is missing proper ending, expected ')%': [message]")
			break
		var/list/pieces = splittext(copytext_char(message, prefix + 2, postfix), ",")
		var/replacement
		switch(length(pieces))
			if(2) // если частей только две — выбираем форму числа
				replacement = pluralize_ru(gender, pieces[1], pieces[2])
			if(4) // если частей четыре — выбираем форму по роду
				replacement = genderize_ru(gender, pieces[1], pieces[2], pieces[3], pieces[4])
			else
				stack_trace("Invalid data sent to 'genderize_decode' proc: [message]")
				break
		// Вырезаем маркер пропуска только из выбранной формы — литеральные `*` в тексте остаются нетронутыми
		message = splicetext_char(message, prefix, postfix + 2, replacetext(replacement, "*", ""))
	return message

/// Макрос для `declent_ru` для автоматической капитализации первой буквы
#define DECLENT_RU_CAP(target, case_id) capitalize(target.declent_ru(case_id))
