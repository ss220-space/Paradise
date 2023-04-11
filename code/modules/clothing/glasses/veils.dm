/obj/item/clothing/glasses/hud/tajblind
	name = "embroidered veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes."
	icon_state = "tajblind"
	item_state = "tajblind"
	prescription_upgradable = FALSE //Just for a while let it be here.
	flash_protect = 1
	tint = 3
	actions_types = list(/datum/action/item_action/toggle_veil)
	flags_cover = GLASSESCOVERSEYES
	visor_vars_to_toggle = VISOR_FLASHPROTECT | VISOR_TINT
	var/obj/item/clothing/glasses/lenses
	sprite_sheets = list(
		"Vox" = 'icons/mob/species/vox/eyes.dmi',
		"Grey" = 'icons/mob/species/grey/eyes.dmi',
		"Monkey" = 'icons/mob/species/monkey/eyes.dmi',
		"Farwa" = 'icons/mob/species/monkey/eyes.dmi',
		"Wolpin" = 'icons/mob/species/monkey/eyes.dmi',
		"Neara" = 'icons/mob/species/monkey/eyes.dmi',
		"Stok" = 'icons/mob/species/monkey/eyes.dmi'
		)

/obj/item/clothing/glasses/hud/tajblind/New()
	. = ..()
	toggle_veil()

/obj/item/clothing/glasses/hud/tajblind/ui_action_click(mob/user, actiontype)
	if(ispath(actiontype, /datum/action/item_action/toggle_veil))
		toggle_veil()
		return TRUE

/obj/item/clothing/glasses/hud/tajblind/proc/toggle_veil()
	if(usr.canmove && !usr.incapacitated())
		up = !up
		flags ^= visor_flags
		flags_inv ^= visor_flags_inv
		if(visor_vars_to_toggle & VISOR_FLASHPROTECT)
			flash_protect ^= initial(flash_protect)
		if(visor_vars_to_toggle & VISOR_TINT)
			tint ^= initial(tint)
		var/mob/living/carbon/user = usr
		user.update_tint()
		user.update_inv_glasses()

/obj/item/clothing/glasses/hud/tajblind/item_action_slot_check(slot)
	if(slot == slot_glasses)
		return TRUE

/obj/item/clothing/glasses/hud/tajblind/engi
	name = "industrial veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed welding protective shield when veil is not active."
	icon_state = "tajblind_engi"
	item_state = "tajblind_engi"
	flash_protect = 2
	lenses = new/obj/item/clothing/glasses/welding

/obj/item/clothing/glasses/hud/tajblind/meson
	name = "khaki veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed meson scanner."
	icon_state = "tajblind_cargo"
	item_state = "tajblind_cargo"
	vision_flags = SEE_TURFS
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	lenses = new/obj/item/clothing/glasses/meson

/obj/item/clothing/glasses/hud/tajblind/meson/night
	name = "Night Vision meson veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed meson scanner. Allows see in dark, but why?"
	icon_state = "tajblind_nv_engi"
	item_state = "tajblind_nv_engi"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	lenses = new/obj/item/clothing/glasses/meson/night

/obj/item/clothing/glasses/hud/tajblind/sci
	name = "hi-tech veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed research and reagent scanner."
	icon_state = "tajblind_sci"
	item_state = "tajblind_sci"
	scan_reagents = 1
	resistance_flags = ACID_PROOF
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 100)
	lenses = new/obj/item/clothing/glasses/science
	actions_types = list(
		/datum/action/item_action/toggle_research_scanner,
		/datum/action/item_action/toggle_veil
		)

/obj/item/clothing/glasses/hud/tajblind/sci/night
	name = "hi-tech Night Vision veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed research and reagent scanner. Allows see in dark, but why?"
	icon_state = "tajblind_nv_sci"
	item_state = "tajblind_nv_sci"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	lenses = new/obj/item/clothing/glasses/science/night

/obj/item/clothing/glasses/hud/tajblind/med
	name = "lightweight veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed medical HUD."
	icon_state = "tajblind_med"
	item_state = "tajblind_med"
	HUDType = DATA_HUD_MEDICAL_ADVANCED
	examine_extensions = list(EXAMINE_HUD_MEDICAL)
	lenses = new/obj/item/clothing/glasses/hud/health

/obj/item/clothing/glasses/hud/tajblind/med/night
	name = "lightweight Night Vision veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed medical HUD. Allows see in dark, but why?"
	icon_state = "tajblind_nv_med"
	item_state = "tajblind_nv_med"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	lenses = new/obj/item/clothing/glasses/hud/health/night

/obj/item/clothing/glasses/hud/tajblind/diag
	name = "robotic veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed diagnostic HUD."
	icon_state = "tajblind_diag"
	item_state = "tajblind_diag"
	HUDType = DATA_HUD_DIAGNOSTIC
	lenses = new/obj/item/clothing/glasses/hud/diagnostic

/obj/item/clothing/glasses/hud/tajblind/diag/night
	name = "robotic Night Vision veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed diagnostic HUD. Allows see in dark, but why?"
	icon_state = "tajblind_nv_diag"
	item_state = "tajblind_nv_diag"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	lenses = new/obj/item/clothing/glasses/hud/diagnostic/night

/obj/item/clothing/glasses/hud/tajblind/sec
	name = "sleek veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed security HUD."
	icon_state = "tajblind_sec"
	item_state = "tajblind_sec"
	var/global/list/jobs[0]
	HUDType = DATA_HUD_SECURITY_ADVANCED
	examine_extensions = list(EXAMINE_HUD_SECURITY_READ, EXAMINE_HUD_SECURITY_WRITE)
	lenses = new/obj/item/clothing/glasses/hud/security

/obj/item/clothing/glasses/hud/tajblind/sec/night
	name = "sleek Night Vision veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed secutiry HUD. Allows see in dark, but why?"
	icon_state = "tajblind_nv_sec"
	item_state = "tajblind_nv_sec"
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	lenses = new/obj/item/clothing/glasses/hud/security/night

/obj/item/clothing/glasses/hud/tajblind/hydro
	name = "nature veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed hydroponic HUD."
	icon_state = "tajblind_hydro"
	item_state = "tajblind_hydro"
	HUDType = DATA_HUD_HYDROPONIC
	lenses = new/obj/item/clothing/glasses/hud/hydroponic

/obj/item/clothing/glasses/hud/tajblind/skill
	name = "personnel veil"
	desc = "An Ahdominian made veil that allows the user to see while obscuring their eyes. This one has an installed skill HUD."
	icon_state = "tajblind_skill"
	item_state = "tajblind_skill"
	HUDType = DATA_HUD_SECURITY_BASIC
	examine_extensions = list(EXAMINE_HUD_SKILLS)
	lenses = new/obj/item/clothing/glasses/hud/skills

//obj/item/clothing/glasses/hud/tajblind/thermal //Ну, а вдруг Кей захочет термалки.
//	name = "holder"
//	desc = "holder"
//	icon_state = "purple"
//	item_state = "purple"
//	vision_flags = SEE_MOBS
//	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
//	lenses = new/obj/item/clothing/glasses/thermal


//obj/item/clothing/glasses/hud/tajblind/thermal/emp_act(severity)
//	if(istype(src.loc, /mob/living/carbon/human))
//		var/mob/living/carbon/human/M = src.loc
//		to_chat(M, "<span class='warning'>The [name] overloads and blinds you!</span>")
//		if(M.glasses == src)
//			M.EyeBlind(3)
//			M.EyeBlurry(5)
//			if(!(NEARSIGHTED in M.mutations))
//				M.BecomeNearsighted()
//				spawn(100)
//					M.CureNearsighted()
//	..()

//Now we try real crafts.

/obj/item/clothing/glasses/hud/tajblind/proc/remove_lenses(/mob/living/user)
	if(lenses)
		to_chat(usr, "<span class='notice'>With a simple click you pulled lenses out from [src].</span>")
		lenses.forceMove(usr)
		usr.put_in_hands(lenses)
		lenses = null
		return

/obj/item/clothing/glasses/hud/tajblind/attack_self(mob/user)
	if(item_state != "tajblind")
		var/A = new/obj/item/clothing/glasses/hud/tajblind(get_turf(src))
		remove_lenses(user)
		qdel(src)
		user.put_in_active_hand(A)
	return

/obj/item/clothing/glasses/hud/tajblind/attackby(var/obj/item/clothing/glasses/glasses, mob/user, params)
	var/obj/item/clothing/glasses/G = glasses
	var/obj/item/clothing/glasses/welding/W = glasses
	var/obj/item/clothing/glasses/hud/H = glasses
	if(istype(H) && !src.lenses)
		var/obj/item/clothing/glasses/hud/tajblind/veilH
		if(istype(H,/obj/item/clothing/glasses/hud/health))
			if(H.see_in_dark)
				veilH = new/obj/item/clothing/glasses/hud/tajblind/med/night(user.loc)
			else
				veilH = new/obj/item/clothing/glasses/hud/tajblind/med(user.loc)
		else if(istype(H,/obj/item/clothing/glasses/hud/security))
			if(H.see_in_dark)
				veilH = new/obj/item/clothing/glasses/hud/tajblind/sec/night(user.loc)
			else
				veilH = new/obj/item/clothing/glasses/hud/tajblind/sec(user.loc)
		else if(istype(H,/obj/item/clothing/glasses/hud/diagnostic))
			if(H.see_in_dark)
				veilH = new/obj/item/clothing/glasses/hud/tajblind/diag/night(user.loc)
			else
				veilH = new/obj/item/clothing/glasses/hud/tajblind/diag(user.loc)
		else if(istype(H,/obj/item/clothing/glasses/hud/hydroponic))
			veilH = new/obj/item/clothing/glasses/hud/tajblind/hydro(user.loc)
		else if(istype(H,/obj/item/clothing/glasses/hud/skills))
			veilH = new/obj/item/clothing/glasses/hud/tajblind/skill(user.loc)
		else
			return FALSE
		veilH.lenses = H
		H.loc = src
		user.put_in_active_hand(veilH)
		qdel(src)
		to_chat(usr, "<span class='notice'>You succesfully inserted new lenses in your [src.name]")
	else if(istype(W) && !src.lenses)
		var/obj/item/clothing/glasses/hud/tajblind/veilW
		if(istype(W,/obj/item/clothing/glasses/welding/superior))
			return FALSE
		veilW = new/obj/item/clothing/glasses/hud/tajblind/engi(user.loc)
		veilW.lenses = W
		W.loc = src
		user.put_in_active_hand(veilW)
		qdel(src)
		to_chat(usr, "<span class='notice'>You succesfully inserted new lenses in your [src.name]")
	else if(istype(G) && !src.lenses)
		var/obj/item/clothing/glasses/hud/tajblind/veilG
		if(G.vision_flags == SEE_TURFS)
			if(G.see_in_dark)
				veilG = new/obj/item/clothing/glasses/hud/tajblind/meson/night(user.loc)
			else
				veilG = new/obj/item/clothing/glasses/hud/tajblind/meson(user.loc)
		else if(G.scan_reagents)
			if(G.see_in_dark)
				veilG = new/obj/item/clothing/glasses/hud/tajblind/sci/night(user.loc)
			else
				veilG = new/obj/item/clothing/glasses/hud/tajblind/sci(user.loc)
//		else if(G.vision_flags == SEE_MOBS)
//			veilG = new/obj/item/clothing/glasses/hud/tajblind/thermal(user.loc)
		else
			return FALSE
		veilG.lenses = G
		G.loc = src
		user.put_in_active_hand(veilG)
		qdel(src)
		to_chat(usr, "<span class='notice'>You succesfully inserted new lenses in your [src.name]")
