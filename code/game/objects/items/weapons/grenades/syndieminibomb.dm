/obj/item/grenade/syndieminibomb
	desc = "A syndicate manufactured explosive used to sow destruction and chaos"
	name = "syndicate minibomb"
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "syndicate"
	item_state = "flashbang"
	origin_tech = "materials=3;magnets=4;syndicate=2"
	var/defused = FALSE // Used in `/obj/item/pen/fancy/bomb`.

/obj/item/grenade/syndieminibomb/prime()
	if(defused)
		defused = FALSE
		if(istype(loc, /obj/item/pen/fancy/bomb))
			var/obj/item/pen/fancy/bomb/pen_holder = loc
			pen_holder.clickscount = 0
	else
		update_mob()
		explosion(loc, 1, 2, 4, flame_range = 2, cause = src)
		qdel(src)
