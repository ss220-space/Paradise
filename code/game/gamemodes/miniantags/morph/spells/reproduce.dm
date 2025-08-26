/obj/effect/proc_holder/spell/morph_spell/reproduce
	name = "Размножение"
	desc = "Разделитесь на две части, создав нового морфа. Можно использовать только на полу. Временно лишает вас возможности ползать по вентиляции."
	hunger_cost = 150 // 5 humans
	base_cooldown = 30 SECONDS
	action_icon_state = "morph_reproduce"
	create_attack_logs = FALSE


/obj/effect/proc_holder/spell/morph_spell/reproduce/Initialize(mapload)
	. = ..()
	update_appearance(UPDATE_NAME)


/obj/effect/proc_holder/spell/morph_spell/reproduce/update_name(updates = ALL)
	. = ..()
	if(hunger_cost && action)
		name = "[initial(name)] ([hunger_cost])"
		updateButtonIcon(change_name = TRUE)


/obj/effect/proc_holder/spell/morph_spell/reproduce/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/morph_spell/reproduce/can_cast(mob/living/simple_animal/hostile/morph/user, charge_check, show_message)
	. = ..()
	if(!.)
		return
	if(!user.can_reproduce)
		if(show_message)
			user.balloon_alert(user, "невозможно размножаться")
		return FALSE
	if(!isturf(user.loc))
		if(show_message)
			to_chat(user, span_warning("нужна поверхность!"))
		return FALSE


/obj/effect/proc_holder/spell/morph_spell/reproduce/cast(list/targets, mob/living/simple_animal/hostile/morph/user)
	to_chat(user, span_sinister("Вы готовитесь разделиться на две части, что временно лишит вас возможности ползать по вентиляции!"))
	REMOVE_TRAIT(user, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)	// Temporarily disable it
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Морфа?", ROLE_MORPH, TRUE, poll_time = 10 SECONDS, source = /mob/living/simple_animal/hostile/morph)
	if(!length(candidates))
		to_chat(user, span_warning("Ваше тело отказывается разделяться сейчас. Попробуйте позже."))
		revert_cast(user)
		ADD_TRAIT(user, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)	// re enable the crawling
		return
	var/mob/C = pick(candidates)
	user.use_food(hunger_cost)
	hunger_cost += 30
	var/datum/spell_handler/morph/handler = custom_handler
	handler.hunger_cost += 30
	update_appearance(UPDATE_NAME)

	playsound(user, SFX_BONEBREAK, 75, TRUE)
	var/mob/living/simple_animal/hostile/morph/new_morph = new /mob/living/simple_animal/hostile/morph(get_turf(user))
	var/datum/mind/player_mind = new /datum/mind(C.key)
	player_mind.active = TRUE
	player_mind.transfer_to(new_morph)
	new_morph.make_morph_antag()
	ADD_TRAIT(user, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT) // re enable the crawling
	user.create_log(MISC_LOG, "Made a new morph using [src]", new_morph)

