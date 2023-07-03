//plasma magmite is exclusively used to upgrade mining equipment, by using it on a heated world anvil to make upgradeparts.
/obj/item/magmite
	name = "plasma magmite"
	desc = "A chunk of plasma magmite, crystallized deep under the planet's surface. It seems to lose strength as it gets further from the planet!"
	icon = 'icons/obj/mining.dmi'
	icon_state = "Magmite ore"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/magmite_parts
	name = "plasma magmite upgrade parts"
	desc = "Forged on the legendary World Anvil, these parts can be used to upgrade many kinds of mining equipment."
	icon = 'icons/obj/mining.dmi'
	icon_state = "upgrade_parts"
	w_class = WEIGHT_CLASS_NORMAL
	var/inert = FALSE

/obj/item/magmite_parts/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(go_inert)), 10 MINUTES)

/obj/item/magmite_parts/proc/go_inert()
	if(inert)
		return
	visible_message(span_warning("The [src] loses it's glow!"))
	inert = TRUE
	name = "inert plasma magmite upgrade parts"
	icon_state = "upgrade_parts_inert"
	desc += "It appears to have lost its magma-like glow."

/obj/item/magmite_parts/proc/restore()
	if(!inert)
		return
	inert = FALSE
	name = initial(name)
	icon_state = initial(icon_state)
	desc = initial(desc)
	addtimer(CALLBACK(src, PROC_REF(go_inert)), 10 MINUTES)

