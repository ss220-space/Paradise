/obj/item/id_decal
	name = "identification card decal"
	desc = "Обертка из наноцеллофана, которая принимает форму ID-карты, чтобы сделать ее более привлекательной."
	icon = 'icons/obj/toy.dmi'
	icon_state = "id_decal"
	gender = FEMALE
	var/decal_name = "identification card"
	var/decal_desc = "Карта, используемая для удостоверения личности и определения доступа на станции."
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
	desc = "Ваша карта будет выглядеть так, словно принадлежит капитану. Или эгоцентричному Главе Персонала. Можно применить на любую ID-карту."
	decal_desc = "Золотая карта, показывающая власть и могущество."
	decal_icon_state = "gold"
	decal_item_state = "gold-id"

/obj/item/id_decal/gold/get_ru_names()
	return list(
		NOMINATIVE = "золотая наклейка на ID-карту",
		GENITIVE = "золотой наклейки на ID-карту",
		DATIVE = "золотой наклейке на ID-карту",
		ACCUSATIVE = "золотую наклейку на ID-карту",
		INSTRUMENTAL = "золотой наклейкой на ID-карту",
		PREPOSITIONAL = "золотой наклейке на ID-карту",
	)

/obj/item/id_decal/silver
	name = "silver ID card decal"
	icon_state = "id_decal_silver"
	desc = "Сделайте вашу карту похожей на карту Главы Персонала самостоятельно, потому что по вашей просьбе он её не перекрасит. Можно применить на любую ID-карту."
	decal_desc = "Серебряная карта, показывающая честь и достоинство."
	decal_icon_state = "silver"
	decal_item_state = "silver-id"

/obj/item/id_decal/silver/get_ru_names()
	return list(
		NOMINATIVE = "серебряная наклейка на ID-карту",
		GENITIVE = "серебряной наклейки на ID-карту",
		DATIVE = "серебряной наклейке на ID-карту",
		ACCUSATIVE = "серебряную наклейку на ID-карту",
		INSTRUMENTAL = "серебряной наклейкой на ID-карту",
		PREPOSITIONAL = "серебряной наклейке на ID-карту",
	)

/obj/item/id_decal/prisoner
	name = "prisoner ID card decal"
	icon_state = "id_decal_prisoner"
	desc = "Все крутые детишки носят карты такого цвета. Можно применить на любую ID-карту."
	decal_desc = "Вы — номер, а не свободный человек."
	decal_icon_state = "prisoner"
	decal_item_state = "orange-id"

/obj/item/id_decal/prisoner/get_ru_names()
	return list(
		NOMINATIVE = "тюремная наклейка на ID-карту",
		GENITIVE = "тюремной наклейки на ID-карту",
		DATIVE = "тюремной наклейке на ID-карту",
		ACCUSATIVE = "тюремную наклейку на ID-карту",
		INSTRUMENTAL = "тюремной наклейкой на ID-карту",
		PREPOSITIONAL = "тюремной наклейке на ID-карту",
	)

/obj/item/id_decal/centcom
	name = "centcom ID card decal"
	icon_state = "id_decal_centcom"
	desc = "Престиж офицера ЦК, но без его ответственности и его доступов. Можно применить на любую ID-карту."
	decal_desc = "Карта, прибывшая прямо из Центрального Командования."
	decal_icon_state = "centcom"

/obj/item/id_decal/centcom/get_ru_names()
	return list(
		NOMINATIVE = "наклейка ЦК на ID-карту",
		GENITIVE = "наклейки ЦК на ID-карту",
		DATIVE = "наклейке ЦК на ID-карту",
		ACCUSATIVE = "наклейку ЦК на ID-карту",
		INSTRUMENTAL = "наклейкой ЦК на ID-карту",
		PREPOSITIONAL = "наклейке ЦК на ID-карту",
	)

/obj/item/id_decal/emag
	name = "cryptographic sequencer ID card decal"
	icon_state = "id_decal_emag"
	desc = "Моток проводов, который можно прилепить на вашу ID-карту, чтобы выглядеть крайне подозрительно. Можно применить на любую ID-карту."
	decal_name = "cryptographic sequencer"
	decal_desc = "Карта с магнитной полосой и микросхемами."
	decal_icon_state = "emag"
	override_name = 1

/obj/item/id_decal/emag/get_ru_names()
	return list(
		NOMINATIVE = "наклейка ЕМАГ на ID-карту",
		GENITIVE = "наклейки ЕМАГ на ID-карту",
		DATIVE = "наклейке ЕМАГ на ID-карту",
		ACCUSATIVE = "наклейку ЕМАГ на ID-карту",
		INSTRUMENTAL = "наклейкой ЕМАГ на ID-карту",
		PREPOSITIONAL = "наклейке ЕМАГ на ID-карту",
	)

/obj/item/id_decal/federal
	name = "federal ID card decal"
	icon_state = "id_decal_federal"
	desc = "Наклейка в цветах ТСФ, выдаваемая резидентам межзвёздного государства. Можно применить на любую ID-карту."
	decal_desc = "Карта в цветах ТСФ, выдаваемая резидентам межзвёздного государства."
	decal_icon_state = "federal"
	decal_item_state = "federal-id"

/obj/item/id_decal/federal/get_ru_names()
	return list(
		NOMINATIVE = "наклейка ТСФ на ID-карту",
		GENITIVE = "наклейки ТСФ на ID-карту",
		DATIVE = "наклейке ТСФ на ID-карту",
		ACCUSATIVE = "наклейку ТСФ на ID-карту",
		INSTRUMENTAL = "наклейкой ТСФ на ID-карту",
		PREPOSITIONAL = "наклейке ТСФ на ID-карту",
	)

/obj/item/id_decal/comrad
	name = "comrad ID card decal"
	icon_state = "id_decal_comrad"
	desc = "Наклейка в цветах военной экипировки колонии СССП для гордых товарищей. Можно применить на любую ID-карту."
	decal_desc = "Карта в цветах военной экипировки колонии СССП для гордых товарищей."
	decal_icon_state = "comrad"
	decal_item_state = "comrad-id"

/obj/item/id_decal/comrad/get_ru_names()
	return list(
		NOMINATIVE = "наклейка СССП на ID-карту",
		GENITIVE = "наклейки СССП на ID-карту",
		DATIVE = "наклейке СССП на ID-карту",
		ACCUSATIVE = "наклейку СССП на ID-карту",
		INSTRUMENTAL = "наклейкой СССП на ID-карту",
		PREPOSITIONAL = "наклейке СССП на ID-карту",
	)

/obj/item/id_decal/syndie
	name = "syndie ID card decal"
	icon_state = "id_decal_syndie"
	desc = "Наклейка в красно-зелёных цветах. Владелец данной наклейки, вероятно, не захочет распространяться о том, от кого она ему досталась. Можно применить на любую ID-карту."
	decal_desc = "Карта подозрительного красно-зелёного цвета. И где вы только её достали?"
	decal_icon_state = "syndieciv"
	decal_item_state = "syndieciv-id"

/obj/item/id_decal/syndie/get_ru_names()
	return list(
		NOMINATIVE = "наклейка \"Синдиката\" на ID-карту",
		GENITIVE = "наклейки \"Синдиката\" на ID-карту",
		DATIVE = "наклейке \"Синдиката\" на ID-карту",
		ACCUSATIVE = "наклейку \"Синдиката\" на ID-карту",
		INSTRUMENTAL = "наклейкой \"Синдиката\" на ID-карту",
		PREPOSITIONAL = "наклейке \"Синдиката\" на ID-карту",
	)

/proc/get_station_card_skins()
	return list("data","id","gold","silver","security", "cadet","medical", "intern","research", "student","cargo", "mining_medic","engineering", "trainee","HoS","CMO","RD","CE","clown","mime","rainbow","prisoner")

/proc/get_centcom_card_skins()
	return list("centcom","centcom_old","nanotrasen","ERT_leader","ERT_empty","ERT_security","ERT_engineering","ERT_medical","ERT_janitorial","deathsquad","commander","syndie","TDred","TDgreen")

/proc/get_all_card_skins()
	return get_station_card_skins() + get_centcom_card_skins()

/proc/get_skin_desc(skin)
	switch(skin)
		if("id")
			return "Standard"
		if("cargo")
			return "Supply"
		if("HoS")
			return "Head of Security"
		if("CMO")
			return "Chief Medical Officer"
		if("RD")
			return "Research Director"
		if("CE")
			return "Chief Engineer"
		if("centcom_old")
			return "Centcom Old"
		if("ERT_leader")
			return "ERT Leader"
		if("ERT_empty")
			return "ERT Default"
		if("ERT_security")
			return "ERT Security"
		if("ERT_engineering")
			return "ERT Engineering"
		if("ERT_medical")
			return "ERT Medical"
		if("ERT_janitorial")
			return "ERT Janitorial"
		if("syndie")
			return "Syndicate"
		if("TDred")
			return "Thunderdome Red"
		if("TDgreen")
			return "Thunderdome Green"
		if("mining_medic")
			return "Mining Medic"
		else
			return capitalize(skin)
