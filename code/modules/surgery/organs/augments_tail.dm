
/obj/item/organ/internal/cyberimp/tail
	name = "Tail-mounted implant"
	desc = "You shoudn't see this! Immediately report to a coder."
	parent_organ_zone = BODY_ZONE_TAIL
	slot = INTERNAL_ORGAN_TAIL_DEVICE
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/sound_on = 'sound/mecha/mechmove03.ogg'
	var/sound_off = 'sound/mecha/mechmove03.ogg'
	var/implant_emp_downtime

// Syndi tail razorblade
/obj/item/organ/internal/cyberimp/tail/blade
	name = "tail razorblade implant"
	desc = "Razor sharp blade designed to be hidden inside the tail. Traditional design of House Eshie'Ssharahss, sold at every corner of the Empire."
	var/datum/action/innate/tail_cut/implant_ability = new

	var/activated = FALSE
	var/slash_strength = 35 							// Implant damage
	var/stamina_damage = 0								// Stamina damage to others
	var/self_stamina_damage = 5							// Stamina damage to self
	var/damage_type = BRUTE								// BRUTE or BURN
	var/slash_sound = 'sound/weapons/bladeslice.ogg'	// A sound plays when you hit someone with tail_cut
	sound_on = 'sound/weapons/blade_dark_unsheath.ogg'	// Activation sound
	sound_off = 'sound/weapons/blade_dark_sheath.ogg'	// Deactivation sound
	icon_state = "tailimplant_blade" 					// All tailblades sprites by @baldek
	origin_tech = "materials=6;combat=5;biotech=5;programming=3;syndicate=3;"

// NT tail laserblade
/obj/item/organ/internal/cyberimp/tail/blade/laser
	name = "tail laserblade implant"
	desc = "A laser blade designed to be hidden inside the tail. Latest design of House Eshie'Ssharahss, issued to Nanotrasen in exclusive contract."

	slash_strength = 20
	stamina_damage = 10
	self_stamina_damage = 10
	damage_type = BURN
	slash_sound = 'sound/weapons/blade1.ogg'
	sound_on = 'sound/weapons/saberon.ogg'
	sound_off = 'sound/weapons/saberoff.ogg'
	icon_state = "tailimplant_laserblue"
	origin_tech = "materials=5;combat=5;biotech=5;powerstorage=4;"

// Syndi tail laserblade
/obj/item/organ/internal/cyberimp/tail/blade/laser/syndi
	name = "overcharged laserblade implant"
	desc = "A laser blade designed to be hidden inside the tail. Design, stolen from House Eshie'Ssharahss and overcharged to be more powerful by the brightest minds of the Gorlex Marauders."

	slash_strength = 25
	stamina_damage = 20
	self_stamina_damage = 5
	damage_type = BURN
	slash_sound = 'sound/weapons/blade1.ogg'
	sound_on = 'sound/weapons/saberon.ogg'
	sound_off = 'sound/weapons/saberoff.ogg'
	icon_state = "tailimplant_laserred"
	origin_tech = "materials=6;combat=5;biotech=5;powerstorage=3;syndicate=2;"

/obj/item/organ/internal/cyberimp/tail/blade/emp_act(severity)
	if(emp_proof)
		return

	if(activated)
		activated = FALSE
		playsound(owner.loc, sound_off, 50, TRUE)
		update_icon(UPDATE_ICON_STATE)

	if(owner)
		to_chat(owner, span_warning("Имплант лезвия отключился от воздействия ЭМИ!"))
		do_sparks(3, 0, owner)
		owner.update_action_buttons()

	implant_emp_downtime = TRUE
	addtimer(CALLBACK(src, PROC_REF(reset_cooldown)), 100 SECONDS) // 100 sec cooldown after EMP

/obj/item/organ/internal/cyberimp/tail/blade/proc/reset_cooldown()
	implant_emp_downtime = FALSE
	if(owner)
		owner.update_action_buttons()
		to_chat(owner, span_notice("Имплант лезвия вернулся в рабочее состояние."))

/obj/item/organ/internal/cyberimp/tail/blade/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(isunathi(M))
		return
	implant_ability.Grant(M)

/obj/item/organ/internal/cyberimp/tail/blade/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(activated)
		owner.apply_damage(slash_strength, damage_type, BODY_ZONE_TAIL, FALSE, TRUE)
		playsound(owner.loc, slash_sound, 40, TRUE)
		playsound(owner.loc, 'sound/effects/bone_break_5.ogg', 40, TRUE)
	implant_ability.Remove(owner)
	. = ..()

/obj/item/organ/internal/cyberimp/tail/blade/ui_action_click(mob/user, actiontype, leftclick)

	if(implant_emp_downtime) // 100 sec cooldown after EMP
		to_chat(owner, span_warning("Ваш имплант всё ещё перегружен после ЭМИ!"))
		return

	activated = !activated

	if(activated)
		playsound(owner.loc, sound_on, 50, TRUE)
		to_chat(owner, span_notice("Вы выдвинули лезвия из хвоста."))

	else
		playsound(owner.loc, sound_off, 50, TRUE)
		to_chat(owner, span_notice("Вы убрали лезвия."))

	update_icon(UPDATE_ICON_STATE)
	owner.update_action_buttons()

/obj/item/organ/internal/cyberimp/tail/blade/update_icon_state()
	if(activated)
		icon_state = "[initial(icon_state)]_active"
	else
		icon_state = "[initial(icon_state)]"


/datum/action/innate/tail_cut
	name = "Взмах хвостом"
	icon_icon = 'icons/mob/actions/actions.dmi'
	button_icon_state = "tail_cut"
	check_flags = AB_CHECK_LYING | AB_CHECK_CONSCIOUS | AB_CHECK_STUNNED

/datum/action/innate/tail_cut/Trigger(left_click = TRUE)
	if(IsAvailable(show_message = TRUE))
		. = ..()


/datum/action/innate/tail_cut/Activate()
	var/mob/living/carbon/human/user = owner
	var/obj/item/organ/internal/cyberimp/tail/blade/implant = user.get_organ_slot(INTERNAL_ORGAN_TAIL_DEVICE)
	var/datum/species/unathi/U // For unathi disabilities
	var/active_implant = FALSE
	var/type_of_damage = BRUTE // I did it only because I need attacklogs without exception
	var/damage_deal = 5		   // Same

	if(implant && implant.activated) // Prevents exception if you dont have the implant, but unathi
		active_implant = TRUE

	if(active_implant)
		type_of_damage = implant.damage_type
		damage_deal = implant.slash_strength

	else if(isunathi(user))
		U = user.dna.species
		damage_deal = U.tail_strength * 5
	else   // Not unathi, no implant, where did you get tail cut?
		return

	if(user.getStaminaLoss() >= 50) // I want to move this to IsAvailable(), but haven't figured out how to synchronise stamina regen with update_action_buttons yet
		to_chat(user, span_warning("Вы слишком устали!"))
		return

	user.changeNext_click(CLICK_CD_MELEE)
	user.spin(10,1)

	// If the user has an implant, we take its values, if not, we take the values from the old unathi's tail_lash (unathi special)
	for(var/mob/living/C in orange(1))

		if(ishuman(C)) // Dealing damage to humans
			var/obj/item/organ/external/E = C.get_organ(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_GROIN))

			if(E)
				var/target_armor = C.run_armor_check(E, MELEE)
				C.apply_damage(damage_deal, type_of_damage, E, target_armor, TRUE)
				C.adjustStaminaLoss(active_implant ? implant.stamina_damage : 0)
				user.visible_message(span_danger("[user.declent_ru(NOMINATIVE)] ударяет хвостом [C.declent_ru(ACCUSATIVE)] по [E.declent_ru(DATIVE)]!"), span_danger("[pluralize_ru(user.gender,"Ты хлещешь","Вы хлещете")] хвостом [C.declent_ru(ACCUSATIVE)] по [E.declent_ru(DATIVE)]!"))

		else  // Dealing damage to simplemobs, silicons
			C.apply_damage_type(damage_deal, type_of_damage)

		user.adjustStaminaLoss(active_implant ? implant.self_stamina_damage : 15)
		playsound(user.loc, active_implant ? implant.slash_sound : 'sound/weapons/slash.ogg', 50, FALSE)
		add_attack_logs(user, C, "whips tail, dealing [damage_deal] [type_of_damage] damage!")

		if(user.restrained() && prob(50))
			user.Weaken(4 SECONDS)
			user.visible_message(span_danger("[user.declent_ru(NOMINATIVE)] теря[pluralize_ru(user.gender,"ет","ют")] равновесие!"), span_danger("[pluralize_ru(user.gender,"Ты теряешь","Вы теряете")] равновесие!"))
			return

		if(user.getStaminaLoss() >= 60)
			to_chat(user, span_warning("Вы выбились из сил!"))
			return

/datum/action/innate/tail_cut/IsAvailable(show_message = FALSE)

	if(!..())
		return FALSE

	var/mob/living/carbon/human/user = owner
	var/obj/item/organ/internal/cyberimp/tail/blade/implant = user.get_organ_slot(INTERNAL_ORGAN_TAIL_DEVICE)
	if(!user.bodyparts_by_name[BODY_ZONE_TAIL])
		if(show_message)
			to_chat(user, span_warning("У вас НЕТ ХВОСТА!"))
		return FALSE

	var/active_implant = FALSE
	if(implant && implant.activated)
		active_implant = TRUE

	if(!istype(user.bodyparts_by_name[BODY_ZONE_TAIL], /obj/item/organ/external/tail/unathi) && !active_implant)
		if(show_message)
			to_chat(user, span_warning("У вас слабый хвост!"))
		return FALSE

	if((user.restrained() && user.pulledby) || user.buckled)
		if(show_message)
			to_chat(user, span_warning("Вам нужно больше свободы движений для взмаха хвостом!"))
		return FALSE

	return TRUE
