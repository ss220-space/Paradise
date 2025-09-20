/obj/effect/proc_holder/spell/touch/mansus_grasp
	name = "Прикосновение Мансуса"
	desc = "Заклинание позволяющее направлять силу Древних Богов через вашу руку."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_grasp"
	sound = 'sound/items/welder.ogg'

	clothes_req = FALSE
	// Mimes can cast it. Chaplains can cast it. Anyone can cast it, so long as they have a hand.
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	hand_path = /obj/item/melee/touch_attack/mansus_fist


/obj/effect/proc_holder/spell/touch/mansus_grasp/valid_target(atom/cast_on)
	return TRUE // This baby can hit anything


/obj/effect/proc_holder/spell/touch/mansus_grasp/can_cast(feedback = TRUE)
	return ..() && (isheretic(action.owner) || !!IS_LUNATIC(action.owner))


// Used for suicide
/obj/item/melee/touch_attack/mansus_fist/proc/attack_effect(atom/victim, mob/living/carbon/caster)
	if(SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, victim) & COMPONENT_BLOCK_HAND_USE)
		return

	var/mob/living/living_hit = victim
	living_hit.apply_damage(10, BRUTE/*, wound_bonus = CANT_WOUND*/)
	caster.apply_status_effect(/datum/status_effect/mansus_bless)
	if(!iscarbon(victim))
		return

	var/mob/living/carbon/carbon_hit = victim

	// Cultists are momentarily disoriented by the stunning aura. Enough for both parties to go 'oh shit' but only a mild combat ability.
	// Cultists have an identical effect on their stun hand. The heretic's faster spell charge time is made up for by their lack of teammates.
	if(!iscultist(carbon_hit))
		carbon_hit.apply_status_effect(/*/datum/status_effect/speech/slurring/heretic*/ STATUS_EFFECT_CLOCK_CULT_SLUR, 4 SECONDS)
		carbon_hit.AdjustKnockdown(5 SECONDS)
		carbon_hit.adjustStaminaLoss(80)
		return

	carbon_hit.AdjustKnockdown(0.5 SECONDS)
	carbon_hit.Confused(1.5 SECONDS, 3 SECONDS)
	carbon_hit.Dizzy(1.5 SECONDS, 3 SECONDS)
	//ADD_TRAIT(carbon_hit, TRAIT_NO_SIDE_KICK, UID()) // We don't want this to be a good stunning tool, just minor disorientation
	//addtimer(TRAIT_CALLBACK_REMOVE(carbon_hit, TRAIT_NO_SIDE_KICK, UID()), 1 SECONDS)

	var/old_color = carbon_hit.color
	carbon_hit.color = COLOR_CULT_RED
	animate(carbon_hit, color = old_color, time = 4 SECONDS, easing = EASE_IN)
	carbon_hit.mob_light2(range = 1.5, power = 2.5, color = COLOR_CULT_RED, duration = 0.5 SECONDS)
	playsound(carbon_hit, 'sound/magic/curse.ogg', 50, TRUE)

	to_chat(caster, span_warning("Нечестивая сила вмешивается, поглощая большую часть эффектов!"))
	to_chat(carbon_hit, span_warning("[caster.declent_ru(NOMINATIVE)] применяет к вам потусторонние силы, но ваша магия крови поглощает большую часть эффектов!"))
	carbon_hit.balloon_alert_to_viewers("поглощено!")
	return


/obj/item/melee/touch_attack/mansus_fist/afterattack(atom/victim, mob/living/carbon/caster, proximity, params)
	if(!proximity)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!mode)
		SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, victim)
		return ..()

	if(isturf(victim))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!isliving(victim))
		return FALSE

	attack_effect(victim, caster)
	return ..()


/obj/item/melee/touch_attack/mansus_fist
	name = "Прикосновение Мансуса"
	desc = "Ваша рука пропитана зловещей аурой, способной искажать реальнось. \
			Вызывает нокдаун, лёгкие ушибы и значительный урон выносливости. \
			По мере того, как вы расширяете свои знания о Мансусе, она приобретает дополнительные эффекты."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "mansus"
	item_state = "mansus"
	catchphrase = "Р'СКР ПР'ВД'!"
	var/mode = TRUE


/obj/item/melee/touch_attack/mansus_fist/get_ru_names()
	return list(
		NOMINATIVE = "Прикосновение Мансуса",
		GENITIVE = "Прикосновения Мансуса",
		DATIVE = "Прикосновению Мансуса",
		ACCUSATIVE = "Прикосновение Мансуса",
		INSTRUMENTAL = "Прикосновением Мансуса",
		PREPOSITIONAL = "Прикосновении Мансуса",
	)


/obj/item/melee/touch_attack/mansus_fist/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You remove %THEEFFECT.", \
		tip_text = "Не забудьте стереть руну", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/decal/heretic_rune), \
		time_to_remove = 0.4 SECONDS)


/obj/item/melee/touch_attack/mansus_fist/attack_self(mob/user)
	. = ..()
	mode = !mode
	user.balloon_alert(user, "альтернативное взаимодействие в[mode ? "ы" : ""]ключено")


/*
 * Callback for effect_remover component.
 */
/obj/item/melee/touch_attack/mansus_fist/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/drawing_heretic_rune/fail(target.loc, target/*.greyscale_colors*/)
	//var/obj/effect/proc_holder/spell/touch/mansus_grasp/grasp = attached_spell?.resolve()
	//grasp?.spell_feedback(user)

	remove_hand_with_no_refund(user)

/*
/obj/item/melee/touch_attack/mansus_fist/ignition_effect(atom/to_light, mob/user)
	. = span_rose("[user] effortlessly snaps [user.p_their()] fingers near [to_light], igniting it with eldritch energies. Fucking badass!")
	remove_hand_with_no_refund(user)
*/

/obj/item/melee/touch_attack/mansus_fist/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user.declent_ru(NOMINATIVE)] делает фейспалм [declent_ru(INSTRUMENTAL)]! Похоже [genderize_ru(user.gender, "он", "она", "оно", "они")] пыта[pluralize_ru(user.gender, "е", "ю")]тся убить себя!"))
	var/mob/living/carbon/carbon_user = user //iscarbon already used in spell's parent
	var/obj/effect/proc_holder/spell/touch/mansus_grasp/source = attached_spell//?.resolve()
	if(QDELETED(source) || !isheretic(user))
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
