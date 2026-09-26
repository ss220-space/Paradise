/**
 * Возвращает форму слова с учётом грамматического рода в русском языке.
 *
 * Выбирает правильную форму слова в зависимости от его грамматического рода (MALE, FEMALE, NEUTER)
 * или множественного числа (PLURAL). Используется для прилагательных, местоимений и глаголов,
 * изменяющихся по родам.
 *
 * Аргументы:
 * * `gender` - Грамматический род (MALE, FEMALE, NEUTER, PLURAL)
 * * `male_word` - Мужская форма (например, "тыкнул")
 * * `female_word` - Женская форма (например, "тыкнула")
 * * `neuter_word` - Средняя форма (например, "тыкнуло")
 * * `multiple_word` - Форма множественного числа (например, "тыкнули")
 */
/proc/genderize_ru(gender, male_word, female_word, neuter_word, multiple_word)
	SHOULD_BE_PURE(TRUE)
	if(!istext(male_word) || !istext(female_word) || !istext(neuter_word) || !istext(multiple_word))
		stack_trace("Invalid word arguments in 'genderize_ru' proc: [male_word], [female_word], [neuter_word], [multiple_word]")
		return multiple_word
	switch(gender)
		if(MALE)
			return male_word
		if(FEMALE)
			return female_word
		if(NEUTER)
			return neuter_word
		if(PLURAL)
			return multiple_word
	stack_trace("Invalid gender argument in 'genderize_ru' proc: [gender]")
	return multiple_word

// Местоимения.
#define GEND_HE_SHE(target) genderize_ru(target.gender, "он", "она", "оно", "они")
#define GEND_HE_SHE_CAP(target) capitalize(genderize_ru(target.gender, "он", "она", "оно", "они"))
#define GEND_HIS_HER(target) genderize_ru(target.gender, "его", "её", "его", "их")
#define GEND_HIS_HER_CAP(target) capitalize(genderize_ru(target.gender, "его", "её", "его", "их"))
#define GEND_HIM_HER(target) genderize_ru(target.gender, "ему", "ей", "ему", "им")
#define GEND_ON_IN_HIM(target) genderize_ru(target.gender, "нём", "ней", "нём", "них")
#define GEND_YOUR(target) genderize_ru(target.gender, "ваш", "вашу", "ваше", "ваши")
#define GEND_YOURS(target) genderize_ru(target.gender, "вашего", "вашей", "вашего", "ваших")
// Окончания. Y — буква Ы.
#define GEND_A_O_I(target) genderize_ru(target.gender, "", "а", "о", "и")
#define GEND_A_O_Y(target) genderize_ru(target.gender, "", "а", "о", "ы")
#define GEND_A_E_I(target) genderize_ru(target.gender, "", "а", "е", "и")
#define GEND_SYA_AS_OS_IS(target) genderize_ru(target.gender, "ся", "ась", "ось", "ись")
#define GEND_LA_LO_LI(target) genderize_ru(target.gender, "", "ла", "ло", "ли")
#define GEND_EN_NA_NO_NY(target) genderize_ru(target.gender, "ен", "на", "но", "ны")
#define GEND_EM_EI_EM_IH(target) genderize_ru(target.gender, "ем", "ей", "ем", "их")
#define GEND_YM_OI_YM_YMI(target) genderize_ru(target.gender, "ым", "ой", "ым", "ыми")
#define GEND_IM_EI_IM_IMI(target) genderize_ru(target.gender, "им", "ей", "им", "ими")
#define GEND_YI_AYA_OE_YE(target) genderize_ru(target.gender, "ый", "ая", "ое", "ые")
#define GEND_II_AYA_II_IE(target) genderize_ru(target.gender, "ий", "ая", "ий", "ие")
// Макросы для случаев, когда обычные не применимы.
#define GEND_SHEL(target) genderize_ru(target.gender, "шёл", "шла", "шло", "шли")
