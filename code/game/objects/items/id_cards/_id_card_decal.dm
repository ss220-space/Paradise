/obj/item/id_decal
	name = "identification card decal"
	desc = "Обёртка из наноцеллофана, которая принимает форму ID-карты. Носит сугубо косметическую функцию."
	icon = 'icons/obj/toy.dmi'
	icon_state = "id_decal"
	gender = FEMALE
	var/decal_desc = "Стандартная идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	var/decal_icon_state = "id"
	var/decal_item_state = "card-id"
	var/override_name = 0

/obj/item/id_decal/get_ru_names()
	return list(
		NOMINATIVE = "наклейка на ID-карту",
		GENITIVE = "наклейки на ID-карту",
		DATIVE = "наклейке на ID-карту",
		ACCUSATIVE = "наклейку на ID-карту",
		INSTRUMENTAL = "наклейкой на ID-карту",
		PREPOSITIONAL = "наклейке на ID-карту",
	)

/obj/item/id_decal/gold
	name = "gold ID card decal"
	icon_state = "id_decal_gold"
	desc = "Обёртка из наноцеллофана, которая принимает форму ID-карты. Носит сугубо косметическую функцию. \
			Ваша карта будет выглядеть так, будто принадлежит Капитану."
	decal_desc = "Идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			Уникальная золотая отделка подчёркивает власть и могущество владельца."
	decal_icon_state = "gold"
	decal_item_state = "gold-id"

/obj/item/id_decal/gold/get_ru_names()
	return list(
		NOMINATIVE = "наклейка на ID-карту \"Золото\"",
		GENITIVE = "наклейки на ID-карту \"Золото\"",
		DATIVE = "наклейке на ID-карту \"Золото\"",
		ACCUSATIVE = "наклейку на ID-карту \"Золото\"",
		INSTRUMENTAL = "наклейкой на ID-карту \"Золото\"",
		PREPOSITIONAL = "наклейке на ID-карту \"Золото\"",
	)

/obj/item/id_decal/silver
	name = "silver ID card decal"
	icon_state = "id_decal_silver"
	desc = "Обёртка из наноцеллофана, которая принимает форму ID-карты. Носит сугубо косметическую функцию. \
			Ваша карта будет выглядеть так, будто принадлежит Главе Персонала."
	decal_desc = "Идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			Уникальная серебряная отделка подчёркивает высокий статус владельца."
	decal_icon_state = "silver"
	decal_item_state = "silver-id"

/obj/item/id_decal/silver/get_ru_names()
	return list(
		NOMINATIVE = "наклейка на ID-карту \"Серебро\"",
		GENITIVE = "наклейки на ID-карту \"Серебро\"",
		DATIVE = "наклейке на ID-карту \"Серебро\"",
		ACCUSATIVE = "наклейку на ID-карту \"Серебро\"",
		INSTRUMENTAL = "наклейкой на ID-карту \"Серебро\"",
		PREPOSITIONAL = "наклейке на ID-карту \"Серебро\"",
	)

/obj/item/id_decal/prisoner
	name = "prisoner ID card decal"
	icon_state = "id_decal_prisoner"
	desc = "Обёртка из наноцеллофана, которая принимает форму ID-карты. Носит сугубо косметическую функцию. \
			Ваша карта будет выглядеть так, будто принадлежит заключённому."
	decal_desc = "Идентификационная карта для заключённых \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	decal_icon_state = "prisoner"
	decal_item_state = "orange-id"

/obj/item/id_decal/prisoner/get_ru_names()
	return list(
		NOMINATIVE = "наклейка на ID-карту \"Заключённый\"",
		GENITIVE = "наклейки на ID-карту \"Заключённый\"",
		DATIVE = "наклейке на ID-карту \"Заключённый\"",
		ACCUSATIVE = "наклейку на ID-карту \"Заключённый\"",
		INSTRUMENTAL = "наклейкой на ID-карту \"Заключённый\"",
		PREPOSITIONAL = "наклейке на ID-карту \"Заключённый\"",
	)

/obj/item/id_decal/centcom
	name = "centcom ID card decal"
	icon_state = "id_decal_centcom"
	desc = "Обёртка из наноцеллофана, которая принимает форму ID-карты. Носит сугубо косметическую функцию. \
			Ваша карта будет выглядеть так, будто принадлежит сотруднику ЦК \"Нанотрейзен\" в секторе \"Эпсилон Лукусты\"."
	decal_desc = "Стандартная идентификационная карта персонала Центрального Командования \"Нанотрейзен\" в секторе \"Эпсилон Лукусты\". \
			Служит для подтверждения личности, определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	decal_icon_state = "centcom"

/obj/item/id_decal/centcom/get_ru_names()
	return list(
		NOMINATIVE = "наклейка на ID-карту \"Центком\"",
		GENITIVE = "наклейки на ID-карту \"Центком\"",
		DATIVE = "наклейке на ID-карту \"Центком\"",
		ACCUSATIVE = "наклейку на ID-карту \"Центком\"",
		INSTRUMENTAL = "наклейкой на ID-карту \"Центком\"",
		PREPOSITIONAL = "наклейке на ID-карту \"Центком\"",
	)

/obj/item/id_decal/emag
	name = "cryptographic sequencer ID card decal"
	icon_state = "id_decal_emag"
	desc = "Обёртка из наноцеллофана, которая принимает форму ID-карты. Носит сугубо косметическую функцию. \
			Ваша карта будет выглядеть как нелегальное устройство для взлома электроники."
	decal_desc = "ID-карта \"Нанотрейзен\" с прикреплённой магнитной лентой и какими-то микросхемами. \
			Судя по всему, это устройство предназначено для взлома систем безопасности электронных устройств."
	decal_icon_state = "emag"
	override_name = 1

/obj/item/id_decal/emag/get_ru_names()
	return list(
		NOMINATIVE = "наклейка на ID-карту \"Криптографический считыватель\"",
		GENITIVE = "наклейки на ID-карту \"Криптографический считыватель\"",
		DATIVE = "наклейке на ID-карту \"Криптографический считыватель\"",
		ACCUSATIVE = "наклейку на ID-карту \"Криптографический считыватель\"",
		INSTRUMENTAL = "наклейкой на ID-карту \"Криптографический считыватель\"",
		PREPOSITIONAL = "наклейке на ID-карту \"Криптографический считыватель\"",
	)

/obj/item/id_decal/federal
	name = "federal ID card decal"
	icon_state = "id_decal_federal"
	desc = "Обёртка из наноцеллофана, которая принимает форму ID-карты. Носит сугубо косметическую функцию. \
			Ваша карта будет сигнализировать о том, что вы — гражданин ТСФ."
	decal_desc = "Стандартная идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			Оформлена в цветах Транс-Солнечной Федерации."
	decal_icon_state = "federal"
	decal_item_state = "federal-id"

/obj/item/id_decal/federal/get_ru_names()
	return list(
		NOMINATIVE = "наклейка на ID-карту \"ТСФ\"",
		GENITIVE = "наклейки на ID-карту \"ТСФ\"",
		DATIVE = "наклейке на ID-карту \"ТСФ\"",
		ACCUSATIVE = "наклейку на ID-карту \"ТСФ\"",
		INSTRUMENTAL = "наклейкой на ID-карту \"ТСФ\"",
		PREPOSITIONAL = "наклейке на ID-карту \"ТСФ\"",
	)

/obj/item/id_decal/comrad
	name = "comrad ID card decal"
	icon_state = "id_decal_comrad"
	desc ="Обёртка из наноцеллофана, которая принимает форму ID-карты. Носит сугубо косметическую функцию. \
			Ваша карта будет сигнализировать о том, что вы — гражданин СССП."
	decal_desc = "Стандартная идентификационная карта персонала \"Нанотрейзен\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника. \
			Оформлена в цветах Союза Советских Социалистических Планет."
	decal_icon_state = "comrad"
	decal_item_state = "comrad-id"

/obj/item/id_decal/comrad/get_ru_names()
	return list(
		NOMINATIVE = "наклейка на ID-карту \"СССП\"",
		GENITIVE = "наклейки на ID-карту \"СССП\"",
		DATIVE = "наклейке на ID-карту \"СССП\"",
		ACCUSATIVE = "наклейку на ID-карту \"СССП\"",
		INSTRUMENTAL = "наклейкой на ID-карту \"СССП\"",
		PREPOSITIONAL = "наклейке на ID-карту \"СССП\"",
	)

/obj/item/id_decal/syndie
	name = "syndie ID card decal"
	icon_state = "id_decal_syndie"
	desc = "Обёртка из наноцеллофана, которая принимает форму ID-карты. Носит сугубо косметическую функцию. \
			Ваша карта будет выглядеть так, будто принадлежит сотруднику \"Синдиката\"."
	decal_desc = "Стандартная идентификационная карта персонала \"Синдиката\". Служит для подтверждения личности, \
			определения уровня допуска к системам рабочего объекта и регистрации биометрических данных сотрудника."
	decal_icon_state = "syndieciv"
	decal_item_state = "syndieciv-id"

/obj/item/id_decal/syndie/get_ru_names()
	return list(
		NOMINATIVE = "наклейка на ID-карту \"Синдикат\"",
		GENITIVE = "наклейки на ID-карту \"Синдикат\"",
		DATIVE = "наклейке на ID-карту \"Синдикат\"",
		ACCUSATIVE = "наклейку на ID-карту \"Синдикат\"",
		INSTRUMENTAL = "наклейкой на ID-карту \"Синдикат\"",
		PREPOSITIONAL = "наклейке на ID-карту \"Синдикат\"",
	)

/proc/get_station_card_skins()
	return list(
		"data",
		"id",
		"gold",
		"silver",
		"security",
		"cadet",
		"medical",
		"intern",
		"research",
		"student",
		"cargo",
		"mining_medic",
		"engineering",
		"trainee",
		"HoS",
		"CMO",
		"RD",
		"CE",
		"clown",
		"mime",
		"rainbow",
		"prisoner",
	)

/proc/get_centcom_card_skins()
	return list(
		"centcom",
		"centcom_old",
		"nanotrasen",
		"ERT_leader",
		"ERT_empty",
		"ERT_security",
		"ERT_engineering",
		"ERT_medical",
		"ERT_janitorial",
		"deathsquad",
		"commander",
		"syndie",
		"TDred",
		"TDgreen",
	)

/proc/get_all_card_skins()
	return get_station_card_skins() + get_centcom_card_skins()

/proc/get_skin_desc(skin)
	switch(skin)
		if("id")
			return "Стандарт"
		if("data")
			return "Пустая"
		if("gold")
			return "Золотая"
		if("silver")
			return "Серебряная"
		if("security")
			return "Безопасность"
		if("cadet")
			return "Кадет"
		if("medical")
			return "Медицина"
		if("intern")
			return "Интерн"
		if("research")
			return "Наука"
		if("student")
			return "Студент"
		if("engineering")
			return "Инженерия"
		if("trainee")
			return "Стажёр"
		if("clown")
			return "Клоун"
		if("mime")
			return "Мим"
		if("rainbow")
			return "Радужная"
		if("prisoner")
			return "Заключённый"
		if("cargo")
			return "Снабжение"
		if("HoS")
			return "Глава Службы Безопасности"
		if("CMO")
			return "Главный Врач"
		if("RD")
			return "Научный Директор"
		if("CE")
			return "Главный Инженер"
		if("centcom_old")
			return "Центком (Старая)"
		if("ERT_leader")
			return "Командир ОБР"
		if("ERT_empty")
			return "ОБР (Стандарт)"
		if("ERT_security")
			return "ОБР (Безопасность)"
		if("ERT_engineering")
			return "ОБР (Инженерия)"
		if("ERT_medical")
			return "ОБР (Медицина)"
		if("ERT_janitorial")
			return "ОБР (Санитария)"
		if("syndie")
			return "Синдикат"
		if("TDred")
			return "Тандердом (Красная)"
		if("TDgreen")
			return "Тандердом (Зелёная)"
		if("mining_medic")
			return "Шахтёрский врач"
		else
			return capitalize(skin)
