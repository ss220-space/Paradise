/obj/mecha/combat/durand
	desc = "It's time to light some fires and kick some tires."
	name = "Durand Mk. II"
	icon_state = "durand"
	initial_icon = "durand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list(melee = 40, bullet = 35, laser = 15, energy = 10, bomb = 20, bio = 0, rad = 50, fire = 100, acid = 100)
	max_temperature = 30000
	infra_luminosity = 8
	maint_access = TRUE
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand

	mech_type = MECH_TYPE_DURAND

/obj/mecha/combat/durand/GrantActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Grant(user, src)

/obj/mecha/combat/durand/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	defense_action.Remove(user)

/obj/mecha/combat/durand/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack
	ME.attach(src)

/obj/mecha/combat/durand/old
	desc = "A retired, third-generation combat exosuit utilized by the Nanotrasen corporation. Originally developed to combat hostile alien lifeforms."
	name = "Durand"
	icon_state = "old_durand"
	initial_icon = "old_durand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list(melee = 50, bullet = 35, laser = 15, energy = 15, bomb = 20, bio = 0, rad = 50, fire = 100, acid = 100)
	max_temperature = 30000
	infra_luminosity = 8
	maint_access = FALSE
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand/old

/obj/mecha/combat/durand/rover
	desc = "Combat exosuit, developed by syndicate from the Durand Mk. II by scraping unnecessary things, and adding some of their tech. Much more protected from any Nanotrasen hazards."
	name = "Rover"
	icon_state = "darkdurand"
	initial_icon = "darkdurand"
	step_in = 4
	dir_in = 1 //Facing North.
	max_integrity = 400
	deflect_chance = 20
	armor = list(melee = 30, bullet = 40, laser = 50, energy = 50, bomb = 20, bio = 0, rad = 50, fire = 100, acid = 100)
	max_temperature = 30000
	infra_luminosity = 8
	max_equip = 4
	maint_access = FALSE
	force = 40
	wreckage = /obj/structure/mecha_wreckage/durand/rover
	internal_damage_threshold = 35
	wall_type = /obj/effect/forcefield/mecha/syndicate //energywall icon_state
	large_wall = TRUE
	starting_voice = /obj/item/mecha_modkit/voice/syndicate
	destruction_sleep_duration = 1
	strafe_allowed = TRUE

/obj/mecha/combat/durand/rover/GrantActions(mob/living/user, human_occupant = 0)
	..()
	thrusters_action.Grant(user, src)
	energywall_action.Grant(user, src)

/obj/mecha/combat/durand/rover/RemoveActions(mob/living/user, human_occupant = 0)
	..()
	thrusters_action.Remove(user)
	energywall_action.Remove(user)

/obj/mecha/combat/durand/rover/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg/syndi
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/repair_droid
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/ionshotgun
	ME.attach(src)

/obj/mecha/combat/durand/rover/loaded/add_cell()
	cell = new /obj/item/stock_parts/cell/bluespace(src)
