/obj/vehicle/ridden/ambulance
	name = "ambulance"
	desc = "This is what the paramedic uses to run over people they need to take to medbay."
	icon_state = "docwagon2"
	key_type = /obj/item/key/ambulance

	var/obj/structure/bed/amb_trolley/bed = null
	var/datum/looping_sound/ambulance_alarm/soundloop

	//Lights on ability activation
	light_on = FALSE
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_power = 3
	light_color = "#F70027"

/obj/vehicle/ridden/ambulance/generate_actions()
	. = ..()
	initialize_controller_action_type(/datum/action/vehicle/ridden/ambulance/ambulance_alarm, VEHICLE_CONTROL_DRIVE)

/obj/vehicle/ridden/ambulance/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/ambulance)

/obj/vehicle/ridden/ambulance/Destroy()
	QDEL_NULL(soundloop)
	bed = null
	return ..()

/obj/vehicle/ridden/ambulance/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
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
	pull_push_slowdown = 0	// used for transporting lying mobs
	interaction_flags_mouse_drop = NEED_HANDS

/obj/structure/bed/amb_trolley/examine(mob/user)
	. = ..()
	. += span_notice("Drag [src]'s sprite over the ambulance to (de)attach it.")

/obj/structure/bed/amb_trolley/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(!istype(over_object, /obj/vehicle/ridden/ambulance))
		return

	var/obj/vehicle/ridden/ambulance/ambulance = over_object

	if(ambulance.bed == src)
		ambulance.bed = null
		balloon_alert(user, "отцеплено от машины")
		return

	if(ambulance.bed)
		balloon_alert(user, "уже прицеплена другая каталка")
		return

	ambulance.bed = src
	balloon_alert(user, "прицеплено к машине")
