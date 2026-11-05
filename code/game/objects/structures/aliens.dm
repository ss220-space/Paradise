/* Alien shit!
 * Contains:
 *		structure/alien
 *		Resin
 *		Weeds
 *		Egg
 */

#define ALIEN_RESIN_BURN_MOD 2
#define ALIEN_RESIN_BRUTE_MOD 0.25

#define RESIN_CORNER_COUNTERCLOCKWISE 1
#define RESIN_CORNER_DIAGONAL 2
#define RESIN_CORNER_CLOCKWISE 4

/obj/structure/alien
	icon = 'icons/mob/alien.dmi'
	max_integrity = 100
	cares_about_temperature = TRUE

/obj/structure/alien/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	if(damage_flag == MELEE)
		switch(damage_type)
			if(BRUTE)
				damage_amount *= ALIEN_RESIN_BRUTE_MOD
			if(BURN)
				damage_amount *= ALIEN_RESIN_BURN_MOD
	. = ..()

/obj/structure/alien/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			if(damage_amount)
				playsound(loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/alien/has_prints()
	return FALSE

/*
 * Resin
 */
/obj/structure/alien/resin
	name = "resin"
	desc = "Похоже на какую-то густую смолу."
	icon = 'icons/mob/xeno/structures.dmi'
	icon_state = "resin"
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	max_integrity = 200
	var/walltype = "resin"
	var/list/wall_connections = list("0", "0", "0", "0")
	var/special_icon = FALSE

/obj/structure/alien/resin/add_debris_element()
	generate_debris_handler(null, -40, 8, 0.7)

/obj/structure/alien/resin/Initialize(mapload)
	recalculate_atmos_connectivity()
	. = ..()
	update_neighbours()

/obj/structure/alien/resin/Destroy()
	var/turf/T = get_turf(src)
	playdestroysound(T)
	. = ..()
	T.recalculate_atmos_connectivity()
	update_neighbours(T)

/obj/structure/alien/resin/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/turf/T = loc
	. = ..()
	move_update_air(T)

/obj/structure/alien/resin/CanAtmosPass(direction)
	return !density

/obj/structure/alien/resin/proc/playdestroysound(source)
	playsound(source, 'sound/creatures/alien/xeno_resin_break.ogg', 80, TRUE)

/**
 * Recomputes corner smoothing for every resin structure in a 1 tile radius around [centre],
 * this structure included. Used on spawn and after a structure is destroyed.
 */
/obj/structure/alien/resin/proc/update_neighbours(turf/centre)
	if(!centre)
		centre = get_turf(src)
	if(!centre)
		return
	for(var/obj/structure/alien/resin/neighbour in range(1, centre))
		neighbour.update_connections()
		neighbour.update_icon()

/**
 * Recalculates [wall_connections] from the adjacent resin structures
 */
/obj/structure/alien/resin/proc/update_connections()
	var/list/smoothing_dirs = list()
	for(var/direction in GLOB.alldirs)
		var/turf/neighbour_turf = get_step(src, direction)
		if(!neighbour_turf)
			continue
		var/obj/structure/alien/resin/neighbour = locate(/obj/structure/alien/resin) in neighbour_turf
		if(!neighbour)
			continue
		if(istype(neighbour, /obj/structure/alien/resin/door) && !(direction in GLOB.cardinal))
			continue
		smoothing_dirs += direction
	wall_connections = corner_states(smoothing_dirs)

/obj/structure/alien/resin/update_icon_state()
	. = ..()
	if(special_icon)
		return
	icon_state = null

/obj/structure/alien/resin/update_overlays()
	. = ..()
	if(special_icon)
		return
	for(var/i in 1 to 4)
		. += image(icon = icon, icon_state = "[walltype][wall_connections[i]]", dir = 1 << (i - 1))

/**
 * Converts a list of directions into the four per-corner states (NW, SE, NE, SW),
 * each a "0".."7" string, used by the CM-SS13 wall corner sprites.
 */
/proc/corner_states(list/dirs)
	if(!islist(dirs))
		return
	var/list/ret = list(NORTHWEST, SOUTHEAST, NORTHEAST, SOUTHWEST)
	for(var/i in 1 to length(ret))
		var/corner_dir = ret[i]
		var/state = 0
		if(corner_dir in dirs)
			state |= RESIN_CORNER_DIAGONAL
		if(turn(corner_dir, 45) in dirs)
			state |= RESIN_CORNER_COUNTERCLOCKWISE
		if(turn(corner_dir, -45) in dirs)
			state |= RESIN_CORNER_CLOCKWISE
		ret[i] = "[state]"
	return ret

/obj/structure/alien/resin/wall
	name = "resin wall"
	desc = "Выпуклая стена чёрной смолы. Под блестящей поверхностью словно пульсируют тонкие жилки."

/obj/structure/alien/resin/wall/get_ru_names()
	return alist(
		NOMINATIVE = "смоляная стена",
		GENITIVE = "смоляной стены",
		DATIVE = "смоляной стене",
		ACCUSATIVE = "смоляную стену",
		INSTRUMENTAL = "смоляной стеной",
		PREPOSITIONAL = "смоляной стене",
	)

/obj/structure/alien/resin/wall/get_superconductivity(direction)
	return FALSE

/obj/structure/alien/resin/wall/shadowling //For chrysalis
	name = "chrysalis wall"
	desc = "Некая субстанция фиолетового цвета, по форме напоминающая яйцо. Она пульсирует и бьется изнутри и кажется непроницаемой.."
	max_integrity = INFINITY

/obj/structure/alien/resin/wall/shadowling/get_ru_names()
	return alist(
		NOMINATIVE = "стена-кокон",
		GENITIVE = "стены-кокона",
		DATIVE = "стене-кокону",
		ACCUSATIVE = "стену-кокон",
		INSTRUMENTAL = "стеной-коконом",
		PREPOSITIONAL = "стене-коконе",
	)

/obj/structure/alien/resin/wall/shadowling/playdestroysound(source)
	playsound(source, 'sound/effects/splat.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

/obj/structure/alien/resin/wall/thick
	name = "thick resin wall"
	walltype = "thickresin"
	max_integrity = 350

/obj/structure/alien/resin/wall/get_ru_names()
	return alist(
		NOMINATIVE = "толстая смоляная стена",
		GENITIVE = "толстой смоляной стены",
		DATIVE = "толстой смоляной стене",
		ACCUSATIVE = "толстую смоляную стену",
		INSTRUMENTAL = "толстой смоляной стеной",
		PREPOSITIONAL = "толстой смоляной стене",
	)

/obj/structure/alien/resin/attack_alien(mob/living/carbon/alien/humanoid/A)
	if(A.a_intent == INTENT_HARM)
		var/damage = 0
		switch(A.caste)
			if("d") //drone breaks wall in 2 hits
				damage = max_integrity/2/ALIEN_RESIN_BRUTE_MOD
			if("q") //queen breaks wall in 1 hit
				damage = max_integrity/ALIEN_RESIN_BRUTE_MOD
			else
				return ..()
		if(attack_generic(A, damage, BRUTE, MELEE, 0, 100))
			playsound(loc, 'sound/effects/attackblob.ogg', 50, TRUE)

#define RESIN_DOOR_CLOSED 0
#define RESIN_DOOR_OPENED 1

/obj/structure/alien/resin/door
	name = "resin door"
	desc = "Перекошенная дверь из затвердевшей чёрной смолы, с тонкими жилками, пульсирующими под блестящей поверхностью."
	icon_state = "resindoor"
	var/icon_closed = "resindoor"
	var/icon_opened = "resindooropen"
	var/icon_closing = "resindoorclosing"
	var/icon_opening = "resindooropening"
	max_integrity = 160
	special_icon = TRUE
	pass_flags_self = PASSDOOR
	var/open_sound = 'sound/creatures/alien/xeno_door_open.ogg'
	var/close_sound = 'sound/creatures/alien/xeno_door_close.ogg'
	var/state = RESIN_DOOR_CLOSED
	var/operating = FALSE
	var/autoclose = TRUE
	var/autoclose_delay = 10 SECONDS

/obj/structure/alien/resin/door/update_connections()
	. = ..()
	var/door_mask = 0
	for(var/direction in GLOB.cardinal)
		if(locate(/obj/structure/alien/resin/door) in get_step(src, direction))
			door_mask |= direction
	if(door_mask & (NORTH|SOUTH))
		setDir(WEST)
	else if(door_mask & (EAST|WEST))
		setDir(NORTH)

/obj/structure/alien/resin/door/Initialize(mapload)
	. = ..()
	update_freelook_sight()
	update_connections()
	update_icon()

/obj/structure/alien/resin/door/Destroy()
	set_density(FALSE)
	update_freelook_sight()
	recalculate_atmos_connectivity()
	return ..()

/obj/structure/alien/resin/door/update_icon_state()
	switch(state)
		if(RESIN_DOOR_CLOSED)
			icon_state = icon_closed
		if(RESIN_DOOR_OPENED)
			icon_state = icon_opened

/obj/structure/alien/resin/door/attack_alien(mob/living/carbon/alien/humanoid/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	return try_switch_state(user)

/obj/structure/alien/resin/door/attack_animal(mob/living/simple_animal/M)
	if(M.a_intent == INTENT_HARM)
		return ..()

	return try_switch_state(M)

/obj/structure/alien/resin/door/attack_hand(mob/living/user)
	..()
	attack_check(user)

/obj/structure/alien/resin/door/proc/attack_check(mob/living/user)
	if(!isalien(user))
		to_chat(user, span_notice("Не удаётся найти способ манипулировать этой дверью."))
		return FALSE
	return TRUE

/obj/structure/alien/resin/door/attack_ghost(mob/user)
	if(user.can_advanced_admin_interact())
		switch_state()

/obj/structure/alien/resin/door/attack_tk(mob/user)
	return

/obj/structure/alien/resin/door/Bumped(atom/movable/moving_atom)
	. = ..()

	if(operating)
		return .

	if(isliving(moving_atom))
		var/mob/living/living = moving_atom
		if(world.time - living.last_bumped <= 1 SECONDS)
			return
		living.last_bumped = world.time

	try_switch_state(moving_atom)

/obj/structure/alien/resin/door/proc/try_switch_state(atom/movable/user)
	if(operating)
		return FALSE

	add_fingerprint(user)
	if(!isliving(user))
		return FALSE
	var/mob/living/mob = user
	if(!isalien(user) && !("alien" in mob.faction))
		return FALSE

	var/mob/living/carbon/alien/alien = user
	if(alien.incapacitated())
		return FALSE

	switch_state()
	return TRUE

/obj/structure/alien/resin/door/proc/switch_state()
	switch(state)
		if(RESIN_DOOR_CLOSED)
			open()
		if(RESIN_DOOR_OPENED)
			close()

/obj/structure/alien/resin/door/proc/open()

	if(operating || !density)
		return

	if(autoclose)
		autoclose_in(autoclose_delay)

	flick(icon_opening, src)
	playsound(loc, open_sound, 100, TRUE)
	operating = TRUE

	sleep(0.1 SECONDS)
	set_opacity(FALSE)
	update_freelook_sight()

	sleep(0.4 SECONDS)
	set_density(FALSE)
	recalculate_atmos_connectivity()

	sleep(0.1 SECONDS)
	operating = FALSE
	state = RESIN_DOOR_OPENED
	update_icon()

/obj/structure/alien/resin/door/proc/close()

	if(operating || density)
		return

	var/turf/source_turf = get_turf(src)
	for(var/atom/movable/moving_atom in source_turf)
		if(moving_atom.density && moving_atom != src)
			if(autoclose)
				autoclose_in(autoclose_delay * 0.5)
			return

	flick(icon_closing, src)
	playsound(loc, close_sound, 100, TRUE)
	operating = TRUE

	sleep(0.1 SECONDS)
	set_density(TRUE)
	recalculate_atmos_connectivity()

	sleep(0.4 SECONDS)
	set_opacity(TRUE)
	update_freelook_sight()

	sleep(0.1 SECONDS)
	operating = FALSE
	state = RESIN_DOOR_CLOSED
	update_icon()
	check_mobs()

/obj/structure/alien/resin/door/proc/check_mobs()
	if(locate(/mob/living) in get_turf(src))
		sleep(0.1 SECONDS)
		open()

/obj/structure/alien/resin/door/proc/autoclose()
	if(!QDELETED(src) && !density && !operating && autoclose)
		close()

/obj/structure/alien/resin/door/proc/autoclose_in(wait)
	addtimer(CALLBACK(src, PROC_REF(autoclose)), wait, TIMER_UNIQUE | TIMER_NO_HASH_WAIT | TIMER_OVERRIDE)

/obj/structure/alien/resin/door/proc/update_freelook_sight()
	if(GLOB.cameranet)
		GLOB.cameranet.updateVisibility(src, opacity_check = FALSE)

#undef RESIN_DOOR_CLOSED
#undef RESIN_DOOR_OPENED

/obj/structure/alien/resin/door/thick
	name = "thick resin door"
	icon_state = "thickresindoor"
	icon_closed = "thickresindoor"
	icon_opened = "thickresindooropen"
	icon_closing = "thickresindoorclosing"
	icon_opening = "thickresindooropening"
	max_integrity = 300

/*
 * Weeds
 */

#define NODERANGE 3

/obj/structure/alien/weeds
	gender = PLURAL
	name = "resin floor"
	desc = "Толстая смоляная поверхность, покрывающая пол."
	anchored = TRUE
	layer = ABOVE_ICYOVERLAY_LAYER
	plane = FLOOR_PLANE
	icon = 'icons/mob/xeno/weeds.dmi'
	icon_state = "base"
	max_integrity = 15
	var/obj/structure/alien/weeds/node/linked_node = null
	var/static/list/forbidden_turf_types
	creates_cover = TRUE

/obj/structure/alien/weeds/get_ru_names()
	return alist(
		NOMINATIVE = "смоляной пол",
		GENITIVE = "смоляного пола",
		DATIVE = "смоляному полу",
		ACCUSATIVE = "смоляной пол",
		INSTRUMENTAL = "смоляным полом",
		PREPOSITIONAL = "смоляном полу",
	)

/obj/structure/alien/weeds/Initialize(mapload, node)
	. = ..()
	linked_node = node
	if(!forbidden_turf_types)
		forbidden_turf_types = typecacheof(list(/turf/space, /turf/simulated/floor/chasm, /turf/simulated/floor/lava))

	if(is_type_in_typecache(loc, forbidden_turf_types))
		qdel(src)
		return

	update_neighbours()

	addtimer(CALLBACK(src, PROC_REF(Life)), rand(15 SECONDS, 20 SECONDS))
	RegisterSignal(linked_node, COMSIG_QDELETING, PROC_REF(clear_linked_node))

/obj/structure/alien/weeds/Destroy()
	var/turf/old_loc = loc
	linked_node = null
	. = ..()
	for(var/obj/structure/alien/weeds/weed in range(1, old_loc))
		weed.update_icon()

/obj/structure/alien/weeds/proc/clear_linked_node()
	SIGNAL_HANDLER
	UnregisterSignal(linked_node, COMSIG_QDELETING)
	linked_node = null

/obj/structure/alien/weeds/proc/Life()
	var/turf/U = get_turf(src)

	if(is_type_in_typecache(U, forbidden_turf_types))
		qdel(src)
		return

	if(!linked_node || get_dist(linked_node, src) > linked_node.node_range)
		return

	for(var/turf/T in U.GetAtmosAdjacentTurfs())

		if(locate(/obj/structure/alien/weeds) in T || is_type_in_typecache(T, forbidden_turf_types))
			continue

		new /obj/structure/alien/weeds(T, linked_node)

/obj/structure/alien/weeds/temperature_expose(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 300)
		take_damage(5, BURN, 0, 0)

/obj/structure/alien/weeds/update_icon_state()
	. = ..()

	var/smoothing_mask = 0
	for(var/direction in GLOB.cardinal)
		var/turf/neighbour = get_step(src, direction)
		if(neighbour && locate(/obj/structure/alien) in neighbour)
			smoothing_mask |= direction

	if(smoothing_mask == 15)
		icon_state = "weed[rand(0, 15)]"
	else if(!smoothing_mask)
		icon_state = "base"
	else
		icon_state = "weed_dir[smoothing_mask]"

/obj/structure/alien/weeds/proc/update_neighbours()
	update_icon()
	for(var/obj/structure/alien/weeds/weed in range(1, src))
		weed.update_icon()

//Weed nodes
/obj/structure/alien/weeds/node
	name = "glowing resin"
	desc = "Толстая смоляная поверхность, покрывающая пол. Из-под поверхности струится синее биолюминесцентное свечение."
	light_range = 1
	layer = MID_TURF_LAYER
	var/node_range = NODERANGE

/obj/structure/alien/weeds/node/get_ru_names()
	return alist(
		NOMINATIVE = "мерцающая смола",
		GENITIVE = "мерцающей смолы",
		DATIVE = "мерцающей смоле",
		ACCUSATIVE = "мерцающую смолу",
		INSTRUMENTAL = "мерцающей смолой",
		PREPOSITIONAL = "мерцающей смоле",
	)

/obj/structure/alien/weeds/node/update_overlays()
	. = ..()
	. += mutable_appearance(icon, "node")

/obj/structure/alien/weeds/node/Initialize(mapload)
	return ..(loc, src)

/obj/structure/alien/weeds/attack_alien(mob/living/carbon/alien/humanoid/A)
	if(A.a_intent == INTENT_HARM)
		return ..()

#undef NODERANGE

/*
 * Egg
 */

//for the status var
#define BURST 0
#define BURSTING 1
#define GROWING 2
#define GROWN 3
#define MIN_GROWTH_TIME 1200	//time it takes to grow a hugger
#define MAX_GROWTH_TIME 1800
#define PROXIMITY_RADIUS 5

/obj/structure/alien/egg
	name = "egg"
	desc = "Большое пятнистое яйцо."
	icon = 'icons/mob/xeno/xenoegg.dmi'
	icon_state = "egg_growing"
	anchored = TRUE
	integrity_failure = 5
	var/status = GROWING	//can be GROWING, GROWN or BURST; all mutually exclusive
	layer = MOB_LAYER

/obj/structure/alien/egg/get_ru_names()
	return alist(
		NOMINATIVE = "яйцо",
		GENITIVE = "яйца",
		DATIVE = "яйцу",
		ACCUSATIVE = "яйцо",
		INSTRUMENTAL = "яйцом",
		PREPOSITIONAL = "яйце",
	)

/obj/structure/alien/egg/grown
	status = GROWN
	icon_state = "egg"

/obj/structure/alien/egg/burst
	status = BURST
	icon_state = "egg_opened"

/obj/structure/alien/egg/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)
	switch(status)
		if(GROWING)
			var/mob/living/simple_animal/hostile/facehugger/hugger = new(src)
			hugger.lose_target()
			addtimer(CALLBACK(src, PROC_REF(Grow)), rand(MIN_GROWTH_TIME, MAX_GROWTH_TIME))
		if(GROWN)
			var/mob/living/simple_animal/hostile/facehugger/hugger = new(src)
			hugger.lose_target()
			proximity_monitor = new(src, PROXIMITY_RADIUS)
		if(BURST)
			update_integrity(integrity_failure)

/obj/structure/alien/egg/Destroy(force)
	. = ..()
	QDEL_NULL(proximity_monitor)

/obj/structure/alien/egg/update_icon_state()
	switch(status)
		if(GROWING)
			icon_state = "egg_growing"
		if(GROWN)
			icon_state = "egg"
		if(BURST)
			icon_state = "egg_opened"

/obj/structure/alien/egg/attack_alien(mob/living/carbon/alien/user)
	return attack_hand(user)

/obj/structure/alien/egg/attack_hand(mob/living/user)
	if(user.get_int_organ(/obj/item/organ/internal/xenos/plasmavessel))
		switch(status)
			if(BURST)
				to_chat(user, span_notice("Вы убираете вылупившееся яйцо."))
				playsound(loc, 'sound/effects/attackblob.ogg', 100, TRUE)
				qdel(src)
				return
			if(GROWING)
				to_chat(user, span_notice("Яйцо еще не созрело."))
				return
			if(GROWN)
				to_chat(user, span_notice("Вы раскрываете яйцо."))
				Burst(kill = FALSE)
				return
	else
		to_chat(user, span_notice("На ощупь — склизкое.."))
		user.changeNext_move(CLICK_CD_MELEE)

/obj/structure/alien/egg/proc/GetFacehugger()
	return locate(/mob/living/simple_animal/hostile/facehugger) in contents

/obj/structure/alien/egg/proc/Grow()
	status = GROWN
	update_icon(UPDATE_ICON_STATE)
	proximity_monitor = new(src, PROXIMITY_RADIUS)

///Need to carry the kill from Burst() to Hatch(), this section handles the alien opening the egg
/obj/structure/alien/egg/proc/Burst(kill = TRUE, atom/movable/trigger)	//drops and kills the hugger if any is remaining
	if(status == GROWN || status == GROWING)
		playsound(get_turf(src), 'sound/creatures/alien/xeno_egg_crack.ogg', 50)
		flick("egg_opening", src)
		status = BURSTING
		QDEL_NULL(proximity_monitor)
		addtimer(CALLBACK(src, PROC_REF(Hatch), kill, trigger), 1 SECONDS)

///We now check HOW the hugger is hatching, kill carried from Burst() and obj_break()
/obj/structure/alien/egg/proc/Hatch(kill, atom/movable/trigger)
	status = BURST
	update_icon(UPDATE_ICON_STATE)
	var/mob/living/simple_animal/hostile/facehugger/child = GetFacehugger()

	if(!child)
		return

	child.forceMove(get_turf(src))
	child.AddComponent(\
		/datum/component/ghost_direct_control,\
		ban_type = ROLE_ALIEN,\
		poll_candidates = FALSE,\
		after_assumed_control = CALLBACK(child, TYPE_PROC_REF(/mob/living/simple_animal/hostile/facehugger, add_datum_if_not_exist)),\
	)
	if(kill)
		child.death()
		return

	for(var/mob/living/victim in range(1, src))
		if(CanHug(victim))
			child.try_hug(victim)
			break

	if(!CanHug(trigger))
		return

	child.GiveTarget(trigger)
	child.MoveToTarget(list(trigger))

/obj/structure/alien/egg/obj_break(damage_flag)
	if(!(obj_flags & NODECONSTRUCT) && status != BURST)
		Burst(kill = TRUE)

/obj/structure/alien/egg/temperature_expose(exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > 500)
		take_damage(5, BURN, 0, 0)

/obj/structure/alien/egg/HasProximity(atom/movable/AM)
	if(status == GROWN)
		if(!CanHug(AM))
			return

		var/mob/living/carbon/target = AM
		if(iscarbon(target) && target.stat == CONSCIOUS && target.get_int_organ(/obj/item/organ/internal/body_egg/alien_embryo))
			return
		if(isalien(target))
			return

		Burst(kill = FALSE, trigger = AM)

#undef BURST
#undef BURSTING
#undef GROWING
#undef GROWN
#undef MIN_GROWTH_TIME
#undef MAX_GROWTH_TIME
#undef PROXIMITY_RADIUS

#undef ALIEN_RESIN_BURN_MOD
#undef ALIEN_RESIN_BRUTE_MOD

#undef RESIN_CORNER_COUNTERCLOCKWISE
#undef RESIN_CORNER_DIAGONAL
#undef RESIN_CORNER_CLOCKWISE
