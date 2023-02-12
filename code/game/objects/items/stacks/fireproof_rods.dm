/obj/item/stack/fireproof_rods
	name = "fireproof rods"
	desc = "Жаропрочные стержни, способные выдержать жар в несколько тысяч градусов. Могут использоваться для строительства мостов над лавой."
	singular_name = "fireproof rod"
	icon = 'icons/obj/items.dmi'
	icon_state = "f_rods"
	item_state = "f_rods"
	flags = CONDUCT
	w_class = WEIGHT_CLASS_NORMAL
	force = 9.0
	throwforce = 10.0
	throw_speed = 3
	throw_range = 7
	max_amount = 50
	attack_verb = list("hit", "bludgeoned", "whacked")
	hitsound = 'sound/weapons/grenadelaunch.ogg'
	toolspeed = 1
	usesound = 'sound/items/deconstruct.ogg'

/obj/item/stack/fireproof_rods/update_icon()
	var/amount = get_amount()
	if((amount <= 5) && (amount > 0))
		icon_state = "f_rods-[amount]"
	else
		icon_state = "f_rods"

/obj/item/stack/fireproof_rods/New(loc, amount=null)
	..()
	update_icon()
