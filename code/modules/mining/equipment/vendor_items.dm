/**********************Mining Equipment Vendor Items**************************/
//misc stuff you can buy from the vendor that has special code but doesn't really need its own file

/**********************Facehugger toy**********************/
/obj/item/clothing/mask/facehugger/toy
	item_state = "facehugger_inactive"
	desc = "A toy often used to play pranks on other miners by putting it in their beds. It takes a bit to recharge after latching onto something."
	throwforce = 0
	real = 0
	sterile = 1
	tint = 3 //Makes it feel more authentic when it latches on
	mob_throw_hit_sound = null
	equip_sound = 'sound/items/handling/generic_equip4.ogg'
	drop_sound = 'sound/items/handling/generic_drop5.ogg'
	pickup_sound = 'sound/items/handling/generic_pickup3.ogg'

/obj/item/clothing/mask/facehugger/toy/Die()
	return
