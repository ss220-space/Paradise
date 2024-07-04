/obj/item/clothing/head/mod
	name = "MOD helmet"
	desc = "A helmet for a MODsuit."
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

/obj/item/clothing/head/mod/update_icon_state()
	var/not_sealed = control.activating ? control.active : !control.active
	icon_state = "[control.skin]-[base_icon_state][not_sealed ? "" : "-sealed"]"

/obj/item/clothing/suit/mod
	name = "MOD chestplate"
	desc = "A chestplate for a MODsuit."
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

/obj/item/clothing/suit/mod/update_icon_state()
	var/not_sealed = control.activating ? control.active : !control.active
	icon_state = "[control.skin]-[base_icon_state][not_sealed ? "" : "-sealed"]"

/obj/item/clothing/gloves/mod
	name = "MOD gauntlets"
	desc = "A pair of gauntlets for a MODsuit."
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

/obj/item/clothing/gloves/mod/update_icon_state()
	var/not_sealed = control.activating ? control.active : !control.active
	icon_state = "[control.skin]-[base_icon_state][not_sealed ? "" : "-sealed"]"


/obj/item/clothing/shoes/mod
	name = "MOD boots"
	desc = "A pair of boots for a MODsuit."
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

/obj/item/clothing/shoes/mod/update_icon_state()
	var/not_sealed = control.activating ? control.active : !control.active
	icon_state = "[control.skin]-[base_icon_state][not_sealed ? "" : "-sealed"]"
