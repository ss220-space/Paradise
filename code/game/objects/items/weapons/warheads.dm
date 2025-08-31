/obj/item/warhead
	icon = 'icons/obj/weapons/grenade.dmi'
	ground_offset_x = 7
	ground_offset_y = 6
	var/max_container_volume = 0
	var/obj/item/reagent_containers/glass/beaker/first_part
	var/obj/item/reagent_containers/glass/beaker/second_part
	var/locked = FALSE

/obj/item/warhead/update_icon_state()
	icon_state = initial(icon_state) + ((locked)? "_locked" : ((first_part || second_part)? "_ass" : ""))


/obj/item/warhead/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/glass/beaker))
		var/obj/item/reagent_containers/glass/beaker/beaker = I
		if(beaker.reagents.maximum_volume > max_container_volume)
			to_chat(user, "[I] is too big to use in this warhead.")
			return ..()
		if(!first_part)
			first_part = beaker
			user.temporarily_remove_item_from_inventory(beaker)
			beaker.forceMove(src)
			update_icon(UPDATE_ICON_STATE)
			return ATTACK_CHAIN_PROCEED_SUCCESS
		if(!second_part)
			second_part = beaker
			user.temporarily_remove_item_from_inventory(beaker)
			beaker.forceMove(src)
			update_icon(UPDATE_ICON_STATE)
			return ATTACK_CHAIN_PROCEED_SUCCESS
	return ..()

/obj/item/warhead/attack_self(mob/user)
	if(locked)
		return ..()

	if(first_part)
		first_part.forceMove_turf()
		first_part = null
		update_icon(UPDATE_ICON_STATE)
		return TRUE

	if(second_part)
		second_part.forceMove_turf()
		second_part = null
		update_icon(UPDATE_ICON_STATE)
		return TRUE

/obj/item/warhead/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()

	if(!locked && (first_part || second_part))
		locked = TRUE
		update_icon(UPDATE_ICON_STATE)
		return .
	
	prime()

/obj/item/warhead/proc/prime()
	var/datum/reagents/first_reagents = first_part?.reagents
	var/datum/reagents/second_reagents = second_part?.reagents
	var/volume = 0
	if(first_reagents)
		volume += first_reagents.maximum_volume

	if(second_reagents)
		volume += second_reagents.maximum_volume

	create_reagents(volume)

	if(first_reagents)
		first_reagents.copy_to(reagents, first_reagents.total_volume)
		QDEL_NULL(first_part)

	if(second_reagents)
		second_reagents.copy_to(reagents, second_reagents.total_volume)
		QDEL_NULL(second_part)

	reagents.handle_reactions()

	QDEL_IN(src, 1 SECONDS)


/obj/item/warhead/mortar
	name = "80mm mortar warhead"
	desc = "A custom warhead meant for 80mm mortar shells."
	icon_state = "warhead_mortar"
	max_container_volume = 100
	materials = list(METAL = 11250) //3 sheets
	var/has_camera = FALSE

/obj/item/warhead/mortar/camera
	name = "80mm mortar camera warhead"
	desc = "A custom warhead meant for 80mm mortar shells. Camera drone included."
	max_container_volume = 50
	materials = list(METAL = 15000) //4 sheets
