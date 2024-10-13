/obj/vehicle/ridden/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	max_integrity = 100
	armor = list("melee" = 20, "bullet" = 15, "laser" = 10, "energy" = 0, "bomb" = 30, "bio" = 0, "rad" = 0, "fire" = 60, "acid" = 60)
	key_type = /obj/item/key/security
	integrity_failure = 50

/obj/vehicle/ridden/secway/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/secway)
