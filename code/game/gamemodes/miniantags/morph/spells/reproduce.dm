#define MORPH_REPRODUCE_COST_INCREASE 30

/datum/action/cooldown/spell/morph_reproduce
	name = "Размножение"
	desc = "Разделитесь на две части, создав нового морфа. Можно использовать только на полу. Временно лишает вас возможности ползать по вентиляции."
	spell_requirements = NONE
	cooldown_time = 30 SECONDS
	button_icon_state = "morph_reproduce"
	background_icon_state = "bg_morph"
	var/hunger_cost = 150 // 5 humans

/datum/action/cooldown/spell/morph_reproduce/create_new_handler()
	var/datum/spell_handler/morph/handler = new
	return handler

/datum/action/cooldown/spell/morph_reproduce/update_button_name(atom/movable/screen/movable/action_button/button, force)
	name = "[initial(name)] ([hunger_cost])"
	. = ..()

/datum/action/cooldown/spell/morph_reproduce/can_cast_spell(feedback)
	. = ..()
	if(!.)
		return FALSE
	if(!ismorph(owner))
		return FALSE
	var/mob/living/simple_animal/hostile/morph/user = owner
	if(!user.can_reproduce)
		if(feedback)
			user.balloon_alert(user, "невозможно размножаться")
		return FALSE
	if(user.gathered_food < hunger_cost)
		if(feedback)
			user.balloon_alert(user, "нужно больше еды ([user.gathered_food]/[hunger_cost])")
		return FALSE
	if(!isturf(user.loc))
		if(feedback)
			to_chat(user, span_warning("нужна поверхность!"))
		return FALSE
	return TRUE

/datum/action/cooldown/spell/morph_reproduce/cast(atom/cast_on)
	. = ..()
	var/mob/living/simple_animal/hostile/morph/user = owner
	to_chat(user, span_sinister("Вы готовитесь разделиться на две части, что временно лишит вас возможности ползать по вентиляции!"))

	REMOVE_TRAIT(user, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите занять роль Морфа?", ROLE_MORPH, TRUE, poll_time = 10 SECONDS, source = /mob/living/simple_animal/hostile/morph)

	if(QDELETED(user))
		return

	if(user.stat == DEAD)
		reset_spell_cooldown()
		return

	if(!length(candidates))
		to_chat(user, span_warning("Ваше тело отказывается разделяться сейчас. Попробуйте позже."))
		reset_spell_cooldown()
		ADD_TRAIT(user, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
		return

	var/mob/picked_candidate = pick(candidates)

	user.use_food(hunger_cost)
	hunger_cost += MORPH_REPRODUCE_COST_INCREASE

	build_button_icon()

	playsound(user, SFX_BONEBREAK, 75, TRUE)
	var/mob/living/simple_animal/hostile/morph/new_morph = new /mob/living/simple_animal/hostile/morph(get_turf(user))
	var/datum/mind/player_mind = new /datum/mind(picked_candidate.key)
	player_mind.active = TRUE
	player_mind.transfer_to(new_morph)
	new_morph.make_morph_antag()

	ADD_TRAIT(user, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)
	user.create_log(MISC_LOG, "Made a new morph using [src]", new_morph)

#undef MORPH_REPRODUCE_COST_INCREASE
