/*
Collection of special ash walker structures and related stuff.
Almost everything - reskin for station structures
Special thanks to piotrthetchaikowsky, pilygun & the_worm
*/

//beds

/obj/structure/bed/ash
	name = "wicker bed"
	desc = "A handmade bed used by ash walker tribes. It doesn't look very comfortable."
	icon_state = "wicker_bed"
	buildstacktype = /obj/item/stack/sheet/leather
	buildstackamount = 4
	buckle_offset = -3
	comfort = 0.6

/obj/structure/bed/wooden
	name = "wooden bed"
	desc = "A handmade bed made of wood and fabric. Looks very comfortable. You could take a nap on it for a while..."
	icon_state = "wooden_bed"
	buildstacktype = /obj/item/stack/sheet/wood
	buildstackamount = 15
	buckle_offset = -3
	comfort = 3

//drying rack

/obj/machinery/smartfridge/drying_rack/ash
	name = "primitive drying rack"
	desc = "A handmade tribal wooden rack, used to dry plant products, food and leather."
	icon_state = "drying_stick"
	use_power = NO_POWER_USE
	can_dry = FALSE //trust me
	drying = TRUE
	idle_power_usage = 0
	active_power_usage = 0
	drying_timer = 8
	primitive = TRUE

/obj/machinery/smartfridge/drying_rack/ash/update_icon()
	overlays.Cut()
	if(length(contents))
		overlays += "drying_stick_filled"


//stool

/obj/structure/chair/stool/wooden
	name = "wooden stool"
	desc = "A comfortable looking stool."
	icon_state = "wooden_stool"
	item_chair = /obj/item/chair/stool/wooden

/obj/item/chair/stool/wooden
	name = "wooden stool"
	desc = "A comfortable looking stool."
	icon_state = "wooden_stool_toppled"
	item_state = "chair" //wooden enough
	origin_type = /obj/structure/chair/stool/wooden
	break_chance = 10

//rack

/obj/structure/rack/wooden
	name = "wooden rack"
	desc = "Middle Ages version of classic rack."
	icon = 'icons/obj/objects.dmi'
	icon_state = "wooden_rack"

/obj/structure/rack/wooden/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		density = FALSE
		var/obj/item/gunrack_parts/newparts = new(loc) //временно.
		transfer_fingerprints_to(newparts)
	for(var/obj/item/I in loc.contents)
		if(istype(I, /obj/item/gun))
			var/obj/item/gun/to_remove = I
			to_remove.remove_from_rack()
	qdel(src)

/obj/structure/closet/crate/wooden
	name = "wooden crate"
	desc = "A rectangular wooden crate"
	icon_state = "woodencrate"
	icon_opened = "woodencrateopen"
	icon_closed = "woodencrate"

/obj/structure/closet/crate/oven
	name = "wooden crate"
	desc = "A rectangular wooden crate"
	icon_state = "oven_basis"
	icon_opened = "oven_basis"
	icon_closed = "oven_basis"
