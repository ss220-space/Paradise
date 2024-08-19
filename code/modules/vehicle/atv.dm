/obj/vehicle/atv
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-earth technologies that are still relevant on most planet-bound outposts."
	icon = 'icons/obj/vehicles/4wheeler.dmi'
	icon_state = "atv"
	max_integrity = 150
	armor = list("melee" = 50, "bullet" = 25, "laser" = 20, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60)
	key_type = /obj/item/key
	integrity_failure = 70
	generic_pixel_x = 0
	generic_pixel_y = 4
	vehicle_move_delay = 0.25 SECONDS
	var/mutable_appearance/atvcover


/obj/vehicle/atv/Initialize(mapload)
	. = ..()
	atvcover = mutable_appearance(icon, "atvcover", ABOVE_MOB_LAYER + 0.1)


/obj/vehicle/atv/Destroy()
	atvcover = null
	return ..()


/obj/vehicle/atv/update_overlays()
	. = ..()
	if(!has_buckled_mobs())
		return .
	. += atvcover


/obj/vehicle/atv/handle_vehicle_icons()
	update_icon(UPDATE_OVERLAYS)


/obj/vehicle/atv/handle_vehicle_layer()
	return


//TURRETS!
/obj/vehicle/atv/turret
	var/obj/machinery/porta_turret/syndicate/vehicle_turret/turret = /obj/machinery/porta_turret/syndicate/vehicle_turret


/obj/vehicle/atv/turret/Initialize(mapload)
	. = ..()
	turret = new turret(loc)
	handle_vehicle_offsets()
	handle_vehicle_icons()
	RegisterSignal(src, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(on_glide_size_update))
	RegisterSignal(turret, COMSIG_QDELETING, PROC_REF(on_turret_deleting))


/obj/vehicle/atv/turret/Destroy()
	QDEL_NULL(turret)
	return ..()


/obj/vehicle/atv/turret/proc/on_glide_size_update(datum/source, new_glide_size)
	SIGNAL_HANDLER
	turret?.set_glide_size(new_glide_size)


/obj/vehicle/atv/turret/proc/on_turret_deleting(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE)
	turret = null


/obj/vehicle/atv/turret/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(. && turret)
		turret.forceMove(loc)


/obj/vehicle/atv/turret/handle_vehicle_layer()
	if(!turret)
		return
	if(!has_buckled_mobs())
		turret.layer = OBJ_LAYER + 0.01
		return
	if(dir == SOUTH)
		turret.layer = OBJ_LAYER + 0.01
	else
		turret.layer = ABOVE_MOB_LAYER + 0.01


/obj/vehicle/atv/turret/update_overlays()
	. = list(atvcover)


/obj/vehicle/atv/turret/handle_vehicle_offsets()
	. = ..()
	if(!turret)
		return

	switch(dir)
		if(NORTH)
			turret.pixel_x = 0
			turret.pixel_y = 4
		if(EAST)
			turret.pixel_x = -12
			turret.pixel_y = 4
		if(SOUTH)
			turret.pixel_x = 0
			turret.pixel_y = 4
		if(WEST)
			turret.pixel_x = 12
			turret.pixel_y = 4


/obj/vehicle/atv/turret/fast
	turret = /obj/machinery/porta_turret/syndicate/vehicle_turret/fast


/obj/machinery/porta_turret/syndicate/vehicle_turret
	name = "mounted turret"
	animate_movement = SLIDE_STEPS
	scan_range = 7
	emp_vulnerable = TRUE
	density = FALSE
	layer = OBJ_LAYER + 0.01


/obj/machinery/porta_turret/syndicate/vehicle_turret/fast
	projectile = /obj/item/projectile/bullet/weakbullet4/c9mmte
	eprojectile = /obj/item/projectile/bullet/weakbullet4/c9mmte
	shot_delay = 0.2 SECONDS


/obj/machinery/porta_turret/syndicate/vehicle_turret/fast/Initialize(mapload)
	. = ..()
	makeSpeedProcess()

