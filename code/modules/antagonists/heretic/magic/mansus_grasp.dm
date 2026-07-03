/obj/effect/proc_holder/spell/touch/mansus_grasp
	name = "Прикосновение Мансуса"
	desc = "Заклинание позволяющее направлять силу Древних Богов через вашу руку."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_grasp"
	// While the grasp is charged into a hand, the action button wears the red "armed" border until the
	// grasp is spent - the fist toggles action.targeting_process on/off.
	action_targeting_overlay = "bg_spell_border_active_red"
	sound = 'sound/items/welder.ogg'

	clothes_req = FALSE
	// Mimes can cast it. Chaplains can cast it. Anyone can cast it, so long as they have a hand.
	spell_requirements = SPELL_CASTABLE_WITHOUT_INVOCATION

	hand_path = /obj/item/melee/touch_attack/mansus_fist


/obj/effect/proc_holder/spell/touch/mansus_grasp/valid_target(atom/cast_on)
	return TRUE // This baby can hit anything


/obj/effect/proc_holder/spell/touch/mansus_grasp/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	return ..() && (isheretic(user) || !!IS_LUNATIC(user))


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


// Right-click on a non-living target (airlock/wall/structure/turf) fires the secondary grasp (Rust/Lock
// path effects). We do it HERE, in pre_attack_secondary, because this runs at the very start of the attack
// chain (melee_attack_chain) - BEFORE the target's own attackby. Doing it in afterattack failed on doors:
// /obj/machinery/door/airlock/attackby would try to open the door (or shock us) and return
// ATTACK_CHAIN_BLOCKED_ALL, skipping afterattack entirely, so the grasp never fired and the airlock
// survived. Running before attackby makes the corrode/smash reliable. Living targets fall through to the
// normal (primary) combat grasp in afterattack.
/obj/item/melee/touch_attack/mansus_fist/pre_attack_secondary(atom/victim, mob/living/carbon/caster, list/modifiers, list/attack_modifiers)
	if(isliving(victim))
		return SECONDARY_ATTACK_CALL_NORMAL
	if(SEND_SIGNAL(caster, COMSIG_HERETIC_MANSUS_GRASP_ATTACK_SECONDARY, victim) & COMPONENT_USE_HAND)
		// Consume the hand AND start the spell's cooldown, exactly like the primary grasp (godhand's
		// afterattack runs attached_spell.perform()). Just deleting the hand without recharging would let
		// the secondary grasp be spammed with no cooldown. perform() also fires the invocation/sound.
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
	name = "Прикосновение Мансуса"
	desc = "Ваша рука пропитана зловещей аурой, способной искажать реальнось. \
			Вызывает нокдаун, лёгкие ушибы и значительный урон выносливости. \
			По мере того, как вы расширяете свои знания о Мансусе, она приобретает дополнительные эффекты."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "mansus"
	item_state = "mansus"
	lefthand_file = 'icons/mob/inhands/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/touchspell_righthand.dmi'
	// NOBLUDGEON so the grasp isn't treated as a melee weapon: without it, right-clicking an airlock on a
	// non-harm intent makes /obj/machinery/door/attackby run try_to_activate_door() and return
	// ATTACK_CHAIN_BLOCKED_ALL, which skips afterattack() - so the secondary (Rust) grasp never fired and
	// the airlock survived. With NOBLUDGEON the door lets the click through to afterattack.
	item_flags = ABSTRACT | DROPDEL | NOBLUDGEON
	catchphrase = "Р'СКР ПР'ВД'!"


/obj/item/melee/touch_attack/mansus_fist/get_ru_names()
	return alist(
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
	// Light up the action button's red "armed" border while the grasp is charged in a hand.
	set_grasp_indicator(TRUE)


/obj/item/melee/touch_attack/mansus_fist/Destroy()
	// Clear the armed border BEFORE the parent nulls our spell link. Covers every way the fist leaves the
	// hand - using the grasp, withdrawing it, dropping it, DROPDEL - so the border lasts exactly "until use".
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
