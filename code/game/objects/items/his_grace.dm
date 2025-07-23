//His Grace is a very special weapon granted only to traitor chaplains and civilians.
//When awakened, He thirsts for blood and begins ticking a "bloodthirst" counter.
//The wielder of His Grace is immune to stuns and gradually heals.
//If the wielder fails to feed His Grace in time, He will devour them and become incredibly aggressive.
//Leaving His Grace alone for some time will reset His thirst and put Him to sleep.
//Using His Grace effectively requires extreme speed and care.
/obj/item/his_grace
	name = "artistic toolbox"
	desc = "Покрашенный в ярко-зелёные цвета тулбокс. От одного его вида становится страшно."
	ru_names = list(
		NOMINATIVE = "артистический ящик для инструментов",
		GENITIVE = "артистического ящика для инструментов",
		DATIVE = "артистическому ящику для инструментов",
		ACCUSATIVE = "артистический ящик для инструментов",
		INSTRUMENTAL = "артистическим ящиком для инструментов",
		PREPOSITIONAL = "артистическом ящике для инструментов"
	)
	icon = 'icons/goonstation/objects/objects.dmi'
	icon_state = "green"
	item_state = "toolbox_green"
	lefthand_file = 'icons/goonstation/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/goonstation/mob/inhands/items_righthand.dmi'
	w_class = WEIGHT_CLASS_GIGANTIC
	force = 12
	attack_verb = list("заробастил", "сокрушил")
	hitsound = 'sound/weapons/smash.ogg'
	actions_types = list(/datum/action/item_action/toggle)
	drop_sound = 'sound/items/handling/drop/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/toolbox_pickup.ogg'
	COOLDOWN_DECLARE(choose_cooldown)
	var/cooldown = 3 SECONDS
	var/mob/living/chosen_target
	var/awakened = FALSE
	var/bloodthirst = HIS_GRACE_SATIATED
	var/prev_bloodthirst = HIS_GRACE_SATIATED
	var/force_bonus = 0
	var/ascended = FALSE
	var/rogue = FALSE
	var/datum/grace_tier/tier

/obj/item/his_grace/ui_action_click(mob/user, datum/action/action, leftclick)
	if(!user.has_status_effect(STATUS_EFFECT_HISGRACE))
		to_chat(user, span_warning("Вы не совсем понимаете, что с этим делать."))
		return
	var/obj/item/his_grace/M = user.get_active_hand()
	if(!istype(M))
		return
	var/prev_has = HAS_TRAIT_FROM(src, TRAIT_NODROP, HIS_GRACE_TRAIT)
	if(prev_has)
		REMOVE_TRAIT(src, TRAIT_NODROP, HIS_GRACE_TRAIT)
	else
		ADD_TRAIT(src, TRAIT_NODROP, HIS_GRACE_TRAIT)
	to_chat(user, span_warning("[declent_ru(NOMINATIVE)] [prev_has ? "освобождает вашу руку" : "привязывается к вашей руке"]!"))

/obj/item/his_grace/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSprocessing, src)
	GLOB.poi_list |= src
	RegisterSignal(src, COMSIG_MOVABLE_POST_THROW, PROC_REF(move_gracefully))
	init_new_tier(HIS_GRACE_DORMANT)
	update_appearance()

/obj/item/his_grace/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	GLOB.poi_list.Remove(src)
	for(var/mob/living/L in src)
		L.forceMove(get_turf(src))
	return ..()

/obj/item/his_grace/update_icon_state()
	icon_state = ascended ? "gold" : (awakened ? (rogue ? "green4" : "green3") : "green")
	item_state = ascended ? "toolbox_gold" : "toolbox_green"
	return ..()

/obj/item/his_grace/proc/try_update_tier()
	if(!tier.next_tier_type)
		return FALSE

	if(count_player_victims() < tier.required_kills)
		return FALSE

	if(!init_new_tier(tier.next_tier_type))
		return FALSE

	return TRUE // tier updated.

/obj/item/his_grace/proc/init_new_tier(typepath)
	if(typepath)
		tier = new typepath()

	if(!tier)
		return FALSE // something bad occured, but we prevent runtimes

	tier.link_tier(src)
	tier.apply_tier()

	return TRUE

/obj/item/his_grace/proc/count_player_victims()
	var/victims
	for(var/mob/living/C in contents)
		if(!C.mind)
			continue
		victims++
	return victims

/obj/item/his_grace/attack_self(mob/living/user)
	if(awakened)
		return
	INVOKE_ASYNC(src, PROC_REF(awaken), user)

/obj/item/his_grace/attack(mob/living/M, mob/user, params, def_zone, skip_attack_anim = FALSE)
	var/mob/living/carbon/CM
	if(ishuman(M))
		CM = M
	if(awakened && (M.stat || CM?.health <= (HEALTH_THRESHOLD_CRIT-30))) //change because carbons on paradise are very lively
		consume(M)
		return
	..()

/obj/item/his_grace/pickup(mob/living/user)
	. = ..()
	SEND_SIGNAL(user, COMSIG_MOB_HALO_GAINED)

/obj/item/his_grace/dropped(mob/living/user, slot, silent = FALSE)
	. = ..()
	SEND_SIGNAL(user, COMSIG_MOB_HALO_GAINED)

/obj/item/his_grace/CtrlClick(mob/user)
	//you can't pull his grace
	return NONE

/obj/item/his_grace/examine(mob/user)
	. = ..()
	if(!awakened)
		. += span_his_grace("Защёлка [declent_ru(GENITIVE)] закрыта.")
		return
	switch(bloodthirst)
		if(HIS_GRACE_SATIATED to HIS_GRACE_PECKISH)
			. += span_his_grace("[declent_ru(NOMINATIVE)] не очень голоден. Пока что...")
		if(HIS_GRACE_PECKISH to HIS_GRACE_HUNGRY)
			. += span_his_grace("[declent_ru(NOMINATIVE)] слегка проголодался.")
		if(HIS_GRACE_HUNGRY to HIS_GRACE_FAMISHED)
			. += span_his_grace("[declent_ru(NOMINATIVE)] уже довольно голоден.")
		if(HIS_GRACE_FAMISHED to HIS_GRACE_STARVING)
			. += span_his_grace("[declent_ru(NOMINATIVE)] уже не скрывает, как пускает слюни при виде вас. Будьте осторожны.")
		if(HIS_GRACE_STARVING to HIS_GRACE_CONSUME_OWNER)
			. += span_his_grace("Вы играете с огнём. [declent_ru(NOMINATIVE)] в шаге от того, чтобы вас сожрать!")
		if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
			. += span_his_grace("[declent_ru(NOMINATIVE)] яростно трясётся, на сводя с вас глаз.")

/obj/item/his_grace/relaymove(mob/living/user, direction) //Allows changelings, etc. to climb out of Him after they revive, provided He isn't active
	if(awakened)
		return
	user.forceMove(get_turf(src))
	user.visible_message(span_warning("[user] выкарабкива[pluralize_ru(user.gender,"ет","ют")]ся из [declent_ru(GENITIVE)]!"), span_notice("Вы выбираетесь из [declent_ru(GENITIVE)]!"))

/obj/item/his_grace/process(seconds_per_tick)
	if(!bloodthirst)
		drowse()
		return
	if(bloodthirst < HIS_GRACE_CONSUME_OWNER && !ascended)
		adjust_bloodthirst((1 + FLOOR(LAZYLEN(contents) * 0.3, 1)) * seconds_per_tick) //Maybe adjust this?
	else
		adjust_bloodthirst(1 * seconds_per_tick) //don't cool off rapidly once we're at the point where His Grace consumes all.
	var/mob/living/master = get_atom_on_turf(src, /mob/living)
	if(!isnull(master) && istype(master, /mob/living) && master.is_in_hands(src)) //required type check
		switch(bloodthirst)
			if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
				consume_owner(master)
			else
				master.apply_status_effect(/datum/status_effect/his_grace)
		return
	forceMove(get_turf(src)) //no you can't put His Grace in a locker you just have to deal with Him
	if(bloodthirst < HIS_GRACE_CONSUME_OWNER)
		return
	if(bloodthirst >= HIS_GRACE_FALL_ASLEEP)
		drowse()
		return
	attack_nearby()

/obj/item/his_grace/proc/awaken(mob/user) //Good morning, Mr. Grace.
	if(awakened)
		return
	awakened = TRUE
	user.visible_message(span_boldwarning("[declent_ru(NOMINATIVE)] начинает яростно дребезжать. Он жаждет крови."), span_his_grace("Вы открываете защёлку [declent_ru(GENITIVE)]. Хорошая ли это была идея?"))
	gender = MALE
	adjust_bloodthirst(1)
	var/pixel_x_offset = -2
	var/pixel_y_offset = -3
	notify_ghosts(
		"[user.real_name] пробудил Его Светлость!",
		source = src,
		action = NOTIFY_FOLLOW,
		title = "Славься Его Светлость!",
		alert_overlay = image('icons/goonstation/objects/objects.dmi', "green4", pixel_x = pixel_x_offset, pixel_y = pixel_y_offset),
		ghost_sound = 'sound/effects/pope_entry.ogg'
	)
	playsound(user, 'sound/effects/his_grace/his_grace_awaken.ogg', 100)
	update_appearance()
	move_gracefully()
	init_new_tier(HIS_GRACE_AWAKENED)
	user.AddElement(/datum/element/halo_attach, GLOB.halo_overlays["his_grace"], GLOB.halo_callbacks["his_grace"])

/obj/item/his_grace/proc/move_gracefully()
	SIGNAL_HANDLER

	if(!awakened)
		return

	spasm_animation()

/obj/item/his_grace/proc/drowse() //Good night, Mr. Grace.
	if(!awakened || ascended)
		return
	var/turf/T = get_turf(src)
	T.visible_message(span_boldwarning("[declent_ru(NOMINATIVE)] медленно затихает и замирает. Защёлка [declent_ru(GENITIVE)] с громким щелчком захлопывается."))
	playsound(loc, 'sound/weapons/batonextend.ogg', 100, TRUE)
	animate(src, transform=matrix())
	gender = initial(gender)
	awakened = FALSE
	bloodthirst = 0
	rogue = FALSE
	init_new_tier(HIS_GRACE_DORMANT)
	update_appearance()

/obj/item/his_grace/proc/consume(mob/living/meal) //Here's your dinner, Mr. Grace.
	if(!meal)
		return
	meal.visible_message(span_warning("[declent_ru(NOMINATIVE)] открывается нараспашку и пожирает [meal]!"), span_his_grace("[span_big("[declent_ru(NOMINATIVE)] пожирает вас!")]"))
	meal.adjustBruteLoss(200)
	meal.death()
	playsound(meal, 'sound/weapons/bladeslice.ogg', 75, TRUE)
	playsound(loc, 'sound/goonstation/misc/burp_alien.ogg', 50, FALSE)
	meal.forceMove(src)
	force_bonus += HIS_GRACE_FORCE_BONUS
	prev_bloodthirst = bloodthirst
	if(prev_bloodthirst < HIS_GRACE_CONSUME_OWNER)
		bloodthirst = max(round(LAZYLEN(contents)/2), 1) //Never fully sated, and His hunger will only grow.
	else
		bloodthirst = HIS_GRACE_CONSUME_OWNER
	try_update_tier()
	update_stats()

/obj/item/his_grace/proc/consume_owner(mob/living/owner)
	owner.visible_message(span_boldwarning("[declent_ru(NOMINATIVE)] натравляется на [owner]!"), span_his_grace("[declent_ru(NOMINATIVE)] натравляется на вас!"))
	do_attack_animation(owner, null, src)
	owner.emote("scream")
	owner.remove_status_effect(/datum/status_effect/his_grace)
	REMOVE_TRAIT(src, TRAIT_NODROP, HIS_GRACE_TRAIT)
	owner.RemoveElement(/datum/element/halo_attach)
	owner.Paralyse(60 SECONDS)
	owner.adjustBruteLoss(owner.maxHealth)
	playsound(owner, 'sound/effects/splat.ogg', 100, FALSE)
	rogue = TRUE
	update_appearance()

/obj/item/his_grace/proc/attack_nearby()
	if(awakened)
		rogue = TRUE
	var/list/targets = list()
	var/list/adjacent_targets = list()
	for(var/mob/living/L in oview(5, src))
		(get_dist(src, L) <= 1) ? (adjacent_targets += L) : (targets += L)

	if(!(LAZYLEN(targets) + LAZYLEN(adjacent_targets)))
		return

	if(LAZYLEN(adjacent_targets))
		chosen_target = pick(adjacent_targets)
	else if(COOLDOWN_FINISHED(src, choose_cooldown) || !(chosen_target in (targets + adjacent_targets)))
		chosen_target = pick(targets)
		COOLDOWN_START(src, choose_cooldown, cooldown)

	step_to(src, chosen_target)
	if(!Adjacent(chosen_target))
		return
	if(chosen_target.stat)
		consume(chosen_target)
		return
	chosen_target.visible_message(span_warning("[declent_ru(NOMINATIVE)] бросается на [chosen_target]!"), span_his_grace("[declent_ru(NOMINATIVE)] бросается на вас!"))
	do_attack_animation(chosen_target, null, src)
	playsound(chosen_target, 'sound/weapons/smash.ogg', 50, TRUE)
	playsound(chosen_target, 'sound/weapons/bladeslice.ogg', 50, TRUE)
	chosen_target.adjustBruteLoss(force)
	adjust_bloodthirst(-5) //Don't stop attacking they're right there!

/obj/item/his_grace/proc/adjust_bloodthirst(amt)
	prev_bloodthirst = bloodthirst
	if(prev_bloodthirst < HIS_GRACE_CONSUME_OWNER && !ascended)
		bloodthirst = clamp(bloodthirst + amt, HIS_GRACE_SATIATED, HIS_GRACE_CONSUME_OWNER)
	else if(!ascended)
		bloodthirst = clamp(bloodthirst + amt, HIS_GRACE_CONSUME_OWNER, HIS_GRACE_FALL_ASLEEP)
	update_stats()

/obj/item/his_grace/proc/update_stats()
	var/mob/living/master = get_atom_on_turf(src, /mob/living)
	if(isnull(master))
		return
	switch(bloodthirst)
		if(HIS_GRACE_CONSUME_OWNER to HIS_GRACE_FALL_ASLEEP)
			if(HIS_GRACE_CONSUME_OWNER > prev_bloodthirst)
				master.visible_message(span_userdanger("[declent_ru(NOMINATIVE)] входит в ярость!"))
		if(HIS_GRACE_STARVING to HIS_GRACE_CONSUME_OWNER)
			if(HIS_GRACE_STARVING > prev_bloodthirst)
				master.visible_message(span_boldwarning("[declent_ru(NOMINATIVE)] адски голоден!"), span_his_grace("[span_big("Кровожадность [declent_ru(GENITIVE)] овладевает вами. [declent_ru(NOMINATIVE)] должен быть накормлен сейчас же, иначе будут последствия.\
				[force_bonus < 15 ? "И всё ещё, его сила растёт.":""]")]"))
				force_bonus = max(force_bonus, 15)
		if(HIS_GRACE_FAMISHED to HIS_GRACE_STARVING)
			if(HIS_GRACE_FAMISHED > prev_bloodthirst)
				master.visible_message(span_boldwarning("[declent_ru(NOMINATIVE)] очень голоден!"), span_his_grace("[span_big("Шипы пронзают вашу руку. [declent_ru(NOMINATIVE)] должен быть накормлен.\
				[force_bonus < 10 ? " Его сила растёт.":""]")]"))
				force_bonus = max(force_bonus, 10)
			if(prev_bloodthirst >= HIS_GRACE_STARVING)
				master.visible_message(span_warning("[declent_ru(NOMINATIVE)] довольно голоден!"), span_his_grace("Ваша кровожадность спадает."))
		if(HIS_GRACE_HUNGRY to HIS_GRACE_FAMISHED)
			if(HIS_GRACE_HUNGRY > prev_bloodthirst)
				master.visible_message(span_boldwarning("[declent_ru(NOMINATIVE)] проголодался!"), span_his_grace("[span_big("Вы чувствуете голод [declent_ru(GENITIVE)].\
				[force_bonus < 5 ? " Его сила растёт.":""]")]"))
				force_bonus = max(force_bonus, 5)
			if(prev_bloodthirst >= HIS_GRACE_FAMISHED)
				master.visible_message(span_warning("[declent_ru(NOMINATIVE)] незначительно голоден."), span_his_grace("Голод [declent_ru(GENITIVE)] незначительно спадает..."))
		if(HIS_GRACE_PECKISH to HIS_GRACE_HUNGRY)
			if(HIS_GRACE_PECKISH > prev_bloodthirst)
				master.visible_message(span_warning("[declent_ru(NOMINATIVE)] не против бы перекусить."), span_his_grace("[declent_ru(NOMINATIVE)] начинает голодать."))
			if(prev_bloodthirst >= HIS_GRACE_HUNGRY)
				master.visible_message(span_warning("[declent_ru(NOMINATIVE)] лишь слегка проголодался."), span_his_grace("Голод [declent_ru(GENITIVE)] незначительно спадает..."))
		if(HIS_GRACE_SATIATED to HIS_GRACE_PECKISH)
			if(prev_bloodthirst >= HIS_GRACE_PECKISH)
				master.visible_message(span_warning("[declent_ru(NOMINATIVE)] сыт."), span_his_grace("Голод [declent_ru(GENITIVE)] спадает..."))
	force = initial(force) + force_bonus

/obj/item/his_grace/proc/on_ascend()
	if(ascended)
		return
	var/mob/living/carbon/human/master = loc
	ascended = TRUE
	update_appearance()
	playsound(src, 'sound/effects/his_grace/his_grace_ascend.ogg', 100)
	if(!istype(master))
		return
	if(master.is_in_hands(src))
		master.update_inv_l_hand()
		master.update_inv_r_hand()
	master.visible_message(span_his_grace("[span_big("Боги заинтересовались тобой.")]"))
	SEND_SIGNAL(master, COMSIG_MOB_HALO_GAINED)


//for thunderdome
/obj/item/his_grace/no_sound

/obj/item/his_grace/no_sound/awaken(mob/user) // no announce
	if(awakened)
		return
	awakened = TRUE
	user.visible_message(span_boldwarning("[declent_ru(NOMINATIVE)] начинает яростно дребезжать. Он жаждет крови."), span_his_grace("Вы открываете защёлку [declent_ru(GENITIVE)]. Хорошая ли это была идея?"))
	gender = MALE
	adjust_bloodthirst(1)
	playsound(user, 'sound/effects/his_grace/his_grace_awaken.ogg', 100)
	update_appearance()
	move_gracefully()
	init_new_tier(HIS_GRACE_AWAKENED)
	user.AddElement(/datum/element/halo_attach, GLOB.halo_overlays["his_grace"], GLOB.halo_callbacks["his_grace"])


/proc/is_grace_ascended(mob/living/carbon/human/user)
	if(!istype(user))
		return
	var/obj/item/his_grace/his_grace = user.find_item(/obj/item/his_grace)
	return his_grace ? his_grace.ascended : FALSE
