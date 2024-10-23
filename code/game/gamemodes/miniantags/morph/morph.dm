#define MORPHED_SPEED 2.5
#define ITEM_EAT_COST 5
#define MORPHS_ANNOUNCE_THRESHOLD 5

/mob/living/simple_animal/hostile/morph
	name = "morph"
	real_name = "morph"
	desc = "A revolting, pulsating pile of flesh."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	speed = 1.5
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	move_resist = MOVE_FORCE_STRONG // Fat being
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	tts_seed = "Treant"

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	maxHealth = 150
	health = 150
	environment_smash = 1
	obj_damage = 50
	melee_damage_lower = 15
	melee_damage_upper = 15
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	vision_range = 1 // Only attack when target is close
	wander = 0
	attacktext = "кусает"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)
	/// If the morph can reproduce or not
	var/can_reproduce = TRUE
	/// If the morph is disguised or not
	var/morphed = FALSE
	/// If the morph is ready to perform an ambush
	var/ambush_prepared = FALSE
	/// How much damage a successful ambush attack does
	var/ambush_damage = 25
	/// How much weaken a successful ambush attack applies
	var/ambush_weaken = 6 SECONDS
	/// How much the morph has gathered in terms of food. Used to reproduce and such
	var/gathered_food = 20 // Start with a bit to use abilities
	/// Antagonist datum, simplifies interaction with morph
	var/datum/antagonist/morph/antag_datum = new

/mob/living/simple_animal/hostile/morph/proc/check_morphs()
	if((LAZYLEN(GLOB.morphs_alive_list) >= MORPHS_ANNOUNCE_THRESHOLD) && (!GLOB.morphs_announced))
		GLOB.command_announcement.Announce("Внимание! Зафиксированы множественные биоугрозы 6 уровня на [station_name()]. Необходима ликвидация угрозы для продолжения безопасной работы.", "Отдел Центрального Командования по биологическим угрозам.", 'sound/AI/commandreport.ogg')
		GLOB.morphs_announced = TRUE
		SSshuttle.emergency.cancel()

/mob/living/simple_animal/hostile/morph/Initialize(mapload)
	. = ..()
	GLOB.morphs_alive_list += src
	check_morphs()

/mob/living/simple_animal/hostile/morph/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/morph/get_status_tab_items()
	var/list/status_tab_data = ..()
	. = status_tab_data
	status_tab_data[++status_tab_data.len] = list("Food Stored:", "[gathered_food]")

/mob/living/simple_animal/hostile/morph/wizard
	name = "magical morph"
	real_name = "magical morph"
	desc = "A revolting, pulsating pile of flesh. This one looks somewhat.. magical."
	can_reproduce = FALSE

/mob/living/simple_animal/hostile/morph/wizard/make_morph_antag(grant_objectives = TRUE)
	antag_datum.is_magical = TRUE
	. = ..()

/mob/living/simple_animal/hostile/morph/proc/try_eat(atom/movable/item)
	var/food_value = calc_food_gained(item)
	if(food_value + gathered_food < 0)
		to_chat(src, span_warning("You can't force yourself to eat more disgusting items. Eat some living things first."))
		return

	var/eat_self_message
	if(food_value < 0)
		eat_self_message = span_warning("You start eating [item]... disgusting....")
	else
		eat_self_message = span_notice("You start eating [item].")
	visible_message(span_warning("[src] starts eating [target]!"), eat_self_message, "You hear loud crunching!")

	if(do_after(src, 3 SECONDS, item))
		if(food_value + gathered_food < 0)
			to_chat(src, span_warning("You can't force yourself to eat more disgusting items. Eat some living things first."))
			return
		eat(item)

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/item)
	if(item?.loc != src)
		visible_message(span_warning("[src] swallows [item] whole!"))

		item.extinguish_light()
		item.forceMove(src)

		var/food_value = calc_food_gained(item)
		add_food(food_value)
		if(food_value > 0)
			adjustHealth(-food_value)
		add_attack_logs(src, item, "morph ate")
		return TRUE

	return FALSE

/mob/living/simple_animal/hostile/morph/proc/calc_food_gained(mob/living/living)
	if(!istype(living))
		return -ITEM_EAT_COST // Anything other than a tasty mob will make me sad ;(

	var/gained_food = max(5, 10 * living.mob_size) // Tiny things are worth less
	if(ishuman(living) && !is_monkeybasic(living))
		gained_food += 10 // Humans are extra tasty

	return gained_food

/mob/living/simple_animal/hostile/morph/proc/use_food(amount)
	if(amount > gathered_food)
		return FALSE
	add_food(-amount)
	return TRUE

/**
 * Adds the given amount of food to the gathered food and updates the actions.
 * Does not include a check to see if it goes below 0 or not
 */
/mob/living/simple_animal/hostile/morph/proc/add_food(amount)
	gathered_food += amount
	update_action_buttons_icon()

/mob/living/simple_animal/hostile/morph/proc/assume()
	morphed = TRUE

	//Morph is weaker initially when disguised
	melee_damage_lower = 5
	melee_damage_upper = 5
	set_varspeed(MORPHED_SPEED)
	antag_datum.ambush_spell.updateButtonIcon()
	antag_datum.pass_airlock_spell.updateButtonIcon()
	move_resist = MOVE_FORCE_DEFAULT // They become more fragile and easier to move

/mob/living/simple_animal/hostile/morph/proc/restore()
	if(!morphed)
		return
	morphed = FALSE

	//Baseline stats
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	set_varspeed(initial(speed))

	if(ambush_prepared)
		to_chat(src, span_warning("The ambush potential has faded as you take your true form."))

	failed_ambush()
	antag_datum.pass_airlock_spell.updateButtonIcon()
	move_resist = MOVE_FORCE_STRONG // Return to their fatness

/mob/living/simple_animal/hostile/morph/proc/prepare_ambush()
	ambush_prepared = TRUE
	to_chat(src, span_sinister("You are ready to ambush any unsuspected target. Your next attack will hurt a lot more and weaken the target! Moving will break your focus. Standing still will perfect your disguise."))
	apply_status_effect(/datum/status_effect/morph_ambush)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/mob/living/simple_animal/hostile/morph/proc/failed_ambush()
	ambush_prepared = FALSE
	antag_datum.ambush_spell.updateButtonIcon()
	antag_datum.mimic_spell.perfect_disguise = FALSE // Reset the perfect disguise
	remove_status_effect(/datum/status_effect/morph_ambush)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)

/mob/living/simple_animal/hostile/morph/proc/perfect_ambush()
	antag_datum.mimic_spell.perfect_disguise = TRUE // Reset the perfect disguise
	to_chat(src, span_sinister("You've perfected your disguise. Making you indistinguishable from the real form!"))

/mob/living/simple_animal/hostile/morph/proc/on_move()
	failed_ambush()
	to_chat(src, span_warning("You moved out of your ambush spot!"))

/mob/living/simple_animal/hostile/morph/death(gibbed)
	. = ..()
	if(stat == DEAD && gibbed)
		for(var/atom/movable/eaten_thing in src)
			eaten_thing.forceMove(loc)
			if(prob(90))
				step(eaten_thing, pick(GLOB.alldirs))
	// Only execute the below if we successfully died
	if(!.)
		return FALSE

	GLOB.morphs_alive_list -= src

/mob/living/simple_animal/hostile/morph/attack_hand(mob/living/carbon/human/attacker)
	if(ambush_prepared)
		to_chat(attacker, "[span_warning("[src] feels a bit different from normal... it feels more..")] [span_danger("SLIMEY?!")]")
		ambush_attack(attacker, TRUE)
		return TRUE

	else if (!morphed)
		to_chat(attacker, span_warning("Touching [src] with your hands hurts you!"))
		attacker.apply_damage(20, def_zone = attacker.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
		add_food(5)

	restore_form()
	return ..()

/mob/living/simple_animal/hostile/morph/proc/restore_form()
	if(morphed)
		return antag_datum.mimic_spell.restore_form(src);

/mob/living/simple_animal/hostile/morph/attackby(obj/item/item, mob/living/user)
	if(stat == DEAD)
		restore_form()
		return ..()

	if(user.a_intent == INTENT_HELP && ambush_prepared)
		to_chat(user, span_warning("You try to use [item] on [src]... it seems different than no-"))
		ambush_attack(user, TRUE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!morphed && isrobot(user))
		var/food_value = calc_food_gained(item)
		if(food_value + gathered_food > 0)
			to_chat(user, span_warning("Attacking [src] damaging your systems!"))
			user.apply_damage(70)
			add_food(-5)

		return ..()

	if(!morphed && prob(50))
		var/food_value = calc_food_gained(item)
		if(food_value + gathered_food > 0 && !(item.item_flags & ABSTRACT) && user.drop_item_ground(item))
			to_chat(user, span_warning("[src] just ate your [item]!"))
			eat(item)
			return ATTACK_CHAIN_BLOCKED_ALL

		return ..()

	restore_form()
	return ..()

/mob/living/simple_animal/hostile/morph/attack_animal(mob/living/simple_animal/animal)
	if(animal.a_intent == INTENT_HELP && ambush_prepared)
		to_chat(animal, "[span_notice("You nuzzle [src].")] [span_danger("And [src] nuzzles back!")]")
		ambush_attack(animal, TRUE)
		return TRUE

	restore_form()

/mob/living/simple_animal/hostile/morph/attack_larva(mob/living/carbon/alien/larva/L)
	restore_form()

/mob/living/simple_animal/hostile/morph/attack_alien(mob/living/carbon/alien/humanoid/M)
	restore_form()

/mob/living/simple_animal/hostile/morph/attack_tk(mob/user)
	restore_form()

/mob/living/simple_animal/hostile/morph/attack_slime(mob/living/simple_animal/slime/M)
	restore_form()

/mob/living/simple_animal/hostile/morph/proc/ambush_attack(mob/living/dumbass, touched)
	ambush_prepared = FALSE
	var/total_weaken = ambush_weaken
	var/total_damage = ambush_damage

	if(touched) // Touching a morph while he's ready to kill you is a bad idea
		total_weaken *= 2
		total_damage *= 2

	dumbass.Weaken(total_weaken)
	dumbass.apply_damage(total_damage, BRUTE)
	add_attack_logs(src, dumbass, "morph ambush attacked")
	do_attack_animation(dumbass, ATTACK_EFFECT_BITE)
	visible_message(span_danger("[src] suddenly leaps towards [dumbass]!"), span_warning("You strike [dumbass] when [dumbass.p_they()] least expected it!"), "You hear a horrible crunch!")

	restore_form()

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/morph/proc/allowed(atom/movable/item)
	var/list/not_allowed = list(/atom/movable/screen, /obj/singularity, /mob/living/simple_animal/hostile/morph)
	return !is_type_in_list(item, not_allowed)

/mob/living/simple_animal/hostile/morph/AIShouldSleep(list/possible_targets)
	. = ..()

	if(!. || morphed)
		return

	var/list/things = list()
	for(var/atom/movable/item_in_view in view(src))
		if(isobj(item_in_view) && allowed(item_in_view))
			LAZYADD(things, item_in_view)

	var/atom/movable/picked_thing = pick(things)
	
	if(picked_thing)
		antag_datum.mimic_spell.take_form(new /datum/mimic_form(picked_thing, src), src)
		prepare_ambush() // They cheat okay

/mob/living/simple_animal/hostile/morph/AttackingTarget()
	if(isliving(target)) // Eat Corpses to regen health
		var/mob/living/living = target
		if(living.stat == DEAD)
			try_eat(living)
			return TRUE

		if(ambush_prepared)
			ambush_attack(living)
			return TRUE // No double attack

	else if(isitem(target)) // Eat items just to be annoying
		var/obj/item/item = target
		if(!item.anchored)
			try_eat(item)
			return TRUE

	. = ..()
	if(. && morphed)
		restore_form()

/mob/living/simple_animal/hostile/morph/proc/make_morph_antag(grant_objectives = TRUE)
	if(!mind)
		return // It can be called by gluttony blessing on mindless mob.
		
	antag_datum.give_objectives = grant_objectives
	mind.add_antag_datum(antag_datum)

/mob/living/simple_animal/hostile/morph/sentience_act()
	..()
	make_morph_antag(FALSE)

/mob/living/simple_animal/hostile/morph/get_examine_time()
	return morphed ? antag_datum.mimic_spell.selected_form.examine_time : ..()

/mob/living/simple_animal/hostile/morph/get_visible_gender()
	return morphed ? antag_datum.mimic_spell.selected_form.examine_gender : ..()

/mob/living/simple_animal/hostile/morph/get_visible_species()
	return morphed ? antag_datum.mimic_spell.selected_form.examine_species : ..()

#undef MORPHED_SPEED
#undef ITEM_EAT_COST
#undef MORPHS_ANNOUNCE_THRESHOLD
