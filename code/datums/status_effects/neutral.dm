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
		to_chat(owner, span_notice("[opponent.name] лов[pluralize_ru(owner.gender, "ит", "ят")] ваш взгляд!"))
		to_chat(opponent, span_notice("[owner.name] лов[pluralize_ru(owner.gender, "ит", "ят")] ваш взгляд!"))
		var/list/loved_ones = list(MALE, FEMALE)
		if(!ishuman(owner) || !(target_gender in loved_ones) || !(owner.gender in loved_ones))
			return
		var/mob/living/carbon/human/human_owner = owner
		if(target_gender != human_owner.gender && target_species == human_owner.dna.species.name && prob(5))
			owner.emote("blush")
			to_chat(owner, span_danger("Вы чувствуете что-то жгучее в груди..."))


/datum/status_effect/high_five
	id = "high_five"
	duration = 10 SECONDS
	alert_type = null
	status_type = STATUS_EFFECT_REFRESH
	/// Message displayed when wizards perform this together
	var/critical_success = "дают друг другу ЭПИЧНУЮ пятюню!"
	/// Message displayed when normal people perform this together
	var/success = "дают друг другу пятюню!"
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
			user.visible_message(span_biggerdanger("<b>[user.name]</b> и <b>[check.name]</b> [critical_success]"))
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
			user.visible_message(span_notice("<b>[user.name]</b> и <b>[check.name]</b> [success]"))
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
		"кажется, неловко машет в никуда.",
		"перемещает свою руку прямо ко лбу от стыда.",
		"даёт пять в воздух.",
		"стыдливо хлопает себя по другой руке, прежде чем смахнуть слезу.",
		"пытается пожать руку, затем ударить кулаками, прежде чем отдернуть руку...? <i>Что [pluralize_ru(owner.gender, "он", "они")] дела[pluralize_ru(owner.gender, "ет", "ют")]?</i>"
	)
	return pick(missed_highfive_messages)


/datum/status_effect/high_five/dap
	id = "dap"
	critical_success = "ЭПИЧНО побратались!"
	success = "побратались!"
	request = "ищ%(ет,ут)% с кем бы побрататься..."
	sound_effect = 'sound/effects/snap.ogg'
	item_path = /obj/item/melee/touch_attack/fake_disintegrate  // EI-NATH!


/datum/status_effect/high_five/dap/get_missed_message()
	return "печально, вы не может найти никого, кому можно дать пятюню, и с кем бы побрататься. Стыдно."


/datum/status_effect/high_five/handshake
	id = "handshake"
	critical_success = "делают ЭПИЧЕСКОЕ рукопожатие!"
	success = "делают рукопожатие!"
	request = "ищ%(ет,ут)% кому бы пожать руку..."
	sound_effect = 'sound/weapons/thudswoosh.ogg'


/datum/status_effect/high_five/handshake/get_missed_message()
	var/list/missed_messages = list(
		"стыдливо опуска[pluralize_ru(owner.gender, "ет", "ют")] руку.",
		"хвата[pluralize_ru(owner.gender, "ет", "ют")] свою протянутую руку другой рукой и пожима[pluralize_ru(owner.gender, "ет", "ют")] её, будто здорова[pluralize_ru(owner.gender, "ется", "ются")] сам[genderize_ru(owner.gender, "", "а", "о", "и")] с собой.",
		"сжима[pluralize_ru(owner.gender, "ет", "ют")] руку в кулак, медленно убирая её."
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
		to_chat(owner, span_warning("Вы пытаетесь остановиться, упасть и кататься, но не можете лечь на землю!"))
		return FALSE

	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(stop_rolling))
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(body_position_changed))
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(id)) // they're kinda busy!

	owner.visible_message(
		span_danger("[owner] ката[pluralize_ru(owner.gender, "ет", "ют")]ся по полу, пытаясь потушить себя!"),
		span_notice("Вы останавливаетесь, падаете и катаетесь!"),
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
		span_danger("[owner] успешно туш[pluralize_ru(owner.gender, "ит", "ат")] себя!"),
		span_notice("Вы тушите себя."),
	)
	qdel(src)


/datum/status_effect/stop_drop_roll/proc/stop_rolling(datum/source, ...)
	SIGNAL_HANDLER

	if(!QDELING(owner))
		to_chat(owner, span_notice("Вы перестаёте кататься."))
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

/datum/status_effect/forced_rumble
	id = "forced_rumble"
	alert_type = null
	duration = 30 SECONDS
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/forced_rumble/tick(seconds_between_ticks)
	if(prob(20) && isunathi(owner))
		owner.emote("rumble")

/datum/status_effect/forced_sneeze
	id = "forced_sneeze"
	alert_type = null
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REFRESH

/datum/status_effect/forced_sneeze/tick(seconds_between_ticks)
	if(prob(30))
		owner.emote("sneeze")

/atom/movable/screen/alert/status_effect/lavaland_tail_o_dead
	name = "Хвост мертвеца"
	desc = "Поедание человеческих конечностей себя оправдало!"
	icon_state = "tail_o_dead"

/datum/status_effect/lavaland_vision
	id = "lavaland vision"
	duration = 5 MINUTES
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/lavaland_tail_o_dead


/datum/status_effect/lavaland_vision/on_apply()
	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		human.force_gene_block(GLOB.colourblindblock, TRUE)
		human.set_vision_override(/datum/vision_override/nightvision)
	return TRUE

/datum/status_effect/lavaland_vision/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/human = owner
		human.force_gene_block(GLOB.colourblindblock, FALSE)
		human.set_vision_override(null)

/atom/movable/screen/alert/status_effect/temperature_stabilize
	name = "Тушёный пивной червь"
	desc = "Температура вашего тела стабилизируется в разы быстрее."
	icon_state = "beer_grub_stew"

/datum/status_effect/temperature_stabilize
	id = "temperature stabilisation"
	duration = 5 MINUTES
	status_type = STATUS_EFFECT_REFRESH
	alert_type = /atom/movable/screen/alert/status_effect/temperature_stabilize
	var/temp_effect

/datum/status_effect/temperature_stabilize/tick(seconds_between_ticks)
	var/normal_temperature = owner?.dna?.species.body_temperature
	if(!normal_temperature)
		normal_temperature = BODYTEMP_NORMAL
	var/difference = owner.bodytemperature - normal_temperature
	if(abs(difference) > temp_effect)
		var/current_effect = difference > 0 ? -temp_effect : temp_effect
		owner.adjust_bodytemperature(current_effect * TEMPERATURE_DAMAGE_COEFFICIENT)


/atom/movable/screen/alert/status_effect/leaning
	name = "Прислонившись"
	desc = "Вы прислонились к чему-то."
	icon_state = "buckled"

/atom/movable/screen/alert/status_effect/leaning/Click()
	var/mob/living/L = usr
	if(!istype(L))
		return
	L.changeNext_move(CLICK_CD_RESIST)
	if(L.last_special <= world.time)
		return L.stop_leaning()

/datum/status_effect/leaning
	id = "leaning"
	duration = -1
	tick_interval = -1
	status_type = STATUS_EFFECT_UNIQUE
	alert_type = /atom/movable/screen/alert/status_effect/leaning

/datum/status_effect/leaning/on_creation(mob/living/carbon/new_owner, atom/object, leaning_offset = 11)
	. = ..()
	if(!.)
		return
	new_owner.start_leaning(object, leaning_offset)
