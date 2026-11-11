//Alium nests. Essentially beds with an unbuckle delay that only aliums can buckle mobs to.

/obj/structure/bed/nest
	name = "alien nest"
	desc = "Это отвратительная куча густой липкой смолы, по форме напоминающая гнездо."
	icon = 'icons/mob/xeno/structures.dmi'
	icon_state = "nest"
	max_integrity = 120
	elevation = 0
	comfort = 0
	obj_flags = NODECONSTRUCT
	allow_tucking = FALSE
	var/image/nest_overlay
	var/ghost_timer

/obj/structure/bed/nest/get_ru_names()
	return alist(
		NOMINATIVE = "гнездо ксеноморфа",
		GENITIVE = "гнезда ксеноморфа",
		DATIVE = "гнезду ксеноморфа",
		ACCUSATIVE = "гнездо ксеноморфа",
		INSTRUMENTAL = "гнездом ксеноморфа",
		PREPOSITIONAL = "гнезде ксеноморфа",
	)

/obj/structure/bed/nest/Initialize(mapload)
	. = ..()
	nest_overlay = image('icons/mob/xeno/structures.dmi', "nest_overlay", layer = BELOW_MOB_LAYER)

/obj/structure/bed/nest/Destroy()
	playsound(get_turf(src), 'sound/creatures/alien/xeno_resin_break.ogg', 80, TRUE)
	. = ..()

/obj/structure/bed/nest/has_prints()
	return FALSE

/obj/structure/bed/nest/user_buckle_mob(mob/living/target, mob/living/user, check_loc = TRUE)
	if(!isliving(target) || target.buckled || !in_range(src, user) || target.loc != loc || user.incapacitated())
		return FALSE

	if(target.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		to_chat(user, span_noticealien("Связь [declent_ru(target, GENITIVE)] с ульем не позволяет вам закрепить их в [declent_ru(src, ACCUSATIVE)]."))
		return FALSE

	if(!user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		to_chat(user, span_noticealien("Отсутствие связи с ульем не позволяет вам пристегнуть [declent_ru(target, ACCUSATIVE)] к [declent_ru(src, ACCUSATIVE)]."))
		return FALSE

	if(has_buckled_mobs())
		unbuckle_all_mobs()

	. = buckle_mob(target)
	if(.)
		target.visible_message(
			span_notice("[DECLENT_RU_CAP(user, NOMINATIVE)] выделя[PLUR_ET_UT(user)] густую мерзкую слизь, закрепляя [declent_ru(target, ACCUSATIVE)] в [declent_ru(src, ACCUSATIVE)]!"),
			span_userdanger("[DECLENT_RU_CAP(user, NOMINATIVE)] облива[PLUR_ET_UT(user)] вас вонючей смолой, заточая вас в [declent_ru(src, ACCUSATIVE)]!"),
			span_italics("Вы слышите чавканье..."),
		)
		if(isalien(user))
			ghost_timer = addtimer(CALLBACK(src, PROC_REF(ghost_check)), 15 SECONDS, TIMER_UNIQUE|TIMER_STOPPABLE)

/obj/structure/bed/nest/user_unbuckle_mob(mob/living/target, mob/living/user)
	if(user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		return unbuckle_mob(target)

	if(target != user)
		target.visible_message(
			span_notice("[DECLENT_RU_CAP(user, NOMINATIVE)] освобожда[PLUR_ET_UT(user)] [declent_ru(target, ACCUSATIVE)] из липкого гнезда!"),
			span_notice("[DECLENT_RU_CAP(user, NOMINATIVE)] освобожда[PLUR_ET_UT(user)] вас из гнезда."),
			span_italics("Вы слышите чавканье..."),
		)
	else
		target.visible_message(
			span_warning("[DECLENT_RU_CAP(target, NOMINATIVE)] пыта[PLUR_ET_UT(target)]ся освободиться от гнезда!"),
			span_warning("Вы пытаетесь освободиться из гнезда... (Задержитесь на две минуты.)"),
			span_italics("Вы слышите чавканье..."),
		)
		if(!do_after(target, 2 MINUTES, src))
			if(target?.buckled)
				to_chat(target, span_warning("Вы не можете выбраться из [declent_ru(src, GENITIVE)]!"))
			return
		if(!target.buckled)
			return
		target.visible_message(
			span_warning("[DECLENT_RU_CAP(target, NOMINATIVE)] освобожда[PLUR_ET_UT(target)]ся от гнезда!"),
			span_notice("Вы освобождаетесь от гнезда!"),
			span_italics("Вы слышите чавканье..."),
		)

	return unbuckle_mob(target)

/obj/structure/bed/nest/proc/ghost_check()
	if(!length(buckled_mobs))
		return
	for(var/mob/living/carbon/human/buckled_mob in buckled_mobs)
		var/obj/item/clothing/mask/facehugger/hugger_mask = buckled_mob.wear_mask
		if(istype(hugger_mask) && !hugger_mask.sterile && (locate(/obj/item/organ/internal/body_egg/alien_embryo) in buckled_mob.internal_organs))
			buckled_mob.throw_alert(ALERT_GHOST_NEST, /atom/movable/screen/alert/ghost)
			to_chat(buckled_mob, span_ghostalert("Вы можете покинуть тело, выйдя в призраки. Возможность вернуться в тело при этом сохранится. Когда вас извлекут из гнезда, вы получите уведомление."))

/obj/structure/bed/nest/post_buckle_mob(mob/living/target)
	ADD_TRAIT(target, TRAIT_RESTRAINED, type)
	target.add_offsets(UID(), y_add = 10)
	target.layer = BELOW_MOB_LAYER
	add_overlay(nest_overlay)

/obj/structure/bed/nest/post_unbuckle_mob(mob/living/target)
	REMOVE_TRAIT(target, TRAIT_RESTRAINED, type)
	target.remove_offsets(UID())
	target.layer = initial(target.layer)
	cut_overlay(nest_overlay)
	deltimer(ghost_timer)
	target.clear_alert(ALERT_GHOST_NEST)
	target.notify_ghost_cloning("Вы были отстегнуты от гнезда ксеноморфа! Нажмите на оповещение, чтобы вернуться в своё тело.", source = src)

/obj/structure/bed/nest/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/bed/nest/attack_alien(mob/living/carbon/alien/user)
	if(user.a_intent != INTENT_HARM)
		return attack_hand(user)
	else
		return ..()

/obj/structure/bed/nest/prevents_buckled_mobs_attacking()
	return TRUE
