// Dead Ratvar
/obj/structure/dead_ratvar
	name = "hulking wreck"
	desc = "The remains of a monstrous war machine."
	icon = 'icons/obj/lavaland/dead_ratvar.dmi'
	icon_state = "dead_ratvar"
	flags = ON_BORDER
	appearance_flags = 0
	layer = FLY_LAYER
	anchored = TRUE
	density = TRUE
	bound_width = 416
	bound_height = 64
	pixel_y = -10
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/effect/clockwork
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF | FREEZE_PROOF

// An "overlay" used by clockwork walls and floors to appear normal to mesons.
/obj/effect/clockwork/overlay
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/atom/linked

/obj/effect/clockwork/overlay/examine(mob/user)
	if(linked)
		return linked.examine(user)

/obj/effect/clockwork/overlay/ex_act()
	return FALSE

/obj/effect/clockwork/overlay/singularity_act()
	return

/obj/effect/clockwork/overlay/singularity_pull()
	return

/obj/effect/clockwork/overlay/singularity_pull(S, current_size)
	return

/obj/effect/clockwork/overlay/Destroy()
	if(linked)
		linked = null
	. = ..()

/obj/effect/clockwork/overlay/wall
	name = "clockwork wall"
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall"
	canSmoothWith = list(/obj/effect/clockwork/overlay/wall, /obj/structure/falsewall/brass)
	smooth = SMOOTH_TRUE
	layer = CLOSED_TURF_LAYER

/obj/effect/clockwork/overlay/wall/Initialize(mapload)
	. = ..()
	queue_smooth_neighbors(src)
	addtimer(CALLBACK(GLOBAL_PROC, .proc/queue_smooth, src), 1)

/obj/effect/clockwork/overlay/wall/Destroy()
	queue_smooth_neighbors(src)
	return ..()

/obj/effect/clockwork/overlay/floor
	icon = 'icons/turf/floors.dmi'
	icon_state = "clockwork_floor"
	layer = TURF_LAYER
	plane = FLOOR_PLANE

//The base clockwork item. Can have an alternate desc and will show up in the list of clockwork objects.
/obj/item/clockwork
	resistance_flags = FIRE_PROOF | ACID_PROOF

//Shards of Alloy, suitable only as a source of power for a replica fabricator.
/obj/item/clockwork/alloy_shards
	name = "replicant alloy shard"
	desc = "A broken shard of some oddly malleable metal. It occasionally moves and seems to glow."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "alloy_shards"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/randomsinglesprite = FALSE
	var/randomspritemax = 2
	var/sprite_shift = 9

/obj/item/clockwork/alloy_shards/Initialize()
	. = ..()
	if(randomsinglesprite)
		icon_state = "[icon_state][rand(1, randomspritemax)]"
		pixel_x = rand(-sprite_shift, sprite_shift)
		pixel_y = rand(-sprite_shift, sprite_shift)

/obj/item/clockwork/clockgolem_remains
	name = "clockwork golem scrap"
	desc = "A pile of scrap metal. It seems damaged beyond repair."
	icon_state = "clockgolem_dead"

/obj/item/clockwork/alloy_shards/large
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	icon_state = "shard_large"
	sprite_shift = 9

/obj/item/clockwork/alloy_shards/medium
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	icon_state = "shard_medium"
	sprite_shift = 10

/obj/item/clockwork/alloy_shards/medium/gear_bit
	name = "gear bit"
	desc = "A broken chunk of a gear. You want it."
	randomspritemax = 4
	icon_state = "gear_bit"
	sprite_shift = 12

/obj/item/clockwork/alloy_shards/medium/gear_bit/large //gives more power
	name = "complex gear bit"

/obj/item/clockwork/alloy_shards/small
	w_class = WEIGHT_CLASS_TINY
	randomsinglesprite = TRUE
	randomspritemax = 3
	icon_state = "shard_small"
	sprite_shift = 12

/obj/item/clockwork/alloy_shards/pinion_lock
	name = "pinion lock"
	desc = "A dented and scratched gear. It's very heavy."
	icon_state = "pinion_lock"

//Components: Used in scripture.
/obj/item/clockwork/component
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/clockwork/component/belligerent_eye
	name = "belligerent eye"
	desc = "A brass construct with a rotating red center. It's as though it's looking for something to hurt."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "belligerent_eye"

/obj/item/clockwork/component/belligerent_eye/blind_eye
	name = "blind eye"
	desc = "A heavy brass eye, its red iris fallen dark."
	icon_state = "blind_eye"
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clockwork/component/geis_capacitor/fallen_armor
	name = "fallen armor"
	desc = "Lifeless chunks of armor. They're designed in a strange way and won't fit on you."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "fallen_armor"
	w_class = WEIGHT_CLASS_NORMAL
