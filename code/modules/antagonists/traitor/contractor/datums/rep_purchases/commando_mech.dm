/**
 * # Rep Purchase - Commando Mech
 */
/datum/rep_purchase/item/commando_mech
	name = "Commando mech delivery"
	description = "A one-use beacon that calls down a Commando exosuit."
	cost = 6
	stock = 1
	item_type = /obj/item/mecha_drop/commando

/obj/item/mecha_drop/commando
	name = "commando mechadrop tool"
	desc = "A one-use targeting device for a compact Syndicate exosuit drop."
	mecha_type = /obj/mecha/combat/commando/loaded
