/obj/structure/girder
	name = "girder"
	icon_state = "girder"
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	var/state = GIRDER_NORMAL
	var/girderpasschance = 20 // percentage chance that a projectile passes through the girder.
	max_integrity = 200
	var/can_displace = TRUE //If the girder can be moved around by crowbarring it
	var/metalUsed = 2 //used to determine amount returned in deconstruction
	var/metal_type = /obj/item/stack/sheet/metal

/obj/structure/girder/examine(mob/user)
	. = ..()
	switch(state)
		if(GIRDER_REINF)
			. += "<span class='notice'>The support struts are <b>screwed</b> in place.</span>"
		if(GIRDER_REINF_STRUTS)
			. += "<span class='notice'>The support struts are <i>unscrewed</i> and the inner <b>grille</b> is intact.</span>"
		if(GIRDER_NORMAL)
			if(can_displace)
				. += "<span class='notice'>The bolts are <b>lodged</b> in place.</span>"
		if(GIRDER_DISPLACED)
			. += "<span class='notice'>The bolts are <i>loosened</i>, but the <b>screws</b> are holding [src] together.</span>"
		if(GIRDER_DISASSEMBLED)
			. += "<span class='notice'>[src] is disassembled! You probably shouldn't be able to see this examine message.</span>"

/obj/structure/girder/proc/refundMetal(metalAmount) //refunds metal used in construction when deconstructed
	for(var/i=0;i < metalAmount;i++)
		new metal_type(get_turf(src))

/obj/structure/girder/temperature_expose(datum/gas_mixture/air, exposed_temperature)
	..()
	var/temp_check = exposed_temperature
	if(temp_check >= GIRDER_MELTING_TEMP)
		take_damage(10)


/obj/structure/girder/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/gun/energy/plasmacutter))
		user.visible_message(
			span_notice("[user] start slicing apart [src] with [I]."),
			span_notice("You start slicing apart [src]..."),
		)
		I.play_tool_sound(src, 100)
		if(!do_after(user, 4 SECONDS * I.toolspeed, src, category = DA_CAT_TOOL))
			add_fingerprint(user)
			return ATTACK_CHAIN_PROCEED
		I.play_tool_sound(src, 100)
		user.visible_message(
			span_notice("[user] slices apart [src] with [I]."),
			span_notice("You have sliced apart [src]."),
		)
		refundMetal(metalUsed)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/pickaxe/drill/diamonddrill))
		user.visible_message(
			span_notice("[user] drills through [src] with [I]."),
			span_notice("You have drilled through [src]."),
		)
		I.play_tool_sound(src, 100)
		refundMetal(metalUsed)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/pickaxe/drill/jackhammer))
		user.visible_message(
			span_notice("[user] disintegrates [src] with [I]."),
			span_notice("You have disintegrated [src]."),
		)
		I.play_tool_sound(src, 100)
		refundMetal(metalUsed)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/twohanded/required/pyro_claws))
		user.visible_message(
			span_notice("[user] melts [src] with [I]."),
			span_notice("You have melted [src]."),
		)
		I.play_tool_sound(src, 100)
		refundMetal(metalUsed)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/pipe))
		add_fingerprint(user)
		var/obj/item/pipe/pipe = I
		if(!(pipe.pipe_type in list(0, 1, 5)))	//simple pipes, simple bends, and simple manifolds.
			to_chat(user, span_warning("This [pipe.name] is not compatible!"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(pipe, src))
			return ..()
		to_chat(user, span_notice("You fit the pipe into [src]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!isstack(I))
		return ..()

	. = ATTACK_CHAIN_PROCEED
	add_hiddenprint(user)
	var/obj/item/stack = I
	if(iswallturf(loc))
		to_chat(user, span_warning("There is already a wall present!"))
		return .
	if(!isfloorturf(loc))
		to_chat(user, span_warning("A floor must be present to build a false wall!"))
		return .
	if(locate(/obj/structure/clockwork) in loc.contents)
		to_chat(user, span_warning("There is a structure here!"))
		return .
	if(locate(/obj/structure/falsewall) in loc.contents)
		to_chat(user, span_warning("There is already a false wall present!"))
		return .
	if(istype(I, /obj/item/stack/sheet/runed_metal) || istype(I, /obj/item/stack/sheet/runed_metal_fake))
		to_chat(user, span_warning("You can't seem to make the metal bend."))
		return .

	if(istype(I, /obj/item/stack/rods))
		var/obj/item/stack/rods/rods = stack
		if(state == GIRDER_DISPLACED)
			if(rods.get_amount() < 5)
				to_chat(user, span_warning("You need at least five rods to create a false wall!"))
				return .
			to_chat(user, span_notice("You start building a reinforced false wall..."))
			if(!do_after(user, 2 SECONDS * rods.toolspeed, src, category = DA_CAT_TOOL) || state != GIRDER_DISPLACED || QDELETED(rods) || !rods.use(5))
				return .
			to_chat(user, span_notice("You created a false wall. Push on it to open or close the passage."))
			var/obj/structure/falsewall/iron/falsewall = new(loc)
			transfer_fingerprints_to(falsewall)
			falsewall.add_fingerprint(user)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(rods.get_amount() < 5)
			to_chat(user, span_warning("You need at least five rods to finalize the iron wall!"))
			return .
		to_chat(user, span_notice("You start adding plating..."))
		if(!do_after(user, 2 SECONDS * rods.toolspeed, src, category = DA_CAT_TOOL) || state == GIRDER_DISPLACED || !isfloorturf(loc) || QDELETED(rods) || !rods.use(5))
			return .
		to_chat(user, span_notice("You have finalized the metal wall."))
		var/turf/floor = loc
		floor.ChangeTurf(/turf/simulated/wall/mineral/iron)
		transfer_fingerprints_to(floor)
		floor.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/ore/glass/basalt))
		var/obj/item/stack/ore/glass/basalt/glass = stack
		if(state == GIRDER_DISPLACED)
			if(glass.get_amount() < 2)
				to_chat(user, span_warning("You need at least two piles of [glass] to create a false wall!"))
				return .
			to_chat(user, span_notice("You start building a false wall..."))
			if(!do_after(user, 2 SECONDS * glass.toolspeed, src, category = DA_CAT_TOOL) || state != GIRDER_DISPLACED || QDELETED(glass) || !glass.use(2))
				return .
			to_chat(user, span_notice("You created a false wall. Push on it to open or close the passage."))
			var/obj/structure/falsewall/mineral_ancient/falsewall = new(loc)
			transfer_fingerprints_to(falsewall)
			falsewall.add_fingerprint(user)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(glass.get_amount() < 2)
			to_chat(user, span_warning("You need at least two piles of [glass] to finalize the wall!"))
			return .
		to_chat(user, span_notice("You start adding [glass]..."))
		if(!do_after(user, 4 SECONDS * glass.toolspeed, src, category = DA_CAT_TOOL) || state == GIRDER_DISPLACED || !isfloorturf(loc) || QDELETED(glass) || !glass.use(2))
			return .
		to_chat(user, span_notice("You have finalized basalt wall."))
		var/turf/floor = loc
		floor.ChangeTurf(/turf/simulated/mineral/ancient)
		transfer_fingerprints_to(floor)
		floor.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	var/obj/item/stack/sheet/sheet = stack
	if(!istype(sheet, /obj/item/stack/sheet) || !sheet.wall_allowed)
		to_chat(user, span_warning("This material is not suitable for a wall."))
		return .

	if(istype(sheet, /obj/item/stack/sheet/wood))
		var/obj/item/stack/sheet/wood/wood = sheet
		if(state == GIRDER_DISPLACED)
			if(wood.get_amount() < 2)
				to_chat(user, span_warning("You need at least two planks of wood to create a false wall!"))
				return .
			to_chat(user, span_notice("You start building a false wall..."))
			if(!do_after(user, 2 SECONDS * wood.toolspeed, src, category = DA_CAT_TOOL) || state != GIRDER_DISPLACED || QDELETED(wood) || !wood.use(2))
				return .
			to_chat(user, span_notice("You created a false wall. Push on it to open or close the passage."))
			var/obj/structure/falsewall/wood/falsewall = new(loc)
			transfer_fingerprints_to(falsewall)
			falsewall.add_fingerprint(user)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(wood.get_amount() < 2)
			to_chat(user, span_warning("You need at least two planks of wood to finalize the wall!"))
			return .
		to_chat(user, span_notice("You start adding plating..."))
		if(!do_after(user, 4 SECONDS * wood.toolspeed, src, category = DA_CAT_TOOL) || state == GIRDER_DISPLACED || !isfloorturf(loc) || QDELETED(wood) || !wood.use(2))
			return .
		to_chat(user, span_notice("You have finalized the wooden wall."))
		var/turf/floor = loc
		floor.ChangeTurf(/turf/simulated/wall/mineral/wood)
		transfer_fingerprints_to(floor)
		floor.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(sheet, /obj/item/stack/sheet/metal))
		var/obj/item/stack/sheet/metal/metal = sheet
		if(state == GIRDER_DISPLACED)
			if(metal.get_amount() < 2)
				to_chat(user, span_warning("You need at least two sheets of metal to create a false wall!"))
				return .
			to_chat(user, span_notice("You start building a false wall..."))
			if(!do_after(user, 2 SECONDS * metal.toolspeed, src, category = DA_CAT_TOOL) || state != GIRDER_DISPLACED || QDELETED(metal) || !metal.use(2))
				return .
			to_chat(user, span_notice("You created a false wall. Push on it to open or close the passage."))
			var/obj/structure/falsewall/falsewall = new(loc)
			transfer_fingerprints_to(falsewall)
			falsewall.add_fingerprint(user)
			qdel(src)
			return ATTACK_CHAIN_BLOCKED_ALL

		if(metal.get_amount() < 2)
			to_chat(user, span_warning("You need at least two sheets of metal to finalize the wall!"))
			return .
		to_chat(user, span_notice("You start adding plating..."))
		if(!do_after(user, 4 SECONDS * metal.toolspeed, src, category = DA_CAT_TOOL) || state == GIRDER_DISPLACED || !isfloorturf(loc) || QDELETED(metal) || !metal.use(2))
			return .
		to_chat(user, span_notice("You have finalized the wall."))
		var/turf/floor = loc
		floor.ChangeTurf(/turf/simulated/wall)
		transfer_fingerprints_to(floor)
		floor.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(sheet, /obj/item/stack/sheet/plasteel))
		var/obj/item/stack/sheet/plasteel/plasteel = sheet
		switch(state)
			if(GIRDER_DISPLACED)
				if(plasteel.get_amount() < 2)
					to_chat(user, span_warning("You need at least two sheets of plasteel to create a false wall!"))
					return .
				to_chat(user, span_notice("You start building a false wall..."))
				if(!do_after(user, 2 SECONDS * plasteel.toolspeed, src, category = DA_CAT_TOOL) || state != GIRDER_DISPLACED || QDELETED(plasteel) || !plasteel.use(2))
					return .
				to_chat(user, span_notice("You created a reinforced false wall. Push on it to open or close the passage."))
				var/obj/structure/falsewall/reinforced/falsewall = new(loc)
				transfer_fingerprints_to(falsewall)
				falsewall.add_fingerprint(user)
				qdel(src)
				return ATTACK_CHAIN_BLOCKED_ALL

			if(GIRDER_REINF)
				if(plasteel.get_amount() < 2)
					to_chat(user, span_warning("You need at least two sheets of plasteel to finalize the reinforced wall!"))
					return .
				to_chat(user, span_notice("You start finalizing the reinforced wall..."))
				if(!do_after(user, 2 SECONDS * plasteel.toolspeed, src, category = DA_CAT_TOOL) || state != GIRDER_REINF || !isfloorturf(loc) || QDELETED(plasteel) || !plasteel.use(2))
					return .
				to_chat(user, span_notice("You have finalized the reinforced wall."))
				var/turf/floor = loc
				floor.ChangeTurf(/turf/simulated/wall/r_wall)
				transfer_fingerprints_to(floor)
				floor.add_fingerprint(user)
				qdel(src)
				return ATTACK_CHAIN_BLOCKED_ALL

			else
				if(plasteel.get_amount() < 2)
					to_chat(user, span_warning("You need at least two sheets of plasteel to reinforce the girder!"))
					return .
				to_chat(user, span_notice("You start reinforcing the girder..."))
				if(!do_after(user, 6 SECONDS * plasteel.toolspeed, src, category = DA_CAT_TOOL) || state == GIRDER_DISPLACED || state == GIRDER_REINF || QDELETED(plasteel) || !plasteel.use(2))
					return .
				to_chat(user, span_notice("You reinforce the girder."))
				var/obj/structure/girder/reinforced/girder = new(loc)
				transfer_fingerprints_to(girder)
				girder.add_fingerprint(user)
				qdel(src)
				return ATTACK_CHAIN_BLOCKED_ALL

	if(!sheet.sheettype)
		to_chat(user, span_warning("This material is not suitable for a wall."))
		return .

	var/cached_sheet_type = sheet.sheettype
	if(state == GIRDER_DISPLACED)
		if(sheet.get_amount() < 2)
			to_chat(user, span_warning("You need at least two sheets of [cached_sheet_type] to create a false wall!"))
			return .
		to_chat(user, span_notice("You start building a false wall..."))
		if(!do_after(user, 2 SECONDS * sheet.toolspeed, src, category = DA_CAT_TOOL) || state != GIRDER_DISPLACED || QDELETED(sheet) || !sheet.use(2))
			return .
		to_chat(user, span_notice("You created [cached_sheet_type] false wall. Push on it to open or close the passage."))
		var/falsewall_path = text2path("/obj/structure/falsewall/[cached_sheet_type]")
		var/obj/structure/falsewall/falsewall = new falsewall_path(loc)
		transfer_fingerprints_to(falsewall)
		falsewall.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(sheet.get_amount() < 2)
		to_chat(user, span_warning("You need at least two sheets of [cached_sheet_type] to add plating!"))
		return .
	to_chat(user, span_notice("You start adding plating..."))
	if(!do_after(user, 4 SECONDS * sheet.toolspeed, src, category = DA_CAT_TOOL) || state == GIRDER_DISPLACED || !isfloorturf(loc) || QDELETED(sheet) || !sheet.use(2))
		return .
	to_chat(user, span_notice("You have finalized the [cached_sheet_type] wall."))
	var/turf/floor = loc
	floor.ChangeTurf(text2path("/turf/simulated/wall/mineral/[cached_sheet_type]"))
	transfer_fingerprints_to(floor)
	floor.add_fingerprint(user)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/structure/girder/crowbar_act(mob/user, obj/item/I)
	if(!can_displace || state != GIRDER_NORMAL)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You start dislodging the girder...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_NORMAL)
		return
	to_chat(user, "<span class='notice'>You dislodge the girder.</span>")
	var/obj/structure/girder/displaced/D = new (loc)
	transfer_fingerprints_to(D)
	qdel(src)

/obj/structure/girder/screwdriver_act(mob/user, obj/item/I)
	if(state != GIRDER_DISPLACED && state != GIRDER_REINF && state != GIRDER_REINF_STRUTS)
		return
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	switch(state)
		if(GIRDER_DISPLACED)
			TOOL_ATTEMPT_DISMANTLE_MESSAGE
			if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_DISPLACED)
				return
			state = GIRDER_DISASSEMBLED
			TOOL_DISMANTLE_SUCCESS_MESSAGE
			var/obj/item/stack/sheet/metal/M = new(loc, 2)
			M.add_fingerprint(user)
			qdel(src)
		if(GIRDER_REINF)
			to_chat(user, "<span class='notice'>You start unsecuring support struts...</span>")
			if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_REINF)
				return
			to_chat(user, "<span class='notice'>You unsecure the support struts.</span>")
			state = GIRDER_REINF_STRUTS
		if(GIRDER_REINF_STRUTS)
			to_chat(user, "<span class='notice'>You start securing support struts...</span>")
			if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_REINF_STRUTS)
				return
			to_chat(user, "<span class='notice'>You secure the support struts.</span>")
			state = GIRDER_REINF

/obj/structure/girder/wirecutter_act(mob/user, obj/item/I)
	if(state != GIRDER_REINF_STRUTS)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	to_chat(user, "<span class='notice'>You start removing the inner grille...</span>")
	if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_REINF_STRUTS)
		return
	to_chat(user, "<span class='notice'>You remove the inner grille.</span>")
	new /obj/item/stack/sheet/plasteel(get_turf(src))
	var/obj/structure/girder/G = new (loc)
	transfer_fingerprints_to(G)
	qdel(src)

/obj/structure/girder/wrench_act(mob/user, obj/item/I)
	if(state != GIRDER_NORMAL && state != GIRDER_DISPLACED)
		return
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	if(state == GIRDER_NORMAL)
		TOOL_ATTEMPT_DISMANTLE_MESSAGE
		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_NORMAL)
			return
		state = GIRDER_DISASSEMBLED
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		refundMetal(metalUsed)
		qdel(src)
	else
		if(!isfloorturf(loc))
			to_chat(user, "<span class='warning'>A floor must be present to secure the girder!</span>")
			return
		to_chat(user, "<span class='notice'>You start securing the girder...</span>")
		if(!I.use_tool(src, user, 40, volume = I.tool_volume) || state != GIRDER_DISPLACED)
			return
		to_chat(user, "<span class='notice'>You secure the girder.</span>")
		var/obj/structure/girder/G = new(loc)
		transfer_fingerprints_to(G)
		qdel(src)

/obj/structure/girder/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.tool_use_check(user, 0))
		return
	WELDER_ATTEMPT_SLICING_MESSAGE
	if(I.use_tool(src, user, 40, volume = I.tool_volume))
		WELDER_SLICING_SUCCESS_MESSAGE
		refundMetal(metalUsed)
		qdel(src)


/obj/structure/girder/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	if(checkpass(mover, PASSGRILLE) || isprojectile(mover))
		return prob(girderpasschance)


/obj/structure/girder/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(pass_info.pass_flags == PASSEVERYTHING || (pass_info.pass_flags & PASSGRILLE))
		return TRUE
	return FALSE


/obj/structure/girder/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		var/remains = pick(/obj/item/stack/rods, /obj/item/stack/sheet/metal)
		new remains(loc)
	qdel(src)

/obj/structure/girder/narsie_act()
	if(prob(25))
		new /obj/structure/girder/cult(loc)
		qdel(src)

/obj/structure/girder/ratvar_act()
	if(prob(25))
		new /obj/structure/clockwork/wall_gear(loc)
		qdel(src)

/obj/structure/girder/displaced
	name = "displaced girder"
	icon_state = "displaced"
	anchored = FALSE
	state = GIRDER_DISPLACED
	girderpasschance = 25
	max_integrity = 120

/obj/structure/girder/reinforced
	name = "reinforced girder"
	icon_state = "reinforced"
	state = GIRDER_REINF
	girderpasschance = 0
	max_integrity = 350

/obj/structure/girder/cult
	name = "runed girder"
	desc = "Framework made of a strange and shockingly cold metal. It doesn't seem to have any bolts."
	icon = 'icons/obj/cult.dmi'
	icon_state = "cultgirder"
	can_displace = FALSE
	metalUsed = 1
	metal_type = /obj/item/stack/sheet/runed_metal

/obj/structure/girder/cult_fake
	name = "runed girder"
	desc = "Framework made of a strange and shockingly cold metal. It does seem to have bolts, wow."
	icon = 'icons/obj/cult.dmi'
	icon_state = "cultgirder"
	metalUsed = 1
	metal_type = /obj/item/stack/sheet/runed_metal_fake

/obj/structure/girder/cult/Initialize(mapload)
	. = ..()
	icon_state = SSticker.cultdat?.cult_girder_icon_state

/obj/structure/girder/cult_fake/Initialize(mapload)
	. = ..()
	icon_state = SSticker.cultdat?.cult_girder_icon_state


/obj/structure/girder/cult/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/melee/cultblade/dagger))
		if(!iscultist(user))	//Cultists can demolish cult girders instantly with their dagger
			return ..()
		user.visible_message(
			span_warning("[user] strikes [src] with [I]!"),
			span_notice("You demolish [src]."),
		)
		refundMetal(metalUsed)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/runed_metal))
		add_fingerprint(user)
		var/obj/item/stack/sheet/runed_metal/metal = I
		if(metal.get_amount() < 1)
			to_chat(user, span_warning("You need at least one sheet of runed metal to construct a runed wall!"))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] starts laying runed metal on [src]."),
			span_notice("You start constructing a runed wall..."),
		)
		if(!do_after(user, 1 SECONDS * metal.toolspeed, src, category = DA_CAT_TOOL) || !isfloorturf(loc) || QDELETED(metal) || !metal.use(1))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] plates [name] with runed metal."),
			span_notice("You have constructed the runed wall."),
		)
		var/turf/floor = loc
		floor.ChangeTurf(/turf/simulated/wall/cult)
		transfer_fingerprints_to(floor)
		floor.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/girder/cult_fake/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/melee/cultblade/dagger))
		if(!iscultist(user))	//Cultists can demolish cult girders instantly with their dagger
			return ..()
		user.visible_message(
			span_warning("[user] strikes [src] with [I]!"),
			span_notice("You demolish [src]."),
		)
		refundMetal(metalUsed)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/runed_metal_fake))
		add_fingerprint(user)
		var/obj/item/stack/sheet/runed_metal_fake/metal = I
		if(metal.get_amount() < 1)
			to_chat(user, span_warning("You need at least one sheet of runed metal to construct a runed wall!"))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] starts laying runed metal on [src]."),
			span_notice("You start constructing a runed wall..."),
		)
		if(!do_after(user, 1 SECONDS * metal.toolspeed, src, category = DA_CAT_TOOL) || !isfloorturf(loc) || QDELETED(metal) || !metal.use(1))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] plates [name] with runed metal."),
			span_notice("You have constructed the runed wall."),
		)
		var/turf/floor = loc
		floor.ChangeTurf(/turf/simulated/wall/cult_fake)
		transfer_fingerprints_to(floor)
		floor.add_fingerprint(user)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/girder/cult/narsie_act()
	return

/obj/structure/girder/cult/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NODECONSTRUCT))
		new /obj/item/stack/sheet/runed_metal(drop_location(), 1)
	qdel(src)
