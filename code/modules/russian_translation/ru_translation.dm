/atom
	/// Список склонений названия атома. Пример заполнения в любом наследнике атома
	/// ru_names = list(NOMINATIVE = "челюсти жизни", GENITIVE = "челюстей жизни", DATIVE = "челюстям жизни", ACCUSATIVE = "челюсти жизни", INSTRUMENTAL = "челюстями жизни", PREPOSITIONAL = "челюстях жизни")
	var/list/ru_names
	/// Русское имя не для склоняемого атома
	var/ru_name
	/// Русское описание предмета
	var/ru_desc
	/// Русский пол предмета
	var/ru_gender

// Процедура выбора отображаемого языка. Если russian пуст, то используется оригинальный английский текст. При оверрайде передает russian, даже если он пуст.
proc/pick_translation(english, russian, override = FALSE, client/target)
	if(target)
		if(target.prefs.toggles2 & PREFTOGGLE_2_RUSSIAN && (russian || override))
			return russian
	else if((usr?.client?.prefs?.toggles2 & PREFTOGGLE_2_RUSSIAN) && (russian || override))
		return russian
	return english

// Процедура выбора правильного падежа для любого предмета,если у него указан словарь «ru_names», примерно такой:
// ru_names = list(NOMINATIVE = "челюсти жизни", GENITIVE = "челюстей жизни", DATIVE = "челюстям жизни", ACCUSATIVE = "челюсти жизни", INSTRUMENTAL = "челюстями жизни", PREPOSITIONAL = "челюстях жизни")
/atom/proc/declent_ru(case_id, list/ru_names_override)
	var/list/list_to_use = ru_names_override || ru_names
	if(length(list_to_use))
		return list_to_use[case_id] || name
	return name
/*
/datum/proc/pick_translation(english, russian, override = FALSE)
	if((usr?.client?.prefs?.toggles2 & PREFTOGGLE_2_RUSSIAN) && (russian || override))
		return russian
	return english
*/
