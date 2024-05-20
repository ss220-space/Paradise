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

/obj/structure/ghostpiano
	parent_type = /obj/structure/musician
	name = "cursed piano"
	desc = "<span class=warning'> You feel an evil presence watching you </span> "
	icon = 'icons/obj/musician.dmi'
	icon_state = "minipiano"
	anchored = TRUE
	density = TRUE
	allowed_instrument_ids = "crgrand1"

/obj/structure/ghostpiano/New()
	..()
	set_light(3, -3, "F6E9D6")
	set_light(1, 5, "4A61D6")

/obj/structure/ghostpiano/attack_ghost(mob/dead/observer/user)
	ui_interact(user)