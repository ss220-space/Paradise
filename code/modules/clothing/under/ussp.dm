/obj/item/clothing/under/ussp
	icon = 'icons/clothing/uniforms/ussp.dmi'
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/uniform.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/uniform.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/species/unathi/uniform.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/species/vulpkanin/uniform.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/uniform.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/uniform.dmi',
	)

/obj/item/clothing/under/ussp/soviet
	name = "Soviet uniform"
	desc = "Стандартная военная униформа СССП."
	icon_state = "soviet"
	item_state = "soviet"
	item_color = "soviet"

/obj/item/clothing/under/ussp/soviet/ussp/get_ru_names()
	return alist(
		NOMINATIVE = "советская униформа",
		GENITIVE = "советской униформы",
		DATIVE = "советской униформе",
		ACCUSATIVE = "советскую униформу",
		INSTRUMENTAL = "советской униформой",
		PREPOSITIONAL = "советской униформе",
	)

/obj/item/clothing/under/ussp/soviet/officer
	name = "Soviet officer uniform"
	desc = "Униформа Командующего Офицера СССП."
	icon_state = "sovietofficer"
	item_state = "sovietofficer"
	item_color = "sovietofficer"

/obj/item/clothing/under/ussp/soviet/officer/get_ru_names()
	return alist(
		NOMINATIVE = "униформа советского офицера",
		GENITIVE = "униформы советского офицера",
		DATIVE = "униформе советского офицера",
		ACCUSATIVE = "униформу советского офицера",
		INSTRUMENTAL = "униформой советского офицера",
		PREPOSITIONAL = "униформе советского офицера",
	)

/obj/item/clothing/under/ussp/soviet/admiral
	name = "Soviet admiral uniform"
	desc = "Униформа Адмирала Флота СССП."
	icon_state = "sovietadmiral"
	item_state = "sovietadmiral"
	item_color = "sovietadmiral"

/obj/item/clothing/under/ussp/soviet/admiral/get_ru_names()
	return alist(
		NOMINATIVE = "униформа советского адмирала",
		GENITIVE = "униформы советского адмирала",
		DATIVE = "униформе советского адмирала",
		ACCUSATIVE = "униформу советского адмирала",
		INSTRUMENTAL = "униформой советского адмирала",
		PREPOSITIONAL = "униформе советского адмирала",
	)

/obj/item/clothing/under/ussp/tracksuit_red
	name = "red track suit"
	desc = "Классический спортивный костюм. Маленькая бирка на одежде говорит: \"Сделано в СССП\"."
	icon_state = "ussptracksuit_red"
	item_state = "ussptracksuit_red"
	item_color = "ussptracksuit_red"

/obj/item/clothing/under/ussp/tracksuit_red/get_ru_names()
	return alist(
		NOMINATIVE = "красный спортивный костюм",
		GENITIVE = "красного спортивного костюма",
		DATIVE = "красному спортивному костюму",
		ACCUSATIVE = "красный спортивный костюм",
		INSTRUMENTAL = "красным спортивным костюмом",
		PREPOSITIONAL = "красном спортивном костюме",
	)

/obj/item/clothing/under/ussp/tracksuit_blue
	name = "blue track suit"
	desc = "Классический спортивный костюм. Маленькая бирка на одежде говорит: \"Сделано в СССП\"."
	icon_state = "ussptracksuit_blue"
	item_state = "ussptracksuit_blue"
	item_color = "ussptracksuit_blue"

/obj/item/clothing/under/ussp/tracksuit_blue/get_ru_names()
	return alist(
		NOMINATIVE = "синий спортивный костюм",
		GENITIVE = "синего спортивного костюма",
		DATIVE = "синему спортивному костюму",
		ACCUSATIVE = "синий спортивный костюм",
		INSTRUMENTAL = "синим спортивным костюмом",
		PREPOSITIONAL = "синем спортивном костюме",
	)

/obj/item/clothing/under/ussp/tracksuit_black
	name = "black track suit"
	desc = "Классический спортивный костюм. Маленькая бирка на одежде говорит: \"Сделано в СССП\"."
	icon_state = "ussptracksuit_black"
	item_state = "ussptracksuit_black"
	item_color = "ussptracksuit_black"

/obj/item/clothing/under/ussp/tracksuit_black/get_ru_names()
	return alist(
		NOMINATIVE = "чёрный спортивный костюм",
		GENITIVE = "чёрного спортивного костюма",
		DATIVE = "чёрному спортивному костюму",
		ACCUSATIVE = "чёрный спортивный костюм",
		INSTRUMENTAL = "чёрным спортивным костюмом",
		PREPOSITIONAL = "чёрном спортивном костюме",
	)

/obj/item/clothing/under/ussp/tracksuit_white
	name = "white track suit"
	desc = "Классический спортивный костюм. Маленькая бирка на одежде говорит: \"Сделано в СССП\"."
	icon_state = "ussptracksuit_white"
	item_state = "ussptracksuit_white"
	item_color = "ussptracksuit_white"

/obj/item/clothing/under/ussp/tracksuit_white/get_ru_names()
	return alist(
		NOMINATIVE = "белый спортивный костюм",
		GENITIVE = "белого спортивного костюма",
		DATIVE = "белому спортивному костюму",
		ACCUSATIVE = "белый спортивный костюм",
		INSTRUMENTAL = "белым спортивным костюмом",
		PREPOSITIONAL = "белом спортивном костюме",
	)

//De facto its ussp form
/obj/item/clothing/under/ussp/clown/officer
	name = "Clown Officer's Uniform"
	desc = "Для клоунов-офицеров, дизайн был создан великим дизайнером клоуном Хьюго Боссом."
	icon_state = "officeruniform"
	item_color = "officeruniform"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/ussp/clown/officer/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон офицера клоуна",
		GENITIVE = "комбинезона офицера клоуна",
		DATIVE = "комбинезону офицера клоуна",
		ACCUSATIVE = "комбинезон офицера клоуна",
		INSTRUMENTAL = "комбинезоном офицера клоуна",
		PREPOSITIONAL = "комбинезоне офицера клоуна",
	)

/obj/item/clothing/under/ussp/clown/soldier
	name = "Clown Soldier's Uniform"
	desc = "Для рядового солдата клоунской армии."
	icon_state = "soldieruniform"
	item_color = "soldieruniform"
	body_parts_covered = UPPER_TORSO|LOWER_TORSO

/obj/item/clothing/under/ussp/clown/soldier/get_ru_names()
	return alist(
		NOMINATIVE = "комбинезон солдата клоуна",
		GENITIVE = "комбинезона солдата клоуна",
		DATIVE = "комбинезону солдата клоуна",
		ACCUSATIVE = "комбинезон солдата клоуна",
		INSTRUMENTAL = "комбинезоном солдата клоуна",
		PREPOSITIONAL = "комбинезоне солдата клоуна",
	)
