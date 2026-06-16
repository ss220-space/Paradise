/**
 * Возвращает форму единственного или множественного числа в зависимости от грамматического рода.
 *
 * Простой инструмент, который помогает легко переключаться между формами единственного и
 * множественного числа, основываясь на указанном роде.
 *
 * Аргументы:
 * * `gender` - Грамматический род (MALE, FEMALE, NEUTER, PLURAL)
 * * `single_word` - Форма единственного числа (например, "делает")
 * * `plural_word` - Форма множественного числа (например, "делают")
 */
/proc/pluralize_ru(gender, single_word, plural_word)
	SHOULD_BE_PURE(TRUE)
	if(!istext(single_word) || !istext(plural_word))
		stack_trace("Invalid word arguments in 'pluralize_ru' proc: [single_word], [plural_word]")
		return plural_word
	switch(gender)
		if(MALE, FEMALE, NEUTER)
			return single_word
		if(PLURAL)
			return plural_word
	stack_trace("Invalid gender argument in 'pluralize_ru' proc: [gender]")
	return plural_word

#define PLUR_ET_YUT(target) pluralize_ru(target.gender, "ет", "ют")
#define PLUR_YOT_YUT(target) pluralize_ru(target.gender, "ёт", "ют")
#define PLUR_ET_UT(target) pluralize_ru(target.gender, "ет", "ут")
#define PLUR_YOT_UT(target) pluralize_ru(target.gender, "ёт", "ут")
#define PLUR_IT_YAT(target) pluralize_ru(target.gender, "ит", "ят")
#define PLUR_IT_AT(target) pluralize_ru(target.gender, "ит", "ат")
#define PLUR_I(target) pluralize_ru(target.gender, "", "и")
// Макросы для случаев, когда обычные не применимы.
#define PLUR_JET_GUT(target) pluralize_ru(target.gender, "жет", "гут")
#define PLUR_CHET_TYAT(target) pluralize_ru(target.gender, "чет", "тят")
