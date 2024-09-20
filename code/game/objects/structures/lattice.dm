/obj/structure/lattice
	name = "lattice"
	desc = "A lightweight support lattice."
	icon = 'icons/obj/smooth_structures/lattice.dmi'
	icon_state = "lattice-31"
	base_icon_state = "lattice"
	density = FALSE
	anchored = TRUE
	armor = list("melee" = 50, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 80, "acid" = 50)
	max_integrity = 50
	layer = LATTICE_LAYER //under pipes
	plane = FLOOR_PLANE // I'd set to GAME_PLANE, but may fuck with pipes, srubbers and pumps. Also you see better lower floor under catwalk.
	var/number_of_rods = 1
	canSmoothWith = SMOOTH_GROUP_LATTICE + SMOOTH_GROUP_CATWALK + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_FLOOR
	smooth = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_LATTICE
	obj_flags = BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
	var/list/give_turf_traits = list(TRAIT_CHASM_STOPPED)


/obj/structure/lattice/Initialize(mapload)
	. = ..()
	for(var/obj/structure/lattice/LAT in loc)
		if(LAT != src)
			QDEL_IN(LAT, 0)
	if(length(give_turf_traits))
		give_turf_traits = string_list(give_turf_traits)
		AddElement(/datum/element/give_turf_traits, give_turf_traits)


/obj/structure/lattice/examine(mob/user)
	. = ..()
	. += deconstruction_hints(user)

/obj/structure/lattice/proc/deconstruction_hints(mob/user)
	return "<span class='notice'>The rods look like they could be <b>cut</b>. There's space for more <i>rods</i> or a <i>tile</i>.</span>"

/obj/structure/lattice/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	new /obj/item/stack/rods(get_turf(src), number_of_rods)
	deconstruct()

/obj/structure/lattice/deconstruct(disassembled)
	var/turf/O = get_turf(loc)
	..() //then we delete ourself proper way
	if(isopenspaceturf(O))
		for(var/atom/movable/movable in O)
			if(!movable.currently_z_moving)
				O.zFall(movable, falling_from_move = TRUE)

/obj/structure/lattice/catwalk/deconstruct()
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	..()


/obj/structure/lattice/attackby(obj/item/I, mob/user, params)
	if((resistance_flags & INDESTRUCTIBLE) || !isturf(loc))
		return ATTACK_CHAIN_BLOCKED_ALL
	add_fingerprint(user)
	I.melee_attack_chain(user, loc, params)	// hand this off to the turf instead (for building plating, catwalks, etc)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/structure/lattice/ratvar_act()
	new /obj/structure/lattice/clockwork(loc)
	qdel(src)

/obj/structure/lattice/blob_act(obj/structure/blob/B)
	return

/obj/structure/lattice/singularity_pull(S, current_size)
	if(current_size >= STAGE_FOUR)
		deconstruct()

/obj/structure/lattice/rcd_construct_act(mob/user, obj/item/rcd/our_rcd, rcd_mode)
	. = ..()
	if(rcd_mode != RCD_MODE_TURF)
		return RCD_NO_ACT
	if(our_rcd.useResource(1, user))
		to_chat(user, "Building Floor...")
		playsound(get_turf(our_rcd), our_rcd.usesound, 50, 1)
		var/turf/AT = get_turf(src)
		add_attack_logs(user, AT, "Constructed floor with RCD")
		AT.ChangeTurf(our_rcd.floor_type)
		return RCD_ACT_SUCCESSFULL
	to_chat(user, span_warning("ERROR! Not enough matter in unit to construct this floor!"))
	playsound(get_turf(our_rcd), 'sound/machines/click.ogg', 50, 1)
	return RCD_ACT_FAILED

/obj/structure/lattice/clockwork
	name = "cog lattice"
	desc = "A lightweight support lattice. These hold the Justicar's station together."
	icon = 'icons/obj/smooth_structures/lattice_clockwork.dmi'
	icon_state = "lattice_clockwork-0"
	base_icon_state = "lattice_clockwork"

/obj/structure/lattice/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()

/obj/structure/lattice/clockwork/ratvar_act()
	if((x + y) % 2 != 0)
		icon = 'icons/obj/smooth_structures/lattice_clockwork_large.dmi'
		pixel_x = -9
		pixel_y = -9
	else
		icon = 'icons/obj/smooth_structures/lattice_clockwork.dmi'
		pixel_x = 0
		pixel_y = 0
	return TRUE

/obj/structure/lattice/catwalk
	name = "catwalk"
	desc = "A catwalk for easier EVA maneuvering and cable placement."
	icon = 'icons/obj/smooth_structures/catwalk.dmi'
	icon_state = "catwalk-0"
	base_icon_state = "catwalk"
	number_of_rods = 2
	smooth = SMOOTH_BITMASK
	canSmoothWith = SMOOTH_GROUP_CATWALK
	smoothing_groups = SMOOTH_GROUP_CATWALK
	obj_flags = BLOCK_Z_OUT_DOWN | BLOCK_Z_IN_UP
	give_turf_traits = list(TRAIT_CHASM_STOPPED, TRAIT_TURF_IGNORE_SLOWDOWN)

/obj/structure/lattice/catwalk/deconstruction_hints(mob/user)
	to_chat(user, "<span class='notice'>The supporting rods look like they could be <b>cut</b>.</span>")

/obj/structure/lattice/catwalk/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	var/turf/T = loc
	for(var/obj/structure/cable/C in T)
		C.deconstruct()
	. = ..()

/obj/structure/lattice/catwalk/ratvar_act()
	new /obj/structure/lattice/catwalk/clockwork(loc)
	qdel(src)

/obj/structure/lattice/catwalk/clockwork
	name = "clockwork catwalk"
	icon = 'icons/obj/smooth_structures/catwalk_clockwork.dmi'
	base_icon_state = "catwalk_clockwork"
	icon_state = "catwalk_clockwork-0"
	smooth = SMOOTH_BITMASK

/obj/structure/lattice/catwalk/clockwork/Initialize(mapload)
	. = ..()
	ratvar_act()
	if(!mapload)
		new /obj/effect/temp_visual/ratvar/floor/catwalk(loc)
		new /obj/effect/temp_visual/ratvar/beam/catwalk(loc)

/obj/structure/lattice/catwalk/clockwork/ratvar_act()
	if((x + y) % 2 != 0)
		icon = 'icons/obj/smooth_structures/catwalk_clockwork_large.dmi'
		pixel_x = -9
		pixel_y = -9
	else
		icon = 'icons/obj/smooth_structures/catwalk_clockwork.dmi'
		pixel_x = 0
		pixel_y = 0
	return TRUE

/obj/structure/lattice/fireproof
	name = "fireproof lattice"
	desc = "A lightweight support lattice made of heat-resistance alloy."
	icon = 'icons/obj/smooth_structures/lattice_f.dmi'
	icon_state = "lattice-31"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 70, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 40, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70)
	max_integrity = 100

/obj/structure/lattice/fireproof/wirecutter_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>Вы начали срезать усиленные прутья, это займёт некоторое время...</span>")
	if(!I.use_tool(src, user, 20, volume = I.tool_volume))
		to_chat(user, "<span class='warning'>Вам необходимо не прерывать процесс.</span>")
		return
	to_chat(user, "<span class='notice'>Вы срезали усиленные прутья!</span>")
	new /obj/item/stack/fireproof_rods(get_turf(src), 1)
	deconstruct()

/obj/structure/lattice/catwalk/fireproof
	name = "strong catwalk"
	desc = "Усиленный мостик, способный выдерживать высокие температуры и сильные нагрузки."
	armor = list("melee" = 70, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 50, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 80)
	max_integrity = 150
	icon = 'icons/obj/smooth_structures/strong_catwalk.dmi'
	icon_state = "catwalk-0"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	number_of_rods = 3
	give_turf_traits = list(TRAIT_LAVA_STOPPED, TRAIT_CHASM_STOPPED, TRAIT_TURF_IGNORE_SLOWDOWN)


/obj/structure/lattice/catwalk/fireproof/wirecutter_act(mob/living/user, obj/item/I)
	to_chat(user, "<span class='notice'>Вы начали срезать усиленные прутья, это займёт некоторое время...</span>")
	if(!I.use_tool(src, user, 80, volume = I.tool_volume))
		to_chat(user, "<span class='warning'>Вам необходимо не прерывать процесс.</span>")
		return
	to_chat(user, "<span class='notice'>Вы срезали усиленный мостик!</span>")
	new /obj/item/stack/fireproof_rods(get_turf(src), 3)
	deconstruct()


/obj/structure/lattice/catwalk/mapping
	name = "reinforced catwalk"
	desc = "A heavily reinforced catwalk used to build bridges in hostile environments. It doesn't look like anything could make this budge."
	resistance_flags = INDESTRUCTIBLE
	icon = 'icons/obj/smooth_structures/strong_catwalk.dmi'
	base_icon_state = "catwalk"
	icon_state = "catwalk-0"
	give_turf_traits = list(TRAIT_LAVA_STOPPED, TRAIT_CHASM_STOPPED, TRAIT_TURF_IGNORE_SLOWDOWN)

/obj/structure/lattice/catwalk/mapping/deconstruction_hints(mob/user)
	return
