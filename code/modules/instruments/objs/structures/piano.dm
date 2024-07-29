/obj/structure/piano
	parent_type = /obj/structure/musician // TODO: Can't edit maps right now due to a freeze, remove and update path when it's done
	name = "space minimoog"
	icon = 'icons/obj/musician.dmi'
	icon_state = "minimoog"
	anchored = TRUE
	density = TRUE
	allowed_instrument_ids = "piano"

/obj/structure/piano/unanchored
	anchored = FALSE

/obj/structure/piano/Initialize(mapload)
	. = ..()
	if(prob(50) && icon_state == initial(icon_state))
		name = "space minimoog"
		desc = "This is a minimoog, like a space piano, but more spacey!"
		icon_state = "minimoog"
	else
		name = "space piano"
		desc = "This is a space piano, like a regular piano, but always in tune! Even if the musician isn't."
		icon_state = "piano"
	AddElement(/datum/element/falling_hazard, damage = 80, hardhat_safety = FALSE, crushes = TRUE, impact_sound = 'sound/effects/piano_hit.ogg')

/obj/structure/pianoclassic
	parent_type = /obj/structure/musician
	name = "space minimoog"
	desc = "This is a minimoog, like a space piano, but more spacey!"
	icon = 'icons/obj/musician.dmi'
	icon_state = "minipiano"
	anchored = TRUE
	density = TRUE
	allowed_instrument_ids = "piano"

/obj/structure/pianoclassic/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = 80, hardhat_safety = FALSE, crushes = TRUE, impact_sound = 'sound/effects/piano_hit.ogg')

/obj/structure/pianoclassic/ghostpiano
	parent_type = /obj/structure/musician
	name = "cursed piano"
	desc = "<b>You feel an evil presence watching you...</b>"
	icon = 'icons/obj/musician.dmi'
	icon_state = "minipiano"
	anchored = TRUE
	density = TRUE
	allowed_instrument_ids = "r3grand"
	light_range = 2
	light_power = 1
	light_color = "#ff0000"
	light_system = MOVABLE_LIGHT

/obj/structure/pianoclassic/ghostpiano/ui_state(mob/user)
	if(isobserver(user))
		return GLOB.observer_state
	. = ..()

/obj/structure/pianoclassic/ghostpiano/attack_ghost(mob/dead/observer/user)
	ui_interact(user)
