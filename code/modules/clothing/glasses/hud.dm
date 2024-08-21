/obj/item/clothing/glasses/hud
	name = "\improper HUD"
	desc = "A heads-up display that provides important info in (almost) real time."
	flags = NONE //doesn't protect eyes because it's a monocle, duh
	origin_tech = "magnets=3;biotech=2"
	prescription_upgradable = TRUE
	/// The visual icons granted by wearing these glasses.
	var/HUDType = null


/obj/item/clothing/glasses/hud/equipped(mob/living/carbon/human/user, slot, initial)
	. = ..()
	if(!istype(user) || !HUDType || !(slot & (ITEM_SLOT_EYES|ITEM_SLOT_HEAD)))
		return .

	var/datum/atom_hud/hud = GLOB.huds[HUDType]
	hud.add_hud_to(user)


/obj/item/clothing/glasses/hud/dropped(mob/living/carbon/human/user, slot, silent = FALSE)
	. = ..()
	if(!istype(user) || !HUDType || !(slot & (ITEM_SLOT_EYES|ITEM_SLOT_HEAD)))
		return .

	var/datum/atom_hud/hud = GLOB.huds[HUDType]
	hud.remove_hud_from(user)


/obj/item/clothing/glasses/hud/emp_act(severity)
	if(!emagged)
		emagged = TRUE
		desc = desc + " The display flickers slightly."

/obj/item/clothing/glasses/hud/visor_toggling(mob/living/carbon/human/user)
	. = ..()
	if(!.)
		return
	if(visor_vars_to_toggle & VISOR_EXAM_EXTENTIONS)
		examine_extensions ^= initial(examine_extensions)

	if(visor_vars_to_toggle & VISOR_HUDTYPE)
		HUDType ^= initial(HUDType)

		var/datum/atom_hud/H = GLOB.huds[initial(HUDType)]
		if(istype(user) && src == user.glasses)
			if(HUDType)
				H.add_hud_to(user)

			else
				H.remove_hud_from(user)

/*
MEDICAL
*/

/obj/item/clothing/glasses/hud/health
	name = "\improper Medical HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their health status."
	icon_state = "healthhud"
	origin_tech = "magnets=3;biotech=2"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = EXAMINE_HUD_MEDICAL

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/health/night
	name = "\improper Night Vision Medical HUD"
	desc = "An advanced medical head-up display that allows doctors to find patients in complete darkness."
	icon_state = "healthhudnight"
	item_state = "nvghud"
	origin_tech = "magnets=4;biotech=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/health/sunglasses
	name = "medical sunglasses"
	desc = "Sunglasses with a medical HUD."
	icon_state = "sunhudmed"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/hud/health/tajblind
	name = "lightweight veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed medical HUD."
	icon_state = "tajblind_med"
	item_state = "tajblind_med"
	flags_cover = GLASSESCOVERSEYES
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/health/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/health/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/health/meson
	name = "\improper Medical-Meson HUD"
	desc = "A medical heads-up display that comes with an optical meson scanner."
	icon_state = "mesonhealth"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/*
DIAGNOSTIC
*/

/obj/item/clothing/glasses/hud/diagnostic
	name = "\improper Diagnostic HUD"
	desc = "A heads-up display capable of analyzing the integrity and status of robotics and exosuits."
	icon_state = "diagnostichud"
	origin_tech = "magnets=2;engineering=2"
	HUDType = DATA_HUD_DIAGNOSTIC

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/diagnostic/night
	name = "\improper Night Vision Diagnostic HUD"
	desc = "A robotics diagnostic HUD fitted with a light amplifier."
	icon_state = "diagnostichudnight"
	item_state = "nvghud"
	origin_tech = "magnets=4;powerstorage=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/diagnostic/sunglasses
	name = "diagnostic sunglasses"
	desc = "Sunglasses with a diagnostic HUD."
	icon_state = "sunhuddiag"
	item_state = "sunhuddiag"
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/hud/diagnostic/tajblind
	name = "diagnostic veil"
	desc = "A tajaran veil capable of analyzing the integrity and status of robotics and exosuits."
	icon_state = "tajblind_diagnostic"
	item_state = "tajblind_diagnostic"
	flags_cover = GLASSESCOVERSEYES
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/diagnostic/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/diagnostic/tajblind/attack_self(mob/user)
	toggle_veil(user)

/*
SECURITY
*/

/obj/item/clothing/glasses/hud/security
	name = "\improper Security HUD"
	desc = "A heads-up display that scans the humans in view and provides accurate data about their ID status and security records."
	icon_state = "securityhud"
	origin_tech = "magnets=3;combat=2"
	var/global/list/jobs[0]
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = EXAMINE_HUD_SECURITY_READ | EXAMINE_HUD_SECURITY_WRITE

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/security/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/night
	name = "\improper Night Vision Security HUD"
	desc = "An advanced heads-up display which provides id data and vision in complete darkness."
	icon_state = "securityhudnight"
	origin_tech = "magnets=4;combat=4;plasmatech=4;engineering=5"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE //don't render darkness while wearing these
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/security/sunglasses
	name = "security sunglasses"
	desc = "Sunglasses with a security HUD."
	icon_state = "sunhud"
	origin_tech = "magnets=3;combat=3;engineering=3"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
	)

/obj/item/clothing/glasses/hud/security/sunglasses/tacticool
	name = "security tactical glasses"
	desc = "Ballistic glasses with a security HUD. Gives you tacticool protection and selfish increase. The elastic band allows it to be worn over a helmet."
	icon_state = "secgoggles-g"
	item_state = "secgoggles-g"
	over_hat = TRUE
	can_toggle = TRUE
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT | VISOR_DARKNESSVIEW | VISOR_FULL_HUD
	actions_types = list(/datum/action/item_action/toggle)

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
	)

/obj/item/clothing/glasses/hud/security/sunglasses/tacticool/attack_self(mob/user)
	weldingvisortoggle(user)

/obj/item/clothing/glasses/hud/security/sunglasses/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/obj/item/clothing/glasses/hud/security/sunglasses/prescription
	prescription = TRUE

/obj/item/clothing/glasses/hud/security/sunglasses/aviators
	name = "security aviators"
	desc = "A aviators with a security HUD."
	icon_state = "aviators"

/obj/item/clothing/glasses/hud/security/sunglasses/jensenshades
	name = "augmented shades"
	desc = "Polarized bioneural eyewear, designed to augment your vision."
	icon_state = "jensenshades"
	item_state = "jensenshades"
	vision_flags = SEE_MOBS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/security/sunglasses/tajblind
	name = "sleek veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an in-built security HUD."
	icon_state = "tajblind_sec"
	item_state = "tajblind_sec"
	flags_cover = GLASSESCOVERSEYES
	tint_up = 1
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/security/sunglasses/tajblind/attack_self(mob/user)
	toggle_veil(user)

/obj/item/clothing/glasses/hud/security/sunglasses/tajblind/read_only
	examine_extensions = EXAMINE_HUD_SECURITY_READ

/*
HYDROPONIC
*/

/obj/item/clothing/glasses/hud/hydroponic
	name = "\improper Hydroponic HUD"
	desc = "A heads-up display capable of analyzing the health and status of plants growing in hydro trays and soil."
	icon_state = "hydroponichud"
	HUDType = DATA_HUD_HYDROPONIC
	examine_extensions = EXAMINE_HUD_BOTANY
	sprite_sheets = list(
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/hydroponic/night
	name = "\improper Night Vision Hydroponic HUD"
	desc = "A hydroponic HUD fitted with a light amplifier."
	icon_state = "hydroponichudnight"
	item_state = "nvghud"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	prescription_upgradable = FALSE

/obj/item/clothing/glasses/hud/hydroponic/sunglasses
	name = "hydroponic sunglasses"
	desc = "For cool botanists only"
	icon_state = "sunhudhydro"
	item_state = "sunhudhydro"
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1

/obj/item/clothing/glasses/hud/hydroponic/tajblind
	name = "blooming veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. There is botanical hud in it."
	icon_state = "tajblind_bot"
	item_state = "tajblind_bot"
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/hydroponic/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/hydroponic/tajblind/attack_self(mob/user)
	toggle_veil(user)

/*
SKILLS
*/

/obj/item/clothing/glasses/hud/skills
	name = "\improper Skills HUD"
	desc = "A heads-up display capable of showing the employment history records of NT crew members."
	icon_state = "skill"
	item_state = "skill"
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = EXAMINE_HUD_SKILLS
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY  = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
	)

/obj/item/clothing/glasses/hud/skills/sunglasses
	name = "skills sunglasses"
	desc = "Sunglasses with a build-in skills HUD, showing the employment history of nearby NT crew members."
	icon_state = "sunhudskill"
	see_in_dark = 1 // None of these three can be converted to booleans. Do not try it.
	flash_protect = FLASH_PROTECTION_FLASH
	tint = 1
	prescription_upgradable = TRUE
	sprite_sheets = list(
		SPECIES_DRASK = 'icons/mob/clothing/species/drask/eyes.dmi',
		SPECIES_GREY  = 'icons/mob/clothing/species/grey/eyes.dmi',
		SPECIES_VOX = 'icons/mob/clothing/species/vox/eyes.dmi',
		SPECIES_MONKEY = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_FARWA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_WOLPIN = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_NEARA = 'icons/mob/clothing/species/monkey/eyes.dmi',
		SPECIES_STOK = 'icons/mob/clothing/species/monkey/eyes.dmi'
	)

/obj/item/clothing/glasses/hud/skills/tajblind
	name = "skills veil"
	desc = "A tajaran veil capable of showing the employment history records of NT crew members."
	icon_state = "tajblind_skill"
	item_state = "tajblind_skill"
	flags_cover = GLASSESCOVERSEYES
	tint = 3
	actions_types = list(/datum/action/item_action/toggle)

/obj/item/clothing/glasses/hud/skills/tajblind/sunglasses
	see_in_dark = 1
	flash_protect = FLASH_PROTECTION_FLASH
	tint_up = 1

/obj/item/clothing/glasses/hud/skills/tajblind/attack_self(mob/user)
	toggle_veil(user)
