/obj/vehicle/ambulance
	name = "ambulance"
	desc = "This is what the paramedic uses to run over people they need to take to medbay."
	icon_state = "docwagon2"
	vehicle_move_delay = 0.3 SECONDS
	key_type = /obj/item/key/ambulance
	var/obj/structure/bed/amb_trolley/bed = null
	var/datum/action/ambulance_alarm/AA
	var/datum/looping_sound/ambulance_alarm/soundloop
	light_on = FALSE
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_power = 3
	light_color = "#F70027"


/obj/vehicle/ambulance/Initialize(mapload)
	. = ..()
	AA = new(src)
	soundloop = new(list(src), FALSE)


/obj/vehicle/ambulance/Destroy()
	QDEL_NULL(soundloop)
	QDEL_NULL(AA)
	bed = null
	return ..()


/datum/action/ambulance_alarm
	name = "Toggle Sirens"
	icon_icon = 'icons/obj/vehicles/vehicles.dmi'
	button_icon_state = "docwagon2"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	var/toggle_cooldown = 40
	var/cooldown = 0


/datum/action/ambulance_alarm/Trigger(left_click = TRUE)
	if(!..())
		return FALSE

	var/obj/vehicle/ambulance/A = target

	if(!istype(A) || !A.soundloop)
		return FALSE

	if(world.time < cooldown + toggle_cooldown)
		return FALSE

	cooldown = world.time

	if(A.soundloop.muted)
		A.soundloop.start()
		A.set_light_on(TRUE)
	else
		A.soundloop.stop()
		A.set_light_on(FALSE)


/datum/looping_sound/ambulance_alarm
	start_length = 0
	mid_sounds = list('sound/items/weeoo1.ogg' = 1)
	mid_length = 14
	volume = 100


/obj/vehicle/ambulance/post_buckle_mob(mob/living/target)
	. = ..()
	AA.Grant(target)


/obj/vehicle/ambulance/post_unbuckle_mob(mob/living/target)
	. = ..()
	AA.Remove(target)


/obj/item/key/ambulance
	name = "ambulance key"
	desc = "A keyring with a small steel key, and tag with a red cross on it."
	icon_state = "keydoc"


/obj/vehicle/ambulance/handle_vehicle_offsets()
	if(!has_buckled_mobs())
		return
	for(var/mob/living/buckled_mob as anything in buckled_mobs)
		buckled_mob.setDir(dir)
		switch(dir)
			if(SOUTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 7
			if(WEST)
				buckled_mob.pixel_x = 13
				buckled_mob.pixel_y = 7
			if(NORTH)
				buckled_mob.pixel_x = 0
				buckled_mob.pixel_y = 4
			if(EAST)
				buckled_mob.pixel_x = -13
				buckled_mob.pixel_y = 7


/obj/vehicle/ambulance/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/oldloc = loc
	if(bed && !Adjacent(bed))
		bed = null
	. = ..()
	if(. && bed && get_dist(oldloc, loc) <= 2)
		bed.Move(oldloc, get_dir(bed, oldloc), glide_size)
		if(bed.has_buckled_mobs())
			for(var/mob/living/buckled_mob as anything in bed.buckled_mobs)
				buckled_mob.setDir(direct)


/obj/structure/bed/amb_trolley
	name = "ambulance train trolley"
	icon = 'icons/obj/vehicles/CargoTrain.dmi'
	icon_state = "ambulance"
	anchored = FALSE


/obj/structure/bed/amb_trolley/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Drag [src]'s sprite over the ambulance to (de)attach it.</span>"

/obj/structure/bed/amb_trolley/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!istype(over_object, /obj/vehicle/ambulance) || usr.incapacitated() || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return FALSE

	var/obj/vehicle/ambulance/amb = over_object
	if(amb.bed)
		amb.bed = null
		balloon_alert(usr, "отцеплено от машины")
	else
		amb.bed = src
		balloon_alert(usr, "прицеплено к машине")
