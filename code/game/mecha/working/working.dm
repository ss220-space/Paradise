/obj/mecha/working
	internal_damage_threshold = 60
	cargo_capacity = 15
	var/fast_pressure_step_in = 2
	var/slow_pressure_step_in = 2

/obj/mecha/working/Initialize()
	. = ..()
	if(!ruin_mecha)
		trackers += new /obj/item/mecha_parts/mecha_tracking(src)

/obj/mecha/working/proc/collect_ore()
	if(locate(/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp) in equipment)
		var/obj/structure/ore_box/ore_box = locate(/obj/structure/ore_box) in cargo
		if(ore_box)
			for(var/obj/item/stack/ore/ore in range(1, src))
				if(ore.Adjacent(src) && ((get_dir(src, ore) & dir) || ore.loc == loc)) //we can reach it and it's in front of us? grab it!
					ore.forceMove(ore_box)

/obj/mecha/working/Move()
	. = ..()
	if(.)
		collect_ore()
	update_pressure()

/obj/mecha/working/proc/update_pressure()
	var/turf/T = get_turf(loc)

	if(lavaland_equipment_pressure_check(T))
		step_in = fast_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)/2
	else
		step_in = slow_pressure_step_in
		for(var/obj/item/mecha_parts/mecha_equipment/drill/drill in equipment)
			drill.equip_cooldown = initial(drill.equip_cooldown)

/obj/mecha/working/go_out()
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/mecha/working/moved_inside(mob/living/carbon/human/H)
	..()
	update_icon(UPDATE_OVERLAYS)

/obj/mecha/working/mmi_moved_inside(obj/item/mmi/mmi_as_oc, mob/user)
	..()
	update_icon(UPDATE_OVERLAYS)
