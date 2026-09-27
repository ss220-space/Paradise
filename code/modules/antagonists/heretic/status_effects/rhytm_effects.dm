#define RHYTM_DECAY_DELAY (3 SECONDS)
#define RHYTM_MAX_BASE 25
#define RHYTM_MAX_UPGRADED 50
#define RHYTM_MAX_FINAL 100
#define RHYTM_BONUS_CAP 25
#define RHYTM_DODGE_THRESHOLD 20
#define RHYTM_BACKLASH_THRESHOLD 25
#define RHYTM_EMPOWER_STAMINA 5
#define RHYTM_BACKLASH_CHANCE 10
#define RHYTM_MEND_THRESHOLD 10
#define RHYTM_HEAL_INTERVAL (5 SECONDS)
#define RHYTM_UPGRADED_HEAL_INTERVAL (3.3 SECONDS)
#define RHYTM_ASCENDED_HEAL_INTERVAL (1 SECONDS)
#define RHYTM_COMBAT_HEAL_MULTIPLIER 0.35
#define RHYTM_COMBAT_DELAY (5 SECONDS)
#define RHYTM_ASCENDED_MINIMUM 30
#define RHYTM_PULSE_RANGE_PER_POINT 10
#define RHYTM_PULSE_MAX_RANGE 5
#define RHYTM_PULSE_INTERVAL (5 SECONDS)
#define RHYTM_PULSE_DAMAGE_MULTIPLIER 0.5
#define RHYTM_HEAL_CAP 50
#define RHYTM_SPIN_SPEED (0.6 SECONDS)
#define FESTIVAL_STAMINA_PER_STEP 5
#define RHYTM_PER_RESONATING_HEART 5
#define RHYTM_PER_MARK 5


/proc/get_heretic_rhytm(mob/living/target)
	RETURN_TYPE(/datum/status_effect/heretic_passive/rhytm)
	return target?.has_status_effect(/datum/status_effect/heretic_passive/rhytm)


/datum/status_effect/heretic_passive/rhytm
	id = "heretic_passive_rhytm"
	name = "Ритм"
	alert_type = /atom/movable/screen/alert/status_effect/rhytm
	passive_descriptions = list(
		"Кровотечения вам не страшны, а ритм постоянно залечивает раны. В бою исцеление слабеет.",
		"Иммунитет ко сну и сбиванию с ног, предел ритма поднят до 50, исцеление приходит чаще.",
		"Предел ритма поднят до 100, высокий ритм больше не бьёт по вам, а бой не мешает исцелению.",
	)
	var/rhythm = 0
	var/max_rhythm = RHYTM_MAX_BASE
	var/minimum_rhythm = 0
	var/heal_interval = RHYTM_HEAL_INTERVAL
	var/next_decay = 0
	var/next_heal = 0
	var/combat_until = 0
	var/applied_click_speed = 1
	var/applied_bonus = 0
	var/pulse_until = 0
	var/next_pulse = 0
	var/always_pulse = FALSE
	var/dancing = FALSE
	var/dance_timer
	var/old_bleed_mod = 1


/datum/status_effect/heretic_passive/rhytm/on_apply()
	. = ..()
	if(!.)
		return
	next_decay = world.time + RHYTM_DECAY_DELAY
	next_heal = world.time + heal_interval
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		old_bleed_mod = human_owner.physiology.bleed_mod
		human_owner.physiology.bleed_mod = 0
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_damage_taken))
	RegisterSignal(owner, COMSIG_MOB_ITEM_ATTACK, PROC_REF(on_damage_dealt))
	RegisterSignal(owner, COMSIG_GET_MELEE_DAMAGE_DELTAS, PROC_REF(on_unarmed_attack))
	RegisterSignal(owner, COMSIG_HUMAN_CHECK_SHIELDS, PROC_REF(try_dodge))
	RegisterSignal(owner, COMSIG_HUMAN_TRY_DEFLECT_BULLET, PROC_REF(dodge_projectile))
	on_rhythm_changed()


/datum/status_effect/heretic_passive/rhytm/level_upgrade()
	. = ..()
	if(!.)
		return
	max_rhythm = RHYTM_MAX_UPGRADED
	heal_interval = RHYTM_UPGRADED_HEAL_INTERVAL
	ADD_TRAIT(owner, TRAIT_SLEEPIMMUNE, TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_LIVING_GENERIC_INCAPACITATE_CHECK, PROC_REF(shrug_off_knockdown))


/datum/status_effect/heretic_passive/rhytm/level_final()
	. = ..()
	if(!.)
		return
	max_rhythm = RHYTM_MAX_FINAL


/datum/status_effect/heretic_passive/rhytm/on_remove()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.bleed_mod = old_bleed_mod
	owner.remove_traits(list(TRAIT_SLEEPIMMUNE), TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(owner, list(
		COMSIG_MOB_APPLY_DAMAGE,
		COMSIG_MOB_ITEM_ATTACK,
		COMSIG_GET_MELEE_DAMAGE_DELTAS,
		COMSIG_HUMAN_CHECK_SHIELDS,
		COMSIG_HUMAN_TRY_DEFLECT_BULLET,
		COMSIG_LIVING_GENERIC_INCAPACITATE_CHECK,
	))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/rhytm)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/rhytm)
	owner.next_move_modifier /= applied_click_speed
	stop_dancing()
	return ..()


/datum/status_effect/heretic_passive/rhytm/tick(seconds_per_tick)
	if(owner.stat == DEAD)
		return

	if(owner.health <= 0)
		adjust_rhythm(1)

	if(rhythm > minimum_rhythm && world.time >= next_decay)
		next_decay = world.time + RHYTM_DECAY_DELAY
		rhythm--
		on_rhythm_changed()

	else if(rhythm < minimum_rhythm)
		adjust_rhythm(minimum_rhythm - rhythm)

	if(world.time >= next_heal)
		next_heal = world.time + heal_interval
		beat()


/datum/status_effect/heretic_passive/rhytm/proc/adjust_rhythm(amount)
	if(!amount)
		return
	var/old_rhythm = rhythm
	rhythm = clamp(rhythm + amount, minimum_rhythm, max_rhythm)
	if(rhythm == old_rhythm)
		return
	if(amount > 0)
		next_decay = world.time + RHYTM_DECAY_DELAY
	on_rhythm_changed()


/datum/status_effect/heretic_passive/rhytm/proc/on_rhythm_changed()
	update_modifiers()
	update_dance()
	if(linked_alert)
		linked_alert.maptext = MAPTEXT_TINY_UNICODE("<div align='center'>[rhythm]</div>")


/datum/status_effect/heretic_passive/rhytm/proc/effective_rhythm()
	return min(rhythm, RHYTM_BONUS_CAP)


/datum/status_effect/heretic_passive/rhytm/proc/update_modifiers()
	var/bonus = effective_rhythm() * 0.01
	if(bonus == applied_bonus)
		return
	applied_bonus = bonus
	owner.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/rhytm, multiplicative_slowdown = -bonus)
	owner.add_or_update_variable_actionspeed_modifier(/datum/actionspeed_modifier/rhytm, multiplicative_slowdown = -bonus)
	owner.next_move_modifier /= applied_click_speed
	applied_click_speed = 1 - bonus
	owner.next_move_modifier *= applied_click_speed


/datum/status_effect/heretic_passive/rhytm/proc/update_dance()
	if(rhythm >= RHYTM_DANCE_THRESHOLD)
		start_dancing()
		return
	stop_dancing()


/datum/status_effect/heretic_passive/rhytm/proc/start_dancing()
	if(dancing)
		return
	dancing = TRUE
	dance_step()


/datum/status_effect/heretic_passive/rhytm/proc/stop_dancing()
	dancing = FALSE
	deltimer(dance_timer)
	dance_timer = null


/datum/status_effect/heretic_passive/rhytm/proc/dance_step()
	if(!dancing || QDELETED(owner))
		return
	flourish()
	INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, custom_emote), EMOTE_VISIBLE, pick("жутко подёргивается.", "радостно танцует."))
	dance_timer = addtimer(CALLBACK(src, PROC_REF(dance_step)), rand(8 SECONDS, 14 SECONDS), TIMER_STOPPABLE)


/datum/status_effect/heretic_passive/rhytm/proc/flourish()
	new /obj/effect/temp_visual/heretic_dance(get_turf(owner))
	owner.SpinAnimation(RHYTM_SPIN_SPEED, 1)


/datum/status_effect/heretic_passive/rhytm/proc/beat()
	if(!rhythm || owner.stat == DEAD)
		return

	var/power = min(rhythm, RHYTM_HEAL_CAP)
	if(applied_level < 3 && world.time < combat_until)
		power *= RHYTM_COMBAT_HEAL_MULTIPLIER

	var/resonating = world.time < pulse_until
	if((always_pulse || resonating) && world.time >= next_pulse)
		next_pulse = world.time + RHYTM_PULSE_INTERVAL
		pulse()

	if(resonating)
		for(var/mob/living/watcher in view(owner))
			if(watcher == owner || !watcher.client || IS_HERETIC_OR_MONSTER(watcher))
				continue
			adjust_rhythm(RHYTM_PER_RESONATING_HEART)

	if(applied_level < 3 && rhythm >= RHYTM_BACKLASH_THRESHOLD && prob(RHYTM_BACKLASH_CHANCE))
		owner.apply_damage(power, BRUTE, BODY_ZONE_CHEST)
		to_chat(owner, span_userdanger("Ритм рвётся наружу и бьёт вас изнутри!"))
		return

	var/brute_to_heal = min(power, owner.getBruteLoss())
	owner.heal_overall_damage(brute_to_heal, power - brute_to_heal, updating_health = FALSE, internal = rhythm >= RHYTM_MEND_THRESHOLD)
	owner.adjustStaminaLoss(-power, updating_health = FALSE)
	owner.updatehealth("rhytm heartbeat")


/datum/status_effect/heretic_passive/rhytm/proc/pulse()
	var/pulse_range = min(1 + round(rhythm / RHYTM_PULSE_RANGE_PER_POINT), RHYTM_PULSE_MAX_RANGE)
	var/pulse_damage = rhythm * RHYTM_PULSE_DAMAGE_MULTIPLIER
	new /obj/effect/temp_visual/resonant_pulse(get_turf(owner))
	playsound(owner, 'sound/magic/heretic/rhytm/timpan3.ogg', 50, TRUE)
	for(var/mob/living/victim in view(pulse_range, owner))
		if(victim == owner || IS_HERETIC_OR_MONSTER(victim))
			continue
		victim.apply_damage(pulse_damage, BRUTE, BODY_ZONE_CHEST)
		to_chat(victim, span_userdanger("Чужое сердцебиение бьёт вас изнутри!"))


/datum/status_effect/heretic_passive/rhytm/proc/on_damage_taken(mob/living/source, damage, damagetype, def_zone, blocked, sharp, used_weapon, spread_damage, forced)
	SIGNAL_HANDLER

	if(damage <= 0 || damagetype == STAMINA || damagetype == OXY)
		return

	combat_until = world.time + RHYTM_COMBAT_DELAY
	adjust_rhythm(1)

	if(applied_level < 3 && rhythm >= RHYTM_EMPOWER_THRESHOLD)
		owner.adjustStaminaLoss(RHYTM_EMPOWER_STAMINA)


/datum/status_effect/heretic_passive/rhytm/proc/on_damage_dealt(mob/living/source, atom/target, list/modifiers, def_zone)
	SIGNAL_HANDLER

	if(!isliving(target) || target == owner)
		return

	combat_until = world.time + RHYTM_COMBAT_DELAY
	adjust_rhythm(1)


/datum/status_effect/heretic_passive/rhytm/proc/on_unarmed_attack(mob/living/source, list/deltas)
	SIGNAL_HANDLER

	combat_until = world.time + RHYTM_COMBAT_DELAY
	adjust_rhythm(1)


/datum/status_effect/heretic_passive/rhytm/proc/try_dodge(mob/living/carbon/human/source, atom/movable/hitby, attack_text, armour_penetration, damage, attack_type)
	SIGNAL_HANDLER

	if(attack_type == PROJECTILE_ATTACK)
		return
	if(!can_dodge() || !prob(effective_rhythm()))
		return

	announce_dodge(hitby)
	return SHIELD_BLOCK


/datum/status_effect/heretic_passive/rhytm/proc/dodge_projectile(mob/living/source, obj/projectile/hitting_projectile, def_zone)
	SIGNAL_HANDLER

	if(!can_dodge())
		return NONE
	if(rhythm < RHYTM_DODGE_THRESHOLD && !prob(effective_rhythm()))
		return NONE

	announce_dodge(hitting_projectile)
	return COMPONENT_BULLET_DEFLECTED


/datum/status_effect/heretic_passive/rhytm/proc/can_dodge()
	return owner.body_position != LYING_DOWN && owner.stat == CONSCIOUS


/datum/status_effect/heretic_passive/rhytm/proc/announce_dodge(atom/movable/hitby)
	owner.visible_message(
		span_danger("[DECLENT_RU_CAP(owner, NOMINATIVE)] уходит с линии удара, не сбившись с такта!"),
		span_userdanger("Такт ведёт вас в сторону, и [hitby.declent_ru(NOMINATIVE)] проходит мимо."),
	)
	playsound(owner, 'sound/magic/heretic/rhytm/timpan2.ogg', 40, TRUE)
	adjust_rhythm(1)


/datum/status_effect/heretic_passive/rhytm/proc/shrug_off_knockdown(mob/living/source, check_flags, force_apply)
	SIGNAL_HANDLER

	if(force_apply || !(check_flags & (CANWEAKEN|CANKNOCKDOWN)))
		return
	return COMPONENT_NO_EFFECT


/datum/status_effect/heretic_passive/rhytm/proc/ascend()
	always_pulse = TRUE
	heal_interval = RHYTM_ASCENDED_HEAL_INTERVAL
	minimum_rhythm = RHYTM_ASCENDED_MINIMUM
	adjust_rhythm(RHYTM_ASCENDED_MINIMUM)


/datum/status_effect/eldritch/rhytm
	effect_icon_state = "emark1"
	var/datum/weakref/conductor_ref


/datum/status_effect/eldritch/rhytm/on_creation(mob/living/new_owner, mob/living/conductor)
	if(conductor)
		conductor_ref = WEAKREF(conductor)
	return ..()


/datum/status_effect/eldritch/rhytm/on_effect()
	var/mob/living/conductor = conductor_ref?.resolve()
	var/datum/status_effect/heretic_passive/rhytm/our_rhythm = get_heretic_rhytm(conductor)
	if(our_rhythm)
		our_rhythm.adjust_rhythm(RHYTM_PER_MARK)
		owner.adjustStaminaLoss(our_rhythm.rhythm)
		conductor.adjustStaminaLoss(-our_rhythm.rhythm)
		to_chat(owner, span_userdanger("Ваши силы уходят в чужой такт!"))
	return ..()


/datum/status_effect/accelerated_dance
	id = "accelerated_dance"
	duration = 10 SECONDS
	alert_type = null
	var/stamina_mod_applied = 0.5
	var/old_stamina_mod = 1


/datum/status_effect/accelerated_dance/on_apply()
	. = ..()
	if(!.)
		return
	owner.add_movespeed_modifier(/datum/movespeed_modifier/accelerated_dance)
	RegisterSignal(owner, COMSIG_LIVING_GENERIC_INCAPACITATE_CHECK, PROC_REF(stay_on_feet))
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		old_stamina_mod = human_owner.physiology.stamina_mod
		human_owner.physiology.stamina_mod *= stamina_mod_applied
	owner.visible_message(
		span_danger("[DECLENT_RU_CAP(owner, NOMINATIVE)] срывается в неистовый танец!"),
		span_notice("Такт подхватывает вас и несёт вперёд."),
	)
	playsound(owner, 'sound/magic/heretic/rhytm/timpan1.ogg', 60, TRUE)


/datum/status_effect/accelerated_dance/on_remove()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/accelerated_dance)
	UnregisterSignal(owner, COMSIG_LIVING_GENERIC_INCAPACITATE_CHECK)
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		human_owner.physiology.stamina_mod = old_stamina_mod
	owner.adjustStaminaLoss(MAX_STAMINA_LOSS * 0.2)
	to_chat(owner, span_warning("Танец обрывается, и всё тело разом вспоминает про усталость."))
	return ..()


/datum/status_effect/accelerated_dance/proc/stay_on_feet(mob/living/source, check_flags, force_apply)
	SIGNAL_HANDLER

	if(force_apply || !(check_flags & (CANWEAKEN|CANKNOCKDOWN)))
		return
	return COMPONENT_NO_EFFECT


/datum/movespeed_modifier/accelerated_dance
	multiplicative_slowdown = -0.4


/datum/movespeed_modifier/rhytm
	variable = TRUE


/datum/movespeed_modifier/unwaking_timpan
	multiplicative_slowdown = -0.1


/datum/actionspeed_modifier/rhytm
	variable = TRUE


/datum/status_effect/festival_puppet
	id = "festival_puppet"
	duration = 10 SECONDS
	alert_type = null
	var/mob/living/conductor


/datum/status_effect/festival_puppet/on_creation(mob/living/new_owner, mob/living/conductor)
	src.conductor = conductor
	return ..()


/datum/status_effect/festival_puppet/on_apply()
	if(!conductor)
		return FALSE
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, PROC_REF(block_own_steps))
	RegisterSignal(conductor, COMSIG_MOVABLE_MOVED, PROC_REF(follow_the_beat))
	RegisterSignals(conductor, list(COMSIG_LIVING_DEATH, COMSIG_QDELETING), PROC_REF(on_conductor_gone))
	owner.visible_message(
		span_danger("[DECLENT_RU_CAP(owner, NOMINATIVE)] пускается в пляс, будто [GEND_HIM_HER(owner)] дёргают за нити!"),
		span_userdanger("Ваше тело больше не слушается вас — оно подчиняется чужому такту!"),
	)
	return TRUE


/datum/status_effect/festival_puppet/on_remove()
	UnregisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE)
	if(conductor)
		UnregisterSignal(conductor, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_DEATH, COMSIG_QDELETING))
		conductor = null
	to_chat(owner, span_notice("Такт отпускает вас."))
	return ..()


/datum/status_effect/festival_puppet/proc/block_own_steps(mob/source, list/move_args)
	SIGNAL_HANDLER

	return COMSIG_MOB_CLIENT_BLOCK_PRE_MOVE


/datum/status_effect/festival_puppet/proc/follow_the_beat(atom/movable/source, atom/old_loc, direction)
	SIGNAL_HANDLER

	if(!direction || owner.stat == DEAD)
		return
	step(owner, direction)
	owner.adjustStaminaLoss(FESTIVAL_STAMINA_PER_STEP)
	if(prob(20))
		INVOKE_ASYNC(owner, TYPE_PROC_REF(/mob, custom_emote), EMOTE_VISIBLE, "пляшет под чужой такт.")


/datum/status_effect/festival_puppet/proc/on_conductor_gone(datum/source)
	SIGNAL_HANDLER

	qdel(src)


/atom/movable/screen/alert/status_effect/rhytm
	name = "Ритм"
	desc = "Ваше сердце ведёт счёт. Чем выше ритм, тем быстрее вы двигаетесь и тем скорее затягиваются раны."
	icon = 'icons/mob/screen_alert_heretic.dmi'
	icon_state = "rhytm_count"
	maptext_y = 5


/obj/effect/temp_visual/heretic_dance
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "heretic_dance"
	duration = 0.7 SECONDS
	layer = ABOVE_ALL_MOB_LAYER
	alpha = 160
	randomdir = FALSE


/obj/effect/temp_visual/resonant_pulse
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "resonant_pulse"
	duration = 0.6 SECONDS
	layer = BELOW_MOB_LAYER


/obj/effect/temp_visual/relentless_festival
	icon = 'icons/effects/eldritch.dmi'
	icon_state = "relentless_festival"
	duration = 0.8 SECONDS
	layer = BELOW_MOB_LAYER


#undef RHYTM_DECAY_DELAY
#undef RHYTM_MAX_BASE
#undef RHYTM_MAX_UPGRADED
#undef RHYTM_MAX_FINAL
#undef RHYTM_BONUS_CAP
#undef RHYTM_DODGE_THRESHOLD
#undef RHYTM_BACKLASH_THRESHOLD
#undef RHYTM_EMPOWER_STAMINA
#undef RHYTM_BACKLASH_CHANCE
#undef RHYTM_MEND_THRESHOLD
#undef RHYTM_HEAL_INTERVAL
#undef RHYTM_UPGRADED_HEAL_INTERVAL
#undef RHYTM_ASCENDED_HEAL_INTERVAL
#undef RHYTM_COMBAT_HEAL_MULTIPLIER
#undef RHYTM_COMBAT_DELAY
#undef RHYTM_ASCENDED_MINIMUM
#undef RHYTM_PULSE_RANGE_PER_POINT
#undef RHYTM_PULSE_MAX_RANGE
#undef RHYTM_PULSE_INTERVAL
#undef RHYTM_HEAL_CAP
#undef RHYTM_PULSE_DAMAGE_MULTIPLIER
#undef RHYTM_SPIN_SPEED
#undef FESTIVAL_STAMINA_PER_STEP
#undef RHYTM_PER_RESONATING_HEART
#undef RHYTM_PER_MARK
