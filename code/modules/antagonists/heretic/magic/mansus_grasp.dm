/obj/effect/proc_holder/spell/touch/mansus_grasp
	name = "Хватка Обители"
	desc = "Заклинание, позволяющее направлять силу Древних Богов через вашу руку."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_grasp"
	action_targeting_overlay = "bg_spell_border_active_red"
	sound = 'sound/items/welder.ogg'

	clothes_req = FALSE
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	hand_path = /obj/item/melee/touch_attack/mansus_fist


/obj/effect/proc_holder/spell/touch/mansus_grasp/valid_target(atom/cast_on)
	return TRUE // This baby can hit anything


/obj/effect/proc_holder/spell/touch/mansus_grasp/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	return ..() && (IS_HERETIC(user) || !!IS_LUNATIC(user))


/obj/item/melee/touch_attack/mansus_fist/proc/attack_effect(atom/victim, mob/living/carbon/caster)
	if(SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, victim) & COMPONENT_BLOCK_HAND_USE)
		return

	var/mob/living/living_hit = victim
	living_hit.apply_damage(10, BRUTE/*, wound_bonus = CANT_WOUND*/)
	caster.apply_status_effect(/datum/status_effect/mansus_bless)
	if(!iscarbon(victim))
		return

	var/mob/living/carbon/carbon_hit = victim

	if(!iscultist(carbon_hit))
		carbon_hit.apply_status_effect(/*/datum/status_effect/speech/slurring/heretic*/ STATUS_EFFECT_CLOCK_CULT_SLUR, 4 SECONDS)
		carbon_hit.AdjustKnockdown(5 SECONDS)
		carbon_hit.adjustStaminaLoss(80)
		return

	carbon_hit.AdjustKnockdown(0.5 SECONDS)
	carbon_hit.AdjustConfused(1.5 SECONDS, bound_upper = 3 SECONDS)
	carbon_hit.AdjustDizzy(1.5 SECONDS, bound_upper = 3 SECONDS)

	var/old_color = carbon_hit.color
	carbon_hit.color = COLOR_CULT_RED
	animate(carbon_hit, color = old_color, time = 4 SECONDS, easing = EASE_IN)
	carbon_hit.mob_light(range = 1.5, power = 2.5, color = COLOR_CULT_RED, duration = 0.5 SECONDS)
	playsound(carbon_hit, 'sound/magic/curse.ogg', 50, TRUE)

	to_chat(caster, span_warning("Нечестивая сила вмешивается, поглощая большую часть эффектов!"))
	to_chat(carbon_hit, span_warning("[DECLENT_RU_CAP(caster, NOMINATIVE)] применяет к вам потусторонние силы, но ваша магия крови поглощает большую часть эффектов!"))
	carbon_hit.balloon_alert_to_viewers("поглощено!")
	return


/obj/item/melee/touch_attack/mansus_fist/pre_attack_secondary(atom/victim, mob/living/carbon/caster, list/modifiers, list/attack_modifiers)
	if(isliving(victim))
		return SECONDARY_ATTACK_CALL_NORMAL
	if(SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, victim) & COMPONENT_USE_HAND)
		if(attached_spell)
			attached_spell.perform(list(), user = caster)
		qdel(src)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN


/obj/item/melee/touch_attack/mansus_fist/afterattack(atom/victim, mob/living/carbon/caster, proximity, list/modifiers, status)
	if(!proximity)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(isturf(victim))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!isliving(victim))
		return FALSE

	attack_effect(victim, caster)
	return ..()


/obj/item/melee/touch_attack/mansus_fist
	name = "Хватка Обители"
	desc = "Ваша рука пропитана зловещей аурой, способной искажать реальность. \
			Наносит лёгкие ушибы, значительный урон выносливости и сбивает с ног. \
			По мере того, как вы расширяете свои знания об Обители, она приобретает дополнительные эффекты."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "mansus"
	item_state = "mansus"
	lefthand_file = 'icons/mob/inhands/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/touchspell_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL | NOBLUDGEON
	catchphrase = "Р'СКР ПР'ВД'!"


/obj/item/melee/touch_attack/mansus_fist/get_ru_names()
	return alist(
		NOMINATIVE = "Хватка Обители",
		GENITIVE = "Хватки Обители",
		DATIVE = "Хватке Обители",
		ACCUSATIVE = "Хватку Обители",
		INSTRUMENTAL = "Хваткой Обители",
		PREPOSITIONAL = "Хватке Обители",
	)


/obj/item/melee/touch_attack/mansus_fist/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You remove %THEEFFECT.", \
		tip_text = "Не забудьте стереть руну", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/decal/heretic_rune), \
		time_to_remove = 0.4 SECONDS)
	set_grasp_indicator(TRUE)


/obj/item/melee/touch_attack/mansus_fist/Destroy()
	set_grasp_indicator(FALSE)
	return ..()


/// Toggles the red "armed" border on the grasp's action button via the spell's action.targeting_process.
/obj/item/melee/touch_attack/mansus_fist/proc/set_grasp_indicator(active)
	var/datum/action/spell_action = attached_spell?.action
	if(!spell_action)
		return
	spell_action.targeting_process = active
	spell_action.UpdateButtonIcon()


/// Callback for effect_remover component.
/obj/item/melee/touch_attack/mansus_fist/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/drawing_heretic_rune/fail(target.loc)

	remove_hand_with_no_refund(user)

/*
/obj/item/melee/touch_attack/mansus_fist/ignition_effect(atom/to_light, mob/user)
	. = span_rose("[user] effortlessly snaps [user.p_their()] fingers near [to_light], igniting it with eldritch energies. Fucking badass!")
	remove_hand_with_no_refund(user)
*/

/obj/item/melee/touch_attack/mansus_fist/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user.declent_ru(NOMINATIVE)] делает фейспалм [declent_ru(INSTRUMENTAL)]! Похоже [GEND_HE_SHE(user)] пыта[PLUR_ET_YUT(user)]ся убить себя!"))
	var/mob/living/carbon/carbon_user = user //iscarbon already used in spell's parent
	var/obj/effect/proc_holder/spell/touch/mansus_grasp/source = attached_spell//?.resolve()
	if(QDELETED(source) || !IS_HERETIC(user))
		return SHAME

	if(user.can_block_magic(source.antimagic_flags))
		return SHAME

	var/escape_our_torment = 0
	while(carbon_user.stat != DEAD)
		if(QDELETED(src) || QDELETED(user))
			return SHAME

		if(escape_our_torment > 20) //Stops us from infinitely stunning ourselves if we're just not taking the damage
			return FIRELOSS

		if(prob(70))
			carbon_user.adjustFireLoss(20)
			playsound(carbon_user, 'sound/effects/wounds/sizzle1.ogg', 70, vary = TRUE)
			if(prob(50))
				carbon_user.emote("scream")
				carbon_user.Stuttering(26 SECONDS)

		attack_effect(user, user)
		escape_our_torment++
		stoplag(0.4 SECONDS)

	return FIRELOSS
