/* Table Frames
 * Contains:
 *		Frames
 *		Wooden Frames
 */


/*
 * Normal Frames
 */

/obj/structure/table_frame
	name = "table frame"
	desc = "Four metal legs with four framing rods for a table. You could easily pass through this."
	icon = 'icons/obj/structures.dmi'
	icon_state = "table_frame"
	density = FALSE
	anchored = FALSE
	layer = PROJECTILE_HIT_THRESHHOLD_LAYER
	max_integrity = 100
	var/framestack = /obj/item/stack/rods
	var/framestackamount = 2


/obj/structure/table_frame/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	var/obj/item/stack/sheet = I
	if(istype(I, /obj/item/stack/sheet/plasteel))
		add_fingerprint(user)
		if(sheet.get_amount() < 1)
			to_chat(user, span_warning("You need at least one sheet of [sheet.name] to do this."))
			return ATTACK_CHAIN_PROCEED
		sheet.play_tool_sound(src)
		to_chat(user, span_notice("You start to add [sheet] to [src]..."))
		if(!do_after(user, 5 SECONDS * sheet.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(sheet) || !sheet.use(1))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have completed the construction of the reinforced table."))
		make_new_table(/obj/structure/table/reinforced)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/metal))
		add_fingerprint(user)
		if(sheet.get_amount() < 1)
			to_chat(user, span_warning("You need at least one sheet of [sheet.name] to do this."))
			return ATTACK_CHAIN_PROCEED
		sheet.play_tool_sound(src)
		to_chat(user, span_notice("You start to add [sheet] to [src]..."))
		if(!do_after(user, 2 SECONDS * sheet.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(sheet) || !sheet.use(1))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have completed the construction of the table."))
		make_new_table(/obj/structure/table)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/glass))
		add_fingerprint(user)
		if(sheet.get_amount() < 1)
			to_chat(user, span_warning("You need at least one sheet of [sheet.name] to do this."))
			return ATTACK_CHAIN_PROCEED
		sheet.play_tool_sound(src)
		to_chat(user, span_notice("You start to add [sheet] to [src]..."))
		if(!do_after(user, 2 SECONDS * sheet.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(sheet) || !sheet.use(1))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have completed the construction of the glass table."))
		make_new_table(/obj/structure/table/glass)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/tile/carpet))
		add_fingerprint(user)
		var/obj/item/stack/tile/carpet/carpet = I
		if(carpet.get_amount() < 1)
			to_chat(user, span_warning("You need at least one [carpet.name] to do this."))
			return ATTACK_CHAIN_PROCEED
		carpet.play_tool_sound(src)
		to_chat(user, span_notice("You start to add [carpet] to [src]..."))
		var/obj/cached_type = carpet.fancy_table_type
		var/cached_name = cached_type::name
		if(!do_after(user, 2 SECONDS * carpet.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(carpet) || !carpet.use(1))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have completed the construction of the [cached_name]."))
		make_new_table(cached_type)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/table_frame/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	TOOL_ATTEMPT_DISMANTLE_MESSAGE
	if(I.use_tool(src, user, 30, volume = I.tool_volume))
		TOOL_DISMANTLE_SUCCESS_MESSAGE
		for(var/i = 1, i <= framestackamount, i++)
			new framestack(get_turf(src))
		qdel(src)

/obj/structure/table_frame/proc/make_new_table(table_type) //makes sure the new table made retains what we had as a frame
	var/obj/structure/table/T = new table_type(loc)
	T.frame = type
	T.framestack = framestack
	T.framestackamount = framestackamount
	T.add_fingerprint(usr)
	qdel(src)

/obj/structure/table_frame/deconstruct(disassembled = TRUE)
	new framestack(get_turf(src), framestackamount)
	qdel(src)

/obj/structure/table_frame/narsie_act()
	new /obj/structure/table_frame/wood(loc)
	qdel(src)

/obj/structure/table_frame/ratvar_act()
	new /obj/structure/table_frame/brass(loc)
	qdel(src)

/*
 * Wooden Frames
 */

/obj/structure/table_frame/wood
	name = "wooden table frame"
	desc = "Four wooden legs with four framing wooden rods for a wooden table. You could easily pass through this."
	icon_state = "wood_frame"
	framestack = /obj/item/stack/sheet/wood
	framestackamount = 2
	resistance_flags = FLAMMABLE


/obj/structure/table_frame/wood/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/sheet/wood))
		add_fingerprint(user)
		var/obj/item/stack/sheet/wood/wood = I
		if(wood.get_amount() < 1)
			to_chat(user, span_warning("You need at least one sheet of wood to do this."))
			return ATTACK_CHAIN_PROCEED
		wood.play_tool_sound(src)
		to_chat(user, span_notice("You start to add [wood] to [src]..."))
		if(!do_after(user, 2 SECONDS * wood.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(wood) || !wood.use(1))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have completed the construction of the wooden table."))
		make_new_table(/obj/structure/table/wood)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/tile/carpet))
		add_fingerprint(user)
		var/obj/item/stack/tile/carpet/carpet = I
		if(carpet.get_amount() < 1)
			to_chat(user, span_warning("You need at least one [carpet.name] to do this."))
			return ATTACK_CHAIN_PROCEED
		carpet.play_tool_sound(src)
		to_chat(user, span_notice("You start to add [carpet] to [src]..."))
		if(!do_after(user, 2 SECONDS * carpet.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(carpet) || !carpet.use(1))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have completed the construction of the poker table."))
		make_new_table(/obj/structure/table/wood/poker)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/table_frame/brass
	name = "brass table frame"
	desc = "Four pieces of brass arranged in a square. It's slightly warm to the touch."
	icon_state = "brass_frame"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	framestack = /obj/item/stack/sheet/brass
	framestackamount = 1


/obj/structure/table_frame/brass/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/sheet/brass))
		add_fingerprint(user)
		var/obj/item/stack/sheet/brass/brass = I
		if(brass.get_amount() < 1)
			to_chat(user, span_warning("You need at least one sheet of brass to do this."))
			return ATTACK_CHAIN_PROCEED
		brass.play_tool_sound(src)
		to_chat(user, span_notice("You start to add [brass] to [src]..."))
		if(!do_after(user, 5 SECONDS * brass.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(brass) || !brass.use(1))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have completed the construction of the brass table."))
		make_new_table(/obj/structure/table/reinforced/brass)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/structure/table_frame/brass/narsie_act()
	..()
	if(src) //do we still exist?
		var/previouscolor = color
		color = COLOR_CULT_RED
		animate(src, color = previouscolor, time = 8)

/obj/structure/table_frame/brass/fake
	name = "brass table frame"
	desc = "Four pieces of brass arranged in a square. It's slightly warm to the touch, and not because of magic!"
	icon_state = "brass_frame"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	framestack = /obj/item/stack/sheet/brass_fake
	framestackamount = 1


/obj/structure/table_frame/brass/fake/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/sheet/brass_fake))
		add_fingerprint(user)
		var/obj/item/stack/sheet/brass_fake/brass = I
		if(brass.get_amount() < 1)
			to_chat(user, span_warning("You need at least one sheet of brass to do this."))
			return ATTACK_CHAIN_PROCEED
		brass.play_tool_sound(src)
		to_chat(user, span_notice("You start to add [brass] to [src]..."))
		if(!do_after(user, 5 SECONDS * brass.toolspeed, src, category = DA_CAT_TOOL) || QDELETED(brass) || !brass.use(1))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You have completed the construction of the brass table."))
		make_new_table(/obj/structure/table/reinforced/brass/fake)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

