/obj/item/clothing/head/mod
	name = "MOD helmet"
	desc = "Стандартный Шлем для модульного костюма."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-helmet"
	base_icon_state = "helmet"
	onmob_sheets = list(ITEM_SLOT_HEAD_STRING = 'icons/mob/clothing/modsuit/mod_clothing.dmi')
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = HEAD
	permeability_coefficient = 0.01
	heat_protection = HEAD
	cold_protection = HEAD
	sprite_sheets = list(
		SPECIES_GREY = 'icons/mob/clothing/modsuit/species/grey_helmets.dmi',
		SPECIES_VULPKANIN = 'icons/mob/clothing/modsuit/species/vulp_modsuits.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/modsuit/species/taj_modsuits.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/modsuit/species/unathi_modsuits.dmi',
		SPECIES_VOX = 'icons/mob/clothing/modsuit/species/vox_modsuits.dmi'
		)
	var/obj/item/mod/control/control

/obj/item/clothing/head/mod/get_ru_names()
	return list(
		NOMINATIVE = "шлем модульного костюма",
		GENITIVE = "шлема модульного костюма",
		DATIVE = "шлему модульного костюма",
		ACCUSATIVE = "шлем модульного костюма",
		INSTRUMENTAL = "шлемом модульного костюма",
		PREPOSITIONAL = "шлеме модульного костюма"
	)

/obj/item/clothing/head/mod/update_icon_state()
	var/not_sealed = control.activating ? control.active : !control.active
	icon_state = "[control.skin]-[base_icon_state][not_sealed ? "" : "-sealed"]"

/obj/item/clothing/head/mod/update_name(updates = ALL)
	if(!control)
		return
	if(!ru_names)
		ru_names = get_ru_names_cached()

	ru_names = list(
		NOMINATIVE = ru_names[NOMINATIVE] + " [control.theme.name] модели",
		GENITIVE = ru_names[GENITIVE] + " [control.theme.name] модели",
		DATIVE = ru_names[DATIVE] + " [control.theme.name] модели",
		ACCUSATIVE = ru_names[ACCUSATIVE] + " [control.theme.name] модели",
		INSTRUMENTAL = ru_names[INSTRUMENTAL] + " [control.theme.name] модели",
		PREPOSITIONAL = ru_names[PREPOSITIONAL] + " [control.theme.name] модели"
	)

/obj/item/clothing/suit/mod
	name = "MOD chestplate"
	desc = "Стандартный нагрудник для модульного костюма."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-chestplate"
	base_icon_state = "chestplate"
	permeability_coefficient = 0.01
	onmob_sheets = list(
		ITEM_SLOT_CLOTH_OUTER_STRING = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	)
	blood_overlay_type = "armor"
	allowed = list(
		/obj/item/tank/internals,
		/obj/item/flashlight,
		/obj/item/tank/jetpack/oxygen/captain,
	)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = UPPER_TORSO|LOWER_TORSO
	heat_protection = UPPER_TORSO|LOWER_TORSO
	cold_protection = UPPER_TORSO|LOWER_TORSO
	hide_tail_by_species = list("modsuit")
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/modsuit/species/vulp_modsuits.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/modsuit/species/taj_modsuits.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/modsuit/species/unathi_modsuits.dmi',
		SPECIES_VOX = 'icons/mob/clothing/modsuit/species/vox_modsuits.dmi'
		)
	var/obj/item/mod/control/control

/obj/item/clothing/suit/mod/get_ru_names()
	return list(
		NOMINATIVE = "нагрудник модульного костюма",
		GENITIVE = "нагрудника модульного костюма",
		DATIVE = "нагруднику модульного костюма",
		ACCUSATIVE = "нагрудник модульного костюма",
		INSTRUMENTAL = "нагрудником модульного костюма",
		PREPOSITIONAL = "нагруднике модульного костюма"
	)

/obj/item/clothing/suit/mod/update_icon_state()
	var/not_sealed = control.activating ? control.active : !control.active
	icon_state = "[control.skin]-[base_icon_state][not_sealed ? "" : "-sealed"]"

/obj/item/clothing/suit/mod/update_name(updates = ALL)
	if(!control)
		return
	if(!ru_names)
		ru_names = get_ru_names_cached()

	ru_names = list(
		NOMINATIVE = ru_names[NOMINATIVE] + " [control.theme.name] модели",
		GENITIVE = ru_names[GENITIVE] + " [control.theme.name] модели"",
		DATIVE = ru_names[DATIVE] + " [control.theme.name] модели",
		ACCUSATIVE = ru_names[ACCUSATIVE] + " [control.theme.name] модели",
		INSTRUMENTAL = ru_names[INSTRUMENTAL] + " [control.theme.name] модели",
		PREPOSITIONAL = ru_names[PREPOSITIONAL] + " [control.theme.name] модели"
	)

/obj/item/clothing/gloves/mod
	name = "MOD gauntlets"
	desc = "Пара стандартный рукавиц для модульного костюма."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-gauntlets"
	base_icon_state = "gauntlets"
	permeability_coefficient = 0.01
	onmob_sheets = list(
		ITEM_SLOT_GLOVES_STRING = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = HANDS|ARMS
	heat_protection = HANDS|ARMS
	cold_protection = HANDS|ARMS
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/modsuit/species/vulp_modsuits.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/modsuit/species/taj_modsuits.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/modsuit/species/unathi_modsuits.dmi',
		SPECIES_VOX = 'icons/mob/clothing/modsuit/species/vox_modsuits.dmi'
		)
	var/obj/item/mod/control/control

/obj/item/clothing/gloves/mod/get_ru_names()
	return list(
		NOMINATIVE = "перчатки модульного костюма",
		GENITIVE = "перчаток модульного костюма",
		DATIVE = "перчаткам модульного костюма",
		ACCUSATIVE = "перчатки модульного костюма",
		INSTRUMENTAL = "перчатками модульного костюма",
		PREPOSITIONAL = "перчатках модульного костюма"
	)

/obj/item/clothing/gloves/mod/update_icon_state()
	var/not_sealed = control.activating ? control.active : !control.active
	icon_state = "[control.skin]-[base_icon_state][not_sealed ? "" : "-sealed"]"

/obj/item/clothing/gloves/mod/update_name(updates = ALL)
	if(!control)
		return
	if(!ru_names)
		ru_names = get_ru_names_cached()

	ru_names = list(
		NOMINATIVE = ru_names[NOMINATIVE] + " [control.theme.name] модели",
		GENITIVE = ru_names[GENITIVE] + " [control.theme.name] модели",
		DATIVE = ru_names[DATIVE] + " [control.theme.name] модели",
		ACCUSATIVE = ru_names[ACCUSATIVE] + " [control.theme.name] модели",
		INSTRUMENTAL = ru_names[INSTRUMENTAL] + " [control.theme.name] модели",
		PREPOSITIONAL = ru_names[PREPOSITIONAL] + " [control.theme.name] модели"
	)

/obj/item/clothing/shoes/mod
	name = "MOD boots"
	desc = "Пара стандартных ботинок для модульного костюма."
	icon = 'icons/obj/clothing/modsuit/mod_clothing.dmi'
	icon_state = "standard-boots"
	base_icon_state = "boots"
	onmob_sheets = list(
		ITEM_SLOT_FEET_STRING = 'icons/mob/clothing/modsuit/mod_clothing.dmi'
	)
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, RAD = 0, FIRE = 0, ACID = 0)
	body_parts_covered = FEET|LEGS
	heat_protection = FEET|LEGS
	cold_protection = FEET|LEGS
	permeability_coefficient = 0.01
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/modsuit/species/vulp_modsuits.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/modsuit/species/taj_modsuits.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/modsuit/species/unathi_modsuits.dmi',
		SPECIES_VOX = 'icons/mob/clothing/modsuit/species/vox_modsuits.dmi'
		)
	var/obj/item/mod/control/control

/obj/item/clothing/shoes/mod/get_ru_names()
	return list(
		NOMINATIVE = "ботинки модульного костюма",
		GENITIVE = "ботинок модульного костюма",
		DATIVE = "ботинкам модульного костюма",
		ACCUSATIVE = "ботинки модульного костюма",
		INSTRUMENTAL = "ботинками модульного костюма",
		PREPOSITIONAL = "ботинках модульного костюма"
	)

/obj/item/clothing/shoes/mod/update_icon_state()
	var/not_sealed = control.activating ? control.active : !control.active
	icon_state = "[control.skin]-[base_icon_state][not_sealed ? "" : "-sealed"]"

/obj/item/clothing/shoes/mod/update_name(updates = ALL)
	if(!control)
		return
	if(!ru_names)
		ru_names = get_ru_names_cached()

	ru_names = list(
		NOMINATIVE = ru_names[NOMINATIVE] + " [control.theme.name] модели",
		GENITIVE = ru_names[GENITIVE] + " [control.theme.name] модели",
		DATIVE = ru_names[DATIVE] + " [control.theme.name] модели",
		ACCUSATIVE = ru_names[ACCUSATIVE] + " [control.theme.name] модели",
		INSTRUMENTAL = ru_names[INSTRUMENTAL] + " [control.theme.name] модели",
		PREPOSITIONAL = ru_names[PREPOSITIONAL] + " [control.theme.name] модели"
	)
