/obj/vehicle/ridden/atv
	name = "all-terrain vehicle"
	desc = "An all-terrain vehicle built for traversing rough terrain with ease. One of the few old-earth technologies that are still relevant on most planet-bound outposts."
	icon = 'icons/obj/vehicles/4wheeler.dmi'
	icon_state = "atv"
	max_integrity = 150
	armor = list("melee" = 50, "bullet" = 25, "laser" = 20, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60)
	key_type = /obj/item/key/atv
	integrity_failure = 0.5
	var/static/mutable_appearance/atvcover


/obj/vehicle/ridden/atv/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/atv)
	if(!atvcover)
		atvcover = mutable_appearance(icon, "atvcover", ABOVE_MOB_LAYER + 0.1)

/obj/vehicle/ridden/atv/post_buckle_mob(mob/living/M)
	add_overlay(atvcover)
	return ..()

/obj/vehicle/ridden/atv/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		cut_overlay(atvcover)
	return ..()


/obj/vehicle/ridden/atv/Destroy()
	atvcover = null
	return ..()

//TURRETS!
/obj/vehicle/ridden/atv/turret
	var/obj/machinery/porta_turret/syndicate/vehicle_turret/turret = /obj/machinery/porta_turret/syndicate/vehicle_turret


/obj/vehicle/ridden/atv/turret/Initialize(mapload)
	. = ..()
	turret = new turret(loc)
	RegisterSignal(src, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, PROC_REF(on_glide_size_update))
	RegisterSignal(turret, COMSIG_QDELETING, PROC_REF(on_turret_deleting))


/obj/vehicle/ridden/atv/turret/Destroy()
	QDEL_NULL(turret)
	return ..()


/obj/vehicle/ridden/atv/turret/proc/on_glide_size_update(datum/source, new_glide_size)
	SIGNAL_HANDLER
	turret?.set_glide_size(new_glide_size)


/obj/vehicle/ridden/atv/turret/proc/on_turret_deleting(datum/source)
	SIGNAL_HANDLER
	UnregisterSignal(src, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE)
	turret = null

/obj/vehicle/ridden/atv/turret/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(!turret)
		return
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return
	turret.forceMove(our_turf)
	switch(dir)
		if(NORTH)
			turret.pixel_x = base_pixel_x
			turret.pixel_y = base_pixel_y + 4
			turret.layer = ABOVE_MOB_LAYER
		if(EAST)
			turret.pixel_x = base_pixel_x - 12
			turret.pixel_y = base_pixel_y + 4
			turret.layer = OBJ_LAYER
		if(SOUTH)
			turret.pixel_x = base_pixel_x
			turret.pixel_y = base_pixel_y + 4
			turret.layer = OBJ_LAYER
		if(WEST)
			turret.pixel_x = base_pixel_x + 12
			turret.pixel_y = base_pixel_y + 4
			turret.layer = OBJ_LAYER


/obj/vehicle/ridden/atv/turret/fast
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

