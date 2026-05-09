/// Left behind when a legion infects you, for medical enrichment
/obj/item/organ/internal/legion_tumour
	name = "legion tumour"
	desc = "Пульсирующая масса плоти и чёрных щупалец, способная регенерировать ткани за страшную цену."
	// failing_desc = "pulses and writhes with horrible life, reaching towards you with its tendrils!"
	icon_state = "legion_remains"
	slot = INTERNAL_ORGAN_PARASITE_EGG
	// organ_flags = parent_type::organ_flags | ORGAN_HAZARDOUS // Похуй потом
	// decay_factor = STANDARD_ORGAN_DECAY * 3 // About 5 minutes outside of a host
	/// What stage of growth the corruption has reached.
	var/stage = 0
	/// We apply this status effect periodically or when used on someone
	var/applied_status = /datum/status_effect/regenerative_core
	/// How long have we been in this stage?
	var/elapsed_time = 0 SECONDS
	/// How long does it take to advance one stage?
	var/growth_time = 80 SECONDS // Long enough that if you go back to lavaland without realising it you're not totally fucked
	/// What kind of mob will we transform into?
	var/spawn_type = /mob/living/basic/mining/legion
	/// Spooky sounds to play as you start to turn
	var/static/list/spooky_sounds = list(
		'sound/voice/lowHiss1.ogg',
		'sound/voice/lowHiss2.ogg',
		'sound/voice/lowHiss3.ogg',
		'sound/voice/lowHiss4.ogg',
	)

/obj/item/organ/internal/legion_tumour/get_ru_names()
	return list(
		NOMINATIVE = "опухоль легиона",
		GENITIVE = "опухоли легиона",
		DATIVE = "опухоли легиона",
		ACCUSATIVE = "опухоль легиона",
		INSTRUMENTAL = "опухолью легиона",
		PREPOSITIONAL = "опухоли легиона",
	)

// /obj/item/organ/internal/legion_tumour/Initialize(mapload)
// 	. = ..()
// 	animate_pulse()

// /obj/item/organ/internal/legion_tumour/on_begin_failure()
// 	animate_pulse()
//
// /obj/item/organ/internal/legion_tumour/on_failure_recovery()
// 	animate_pulse()
//
// /// Do a heartbeat animation depending on if we're failing or not
// /obj/item/organ/internal/legion_tumour/proc/animate_pulse()
// 	animate(src, transform = matrix()) // Stop any current animation
//
// 	var/speed_divider = organ_flags & ORGAN_FAILING ? 2 : 1
//
// 	animate(src, transform = matrix().Scale(1.1), time = 0.5 SECONDS / speed_divider, easing = SINE_EASING | EASE_OUT, loop = -1, flags = ANIMATION_PARALLEL)
// 	animate(transform = matrix(), time = 0.5 SECONDS / speed_divider, easing = SINE_EASING | EASE_IN)
// 	animate(transform = matrix(), time = 2 SECONDS / speed_divider)

/obj/item/organ/internal/legion_tumour/insert(mob/living/carbon/egg_owner, special)
	. = ..()
	ADD_TRAIT(egg_owner, TRAIT_LEGION_TUMOUR, GENERIC_TRAIT)
	egg_owner.med_hud_set_status()

/obj/item/organ/internal/legion_tumour/remove(mob/living/carbon/egg_owner, special, movement_flags)
	stage = 0
	elapsed_time = 0
	if(!egg_owner)
		return

	REMOVE_TRAIT(egg_owner, TRAIT_LEGION_TUMOUR, GENERIC_TRAIT)
	egg_owner.med_hud_set_status()

/obj/item/organ/internal/legion_tumour/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	if(try_apply(target, user))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()

/// Smear it on someone like a regen core, why not. Make sure they're alive though.
/obj/item/organ/internal/legion_tumour/proc/try_apply(mob/living/target, mob/user)
	if(!ishuman(target))
		return FALSE
	if(target.stat == DEAD)
		balloon_alert(user, "не сработает на трупах!")
		return FALSE
	. = TRUE
	if(target != user)
		target.visible_message(
			span_warning("[user] заставляет [target] применить [declent_ru(ACCUSATIVE)]... Чёрные щупальца опутывают [GEND_HIS_HER(user)]!"),
			span_notice("Вы заставили [target] применить [declent_ru(ACCUSATIVE)]... Чёрные щупальца опутывают [GEND_HIS_HER(user)]!"),
		)
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "other"))
	else
		to_chat(user, span_notice("Вы начинаете наносить [declent_ru(ACCUSATIVE)] на себя. Мерзкие щупальца скрепляют ваше тело, но как долго это продлится?"))
		SSblackbox.record_feedback("nested tally", "hivelord_core", 1, list("[type]", "used", "self"))

	target.apply_status_effect(STATUS_EFFECT_REGENERATIVE_CORE)
	qdel(src)

/obj/item/organ/internal/legion_tumour/on_life(seconds_per_tick)
	. = ..()
	if(QDELETED(src) || QDELETED(owner))
		return

	if(stage >= 2)
		if(SPT_PROB(stage / 5, seconds_per_tick))
			to_chat(owner, span_notice("Вы чувствуете себя немного лучше."))
			owner.apply_status_effect(applied_status) // It's not all bad!
		if(SPT_PROB(1, seconds_per_tick))
			owner.emote("twitch")

	switch(stage)
		if(2, 3)
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(owner, span_danger("Ваша грудь болезненно сжимается!"))
			if(SPT_PROB(1, seconds_per_tick))
				to_chat(owner, span_danger("Вы чувствуете слабость."))
			if(SPT_PROB(1, seconds_per_tick))
				SEND_SOUND(owner, sound(pick(spooky_sounds)))
			if(SPT_PROB(2, seconds_per_tick))
				owner.vomit()
		if(4, 5)
			if(SPT_PROB(2, seconds_per_tick))
				to_chat(owner, span_danger("Что-то шевелится под вашей кожей."))
			if(SPT_PROB(2, seconds_per_tick))
				if(prob(40))
					SEND_SOUND(owner, sound('sound/spookoween/ghost_whisper.ogg'))
				else
					SEND_SOUND(owner, sound(pick(spooky_sounds)))
			if(SPT_PROB(3, seconds_per_tick))
				owner.vomit(0, VOMIT_BLOOD)
				if(prob(50))
					var/turf/check_turf = get_step(owner.loc, owner.dir)
					var/atom/land_turf = (check_turf.is_blocked_turf()) ? owner.loc : check_turf
					var/mob/living/basic/mining/legion_brood/child = new(land_turf)
					child.assign_creator(owner, copy_full_faction = FALSE)

			if(SPT_PROB(3, seconds_per_tick))
				to_chat(owner, span_danger("Ваши мышцы ноют."))
				owner.adjustBruteLoss(20)

	if(stage == 5)
		if(SPT_PROB(10, seconds_per_tick))
			infest()
		return

	elapsed_time += seconds_per_tick SECONDS
	if(elapsed_time < growth_time)
		return
	stage++
	elapsed_time = 0
	if(stage == 5)
		to_chat(owner, span_danger("Что-то движется под вашей кожей!"))

/// Consume our host
/obj/item/organ/internal/legion_tumour/proc/infest()
	if(QDELETED(src) || QDELETED(owner))
		return

	owner.visible_message(span_boldwarning("Чёрные щупальца вырываются из плоти [owner], покрывая [GEND_HIS_HER(owner)] аморфной массой!"))
	var/mob/living/basic/mining/legion/new_legion = new spawn_type(owner.loc)
	new_legion.consume(owner)
	qdel(src)

/obj/item/organ/internal/legion_tumour/on_find(mob/living/finder)
	. = ..()
	to_chat(finder, span_warning("В груди [owner] огромная опухоль!"))
	if(stage < 4)
		to_chat(finder, span_notice("Щупальца дёргаются и тянутся к свету."))
		return
	to_chat(finder, span_notice("Пульсирующие щупальца пронизывают всё тело."))
	if(prob(stage * 2))
		infest()

