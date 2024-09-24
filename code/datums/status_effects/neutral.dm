//entirely neutral or internal status effects go here

/datum/status_effect/crusher_damage //tracks the damage dealt to this mob by kinetic crushers
	id = "crusher_damage"
	duration = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = null
	var/total_damage = 0

/datum/status_effect/syphon_mark
	id = "syphon_mark"
	duration = 50
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	var/obj/item/borg/upgrade/modkit/bounty/reward_target


/datum/status_effect/syphon_mark/on_creation(mob/living/new_owner, obj/item/borg/upgrade/modkit/bounty/new_reward_target)
	. = ..()
	if(.)
		reward_target = new_reward_target


/datum/status_effect/syphon_mark/on_apply()
	if(owner.stat == DEAD)
		return FALSE
	return ..()


/datum/status_effect/syphon_mark/proc/get_kill()
	if(!QDELETED(reward_target))
		reward_target.get_kill(owner)


/datum/status_effect/syphon_mark/tick(seconds_between_ticks)
	if(owner.stat == DEAD)
		get_kill()
		qdel(src)


/datum/status_effect/syphon_mark/on_remove()
	get_kill()
	. = ..()

/datum/status_effect/staring
	id = "staring"
	alert_type = null
	status_type = STATUS_EFFECT_UNIQUE
	var/mob/living/target
	var/target_gender
	var/target_species

/datum/status_effect/staring/on_creation(mob/living/new_owner, new_duration, new_target, new_target_gender, new_target_species)
	if(!new_duration)
		qdel(src)
		return
	duration = new_duration
	. = ..()
	target = new_target
	target_gender = new_target_gender
	target_species = new_target_species

/datum/status_effect/staring/proc/catch_look(mob/living/opponent)
	if(target == opponent)
		to_chat(owner, span_notice("[opponent.name] catch your look!"))
		to_chat(opponent, span_notice("[owner.name] catch your look!"))
		var/list/loved_ones = list(MALE, FEMALE)
		if(!ishuman(owner) || !(target_gender in loved_ones) || !(owner.gender in loved_ones))
			return
		var/mob/living/carbon/human/human_owner = owner
		if(target_gender != human_owner.gender && target_species == human_owner.dna.species.name && prob(5))
			owner.emote("blush")
			to_chat(owner, span_danger("You feel something burning in your chest..."))


/datum/status_effect/high_five
	id = "high_five"
	duration = 10 SECONDS
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	/// Message displayed when wizards perform this together
	var/critical_success = "high-five EPICALLY!"
	/// Message displayed when normal people perform this together
	var/success = "high-five!"
	/// Message displayed when this status effect is applied.
	var/request = "ищ%(ет,ут)% кому бы дать пятюню..."
	/// Item to be shown in the pop-up balloon.
	var/obj/item/item_path = /obj/item/latexballon
	/// Sound effect played when this emote is completed.
	var/sound_effect = 'sound/weapons/slap.ogg'


/// So we don't leave folks with god-mode
/datum/status_effect/high_five/proc/wiz_cleanup(mob/living/carbon/user, mob/living/carbon/highfived)
	REMOVE_TRAIT(user, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src))
	REMOVE_TRAIT(highfived, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src))
	user.remove_status_effect(type)
	highfived.remove_status_effect(type)


/datum/status_effect/high_five/on_apply()
	if(!iscarbon(owner))
		return FALSE
	. = ..()

	var/mob/living/carbon/user = owner
	var/is_wiz = iswizard(user)
	var/both_wiz = FALSE
	for(var/mob/living/carbon/check in (orange(1, user) - user))
		if(!check.has_status_effect(type))
			continue
		if(is_wiz && iswizard(check))
			user.visible_message(span_dangerbigger("<b>[user.name]</b> and <b>[check.name]</b> [critical_success]"))
			ADD_TRAIT(user, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src))
			ADD_TRAIT(check, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src))
			explosion(get_turf(user), 5, 2, 1, 3, cause = id)
			// explosions have a spawn so this makes sure that we don't get gibbed
			addtimer(CALLBACK(src, PROC_REF(wiz_cleanup), user, check), 0.3 SECONDS) //I want to be sure this lasts long enough, with lag.
			add_attack_logs(user, check, "caused a wizard [id] explosion")
			both_wiz = TRUE
		user.do_attack_animation(check, no_effect = TRUE)
		check.do_attack_animation(user, no_effect = TRUE)
		playsound(user, sound_effect, 80)
		if(!both_wiz)
			user.visible_message(span_notice("<b>[user.name]</b> and <b>[check.name]</b> [success]"))
			user.remove_status_effect(type)
			check.remove_status_effect(type)
			return FALSE
		return TRUE // DO NOT AUTOREMOVE

	owner.custom_emote(EMOTE_VISIBLE, request)
	//owner.create_point_bubble_from_path(item_path, FALSE)	// later


/datum/status_effect/high_five/on_timeout()
	owner.visible_message("[owner] [get_missed_message()]")


/datum/status_effect/high_five/proc/get_missed_message()
	var/list/missed_highfive_messages = list(
		"lowers [owner.p_their()] hand, it looks like [owner.p_they()] [owner.p_were()] left hanging...",
		"seems to awkwardly wave at nobody in particular.",
		"moves [owner.p_their()] hand directly to [owner.p_their()] forehead in shame.",
		"fully commits and high-fives empty space.",
		"high-fives [owner.p_their()] other hand shamefully before wiping away a tear.",
		"goes for a handshake, then a fistbump, before pulling [owner.p_their()] hand back...? <i>What [owner.p_are()] [owner.p_they()] doing?</i>"
	)
	return pick(missed_highfive_messages)


/datum/status_effect/high_five/dap
	id = "dap"
	critical_success = "dap each other up EPICALLY!"
	success = "dap each other up!"
	request = "ищ%(ет,ут)% с кем бы побрататься..."
	sound_effect = 'sound/effects/snap.ogg'
	item_path = /obj/item/melee/touch_attack/fake_disintegrate  // EI-NATH!


/datum/status_effect/high_five/dap/get_missed_message()
	return "sadly can't find anybody to give daps to, and daps [owner.p_themselves()]. Shameful."


/datum/status_effect/high_five/handshake
	id = "handshake"
	critical_success = "give each other an EPIC handshake!"
	success = "give each other a handshake!"
	request = "ищ%(ет,ут)% кому бы пожать руку..."
	sound_effect = 'sound/weapons/thudswoosh.ogg'


/datum/status_effect/high_five/handshake/get_missed_message()
	var/list/missed_messages = list(
		"drops [owner.p_their()] hand, shamefully.",
		"grabs [owner.p_their()] outstretched hand with [owner.p_their()] other hand and gives [owner.p_themselves()] a handshake.",
		"balls [owner.p_their()] hand into a fist, slowly bringing it back in."
	)
	return pick(missed_messages)


/datum/status_effect/adaptive_learning
	id = "adaptive_learning"
	duration = 300
	status_type = STATUS_EFFECT_REFRESH
	alert_type = null
	var/bonus_damage = 0


/datum/status_effect/charging
	id = "charging"
	alert_type = null

/datum/status_effect/delayed
	id = "delayed_status_effect"
	status_type = STATUS_EFFECT_MULTIPLE
	alert_type = null
	var/prevent_signal = null
	var/datum/callback/expire_proc = null

/datum/status_effect/delayed/on_creation(mob/living/new_owner, new_duration, datum/callback/new_expire_proc, new_prevent_signal = null)
	if(!new_duration || !istype(new_expire_proc))
		qdel(src)
		return
	duration = new_duration
	expire_proc = new_expire_proc
	. = ..()
	if(new_prevent_signal)
		RegisterSignal(owner, new_prevent_signal, PROC_REF(prevent_action))
		prevent_signal = new_prevent_signal

/datum/status_effect/proc/prevent_action()
	SIGNAL_HANDLER
	qdel(src)

/datum/status_effect/delayed/on_remove()
	if(prevent_signal)
		UnregisterSignal(owner, prevent_signal)
	. = ..()

/datum/status_effect/delayed/on_timeout()
	. = ..()
	expire_proc.Invoke()


/datum/status_effect/stop_drop_roll
	id = "stop_drop_roll"
	alert_type = null
	tick_interval = 0.8 SECONDS


/datum/status_effect/stop_drop_roll/on_apply()
	if(!iscarbon(owner))
		return FALSE

	var/actual_interval = initial(tick_interval)
	if(!owner.Knockdown(actual_interval * 2, ignore_canknockdown = TRUE) || owner.body_position != LYING_DOWN)
		to_chat(owner, span_warning("You try to stop, drop, and roll - but you can't get on the ground!"))
		return FALSE

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(stop_rolling))
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(body_position_changed))
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id)) // they're kinda busy!

	owner.visible_message(
		span_danger("[owner] rolls on the floor, trying to put [owner.p_them()]self out!"),
		span_notice("You stop, drop, and roll!"),
	)
	// Start with one weaker roll
	owner.spin(spintime = actual_interval, speed = actual_interval / 4)
	owner.adjust_fire_stacks(-0.25)
	return TRUE


/datum/status_effect/stop_drop_roll/on_remove()
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BODY_POSITION))
	REMOVE_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id))


/datum/status_effect/stop_drop_roll/tick(seconds_between_ticks)
	if(HAS_TRAIT(owner, TRAIT_IMMOBILIZED) || HAS_TRAIT(owner, TRAIT_INCAPACITATED))
		qdel(src)
		return

	var/actual_interval = initial(tick_interval)
	if(!owner.Knockdown(actual_interval * 1.2, ignore_canknockdown = TRUE))
		stop_rolling()
		return

	owner.spin(spintime = actual_interval, speed = actual_interval / 4)
	owner.adjust_fire_stacks(-1)

	if(owner.fire_stacks > 0)
		return

	owner.visible_message(
		span_danger("[owner] successfully extinguishes [owner.p_them()]self!"),
		span_notice("You extinguish yourself."),
	)
	qdel(src)


/datum/status_effect/stop_drop_roll/proc/stop_rolling(datum/source, ...)
	SIGNAL_HANDLER

	if(!QDELING(owner))
		to_chat(owner, span_notice("You stop rolling around."))
	qdel(src)


/datum/status_effect/stop_drop_roll/proc/body_position_changed(datum/source, new_value, old_value)
	SIGNAL_HANDLER

	if(new_value != LYING_DOWN)
		stop_rolling()


/datum/status_effect/recently_succumbed
	id = "recently_succumbed"
	alert_type = null
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REFRESH
