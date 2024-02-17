
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
	var/implant_type = 1 // 0 - Unathi lash, 1 - Syndi blade, 2 - Lazer blade, 3 - Syndi lazer blade
	var/implant_type_buffer // UNATHI SPECIAL, YE YE
	var/datum/action/innate/tail_cut/implant_ability


/obj/item/organ/internal/cyberimp/tail/blade/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	implant_ability = new(src)

	update_implant(implant_type)

/obj/item/organ/internal/cyberimp/tail/blade/proc/update_implant(implant_type)

	switch(implant_type) // Change implant stats here

		if(0) // Unathi lash
			implant_ability.slash_strength = 1                       // Slash damage modifier, 5*slash_strength damage
			implant_ability.stamina_damage = 0                       // Stamina damage to others
			implant_ability.self_stamina_damage = 15                 // Stamina damage to self
			implant_ability.damage_type = BRUTE                      // BRUTE or BURN
			implant_ability.slash_sound = 'sound/weapons/slash.ogg'  // Sound of attack

		if(1) // Syndi blade
			implant_ability.slash_strength = 6
			implant_ability.stamina_damage = 0
			implant_ability.self_stamina_damage = 15
			implant_ability.damage_type = BRUTE
			implant_ability.slash_sound = 'sound/weapons/bladeslice.ogg'

		if(2) // NT lazer blade
			implant_ability.slash_strength = 3
			implant_ability.stamina_damage = 10
			implant_ability.self_stamina_damage = 10
			implant_ability.damage_type = BURN
			implant_ability.slash_sound = 'sound/weapons/blade1.ogg'

		if(3) // Syndi lazer blade
			implant_ability.slash_strength = 4
			implant_ability.stamina_damage = 20
			implant_ability.self_stamina_damage = 5
			implant_ability.damage_type = BURN
			implant_ability.slash_sound = 'sound/weapons/blade1.ogg'

/obj/item/organ/internal/cyberimp/tail/blade/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	var/obj/item/organ/internal/cyberimp/tail/blade/implant = owner.get_organ_slot(INTERNAL_ORGAN_TAIL)
	implant.implant_ability.Remove(owner)
	implant.implant_ability = null
	. = ..()

/obj/item/organ/internal/cyberimp/tail/blade/ui_action_click(mob/user, actiontype, leftclick)
	user = owner
	var/obj/item/organ/internal/cyberimp/tail/blade/implant = user.get_organ_slot(INTERNAL_ORGAN_TAIL)
	activated = !activated

	if(activated)

		if(isunathi(user))

			/// I have to do it all because of the unathi disabilities.dm...
			implant_type_buffer = implant_type
			implant_type = 0
			update_implant(implant_type)
			var/datum/species/unathi/U = user.dna.species
			implant_ability.slash_strength = U.tail_strength
			to_chat(user, span_notice("Вы выдвинули лезвия, делая свой хвост ещё опаснее."))
			return

		implant.implant_ability.Grant(user)
		to_chat(user, span_notice("Вы выдвинули лезвия из хвоста."))

	else

		if(isunathi(user))

			/// And back...
			implant_type = implant_type_buffer
			update_implant(implant_type)
			to_chat(user, span_notice("Вы убрали лезвия."))
			return

		implant.implant_ability.Remove(user)
		to_chat(user, span_notice("Вы убрали лезвия."))


/obj/item/organ/internal/cyberimp/tail/blade/standart
	name = "Tail blade implant"
	desc = "A technologically advanced version of the tail implant, compatible with any tail. If you have one."
	implant_type = 1

/obj/item/organ/internal/cyberimp/tail/blade/lazer
	name = "Tail lazer blade implant"
	desc = "A technologically advanced version of the tail implant, compatible with any tail. If you have one."
	implant_type = 2

/obj/item/organ/internal/cyberimp/tail/blade/lazer/syndi
	name = "Syndi lazer blade implant"
	desc = "A technologically advanced version of the tail implant, compatible with any tail. If you have one."
	implant_type = 3

/datum/action/innate/tail_cut
	name = "Разрез хвостом"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "tail"
	check_flags = AB_CHECK_LYING | AB_CHECK_CONSCIOUS | AB_CHECK_STUNNED

	var/haslash = 0
	var/slash_strength = 1
	var/stamina_damage = 0
	var/self_stamina_damage = 15
	var/damage_type = BRUTE
	var/slash_sound = 'sound/weapons/slash.ogg'

/datum/action/innate/tail_cut/Trigger(left_click = TRUE)
	if(IsAvailable(show_message = TRUE))
		. = ..()

/datum/action/innate/tail_cut/Activate()
	var/mob/living/carbon/human/user = owner

	if((user.restrained() && user.pulledby) || user.buckled)
		to_chat(user, span_warning("Вам нужно больше свободы движений для взмаха хвостом!"))
		return

	if(user.getStaminaLoss() >= 50)
		to_chat(user, span_warning("Вы слишком устали!"))
		return

	for(var/mob/living/carbon/human/C in orange(1))
		var/obj/item/organ/external/E = C.get_organ(pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_GROIN))

		if(E)
			user.changeNext_move(CLICK_CD_MELEE)
			user.visible_message(span_danger("[user.declent_ru(NOMINATIVE)] режет хвостом [C.declent_ru(ACCUSATIVE)] по [E.declent_ru(DATIVE)]!"), span_danger("[pluralize_ru(user.gender,"Ты хлещешь","Вы хлещете")] хвостом [C.declent_ru(ACCUSATIVE)] по [E.declent_ru(DATIVE)]!"))
			user.adjustStaminaLoss(self_stamina_damage)
			C.apply_damage(5 * slash_strength, damage_type, E)
			C.adjustStaminaLoss(stamina_damage)
			user.spin(10,1)
			playsound(user.loc, slash_sound, 50, 0)
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

	if(!user.bodyparts_by_name[BODY_ZONE_TAIL])
		if(show_message)
			to_chat(user, span_warning("У вас НЕТ ХВОСТА!"))
		return FALSE

	if(!istype(owner.get_organ_slot(INTERNAL_ORGAN_TAIL), /obj/item/organ/internal/cyberimp/tail/blade))
		if(show_message)
			to_chat(user, span_warning("У вас слабый хвост!"))
