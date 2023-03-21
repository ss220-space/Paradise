/obj/item/stack/pokerchips
	name = "Chips"
	desc = "Poker chips"
	icon = 'icons/goonstation/objects/pokerchips.dmi'
	icon_state = "c1000"
	hitsound = "swing_hit"
	force = 1
	throwforce = 1
	throw_speed = 1
	throw_range = 7
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE
	singular_name = "chip"
	max_amount = 1000000
	merge_type = /obj/item/stack/pokerchips

/obj/item/stack/pokerchips/New(loc, amt = null)
	..()
	update_icon()

/obj/item/stack/pokerchips/update_icon()
	..()
	name = "[amount == max_amount ? "1000000" : amount] Chip[amount > 1 ? "s" : ""]"
	if(amount >= 1 && amount <= 20)
		icon_state = "c20"
	else if(amount > 20 && amount <= 50)
		icon_state = "c50"
	else if(amount > 50 && amount <= 100)
		icon_state = "c100"
	else if(amount > 100 && amount <= 200)
		icon_state = "c200"
	else if(amount > 200 && amount <= 500)
		icon_state = "c500"
	else
		icon_state = "c1000"

/obj/item/stack/pokerchips/c10
	amount = 10

/obj/item/stack/pokerchips/c20
	amount = 20

/obj/item/stack/pokerchips/c50
	amount = 50

/obj/item/stack/pokerchips/c100
	amount = 100

/obj/item/stack/pokerchips/c200
	amount = 200

/obj/item/stack/pokerchips/c500
	amount = 500

/obj/item/stack/pokerchips/c1000
	amount = 1000

/obj/item/stack/pokerchips/c1000000
	amount = 1000000
