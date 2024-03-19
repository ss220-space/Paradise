/mob/living/simple_animal/hostile/gorilla
	name = "горилла"
	desc = "Наземная, преимущественно травоядная обезьяна, населяющая леса центральной Африки, на Земле."
	icon = 'icons/mob/gorilla.dmi'
	icon_state = "crawling"
	icon_living = "crawling"
	icon_dead = "dead"
	gender = FEMALE
	speak_chance = 80
	maxHealth = 220
	health = 220
	mob_size = MOB_SIZE_LARGE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab/gorilla = 4)
	response_help = "prods"
	response_disarm = "challenges"
	response_harm = "thumps"
	attacktext = "pummels"
	speed = 0.5
	melee_damage_lower = 15
	melee_damage_upper = 18
	damage_coeff = list(BRUTE = 1, BURN = 1.5, TOX = 1.5, CLONE = 0, STAMINA = 0, OXY = 1.5)
	obj_damage = 20
	environment_smash = ENVIRONMENT_SMASH_WALLS
	attack_sound = 'sound/weapons/punch1.ogg'
	faction = list("hostile", "monkey", "jungle")
	robust_searching = TRUE
	minbodytemp = 270
	maxbodytemp = 350
	see_in_dark = 8
	can_collar = TRUE
	footstep_type = FOOTSTEP_MOB_BAREFOOT
	gold_core_spawnable = HOSTILE_SPAWN
	stat_attack = UNCONSCIOUS // Sleeping won't save you
	a_intent = INTENT_HARM // Angrilla
	tts_seed = "Mannoroth"
	/// Is the gorilla stood up or not?
	var/is_bipedal = FALSE
	/// The max number of crates we can carry
	var/crate_limit = 1
	/// Typecache of all the types we can pick up and carry
	var/list/carriable_cache
	/// A lazylist of all crates we are carrying
	var/list/atom/movable/crates_in_hand
	/// Chance to dismember while unconcious
	var/dismember_chance = 10
	/// Amount of stamina lost on a successful hit
	var/stamina_damage = 20
	/// Chance of doing the throw or stamina damage, along with the flat damage amount
	var/throw_onhit = 50
	/// Gorilla bipedal toggle.
	var/datum/action/innate/gorilla/gorilla_toggle/gorilla_toggle


/mob/living/simple_animal/hostile/gorilla/Initialize()
	. = ..()
	gorilla_toggle = new
	gorilla_toggle.Grant(src)
	var/static/default_cache = typecacheof(list(/obj/structure/closet/crate))	// Normal crates only please, no weird sized ones
	carriable_cache = default_cache


/mob/living/simple_animal/hostile/gorilla/Destroy()
	reset_behavior(play_emote = FALSE)
	LAZYCLEARLIST(crates_in_hand)
	QDEL_NULL(gorilla_toggle)
	return ..()


/mob/living/simple_animal/hostile/gorilla/Login()
	var/need_reset = last_known_ckey != client.ckey
	. = ..()
	if(need_reset)
		reset_behavior(play_emote = FALSE)


/mob/living/simple_animal/hostile/gorilla/Logout()
	. = ..()
	// 60 seconds to relogin is a generous number
	addtimer(CALLBACK(src, PROC_REF(delayed_reset)), 1 MINUTES, TIMER_UNIQUE|TIMER_OVERRIDE)


/mob/living/simple_animal/hostile/gorilla/proc/delayed_reset()
	if(!client)
		reset_behavior()


/datum/action/innate/gorilla/gorilla_toggle
	name = "Toggle Stand"
	desc = "Toggles between crawling and standing up. Use <b>Alt+Click</b> on self."
	icon_icon = 'icons/mob/actions/actions_animal.dmi'
	button_icon_state = "gorilla_toggle"
	check_flags = AB_CHECK_CONSCIOUS


/datum/action/innate/gorilla/gorilla_toggle/Activate()
	. = ..()
	var/mob/living/simple_animal/hostile/gorilla/gorilla = owner
	if(!istype(gorilla))
		return

	if(gorilla.is_bipedal && LAZYLEN(gorilla.crates_in_hand))
		to_chat(gorilla, span_warning("You can't get on all fours while carrying something!"))
		return

	gorilla.is_bipedal = !gorilla.is_bipedal // Toggle
	gorilla.visible_message(
		span_notice("[gorilla] [gorilla.is_bipedal ? "stands up menacingly." : "drops back to all fours."]"),
		span_notice("You [gorilla.is_bipedal ? "stand up" : "get down on all fours."]"),
		span_italics("You hear the sound of a gorilla rustling."),
	)

	if(gorilla.client)
		gorilla.oogaooga()

	gorilla.update_icon(UPDATE_ICON_STATE)


/mob/living/simple_animal/hostile/gorilla/AltClick(mob/living/simple_animal/hostile/gorilla/user)
	if(!istype(user) || src != user || !gorilla_toggle)
		return ..()
	gorilla_toggle.Activate()


/**
 * Returns a list with phrases to which gorilla reacts as if it were their names. For clientless mobs only.
 */
/mob/living/simple_animal/hostile/gorilla/proc/get_names()
	. = list("[lowertext(name)]", "gorilla", "горилла")


/**
 * Gorillas like to dismember limbs from unconscious mobs.
 * Returns null when the target is not an unconscious carbon mob; a list of limbs (possibly empty) otherwise.
 */
/mob/living/simple_animal/hostile/gorilla/proc/get_target_bodyparts(mob/living/carbon/human/target)
	if(!ishuman(target) || target.stat != CONSCIOUS)
		return
	var/list/parts = list()
	for(var/obj/item/organ/external/bodypart as anything in target.bodyparts)
		if(bodypart.limb_zone == BODY_ZONE_CHEST || bodypart.limb_zone == BODY_ZONE_PRECISE_GROIN || bodypart.limb_zone == BODY_ZONE_HEAD)
			continue // No chest or head removal please
		if(bodypart.cannot_amputate)
			continue // No dismembering of limbs that cannot be dismembered
		parts += bodypart
	return parts


/mob/living/simple_animal/hostile/gorilla/say(message, verb = "says", sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE)
	. = ..()
	if(.)
		oogaooga(100, rand(30, 100))


/mob/living/simple_animal/hostile/gorilla/AttackingTarget()
	if(client)
		if(istype(target, /obj/item/reagent_containers/food/snacks/grown/banana))
			if(is_on_cooldown())
				to_chat(src, span_warning("Вы не можете настолько быстро поедать бананы!"))
				return FALSE
			start_action_cooldown()
			eat_banana(target)
			return FALSE

		if(manipulate_crate(target))
			return FALSE

		if(isturf(target) && LAZYLEN(crates_in_hand))
			var/turf/target_turf = target
			if(!target_turf.is_blocked_turf())
				drop_random_crate(target)
				return FALSE

	. = ..()
	if(!.)
		return .

	if(client)
		oogaooga()

	var/list/parts = get_target_bodyparts(target)
	if(length(parts) && prob(dismember_chance))
		var/obj/item/organ/external/to_dismember = pick(parts)
		to_dismember.droplimb()
		return .

	if(isliving(target))
		var/mob/living/living_target = target
		if(prob(throw_onhit))
			living_target.throw_at(get_edge_target_turf(living_target, dir), rand(1, 2), 7, src)
			return .

		living_target.adjustStaminaLoss(stamina_damage)
		visible_message(span_warning("[src] knocks [living_target] down!"))


/mob/living/simple_animal/hostile/gorilla/update_icon_state()
	if(is_bipedal || LAZYLEN(crates_in_hand))
		icon_state = "standing"
		return
	icon_state = initial(icon_state)


/mob/living/simple_animal/hostile/gorilla/update_overlays()
	. = ..()
	if(!LAZYLEN(crates_in_hand))
		return
	var/atom/movable/random_crate = pick(crates_in_hand)
	var/mutable_appearance/crate_olay = mutable_appearance(random_crate.icon, random_crate.icon_state, appearance_flags = RESET_COLOR)
	crate_olay.copy_overlays(random_crate)
	. += crate_olay
	. += mutable_appearance(icon, "standing_overlay")


/mob/living/simple_animal/hostile/gorilla/CanAttack(atom/the_target)
	var/list/parts = get_target_bodyparts(target)
	return ..() && !ismonkeybasic(the_target) && (!parts || length(parts) > 3)


/mob/living/simple_animal/hostile/gorilla/CanSmashTurfs(turf/T)
	return iswallturf(T)


/mob/living/simple_animal/hostile/gorilla/handle_automated_speech(override)
	if(speak_chance && (override || prob(speak_chance)))
		oogaooga(100)
	return ..()


/mob/living/simple_animal/hostile/gorilla/proc/oogaooga(probability, volume = 50)
	var/chance = probability ? prob(probability) : prob(rand(15, 35))
	if(chance)
		playsound(src, 'sound/creatures/gorilla.ogg', volume, TRUE)


/mob/living/simple_animal/hostile/gorilla/special_hands_drop_action()
	if(LAZYLEN(crates_in_hand))
		drop_random_crate(drop_location())
		return TRUE
	return FALSE


/mob/living/simple_animal/hostile/gorilla/death(gibbed)
	if(LAZYLEN(crates_in_hand))
		drop_all_crates(drop_location())
	if(master)
		reset_behavior(play_emote = FALSE)
	return ..()


/mob/living/simple_animal/hostile/gorilla/examine(mob/user)
	. = ..()
	if(LAZYLEN(crates_in_hand))
		var/crate_text = "<span class='notice'>[p_theyre(TRUE)] carrying the following:\n"
		for(var/atom/movable/crate in crates_in_hand)
			crate_text += " - [crate.name]\n"
		crate_text += "</span>"
		. += crate_text


/**
 * Proc that manipulated with passed object. Opens/closes a crate/closet or picks up a crate.
 *
 * Arguments:
 * * target_object - object gorilla will manipulate with.
 */
/mob/living/simple_animal/hostile/gorilla/proc/manipulate_crate(atom/target_object)

	face_atom(target_object)

	var/is_correct_delivery = FALSE
	var/is_big_delivery = istype(target_object, /obj/structure/bigDelivery)
	if(is_big_delivery)
		var/obj/structure/bigDelivery/delivery = target_object
		if(istype(delivery.wrapped, /obj/structure/closet/crate))
			is_correct_delivery = TRUE

	if(istype(target_object, /obj/structure/closet) || is_big_delivery)
		var/obj/structure/closet/check_crate = target_object

		if(a_intent == INTENT_HELP)
			if(!is_big_delivery && check_crate.opened)
				to_chat(src, span_notice("You are closing [target_object]."))
				if(master)
					oogaooga(100, 100)
					custom_emote(EMOTE_VISIBLE, "ловко закрыва%(ет,ют)% ящик.", intentional = TRUE)
				check_crate.close()
				return TRUE

			if(master && !is_type_in_typecache(check_crate, carriable_cache) && !is_correct_delivery)
				oogaooga(100, 100)
				custom_emote(EMOTE_VISIBLE, "недовольно смотр%(ит,ят)% на ящик.", intentional = TRUE)
				return FALSE

		if(a_intent == INTENT_HARM)
			var/push_dir = get_dir(src, check_crate)
			var/turf/push_turf = get_step(check_crate, push_dir)
			if(push_turf.is_blocked_turf())
				if(master)
					oogaooga(100, 100)
					custom_emote(EMOTE_VISIBLE, "указыва%(ет,ют)% лапой на заполненное пространство за ящиком.", intentional = TRUE)
				return FALSE
			step(check_crate, push_dir)
			playsound(check_crate, 'sound/effects/hulk_hit_airlock.ogg', 50)
			if(master)
				oogaooga(100, 100)
				custom_emote(EMOTE_VISIBLE, "непринуждённо толка%(ет,ют)% ящик.", intentional = TRUE)
			return TRUE

	if(!is_type_in_typecache(target_object, carriable_cache) && !is_correct_delivery)
		return FALSE

	var/atom/movable/movable_target = target_object
	if(LAZYLEN(crates_in_hand) >= crate_limit)
		to_chat(src, span_warning("You are carrying too many crates!"))
		if(master)
			oogaooga(100, 100)
			custom_emote(EMOTE_VISIBLE, "чеш%(ет,ут)% затылок, перебирая ящики в лапах.", intentional = TRUE)
		return TRUE

	for(var/mob/living/inside_mob in movable_target.contents)
		if(inside_mob.mob_size < MOB_SIZE_HUMAN)
			continue
		to_chat(src, span_warning("This crate is too heavy!"))
		if(master)
			oogaooga(100, 100)
			custom_emote(EMOTE_VISIBLE, "туж%(ит,ат)%ся, но не мо%(жет,гут)% свдинуть [target_object] с места.", intentional = TRUE)
		return TRUE

	oogaooga(100)
	LAZYADD(crates_in_hand, movable_target)
	is_bipedal = TRUE
	update_icon()
	movable_target.forceMove(src)
	playsound(loc, 'sound/items/handling/toolbox_pickup.ogg', 80)
	if(master)
		custom_emote(EMOTE_VISIBLE, "хвата%(ет,ют)% [target_object] в лапы.", intentional = TRUE)
	return TRUE


/**
 * Drops one random crates from our crate list.
 *
 * Arguments:
 * * drop_to - location at which crates will be dropped.
 */
/mob/living/simple_animal/hostile/gorilla/proc/drop_random_crate(atom/drop_to)
	var/obj/structure/closet/crate/held_crate = pick(crates_in_hand)
	held_crate.forceMove(drop_to)
	LAZYREMOVE(crates_in_hand, held_crate)
	update_icon()
	playsound(loc, 'sound/items/handling/toolbox_drop.ogg', 100)
	if(master)
		oogaooga(100)
		custom_emote(EMOTE_VISIBLE, "броса%(ет,ют)% ящик на пол.", intentional = TRUE)


/**
 * Drops all the crates in our crate list.
 *
 * Arguments:
 * * drop_to - location at which crates will be dropped.
 */
/mob/living/simple_animal/hostile/gorilla/proc/drop_all_crates(atom/drop_to)
	for(var/obj/structure/closet/crate/held_crate as anything in crates_in_hand)
		held_crate.forceMove(drop_to)
		LAZYREMOVE(crates_in_hand, held_crate)
	update_icon()
	playsound(loc, 'sound/items/handling/toolbox_drop.ogg', 100)
	if(master)
		oogaooga(100)
		custom_emote(EMOTE_VISIBLE, "броса%(ет,ют)% все ящики на пол.", intentional = TRUE)


/mob/living/simple_animal/hostile/gorilla/add_collar(obj/item/clothing/accessory/petcollar/collar, mob/user)
	. = ..()
	if(. && istext(collar.tagname))
		attention_phrases |= lowertext(collar.tagname)


/mob/living/simple_animal/hostile/gorilla/regenerate_icons()
	return


/mob/living/simple_animal/hostile/gorilla/cargo_domestic
	name = "каргорилла"
	icon = 'icons/mob/cargorillia.dmi'
	desc = "Ручной самец гориллы, приписанный к департаменту грузоперевозок. Похоже у него набито тату \"Я люблю Маму\"."
	faction = list("neutral", "monkey", "jungle")
	gold_core_spawnable = NO_SPAWN
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	gender = MALE
	a_intent = INTENT_HELP
	crate_limit = 2
	attention_phrases = list("goril", "banan", "monkey", "горил", "банан", "обезьян", "карго")
	/// The ID card that the gorilla is currently wearing.
	var/obj/item/card/id/access_card


/mob/living/simple_animal/hostile/gorilla/cargo_domestic/Initialize(mapload)
	. = ..()
	access_card = new /obj/item/card/id/supply/cargo_gorilla(src)
	ADD_TRAIT(src, TRAIT_PACIFISM, INNATE_TRAIT)


/mob/living/simple_animal/hostile/gorilla/cargo_domestic/Destroy()
	QDEL_NULL(access_card)
	return ..()


/mob/living/simple_animal/hostile/gorilla/cargo_domestic/Login()
	. = ..()
	to_chat(src, span_boldnotice("Вы \"[name]\" - одомашненная горилла и питомец департамента карго. Вы преданная и трудолюбивая горилла и любите свою работу. Вы хорошая горилла, и карго любит Вас."))
	to_chat(src, span_boldnotice("В интенте \"HELP\" Вы можете подбирать ящики, щёлкнув по ним, и бросить их, щелкнув по открытому полу. Вы можете переносить [crate_limit] [declension_ru(crate_limit, "ящик", "ящика", "ящиков")] единовременно. В интенте \"HARM\" Вы можете толкать ящики, но не ломать их. Также Вы можете закрывать или открывать ящики используя Alt+Click."))
	to_chat(src, span_boldnotice("Легенды гласят, что бананы заключают в себе просвещение..."))


/mob/living/simple_animal/hostile/gorilla/cargo_domestic/get_access()
	. = ..()
	. |= access_card.GetAccess()


/obj/item/card/id/supply/cargo_gorilla
	name = "cargorilla ID"
	registered_name = "Cargorilla"
	desc = "A card used to provide ID and determine access across the station. A gorilla-sized ID for a gorilla-sized cargo technician."


/mob/living/simple_animal/hostile/gorilla/cargo_domestic/mars
	name = "Марс"
	real_name = "Марс"
	gender = MALE
	unique_pet = TRUE
	attention_phrases = list("mars", "марс", "goril", "banan", "monkey", "горил", "банан", "обезьян", "карго")


/mob/living/simple_animal/hostile/gorilla/cargo_domestic/mars/Initialize(mapload)
	. = ..()
	var/obj/structure/chair/chair = locate() in get_turf(src)
	chair?.buckle_mob(src, TRUE, FALSE)


/mob/living/simple_animal/hostile/gorilla/cargo_domestic/mars/get_names()
	. = ..()
	. += "mars"


/mob/living/simple_animal/hostile/gorilla/rampaging
	name = "Неистовая Горилла"
	desc = "Горилла, которая одичала. Бегите глупцы!"
	speed = 0
	color = "#ff0000"
	health = 350
	maxHealth = 350
	melee_damage_lower = 25
	melee_damage_upper = 35
	obj_damage = 40
	gold_core_spawnable = NO_SPAWN
	damage_coeff = list(BRUTE = 1.25, BURN = 1, TOX = 1.5, CLONE = 0, STAMINA = 0, OXY = 1)
	dismember_chance = 100
	stamina_damage = 40
	throw_onhit = 80
	can_befriend = FALSE


/mob/living/simple_animal/hostile/gorilla/rampaging/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_OVERLAYS)


/mob/living/simple_animal/hostile/gorilla/rampaging/update_overlays()
	. = ..()
	. += mutable_appearance('icons/effects/effects.dmi', "electricity")	// I wanna be Winston

