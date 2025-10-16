/**
 * Возвращает правильную форму слова, соответствующую русскому склонению числительных.
 *
 * Учитывает правила русского языка, определяющие окончания числительных, на основе переданного числа.
 * Использует три формы: единственное число (1), двойственное число (2-4) и множественное число (5+).
 *
 * Аргументы:
 * * num - Число, для которого необходимо определить форму слова
 * * single_name - Форма слова для 1 (например, "стол")
 * * double_name - Форма слова для 2-4 (например, "стола")
 * * multiple_name - Форма слова для 5+ (например, "столов")
 */
/proc/declension_ru(num, single_name, double_name, multiple_name)
	if(!isnum(num) || round(num) != num)
		return double_name // fractional numbers
	if(((num % 10) == 1) && ((num % 100) != 11)) // 1, not 11
		return single_name
	if(((num % 10) in 2 to 4) && !((num % 100) in 12 to 14)) // 2, 3, 4, not 12, 13, 14
		return double_name
	return multiple_name // 5, 6, 7, 8, 9, 0

// Макросы для наиболее часто используемых случаев.
/// Секунд, минут, единиц
#define DECL_SEC_MIN(target) declension_ru(target, "у", "ы", "")

/**
 * Возвращает форму слова с учётом грамматического рода в русском языке.
 *
 * Выбирает правильную форму слова в зависимости от его грамматического рода (MALE, FEMALE, NEUTER)
 * или множественного числа (PLURAL). Используется для прилагательных, местоимений и глаголов,
 * изменяющихся по родам.
 *
 * Аргументы:
 * * gender - Грамматический род (MALE, FEMALE, NEUTER, PLURAL)
 * * male_word - Мужская форма
 * * female_word - Женская форма
 * * neuter_word - Средняя форма
 * * multiple_word - Форма множественного числа
 */
/proc/genderize_ru(gender, male_word, female_word, neuter_word, multiple_word)
	return gender == MALE ? male_word : (gender == FEMALE ? female_word : (gender == NEUTER ? neuter_word : multiple_word))

// Макросы для наиболее часто используемых случаев.
#define GEND_HE_SHE(target) genderize_ru(target.gender, "он", "она", "оно", "они")
#define GEND_HIS_HER(target) genderize_ru(target.gender, "его", "её", "его", "их")
#define GEND_HIM_HER(target) genderize_ru(target.gender, "ему", "ей", "ему", "им")

/**
 * Возвращает форму единственного или множественного числа в зависимости от грамматического рода.
 *
 * Простой инструмент, который помогает легко переключаться между формами единственного и
 * множественного числа, основываясь на указанном роде.
 *
 * Аргументы:
 * * gender - Грамматический род (MALE, FEMALE, NEUTER, PLURAL)
 * * single_word - Форма единственного числа
 * * plural_word - Форма множественного числа
 */
/proc/pluralize_ru(gender, single_word, plural_word)
	return gender == PLURAL ? plural_word : single_word

// Макросы для наиболее часто используемых случаев.
#define PLUR_ET_UT(target) pluralize_ru(target.gender, "ет", "ют")
#define PLUR_IT_YAT(target) pluralize_ru(target.gender, "ит", "ят")

/**
 * Обрабатывает гендерно-зависимую текстовую разметку в строке.
 *
 * Заменяет шаблоны %(SINGLE,PLURAL)% и %(MALE,FEMALE,NEUTER,PLURAL)% в сообщении
 * на соответствующую форму слова в зависимости от пола моба.
 * Используйте * для пропуска конкретной формы рода (например, %(*,FEMALE,*,PLURAL)%).
 * Обрабатывает все шаблоны до тех пор, пока они полностью не исчезнут.
 *
 * Аргументы:
 * * user - Моб, чей пол определяет форму слов (использует NEUTER, если не моб)
 * * msg - Строка с гендерной разметкой для обработки
 */
/proc/genderize_decode(mob/user, msg)
	if(!istext(msg))
		stack_trace("Invalid arguments in genderize_decode proc.")
	var/gender
	if(ismob(user))
		gender = user.gender
	else
		gender = NEUTER
	while(TRUE)
		var/prefix = findtext_char(msg, "%(")
		if(!prefix)
			break
		var/postfix = findtext_char(msg, ")%")
		if(!postfix)
			stack_trace("Genderize string is missing proper ending, expected )%.")
		var/list/pieces = splittext(copytext_char(msg, prefix + 2, postfix), ",")
		switch(length(pieces))
			if(2) // pluralize if only two parts present
				msg = replacetext(splicetext_char(msg, prefix, postfix + 2, pluralize_ru(gender, pieces[1], pieces[2])), "*", "")
			if(4) // use full genderize if all four parts exist
				msg = replacetext(splicetext_char(msg, prefix, postfix + 2, genderize_ru(gender, pieces[1], pieces[2], pieces[3], pieces[4])), "*", "")
			else
				stack_trace("Invalid data sent to genderize_decode proc.")
	return msg

