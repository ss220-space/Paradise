/obj/effect/timestop
	name = "chronofield"
	desc = "Поле, искажающее течение времени. Вы всё равно в игре это не прочитаете."
	icon = 'icons/effects/160x160.dmi'
	icon_state = "time"
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	pixel_x = -64
	pixel_y = -64
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	alpha = 125
	/// List of immune persons for timestop field
	var/list/immune = list()
	/// Turf, where we cast timestop
	var/turf/target
	/// Range for our timestop
	var/freezerange = 2
	/// Duration of our timestop
	var/duration = 14 SECONDS
	/// Datum of our chronofield
	var/datum/proximity_monitor/advanced/timestop/chronofield
	/// Not implemented yet, waiting for antimagic port. Please update this
	var/antimagic_flags = NONE
	/// If true, immune atoms moving ends the timestop instead of duration.
	var/channelled = FALSE
	/// Hides time icon effect and mutes sound
	var/hidden = FALSE
	/// If this true, our timestop deals huge movespeed debuffs instead of full stop. Works only on humans and bullets
	var/timefreeze = FALSE
	/// Sets color matrix for timestop effect.
	var/color_matrix = COLOR_MATRIX_INVERT

/obj/effect/timestop/wizard
	duration = 10 SECONDS

/obj/effect/timestop/clockwork
	duration = 10 SECONDS
	timefreeze = TRUE
	color_matrix = COLOR_MATRIX_SEPIATONE

///indefinite version, but only if no immune atoms move.
/obj/effect/timestop/channelled
	channelled = TRUE

/*
/obj/effect/timestop/magic
	antimagic_flags = MAGIC_RESISTANCE
*/

/obj/effect/timestop/Initialize(mapload, radius, time, list/immune_atoms, start = TRUE, silent = FALSE) //Immune atoms assoc list atom = TRUE
	. = ..()
	if(!isnull(time))
		duration = time
	if(!isnull(radius))
		freezerange = radius
	if(silent)
		hidden = TRUE
		alpha = 0
	for(var/atoms in immune_atoms)
		immune[atoms] = TRUE
	for(var/mob/living/to_check in GLOB.player_list)
		if(HAS_TRAIT(to_check, TRAIT_TIME_STOP_IMMUNE))
			immune[to_check] = TRUE
	for(var/mob/living/simple_animal/hostile/guardian/stand in GLOB.parasites)
		if(stand.summoner && HAS_TRAIT(stand.summoner, TRAIT_TIME_STOP_IMMUNE))
			immune[stand] = TRUE
	if(start)
		INVOKE_ASYNC(src, PROC_REF(timestop))

/obj/effect/timestop/Destroy()
	QDEL_NULL(chronofield)
	if(!hidden)
		playsound(src, 'sound/magic/timeparadox2.ogg', 75, TRUE, frequency = -1) //reverse!
	return ..()

/obj/effect/timestop/proc/timestop()
	target = get_turf(src)
	if(!hidden)
		playsound(src, 'sound/magic/timeparadox2.ogg', 75, TRUE, -1)
	chronofield = new (src, freezerange, TRUE, immune, antimagic_flags, channelled, timefreeze, color_matrix)
	if(!channelled)
		QDEL_IN(src, duration)

/datum/proximity_monitor/advanced/timestop
	edge_is_a_field = TRUE
	/// List of immune atoms
	var/list/immune = list()
	/// List of frozen atoms
	var/list/frozen_things = list()
	/// List of frozen mobs. Cached separately for processing
	var/list/frozen_mobs = list()
	/// List of frozen structures and also machinery, and only frozen aestethically
	var/list/frozen_structures = list()
	/// List of frozen turfs. Only aesthetically
	var/list/frozen_turfs = list()
	/// Not implemented yet, waiting for antimagic port. Please update this
	var/antimagic_flags = NONE
	/// If true, this doesn't time out after a duration but rather when an immune atom inside moves.
	var/channelled = FALSE
	/// If true, humans and bullets get massive slowdowns instead of full stop
	var/timefreeze = FALSE
	/// Sets color matrix for timestop effect.
	var/color_matrix = COLOR_MATRIX_INVERT

	var/static/list/global_frozen_atoms = list()

/datum/proximity_monitor/advanced/timestop/New(atom/_host, range, _ignore_if_not_on_turf = TRUE, list/immune, antimagic_flags, channelled, timefreeze, color_matrix)
	..()
	src.immune = immune.Copy()
	src.antimagic_flags = antimagic_flags
	src.channelled = channelled
	src.timefreeze = timefreeze
	src.color_matrix = color_matrix
	recalculate_field(full_recalc = TRUE)
	START_PROCESSING(SSfastprocess, src)

/datum/proximity_monitor/advanced/timestop/Destroy()
	unfreeze_all()
	if(channelled)
		for(var/atom in immune)
			UnregisterSignal(atom, COMSIG_MOVABLE_MOVED)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/datum/proximity_monitor/advanced/timestop/field_turf_crossed(atom/movable/movable, turf/old_location, turf/new_location)
	freeze_atom(movable)

/datum/proximity_monitor/advanced/timestop/proc/freeze_atom(atom/movable/our_movable)
	if(global_frozen_atoms[our_movable] || !istype(our_movable))
		return FALSE

	if(immune[our_movable]) //a little special logic but yes immune things don't freeze
		if(channelled)
			RegisterSignal(our_movable, COMSIG_MOVABLE_MOVED, PROC_REF(atom_broke_channel), override = TRUE)
		return FALSE
	/*
	if(ismob(our_movable))
		var/mob/our_mob = our_movable
		if(our_mob.can_block_magic(antimagic_flags))
			immune[our_movable] = TRUE
			return
	*/
	var/frozen = TRUE
	if(isliving(our_movable))
		freeze_mob(our_movable)
	else if(isprojectile(our_movable))
		freeze_projectile(our_movable)
	else if(ismecha(our_movable))
		freeze_mecha(our_movable)
	else if((ismachinery(our_movable) && !istype(our_movable, /obj/machinery/light)) || isstructure(our_movable))
		freeze_structure(our_movable)
	else
		frozen = FALSE
	if(our_movable.throwing)
		freeze_throwing(our_movable)
		frozen = TRUE
	if(!frozen)
		return

	frozen_things[our_movable] = our_movable.move_resist
	our_movable.move_resist = INFINITY
	global_frozen_atoms[our_movable] = src
	into_the_negative_zone(our_movable)
	RegisterSignal(our_movable, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(unfreeze_atom))
	RegisterSignal(our_movable, COMSIG_ITEM_PICKUP, PROC_REF(unfreeze_atom))

	SEND_SIGNAL(our_movable, COMSIG_ATOM_TIMESTOP_FREEZE, src)

	return TRUE

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_all()
	for(var/our_item in frozen_things)
		unfreeze_atom(our_item)
	for(var/our_turf in frozen_turfs)
		unfreeze_turf(our_turf)

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_atom(atom/movable/our_movable)
	SIGNAL_HANDLER
	if(our_movable.throwing)
		unfreeze_throwing(our_movable)
	if(isliving(our_movable))
		unfreeze_mob(our_movable)
	else if(isprojectile(our_movable))
		unfreeze_projectile(our_movable)
	else if(ismecha(our_movable))
		unfreeze_mecha(our_movable)

	UnregisterSignal(our_movable, COMSIG_MOVABLE_PRE_MOVE)
	UnregisterSignal(our_movable, COMSIG_ITEM_PICKUP)

	SEND_SIGNAL(our_movable, COMSIG_ATOM_TIMESTOP_UNFREEZE, src)

	escape_the_negative_zone(our_movable)
	our_movable.move_resist = frozen_things[our_movable]
	frozen_things -= our_movable
	global_frozen_atoms -= our_movable

/datum/proximity_monitor/advanced/timestop/proc/freeze_mecha(obj/mecha/our_mecha)
	our_mecha.completely_disabled = TRUE

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_mecha(obj/mecha/our_mecha)
	our_mecha.completely_disabled = FALSE

/datum/proximity_monitor/advanced/timestop/proc/freeze_throwing(atom/movable/our_atom)
	var/datum/thrownthing/throw_watum = our_atom.throwing
	if(!throw_watum)
		return
	throw_watum.paused = TRUE

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_throwing(atom/movable/our_atom)
	var/datum/thrownthing/throw_watum = our_atom.throwing
	if(!throw_watum)
		return
	throw_watum.paused = FALSE

/datum/proximity_monitor/advanced/timestop/proc/freeze_turf(turf/our_turf)
	into_the_negative_zone(our_turf)
	frozen_turfs += our_turf

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_turf(turf/our_turf)
	escape_the_negative_zone(our_turf)

/datum/proximity_monitor/advanced/timestop/proc/freeze_structure(obj/our_object)
	into_the_negative_zone(our_object)
	frozen_structures += our_object

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_structure(obj/our_object)
	escape_the_negative_zone(our_object)

/datum/proximity_monitor/advanced/timestop/process()
	for(var/our_mob in frozen_mobs)
		var/mob/living/mob = our_mob
		if(timefreeze)
			continue
		mob.Stun(20, ignore_canstun = TRUE)

/datum/proximity_monitor/advanced/timestop/setup_field_turf(turf/target)
	. = ..()
	for(var/our_item in target.contents)
		freeze_atom(our_item)
	freeze_turf(target)

/datum/proximity_monitor/advanced/timestop/proc/freeze_projectile(obj/projectile/proj)
	if(!timefreeze)
		proj.paused = TRUE
		return
	proj.speed *= 20 //trust me bro

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_projectile(obj/projectile/proj)
	if(!timefreeze)
		proj.paused = FALSE
		return
	proj.speed /= 20

/datum/proximity_monitor/advanced/timestop/proc/freeze_mob(mob/living/victim)
	frozen_mobs += victim
	if(!timefreeze)
		victim.Stun(20, ignore_canstun = TRUE)
		GLOB.move_manager.stop_looping(victim) //stops them mid pathing even if they're stunimmune
	else
		victim.add_movespeed_modifier(/datum/movespeed_modifier/timestop_modifier)
		victim.next_move_modifier *= 3
	if(is_simple_animal(victim))
		var/mob/living/simple_animal/animal_victim = victim
		animal_victim.toggle_ai(AI_OFF)
		if(ishostile(victim))
			var/mob/living/simple_animal/hostile/hostile_victim = victim
			hostile_victim.lose_target()
	else if(isbasicmob(victim))
		var/mob/living/basic/basic_victim = victim
		basic_victim.ai_controller?.set_ai_status(AI_STATUS_OFF)

/datum/proximity_monitor/advanced/timestop/proc/unfreeze_mob(mob/living/victim)
	frozen_mobs -= victim
	if(!timefreeze)
		victim.AdjustStunned(-20, ignore_canstun = TRUE)
	else
		victim.remove_movespeed_modifier(/datum/movespeed_modifier/timestop_modifier)
		victim.next_move_modifier /= 3
	if(is_simple_animal(victim))
		var/mob/living/simple_animal/animal_victim = victim
		animal_victim.toggle_ai(initial(animal_victim.AIStatus))
	else if(isbasicmob(victim))
		var/mob/living/basic/basic_victim = victim
		basic_victim.ai_controller?.set_ai_status(AI_STATUS_ON) // change to reset_ai_status when finish basic port

//you don't look quite right, is something the matter?
/datum/proximity_monitor/advanced/timestop/proc/into_the_negative_zone(atom/our_atom)
	our_atom.add_atom_colour(color_matrix, TEMPORARY_COLOUR_PRIORITY)

//let's put some colour back into your cheeks
/datum/proximity_monitor/advanced/timestop/proc/escape_the_negative_zone(atom/our_atom)
	our_atom.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY)

//signal fired when an immune atom moves in the time freeze zone
/datum/proximity_monitor/advanced/timestop/proc/atom_broke_channel(datum/source)
	SIGNAL_HANDLER
	qdel(host)

