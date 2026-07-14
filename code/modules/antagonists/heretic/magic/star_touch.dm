/obj/effect/proc_holder/spell/touch/star_touch
	name = "Звёздное Касание"
	desc = "Создаёт космические поля на плитках рядом с вами, одновременно отмечая жертву звёздной меткой \
			или поглощая уже существующую звёздную метку, чтобы усыпить её на 4 секунды. \
			Затем жертва будет связана с вами космическим лучом: если связь не оборвётся, жертва уснёт и \
			будет притянута к вам, но стоит ей скрыться от вас — луч разорвётся. \"Звёздное Касание\" также \
			может стереть Космические руны или телепортировать вас к вашему Звёздному Наблюдателю при использовании на себе."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
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

/obj/item/melee/touch_attack/star_touch/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE
	var/mob/living/living_target = interacting_with
	if(get_dist(living_target, user) > 3)
		return NONE
	melee_attack_chain(user, living_target, modifiers)
	return TRUE


/obj/item/melee/touch_attack/star_touch/afterattack(mob/living/victim, mob/living/carbon/caster, proximity, params)
	if(!proximity) // Ranged use goes through ranged_interact_with_atom (3-tile limit), never straight to here.
		return FALSE
	if(!istype(victim))
		return FALSE

	if(!victim.has_status_effect(/datum/status_effect/star_mark))
		victim.apply_status_effect(/datum/status_effect/star_mark, caster)
		return ..()

	victim.remove_status_effect(/datum/status_effect/star_mark)
	victim.Drowsy(8 SECONDS)
	for(var/turf/cast_turf as anything in get_turfs(victim))
		create_cosmic_field(cast_turf, caster)

	caster.apply_status_effect(/datum/status_effect/cosmic_beam, victim)
	return ..()


/obj/item/melee/touch_attack/star_touch/proc/get_turfs(mob/living/victim)
	var/list/target_turfs = list(get_turf(owner))
	var/obj/effect/proc_holder/spell/touch/star_touch/star_touch = attached_spell
	var/range = star_touch.ascended ? 2 : 1
	var/list/directions = list(turn(owner.dir, 90), turn(owner.dir, 270))
	for(var/direction in directions)
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
	name = "star touch"
	desc = "Зловещая аура, искажающая реальность вокруг себя. \
			Заставляет людей со звёздной меткой заснуть на 4 секунды, а людей без звёздной метки — получить её."
	icon = 'icons/obj/weapons/hand.dmi'
	icon_state = "star"
	item_state = "star"
	lefthand_file = 'icons/mob/inhands/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/touchspell_righthand.dmi'


/obj/item/melee/touch_attack/star_touch/get_ru_names()
	return alist(
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


/obj/item/melee/touch_attack/star_touch/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/cosmic_rune_fade(get_turf(target))
	var/obj/effect/proc_holder/spell/cosmic_rune/rune_spell = locate() in user.mob_spell_list
	if(rune_spell)
		var/obj/effect/cosmic_rune/first_rune = rune_spell.first_rune?.resolve()
		var/obj/effect/cosmic_rune/second_rune = rune_spell.second_rune?.resolve()
		if(!QDELETED(first_rune))
			new /obj/effect/temp_visual/cosmic_rune_fade(get_turf(first_rune))
			QDEL_NULL(first_rune)
		if(!QDELETED(second_rune))
			new /obj/effect/temp_visual/cosmic_rune_fade(get_turf(second_rune))
			QDEL_NULL(second_rune)
	remove_hand_with_no_refund(user)

/obj/item/melee/touch_attack/star_touch/ignition_effect(atom/to_light, mob/user)
	. = span_rose("[DECLENT_RU_CAP(user, NOMINATIVE)] непринуждённо щёлкает пальцами, поджигая [to_light.declent_ru(ACCUSATIVE)] космическими энергиями. Чертовски круто!")
	remove_hand_with_no_refund(user)

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
		ignore_bluespace_interference = TRUE,
		no_effects = TRUE,
	)
	remove_hand_with_no_refund(user)


/obj/effect/ebeam/cosmic
	name = "звёздный луч"


/datum/status_effect/cosmic_beam
	id = "cosmic_beam"
	duration = 8 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	/// Stores the current beam target
	var/mob/living/current_target
	/// The maximum range of the beam
	var/max_range = 8
	/// Wether the beam is active or not
	var/active = FALSE
	/// The storage for the beam
	var/datum/beam/current_beam = null
	/// The effect-trail element type we drape on our victim while tethered (passive-scaled).
	var/cosmic_effect_trail
	/// Whether we successfully reeled the victim in (suppresses the "tether broken" warning).
	var/successful_teleport = FALSE


/datum/status_effect/cosmic_beam/on_creation(mob/living/new_owner, mob/living/current_target)
	cosmic_effect_trail = cosmic_trail_based_on_passive(new_owner)
	start_beam(current_target, new_owner)
	return ..()


/datum/status_effect/cosmic_beam/on_remove()
	if(current_target && get_dist(owner, current_target) <= max_range)
		yoink_victim()
		successful_teleport = TRUE
	lose_target()
	return ..()


/// Puts the victim to sleep and reels them in to the caster's feet, re-marking them.
/datum/status_effect/cosmic_beam/proc/yoink_victim()
	current_target.Sleeping(8 SECONDS)
	do_teleport(current_target, get_turf(owner), ignore_bluespace_interference = TRUE, no_effects = TRUE, ignore_blocking_traits = TRUE)
	current_target.apply_status_effect(/datum/status_effect/star_mark)


/datum/status_effect/cosmic_beam/be_replaced()
	if(active)
		QDEL_NULL(current_beam)
		active = FALSE
	return ..()


/// Called whenever we want to end the beam; makes sure things are cleaned up (see beam_died()).
/datum/status_effect/cosmic_beam/proc/lose_target()
	if(active)
		QDEL_NULL(current_beam)
		active = FALSE

	if(current_target)
		on_beam_release(current_target)

	current_target = null


/// Only called when the beam fails on its own (target fled out of range / died), not on a manual end.
/// Warns the caster the tether snapped and ends the effect without reeling the victim in.
/datum/status_effect/cosmic_beam/proc/beam_died()
	SIGNAL_HANDLER
	if(successful_teleport)
		return
	to_chat(owner, span_warning("Ваша космическая связь с [current_target?.declent_ru(INSTRUMENTAL) || "целью"] разорвана!"))
	active = FALSE
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
	current_beam = user.Beam(current_target, icon_state = "cosmic_beam", time = 1 MINUTES, maxdistance = max_range, beam_type = /obj/effect/ebeam/cosmic)
	RegisterSignal(current_beam, COMSIG_QDELETING, PROC_REF(beam_died))
	RegisterSignal(current_target, COMSIG_QDELETING, PROC_REF(beam_died))

	SSblackbox.record_feedback("tally", "gun_fired", 1, type)
	if(current_target)
		on_beam_hit(current_target, user)


/// What to add when the beam connects to a target: lock their teleporting and drape a cosmic-field trail on them.
/datum/status_effect/cosmic_beam/proc/on_beam_hit(mob/living/target, mob/living/user)
	if(istype(target, /mob/living/simple_animal/hostile/heretic_summon/star_gazer))
		return

	ADD_TRAIT(target, TRAIT_NO_TELEPORT, TRAIT_STATUS_EFFECT(id))
	target.AddElement(cosmic_effect_trail, /obj/effect/forcefield/cosmic_field/star_touch)


/// What to remove when the beam disconnects from a target
/datum/status_effect/cosmic_beam/proc/on_beam_release(mob/living/target)
	if(istype(target, /mob/living/simple_animal/hostile/heretic_summon/star_gazer))
		return

	REMOVE_TRAIT(target, TRAIT_NO_TELEPORT, TRAIT_STATUS_EFFECT(id))
	target.RemoveElement(cosmic_effect_trail, /obj/effect/forcefield/cosmic_field/star_touch)
