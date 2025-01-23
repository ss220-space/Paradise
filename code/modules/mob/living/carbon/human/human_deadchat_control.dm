// Custom human behavior for deadchat control


/mob/living/carbon/human/proc/dchat_emote()
	var/list/possible_emotes = list("scream", "clap", "snap", "crack", "dap", "burp")
	emote(pick(possible_emotes), intentional = TRUE)

/mob/living/carbon/human/proc/dchat_attack(intent)
	var/turf/ahead = get_turf(get_step(src, dir))
	var/atom/victim = locate(/mob/living) in ahead
	var/obj/item/in_hand = get_active_hand()
	var/implement = "[isnull(in_hand) ? "кулаками" : in_hand.declent_ru(INSTRUMENTAL)]"
	if(!victim)
		victim = locate(/obj/structure) in ahead
	if(!victim)
		switch(intent)
			if(INTENT_HARM)
				visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] дико [pluralize_ru(gender, "бьёт", "бьют")] [implement]!"))
			if(INTENT_HELP)
				visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] кажется, дела[pluralize_ru(gender, "ет", "ют")] глубокий вдох."))
		return
	implement = "[isnull(in_hand) ? "кулаки" : in_hand.declent_ru(ACCUSATIVE)]"
	if(isLivingSSD(victim))
		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] [intent == INTENT_HARM ? "неохотно " : ""] опуска[pluralize_ru(gender, "ет", "ют")] [implement]."))
		return

	var/original_intent = a_intent
	a_intent = intent
	if(in_hand)
		in_hand.melee_attack_chain(src, victim)
	else
		UnarmedAttack(victim, TRUE)
	a_intent = original_intent

/mob/living/carbon/human/proc/dchat_resist()
	if(!can_resist())
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] кажется, ничего не cмо[pluralize_ru(gender, "жет", "гут")] сделать!"))
		return
	if(!HAS_TRAIT(src, TRAIT_RESTRAINED))
		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] кажется, ничего особенного не дела[pluralize_ru(gender, "ет", "ют")]."))
		return

	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] пыта[pluralize_ru(gender, "ет", "ют")]ся освободиться!"))
	resist()

/mob/living/carbon/human/proc/dchat_pickup()
	var/turf/ahead = get_step(src, dir)
	var/obj/item/thing = locate(/obj/item) in ahead
	if(!thing)
		return

	var/old_loc = thing.loc
	var/obj/item/in_hand = get_active_hand()

	if(in_hand)
		if(HAS_TRAIT(in_hand, TRAIT_NODROP))
			visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] пыта[pluralize_ru(gender, "ет", "ют")]ся выпустить [in_hand.declent_ru(ACCUSATIVE)], но кажется, что [genderize_ru(in_hand.gender, "он застрял", "она застряла", "оно зястряло", "они застряли")] в руке!"))
			return
		if(in_hand.flags & ABSTRACT)
			visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] кажется, что у [genderize_ru(gender, "него", "неё", "него", "них")] заняты руки!"))
			return
		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] броса[pluralize_ru(gender, "ет", "ют")] [in_hand.declent_ru(ACCUSATIVE)] и поднимает [thing.declent_ru(ACCUSATIVE)]!"))
		do_unEquip(in_hand)
		in_hand.forceMove(old_loc)
	else
		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] поднима[pluralize_ru(gender, "ет", "ют")] [thing.declent_ru(ACCUSATIVE)]!"))
	put_in_active_hand(thing)

/mob/living/carbon/human/proc/dchat_throw()
	var/obj/item/in_hand = get_active_hand()
	if(!in_hand || in_hand.flags & ABSTRACT)
		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] дела[pluralize_ru(gender, "ет", "ют")] движение, похожее на бросок!"))
		return
	var/atom/possible_target
	var/cur_turf = get_turf(src)
	for(var/i in 1 to 5)
		cur_turf = get_step(cur_turf, dir)
		possible_target = locate(/mob/living) in cur_turf
		if(possible_target)
			break

		possible_target = locate(/obj/structure) in cur_turf
		if(possible_target)
			break

	if(!possible_target)
		possible_target = cur_turf
	if(HAS_TRAIT(in_hand, TRAIT_NODROP))
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] пыта[pluralize_ru(gender, "ет", "ют")]ся бросить [in_hand.declent_ru(ACCUSATIVE)][isturf(possible_target) ? "" : " в сторону [possible_target]"], но [genderize_ru(gender, "он", "она", "оно", "они")] не отрыва[pluralize_ru(gender, "ет", "ют")]ся от руки!"))
		return
	throw_item(possible_target)

/mob/living/carbon/human/proc/dchat_shove()
	var/turf/ahead = get_turf(get_step(src, dir))
	var/mob/living/carbon/human/H = locate(/mob/living/carbon/human) in ahead
	if(!H)
		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] пыта[pluralize_ru(gender, "ет", "ют")]ся что-то отодвинуть в сторону!"))
		return
	dna?.species.disarm(src, H)

/mob/living/carbon/human/proc/dchat_shoot()

	var/atom/possible_target
	var/cur_turf = get_turf(src)
	for(var/i in 1 to 5)
		cur_turf = get_step(cur_turf, dir)
		possible_target = locate(/mob/living) in cur_turf
		if(possible_target)
			break

	if(!possible_target)
		possible_target = cur_turf

	var/obj/item/gun/held_gun = get_active_hand()
	if(!held_gun)
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] направля[pluralize_ru(gender, "ет", "ют")] палец в форме пистолета в сторону [possible_target.declent_ru(GENITIVE)]!"))
		return
	if(!istype(held_gun))
		visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] направля[pluralize_ru(gender, "ет", "ют")] [held_gun.declent_ru(ACCUSATIVE)] в сторону [possible_target.declent_ru(GENITIVE)]!"))
		return
	// for his neutral special, he wields a Gun
	held_gun.afterattack(possible_target, src)
	visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] стреля[pluralize_ru(gender, "ет", "ют")] из [held_gun.declent_ru(GENITIVE)][isturf(possible_target) ? "" : " в сторону [possible_target.declent_ru(GENITIVE)]!"]"))

/mob/living/carbon/human/proc/dchat_step(dir)
	if(length(pulledby))
		resist_grab()
	step(src, dir)


/mob/living/carbon/human/deadchat_plays(mode = DEADCHAT_DEMOCRACY_MODE, cooldown = 7 SECONDS)
	var/list/inputs = list(
		"эмоция" = CALLBACK(src, PROC_REF(dchat_emote)),
		"атака" = CALLBACK(src, PROC_REF(dchat_attack), INTENT_HARM),
		"помощь" = CALLBACK(src, PROC_REF(dchat_attack), INTENT_HELP),
		"бросок" = CALLBACK(src, PROC_REF(dchat_throw)),
		"выстрел" = CALLBACK(src, PROC_REF(dchat_shoot)),
		"поднять" = CALLBACK(src, PROC_REF(dchat_pickup)),
		"обезоружить" = CALLBACK(src, PROC_REF(dchat_shove)),
		"сопротивляться" = CALLBACK(src, PROC_REF(dchat_resist)),
	)

	AddComponent(/datum/component/deadchat_control/human, mode, inputs, cooldown)
