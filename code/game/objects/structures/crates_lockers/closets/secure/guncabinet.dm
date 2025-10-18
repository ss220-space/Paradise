/obj/structure/closet/secure_closet/guncabinet
	name = "gun cabinet"
	req_access = list(ACCESS_ARMORY)
	icon = 'icons/obj/guncabinet.dmi'
	icon_state = "guncabinet"

	var/static/list/gun_overlays = list(
		/obj/item/gun/energy/laser = "laser",
		/obj/item/gun/projectile/shotgun = "shotgun",
		/obj/item/gun/projectile/automatic/wt550 = "wt550",
		/obj/item/gun/projectile/automatic/lr30 = "lr30",
		/obj/item/gun/projectile/automatic/sp91rc = "sp91"
	)

/obj/structure/closet/secure_closet/guncabinet/Initialize(mapload)
	. = ..()
	// we need to update our guns inside, after closet is filled
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), UPDATE_OVERLAYS), 1 SECONDS)

/obj/structure/closet/secure_closet/guncabinet/apply_contents_overlays()
	. = ..()
	var/count = 0
	for(var/thing in contents)
		for(var/type in gun_overlays)
			if(!istype(thing, type))
				continue
			if(count >= 2)
				break
			count++
			var/mutable_appearance/gun_olay = mutable_appearance(icon, gun_overlays[type], CLOSET_OLAY_LAYER_CONTENTS)
			gun_olay.pixel_w = count * 2
			. += gun_olay
