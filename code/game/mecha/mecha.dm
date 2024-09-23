#define OCCUPANT_LOGGING occupant ? occupant : "empty mech"

/obj/mecha
	name = "Mecha"
	desc = "Exosuit"
	icon = 'icons/obj/mecha/mecha.dmi'
	density = TRUE //Dense. To raise the heat.
	opacity = TRUE ///opaque. Menacing.
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	move_force = MOVE_FORCE_VERY_STRONG
	resistance_flags = FIRE_PROOF | ACID_PROOF
	layer = MOB_LAYER //icon draw layer
	infra_luminosity = 15 //byond implementation is bugged.
	force = 5
	max_integrity = 300 //max_integrity is base health
	armor = list(melee = 20, bullet = 10, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 100)
	bubble_icon = "machine"
	var/list/facing_modifiers = list(MECHA_FRONT_ARMOUR = 1.5, MECHA_SIDE_ARMOUR = 1, MECHA_BACK_ARMOUR = 0.5)
	var/ruin_mecha = FALSE //if the mecha starts on a ruin, don't automatically give it a tracking beacon to prevent metagaming.
	var/initial_icon = null //Mech type for resetting icon. Only used for reskinning kits (see custom items)
	var/can_move = 0 // time of next allowed movement
	var/mech_enter_time = 4 SECONDS // Entering mecha time
	var/mob/living/carbon/occupant = null
	var/step_in = 10 //make a step in step_in/10 sec.
	var/dir_in = 2//What direction will the mech face when entered/powered on? Defaults to South.
	var/normal_step_energy_drain = 10
	var/step_energy_drain = 10
	var/melee_energy_drain = 15
	var/overload_step_energy_drain_min = 100
	var/deflect_chance = 10 //chance to deflect the incoming projectiles, hits, or lesser the effect of ex_act.
	var/obj/item/stock_parts/cell/cell
	var/state = 0
	var/list/log = new
	var/last_message = 0
	var/add_req_access = TRUE
	var/maint_access = TRUE
	var/dna	//dna-locking the mech
	var/datum/effect_system/spark_spread/spark_system = new
	var/lights = 0
	var/lights_power = 6
	var/lights_color = -99999 // "NONSENSICAL_VALUE"
	var/emagged = FALSE
	var/frozen = FALSE
	var/repairing = FALSE
	/// The internal storage of the exosuit. For the cargo module
	var/list/cargo
	/// You can fit a few things in this mecha but not much.
	var/cargo_capacity = 1
	/// for wide cargo module
	var/cargo_expanded = FALSE

	//inner atmos
	var/use_internal_tank = FALSE
	var/internal_tank_valve = ONE_ATMOSPHERE
	var/obj/machinery/portable_atmospherics/canister/internal_tank
	var/datum/gas_mixture/cabin_air
	var/obj/machinery/atmospherics/unary/portables_connector/connected_port = null

	var/obj/item/radio/radio = null
	var/list/trackers = list()

	var/max_temperature = 25000
	var/internal_damage_threshold = 50 //health percentage below which internal damage is possible
	var/internal_damage = 0 //contains bitflags

	var/list/operation_req_access = list()//required access level for mecha operation
	var/list/internals_req_access = list(ACCESS_ENGINE,ACCESS_ROBOTICS)//required access level to open cell compartment

	var/wreckage

	var/list/equipment = new
	var/obj/item/mecha_parts/mecha_equipment/selected
	var/max_equip = 3
	var/turf/crashing = null
	var/occupant_sight_flags = 0

	var/stepsound = 'sound/mecha/mechstep.ogg'
	var/turnsound = 'sound/mecha/mechturn.ogg'
	var/nominalsound = 'sound/mecha/nominal.ogg'
	var/zoomsound = 'sound/mecha/imag_enh.ogg'
	var/critdestrsound = 'sound/mecha/critdestr.ogg'
	var/weapdestrsound = 'sound/mecha/weapdestr.ogg'
	var/lowpowersound = 'sound/mecha/lowpower.ogg'
	var/longactivationsound = 'sound/mecha/nominal.ogg'
	var/starting_voice = /obj/item/mecha_modkit/voice
	var/activated = FALSE
	var/power_warned = FALSE

	var/destruction_sleep_duration = 2 SECONDS //Time that mech pilot is put to sleep for if mech is destroyed

	var/melee_cooldown = 1 SECONDS
	var/melee_can_hit = TRUE

	// Action vars
	var/defence_mode = FALSE
	var/defence_mode_deflect_chance = 35
	var/leg_overload_mode = FALSE
	var/leg_overload_coeff = 100
	var/thrusters_active = FALSE
	var/smoke = 5
	var/smoke_ready = TRUE
	var/smoke_cooldown = 10 SECONDS
	var/zoom_mode = FALSE
	var/phasing = FALSE
	var/phasing_energy_drain = 200
	var/phase_state = "" //icon_state when phasing
	var/wall_type = /obj/effect/forcefield/mecha //energywall icon_state
	var/wall_ready = TRUE
	var/wall_cooldown = 20 SECONDS
	var/large_wall = FALSE

	// Strafe variables
	///Allows strafe mode for mecha
	var/strafe_allowed = FALSE
	///Special module that allows strafe mode by modifying "strafe_allowed" variable
	var/obj/item/mecha_parts/mecha_equipment/servo_hydra_actuator/actuator = null
	///Multiplier that modifies mecha speed while strafing (bigger numbers mean slower movement)
	var/strafe_speed_factor = 1
	///Allows diagonal strafing while strafe is enabled (very OP, FALSE by default on all mechas)
	var/strafe_diagonal = FALSE
	///Is mecha strafing currently
	var/strafe = FALSE

	hud_possible = list (DIAG_STAT_HUD, DIAG_BATT_HUD, DIAG_MECH_HUD, DIAG_TRACK_HUD)

/obj/mecha/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_WEATHER_IMMUNE, INNATE_TRAIT)
	icon_state += "-open"
	add_radio()
	add_cabin()
	add_airtank()
	spark_system.set_up(2, 0, src)
	spark_system.attach(src)
	smoke_system.set_up(3, src)
	smoke_system.attach(src)
	add_cell()
	START_PROCESSING(SSobj, src)
	GLOB.poi_list |= src
	log_message("[src] created.")
	GLOB.mechas_list += src //global mech list
	prepare_huds()
	for(var/datum/atom_hud/data/diagnostic/diag_hud in GLOB.huds)
		diag_hud.add_to_hud(src)
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()
	diag_hud_set_mechtracking()

	var/obj/item/mecha_modkit/voice/V = new starting_voice(src)
	V.install(src)
	qdel(V)

	AddElement(/datum/element/falling_hazard, damage = 100, hardhat_safety = FALSE, crushes = TRUE)

////////////////////////
////// Helpers /////////
////////////////////////

/obj/mecha/get_cell()
	return cell

/obj/mecha/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/mecha/proc/add_cell(var/obj/item/stock_parts/cell/C=null)
	if(C)
		C.forceMove(src)
		cell = C
		return
	cell = new/obj/item/stock_parts/cell/high/plus(src)

/obj/mecha/proc/add_cabin()
	cabin_air = new
	cabin_air.temperature = T20C
	cabin_air.volume = 200
	cabin_air.oxygen = O2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	cabin_air.nitrogen = N2STANDARD*cabin_air.volume/(R_IDEAL_GAS_EQUATION*cabin_air.temperature)
	return cabin_air

/obj/mecha/proc/add_radio()
	radio = new(src)
	radio.name = "[src] radio"
	radio.icon = icon
	radio.icon_state = icon_state

/obj/mecha/examine(mob/user)
	. = ..()
	var/integrity = obj_integrity * 100 / max_integrity
	switch(integrity)
		if(85 to 100)
			. += span_notice("It's fully intact.")
		if(65 to 85)
			. += span_notice("It's slightly damaged.")
		if(45 to 65)
			. += span_notice("It's badly damaged.")
		if(25 to 45)
			. += span_notice("It's heavily damaged.")
		else
			. += span_warning("It's falling apart.")
	if(equipment && equipment.len)
		. += span_notice("It's equipped with:")
		for(var/obj/item/mecha_parts/mecha_equipment/ME in equipment)
			. += span_notice("[bicon(ME)] [ME]")

/obj/mecha/hear_talk(mob/M, list/message_pieces)
	if(M == occupant && radio.broadcasting)
		radio.talk_into(M, message_pieces)

/obj/mecha/proc/click_action(atom/target, mob/user, params)
	if(!occupant || occupant != user )
		return
	if(user.incapacitated())
		return
	if(phasing)
		occupant_message(span_warning("Unable to interact with objects while phasing."))
		return
	if(state)
		occupant_message(span_warning("Maintenance protocols in effect."))
		return
	if(!get_charge())
		return
	if(src == target)
		return

	if(GLOB.pacifism_after_gt)
		var/mob/living/L = user
		if(!target.Adjacent(src))
			if(selected && selected.is_ranged())
				if(selected.harmful)
					to_chat(L, span_warning("You don't want to harm other living beings!"))
					return
				selected.action(target, params)
		else if(selected && selected.is_melee())
			if(ishuman(target) && selected.harmful)
				to_chat(user, span_warning("You don't want to harm other living beings!"))
				return

	var/dir_to_target = get_dir(src, target)
	if(dir_to_target && !(dir_to_target & dir))//wrong direction
		return

	if(hasInternalDamage(MECHA_INT_CONTROL_LOST))
		target = safepick(view(3,target))
		if(!target)
			return
	var/mob/living/L = user
	if(!target.Adjacent(src))
		if(selected && selected.is_ranged())
			if(HAS_TRAIT(L, TRAIT_PACIFISM) && selected.harmful)
				to_chat(L, span_warning("You don't want to harm other living beings!"))
				return
			if(user.mind?.martial_art?.no_guns)
				to_chat(L, span_warning("[L.mind.martial_art.no_guns_message]"))
				return
			selected.action(target, params)
	else if(selected && selected.is_melee())
		if(isliving(target) && selected.harmful && HAS_TRAIT(L, TRAIT_PACIFISM))
			to_chat(user, span_warning("You don't want to harm other living beings!"))
			return
		selected.action(target, params)
	else
		if(internal_damage & MECHA_INT_CONTROL_LOST)
			target = safepick(oview(1, src))
		if(!melee_can_hit || !isatom(target))
			return
		target.mech_melee_attack(src)
		melee_can_hit = FALSE
		addtimer(CALLBACK(src, PROC_REF(melee_hit_ready)), melee_cooldown)

/obj/mecha/proc/melee_hit_ready()
	melee_can_hit = TRUE

/obj/mecha/proc/set_smoke_ready()
	smoke_ready = TRUE

/obj/mecha/proc/set_wall_ready()
	wall_ready = TRUE

/obj/mecha/proc/mech_toxin_damage(mob/living/target)
	playsound(src, 'sound/effects/spray2.ogg', 50, 1)
	if(target.reagents)
		if(target.reagents.get_reagent_amount("atropine") + force < force*2)
			target.reagents.add_reagent("atropine", force/2)
		if(target.reagents.get_reagent_amount("toxin") + force < force*2)
			target.reagents.add_reagent("toxin", force/2.5)

/obj/mecha/proc/range_action(atom/target)
	return

/**
 * Proc that converts diagonal direction into cardinal for mecha
 *
 * Arguments
 * * direction - input direction we need to convert
 */
/obj/mecha/proc/convert_diagonal_dir(direction)
	switch(dir)
		if(NORTH, SOUTH)
			switch(direction)
				if(NORTHEAST, SOUTHEAST)
					return EAST
				if(NORTHWEST, SOUTHWEST)
					return WEST
				if(NORTH, SOUTH, EAST, WEST)
					return direction
		if(EAST, WEST, NORTHEAST, SOUTHEAST, NORTHWEST, SOUTHWEST)
			switch(direction)
				if(NORTHEAST, NORTHWEST)
					return NORTH
				if(SOUTHEAST, SOUTHWEST)
					return SOUTH
				if(NORTH, SOUTH, EAST, WEST)
					return direction

/**
 * Proc that checks if current cardinal direction is opposite for mecha
 *
 * Arguments
 * * direction - input direction we need to check
 */
/obj/mecha/proc/is_opposite_dir(direction)
	. = FALSE
	switch(dir)
		if(NORTH)
			return direction == SOUTH
		if(SOUTH)
			return direction == NORTH
		if(EAST)
			return direction == WEST
		if(WEST)
			return direction == EAST

//////////////////////////////////
////////  Movement procs  ////////
//////////////////////////////////
/obj/mecha/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	. = ..()
	if(.)
		return TRUE

	//Turns strafe OFF if not enough energy to step (with actuator module only)
	if(strafe && actuator && !has_charge(actuator.energy_per_step))
		toggle_strafe(silent = TRUE)

	var/atom/movable/backup = get_spacemove_backup(movement_dir, continuous_move)
	if(backup)
		if(!istype(backup) || !movement_dir || backup.anchored || continuous_move)
			return TRUE	//get_spacemove_backup() already checks if a returned turf is solid, so we can just go
		last_pushoff = world.time
		if(backup.newtonian_move(REVERSE_DIR(movement_dir), instant = TRUE))
			backup.last_pushoff = world.time
			if(occupant)
				to_chat(occupant, span_info("You push off of [backup] to propel yourself."))
		return TRUE

	if(thrusters_active && movement_dir && use_power(step_energy_drain))
		return TRUE

	return FALSE


/obj/mecha/relaymove(mob/user, direction)
	if(!direction || frozen)
		return FALSE
	if(user != occupant) //While not "realistic", this piece is player friendly.
		user.forceMove(get_turf(src))
		to_chat(user, span_notice("You climb out from [src]."))
		return FALSE
	if(connected_port)
		if(world.time - last_message > 20)
			occupant_message(span_warning("Unable to move while connected to the air system port!"))
			last_message = world.time
		return FALSE
	if(state)
		occupant_message(span_danger("Maintenance protocols in effect."))
		return FALSE
	return domove(direction)

//Constants for strafe mode
#define STRAFE_TURN_FACTOR 1.5 //Speed multiplier for strafe while mecha turns around
#define STRAFE_DIAGONAL_FACTOR 2 //Speed multiplier for strafe while mecha moves diagonally
#define STRAFE_BACKWARDS_FACTOR 2 //Speed and energy drain multiplier for strafe while mecha moves backwards

/obj/mecha/proc/domove(direction)
	if(can_move >= world.time)
		return FALSE
	if(!Process_Spacemove(direction))
		return FALSE
	if(!has_charge(step_energy_drain))
		return FALSE
	if(defence_mode)
		if(world.time - last_message > 20)
			occupant_message(span_danger("Unable to move while in defence mode."))
			last_message = world.time
		return FALSE
	if(zoom_mode)
		if(world.time - last_message > 20)
			occupant_message(span_danger("Unable to move while in zoom mode."))
			last_message = world.time
		return FALSE

	//Turns strafe OFF if not enough energy to step (with actuator module only)
	if(strafe && actuator && !has_charge(actuator.energy_per_step))
		toggle_strafe(silent = TRUE)

	var/move_result = FALSE
	var/move_type = FALSE
	var/old_direction = dir //Initial direction of the mecha
	var/step_in_final = strafe ? (step_in * strafe_speed_factor) : step_in //Modifies strafe speed, if "strafe_speed_factor" is anything other than 1
	var/strafed_backwards = FALSE //Checks if mecha moved backwards, while strafe is active (used later to modify speed and energy drain)

	var/keyheld = FALSE //Checks if player pressed ALT button down while strafe is active
	if(strafe && occupant.client?.keys_held["Alt"])
		keyheld = TRUE

	if(internal_damage & MECHA_INT_CONTROL_LOST)
		if(strafe) //No strafe while controls are malfunctioning
			toggle_strafe(silent = TRUE)
		move_result = mechsteprand()
		move_type = MECHAMOVE_RAND
	else if(direction & (UP|DOWN))
		var/turf/above = GET_TURF_ABOVE(loc)
		if(!(direction & UP) || !can_z_move(DOWN, above, null, ZMOVE_FALL_FLAGS|ZMOVE_CAN_FLY_CHECKS|ZMOVE_FEEDBACK, occupant))
			if(zMove(direction, z_move_flags = ZMOVE_FLIGHT_FLAGS))
				playsound(src, stepsound, 40, 1)
				move_result = TRUE
				move_type = MECHAMOVE_STEP
	else if(dir != direction && !strafe || keyheld) //Player can use ALT button while strafe is active to change direction on fly
		if(strafe)
			step_in_final *= STRAFE_TURN_FACTOR
		move_result = mechturn(direction)
		move_type = MECHAMOVE_TURN
	else
		if(direction & (direction - 1))	//Trick to check for diagonal direction
			if(strafe)
				if(strafe_diagonal) //Diagonal strafe is overpowered, disabled by default on all mechas
					step_in_final *= STRAFE_DIAGONAL_FACTOR //Applies speed multiplier if mecha moved diagonally
					move_result = mechstep(direction, old_direction, step_in_final)
					move_type = MECHAMOVE_STEP
				else
					strafed_backwards = is_opposite_dir(convert_diagonal_dir(direction))
					step_in_final *= strafed_backwards ? STRAFE_BACKWARDS_FACTOR : 1 //Applies speed multiplier if mecha moved backwards
					move_result = mechstep(convert_diagonal_dir(direction), old_direction, step_in_final) //Any diagonal movement will be converted to cardinal via "convert_diagonal_dir" proc
					move_type = MECHAMOVE_STEP
			else
				move_result = mechstep(direction)
				move_type = MECHAMOVE_STEP
		else
			strafed_backwards = is_opposite_dir(direction)
			step_in_final *= strafed_backwards ? STRAFE_BACKWARDS_FACTOR : 1 //Applies speed multiplier if mecha moved backwards
			move_result = mechstep(direction, old_direction, step_in_final)
			move_type = MECHAMOVE_STEP

	if(move_result && move_type)
		set_glide_size(DELAY_TO_GLIDE_SIZE(step_in_final))
		if(strafe && actuator) //Energy drain mechanics for actuator module
			use_power(strafed_backwards ? (actuator.energy_per_step * STRAFE_BACKWARDS_FACTOR) : actuator.energy_per_step)
		aftermove(move_type)
		can_move = world.time + step_in_final
		return TRUE
	return FALSE

#undef STRAFE_TURN_FACTOR
#undef STRAFE_DIAGONAL_FACTOR
#undef STRAFE_BACKWARDS_FACTOR

/obj/mecha/proc/aftermove(move_type)
	use_power(step_energy_drain)
	if(move_type & (MECHAMOVE_RAND | MECHAMOVE_STEP) && occupant)
		var/obj/machinery/atmospherics/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/unary/portables_connector) in loc
		if(possible_port)
			var/atom/movable/screen/alert/mech_port_available/A = occupant.throw_alert("mechaport", /atom/movable/screen/alert/mech_port_available, override = TRUE)
			if(A)
				A.target = possible_port
		else
			occupant.clear_alert("mechaport")
	if(leg_overload_mode)
		if(strafe) //No strafe while overload is active
			toggle_strafe(silent = TRUE)
		log_message("Leg Overload damage.")
		take_damage(1, BRUTE, FALSE, FALSE)
		if(obj_integrity < max_integrity - max_integrity / 3)
			leg_overload_mode = FALSE
			step_in = initial(step_in)
			step_energy_drain = initial(step_energy_drain)
			occupant_message("<font color='red'>Leg actuators damage threshold exceded. Disabling overload.</font>")

/obj/mecha/proc/mechturn(direction)
	dir = direction
	if(turnsound)
		playsound(src,turnsound,40,1)
	return TRUE

/obj/mecha/proc/mechstep(direction, old_direction, step_in_final)
	. = step(src, direction)
	if(strafe)
		setDir(old_direction) //Mecha will always face the same direction while moving and strafe is active
	if(!.)
		if(strafe) //Cooldown and sound effect if mecha failed to step
			can_move = world.time + step_in_final
			if(turnsound)
				playsound(src, turnsound, 40, 1)
		if(phasing && get_charge() >= phasing_energy_drain)
			if(strafe) //No strafe while phase mode is active
				toggle_strafe(silent = TRUE)
			if(can_move < world.time)
				. = FALSE // We lie to mech code and say we didn't get to move, because we want to handle power usage + cooldown ourself
				flick("[initial_icon]-phase", src)
				forceMove(get_step(src, direction))
				use_power(phasing_energy_drain)
				playsound(src, stepsound, 40, 1)
				can_move = world.time + (step_in * 3)
	else if(stepsound)
		playsound(src, stepsound, 40, 1)

/obj/mecha/proc/mechsteprand()
	. = step_rand(src)
	if(. && stepsound)
		playsound(src, stepsound, 40, 1)


/obj/mecha/Bump(atom/bumped_atom)
	if(!throwing)
		. = ..()
		if(.)
			return .
		if(isobj(bumped_atom))
			var/obj/bumped_object = bumped_atom
			if(!bumped_object.anchored)
				step(bumped_atom, dir)
		else if(ismob(bumped_atom))
			step(bumped_atom, dir)
		return .

	//high velocity mechas in your face!
	var/breakthrough = FALSE
	if(istype(bumped_atom, /obj/structure/window))
		qdel(bumped_atom)
		breakthrough = TRUE

	else if(istype(bumped_atom, /obj/structure/grille))
		var/obj/structure/grille/grille = bumped_atom
		grille.obj_break()
		breakthrough = TRUE

	else if(istype(bumped_atom, /obj/structure/table))
		qdel(bumped_atom)
		breakthrough = TRUE

	else if(istype(bumped_atom, /obj/structure/rack))
		new /obj/item/rack_parts(bumped_atom.loc)
		qdel(bumped_atom)
		breakthrough = TRUE

	else if(istype(bumped_atom, /obj/structure/reagent_dispensers/fueltank))
		bumped_atom.ex_act(EXPLODE_DEVASTATE)

	else if(isliving(bumped_atom))
		var/mob/living/bumped_living = bumped_atom
		if(bumped_living.flags & GODMODE)
			return
		var/static/list/mecha_hit_sound = list('sound/weapons/genhit1.ogg','sound/weapons/genhit2.ogg','sound/weapons/genhit3.ogg')
		bumped_living.take_overall_damage(5)
		bumped_living.unbuckle_mob(force = TRUE)
		bumped_living.Weaken(10 SECONDS)
		bumped_living.apply_effect(STUTTER, 10 SECONDS)
		playsound(src, pick(mecha_hit_sound), 50, FALSE)
		breakthrough = TRUE
	else
		throwing.finalize()
		crashing = null

	. = ..()

	if(breakthrough)
		if(crashing)
			spawn(1)
				throw_at(crashing, 50, throw_speed)
		else
			spawn(1)
				crashing = get_distant_turf(get_turf(src), dir, 3)//don't use get_dir(src, obstacle) or the mech will stop if he bumps into a one-direction window on his tile.
				throw_at(crashing, 50, throw_speed)



///////////////////////////////////
////////  Internal damage  ////////
///////////////////////////////////

/obj/mecha/proc/check_for_internal_damage(list/possible_int_damage, ignore_threshold=null)
	if(!islist(possible_int_damage) || isemptylist(possible_int_damage))
		return
	if(prob(20))
		if(ignore_threshold || obj_integrity*100/max_integrity < internal_damage_threshold)
			for(var/T in possible_int_damage)
				if(internal_damage & T)
					possible_int_damage -= T
			var/int_dam_flag = safepick(possible_int_damage)
			if(int_dam_flag)
				setInternalDamage(int_dam_flag)
	if(prob(5))
		if(ignore_threshold || obj_integrity*100/max_integrity < internal_damage_threshold)
			var/obj/item/mecha_parts/mecha_equipment/ME = safepick(equipment)
			if(ME)
				qdel(ME)

/obj/mecha/proc/hasInternalDamage(int_dam_flag=null)
	return int_dam_flag ? internal_damage&int_dam_flag : internal_damage


/obj/mecha/proc/setInternalDamage(int_dam_flag)
	internal_damage |= int_dam_flag
	log_append_to_last("Internal damage of type [int_dam_flag].",1)
	occupant << sound('sound/machines/warning-buzzer.ogg',wait=0)
	diag_hud_set_mechstat()

/obj/mecha/proc/clearInternalDamage(int_dam_flag)
	internal_damage &= ~int_dam_flag
	switch(int_dam_flag)
		if(MECHA_INT_TEMP_CONTROL)
			occupant_message(span_notice("Life support system reactivated."))
		if(MECHA_INT_FIRE)
			occupant_message(span_notice("Internal fire extinquished."))
		if(MECHA_INT_TANK_BREACH)
			occupant_message(span_notice("Damaged internal tank has been sealed."))
	diag_hud_set_mechstat()


////////////////////////////////////////
////////  Health related procs  ////////
////////////////////////////////////////

/obj/mecha/proc/get_armour_facing(relative_dir)
	switch(relative_dir)
		if(0) // BACKSTAB!
			return facing_modifiers[MECHA_BACK_ARMOUR]
		if(45, 90, 270, 315)
			return facing_modifiers[MECHA_SIDE_ARMOUR]
		if(225, 180, 135)
			return facing_modifiers[MECHA_FRONT_ARMOUR]
	return TRUE //always return non-0

/obj/mecha/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(. && obj_integrity > 0)
		spark_system.start()
		switch(damage_flag)
			if("fire")
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL))
			if("melee")
				check_for_internal_damage(list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST))
			else
				check_for_internal_damage(list(MECHA_INT_FIRE,MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH,MECHA_INT_CONTROL_LOST,MECHA_INT_SHORT_CIRCUIT))
		if((. >= 5 || prob(33)) && !(. == 1 && leg_overload_mode)) //If it takes 1 damage and leg_overload_mode is true, do not say TAKING DAMAGE! to the user several times a second.
			occupant_message(span_userdanger("Taking damage!"))
		log_message("Took [damage_amount] points of damage. Damage type: [damage_type]")

/obj/mecha/run_obj_armor(damage_amount, damage_type, damage_flag = 0, attack_dir)
	. = ..()
	if(!damage_amount)
		return FALSE
	var/booster_deflection_modifier = 1
	var/booster_damage_modifier = 1
	if(damage_flag == "bullet" || damage_flag == "laser" || damage_flag == "energy")
		for(var/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/B in equipment)
			if(B.projectile_react())
				booster_deflection_modifier = B.deflect_coeff
				booster_damage_modifier = B.damage_coeff
				break
	else if(damage_flag == "melee")
		for(var/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/B in equipment)
			if(B.attack_react())
				booster_deflection_modifier *= B.deflect_coeff
				booster_damage_modifier *= B.damage_coeff
				break

	if(attack_dir)
		var/facing_modifier = get_armour_facing(dir2angle(attack_dir) - dir2angle(src))
		booster_damage_modifier /= facing_modifier
		booster_deflection_modifier *= facing_modifier
	if(prob(deflect_chance * booster_deflection_modifier))
		visible_message(span_danger("[src]'s armour deflects the attack!"))
		log_message("Armor saved.")
		return FALSE
	if(.)
		. *= booster_damage_modifier

/obj/mecha/attack_hand(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
	playsound(loc, 'sound/weapons/tap.ogg', 40, 1, -1)
	user.visible_message(span_notice("[user] hits [name]. Nothing happens."), span_notice("You hit [name] with no visible effect."))
	log_message("Attack by hand/paw. Attacker - [user].")


/obj/mecha/attack_alien(mob/living/carbon/alien/user)
	log_message("Attack by alien. Attacker - [user].", TRUE)
	add_attack_logs(user, OCCUPANT_LOGGING, "Alien attacked mech [src]")
	playsound(loc, 'sound/weapons/slash.ogg', 100, TRUE)
	attack_generic(user, user.obj_damage, BRUTE, MELEE, 0, user.armour_penetration)

/obj/mecha/attack_animal(mob/living/simple_animal/user)
	log_message("Attack by simple animal. Attacker - [user].")
	if(!user.melee_damage_upper && !user.obj_damage)
		user.custom_emote(EMOTE_VISIBLE, "[user.friendly] [src].")
		return FALSE
	else
		var/play_soundeffect = TRUE
		if(user.environment_smash)
			play_soundeffect = FALSE
			playsound(src, 'sound/effects/bang.ogg', 50, TRUE)
		var/animal_damage = rand(user.melee_damage_lower,user.melee_damage_upper)
		if(user.obj_damage)
			animal_damage = user.obj_damage
		animal_damage = min(animal_damage, 20*user.environment_smash)
		if(animal_damage)
			add_attack_logs(user, OCCUPANT_LOGGING, "Animal attacked mech [src]")
		attack_generic(user, animal_damage, user.melee_damage_type, "melee", play_soundeffect)
		return TRUE

/obj/mecha/blob_act(obj/structure/blob/B)
	log_message("Attack by blob. Attacker - [B].")
	take_damage(30, BRUTE, "melee", 0, get_dir(src, B))

/obj/mecha/attack_tk()
	return

/obj/mecha/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum) //wrapper
	log_message("Hit by [AM].")
	if(isitem(AM))
		var/obj/item/I = AM
		add_attack_logs(locateUID(I.thrownby), OCCUPANT_LOGGING, "threw [AM] at mech [src]")
	. = ..()

/obj/mecha/bullet_act(obj/item/projectile/Proj) //wrapper
	log_message("Hit by projectile. Type: [Proj.name]([Proj.flag]).")
	add_attack_logs(Proj.firer, OCCUPANT_LOGGING, "shot [Proj.name]([Proj.flag]) at mech [src]")
	..()

/obj/mecha/ex_act(severity, target)
	log_message("Affected by explosion of severity: [severity].")
	if(prob(deflect_chance))
		severity++
		log_message("Armor saved, changing severity to [severity]")
	..()
	severity++
	for(var/X in equipment)
		var/obj/item/mecha_parts/mecha_equipment/ME = X
		ME.ex_act(severity)
	for(var/Y in trackers)
		var/obj/item/mecha_parts/mecha_tracking/MT = Y
		MT.ex_act(severity)
	if(occupant)
		occupant.ex_act(severity)

	for(var/X in cargo)
		var/atom/movable/cargo_thing = X
		if(prob(30 / severity))
			cargo -= cargo_thing
			cargo_thing.forceMove(drop_location())

/obj/mecha/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		update_icon(UPDATE_ICON_STATE)
		setDir(dir_in)
	if(A in trackers)
		trackers -= A

/obj/mecha/Destroy()

	for(var/atom/movable/cargo_thing as anything in cargo)
		cargo -= cargo_thing
		cargo_thing.forceMove(drop_location())
		step_rand(cargo_thing)

	if(occupant)
		occupant.SetSleeping(destruction_sleep_duration)
	go_out()
	var/mob/living/silicon/ai/AI
	for(var/mob/M in src) //Let's just be ultra sure
		if(isAI(M))
			occupant = null
			AI = M //AIs are loaded into the mech computer itself. When the mech dies, so does the AI. They can be recovered with an AI card from the wreck.
		else
			M.forceMove(loc)
	for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
		E.detach(loc)
		qdel(E)
	equipment.Cut()
	QDEL_NULL(cell)
	QDEL_NULL(internal_tank)
	if(AI)
		AI.gib() //No wreck, no AI to recover
	STOP_PROCESSING(SSobj, src)
	GLOB.poi_list.Remove(src)
	if(loc)
		loc.assume_air(cabin_air)
		air_update_turf()
	else
		qdel(cabin_air)
	cabin_air = null
	QDEL_NULL(spark_system)
	QDEL_NULL(smoke_system)
	QDEL_LIST(trackers)
	GLOB.mechas_list -= src //global mech list
	return ..()

//TODO
/obj/mecha/emp_act(severity)
	if(get_charge())
		use_power((cell.charge/3)/(severity*2))
		take_damage(30 / severity, BURN, "energy", 1)
	log_message("EMP detected", 1)
	check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL, MECHA_INT_CONTROL_LOST, MECHA_INT_SHORT_CIRCUIT), 1)

/obj/mecha/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	if(exposed_temperature > max_temperature)
		log_message("Exposed to dangerous temperature.", 1)
		take_damage(5, BURN, 0, 1)
		check_for_internal_damage(list(MECHA_INT_FIRE, MECHA_INT_TEMP_CONTROL))

//////////////////////
////// AttackBy //////
//////////////////////

/obj/mecha/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		if(I.force)
			add_attack_logs(user, OCCUPANT_LOGGING, "attacked mech '[name]' using [I]")
		return ..()

	if(istype(I, /obj/item/mmi))
		add_fingerprint(user)
		if(!mmi_move_inside(I, user))
			to_chat(user, "[name]-MMI interface initialization failed.")
			return ATTACK_CHAIN_PROCEED
		to_chat(user, "[name]-MMI interface initialized successfuly")
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/mecha_parts/mecha_equipment))
		add_fingerprint(user)
		var/obj/item/mecha_parts/mecha_equipment/equipment = I
		if(!equipment.can_attach(src))
			to_chat(user, span_warning("You were unable to attach [I] to [src]!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		equipment.attach(src)
		user.visible_message(
			span_notice("[user] attaches [I] to [src]."),
			span_notice("You attach [I] to [src]."),
		)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/card/id))
		add_fingerprint(user)
		if(!add_req_access && !maint_access)
			to_chat(user, span_warning("Maintenance protocols disabled by operator."))
			return ATTACK_CHAIN_PROCEED
		if(!internals_access_allowed(user))
			to_chat(user, span_warning("Invalid ID: Access denied."))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/card/id/id_card = I
		output_maintenance_dialog(id_card, user)
		return ATTACK_CHAIN_PROCEED

	if(iscoil(I) && state == 3 && hasInternalDamage(MECHA_INT_SHORT_CIRCUIT))
		add_fingerprint(user)
		var/obj/item/stack/cable_coil/coil = I
		if(!coil.use(2))
			to_chat(user, span_warning("There's not enough wire to finish the task."))
			return ATTACK_CHAIN_PROCEED
		clearInternalDamage(MECHA_INT_SHORT_CIRCUIT)
		to_chat(user, span_notice("You replace the fused wires."))
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/stock_parts/cell) && state == 4)
		add_fingerprint(user)
		if(cell)
			to_chat(user, span_warning("There's already a powercell installed."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You install the powercell."))
		cell = I
		log_message("Powercell installed")
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/mecha_parts/mecha_tracking))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		trackers += I
		user.visible_message(
			span_notice("[user] attaches [I] to [src]."),
			span_notice("You attach [I] to [src]."),
		)
		diag_hud_set_mechtracking()
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/paintkit))
		add_fingerprint(user)
		if(occupant)
			to_chat(user, span_warning("You can't customize a mech while someone is piloting it - that would be unsafe!"))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/paintkit/paintkit = I
		var/found = FALSE
		for(var/type in paintkit.allowed_types)
			if(type == initial_icon)
				found = TRUE
				break
		if(!found)
			to_chat(user, span_warning("This paintkit isn't meant for use on this class of exosuit."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(paintkit, src))
			return ..()
		user.visible_message(span_notice("[user] opens [paintkit] and spends some quality time customising [name]."))
		if(paintkit.new_prefix)
			initial_icon = "[paintkit.new_prefix][initial_icon]"
		else
			initial_icon = paintkit.new_icon
		name = paintkit.new_name
		desc = paintkit.new_desc
		update_icon(UPDATE_ICON_STATE)
		qdel(paintkit)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/mecha_modkit))
		add_fingerprint(user)
		if(occupant)
			to_chat(user, span_warning("You can't access the mech's modification port while it is occupied."))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/mecha_modkit/modkit = I
		if(!do_after(user, modkit.install_time, src, max_interact_count = 1, cancel_on_max = TRUE, cancel_message = span_warning("You stop installing [modkit]."), category = DA_CAT_TOOL))
			return ATTACK_CHAIN_PROCEED
		modkit.install(src, user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(I.force)
		add_attack_logs(user, OCCUPANT_LOGGING, "attacked mech '[name]' using [I]")

	return ..()


/obj/mecha/crowbar_act(mob/user, obj/item/I)
	if(state != 2 && state != 3 && !(state == 4 && occupant))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(state == 2)
		state = 3
		to_chat(user, "You open the hatch to the power unit")
	else if(state == 3)
		state = 2
		to_chat(user, "You close the hatch to the power unit")
	else if(ishuman(occupant))
		user.visible_message("[user] begins levering out the driver from the [src].", "You begin to lever out the driver from the [src].")
		to_chat(occupant, span_warning("[user] is prying you out of the exosuit!"))
		if(I.use_tool(src, user, 80, volume = I.tool_volume))
			user.visible_message(span_notice("[user] pries the driver out of the [src]!"), span_notice("You finish removing the driver from the [src]!"))
			go_out()
	else
		// Since having maint protocols available is controllable by the MMI, I see this as a consensual way to remove an MMI without destroying the mech
		user.visible_message("[user] begins levering out the MMI from the [src].", "You begin to lever out the MMI from the [src].")
		to_chat(occupant, span_warning("[user] is prying you out of the exosuit!"))
		if(I.use_tool(src, user, 80, volume = I.tool_volume) && pilot_is_mmi())
			user.visible_message(span_notice("[user] pries the MMI out of the [src]!"), span_notice("You finish removing the MMI from the [src]!"))
			go_out()

/obj/mecha/screwdriver_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return
	if(!(state==3 && cell) && !(state==4 && cell))
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(hasInternalDamage(MECHA_INT_TEMP_CONTROL))
		clearInternalDamage(MECHA_INT_TEMP_CONTROL)
		to_chat(user, span_notice("You repair the damaged temperature controller."))
	else if(state==3 && cell)
		cell.forceMove(loc)
		cell = null
		state = 4
		to_chat(user, span_notice("You unscrew and pry out the powercell."))
		log_message("Powercell removed")
	else if(state==4 && cell)
		state=3
		to_chat(user, span_notice("You screw the cell in place."))

/obj/mecha/wrench_act(mob/user, obj/item/I)
	if(state != 1 && state != 2)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(state==1)
		state = 2
		to_chat(user, "You undo the securing bolts.")
	else
		state = 1
		to_chat(user, "You tighten the securing bolts.")

/obj/mecha/welder_act(mob/user, obj/item/I)
	if(user.a_intent == INTENT_HARM)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if((obj_integrity >= max_integrity) && !internal_damage)
		to_chat(user, span_notice("[src] is at full integrity!"))
		return
	if(repairing)
		to_chat(user, span_notice("[src] is currently being repaired!"))
		return
	if(state == 0) // If maint protocols are not active, the state is zero
		to_chat(user, span_warning("[src] can not be repaired without maintenance protocols active!"))
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	repairing = TRUE
	if(I.use_tool(src, user, 15, volume = I.tool_volume))
		if(internal_damage & MECHA_INT_TANK_BREACH)
			clearInternalDamage(MECHA_INT_TANK_BREACH)
			user.visible_message(span_notice("[user] repairs the damaged gas tank."), span_notice("You repair the damaged gas tank."))
		else if(obj_integrity < max_integrity)
			user.visible_message(span_notice("[user] repairs some damage to [name]."), span_notice("You repair some damage to [name]."))
			obj_integrity += min(10, max_integrity - obj_integrity)
		else
			to_chat(user, span_notice("[src] is at full integrity!"))
	repairing = FALSE

/obj/mecha/mech_melee_attack(obj/mecha/M)
	if(!has_charge(melee_energy_drain))
		return FALSE
	use_power(melee_energy_drain)
	if(M.damtype == BRUTE || M.damtype == BURN)
		add_attack_logs(M.occupant, src, "Mecha-attacked with [M] ([uppertext(M.occupant.a_intent)]) ([uppertext(M.damtype)])")
		. = ..()

/obj/mecha/emag_act(mob/user)
	if(user)
		to_chat(user, span_warning("[src]'s ID slot rejects the card."))


/////////////////////////////////////
//////////// AI piloting ////////////
/////////////////////////////////////

/obj/mecha/attack_ai(mob/living/silicon/ai/user)
	if(!isAI(user))
		return
	//Allows the Malf to scan a mech's status and loadout, helping it to decide if it is a worthy chariot.
	if(user.can_dominate_mechs)
		examine(user) //Get diagnostic information!
		for(var/obj/item/mecha_parts/mecha_tracking/B in trackers)
			to_chat(user, span_danger("Warning: Tracking Beacon detected. Enter at your own risk. Beacon Data:"))
			to_chat(user, "[B.get_mecha_info_text()]")
			break
		//Nothing like a big, red link to make the player feel powerful!
		to_chat(user, "<a href='byond://?src=[user.UID()];ai_take_control=\ref[src]'>[span_userdanger("ASSUME DIRECT CONTROL?")]</a><br>")
	else
		examine(user)
		if(occupant)
			to_chat(user, span_warning("This exosuit has a pilot and cannot be controlled."))
			return
		var/can_control_mech = FALSE
		for(var/obj/item/mecha_parts/mecha_tracking/ai_control/A in trackers)
			can_control_mech = TRUE
			to_chat(user, "[span_notice("[bicon(src)] Status of [name]:")]\n\
				[A.get_mecha_info_text()]")
			break
		if(!can_control_mech)
			to_chat(user, span_warning("You cannot control exosuits without AI control beacons installed."))
			return
		to_chat(user, "<a href='byond://?src=[user.UID()];ai_take_control=\ref[src]'>[span_boldnotice("Take control of exosuit?")]</a><br>")

/obj/mecha/transfer_ai(interaction, mob/user, mob/living/silicon/ai/AI, obj/item/aicard/card)
	if(!..())
		return

 //Transfer from core or card to mech. Proc is called by mech.
	switch(interaction)
		if(AI_TRANS_TO_CARD) //Upload AI from mech to AI card.
			if(!maint_access) //Mech must be in maint mode to allow carding.
				to_chat(user, span_warning("[name] must have maintenance protocols active in order to allow a transfer."))
				return
			AI = occupant
			if(!AI || !isAI(occupant)) //Mech does not have an AI for a pilot
				to_chat(user, span_warning("No AI detected in the [name] onboard computer."))
				return
			if(AI.mind.special_role) //Malf AIs cannot leave mechs. Except through death.
				to_chat(user, span_boldannounceic("ACCESS DENIED."))
				return
			AI.aiRestorePowerRoutine = 0//So the AI initially has power.
			AI.control_disabled = TRUE
			AI.aiRadio.disabledAi = TRUE
			AI.forceMove(card)
			occupant = null
			AI.controlled_mech = null
			AI.remote_control = null
			update_icon(UPDATE_ICON_STATE)
			to_chat(AI, "You have been downloaded to a mobile storage device. Wireless connection offline.")
			to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) removed from [name] and stored within local memory.")

		if(AI_MECH_HACK) //Called by AIs on the mech
			if(occupant)
				if(AI.can_dominate_mechs) //Oh, I am sorry, were you using that?
					to_chat(AI, span_warning("Pilot detected! Forced ejection initiated!"))
					to_chat(occupant, span_danger("You have been forcibly ejected!"))
					go_out(TRUE) //IT IS MINE, NOW. SUCK IT, RD!
				else
					to_chat(AI, span_warning("This exosuit has a pilot and cannot be controlled."))
					return
			AI.linked_core = new /obj/structure/AIcore/deactivated(AI.loc)
			ai_enter_mech(AI, interaction)

		if(AI_TRANS_FROM_CARD) //Using an AI card to upload to a mech.
			AI = locate(/mob/living/silicon/ai) in card
			if(!AI)
				to_chat(user, span_warning("There is no AI currently installed on this device."))
				return
			else if(AI.stat || !AI.client)
				to_chat(user, span_warning("[AI.name] is currently unresponsive, and cannot be uploaded."))
				return
			else if(occupant || dna) //Normal AIs cannot steal mechs!
				to_chat(user, span_warning("Access denied. [name] is [occupant ? "currently occupied" : "secured with a DNA lock"]."))
				return
			AI.control_disabled = FALSE
			AI.aiRadio.disabledAi = FALSE
			to_chat(user, "[span_boldnotice("Transfer successful")]: [AI.name] ([rand(1000,9999)].exe) installed and executed successfully. Local copy has been removed.")
			ai_enter_mech(AI, interaction)

//Hack and From Card interactions share some code, so leave that here for both to use.
/obj/mecha/proc/ai_enter_mech(mob/living/silicon/ai/AI, interaction)
	AI.aiRestorePowerRoutine = 0
	AI.forceMove(src)
	occupant = AI
	update_icon(UPDATE_ICON_STATE)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
	if(!hasInternalDamage())
		occupant << sound(nominalsound, volume = 50)
	AI.eyeobj?.forceMove(src)
	AI.eyeobj?.RegisterSignal(src, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/camera/aiEye, update_visibility))
	AI.controlled_mech = src
	AI.remote_control = src
	AI.can_shunt = FALSE //ONE AI ENTERS. NO AI LEAVES.
	to_chat(AI, "[AI.can_dominate_mechs ? span_announce("Takeover of [name] complete! You are now permanently loaded onto the onboard computer. Do not attempt to leave the station sector!") \
	: span_notice("You have been uploaded to a mech's onboard computer.")]")
	to_chat(AI, span_boldnotice("Use Middle-Mouse to activate mech functions and equipment. Click normally for AI interactions."))
	if(interaction == AI_TRANS_FROM_CARD)
		GrantActions(AI, FALSE)
	else
		GrantActions(AI, !AI.can_dominate_mechs)

/////////////////////////////////////
////////  Atmospheric stuff  ////////
/////////////////////////////////////

/obj/mecha/proc/get_turf_air()
	var/turf/T = get_turf(src)
	if(T)
		. = T.return_air()

/obj/mecha/remove_air(amount)
	if(use_internal_tank)
		return cabin_air.remove(amount)
	else
		var/turf/T = get_turf(src)
		if(T)
			return T.remove_air(amount)

/obj/mecha/return_air()
	if(use_internal_tank)
		return cabin_air
	return get_turf_air()

/obj/mecha/return_analyzable_air()
	if(use_internal_tank)
		return cabin_air
	return null

/obj/mecha/proc/return_pressure()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_pressure()

//skytodo: //No idea what you want me to do here, mate.
/obj/mecha/proc/return_temperature()
	var/datum/gas_mixture/t_air = return_air()
	if(t_air)
		. = t_air.return_temperature()

/obj/mecha/proc/connect(obj/machinery/atmospherics/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !istype(new_port) || new_port.connected_device)
		return FALSE

	//Make sure are close enough for a valid connection
	if(new_port.loc != loc)
		return FALSE

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	connected_port.parent.reconcile_air()

	if(occupant)
		occupant.clear_alert("mechaport")
		occupant.throw_alert("mechaport_d", /atom/movable/screen/alert/mech_port_disconnect)

	log_message("Connected to gas port.")
	return TRUE

/obj/mecha/proc/disconnect()
	if(!connected_port)
		return FALSE

	connected_port.connected_device = null
	connected_port = null
	log_message("Disconnected from gas port.")
	if(occupant)
		occupant.clear_alert("mechaport_d")
	return TRUE

/obj/mecha/portableConnectorReturnAir()
	return internal_tank.return_air()

/obj/mecha/proc/toggle_lights()
	lights_action.Trigger()

/obj/mecha/extinguish_light(force = FALSE)
	if(!lights || !lights_power)
		return
	toggle_lights()

/obj/mecha/proc/toggle_internal_tank()
	internals_action.Trigger()

/obj/mecha/MouseDrop_T(mob/M, mob/user, params)
	if(frozen)
		to_chat(user, span_warning("Do not enter Admin-Frozen mechs."))
		return TRUE
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(user != M)
		return
	log_message("[user] tries to move in.")
	if(occupant)
		to_chat(user, span_warning("The [src] is already occupied!"))
		log_append_to_last("Permission denied.")
		return TRUE
	var/passed
	if(dna)
		if(ishuman(user))
			if(user.dna.unique_enzymes == dna)
				passed = TRUE
	else if(operation_allowed(user))
		passed = TRUE
	if(!passed)
		to_chat(user, span_warning("Access denied."))
		log_append_to_last("Permission denied.")
		return TRUE
	if(user.buckled)
		to_chat(user, span_warning("You are currently buckled and cannot move."))
		log_append_to_last("Permission denied.")
		return TRUE
	if(user.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("You can't enter the exosuit with other creatures attached to you!"))
		return TRUE

	visible_message(span_notice("[user] starts to climb into [src]"))
	INVOKE_ASYNC(src, TYPE_PROC_REF(/obj/mecha, put_in), user)
	return TRUE


/obj/mecha/proc/put_in(mob/user)
	if(do_after(user, mech_enter_time, src, category = DA_CAT_TOOL))
		if(obj_integrity <= 0)
			to_chat(user, span_warning("You cannot get in the [name], it has been destroyed!"))
		else if(occupant)
			to_chat(user, span_danger("[occupant] was faster! Try better next time, loser."))
		else if(user.buckled)
			to_chat(user, span_warning("You can't enter the exosuit while buckled."))
		else if(user.has_buckled_mobs())
			to_chat(user, span_warning("You can't enter the exosuit with other creatures attached to you!"))
		else
			moved_inside(user)
	else
		to_chat(user, span_warning("You stop entering the exosuit!"))


/obj/mecha/proc/moved_inside(mob/living/carbon/human/H)
	if(H && H.client && (H in range(1)))
		occupant = H
		H.forceMove(src)
		add_fingerprint(H)
		GrantActions(H, human_occupant = 1)
		forceMove(loc)
		log_append_to_last("[H] moved in as pilot.")
		update_icon(UPDATE_ICON_STATE)
		dir = dir_in
		playsound(src, 'sound/machines/windowdoor.ogg', 50, 1)
		if(!activated)
			occupant << sound(longactivationsound, volume = 50)
			activated = TRUE
		else if(!hasInternalDamage())
			occupant << sound(nominalsound, volume = 50)
		if(state)
			H.throw_alert("locked", /atom/movable/screen/alert/mech_maintenance)
		return TRUE
	else
		return FALSE

/obj/mecha/proc/mmi_move_inside(var/obj/item/mmi/mmi_as_oc as obj,mob/user as mob)
	if(!mmi_as_oc.brainmob || !mmi_as_oc.brainmob.client)
		to_chat(user, span_warning("Consciousness matrix not detected!"))
		return FALSE
	else if(mmi_as_oc.brainmob.stat)
		to_chat(user, span_warning("Beta-rhythm below acceptable level!"))
		return FALSE
	else if(occupant)
		to_chat(user, span_warning("Occupant detected!"))
		return FALSE
	else if(dna && dna != mmi_as_oc.brainmob.dna.unique_enzymes)
		to_chat(user, span_warning("Access denied. [name] is secured with a DNA lock."))
		return FALSE
	else if(!operation_allowed(user))
		to_chat(user, span_warning("Access denied. [name] is secured with an ID lock."))
		return FALSE

	if(do_after(user, 4 SECONDS, src))
		if(!occupant)
			return mmi_moved_inside(mmi_as_oc,user)
		else
			to_chat(user, span_warning("Occupant detected!"))
	else
		to_chat(user, span_notice("You stop inserting the MMI."))
	return FALSE

/obj/mecha/proc/mmi_moved_inside(obj/item/mmi/mmi_as_oc,mob/user)
	if(mmi_as_oc && (user in range(1)))
		if(!mmi_as_oc.brainmob || !mmi_as_oc.brainmob.client)
			to_chat(user, "Consciousness matrix not detected.")
			return FALSE
		else if(mmi_as_oc.brainmob.stat)
			to_chat(user, "Beta-rhythm below acceptable level.")
			return FALSE
		if(!user.drop_transfer_item_to_loc(mmi_as_oc, src))
			to_chat(user, span_notice("\the [mmi_as_oc] is stuck to your hand, you cannot put it in \the [src]."))
			return FALSE
		var/mob/living/carbon/brain/brainmob = mmi_as_oc.brainmob
		brainmob.reset_perspective(src)
		occupant = brainmob
		brainmob.forceMove(src) //should allow relaymove
		if(istype(mmi_as_oc, /obj/item/mmi/robotic_brain))
			var/obj/item/mmi/robotic_brain/R = mmi_as_oc
			if(R.imprinted_master)
				to_chat(brainmob, span_notice("Your imprint to [R.imprinted_master] has been temporarily disabled. You should help the crew and not commit harm."))
		mmi_as_oc.mecha = src
		Entered(mmi_as_oc)
		Move(loc)
		update_icon(UPDATE_ICON_STATE)
		dir = dir_in
		log_message("[mmi_as_oc] moved in as pilot.")
		if(!hasInternalDamage())
			SEND_SOUND(occupant, sound(nominalsound, volume=50))
		GrantActions(brainmob)
		return TRUE
	else
		return FALSE

/obj/mecha/proc/pilot_is_mmi()
	var/atom/movable/mob_container
	if(isbrain(occupant))
		var/mob/living/carbon/brain/brain = occupant
		mob_container = brain.container
	if(istype(mob_container, /obj/item/mmi))
		return TRUE
	return FALSE

/obj/mecha/Exited(atom/movable/departed, atom/newLoc)
	. = ..()
	if(occupant && occupant == departed) // The occupant exited the mech without calling go_out()
		go_out(TRUE, newLoc)

/obj/mecha/Exit(atom/movable/leaving, atom/newLoc)
	if(leaving in cargo)
		return FALSE
	return ..()

/obj/mecha/proc/go_out(forced, atom/newloc = loc)
	if(!occupant)
		return
	var/atom/movable/mob_container
	occupant.clear_alert("charge")
	occupant.clear_alert("locked")
	occupant.clear_alert("mech damage")
	occupant.clear_alert("mechaport")
	occupant.clear_alert("mechaport_d")
	if(occupant && occupant.client)
		occupant.client.mouse_pointer_icon = initial(occupant.client.mouse_pointer_icon)
	if(ishuman(occupant))
		mob_container = occupant
		RemoveActions(occupant, human_occupant = 1)
	else if(isbrain(occupant))
		var/mob/living/carbon/brain/brain = occupant
		RemoveActions(brain)
		mob_container = brain.container
	else if(isAI(occupant))
		var/mob/living/silicon/ai/AI = occupant
		//stop listening to this signal, as the static update is now handled by the eyeobj's setLoc
		AI.eyeobj?.UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
		AI.eyeobj?.forceMove(newloc) //kick the eye out as well
		if(forced)//This should only happen if there are multiple AIs in a round, and at least one is Malf.
			RemoveActions(occupant)
			if(!istype(newloc, /obj/item/aicard))
				occupant.gib()  //If one Malf decides to steal a mech from another AI (even other Malfs!), they are destroyed, as they have nowhere to go when replaced.
				occupant = null
			return
		else
			if(!AI.linked_core || QDELETED(AI.linked_core))
				to_chat(AI, span_userdanger("Inactive core destroyed. Unable to return."))
				AI.linked_core = null
				return
			to_chat(AI, span_notice("Returning to core..."))
			AI.controlled_mech = null
			AI.remote_control = null
			RemoveActions(occupant, 1)
			mob_container = AI
			newloc = get_turf(AI.linked_core)
			qdel(AI.linked_core)
	else
		return
	var/mob/living/L = occupant
	occupant = null //we need it null when forceMove calls Exited().
	if(mob_container.forceMove(newloc))//ejecting mob container
		log_message("[mob_container] moved out.")
		L << browse(null, "window=exosuit")

		if(istype(mob_container, /obj/item/mmi))
			var/obj/item/mmi/mmi = mob_container
			if(mmi.brainmob)
				L.forceMove(mmi)
				L.reset_perspective()
			mmi.mecha = null
			mmi.update_icon()
			if(istype(mmi, /obj/item/mmi/robotic_brain))
				var/obj/item/mmi/robotic_brain/R = mmi
				if(R.imprinted_master)
					to_chat(L, span_notice("Imprint re-enabled, you are once again bound to [R.imprinted_master]'s commands."))
		update_icon(UPDATE_ICON_STATE)
		dir = dir_in

	if(L && L.client)
		L.client.RemoveViewMod("mecha")
		zoom_mode = FALSE

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.regenerate_icons() // workaround for 14457

/obj/mecha/force_eject_occupant(mob/target)
	go_out()

/////////////////////////
////// Access stuff /////
/////////////////////////

/obj/mecha/proc/operation_allowed(mob/living/carbon/human/H)
	if(!ishuman(H))
		return FALSE
	for(var/ID in H.get_access_locations())
		if(check_access(ID, operation_req_access))
			return TRUE
	return FALSE


/obj/mecha/proc/internals_access_allowed(mob/living/carbon/human/H)
	for(var/atom/ID in H.get_access_locations())
		if(check_access(ID, internals_req_access))
			return TRUE
	return FALSE


/obj/mecha/check_access(obj/item/I, list/access_list)
	if(!istype(access_list))
		return TRUE
	if(!length(access_list)) //no requirements
		return TRUE
	if(!I || !I.GetID() || !I.GetAccess()) //not ID or no access
		return FALSE
	if(access_list==operation_req_access)
		for(var/req in access_list)
			if(!(req in I.GetAccess())) //doesn't have this access
				return FALSE
	else if(access_list==internals_req_access)
		for(var/req in access_list)
			if(req in I.GetAccess())
				return TRUE
	return TRUE

///////////////////////
///// Power stuff /////
///////////////////////

/obj/mecha/proc/has_charge(amount)
	return (get_charge()>=amount)

/obj/mecha/proc/get_charge()
	for(var/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/R in equipment)
		var/relay_charge = R.get_charge()
		if(relay_charge)
			return relay_charge
	if(cell)
		return max(0, cell.charge)

/obj/mecha/proc/use_power(amount)
	if(get_charge())
		cell.use(amount)
		if(occupant)
			update_cell()
		return TRUE
	return FALSE

/obj/mecha/proc/give_power(amount)
	if(!isnull(get_charge()))
		cell.give(amount)
		if(occupant)
			update_cell()
		return TRUE
	return FALSE

/obj/mecha/proc/update_cell()
	if(cell)
		var/cellcharge = cell.charge/cell.maxcharge
		switch(cellcharge)
			if(0.75 to INFINITY)
				occupant.clear_alert("charge")
			if(0.5 to 0.75)
				occupant.throw_alert("charge", /atom/movable/screen/alert/mech_lowcell, 1)
			if(0.25 to 0.5)
				occupant.throw_alert("charge", /atom/movable/screen/alert/mech_lowcell, 2)
				if(power_warned)
					power_warned = FALSE
			if(0.01 to 0.25)
				occupant.throw_alert("charge", /atom/movable/screen/alert/mech_lowcell, 3)
				if(!power_warned)
					occupant << sound(lowpowersound, volume = 50)
					power_warned = TRUE
			else
				occupant.throw_alert("charge", /atom/movable/screen/alert/mech_emptycell)
	else
		occupant.throw_alert("charge", /atom/movable/screen/alert/mech_nocell)


//////////////////////////////////////////
////////  Mecha global iterators  ////////
//////////////////////////////////////////

/obj/mecha/process()
	process_internal_damage()
	regulate_temp()
	give_air()
	update_huds()

/obj/mecha/proc/process_internal_damage()
	if(!internal_damage)
		return

	if(internal_damage & MECHA_INT_FIRE)
		if(!(internal_damage & MECHA_INT_TEMP_CONTROL) && prob(5))
			clearInternalDamage(MECHA_INT_FIRE)
		if(internal_tank)
			var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
			if(int_tank_air.return_pressure() > internal_tank.maximum_pressure && !(internal_damage & MECHA_INT_TANK_BREACH))
				setInternalDamage(MECHA_INT_TANK_BREACH)

			if(int_tank_air && int_tank_air.return_volume() > 0)
				int_tank_air.temperature = min(6000 + T0C, cabin_air.return_temperature() + rand(10, 15))

			if(cabin_air && cabin_air.return_volume()>0)
				cabin_air.temperature = min(6000+T0C, cabin_air.return_temperature()+rand(10,15))
				if(cabin_air.return_temperature() > max_temperature/2)
					take_damage(4/round(max_temperature/cabin_air.return_temperature(),0.1), BURN, 0, 0)

	if(internal_damage & MECHA_INT_TANK_BREACH) //remove some air from internal tank
		if(internal_tank)
			var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
			var/datum/gas_mixture/leaked_gas = int_tank_air.remove_ratio(0.10)
			if(loc)
				loc.assume_air(leaked_gas)
				air_update_turf()
			else
				qdel(leaked_gas)

	if(internal_damage & MECHA_INT_SHORT_CIRCUIT)
		if(get_charge())
			spark_system.start()
			cell.charge -= min(20,cell.charge)
			cell.maxcharge -= min(20,cell.maxcharge)

/obj/mecha/proc/regulate_temp()
	if(internal_damage & MECHA_INT_TEMP_CONTROL)
		return

	if(cabin_air && cabin_air.return_volume() > 0)
		var/delta = cabin_air.temperature - T20C
		cabin_air.temperature -= max(-10, min(10, round(delta / 4, 0.1)))

/obj/mecha/proc/give_air()
	if(!internal_tank)
		return

	var/datum/gas_mixture/tank_air = internal_tank.return_air()

	var/release_pressure = internal_tank_valve
	var/cabin_pressure = cabin_air.return_pressure()
	var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
	var/transfer_moles = 0
	if(pressure_delta > 0) //cabin pressure lower than release pressure
		if(tank_air.return_temperature() > 0)
			transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
			cabin_air.merge(removed)
	else if(pressure_delta < 0) //cabin pressure higher than release pressure
		var/datum/gas_mixture/t_air = return_air()
		pressure_delta = cabin_pressure - release_pressure
		if(t_air)
			pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)
		if(pressure_delta > 0) //if location pressure is lower than cabin pressure
			transfer_moles = pressure_delta*cabin_air.return_volume()/(cabin_air.return_temperature() * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
			if(t_air)
				t_air.merge(removed)
			else //just delete the cabin gas, we're in space or some shit
				qdel(removed)

/obj/mecha/proc/update_huds()
	diag_hud_set_mechhealth()
	diag_hud_set_mechcell()
	diag_hud_set_mechstat()
	diag_hud_set_mechtracking()


/obj/mecha/speech_bubble(bubble_state = "", bubble_loc = src, list/bubble_recipients = list())
	var/image/I = image('icons/mob/talk.dmi', bubble_loc, bubble_state, FLY_LAYER)
	SET_PLANE_EXPLICIT(I, ABOVE_GAME_PLANE, src)
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	INVOKE_ASYNC(GLOBAL_PROC, /proc/flick_overlay, I, bubble_recipients, 30)

/obj/mecha/update_remote_sight(mob/living/user)
	if(occupant_sight_flags)
		if(user == occupant)
			user.add_sight(occupant_sight_flags)

	..()

/obj/mecha/do_attack_animation(atom/A, visual_effect_icon, obj/item/used_item, no_effect)
	if(!no_effect)
		if(selected)
			used_item = selected
		else if(!visual_effect_icon)
			visual_effect_icon = ATTACK_EFFECT_SMASH
			if(damtype == BURN)
				visual_effect_icon = ATTACK_EFFECT_MECHFIRE
			else if(damtype == TOX)
				visual_effect_icon = ATTACK_EFFECT_MECHTOXIN
	..()

/obj/mecha/obj_destruction()
	if(wreckage)
		var/mob/living/silicon/ai/AI
		if(isAI(occupant))
			AI = occupant
			occupant = null
		var/obj/structure/mecha_wreckage/WR = new wreckage(loc, AI)
		for(var/obj/item/mecha_parts/mecha_equipment/E in equipment)
			if(E.salvageable && prob(30))
				WR.crowbar_salvage += E
				E.detach(WR) //detaches from src into WR
				E.equip_ready = TRUE
			else
				E.detach(loc)
				qdel(E)
		if(cell)
			WR.crowbar_salvage += cell
			cell.forceMove(WR)
			cell.charge = rand(0, cell.charge)
			cell = null
		if(internal_tank)
			WR.crowbar_salvage += internal_tank
			internal_tank.forceMove(WR)
			internal_tank = null
	. = ..()

/obj/mecha/CtrlClick(mob/living/L)
	if(occupant != L || !istype(L))
		return ..()

	var/list/choices = list("Cancel / No Change" = mutable_appearance(icon = 'icons/mob/screen_gen.dmi', icon_state = "x"))
	var/list/choices_to_refs = list()

	for(var/obj/item/mecha_parts/mecha_equipment/MT in equipment)
		if(!MT.selectable || selected == MT)
			continue
		var/mutable_appearance/clean/MA = new(MT)
		choices[MT.name] = MA
		choices_to_refs[MT.name] = MT

	var/choice = show_radial_menu(L, src, choices, radius = 48, custom_check = CALLBACK(src, PROC_REF(check_menu), L))
	if(!check_menu(L) || choice == "Cancel / No Change")
		return

	var/obj/item/mecha_parts/mecha_equipment/chosen_module = LAZYACCESS(choices_to_refs, choice)
	if(!istype(chosen_module))
		return

	switch(chosen_module.selectable)
		if(MODULE_SELECTABLE_FULL)
			chosen_module.select_module()
		if(MODULE_SELECTABLE_TOGGLE)
			chosen_module.toggle_module()

/obj/mecha/proc/check_menu(mob/living/L)
	if(L != occupant || !istype(L))
		return FALSE
	if(L.incapacitated())
		return FALSE
	return TRUE


/obj/mecha/update_icon_state()
	var/init_icon_state = initial_icon ? initial_icon : initial(icon_state)
	icon_state = occupant ? init_icon_state : "[init_icon_state]-open"


#undef OCCUPANT_LOGGING
