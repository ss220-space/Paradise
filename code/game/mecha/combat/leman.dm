/obj/mecha/combat/leman
        desc = "A main battle tank of multiple private security companies, capable of quick assaults and long defences."
        name = "Leman Russ"
        icon_state = "leman"
        initial_icon = "leman"
        max_integrity = 600
        deflect_chance = 30
        step_in = 3.5
        dir_in = 2
        armor = list(melee = 40, bullet = 35, laser = 15, energy = 10, bomb = 20, bio = 0, rad = 50, fire = 100, acid = 100)
        max_temperature = 30000
        infra_luminosity = 8
        force = 40
        leg_overload_coeff = 2
        wreckage = /obj/structure/mecha_wreckage/leman
        internal_damage_threshold = 15
        max_equip = 5
        maxsize = 2
        step_energy_drain = 3
        normal_step_energy_drain = 1.5


/obj/mecha/combat/leman/GrantActions(mob/living/user, human_occupant = 0)
        ..()
        overload_action.Grant(user, src)


/obj/mecha/combat/leman/RemoveActions(mob/living/user, human_occupant = 0)
        ..()
        overload_action.Remove(user)


/obj/mecha/combat/leman/loaded/New()
        ..()
        var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/bolter
        ME.attach(src)
        ME = new /obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/ontos
        ME.attach(src)
        ME = new
/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster
        ME.attach(src)
        ME = new
/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster
        ME.attach(src)
        ME = new
/obj/item/mecha_parts/mecha_equipment/generator
        ME.attach(src)