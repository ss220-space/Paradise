// Teleporter, Wormhole generator, Gravitational catapult, Armor booster modules,
// Repair droid, Tesla Energy relay, Generators, SCS-3 Cage

////////////////////////////////////////////// TELEPORTER ///////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/teleporter
	name = "mounted teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view."
	icon_state = "mecha_teleport"
	origin_tech = "bluespace=7"
	equip_cooldown = 15 SECONDS
	energy_drain = 4000
	range = MECHA_RANGED
	var/tele_precision = 4

/obj/item/mecha_parts/mecha_equipment/teleporter/action(atom/target)
	if(!action_checks(target) || !is_teleport_allowed(loc.z))
		return FALSE
	if(!is_faced_target(target))
		return FALSE
	var/turf/T = get_turf(target)
	if(!T)
		return FALSE
	chassis.use_power(energy_drain)
	var/turf/user_turf = get_turf(src)
	do_teleport(chassis, T, tele_precision)
	chassis.investigate_log("[key_name_log(chassis.occupant)] mecha-teleported from [COORD(user_turf)] to [COORD(chassis)].", INVESTIGATE_TELEPORTATION)
	start_cooldown()

/obj/item/mecha_parts/mecha_equipment/teleporter/precise
	name = "upgraded teleporter"
	desc = "An exosuit module that allows exosuits to teleport to any position in view. This is the high-precision, energy-efficient version."
	origin_tech = "bluespace=7"
	energy_drain = 1000
	tele_precision = 1


////////////////////////////////////////////// WORMHOLE GENERATOR //////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/wormhole_generator
	name = "mounted wormhole generator"
	desc = "An exosuit module that allows generating of small quasi-stable wormholes."
	icon_state = "mecha_wholegen"
	origin_tech = "bluespace=4;magnets=4;plasmatech=2"
	equip_cooldown = 5 SECONDS
	energy_drain = 300
	range = MECHA_RANGED

/obj/item/mecha_parts/mecha_equipment/wormhole_generator/action(atom/target)
	if(!action_checks(target) || !is_teleport_allowed(loc.z))
		return FALSE
	if(!is_faced_target(target))
		return FALSE
	var/list/theareas = get_areas_in_range(100, chassis)
	if(!theareas.len)
		return FALSE
	var/area/thearea = pick(theareas)
	var/list/L = list()
	var/turf/pos = get_turf(src)
	for(var/turf/T in get_area_turfs(thearea.type))
		if(!T.density && pos.z == T.z)
			var/clear = TRUE
			for(var/obj/O in T)
				if(O.density)
					clear = FALSE
					break
			if(clear)
				L+=T
	if(!L.len)
		return FALSE
	var/turf/target_turf = pick(L)
	if(!target_turf)
		return FALSE
	var/obj/effect/portal/P = new /obj/effect/portal(get_turf(target), target_turf)
	P.icon = 'icons/obj/objects.dmi'
	P.failchance = 0
	P.icon_state = "anom"
	P.name = "wormhole"
	message_admins("[ADMIN_LOOKUPFLW(chassis.occupant)] used a Wormhole Generator in [ADMIN_COORDJMP(loc)]")
	add_game_logs("used a Wormhole Generator in [COORD(loc)]", chassis.occupant)
	chassis.investigate_log("[key_name_log(chassis.occupant)] used a Wormhole Generator at [COORD(loc)].", INVESTIGATE_TELEPORTATION)

	start_cooldown()
	spawn(rand(150,300))
		qdel(P)

/////////////////////////////////////// GRAVITATIONAL CATAPULT ///////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/gravcatapult
	name = "mounted gravitational catapult"
	desc = "An exosuit mounted Gravitational Catapult."
	icon_state = "mecha_teleport"
	origin_tech = "bluespace=3;magnets=3;engineering=4"
	equip_cooldown = 3 SECONDS
	energy_drain = 100
	range = MECHA_MELEE | MECHA_RANGED
	var/atom/movable/locked
	var/mode = 1 //1 - gravsling 2 - gravpush

/obj/item/mecha_parts/mecha_equipment/gravcatapult/action(atom/movable/target)
	if(!action_checks(target))
		return FALSE
	if(!is_faced_target(target))
		return FALSE
	equip_cooldown = (initial(equip_cooldown) * mode)
	switch(mode)
		if(1)
			if(!locked)
				if(!istype(target) || target.anchored || istype(target, /obj/mecha))
					occupant_message("Unable to lock on [target]")
					return FALSE
				locked = target
				occupant_message("Locked on [target]")
				send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
			else if(target != locked)
				if(locked in view(chassis))
					locked.throw_at(target, 14, 1.5)
					locked = null
					send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
					start_cooldown()
				else
					occupant_message("Lock on [locked] disengaged.")
					locked = null
					send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
		if(2)
			var/list/atoms = list()
			if(isturf(target))
				atoms = range(3, target)
			else
				atoms = orange(3, target)
			for(var/atom/movable/A in atoms)
				if(A.anchored || A.move_resist == INFINITY)
					continue
				spawn(0)
					var/iter = 5-get_dist(A,target)
					for(var/i=0 to iter)
						step_away(A,target)
						sleep(2)
			var/turf/T = get_turf(target)
			add_game_logs("used a Gravitational Catapult in [COORD(T)]", chassis.occupant)
			start_cooldown()


/obj/item/mecha_parts/mecha_equipment/gravcatapult/get_module_equip_info()
	return " [mode==1?"([locked||"Nothing"])":null] \[<a href='byond://?src=[UID()];mode=1'>S</a>|<a href='byond://?src=[UID()];mode=2'>P</a>\]"

/obj/item/mecha_parts/mecha_equipment/gravcatapult/Topic(href, href_list)
	..()
	if(href_list["mode"])
		mode = text2num(href_list["mode"])
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
	return

//////////////////////////// ARMOR BOOSTER MODULES //////////////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster //what is that noise? A BAWWW from TK mutants.
	name = "Armor Booster Module (Close Combat Weaponry)"
	desc = "Boosts exosuit armor against armed melee attacks. Requires energy to operate."
	icon_state = "mecha_abooster_ccw"
	origin_tech = "materials=4;combat=4"
	equip_cooldown = 1 SECONDS
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8
	selectable = MODULE_SELECTABLE_NONE

/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster/proc/attack_react(mob/user)
	if(action_checks(user))
		start_cooldown()
	return TRUE


/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	name = "Armor Booster Module (Ranged Weaponry)"
	desc = "Boosts exosuit armor against ranged attacks. Completely blocks taser shots. Requires energy to operate."
	icon_state = "mecha_abooster_proj"
	origin_tech = "materials=4;combat=3;engineering=3"
	equip_cooldown = 1 SECONDS
	energy_drain = 50
	range = 0
	var/deflect_coeff = 1.15
	var/damage_coeff = 0.8
	selectable = MODULE_SELECTABLE_NONE

/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster/proc/projectile_react()
	if(action_checks(src))
		start_cooldown()
		return TRUE


////////////////////////////////// REPAIR DROID //////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/repair_droid
	name = "repair droid"
	desc = "Automated repair droid. Scans exosuit for damage and repairs it. Can fix almost all types of external or internal damage."
	icon_state = "repair_droid"
	origin_tech ="magnets=3;programming=3;engineering=4"
	equip_cooldown = 2 SECONDS
	energy_drain = 50
	range = 0
	var/active_mode = FALSE
	var/health_boost = 1
	var/icon/droid_overlay
	var/list/repairable_damage = list(MECHA_INT_TEMP_CONTROL,MECHA_INT_TANK_BREACH)
	selectable = MODULE_SELECTABLE_TOGGLE

/obj/item/mecha_parts/mecha_equipment/repair_droid/Destroy()
	STOP_PROCESSING(SSobj, src)
	chassis?.cut_overlay(droid_overlay)
	return ..()

/obj/item/mecha_parts/mecha_equipment/repair_droid/attach_act(obj/mecha/M)
	droid_overlay = new(icon, icon_state = "repair_droid")
	M.add_overlay(droid_overlay)

/obj/item/mecha_parts/mecha_equipment/repair_droid/detach_act()
	chassis.cut_overlay(droid_overlay)
	STOP_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/repair_droid/get_module_equip_info()
	return " <a href='byond://?src=[UID()];toggle_repairs=1'>[!active_mode?"A":"Dea"]ctivate</a>"

/obj/item/mecha_parts/mecha_equipment/repair_droid/Topic(href, href_list)
	..()
	if(href_list["toggle_repairs"])
		toggle_module()

/obj/item/mecha_parts/mecha_equipment/repair_droid/toggle_module()
	if(!action_checks(src))
		return
	chassis.cut_overlay(droid_overlay)
	if(!active_mode)
		START_PROCESSING(SSobj, src)
		droid_overlay = new(icon, icon_state = "repair_droid_a")
		log_message("Droid activated.")
	else
		STOP_PROCESSING(SSobj, src)
		droid_overlay = new(icon, icon_state = "repair_droid")
		log_message("Droid deactivated.")
	active_mode = !active_mode
	chassis.add_overlay(droid_overlay)
	send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
	start_cooldown()

/obj/item/mecha_parts/mecha_equipment/repair_droid/process()
	if(!chassis)
		STOP_PROCESSING(SSobj, src)
		active_mode = FALSE
		return
	var/h_boost = health_boost
	var/repaired = FALSE
	if(chassis.internal_damage & MECHA_INT_SHORT_CIRCUIT)
		h_boost *= -2
	else if(chassis.internal_damage && prob(15))
		for(var/int_dam_flag in repairable_damage)
			if(chassis.internal_damage & int_dam_flag)
				chassis.clearInternalDamage(int_dam_flag)
				repaired = TRUE
				break
	if(h_boost < 0 || chassis.obj_integrity < chassis.max_integrity)
		chassis.obj_integrity += min(h_boost, chassis.max_integrity-chassis.obj_integrity)
		repaired = TRUE
	if(repaired)
		if(!chassis.use_power(energy_drain))
			STOP_PROCESSING(SSobj, src)
			active_mode = FALSE
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
	else //no repair needed, we turn off
		STOP_PROCESSING(SSobj, src)
		active_mode = FALSE
		send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())
		chassis.cut_overlay(droid_overlay)
		droid_overlay = new(icon, icon_state = "repair_droid")
		chassis.add_overlay(droid_overlay)

/////////////////////////////////// TESLA ENERGY RELAY ////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay
	name = "exosuit energy relay"
	desc = "An exosuit module that wirelessly drains energy from any available power channel in area. The performance index is quite low."
	icon_state = "tesla"
	origin_tech = "magnets=4;powerstorage=4;engineering=4"
	energy_drain = 0
	range = 0
	var/coeff = 100
	var/list/use_channels = list(EQUIP, ENVIRON, LIGHT)
	selectable = MODULE_SELECTABLE_TOGGLE

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/detach_act()
	STOP_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/get_charge()
	if(equip_ready) //disabled
		return
	var/area/A = get_area(chassis)
	var/pow_chan = get_power_channel(A)
	if(pow_chan)
		return 1000 //making magic


/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/proc/get_power_channel(area/A)
	var/pow_chan
	if(A)
		for(var/c in use_channels)
			if(A.powered(c))
				pow_chan = c
				break
	return pow_chan

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/Topic(href, href_list)
	..()
	if(href_list["toggle_relay"])
		toggle_module()

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/toggle_module()
	if(equip_ready) //inactive
		START_PROCESSING(SSobj, src)
		set_ready_state(FALSE)
		log_message("Activated.")
	else
		STOP_PROCESSING(SSobj, src)
		set_ready_state(TRUE)
		log_message("Deactivated.")

/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/get_module_equip_info()
	return " <a href='byond://?src=[UID()];toggle_relay=1'>[equip_ready?"A":"Dea"]ctivate</a>"


/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay/process()
	if(!chassis || chassis.internal_damage & MECHA_INT_SHORT_CIRCUIT)
		STOP_PROCESSING(SSobj, src)
		set_ready_state(TRUE)
		return
	var/cur_charge = chassis.get_charge()
	if(isnull(cur_charge) || !chassis.cell)
		STOP_PROCESSING(SSobj, src)
		set_ready_state(TRUE)
		occupant_message("No powercell detected.")
		return
	if(cur_charge < chassis.cell.maxcharge)
		var/area/A = get_area(chassis)
		if(A)
			var/pow_chan
			for(var/c in list(EQUIP,ENVIRON,LIGHT))
				if(A.powered(c))
					pow_chan = c
					break
			if(pow_chan)
				var/delta = min(20, chassis.cell.maxcharge-cur_charge)
				chassis.give_power(delta)
				A.use_power(delta*coeff, pow_chan)

/////////////////////////////////////////// GENERATOR /////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/generator
	name = "exosuit plasma converter"
	desc = "An exosuit module that generates power using solid plasma as fuel. Pollutes the environment."
	icon_state = "tesla"
	origin_tech = "plasmatech=2;powerstorage=2;engineering=2"
	range = MECHA_MELEE
	var/coeff = 100
	var/fuel_type = MAT_PLASMA
	var/max_fuel = 150000
	var/fuel_name = "plasma" // Our fuel name as a string
	var/fuel_amount = 0
	var/fuel_per_cycle_idle = 10
	var/fuel_per_cycle_active = 100
	var/power_per_cycle = 30


/obj/item/mecha_parts/mecha_equipment/generator/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/mecha_parts/mecha_equipment/generator/detach_act()
	STOP_PROCESSING(SSobj, src)

/obj/item/mecha_parts/mecha_equipment/generator/Topic(href, href_list)
	..()
	if(href_list["toggle"])
		if(equip_ready) //inactive
			set_ready_state(FALSE)
			START_PROCESSING(SSobj, src)
			log_message("Activated.")
		else
			set_ready_state(TRUE)
			STOP_PROCESSING(SSobj, src)
			log_message("Deactivated.")

/obj/item/mecha_parts/mecha_equipment/generator/get_module_equip_info()
	return " \[[fuel_name]: [round(fuel_amount,0.1)] cm<sup>3</sup>\] - <a href='byond://?src=[UID()];toggle=1'>[equip_ready?"A":"Dea"]ctivate</a>"

/obj/item/mecha_parts/mecha_equipment/generator/action(target)
	if(chassis)
		var/result = load_fuel(target)
		if(result)
			send_byjax(chassis.occupant,"exosuit.browser","\ref[src]",get_equip_info())

/obj/item/mecha_parts/mecha_equipment/generator/proc/load_fuel(obj/item/I)
	if(istype(I) && (fuel_type in I.materials))
		if(istype(I, /obj/item/stack/sheet))
			var/obj/item/stack/sheet/P = I
			var/to_load = max(max_fuel - fuel_amount, 0)
			if(to_load)
				var/units = min(max(round(to_load / P.perunit),1),P.amount)
				if(units)
					var/added_fuel = units * P.perunit
					fuel_amount = min(fuel_amount + added_fuel, max_fuel)
					P.use(units)
					occupant_message("[units] unit\s of [fuel_name] successfully loaded.")
					return added_fuel
			else
				occupant_message("Unit is full.")
				return FALSE
		else // Some other object containing our fuel's type, so we just eat it (ores mainly)
			var/to_load = max(min(I.materials[fuel_type], max_fuel - fuel_amount),0)
			if(to_load)
				fuel_amount += to_load
				qdel(I)
				return to_load

	else if(istype(I, /obj/structure/ore_box))
		var/fuel_added = 0
		for(var/baz in I.contents)
			var/obj/item/O = baz
			if(fuel_type in O.materials)
				fuel_added = load_fuel(O)
				break
		return fuel_added

	else
		occupant_message(span_warning("[fuel_name] traces in target minimal! [I] cannot be used as fuel."))
		return FALSE


/obj/item/mecha_parts/mecha_equipment/generator/attackby(obj/item/I, mob/user, params)
	if(load_fuel(I))
		return ATTACK_CHAIN_BLOCKED_ALL
	return ..()


/obj/item/mecha_parts/mecha_equipment/generator/critfail()
	..()
	var/turf/simulated/T = get_turf(src)
	if(!istype(T))
		return
	var/datum/gas_mixture/GM = new
	if(prob(10))
		GM.toxins += 100
		GM.temperature = 1500+T0C //should be enough to start a fire
		T.visible_message("[src] suddenly disgorges a cloud of heated plasma.")
		qdel(src)
	else
		GM.toxins += 5
		GM.temperature = istype(T) ? T.air.return_temperature() : T20C
		T.visible_message("[src] suddenly disgorges a cloud of plasma.")
	T.assume_air(GM)

/obj/item/mecha_parts/mecha_equipment/generator/process()
	if(!chassis)
		STOP_PROCESSING(SSobj, src)
		set_ready_state(TRUE)
		return
	if(fuel_amount<=0)
		STOP_PROCESSING(SSobj, src)
		log_message("Deactivated - no fuel.")
		set_ready_state(TRUE)
		return
	var/cur_charge = chassis.get_charge()
	if(isnull(cur_charge))
		set_ready_state(TRUE)
		occupant_message("No powercell detected.")
		log_message("Deactivated.")
		STOP_PROCESSING(SSobj, src)
		return
	var/use_fuel = fuel_per_cycle_idle
	if(cur_charge < chassis.cell.maxcharge)
		use_fuel = fuel_per_cycle_active
		chassis.give_power(power_per_cycle)
	fuel_amount -= min(use_fuel, fuel_amount)
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/generator/nuclear
	name = "exonuclear reactor"
	desc = "An exosuit module that generates power using uranium as fuel. Pollutes the environment."
	icon_state = "tesla"
	origin_tech = "powerstorage=4;engineering=4"
	fuel_name = "uranium" // Our fuel name as a string
	fuel_type = MAT_URANIUM
	max_fuel = 50000
	fuel_per_cycle_idle = 10
	fuel_per_cycle_active = 30
	power_per_cycle = 50
	var/rad_per_cycle = 0.3

/obj/item/mecha_parts/mecha_equipment/generator/nuclear/critfail()
	return

/obj/item/mecha_parts/mecha_equipment/generator/nuclear/process()
	if(..())
		for(var/mob/living/carbon/M in view(chassis))
			M.apply_effect((rad_per_cycle * 3), IRRADIATE, 0)

/////////////////////////////////// SERVO-HYDRAULIC ACTUATOR ////////////////////////////////////////////////

/obj/item/mecha_parts/mecha_equipment/servo_hydra_actuator
	name = "Servo-Hydraulic Actuator"
	desc = "Boosts exosuit servo-motors, allowing it to activate strafe mode. Requires energy to operate."
	icon_state = "actuator"
	origin_tech = "powerstorage=5;programming=5;engineering=5;combat=5"
	selectable = MODULE_SELECTABLE_NONE
	var/energy_per_step = 50 //How much energy this module drains per step in strafe mode

/obj/item/mecha_parts/mecha_equipment/servo_hydra_actuator/can_attach(obj/mecha/M)
	if(M.strafe_allowed)
		return FALSE
	. = ..()

/obj/item/mecha_parts/mecha_equipment/servo_hydra_actuator/attach_act(obj/mecha/M)
	M.strafe_allowed = TRUE
	M.actuator = src
	if(M.occupant)
		M.strafe_action.Grant(M.occupant, M)

/obj/item/mecha_parts/mecha_equipment/servo_hydra_actuator/detach_act()
	chassis.strafe_allowed = FALSE
	chassis.strafe = FALSE
	chassis.actuator = null
	if(chassis.occupant)
		chassis.strafe_action.Remove(chassis.occupant)

/obj/item/mecha_parts/mecha_equipment/servo_hydra_actuator/Destroy()
	if(chassis)
		chassis.strafe_allowed = FALSE
		chassis.strafe = FALSE
		chassis.actuator = null
		if(chassis.occupant)
			chassis.strafe_action.Remove(chassis.occupant)
	. = ..()

//LEG UPGRADE

/obj/item/mecha_parts/mecha_equipment/improved_exosuit_control_system
	name = "improved exosuit control system"
	desc = "Equipment for exosuits. A system that provides more precise control of exosuit movement. In other words - Gotta go fast!"
	icon = 'icons/obj/mecha/mecha_equipment.dmi'
	icon_state = "move_plating"
	origin_tech = "materials=5;engineering=5;magnets=4;powerstorage=4"
	energy_drain = 20
	selectable = MODULE_SELECTABLE_NONE
	var/ripley_step_in = 2.5
	var/odyss_step_in = 1.8
	var/clarke_step_in = 1.5
	var/durand_step_in = 3.3
	var/locker_step_in = 2

/obj/item/mecha_parts/mecha_equipment/improved_exosuit_control_system/can_attach(obj/mecha/M)
	if(..())
		if(istype(M, /obj/mecha/medical) || istype(M, /obj/mecha/combat/lockersyndie) || istype(M, /obj/mecha/working) || istype(M, /obj/mecha/combat/durand))
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/improved_exosuit_control_system/attach_act()
	if(istype(loc, /obj/mecha/working/ripley)) // for ripley/firefighter
		var/obj/mecha/working/ripley/R = loc
		R.slow_pressure_step_in = ripley_step_in
	if(istype(loc, /obj/mecha/medical/odysseus)) // odyss
		var/obj/mecha/medical/odysseus/O = loc
		O.step_in = odyss_step_in
	if(istype(loc, /obj/mecha/working/clarke)) // clerke
		var/obj/mecha/working/clarke/K = loc
		K.fast_pressure_step_in = clarke_step_in  // that's why
	if(istype(loc, /obj/mecha/combat/durand)) // dura
		var/obj/mecha/combat/durand/D = loc
		D.step_in = durand_step_in
	if(istype(loc, /obj/mecha/combat/lockersyndie)) // syndilocker
		var/obj/mecha/combat/lockersyndie/L = loc
		L.step_in = locker_step_in

/obj/item/mecha_parts/mecha_equipment/improved_exosuit_control_system/detach_act()
	if(ismecha(loc))
		var/obj/mecha/O = loc
		O.step_in = initial(O.step_in)
	if(istype(loc, /obj/mecha/working))
		var/obj/mecha/working/W = loc
		W.slow_pressure_step_in = initial(W.slow_pressure_step_in)
		W.fast_pressure_step_in = initial(W.fast_pressure_step_in)



// SCS-3 CAGE

/obj/item/mecha_parts/mecha_equipment/cage
	name = "SCS 3 Cage"
	desc = "Модуль для экзокостюмов, используемый для задержании преступников."
	ru_names = list(
	    NOMINATIVE = "модуль \"Клетка SCS-3\"",
	    GENITIVE = "модуля \"Клетка SCS-3\"",
	    DATIVE = "модулю \"Клетка SCS-3\"",
	    ACCUSATIVE = "модуль \"Клетка SCS-3\"",
	    INSTRUMENTAL = "модулем \"Клетка SCS-3\"",
	    PREPOSITIONAL = "модулю \"Клетка SCS-3\""
	)
	icon_state = "mecha_cage"
	origin_tech = "combat=6;materials=5"
	equip_cooldown = 3 SECONDS
	energy_drain = 500
	range = MECHA_MELEE
	salvageable = FALSE
	harmful = FALSE
	alert_category = "mecha_cage"

	var/mob/living/carbon/prisoner
	var/mob/living/carbon/holding
	///for custom icons
	var/datum/action/innate/mecha/select_module/button
	///wacky case
	var/current_stage
	var/obj/effect/supress/supress_effect

/obj/item/mecha_parts/mecha_equipment/cage/can_attach(obj/mecha/M)
	if(..())
		if(locate(src) in M.equipment)
			return FALSE
		if(istype(M, /obj/mecha/combat/gygax) || istype(M, /obj/mecha/combat/durand) || istype(M, /obj/mecha/combat/lockersyndie) || istype(M, /obj/mecha/combat/marauder))
			return TRUE
		else if(M.emagged == TRUE)
			return TRUE
	return FALSE

/obj/item/mecha_parts/mecha_equipment/cage/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(get_turf(src))
		if(holding)
			stop_supressing(holding)

	prisoner = null
	holding = null
	return ..()

/obj/item/mecha_parts/mecha_equipment/cage/select_set_alert()
	. = ..()
	if(!.)
		if(prisoner)
			change_alert(CAGE_STAGE_THREE)
		else if(holding)
			if(!holding.handcuffed)
				change_alert(CAGE_STAGE_ONE)
			else
				change_alert(CAGE_STAGE_TWO)
		else
			change_alert(CAGE_STAGE_ZERO)

/obj/item/mecha_parts/mecha_equipment/cage/action(mob/living/carbon/target)
	if(!action_checks(target))
		return FALSE
	if(!istype(target))
		return FALSE

	var/same_target = target == holding
	var/supress_check = target.IsStamcrited() || (target.health <= HEALTH_THRESHOLD_CRIT) || target.stat != CONSCIOUS

	//SUPRESSING
	if(((holding && !same_target) || !holding) && supress_check)
		supress_action(target)
		return TRUE

	//HANDCUFFING
	if(same_target && !target.handcuffed)
		handcuff_action(target)
		return TRUE

	//PUTTING INTO MECH
	if(same_target && target.handcuffed)
		insert_action(target)
		return TRUE

	occupant_message(span_notice("[target] не мо[pluralize_ru(target.gender, "жет", "гут")] быть удержа[genderize_ru(target.gender, "н", "на", "но", "ны")], так как [target] не наход[pluralize_ru(target.gender, "ит", "ят")]ся в критическом состоянии."))
	return FALSE

/obj/item/mecha_parts/mecha_equipment/cage/proc/supress_action(mob/living/carbon/target)
	if(holding)
		occupant_message(span_notice("Вы перестаёте удерживать [holding], и начинаете удерживать [target]..."))
		chassis.visible_message(span_warning("[capitalize(chassis.declent_ru(NOMINATIVE))] перестаёт удерживать [holding] и начинает удерживать [target]."))
		stop_supressing(holding)
	else
		occupant_message(span_notice("Вы начинаете удерживать [target]..."))
		chassis.visible_message(span_warning(span_warning("[capitalize(chassis.declent_ru(NOMINATIVE))] начинает удерживать [target].")))

	set_supress_effect(target)
	if(!do_after_cooldown(target))
		qdel(supress_effect)
		supress_effect = null
		return FALSE
	if(!prisoner)
		change_alert(CAGE_STAGE_ONE)
	supress(target)

/obj/item/mecha_parts/mecha_equipment/cage/proc/handcuff_action(mob/living/carbon/target)
	occupant_message(span_notice("Вы начинаете сковывать [target]..."))
	chassis.visible_message(span_warning("[capitalize(chassis.declent_ru(NOMINATIVE))] начинает сковывать [target]."))
	if(!do_after_cooldown(target))
		return FALSE
	if(!prisoner)
		change_alert(CAGE_STAGE_TWO)
	target.apply_restraints(new /obj/item/restraints/handcuffs, ITEM_SLOT_HANDCUFFED, TRUE)
	occupant_message(span_notice("Вы успешно сковали [target]..."))
	chassis.visible_message(span_warning("[capitalize(chassis.declent_ru(NOMINATIVE))] успешно сковал [target]."))
	add_attack_logs(chassis.occupant, target, "shackled")

/obj/item/mecha_parts/mecha_equipment/cage/proc/insert_action(mob/living/carbon/target)
	if(!prisoner_insertion_check(target))
		return FALSE
	if(!button)
		for(var/datum/action/innate/mecha/select_module/H in chassis.occupant.actions)
			if(H.button_icon_state == "mecha_cage")
				button = H
				break

	change_state("mecha_cage_activate")
	occupant_message(span_notice("Вы начинаете помещать [target] внутрь клетки..."))
	chassis.visible_message(span_warning("[capitalize(chassis.declent_ru(NOMINATIVE))] начинает помещать [target] внутрь клетки."))
	if(!do_after_cooldown(target))
		change_state("mecha_cage")
		return FALSE
	change_state("mecha_cage_activated")
	change_alert(CAGE_STAGE_THREE)
	prisoner = target
	target.forceMove(src)
	stop_supressing(target)
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_escape))
	update_equip_info()
	occupant_message(span_notice("[target] успешно помещ[genderize_ru(target.gender, "ён", "ена", "ено", "ены")] в клетку."))
	chassis.visible_message(span_warning("[capitalize(chassis.declent_ru(NOMINATIVE))] поместил [target] в клетку."))
	log_message("[target] loaded in SCS-3 Cage.")

/obj/item/mecha_parts/mecha_equipment/cage/proc/supress(mob/living/carbon/target)
	RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	add_attack_logs(chassis.occupant, target, "started supressing with SCS-3 Cage")
	holding = target
	target.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_FLOORED), MECH_SUPRESSED_TRAIT)
	target.move_resist = MOVE_FORCE_STRONG
	supress_effect.icon_state = "applied"

/obj/item/mecha_parts/mecha_equipment/cage/proc/stop_supressing(mob/living/carbon/target)
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	add_attack_logs(chassis.occupant, target, "stopped supressing with SCS-3 Cage")
	holding = null
	target.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_FLOORED), MECH_SUPRESSED_TRAIT)
	target.move_resist = MOVE_FORCE_DEFAULT
	qdel(supress_effect)
	supress_effect = null

	if(!prisoner)
		change_alert(CAGE_STAGE_ZERO)

/obj/item/mecha_parts/mecha_equipment/cage/proc/on_moved(mob/living/carbon/target)
	SIGNAL_HANDLER
	stop_supressing(target)

/obj/item/mecha_parts/mecha_equipment/cage/proc/on_escape(mob/living/carbon/target)
	SIGNAL_HANDLER
	occupant_message(span_warning("[prisoner] сбежа[genderize_ru(prisoner.gender, "л", "ла", "ло", "ли")] из клетки."))
	log_message("[prisoner] escaped from mech cage.")
	prisoner = null
	if(holding)
		if(holding.handcuffed)
			change_alert(CAGE_STAGE_TWO)
		else
			change_alert(CAGE_STAGE_ONE)
	else
		change_alert(CAGE_STAGE_ZERO)
	change_state("mecha_cage")
	update_equip_info()
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)

/obj/item/mecha_parts/mecha_equipment/cage/proc/change_state(icon)
	button.button_icon_state = icon
	flick(icon, button)
	button.UpdateButtonIcon()

/obj/item/mecha_parts/mecha_equipment/cage/proc/change_alert(var/stage_define)
	var/mob/living/carbon/H = chassis.occupant
	for(var/I in subtypesof(/atom/movable/screen/alert/mech_cage))
		var/atom/movable/screen/alert/mech_cage/alert = I
		if(alert.stage_define == stage_define)
			H.throw_alert(alert_category, alert)
			break

	current_stage = stage_define


/obj/item/mecha_parts/mecha_equipment/cage/proc/set_supress_effect(mob/living/carbon/target)
	supress_effect = new(target.loc)
	flick("effect_on_doll", supress_effect)

/obj/item/mecha_parts/mecha_equipment/cage/proc/prisoner_insertion_check(mob/living/carbon/target)
	if(target.buckled)
		occupant_message(span_warning("[target] не помест[pluralize_ru(target.gender, "ит", "ят")]ся в клетку, так как [target] прикова[genderize_ru(target.gender, "н", "на", "но", "ны")] к [target.buckled.declent_ru(DATIVE)]!"))
		return FALSE
	if(target.has_buckled_mobs())
		occupant_message(span_warning("[target] не помест[pluralize_ru(target.gender, "ит", "ят")]ся в клетку, пока на [genderize_ru(target.gender, "нём", "ней", "нём", "них")] висит слайм!"))
		return FALSE
	if(prisoner)
		occupant_message(span_warning("Клетка уже занята!"))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/cage/proc/eject(force)
	if(!action_checks(src))
		return FALSE
	if(!prisoner)
		return FALSE
	if(holding)
		if(holding.handcuffed)
			change_alert(CAGE_STAGE_TWO)
		else
			change_alert(CAGE_STAGE_ONE)
	else
		change_alert(CAGE_STAGE_ZERO)
	UnregisterSignal(prisoner, COMSIG_MOVABLE_MOVED)
	prisoner.forceMove(get_turf(src))
	if(!force)
		occupant_message("[prisoner] извлеч[genderize_ru(prisoner.gender, "ён", "ена", "ено", "ены")].")
		log_message("[prisoner] ejected from SCS 3 Cage.")
	else
		occupant_message("[prisoner] сбежа[genderize_ru(prisoner.gender, "л", "ла", "ло", "ли")] из клетки.")
		log_message("[prisoner] escaped from SCS 3 Cage.")
	prisoner = null
	change_state("mecha_cage")
	update_equip_info()

/obj/item/mecha_parts/mecha_equipment/cage/can_detach()
	if(prisoner || holding)
		occupant_message(span_warning("Невозможно отсоединить [declent_ru(ACCUSATIVE)] - модуль в работе!"))
		return FALSE
	return TRUE

/obj/item/mecha_parts/mecha_equipment/cage/detach_act()
	button = null

/obj/item/mecha_parts/mecha_equipment/cage/get_module_equip_info()
	if(prisoner)
		return " <br />\[Задержанный: [prisoner] \]<br /><a href='byond://?src=[UID()];eject=1'>Eject</a>"

/obj/item/mecha_parts/mecha_equipment/cage/Topic(href,href_list)
	..()
	var/datum/topic_input/afilter = new /datum/topic_input(href,href_list)
	if(afilter.get("eject"))
		eject(FALSE)
	return

/obj/item/mecha_parts/mecha_equipment/cage/container_resist()
	if(prisoner.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER))
		var/obj/item/clothing/suit/straight_jacket/H = prisoner.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER)
		prisoner.cuff_resist(H, FALSE)
		return
	if(prisoner.handcuffed)
		prisoner.cuff_resist(prisoner.handcuffed, FALSE)
		return
	if(do_after(prisoner, 30 SECONDS, prisoner))
		eject(TRUE)

/obj/effect/supress
	name = "Mech claws"
	desc = "Пара мощных механических клешней. Такие могут запросто схватить гуманоида, не дав ему возможности выбраться."
	ru_names = list(
	    NOMINATIVE = "механические клешни",
	    GENITIVE = "механических клешней",
	    DATIVE = "механическим клешням",
	    ACCUSATIVE = "механические клешни",
	    INSTRUMENTAL = "механическими клешнями",
	    PREPOSITIONAL = "механических клешней"
	)
	icon = 'icons/misc/supress_effect.dmi'
	icon_state = "effect_on_doll"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ABOVE_GAME_PLANE
