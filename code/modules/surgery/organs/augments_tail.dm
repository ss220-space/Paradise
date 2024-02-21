
/obj/item/organ/internal/cyberimp/tail
	name = "Tail-mounted implant"
	desc = "You shoudn't see this! Immediately report to a coder."
	parent_organ_zone = BODY_ZONE_TAIL
	slot = INTERNAL_ORGAN_TAIL
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_NORMAL
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/sound_on = 'sound/mecha/mechmove03.ogg'
	var/sound_off = 'sound/mecha/mechmove03.ogg'

/obj/item/organ/internal/cyberimp/tail/blade
	name = "Tail blade implant"
	desc = "A technologically advanced version of the tail implant, compatible with any tail. If you have one."
	var/activated = FALSE
	implant_color = "#585857"
	var/datum/action/innate/tail_cut/implant_ability

	var/slash_strength
	var/stamina_damage
	var/self_stamina_damage
	var/damage_type
	var/slash_sound

/obj/item/organ/internal/cyberimp/tail/blade/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	if(!implant_ability)
		implant_ability = new(src)

/obj/item/organ/internal/cyberimp/tail/blade/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	if(implant_ability)
		implant_ability.Remove(owner)
		implant_ability = null
	. = ..()

/obj/item/organ/internal/cyberimp/tail/blade/ui_action_click(mob/user, actiontype, leftclick)
	user = owner
	var/obj/item/organ/internal/cyberimp/tail/blade/implant = user.get_organ_slot(INTERNAL_ORGAN_TAIL)
	var/datum/action/innate/tail_cut/hascut = locate() in user.actions
	activated = !activated

	if(activated)

		if(hascut) // Prevents from double action icons for unathies
			to_chat(user, span_notice("Вы выдвинули лезвия, делая свой хвост ещё опаснее."))
			return
		implant.implant_ability.Grant(user)
		to_chat(user, span_notice("Вы выдвинули лезвия из хвоста."))

	else

		to_chat(user, span_notice("Вы убрали лезвия."))
		implant.implant_ability.Remove(user)



/obj/item/organ/internal/cyberimp/tail/blade/standard
	name = "Tail blade implant"
	desc = "A technologically advanced version of the tail implant, compatible with any tail. If you have one."

	slash_strength = 6
	stamina_damage = 0
	self_stamina_damage = 15
	damage_type = BRUTE
	slash_sound = 'sound/weapons/bladeslice.ogg'


/obj/item/organ/internal/cyberimp/tail/blade/lazer
	name = "Tail lazer blade implant"
	desc = "A technologically advanced version of the tail implant, compatible with any tail. If you have one."

	slash_strength = 3
	stamina_damage = 10
	self_stamina_damage = 10
	damage_type = BURN
	slash_sound = 'sound/weapons/blade1.ogg'


/obj/item/organ/internal/cyberimp/tail/blade/lazer/syndi
	name = "Syndi lazer blade implant"
	desc = "A technologically advanced version of the tail implant, compatible with any tail. If you have one."

	slash_strength = 4
	stamina_damage = 20
	self_stamina_damage = 5
	damage_type = BURN
	slash_sound = 'sound/weapons/blade1.ogg'

/datum/action/innate/tail_cut
	name = "Разрез хвостом"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "tail"
	check_flags = AB_CHECK_LYING | AB_CHECK_CONSCIOUS | AB_CHECK_STUNNED

/datum/action/innate/tail_cut/Trigger(left_click = TRUE)
	if(IsAvailable(show_message = TRUE))
		. = ..()


/datum/action/innate/tail_cut/Activate()
	var/mob/living/carbon/human/user = owner
	var/obj/item/organ/internal/cyberimp/tail/blade/implant = user.get_organ_slot(INTERNAL_ORGAN_TAIL)
	var/datum/species/unathi/U // For unathi disabilities
	var/active_implant = FALSE

	if((user.restrained() && user.pulledby) || user.buckled)
		to_chat(user, span_warning("Вам нужно больше свободы движений для взмаха хвостом!"))
		return

	if(user.getStaminaLoss() >= 50)
		to_chat(user, span_warning("Вы слишком устали!"))
		return

	if(implant && implant.activated) // Prevents excepcion if you dont have the implant, but unathi
		active_implant = TRUE

	if(!istype(user.bodyparts_by_name[BODY_ZONE_TAIL], /obj/item/organ/external/tail/unathi) && !active_implant)
		to_chat(user, span_warning("У вас слабый хвост!"))
		return

		/// If the user has an implant, we take its values, if not, we take the values from the old unathi's tail_lash (unathi special)
	for(var/mob/living/carbon/human/C in orange(1))
		var/obj/item/organ/external/E = C.get_organ(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_GROIN))

		if(E)
			user.visible_message(span_danger("[user.declent_ru(NOMINATIVE)] режет хвостом [C.declent_ru(ACCUSATIVE)] по [E.declent_ru(DATIVE)]!"), span_danger("[pluralize_ru(user.gender,"Ты хлещешь","Вы хлещете")] хвостом [C.declent_ru(ACCUSATIVE)] по [E.declent_ru(DATIVE)]!"))
			user.adjustStaminaLoss(active_implant ? implant.self_stamina_damage : 15)

			if(isunathi(user))
				U = user.dna.species

			else if(!isunathi(user) && !implant) // Not unathi, no implant, where did you get tail cut?
				return

			C.apply_damage(active_implant ? implant.slash_strength * 5 : U.tail_strength * 5, active_implant ? implant.damage_type : BRUTE, E)
			C.adjustStaminaLoss(active_implant ? implant.stamina_damage : 0)
			user.spin(10,1)
			playsound(user.loc, active_implant ? implant.slash_sound : 'sound/weapons/slash.ogg', 50, 0)
			add_attack_logs(user, C, "tail whipped")

			if(user.restrained() && prob(50))
				user.Weaken(4 SECONDS)
				user.visible_message(span_danger("[user.declent_ru(NOMINATIVE)] теря[pluralize_ru(user.gender,"ет","ют")] равновесие!"), span_danger("[pluralize_ru(user.gender,"Ты теряешь","Вы теряете")] равновесие!"))
				return

			if(user.getStaminaLoss() >= 60)
				to_chat(user, span_warning("Вы выбились из сил!"))
				return

/datum/action/innate/tail_cut/IsAvailable(show_message = FALSE)
	. = ..()
	var/mob/living/carbon/human/user = owner

	if(!.)
		return

	if(!user.bodyparts_by_name[BODY_ZONE_TAIL])
		if(show_message)
			to_chat(user, span_warning("У вас НЕТ ХВОСТА!"))
		return FALSE

