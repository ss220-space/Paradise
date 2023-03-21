/obj/item/clothing/glasses/hud/tajblind
	name = "embroidered veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes."
	icon_state = "tajblind"
	item_state = "tajblind"
	flags_cover = GLASSESCOVERSEYES
	var/flash_protect_mod = 1
	actions_types = list(/datum/action/item_action/toggle)

	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi',
		"Monkey" = 'icons/mob/species/monkey/eyes.dmi',
		"Farwa" = 'icons/mob/species/monkey/eyes.dmi',
		"Wolpin" = 'icons/mob/species/monkey/eyes.dmi',
		"Neara" = 'icons/mob/species/monkey/eyes.dmi',
		"Stok" = 'icons/mob/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/tajblind/attack_self()
	toggle_veil()

/obj/item/clothing/glasses/hud/tajblind/proc/toggle_veil()
	if(usr.canmove && !usr.incapacitated())
		if(up)
			up = !up
			tint = initial(tint)
			flash_protect = initial(flash_protect)
			to_chat(usr, "You activate [src], allowing you to see.")
		else
			up = !up
			tint = 3
			flash_protect = flash_protect_mod
			to_chat(usr, "You deactivate [src], obscuring your vision.")
		var/mob/living/carbon/user = usr
		user.update_tint()
		user.update_inv_glasses()

/obj/item/clothing/glasses/hud/tajblind/engi
	name = "industrial veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed welding protective shield when veil is not active."
	icon_state = "tajblind_engi"
	item_state = "tajblind_engi"
	flash_protect_mod = 2

/obj/item/clothing/glasses/hud/tajblind/meson
	name = "khaki veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed meson scanner."
	icon_state = "tajblind_cargo"
	item_state = "tajblind_cargo"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/tajblind/meson/night
	name = "Night Vision meson veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed meson scanner. Allows see in dark, but why?"
	icon_state = "tajblind_nv_engi"
	item_state = "tajblind_nv_engi"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/obj/item/clothing/glasses/hud/tajblind/sci
	name = "hi-tech veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed research and reagent scanner."
	icon_state = "tajblind_sci"
	item_state = "tajblind_sci"
	scan_reagents = 1
	resistance_flags = ACID_PROOF
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	actions_types = list(
		/datum/action/item_action/toggle_research_scanner,
		/datum/action/item_action/toggle
		)

/obj/item/clothing/glasses/hud/tajblind/sci/item_action_slot_check(slot)
	if(slot == slot_glasses)
		return 1

/obj/item/clothing/glasses/hud/tajblind/sci/night
	name = "hi-tech Night Vision veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed research and reagent scanner. Allows see in dark, but why?"
	icon_state = "tajblind_nv_sci"
	item_state = "tajblind_nv_sci"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/obj/item/clothing/glasses/hud/tajblind/med
	name = "lightweight veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed medical HUD."
	icon_state = "tajblind_med"
	item_state = "tajblind_med"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = list(EXAMINE_HUD_MEDICAL)

/obj/item/clothing/glasses/hud/tajblind/med/night
	name = "lightweight Night Vision veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed medical HUD. Allows see in dark, but why?"
	icon_state = "tajblind_nv_med"
	item_state = "tajblind_nv_med"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/tajblind/diag
	name = "robotic veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed diagnostic HUD."
	icon_state = "tajblind_diag"
	item_state = "tajblind_diag"
	HUDType = DATA_HUD_DIAGNOSTIC

/obj/item/clothing/glasses/hud/tajblind/diag/night
	name = "robotic Night Vision veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed diagnostic HUD. Allows see in dark, but why?"
	icon_state = "tajblind_nv_diag"
	item_state = "tajblind_nv_diag"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/glasses/hud/tajblind/sec
	name = "sleek veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed security HUD."
	icon_state = "tajblind_sec"
	item_state = "tajblind_sec"
	var/global/list/jobs[0]
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = list(EXAMINE_HUD_SECURITY_READ, EXAMINE_HUD_SECURITY_WRITE)

/obj/item/clothing/glasses/hud/tajblind/sec/night
	name = "sleek Night Vision veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed secutiry HUD. Allows see in dark, but why?"
	icon_state = "tajblind_nv_sec"
	item_state = "tajblind_nv_sec"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE

/obj/item/clothing/glasses/hud/tajblind/hydro
	name = "nature veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed hydroponic HUD."
	icon_state = "tajblind_hydro"
	item_state = "tajblind_hydro"
	HUDType = DATA_HUD_HYDROPONIC

/obj/item/clothing/glasses/hud/tajblind/skill
	name = "personnel veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed skill HUD."
	icon_state = "tajblind_skill"
	item_state = "tajblind_skill"
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = list(EXAMINE_HUD_SKILLS)

//Now we try real crafts.

/obj/item/clothing/glasses/hud/tajblind/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	to_chat(user, "<span class='notice'>You start unsecuring bolts on [src], trying to pull out a HUD from it.</span>")
	if(I.use_tool(src, user, 30, volume = I.tool_volume))
		to_chat(user, "<span class='notice'>You succesfully pulled out HUD from [src]! HUD looks too worsen to be used again.</span>")
		new/obj/item/clothing/glasses/hud/tajblind(get_mob(src))
		qdel(src)







