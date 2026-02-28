/datum/action/innate/robot_sight
	var/sight_mode = null

	button_icon = 'icons/obj/decals.dmi'
	button_icon_state = "securearea"

/datum/action/innate/robot_sight/Activate()
	var/mob/living/silicon/robot/R = owner

	R.sight_mode |= sight_mode
	R.update_sight()

	active = TRUE

/datum/action/innate/robot_sight/Deactivate()
	var/mob/living/silicon/robot/R = owner

	R.sight_mode &= ~sight_mode
	R.update_sight()

	active = FALSE

/datum/action/innate/robot_sight/xray
	name = "Рентген зрение"
	sight_mode = SILICONXRAY

/datum/action/innate/robot_sight/thermal
	name = "Термальное зрение"
	sight_mode = SILICONTHERM
	button_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "thermal"

// ayylmao
/datum/action/innate/robot_sight/thermal/alien
	button_icon = 'icons/mob/alien.dmi'
	button_icon_state = "borg-extra-vision"

/datum/action/innate/robot_sight/meson
	name = "Мезонное зрение"
	sight_mode = SILICONMESON
	button_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "meson"

/datum/action/innate/robot_magpulse
	name = "Магнитные захваты"
	button_icon = 'icons/obj/clothing/shoes.dmi'
	button_icon_state = "magboots0"
	var/slowdown_active = 2 // Same as magboots

/datum/action/innate/robot_magpulse/Activate()
	ADD_TRAIT(owner, TRAIT_NEGATES_GRAVITY, ROBOT_TRAIT)
	to_chat(owner, "Вы включаете магнитные захваты.")
	owner.add_movespeed_modifier(/datum/movespeed_modifier/robot_magboots_on)
	button_icon_state = "magboots1"
	active = TRUE

/datum/action/innate/robot_magpulse/Deactivate()
	REMOVE_TRAIT(owner, TRAIT_NEGATES_GRAVITY, ROBOT_TRAIT)
	to_chat(owner, "Вы выключаете магнитные захваты.")
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/robot_magboots_on)
	button_icon_state = initial(button_icon_state)
/datum/action/innate/robot_sight_hydro
	name = "Гидропоническое зрение"
	button_icon = 'icons/obj/clothing/glasses.dmi'
	button_icon_state = "hydroponichud"

/datum/action/innate/robot_sight_hydro/Activate()
	for(var/datum/atom_hud/data/hydroponic/hydrosensors in GLOB.huds)
		hydrosensors.show_to(owner)

	active = TRUE

/datum/action/innate/robot_sight_hydro/Deactivate()
	for(var/datum/atom_hud/data/hydroponic/hydrosensors in GLOB.huds)
		hydrosensors.hide_from(owner)

