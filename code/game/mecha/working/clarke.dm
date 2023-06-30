/obj/mecha/working/clarke
	desc = "Combining man and machine for a better, stronger miner."
	name = "Clarke"
	icon_state = "clarke"
	initial_icon = "clarke"
	step_in = 2
	var/fast_pressure_step_in = 2
	var/slow_pressure_step_in = 2 // wanna know why they're the same? me too
	dir_in = 1 //Facing North.
	max_integrity = 250
	deflect_chance = 15
	armor = list("melee" = 40, "bullet" = 30, "laser" = 20, "energy" = 30, "bomb" = 40, "bio" = 20, "rad" = 20, "fire" = 100, "acid" = 100)
	max_temperature = 25000
	lights_power = 8
	wreckage = /obj/structure/mecha_wreckage/clarke
	internal_damage_threshold = 35
	max_equip = 4
	step_energy_drain = 2
	normal_step_energy_drain = 2
	stepsound = 'sound/mecha/mechmove04.ogg'
	turnsound = 'sound/mecha/mechmove04.ogg'

/obj/mecha/working/clarke/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	thrusters_action.Grant(user, src)

/obj/mecha/working/clarke/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	thrusters_action.Remove(user)

/obj/mecha/working/clarke/Move()
	. = ..()
	update_pressure()

/obj/mecha/working/clarke/proc/update_pressure()
	var/turf/T = get_turf(loc)

	if(lavaland_equipment_pressure_check(T))
		step_in = fast_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)/2
	else
		step_in = slow_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)
