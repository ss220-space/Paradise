/obj/effect/proc_holder/spell/touch/star_touch
	name = "Звёздное касание"
	desc = "Создаёт космические поля на плитках рядом с вами, одновременно отмечая жертву звёздной меткой \
			или поглощая уже существующую звёздную метку, чтобы усыпить её на 4 секунды. \
			Затем жертва будет связана с вами космическим лучом, сжигающим её до минуты или \
			до момента пока ваша жертва не скроется от вас. «Звёздное Касание» также может стереть Космические \
			руны или телепортировать вас к вашему Звёздному Глашатаю при использовании на себе."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "star_touch"

	sound = 'sound/items/welder.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 15 SECONDS
	invocation = "ЗВ'ЗДН К'С'Н!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	hand_path = /obj/item/melee/touch_attack/star_touch
	/// Stores the weakref for the Star Gazer after ascending
	var/datum/weakref/star_gazer
	/// If the heretic is ascended or not
	var/ascended = FALSE


/obj/effect/proc_holder/spell/touch/star_touch/valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE

	return TRUE

/*
/obj/effect/proc_holder/spell/touch/star_touch/on_antimagic_triggered(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	victim.visible_message(
		span_danger("The spell bounces off of you!"),
	)
*/

/obj/item/melee/touch_attack/star_touch/afterattack(mob/living/victim, mob/living/carbon/caster, proximity, params)
	if(!istype(victim))
		return FALSE

	if(victim.has_status_effect(/datum/status_effect/star_mark))
		victim.apply_effect(4 SECONDS, effecttype = SLEEPING)
		victim.remove_status_effect(/datum/status_effect/star_mark)
	else
		victim.apply_status_effect(/datum/status_effect/star_mark, caster)

	for(var/turf/cast_turf as anything in get_turfs(victim))
		new /obj/effect/forcefield/cosmic_field(cast_turf)

	caster.apply_status_effect(/datum/status_effect/cosmic_beam, victim)
	return ..()


/obj/item/melee/touch_attack/star_touch/proc/get_turfs(mob/living/victim)
	var/list/target_turfs = list(get_turf(owner))
	var/obj/effect/proc_holder/spell/touch/star_touch/star_touch = attached_spell
	var/range = star_touch.ascended ? 2 : 1
	var/list/directions = list(turn(owner.dir, 90), turn(owner.dir, 270))
	for(var/direction as anything in directions)
		for(var/i in 1 to range)
			target_turfs += get_ranged_target_turf(owner, direction, i)

	return target_turfs


/// To set the star gazer
/obj/effect/proc_holder/spell/touch/star_touch/proc/set_star_gazer(mob/living/simple_animal/hostile/heretic_summon/star_gazer/star_gazer_mob)
	star_gazer = WEAKREF(star_gazer_mob)


/// To obtain the star gazer if there is one
/obj/effect/proc_holder/spell/touch/star_touch/proc/get_star_gazer()
	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/star_gazer_resolved = star_gazer?.resolve()
	if(star_gazer_resolved)
		return star_gazer_resolved

	return FALSE


/obj/item/melee/touch_attack/star_touch
	name = "звёздное касание"
	desc = "Зловещая аура, искажающая реальность вокруг себя. \
			Заставляет людей со звёздной меткой заснуть на 4 секунды, а людей без звёздной метки — получить её."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "star"
	item_state = "star"


/obj/item/melee/touch_attack/star_touch/get_ru_names()
	return list(
		NOMINATIVE = "звёздное касание",
		GENITIVE = "звёздного касания",
		DATIVE = "звёздному касанию",
		ACCUSATIVE = "звёздное касание",
		INSTRUMENTAL = "звёздным касанием",
		PREPOSITIONAL = "звёздном касании"
	)


/obj/item/melee/touch_attack/star_touch/Initialize(mapload)
	. = ..()
	AddComponent(\
		/datum/component/effect_remover, \
		success_feedback = "Вы стёрли %THEEFFECT.", \
		tip_text = "Стереть руну", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/cosmic_rune), \
	)


/*
 * Callback for effect_remover component.
 */
/obj/item/melee/touch_attack/star_touch/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/cosmic_rune_fade(get_turf(target))
	//var/obj/effect/proc_holder/spell/touch/star_touch/star_touch_spell = attached_spell
	//star_touch_spell?.spell_feedback(user)
	remove_hand_with_no_refund(user)

/*
/obj/item/melee/touch_attack/star_touch/ignition_effect(atom/to_light, mob/user)
	. = span_rose("[user] effortlessly snaps [user.p_their()] fingers near [to_light], igniting it with cosmic energies. Fucking badass!")
	remove_hand_with_no_refund(user)
*/

/obj/item/melee/touch_attack/star_touch/attack_self(mob/living/user)
	var/obj/effect/proc_holder/spell/touch/star_touch/star_touch_spell = attached_spell
	var/mob/living/simple_animal/hostile/heretic_summon/star_gazer/star_gazer_mob = star_touch_spell?.get_star_gazer()
	if(!star_gazer_mob)
		balloon_alert(user, "нет привязанного существа!")
		return ..()

	new /obj/effect/temp_visual/cosmic_explosion(get_turf(user))
	do_teleport(
		user,
		get_turf(star_gazer_mob),
		asoundin = 'sound/magic/cosmic_energy.ogg',
		asoundout = 'sound/magic/cosmic_energy.ogg',
	)
	remove_hand_with_no_refund(user)


/obj/effect/ebeam/cosmic
	name = "звёздный луч"


/datum/status_effect/cosmic_beam
	id = "cosmic_beam"
	tick_interval = 0.2 SECONDS
	duration = 1 MINUTES
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	/// Stores the current beam target
	var/mob/living/current_target
	/// Checks the time of the last check
	var/last_check = 0
	/// The delay of when the beam gets checked
	var/check_delay = 10 //Check los as often as possible, max resolution is SSobj tick though
	/// The maximum range of the beam
	var/max_range = 8
	/// Wether the beam is active or not
	var/active = FALSE
	/// The storage for the beam
	var/datum/beam/current_beam = null


/datum/status_effect/cosmic_beam/on_creation(mob/living/new_owner, mob/living/current_target)
	src.current_target = current_target
	start_beam(current_target, new_owner)
	return ..()


/datum/status_effect/cosmic_beam/be_replaced()
	if(!active)
		return ..()

	QDEL_NULL(current_beam)
	active = FALSE


/datum/status_effect/cosmic_beam/tick(seconds_between_ticks)
	if(!current_target)
		lose_target()
		return

	if(world.time <= last_check+check_delay)
		return

	last_check = world.time

/*
	if(!los_check(owner, current_target))
		QDEL_NULL(current_beam)//this will give the target lost message
		return
*/

	if(!current_target)
		return

	on_beam_tick(current_target)


/**
 * Proc that always is called when we want to end the beam and makes sure things are cleaned up, see beam_died()
 */
/datum/status_effect/cosmic_beam/proc/lose_target()
	if(active)
		//QDEL_NULL(current_beam)
		active = FALSE

	if(current_target)
		on_beam_release(current_target)

	current_target = null


/**
 * Proc that is only called when the beam fails due to something, so not when manually ended.
 * manual disconnection = lose_target, so it can silently end
 * automatic disconnection = beam_died, so we can give a warning message first
 */
/datum/status_effect/cosmic_beam/proc/beam_died()
	SIGNAL_HANDLER
	to_chat(owner, span_warning("Вы теряете контроль над лучом!"))
	lose_target()
	duration = 0


/// Used for starting the beam when a target has been acquired
/datum/status_effect/cosmic_beam/proc/start_beam(atom/target, mob/living/user)
	if(current_target)
		lose_target()

	if(!isliving(target))
		return

	current_target = target
	active = TRUE
	current_beam = user.Beam(current_target, icon_state="cosmic_beam", time = 1 MINUTES, maxdistance = max_range, beam_type = /obj/effect/ebeam/cosmic)
	RegisterSignal(current_beam, COMSIG_QDELETING, PROC_REF(beam_died))

	SSblackbox.record_feedback("tally", "gun_fired", 1, type)
	if(!current_target)
		return

	on_beam_hit(current_target)


/// What to add when the beam connects to a target
/datum/status_effect/cosmic_beam/proc/on_beam_hit(mob/living/target)
	if(istype(target, /mob/living/simple_animal/hostile/heretic_summon/star_gazer))
		return

	target.AddElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)


/// What to process when the beam is connected to a target
/datum/status_effect/cosmic_beam/proc/on_beam_tick(mob/living/target)
	if(!target.adjustFireLoss(3, updating_health = FALSE))
		return

	target.updatehealth()


/// What to remove when the beam disconnects from a target
/datum/status_effect/cosmic_beam/proc/on_beam_release(mob/living/target)
	if(istype(target, /mob/living/simple_animal/hostile/heretic_summon/star_gazer))
		return

	target.RemoveElement(/datum/element/effect_trail, /obj/effect/forcefield/cosmic_field/fast)
