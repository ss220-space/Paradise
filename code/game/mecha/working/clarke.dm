/obj/mecha/working/clarke
	desc = "Combining man and machine for a better, stronger miner."
	name = "Clarke"
	icon_state = "clarke"
	initial_icon = "clarke"
	step_in = 2
	dir_in = 1 //Facing North.
	max_integrity = 250
	deflect_chance = 15
	armor = list(MELEE = 40, BULLET = 30, LASER = 20, ENERGY = 30, BOMB = 40, BIO = 20, RAD = 20, FIRE = 100, ACID = 100)
	max_temperature = 25000
	lights_power = 8
	wreckage = /obj/structure/mecha_wreckage/clarke
	internal_damage_threshold = 35
	max_equip = 4
	step_energy_drain = 2
	normal_step_energy_drain = 2
	stepsound = 'sound/mecha/mechmove04.ogg'
	turnsound = 'sound/mecha/mechmove04.ogg'

	mech_type = MECH_TYPE_CLARKE

/obj/mecha/working/clarke/GrantActions(mob/living/user, human_occupant = 0)
	. = ..()
	thrusters_action.Grant(user, src)

/obj/mecha/working/clarke/RemoveActions(mob/living/user, human_occupant = 0)
	. = ..()
	thrusters_action.Remove(user)
