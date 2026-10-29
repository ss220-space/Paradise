#define WEAK_FLAME_TIME 10 SECONDS

/datum/status_effect/cursed_flame
	id = "cursed flame"
	duration = 60 SECONDS
	status_type = STATUS_EFFECT_REFRESH
	processing_speed = STATUS_EFFECT_NORMAL_PROCESS
	alert_type = /atom/movable/screen/alert/status_effect/cursed_flame
	var/image/overlay_image
	var/essence = 0
	var/mob/living/simple_animal/revenant/flame_inflicter
	var/list/messages = list(
		"Жгучая боль пронзает ваше тело насквозь!",
		"Огонь пожирает вашу сущность, оставляя лишь пустоту!",
		"Вы чувствуете, как теряете частичку души",
	)
	COOLDOWN_DECLARE(message_cooldown)

/datum/status_effect/cursed_flame/New(list/args)
	if(args[2])
		duration = args[2]
	flame_inflicter = args[3]
	. = ..()
	update_overlay()

/datum/status_effect/cursed_flame/get_examine_text()
	return span_revendanger("Из н[GEND_HIS_HER(owner)] вырывается пламя. Кажется, будто сама [GEND_HIS_HER(owner)] душа пылает!")

/datum/status_effect/cursed_flame/tick(seconds_between_ticks)
	update_overlay()
	var/holywater = owner.reagents.has_reagent(/datum/reagent/holywater, 1)
	if(holywater)
		duration -= 2 SECONDS
		owner.reagents.remove_reagent("holy_water", 1)
		if(COOLDOWN_FINISHED(src, message_cooldown))
			to_chat(owner, span_revendanger("Святая вода шипит внутри вас, гася призрачное пламя!"))
			COOLDOWN_START(src, message_cooldown, 5 SECONDS)
		owner.cut_overlay(overlay_image)
		update_overlay()
		return
	if(owner.IsSleeping() || owner.stat != CONSCIOUS)
		return
	var/damage = rand(4, 6)
	essence += round(damage/2)
	owner.adjustStaminaLoss(damage)
	adjust_essence()
	if(COOLDOWN_FINISHED(src, message_cooldown) && prob(30))
		var/omnious_message = pick(messages)
		to_chat(owner, span_revendanger(omnious_message))
		COOLDOWN_START(src, message_cooldown, 5 SECONDS)
	if(owner.getStaminaLoss() >= 100)
		to_chat(owner, span_revendanger("Ваше зрение темнеет, кажется вы вот-вот потеряете сознание!"))
		owner.Sleeping(12 SECONDS)

/datum/status_effect/cursed_flame/proc/adjust_essence()
	if(!istype(flame_inflicter))
		return
	var/essence_to_gain = round(essence/2)
	essence -= essence_to_gain
	flame_inflicter.change_essence_amount(essence_to_gain, TRUE)

/datum/status_effect/cursed_flame/on_remove()
	owner.cut_overlay(overlay_image)
	. = ..()

/datum/status_effect/cursed_flame/proc/update_overlay()
	if(overlay_image in owner.overlays)
		return
	owner.add_overlay(get_overlay())

/datum/status_effect/cursed_flame/proc/get_overlay()
	owner.cut_overlay(overlay_image)
	var/fire_type = "human"
	if(ismonkey(owner) || isfarwa(owner) || isstok(owner) || isneara(owner) || iswolpin(owner))
		fire_type = "monkey"
	overlay_image = image('icons/effects/revenant.dmi', "[fire_type]_fire")
	if(duration - world.time <= WEAK_FLAME_TIME || owner.reagents.has_reagent(/datum/reagent/holywater, 1))
		overlay_image = image('icons/effects/revenant.dmi', "[fire_type]_generic_burn")
	return overlay_image

/atom/movable/screen/alert/status_effect/cursed_flame
	name = "Призрачное Пламя"
	desc = "Кажется, ваша душа горит! Выпейте святой воды или попытайтесь сбить пламя, катаясь по полу."
	icon_state = "cursed_flame"
	var/active = FALSE
	var/interval = 0.8 SECONDS

/atom/movable/screen/alert/status_effect/cursed_flame/Click(location, control, params)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/living_owner = owner
	if(!living_owner.can_resist())
		return FALSE

	living_owner.changeNext_move(CLICK_CD_RESIST)
	if(!(living_owner.mobility_flags & MOBILITY_MOVE))
		return FALSE

	return handle_stop_drop_roll(owner)

/atom/movable/screen/alert/status_effect/cursed_flame/proc/handle_stop_drop_roll(mob/living/roller)
	if(!active)
		start_rolling()
		return TRUE
	stop_rolling()
	return TRUE

/atom/movable/screen/alert/status_effect/cursed_flame/proc/start_rolling()
	if(!iscarbon(owner))
		return
	var/mob/living/carbon/carbon_owner = owner
	if(!carbon_owner.Knockdown(interval * 2, ignore_canknockdown = TRUE) || carbon_owner.body_position != LYING_DOWN)
		to_chat(owner, span_warning("Вы пытаетесь остановиться, упасть и кататься, но не можете лечь на землю!"))
		return
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(stop_rolling))
	RegisterSignal(owner, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(body_position_changed))
	ADD_TRAIT(owner, TRAIT_HANDS_BLOCKED, TRAIT_STATUS_EFFECT(attached_effect.id)) // they're kinda busy!

	owner.visible_message(
		span_danger("[owner] ката[PLUR_ET_YUT(owner)]ся по полу, пытаясь потушить себя!"),
		span_notice("Вы останавливаетесь, падаете и катаетесь!"),
	)
	// Start with one weaker roll
	owner.spin(spintime = interval, speed = interval / 4)
	active = TRUE
	START_PROCESSING(SSprocessing, src)

/atom/movable/screen/alert/status_effect/cursed_flame/process(seconds_per_tick)
	if(HAS_TRAIT(owner, TRAIT_IMMOBILIZED) || HAS_TRAIT(owner, TRAIT_INCAPACITATED))
		return
	var/mob/living/carbon/carbon_owner = owner
	if(!carbon_owner.Knockdown(interval * 1.2, ignore_canknockdown = TRUE))
		stop_rolling()
		return

	owner.spin(spintime = interval, speed = interval / 4)
	attached_effect.duration -= 1 SECONDS

	if(owner.has_status_effect(attached_effect))
		return

/atom/movable/screen/alert/status_effect/cursed_flame/proc/stop_rolling()
	if(!QDELING(owner))
		to_chat(owner, span_notice("Вы перестаёте кататься."))
	UnregisterSignal(owner, list(COMSIG_MOVABLE_MOVED, COMSIG_LIVING_SET_BODY_POSITION))
	STOP_PROCESSING(SSprocessing, src)
	active = FALSE

/atom/movable/screen/alert/status_effect/cursed_flame/proc/stop_rolling_signal()
	SIGNAL_HANDLER
	stop_rolling()

/atom/movable/screen/alert/status_effect/cursed_flame/proc/body_position_changed(datum/source, new_value, old_value)
	SIGNAL_HANDLER
	if(new_value != LYING_DOWN)
		stop_rolling()

/obj/effect/temp_visual/revenant_fire
	icon = 'icons/effects/fire.dmi'
	icon_state = "1"
	color = "#00beff"

/proc/revenant_fire_ring(center, max_radius = 5, starting_radius = 0)
	for(var/turf/turf in get_hollow_turfs_circle(center, starting_radius))
		new /obj/effect/temp_visual/revenant_fire(turf)
	var/new_range = starting_radius += 1
	if(new_range > max_radius)
		return
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(revenant_fire_ring), center, max_radius, new_range), 0.1 SECONDS)

#undef WEAK_FLAME_TIME
