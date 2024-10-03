/obj/item/melee/baton
	name = "police baton"
	desc = "A wooden truncheon for beating criminal scum."
	icon_state = "baton"
	item_state = "classic_baton"
	slot_flags = ITEM_SLOT_BELT
	force = 12 //9 hit crit
	w_class = WEIGHT_CLASS_NORMAL
	/// Whether this baton is active or not.
	var/active = TRUE
	/// Default wait time until can stun again.
	var/cooldown = 4 SECONDS
	/// Can we stun the target in harm intent, additionally to a normal attack?
	var/allows_stun_in_harm = FALSE
	/// Whether to skip attack in harm mode.
	var/skip_harm_attack = FALSE
	/// Can we stun cyborgs?
	var/affect_cyborgs = FALSE
	/// Can we stun bots?
	var/affect_bots = FALSE
	/// The length of the knockdown applied to a struck living, non-cyborg mob.
	var/knockdown_time = 1.5 SECONDS
	/// If affect_cyborg is TRUE, this is how long we stun cyborgs for on a hit.
	var/stun_time_cyborg = 5 SECONDS
	/// The length of the knockdown applied to the user on clumsy_check().
	var/clumsy_knockdown_time = 18 SECONDS
	/// How much stamina damage we deal on a successful hit against a living, non-cyborg mob.
	var/stamina_damage = 35
	/// Do we animate the "hit" when stunning something?
	var/stun_animation = TRUE
	/// Chance of causing force_say() when stunning a human mob.
	var/force_say_chance = 33
	/// The path of the default sound to play when we stun something.
	var/on_stun_sound = 'sound/effects/woodhit.ogg'
	/// The volume of the stun sound.
	var/on_stun_volume = 75
	/// Whether the stun attack is logged. Only relevant for abductor batons, which have different modes.
	var/log_stun_attack = TRUE
	/// Cooldown timestamp
	COOLDOWN_DECLARE(stun_cooldown)


/**
 * Ok, think of baton attacks like a melee attack chain:
 *
 * [/baton_attack()] comes first. It checks if the user is clumsy, human shields, martial defence and handles some messages and sounds.
 * * Depending on its return value, it'll either do a normal attack, continue to the next step or stop the attack.
 *
 * [/finalize_baton_attack()] is then called. It handles logging stuff, sound effects and calls baton_effect().
 * * The proc is also called in other situations such as throw impact. Basically when baton_attack()
 * * checks are either redundant or unnecessary.
 *
 * [/baton_effect()] is third in the line. It knockdowns targets, along other effects called in additional_effects_cyborg() and
 * * additional_effects_non_cyborg().
 *
 * Last but not least [/set_batoned()], which gives the target the IWASBATONED trait with UNIQUE_TRAIT_SOURCE(user) as source
 * * and then removes it after a cooldown has passed. Basically, it stops users from cheesing the cooldowns by dual wielding batons.
 *
 * TL;DR: [/baton_attack()] -> [/finalize_baton_attack()] -> [/baton_effect()] -> [/set_batoned()]
 */
/obj/item/melee/baton/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	add_fingerprint(user)
	switch(baton_attack(target, user))
		if(BATON_ATTACK_DONE)
			return ATTACK_CHAIN_PROCEED
		if(BATON_DO_NORMAL_ATTACK)
			return ..()
		if(BATON_ATTACKING)
			finalize_baton_attack(target, user)
			if(!skip_harm_attack && user.a_intent == INTENT_HARM)
				return ..(target, user, params, def_zone, stun_animation)
			return ATTACK_CHAIN_PROCEED_SUCCESS


/obj/item/melee/baton/proc/baton_attack(mob/living/target, mob/living/user)
	. = BATON_ATTACKING

	if(clumsy_check(user, target))
		return BATON_ATTACK_DONE

	if(!active)
		return BATON_DO_NORMAL_ATTACK

	if(!allows_stun_in_harm && user.a_intent == INTENT_HARM)
		return BATON_DO_NORMAL_ATTACK

	if(!COOLDOWN_FINISHED(src, stun_cooldown))
		if(user.a_intent == INTENT_HARM)
			return BATON_DO_NORMAL_ATTACK
		var/wait_desc = get_wait_description()
		if(wait_desc)
			to_chat(user, wait_desc)
		return BATON_ATTACK_DONE

	if(HAS_TRAIT_FROM(target, TRAIT_IWASBATONED, UNIQUE_TRAIT_SOURCE(user))) //no doublebaton abuse son!
		to_chat(user, span_danger("You fumble and miss [target]!"))
		return BATON_ATTACK_DONE

	if(stun_animation)
		user.do_attack_animation(target)

	var/list/attack_desc

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.check_shields(src, 0, "[user]'s [name]", ITEM_ATTACK))
			return BATON_ATTACK_DONE
		if(check_martial_counter(target, user))
			return BATON_ATTACK_DONE
		attack_desc = get_stun_description(target, user)

	else if(isrobot(target))
		if(affect_cyborgs)
			attack_desc = get_cyborg_stun_description(target, user)
		else
			attack_desc = get_unga_dunga_cyborg_stun_description(target, user)
			playsound(get_turf(src), 'sound/effects/bang.ogg', 10, TRUE) //bonk
			. = BATON_ATTACK_DONE

	else if(isbot(target))
		if(affect_bots)
			attack_desc = get_cyborg_stun_description(target, user)
		else
			attack_desc = get_unga_dunga_cyborg_stun_description(target, user)
			playsound(get_turf(src), 'sound/effects/bang.ogg', 10, TRUE)
			. = BATON_ATTACK_DONE
	else
		attack_desc = get_stun_description(target, user)

	if(attack_desc)
		target.visible_message(attack_desc["visible"], attack_desc["local"])


/obj/item/melee/baton/proc/finalize_baton_attack(mob/living/target, mob/living/user, in_attack_chain = TRUE)
	if(!in_attack_chain && HAS_TRAIT_FROM(target, TRAIT_IWASBATONED, UNIQUE_TRAIT_SOURCE(user)))
		return BATON_ATTACK_DONE

	COOLDOWN_START(src, stun_cooldown, cooldown)
	if(on_stun_sound)
		playsound(get_turf(src), on_stun_sound, on_stun_volume, TRUE, -1)
	if(user)
		target.lastattacker = user.real_name
		target.lastattackerckey = user.ckey
		if(log_stun_attack)
			add_attack_logs(user, target, "stun attacked")
	if(baton_effect(target, user) && user)
		set_batoned(target, user, cooldown)


/obj/item/melee/baton/proc/baton_effect(mob/living/target, mob/living/user, stun_override)
	if(isrobot(target))
		if(!affect_cyborgs)
			return FALSE
		var/mob/living/silicon/robot/cyborg = target
		cyborg.flash_eyes(3, affect_silicon = TRUE)
		cyborg.Stun((isnull(stun_override) ? stun_time_cyborg : stun_override))
		additional_effects_cyborg(cyborg, user)
	else if(isbot(target))
		if(!affect_bots)
			return FALSE
		var/mob/living/simple_animal/bot/bot = target
		bot.disable(isnull(stun_override) ? stun_time_cyborg : stun_override)
	else
		if(ishuman(target) && prob(force_say_chance))
			var/mob/living/carbon/human/human_target = target
			human_target.forcesay(GLOB.hit_appends)
		target.apply_damage(stamina_damage, STAMINA)
		target.Knockdown((isnull(stun_override) ? knockdown_time : stun_override))
		additional_effects_non_cyborg(target, user)
	return TRUE


/obj/item/melee/baton/proc/set_batoned(mob/living/target, mob/living/user, cooldown)
	if(!cooldown)
		return
	var/user_UID = UNIQUE_TRAIT_SOURCE(user)
	ADD_TRAIT(target, TRAIT_IWASBATONED, user_UID)
	addtimer(TRAIT_CALLBACK_REMOVE(target, TRAIT_IWASBATONED, user_UID), cooldown)


/obj/item/melee/baton/proc/clumsy_check(mob/living/user, mob/living/intented_target)
	if(!active || !HAS_TRAIT(user, TRAIT_CLUMSY) || prob(50))
		return FALSE
	user.visible_message(
		span_danger("[user] accidentally hits [user.p_them()]self over the head with [src]! What a doofus!"),
		span_userdanger("You accidentally hit yourself over the head with [src]!"),
	)

	if(isrobot(user))
		if(affect_cyborgs)
			var/mob/living/silicon/robot/cyborg = user
			cyborg.flash_eyes(3, affect_silicon = TRUE)
			cyborg.Stun(clumsy_knockdown_time)
			additional_effects_cyborg(user, user) // user is the target here
			if(on_stun_sound)
				playsound(get_turf(src), on_stun_sound, on_stun_volume, TRUE, -1)
		else
			playsound(get_turf(src), 'sound/effects/bang.ogg', 10, TRUE)
	else
		if(ishuman(user))
			var/mob/living/carbon/human/human_user = user
			human_user.forcesay(GLOB.hit_appends)
		user.Knockdown(clumsy_knockdown_time)
		user.apply_damage(stamina_damage, STAMINA)
		additional_effects_non_cyborg(user, user) // user is the target here
		if(on_stun_sound)
			playsound(get_turf(src), on_stun_sound, on_stun_volume, TRUE, -1)

	user.apply_damage(2 * force, BRUTE, BODY_ZONE_HEAD, used_weapon = src)

	add_attack_logs(user, user, "accidentally stun attacked [user.p_them()]self due to their clumsiness")
	if(stun_animation)
		user.do_attack_animation(user)
	return TRUE


/// Description for trying to stun when still on cooldown.
/obj/item/melee/baton/proc/get_wait_description()
	return


/// Default message for stunning a living, non-cyborg mob.
/obj/item/melee/baton/proc/get_stun_description(mob/living/target, mob/living/user)
	. = list()
	.["visible"] = span_danger("[user] knocks [target] down with [src]!")
	.["local"] = span_userdanger("[user] knocks you down with [src]!")



/// Default message for stunning a cyborg.
/obj/item/melee/baton/proc/get_cyborg_stun_description(mob/living/target, mob/living/user)
	. = list()
	.["visible"] = span_danger("[user] pulses [target]'s sensors with the baton!")
	.["local"] = span_danger("You pulse [target]'s sensors with the baton!")


/// Default message for trying to stun a cyborg with a baton that can't stun cyborgs.
/obj/item/melee/baton/proc/get_unga_dunga_cyborg_stun_description(mob/living/target, mob/living/user)
	. = list()
	.["visible"] = span_danger("[user] tries to knock down [target] with [src], and predictably fails!") //look at this duuuuuude
	.["local"] = span_userdanger("[user] tries to... knock you down with [src]?") //look at the top of his head!


/// Contains any special effects that we apply to living, non-cyborg mobs we stun. Does not include applying a knockdown, dealing stamina damage, etc.
/obj/item/melee/baton/proc/additional_effects_non_cyborg(mob/living/target, mob/living/user)
	return


/// Contains any special effects that we apply to cyborgs we stun. Does not include flashing the cyborg's screen, hardstunning them, etc.
/obj/item/melee/baton/proc/additional_effects_cyborg(mob/living/target, mob/living/user)
	return


/obj/item/melee/baton/ntcane
	name = "fancy cane"
	desc = "A cane with special engraving on it. It seems well suited for fending off assailants..."
	icon_state = "cane_nt"
	item_state = "cane_nt"
	needs_permit = FALSE


// Telescopic baton
/obj/item/melee/baton/telescopic
	name = "telescopic baton"
	desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
	icon_state = "telebaton"
	item_state = null
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	needs_permit = FALSE
	active = FALSE
	force = 0
	attack_verb = list("hit", "poked")
	clumsy_knockdown_time = 15 SECONDS
	/// The sound effecte played when our baton is extended.
	var/extend_sound = 'sound/weapons/batonextend.ogg'
	/// The inhand iconstate used when our baton is extended.
	var/extend_item_state = "nullrod"
	/// The force on extension.
	var/extend_force = 10


/obj/item/melee/baton/telescopic/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		force_on = src.extend_force, \
		hitsound_on = src.hitsound, \
		hitsound_off = src.hitsound, \
		w_class_on = WEIGHT_CLASS_NORMAL, \
		item_state_on = src.extend_item_state, \
		clumsy_check_prob = 0, \
		attack_verb_on = list("smacked", "struck", "cracked", "beaten"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))


/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives feedback to the user and applies active state.
 */
/obj/item/melee/baton/telescopic/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	src.active = active
	if(user)
		balloon_alert(user, "[active ? "разложено" : "сложено"]")
	playsound(src, extend_sound, 50, TRUE)
	return COMPONENT_NO_DEFAULT_MESSAGE

