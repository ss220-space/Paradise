/obj/effect/decal/cleanable/generic
	name = "clutter"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/obj/objects.dmi'
	icon_state = "shards"

/obj/effect/decal/cleanable/ash
	name = "ashes"
	desc = "Ashes to ashes, dust to dust, and into space."
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "ash"
	anchored = TRUE
	scoop_reagents = list("ash" = 10)
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/dirt
	name = "dirt"
	desc = "Someone should clean that up."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/dirt.dmi'
	icon_state = "dirt"
	base_icon_state = "dirt"
	smoothing_groups = SMOOTH_GROUP_CLEANABLE_DIRT
	canSmoothWith = SMOOTH_GROUP_CLEANABLE_DIRT + SMOOTH_GROUP_WALLS
	smooth = SMOOTH_BITMASK
	mouse_opacity = FALSE

/obj/effect/decal/cleanable/dirt/Initialize(mapload)
	. = ..()
	icon_state = ""

/obj/effect/decal/cleanable/dust
	name = "dust"
	desc = "It's a little dusty. Someone should clean that up."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/dirt.dmi'
	icon_state = "dust"
	mouse_opacity = FALSE

/obj/effect/decal/cleanable/dirt/blackpowder
	name = "black powder"
	mouse_opacity = TRUE
	no_scoop = TRUE
	scoop_reagents = list("blackpowder" = 40) // size 2 explosion when activated

/obj/effect/decal/cleanable/flour
	name = "flour"
	desc = "It's still good. Four second rule!"
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"

/obj/effect/decal/cleanable/flour/foam
	name = "Fire fighting foam"
	desc = "It's foam."
	color = "#EBEBEB"

/obj/effect/decal/cleanable/flour/foam/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 15 SECONDS)

/obj/effect/decal/cleanable/greenglow
	name = "glowing goo"
	desc = "Jeez. I hope that's not for lunch."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	light_range = 1
	icon = 'icons/effects/effects.dmi'
	icon_state = "greenglow"

/obj/effect/decal/cleanable/greenglow/Initialize(mapload)
	. = ..()
	QDEL_IN(src, 2 MINUTES)

/obj/effect/decal/cleanable/greenglow/ex_act()
	return

/obj/effect/decal/cleanable/cobweb
	name = "cobweb"
	desc = "Somebody should remove that."
	density = FALSE
	anchored = TRUE
	layer = OBJ_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb1"
	resistance_flags = FLAMMABLE

/obj/effect/decal/cleanable/molten_object
	name = "gooey grey mass"
	desc = "It looks like a melted... something."
	density = FALSE
	anchored = TRUE
	layer = OBJ_LAYER
	gender = NEUTER
	icon = 'icons/effects/effects.dmi'
	icon_state = "molten"
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/molten_object/large
	name = "big gooey grey mass"
	icon_state = "big_molten"

/obj/effect/decal/cleanable/cobweb2
	name = "cobweb"
	desc = "Somebody should remove that."
	density = FALSE
	anchored = TRUE
	layer = OBJ_LAYER
	icon = 'icons/effects/effects.dmi'
	icon_state = "cobweb2"

/obj/effect/decal/cleanable/vomit
	name = "vomit"
	desc = "Gosh, how unpleasant."
	gender = PLURAL
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/blood.dmi'
	icon_state = "vomit_1"
	random_icon_states = list("vomit_1", "vomit_2", "vomit_3", "vomit_4")
	no_clear = TRUE
	scoop_reagents = list("vomit" = 5)

/obj/effect/decal/cleanable/vomit/green
	name = "green vomit"
	desc = "It's all gummy. Ew."
	icon_state = "gvomit_1"
	random_icon_states = list("gvomit_1", "gvomit_2", "gvomit_3", "gvomit_4")
	scoop_reagents = list("green_vomit" = 5)

/obj/effect/decal/cleanable/shreds
	name = "shreds"
	desc = "The shredded remains of what appears to be clothing."
	icon_state = "shreds"
	gender = PLURAL
	mergeable_decal = FALSE

/obj/effect/decal/cleanable/shreds/ex_act(severity, target)
	if(severity == 1) //so shreds created during an explosion aren't deleted by the explosion.
		qdel(src)

/obj/effect/decal/cleanable/shreds/Initialize(mapload)
	pixel_x = rand(-10, 10)
	pixel_y = rand(-10, 10)
	. = ..()

/obj/effect/decal/cleanable/tomato_smudge
	name = "tomato smudge"
	desc = "It's red."
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "tomato_floor1"
	random_icon_states = list("tomato_floor1", "tomato_floor2", "tomato_floor3")

/obj/effect/decal/cleanable/plant_smudge
	name = "plant smudge"
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	gender = NEUTER
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "smashed_plant"
	random_icon_states = list("smashed_plant")

/obj/effect/decal/cleanable/egg_smudge
	name = "smashed egg"
	desc = "Seems like this one won't hatch."
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "smashed_egg1"
	random_icon_states = list("smashed_egg1", "smashed_egg2", "smashed_egg3")

/obj/effect/decal/cleanable/pie_smudge //honk
	name = "smashed pie"
	desc = "It's pie cream from a cream pie."
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	icon = 'icons/effects/tomatodecal.dmi'
	icon_state = "smashed_pie"
	random_icon_states = list("smashed_pie")

/obj/effect/decal/cleanable/fungus
	name = "space fungus"
	desc = "A fungal growth. Looks pretty nasty."
	density = FALSE
	anchored = TRUE
	layer = TURF_LAYER
	plane = GAME_PLANE
	icon = 'icons/effects/effects.dmi'
	icon_state = "flour"
	color = "#D5820B"
	scoop_reagents = list("fungus" = 10)


/obj/effect/decal/cleanable/confetti //PARTY TIME!
	name = "confetti"
	desc = "Party time!"
	gender = PLURAL
	icon = 'icons/obj/objects.dmi'
	icon_state = "confetti1"
	random_icon_states = list("confetti1", "confetti2", "confetti3")
	anchored = TRUE
	mergeable_decal = FALSE


/**
 * Used for the confetti gibspawner, moves in a direction leaving a trail of confetti.
 */
/obj/effect/decal/cleanable/confetti/proc/streak(list/directions)
	set waitfor = FALSE

	var/direction = pick(directions)
	for(var/i in 0 to pick(0, 20;1)) //small chance of going farther than 1 tile
		sleep(2) //smooths movement
		if(i > 0)
			new /obj/effect/decal/cleanable/confetti(loc)
		if(!step_to(src, get_step(src, direction), 0))
			break


/obj/effect/decal/cleanable/insectguts
	name = "cockroach guts"
	desc = "One bug squashed. Four more will rise in its place."
	icon = 'icons/effects/blood.dmi'
	icon_state = "xfloor1"
	random_icon_states = list("xfloor1", "xfloor2", "xfloor3", "xfloor4", "xfloor5", "xfloor6", "xfloor7")
	anchored = TRUE

/obj/effect/decal/cleanable/glass
	name = "tiny shards"
	desc = "Back to sand."
	icon = 'icons/obj/shards.dmi'
	icon_state = "tiny"
	anchored = TRUE

/obj/effect/decal/cleanable/glass/plasma
	icon_state = "plasmatiny"

/obj/effect/decal/cleanable/ashrune
	name = "Ash rune"
	desc = "A rune drawn in ash."
	icon = 'icons/effects/ashwalker_rune.dmi'
	icon_state = "AshRuneFilled"
	anchored = TRUE
	mergeable_decal = FALSE
	mouse_opacity = MOUSE_OPACITY_ICON

/obj/effect/decal/cleanable/ashrune/ComponentInitialize()
	AddComponent( \
		/datum/component/ritual_object, \
		/datum/ritual/ashwalker, \
	)

/obj/effect/decal/cleanable/ashrune/is_cleanable()
	return FALSE
