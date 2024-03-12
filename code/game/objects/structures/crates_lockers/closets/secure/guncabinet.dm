/obj/structure/closet/secure_closet/guncabinet
	name = "gun cabinet"
	req_access = list(ACCESS_ARMORY)
	icon = 'icons/obj/guncabinet.dmi'
	icon_state = "guncabinet"


/obj/structure/closet/secure_closet/guncabinet/Initialize(mapload)
	. = ..()
	// we need to update our guns inside, after closet is filled
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), UPDATE_OVERLAYS), 1 SECONDS)


/obj/structure/closet/secure_closet/guncabinet/apply_contents_overlays()
	. = ..()

	var/lazors = 0
	var/shottas = 0
	for(var/thing in contents)
		if(istype(thing, /obj/item/gun/energy))
			lazors++
		if(istype(thing, /obj/item/gun/projectile))
			shottas++

	if(lazors || shottas)
		for(var/i = 1 to 2)
			var/choise = ""
			if(lazors > 0 && (shottas <= 0 || prob(50)))
				lazors--
				choise = "laser"
			else if(shottas > 0)
				shottas--
				choise = "projectile"
			if(choise)
				. += image(icon, icon_state = choise, pixel_x = i * 4)

