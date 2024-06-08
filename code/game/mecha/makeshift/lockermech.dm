/obj/mecha/makeshift
	desc = "A locker with stolen wires, struts, electronics and airlock servos crudley assemebled into something that resembles the fuctions of a mech."
	name = "Locker Mech"
	icon = 'icons/obj/mecha/lockermech.dmi'
	icon_state = "lockermech"
	initial_icon = "lockermech"
	max_integrity = 100 //its made of scraps
	lights_power = 5
	step_in = 4 //Same speed as a ripley, for now.
	armor = list(melee = 20, bullet = 10, laser = 10, energy = 0, bomb = 10, bio = 0, rad = 0, fire = 70, acid = 60) //Same armour as a locker
	internal_damage_threshold = 30 //Its got shitty durability
	max_equip = 2 //You only have two arms and the control system is shitty
	wreckage = null
	mech_enter_time = 20

	cargo_capacity = 5 // you can fit a few things in this locker but not much.


/obj/mecha/makeshift/Destroy()
	new /obj/structure/closet(loc)
	return ..()

/obj/mecha/combat/lockersyndie
	desc = "A locker with stolen wires, struts, electronics and airlock servos crudley assemebled into something that resembles the fuctions of a mech. Dark-red painted."
	name = "Syndie Locker Mech"
	icon = 'icons/obj/mecha/lockermech.dmi'
	icon_state = "syndielockermech"
	initial_icon = "syndielockermech"
	lights_power = 5
	step_in = 4
	max_integrity = 225 //its made of scraps
	armor = list(melee = 20, bullet = 20, laser = 20, energy = 10, bomb = 15, bio = 0, rad = 0, fire = 70, acid = 60)
	internal_damage_threshold = 30
	deflect_chance = 20
	force = 20
	mech_enter_time = 20
	max_equip = 4
	wreckage = null


/obj/mecha/combat/lockersyndie/add_cell()
	cell = new /obj/item/stock_parts/cell/high/slime(src)

/obj/mecha/combat/lockersyndie/loaded/New()
	..()
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/drill/diamonddrill(src)
	ME.attach(src)
	ME = new /obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster(src)
	ME.attach(src)

/obj/mecha/combat/lockersyndie/Destroy()
	new /obj/structure/closet(loc)
	return ..()

/obj/effect/particle_effect/mecha_drop
	name = "mecha drop"
	icon_state = "dropzone_mech_loop"
	icon = 'icons/effects/96x96.dmi'
	pixel_x = -32
	pixel_y = -32

/obj/item/mecha_drop
	name = "mechadrop tool"
	desc = "Simple looking tool with only one button"
	icon = 'icons/obj/device.dmi'
	icon_state = "pointer"
	item_state = "pen"
	var/mecha_type = /obj/mecha/combat/lockersyndie/loaded
	var/obj/mecha/summon_mecha
	var/list/summon_sound = 'sound/items/bikehorn.ogg'
	var/used = FALSE

/obj/item/mecha_drop/New()
	. = ..()
	if(mecha_type)
		summon_mecha = new mecha_type(src)

/obj/item/mecha_drop/afterattack(atom/target, mob/user, proximity, params)
	if(used)
		return
	if(isfloorturf(target))
		for(var/turf/T in (RANGE_TURFS(1, target) + target))
			if(!isfloorturf(T))
				to_chat(user, "You need free 3x3 area for mecha summon.")
				return
			for(var/obj/O in T)
				if(O.density && O.anchored)
					to_chat(user, "You need free 3x3 area for mecha summon.")
					return
		used = TRUE
		var/obj/effect/particle_effect/mecha_drop/mecha_effect = new(target)
		flick("dropzone_mech_start", mecha_effect)
		if(do_after(user, 2 SECONDS, user))
			if(do_after(user, 5 SECONDS, user))
				summon_mecha.forceMove(target)
				new /obj/effect/particle_effect/smoke(target)
				playsound(target, 'sound/magic/disintegrate2.ogg', 200, 1)
				for(var/mob/M in range(6, target))
					shake_camera(M, 2 SECONDS, 2)
				for(var/mob/living/M in range(1, target))
					M.apply_damage(120)
			else
				used = FALSE
		else
			used = FALSE
		qdel(mecha_effect)
	else
		to_chat(user, "You can use it only on floor.")

