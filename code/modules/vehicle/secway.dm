/obj/vehicle/ridden/secway
	name = "secway"
	desc = "A brave security cyborg gave its life to help you look like a complete tool."
	icon_state = "secway"
	max_integrity = 100
	armor = list(MELEE = 20, BULLET = 15, LASER = 10, ENERGY = 0, BOMB = 30, BIO = 0, RAD = 0, FIRE = 60, ACID = 60)
	key_type = /obj/item/key/security
	integrity_failure = 50

/obj/vehicle/ridden/secway/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/secway)
