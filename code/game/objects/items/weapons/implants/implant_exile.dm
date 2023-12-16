/**
 * Exile implants will allow you to use the station gate, but not return home.
 * This will allow security to exile badguys/for badguys to exile their kill targets.
 */
/obj/item/implant/exile
	name = "exile implant"
	desc = "Prevents you from returning from away missions"
	origin_tech = "materials=2;biotech=3;magnets=2;bluespace=3"
	implant_state = "implant-nanotrasen"
	activated = BIOCHIP_ACTIVATED_PASSIVE
	implant_data = /datum/implant_fluff/exile


/obj/item/implanter/exile
	name = "bio-chip implanter (exile)"
	imp = /obj/item/implant/exile


/obj/item/implantcase/exile
	name = "bio-chip case - 'Exile'"
	desc = "A glass case containing an exile bio-chip."
	imp = /obj/item/implant/exile

