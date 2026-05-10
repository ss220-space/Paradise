/obj/item/key
	name = "key"
	desc = "A small grey key."
	icon = 'icons/obj/vehicles/vehicles.dmi'
	icon_state = "key"
	w_class = WEIGHT_CLASS_TINY

/obj/item/key/atv
	name = "ATV key"
	desc = "A small grey key for starting and operating ATVs."

/obj/item/key/ambulance
	name = "ambulance key"
	desc = "A keyring with a small steel key, and tag with a red cross on it."
	icon_state = "keydoc"

/obj/item/key/janitor
	desc = "A keyring with a small steel key, and a pink fob reading \"Pussy Wagon\"."
	icon_state = "keyjanitor"

/obj/item/key/security
	desc = "A keyring with a small steel key, and a rubber stun baton accessory."
	icon_state = "keysec"

/obj/item/key/snowmobile
	name = "snowmobile key"
	desc = "A keyring with a small steel key, and tag with a red cross on it; clearly it's not implying you're going to the hospital for this..."
	icon_state = "keydoc" //get a better icon, sometime.

/obj/item/key/lasso
	name = "bone lasso"
	desc = "The perfect tool for directing a Goliath! If only it made them move any faster..."
	force = 12
	icon_state = "lasso"
	item_state = "chain"
	lefthand_file = 'icons/mob/inhands/chaplain_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/chaplain_righthand.dmi'
	// attack_verb_continuous = list("flogs", "whips", "lashes", "disciplines")
	// attack_verb_simple = list("flog", "whip", "lash", "discipline") // Похуй потом
	hitsound = 'sound/weapons/whip.ogg'
	slot_flags = ITEM_SLOT_BELT
