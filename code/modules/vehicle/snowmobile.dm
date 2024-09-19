/obj/vehicle/ridden/snowmobile
	name = "red snowmobile"
	desc = "Wheeeeeeeeeeee."
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "snowmobile"
	key_type = /obj/item/key/snowmobile

/obj/vehicle/ridden/snowmobile/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/snowmobile)

/obj/vehicle/ridden/snowmobile/blue
	name = "blue snowmobile"
	icon_state = "bluesnowmobile"

/obj/vehicle/ridden/snowmobile/key/Initialize(mapload)
	. = ..()
	inserted_key = new /obj/item/key/snowmobile(src)

/obj/vehicle/ridden/snowmobile/blue/key/Initialize(mapload)
	. = ..()
	inserted_key = new /obj/item/key/snowmobile(src)

