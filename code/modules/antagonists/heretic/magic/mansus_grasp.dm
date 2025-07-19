/obj/effect/proc_holder/spell/touch/mansus_grasp
	name = "Восприятие Мансуса"
	desc = "A touch spell that lets you channel the power of the Old Gods through your grip."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_grasp"
	sound = 'sound/items/welder.ogg'

	school = SCHOOL_EVOCATION
	base_cooldown = 10 SECONDS

	invocation = "R'CH T'H TR'TH!"
	invocation_type = INVOCATION_SHOUT
	// Mimes can cast it. Chaplains can cast it. Anyone can cast it, so long as they have a hand.
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	hand_path = /obj/item/melee/touch_attack/mansus_fist

/obj/effect/proc_holder/spell/touch/mansus_grasp/valid_target(atom/cast_on)
	return TRUE // This baby can hit anything

/obj/effect/proc_holder/spell/touch/mansus_grasp/can_cast(feedback = TRUE)
	return ..() && (!!isheretic(action.owner) || !!IS_LUNATIC(action.owner))

/*
/obj/effect/proc_holder/spell/touch/mansus_grasp/on_antimagic_triggered(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("The spell bounces off of [victim]!"),
		span_danger("The spell bounces off of you!"),
	)
*/

/obj/item/melee/touch_attack/mansus_fist/afterattack(atom/victim, mob/living/carbon/caster, proximity, params)
	if(!isliving(victim))
		return FALSE

	if(SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK, victim) & COMPONENT_BLOCK_HAND_USE)
		return FALSE

	var/mob/living/living_hit = victim
	living_hit.apply_damage(10, BRUTE/*, wound_bonus = CANT_WOUND*/)
	if(!iscarbon(victim))
		return TRUE

	var/mob/living/carbon/carbon_hit = victim

	// Cultists are momentarily disoriented by the stunning aura. Enough for both parties to go 'oh shit' but only a mild combat ability.
	// Cultists have an identical effect on their stun hand. The heretic's faster spell charge time is made up for by their lack of teammates.
	if(iscultist(carbon_hit))
		carbon_hit.AdjustKnockdown(0.5 SECONDS)
		carbon_hit.Confused(1.5 SECONDS, 3 SECONDS)
		carbon_hit.Dizzy(1.5 SECONDS, 3 SECONDS)
		//ADD_TRAIT(carbon_hit, TRAIT_NO_SIDE_KICK, REF(src)) // We don't want this to be a good stunning tool, just minor disorientation
		//addtimer(TRAIT_CALLBACK_REMOVE(carbon_hit, TRAIT_NO_SIDE_KICK, REF(src)), 1 SECONDS)

		var/old_color = carbon_hit.color
		carbon_hit.color = COLOR_CULT_RED
		animate(carbon_hit, color = old_color, time = 4 SECONDS, easing = EASE_IN)
		carbon_hit.mob_light2(range = 1.5, power = 2.5, color = COLOR_CULT_RED, duration = 0.5 SECONDS)
		playsound(carbon_hit, 'sound/effects/magic/curse.ogg', 50, TRUE)

		to_chat(caster, span_warning("An unholy force intervenes as you grasp [carbon_hit], absorbing most of the effects!"))
		to_chat(carbon_hit, span_warning("As [caster] grasps you with eldritch forces, your blood magic absorbs most of the effects!"))
		carbon_hit.balloon_alert_to_viewers("absorbed!")
		return TRUE

	carbon_hit.apply_status_effect(/*/datum/status_effect/speech/slurring/heretic*/ STATUS_EFFECT_CLOCK_CULT_SLUR, 4 SECONDS)
	carbon_hit.AdjustKnockdown(5 SECONDS)
	carbon_hit.adjustStaminaLoss(80)

	return TRUE


/obj/effect/proc_holder/spell/touch/mansus_grasp/click_alt(mob/victim)
	if(isliving(victim)) // if it's a living mob, go with our normal afterattack
		return ATTACK_CHAIN_PROCEED

	if(SEND_SIGNAL(action.owner, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, victim) & COMPONENT_USE_HAND)
		return ATTACK_CHAIN_PROCEED

	return ATTACK_CHAIN_PROCEED


/obj/item/melee/touch_attack/mansus_fist
	name = "Восприятие Мансуса"
	desc = "A sinister looking aura that distorts the flow of reality around it. \
		Causes knockdown, minor bruises, and major stamina damage. \
		It gains additional beneficial effects as you expand your knowledge of the Mansus."
	icon_state = "mansus"
	item_state = "mansus"


/obj/item/melee/touch_attack/mansus_fist/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You remove %THEEFFECT.", \
		tip_text = "Clear rune", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/heretic_rune), \
		time_to_remove = 0.4 SECONDS)

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
	user.visible_message(span_suicide("[user] covers [user.p_their()] face with [user.p_their()] sickly-looking hand! It looks like [user.p_theyre()] trying to commit suicide!"))
	var/mob/living/carbon/carbon_user = user //iscarbon already used in spell's parent
	var/obj/effect/proc_holder/spell/touch/mansus_grasp/source = attached_spell//?.resolve()
	if(QDELETED(source) || !isheretic(user))
		return SHAME

	if(user.can_block_magic(source.antimagic_flags))
		return SHAME

	var/escape_our_torment = 0
	while(carbon_user.stat == CONSCIOUS)
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

		source.attached_hand.afterattack(user, user)
		escape_our_torment++
		stoplag(0.4 SECONDS)

	return FIRELOSS
