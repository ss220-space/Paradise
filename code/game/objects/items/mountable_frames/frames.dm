/obj/item/mounted/frame
	name = "mountable frame"
	desc = "Place it on a wall."
	origin_tech = "materials=1;engineering=1"
	var/sheets_refunded = 2
	var/list/mount_reqs = list() //can contain simfloor, nospace. Used in try_build to see if conditions are needed, then met
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'


/obj/item/mounted/frame/wrench_act(mob/living/user, obj/item/I)
	if(!sheets_refunded)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	new /obj/item/stack/sheet/metal(drop_location(), sheets_refunded)
	qdel(src)


/obj/item/mounted/frame/try_build(turf/on_wall, mob/user)
	if(..()) //if we pass the parent tests
		var/turf/turf_loc = get_turf(user)

		if(src.mount_reqs.Find("simfloor") && !isfloorturf(turf_loc))
			to_chat(user, "<span class='warning'>[src] cannot be placed on this spot.</span>")
			return
		if(src.mount_reqs.Find("nospace"))
			var/area/my_area = turf_loc.loc
			if(!istype(my_area) || (my_area.requires_power == 0 || istype(my_area,/area/space)))
				to_chat(user, "<span class='warning'>[src] cannot be placed in this area.</span>")
				return
		return 1
