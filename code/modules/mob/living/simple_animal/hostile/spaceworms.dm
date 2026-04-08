#define MAX_WORM_LENGTH 15

//Worm Segments, Dummy, has no AI, relies on the head.
/mob/living/simple_animal/hostile/space_worm
	name = "space worm segment"
	desc = "A part of a space worm."
	icon_state = "spaceworm"
	icon_living = "spaceworm"
	icon_dead = "spacewormdead"
	status_flags = 0

	speak_emote = list("визжит")
	emote_hear = list("визжит")

	response_help  = "touches"
	response_disarm = "flails at"
	response_harm   = "punches"

	harm_intent_damage = 2

	maxHealth = 50
	health = 50

	stop_automated_movement = 1
	animate_movement = SYNC_STEPS

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	speed = -1

	AIStatus = AI_OFF

	anchored = TRUE //otherwise people can literally fucking pull space worms apart

	faction = list("spaceworms")

	var/mob/living/simple_animal/hostile/space_worm/previous_worm //next/previous segments, correspondingly
	var/mob/living/simple_animal/hostile/space_worm/next_worm     //head is the nextest segment

	var/mob/living/simple_animal/hostile/space_worm/worm_head/my_head		//Can be the same as next, just a general reference to the main worm.

	var/stomach_process_probability = 50
	var/digestion_probability = 20

	/// What the worm is currently eating
	var/atom/currently_eating
	var/plasma_poop_potential = 5

/mob/living/simple_animal/hostile/space_worm/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, INNATE_TRAIT)

/mob/living/simple_animal/hostile/space_worm/Destroy()
	if(previous_worm)
		previous_worm.next_worm = null
		previous_worm = null

	if(next_worm)
		next_worm.previous_worm = null
		next_worm = null

	if(my_head)
		my_head.total_worm_segments -= src
		my_head = null

	currently_eating = null

	var/turf/current_turf = get_turf(src)
	for(var/atom/movable/stomach_content in contents)
		stomach_content.forceMove(current_turf)

	contents.Cut()
	return ..()

/mob/living/simple_animal/hostile/space_worm/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		maxbodytemp = 350, \
		minbodytemp = 0, \
	)

/mob/living/simple_animal/hostile/space_worm/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE //space worms can flyyyyyy

//Worm Head, Controls the AI for the entire worm "entity"
/mob/living/simple_animal/hostile/space_worm/worm_head
	name = "space worm head"
	icon_state = "spacewormhead"
	icon_living = "spacewormhead"

	//Stronger than normal segments
	maxHealth = 125
	health = 125

	melee_damage_lower = 10//was 20, dear god
	melee_damage_upper = 15//was 25, dear god
	obj_damage = 80
	attacktext = "кусает"
	attack_sound = 'sound/weapons/bite.ogg'

	animate_movement = SLIDE_STEPS

	AIStatus = AI_ON//The head is conscious
	stop_automated_movement = 0 //Ditto ^

	faction = list("spaceworms") //head and body both have this faction JIC

	//head specific variables
	var/spawn_with_segments = 6
	var/list/total_worm_segments = list() //doesn't contain src
	var/catastrophic_death_prob = 15 //15% chance for the death of the head to kill the whole thing

/mob/living/simple_animal/hostile/space_worm/worm_head/Initialize(mapload, segments = spawn_with_segments)
	. = ..()

	my_head = src //It's it's own head.

	//Used in the for to attach each worm segment to the next in the sequence, instead of all of them to src
	var/mob/living/simple_animal/hostile/space_worm/current_worm_segment = src

	for(var/i in 1 to segments)
		var/mob/living/simple_animal/hostile/space_worm/new_segment = new(loc)
		current_worm_segment.attach(new_segment)
		current_worm_segment = new_segment

	for(var/mob/living/simple_animal/hostile/space_worm/worm_segment in total_worm_segments)
		worm_segment.update_icon(UPDATE_ICON_STATE)

/mob/living/simple_animal/hostile/space_worm/worm_head/Destroy()
	LAZYCLEARLIST(total_worm_segments)
	return ..()

/mob/living/simple_animal/hostile/space_worm/worm_head/proc/check_fragments()
	var/list/parts_list = total_worm_segments
	for(var/mob/living/simple_animal/hostile/space_worm/part as anything in parts_list)
		if(part.my_head != src)
			parts_list -= part

/mob/living/simple_animal/hostile/space_worm/worm_head/Move(atom/newloc, direct, glide_size_override, update_dir)
	if(!QDELETED(previous_worm) && (direct == get_dir(src, previous_worm)))
		return
	. = ..()

/mob/living/simple_animal/hostile/space_worm/worm_head/update_icon_state()
	if(stat == CONSCIOUS || stat == UNCONSCIOUS)
		icon_state = "spacewormhead[previous_worm ? "1" : "0"]"
		if(previous_worm)
			dir = get_dir(previous_worm, src)
	else
		icon_state = "spacewormheaddead"

	for(var/mob/living/simple_animal/hostile/space_worm/worm_segment in total_worm_segments)
		if(worm_segment == src || QDELETED(worm_segment))//incase src ends up in here we don't want an infinite loop
			continue
		worm_segment.update_icon(UPDATE_ICON_STATE)

//Try to move onto target's turf and eat them
/mob/living/simple_animal/hostile/space_worm/worm_head/AttackingTarget()
	. = ..()
	if(!.)
		attempt_to_eat(target)

//Attempt to eat things we bump into, Mobs, Walls, Clowns
/mob/living/simple_animal/hostile/space_worm/worm_head/Bump(atom/bumped_atom)
	. = ..()
	if(!.)
		attempt_to_eat(bumped_atom)

//Attempt to eat things, only the head can eat
/mob/living/simple_animal/hostile/space_worm/worm_head/proc/attempt_to_eat(atom/target_nom)
	if(QDELETED(target_nom) || QDELETED(src))
		return

	if(currently_eating == target_nom) //currently_eating is always undefined at the end, so don't eat the same thing twice
		return

	if(is_window(target_nom))
		return

	if(istype(target_nom, /obj/structure/grille)) //these three bug-out and won't work, so just ignore them
		return

	if(istype(target_nom, /obj/machinery/door/window))
		return

	if(target_nom in total_worm_segments) //Trying to eat part of self
		return

	currently_eating = target_nom

	var/nom_delay = 2.5 SECONDS
	var/turf/simulated/wall/target_wall

	if(isturf(target_nom))
		if(!iswallturf(target_nom))
			currently_eating = null
			return
		target_wall = target_nom
		nom_delay *= 2
		if(isreinforcedwallturf(target_wall))
			nom_delay *= 2

	var/readable_nom_delay = nom_delay * 0.1

	visible_message(
		span_userdanger("\the [src] starts to eat \the [target_nom]!"),
		span_notice("You start to eat \the [target_nom]. (This will take about [readable_nom_delay] seconds.)"),
		span_userdanger("You hear gnashing.")
	)

	if(!do_after(src, nom_delay, target_nom, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
		currently_eating = null
		return

	// Check if target still exists and is valid
	if(QDELETED(target_nom) || !Adjacent(target_nom) || (currently_eating != target_nom))
		currently_eating = null
		return

	if(target_wall)
		target_wall.ChangeTurf(/turf/simulated/floor/plating)
		new /obj/item/stack/sheet/metal(src, plasma_poop_potential)
		visible_message(
			span_userdanger("\the [src] eats \the [target_nom]!"),
			span_notice("You eat \the [target_nom]!"),
			span_userdanger("You hear gnashing.")
		)
		currently_eating = null
		return

	if(ismob(target_nom))
		var/mob/target_mob = target_nom
		target_mob.forceMove(src)
		visible_message(
			span_userdanger("\the [src] eats \the [target_nom]!"),
			span_notice("You eat \the [target_nom]!"),
			span_userdanger("You hear gnashing.")
		)
		currently_eating = null
		return

	if(isatom(target_nom))
		var/atom/movable/movable_target = target_nom
		movable_target?.forceMove(src)
		visible_message(
			span_userdanger("\the [src] eats \the [target_nom]!"),
			span_notice("You eat \the [target_nom]!"),
			span_userdanger("You hear gnashing.")
		)

	currently_eating = null

//Harder to kill the head, but it can kill off the whole worm
/mob/living/simple_animal/hostile/space_worm/worm_head/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE

	if(!prob(catastrophic_death_prob))
		return

	for(var/mob/living/simple_animal/hostile/space_worm/worm_segment in total_worm_segments)
		if(!QDELETED(worm_segment))
			worm_segment.death()

/mob/living/simple_animal/hostile/space_worm/Life(seconds, times_fired)
	if(QDELETED(src))
		return

	if(next_worm && !(Adjacent(next_worm)))
		detach(FALSE)

	if(stat == DEAD)
		if(previous_worm)
			previous_worm.detach(FALSE)
		if(next_worm)
			detach(TRUE)

	if(prob(stomach_process_probability))
		process_stomach()

	update_icon(UPDATE_ICON_STATE)//While most mobs don't call this on Life(), the worm would probably look stupid without it
	//Plus the worm's update_icon() isn't as beefy.

	..() //Really high fuckin priority that this is at the bottom.

//Move all segments if one piece moves.
/mob/living/simple_animal/hostile/space_worm/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	if(QDELETED(src))
		return FALSE
	. = ..()
	if(!.)
		return

	if(previous_worm && !QDELETED(previous_worm))
		previous_worm.Move(old_loc)

	update_icon(UPDATE_ICON_STATE)

//Update the appearence of this big weird chain-worm-thingy
/mob/living/simple_animal/hostile/space_worm/update_icon_state()
	if(QDELETED(src))
		return

	if(stat == DEAD)
		icon_state = "spacewormdead"
		return

	if(!QDELETED(previous_worm) && !QDELETED(next_worm))
		icon_state = "spaceworm[get_dir(src, previous_worm) | get_dir(src, next_worm)]"
		return

	icon_state = "spacewormtail" //end of rine
	if(!QDELETED(next_worm))
		dir = get_dir(src, next_worm)

//Add a new worm segment
/mob/living/simple_animal/hostile/space_worm/proc/attach(mob/living/simple_animal/hostile/space_worm/segment_to_attach)
	if(!segment_to_attach || QDELETED(segment_to_attach) || QDELETED(src))
		return

	previous_worm = segment_to_attach
	segment_to_attach.next_worm = src

	if(!my_head)
		update_icons(UPDATE_ICON_STATE)
		return

	if(segment_to_attach.my_head)
		segment_to_attach.my_head.total_worm_segments -= src

	segment_to_attach.my_head = my_head
	my_head.total_worm_segments |= segment_to_attach

	//if segment_to_attach is part of another worm, disconnect all those parts and connect them to the new worm.
	var/mob/living/simple_animal/hostile/space_worm/current_previous_worm = segment_to_attach.previous_worm

	while(current_previous_worm)
		if(QDELETED(current_previous_worm))
			current_previous_worm = null
			continue

		if(current_previous_worm.previous_worm && !QDELETED(current_previous_worm.previous_worm))
			if(current_previous_worm.my_head)
				current_previous_worm.my_head.total_worm_segments -= current_previous_worm.previous_worm
				segment_to_attach.my_head.total_worm_segments |= current_previous_worm.previous_worm
			current_previous_worm = current_previous_worm.previous_worm
		else
			current_previous_worm = null

	my_head.check_fragments()

	update_icons(UPDATE_ICON_STATE)

//Remove a worm segment
/mob/living/simple_animal/hostile/space_worm/proc/detach(die = FALSE)
	if(QDELETED(src))
		return

	var/mob/living/simple_animal/hostile/space_worm/worm_head/new_head = new (loc, 0)
	var/mob/living/simple_animal/hostile/space_worm/new_head_previous_segment

	if(previous_worm)
		new_head_previous_segment = previous_worm
		previous_worm = null

	if(new_head_previous_segment && !QDELETED(new_head_previous_segment))
		new_head.attach(new_head_previous_segment)

	if(my_head)
		my_head.total_worm_segments -= src

	if(die)
		new_head.death()

	qdel(src)
	my_head.check_fragments()
	new_head.check_fragments()

/mob/living/simple_animal/hostile/space_worm/death(gibbed)
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE

	qdel(src)

	if(my_head)
		my_head.total_worm_segments -= src

//Process nom noms, things we've eaten have a chance to become plasma
/mob/living/simple_animal/hostile/space_worm/proc/process_stomach()
	if(QDELETED(src))
		return

	var/mob/living/simple_animal/hostile/space_worm/worm_head/cached_head = my_head

	for(var/atom/movable/stomach_content in contents)
		if(!prob(digestion_probability))
			if(isliving(stomach_content))
				var/mob/living/target_mob = stomach_content
				target_mob.adjustBruteLoss(/mob/living/simple_animal/hostile/space_worm/worm_head::melee_damage_upper)
			continue
		new /obj/item/stack/sheet/mineral/plasma(src, plasma_poop_potential)
		if(ismob(stomach_content))
			var/mob/target_mob = stomach_content
			target_mob.ghostize() //because qdelling an entire mob without ghosting it is BAD
			if(length(cached_head.total_worm_segments) <= MAX_WORM_LENGTH)
				var/mob/living/simple_animal/hostile/space_worm/new_worm = new(get_turf(cached_head))
				var/mob/living/simple_animal/hostile/space_worm/old_worm = cached_head.previous_worm
				cached_head.attach(new_worm)
				if(old_worm)
					new_worm.attach(old_worm)
		qdel(stomach_content)

	if(!previous_worm || QDELETED(previous_worm))
		var/turf/current_turf = get_turf(src)
		if(current_turf && !QDELETED(current_turf))
			for(var/atom/movable/stomach_content in contents)
				contents -= stomach_content
				stomach_content.forceMove(current_turf)
		return

	// Move contents to previous worm segment
	for(var/atom/movable/stomach_content in contents)
		contents -= stomach_content
		previous_worm.contents += stomach_content
		if(ismob(stomach_content))
			stomach_content.forceMove(previous_worm) //weird shit happens otherwise

//Jiggle the whole worm forwards towards the next segment
/mob/living/simple_animal/hostile/space_worm/do_attack_animation(atom/target_atom, visual_effect_icon, used_item, no_effect)
	..()
	if(previous_worm && !QDELETED(previous_worm))
		previous_worm.do_attack_animation(src)

#undef MAX_WORM_LENGTH
