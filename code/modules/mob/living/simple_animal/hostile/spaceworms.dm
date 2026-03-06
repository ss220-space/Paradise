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
	var/turf/location = get_turf(src)
	for(var/atom/movable/stomach_content in contents)
		stomach_content.forceMove(location)
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

/mob/living/simple_animal/hostile/space_worm/worm_head/Initialize(mapload, segments = spawnWithSegments)
	. = ..()

	my_head = src //It's it's own head.

	//Used in the for to attach each worm segment to the next in the sequence, instead of all of them to src
	var/mob/living/simple_animal/hostile/space_worm/current_worm_seg = src

	for(var/i = 1 to segments)
		var/mob/living/simple_animal/hostile/space_worm/new_segment = new /mob/living/simple_animal/hostile/space_worm(loc)
		current_worm_seg.attach(new_segment)
		current_worm_seg = new_segment

	for(var/mob/living/simple_animal/hostile/space_worm/space_worm in total_worm_segments)
		space_worm.update_icon(UPDATE_ICON_STATE)

/mob/living/simple_animal/hostile/space_worm/worm_head/Destroy()
	LAZYCLEARLIST(total_worm_segments)
	return ..()

/mob/living/simple_animal/hostile/space_worm/worm_head/update_icon_state()
	if(stat == CONSCIOUS || stat == UNCONSCIOUS)
		icon_state = "spacewormhead[previous_worm ? "1" : "0"]"
		if(previous_worm)
			dir = get_dir(previous_worm, src)
	else
		icon_state = "spacewormheaddead"

	for(var/mob/living/simple_animal/hostile/space_worm/space_worm in total_worm_segments)
		if(space_worm  == src || QDELETED(space_worm ))//incase src ends up in here we don't want an infinite loop
			continue
		space_worm .update_icon(UPDATE_ICON_STATE)

//Try to move onto target's turf and eat them
/mob/living/simple_animal/hostile/space_worm/worm_head/AttackingTarget()
	. = ..()
	if(.)
		attemptToEat(target)

//Attempt to eat things we bump into, Mobs, Walls, Clowns
/mob/living/simple_animal/hostile/space_worm/worm_head/Bump(atom/bumped_atom)
	. = ..()
	attemptToEat(bumped_atom)

//Attempt to eat things, only the head can eat
/mob/living/simple_animal/hostile/space_worm/worm_head/proc/attemptToEat(atom/noms)
	if(QDELETED(noms) || QDELETED(src))
		return

	if(currently_eating == noms) //currently_eating is always undefined at the end, so don't eat the same thing twice
		return

	if(istype(noms, /obj/structure/window))
		return

	if(istype(noms, /obj/structure/grille)) //these three bug-out and won't work, so just ignore them
		return

	if(istype(noms, /obj/machinery/door/window))
		return

	if(!noms)
		return

	currently_eating = noms

	var/nomDelay = 2.5 SECONDS
	var/turf/simulated/wall/wall

	if(noms in total_worm_segments || QDELETED(noms))
		return //Trying to eat part of self.

	if(isturf(noms))
		if(!iswallturf(noms))
			return
		wall = noms
		nomDelay *= 2
		if(isreinforcedwallturf(wall))
			nomDelay *= 2

	var/ufnomDelay = nomDelay * 0.1

	visible_message(span_userdanger("\the [src] starts to eat \the [noms]!"),span_notice("You start to eat \the [noms]. (This will take about [ufnomDelay] seconds.)"),span_userdanger("You hear gnashing.")) //inform everyone what the fucking worm is doing.

	if(do_after(src, nomDelay, noms, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))

		if(noms && !QDELETED(noms) && Adjacent(noms) && (currently_eating == noms))//It exists, were next to it, and it's still the thing were eating
			if(wall)
				wall.ChangeTurf(/turf/simulated/floor/plating)
				new /obj/item/stack/sheet/metal(src, plasma_poop_potential)
				currently_eating = null //ffs, unstore this
				visible_message(span_userdanger("\the [src] eats \the [noms]!"),span_notice("You eat \the [noms]!"),span_userdanger("You hear gnashing.")) //inform everyone what the fucking worm is doing.
			else
				currently_eating = null
				if(ismob(noms))
					var/mob/mob = noms
					mob.forceMove(src)
				else
					var/atom/movable/movable_noms = noms.astype(/atom/movable)
					movable_noms?.forceMove(src)
				visible_message(span_userdanger("\the [src] eats \the [noms]!"),span_notice("You eat \the [noms]!"),span_userdanger("You hear gnashing."))
		else
			currently_eating = null
	else
		currently_eating = null //JIC

//Harder to kill the head, but it can kill off the whole worm
/mob/living/simple_animal/hostile/space_worm/worm_head/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	if(prob(catastrophic_death_prob))
		for(var/mob/living/simple_animal/hostile/space_worm/SW in total_worm_segments)
			if(!QDELETED(SW))
				SW.death()

/mob/living/simple_animal/hostile/space_worm/Life(seconds, times_fired)
	// УЛУЧШЕНИЕ: Проверка на QDELETED в начале Life
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
/mob/living/simple_animal/hostile/space_worm/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(QDELETED(src))
		return FALSE

	var/segment_next_pos = loc
	. = ..()
	if(!.)
		return

	if(previous_worm && !QDELETED(previous_worm))
		previous_worm.Move(segment_next_pos)
	update_icon(UPDATE_ICON_STATE)

//Update the appearence of this big weird chain-worm-thingy
/mob/living/simple_animal/hostile/space_worm/update_icon_state()
	if(QDELETED(src))
		return

	if(stat == DEAD)
		icon_state = "spacewormdead"
		return

	if(previous_worm && !QDELETED(previous_worm))
		icon_state = "spaceworm[get_dir(src, previous_worm) | get_dir(src, next_worm)]"
		return

	icon_state = "spacewormtail" //end of rine
	if(next_worm && !QDELETED(next_worm))
		dir = get_dir(src, next_worm)

//Add a new worm segment
/mob/living/simple_animal/hostile/space_worm/proc/attach(mob/living/simple_animal/hostile/space_worm/to_attach)
	if(!to_attach || QDELETED(to_attach) || QDELETED(src))
		return

	previous_worm = to_attach
	to_attach.next_worm = src

	if(my_head)
		if(to_attach.my_head)
			to_attach.my_head.total_worm_segments -= src

		to_attach.my_head = my_head
		my_head.total_worm_segments |= to_attach

		//if to_attach is part of another worm, disconnect all those parts and connect them to the new worm.
		var/mob/living/simple_animal/hostile/space_worm/is_prev_worm
		if(to_attach.previous_worm)
			is_prev_worm = to_attach.previous_worm

		while(is_prev_worm)
			if(QDELETED(is_prev_worm))
				is_prev_worm = null
				continue

			if(is_prev_worm.previous_worm && !QDELETED(is_prev_worm.previous_worm))
				if(is_prev_worm.my_head)
					is_prev_worm.my_head.total_worm_segments -= is_prev_worm.previous_worm
					to_attach.my_head.total_worm_segments |= is_prev_worm.previous_worm
				is_prev_worm = is_prev_worm.previous_worm
			else
				is_prev_worm = null

	update_icons()

//Remove a worm segment
/mob/living/simple_animal/hostile/space_worm/proc/detach(die = FALSE)
	if(QDELETED(src))
		return

	var/mob/living/simple_animal/hostile/space_worm/worm_head/newHead = new /mob/living/simple_animal/hostile/space_worm/worm_head(loc,0)
	var/mob/living/simple_animal/hostile/space_worm/newHeadPrev

	if(previous_worm)
		newHeadPrev = previous_worm
		previous_worm = null

	if(newHeadPrev && !QDELETED(newHeadPrev))
		newHead.attach(newHeadPrev)

	if(my_head)
		my_head.total_worm_segments -= src

	if(die)
		newHead.death()

	qdel(src)

/mob/living/simple_animal/hostile/space_worm/death(gibbed)
	// Only execute the below if we successfully died
	. = ..()
	if(!.)
		return FALSE
	if(my_head)
		my_head.total_worm_segments -= src

//Process nom noms, things we've eaten have a chance to become plasma
/mob/living/simple_animal/hostile/space_worm/proc/process_stomach()
	if(QDELETED(src))
		return

	for(var/atom/movable/stomach_content in contents)
		if(prob(digestion_probability))
			new /obj/item/stack/sheet/mineral/plasma(src, plasma_poop_potential)
			if(ismob(stomach_content))
				var/mob/mob = stomach_content
				mob.ghostize() //because qdelling an entire mob without ghosting it is BAD
			qdel(stomach_content)

	if(previous_worm && !QDELETED(previous_worm))
		for(var/atom/movable/stomach_content in contents) //move it along the digestive tract
			contents -= stomach_content
			previous_worm.contents += stomach_content
			if(ismob(stomach_content))
				stomach_content.forceMove(previous_worm) //weird shit happens otherwise
		return

	var/turf/location = get_turf(src)
	if(location || QDELETED(location))
		return

	for(var/atom/movable/stomach_content in contents)
		contents -= stomach_content
		stomach_content.forceMove(location)

//Jiggle the whole worm forwards towards the next segment
/mob/living/simple_animal/hostile/space_worm/do_attack_animation(atom/A, visual_effect_icon, used_item, no_effect)
	..()
	if(previous_worm && !QDELETED(previous_worm))
		previous_worm.do_attack_animation(src)
