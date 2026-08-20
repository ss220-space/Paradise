/obj/structure/logistics_construct
	name = "logistics pipe segment"
	desc = "Сегмент трубы для сборки логистической сети."
	icon = 'icons/obj/pipes_and_stuff/not_atmos/logistics.dmi'
	icon_state = "conlogi-s"
	pressure_resistance = 5 * ONE_ATMOSPHERE
	max_integrity = 200
	set_dir_on_move = FALSE
	var/obj/pipe_type = /obj/structure/logistics_pipe/segment
	var/pipename

/obj/structure/logistics_construct/get_ru_names()
	return alist(
		NOMINATIVE = "сегмент логистической трубы",
		GENITIVE = "сегмента логистической трубы",
		DATIVE = "сегменту логистической трубы",
		ACCUSATIVE = "сегмент логистической трубы",
		INSTRUMENTAL = "сегментом логистической трубы",
		PREPOSITIONAL = "сегменте логистической трубы",
	)

/obj/structure/logistics_construct/Initialize(mapload, pipe_define, dir = SOUTH, obj/made_from)
	. = ..()
	if(made_from)
		pipe_type = made_from.type
		setDir(made_from.dir)
	else
		if(ispath(pipe_define))
			pipe_type = pipe_define
		else if(isnum(pipe_define))
			pipe_type = define2type(pipe_define)
			if(pipe_define == PIPE_LOGISTICS_BENT)
				dir = turn(dir, -45)
		setDir(dir)
	pipename = initial(pipe_type.name)
	update_appearance(UPDATE_ICON_STATE)
	AddElement(/datum/element/undertile)

/obj/structure/logistics_construct/proc/define2type(value)
	switch(value)
		if(PIPE_LOGISTICS_STRAIGHT, PIPE_LOGISTICS_BENT)
			return /obj/structure/logistics_pipe/segment
		if(PIPE_LOGISTICS_JUNCTION_RIGHT)
			return /obj/structure/logistics_pipe/junction
		if(PIPE_LOGISTICS_JUNCTION_LEFT)
			return /obj/structure/logistics_pipe/junction/reversed
		if(PIPE_LOGISTICS_Y_JUNCTION)
			return /obj/structure/logistics_pipe/junction/yjunction
		if(PIPE_LOGISTICS_TRUNK)
			return /obj/structure/logistics_pipe/trunk
	return /obj/structure/logistics_pipe/segment

/obj/structure/logistics_construct/update_icon_state()
	icon_state = "con[initial(pipe_type.icon_state)]"
	return ..()

/obj/structure/logistics_construct/proc/get_logistics_dir()
	if(ISDIAGONALDIR(dir))
		return dir
	var/obj/structure/logistics_pipe/temp = pipe_type
	var/initialize_dirs = initial(temp.initialize_dirs)
	var/result = NONE
	if(initialize_dirs != DISP_DIR_NONE)
		result = dir
		if(initialize_dirs & DISP_DIR_LEFT)
			result |= turn(dir, 90)
		if(initialize_dirs & DISP_DIR_RIGHT)
			result |= turn(dir, -90)
		if(initialize_dirs & DISP_DIR_FLIP)
			result |= REVERSE_DIR(dir)
	return result

/obj/structure/logistics_construct/examine(mob/user)
	. = ..()
	. += span_notice("<b>Alt-Click</b> to rotate it, <b>Alt-Shift-Click</b> to flip it.")

/obj/structure/logistics_construct/verb/rotate_verb()
	set category = VERB_CATEGORY_OBJECT
	set name = "Повернуть трубу"
	set src in view(1)
	rotate(usr)

/obj/structure/logistics_construct/click_alt(mob/user)
	rotate(user)
	return CLICK_ACTION_SUCCESS

/obj/structure/logistics_construct/proc/rotate(mob/user)
	if(user && (user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)))
		to_chat(user, span_warning("You can't do that right now!"))
		return FALSE
	if(anchored)
		if(user)
			to_chat(user, span_warning("You must unfasten the [pipename] before rotating it."))
		return FALSE
	add_fingerprint(user)
	setDir(turn(dir, -90))
	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/obj/structure/logistics_construct/verb/flip_verb()
	set category = VERB_CATEGORY_OBJECT
	set name = "Перевернуть трубу"
	set src in view(1)
	flip(usr)

/obj/structure/logistics_construct/AltShiftClick(mob/user)
	if(Adjacent(user))
		flip(user)

/obj/structure/logistics_construct/proc/flip(mob/user)
	if(user && (user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED)))
		to_chat(user, span_warning("You can't do that right now!"))
		return FALSE
	if(anchored)
		if(user)
			to_chat(user, span_warning("You must unfasten the [pipename] before flipping it."))
		return FALSE
	add_fingerprint(user)
	setDir(turn(dir, 180))
	var/obj/structure/logistics_pipe/temp = pipe_type
	if(initial(temp.flip_type))
		pipe_type = initial(temp.flip_type)
	update_appearance(UPDATE_ICON_STATE)
	return TRUE

/obj/structure/logistics_construct/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	var/turf/our_turf = loc
	if(!isturf(our_turf))
		return
	if(HAS_TRAIT(src, TRAIT_UNDERFLOOR))
		to_chat(user, span_warning("You can only [anchored ? "detach" : "attach"] the [pipename] if the floor plating is removed."))
		return FALSE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	if(anchored)
		set_anchored(FALSE)
		to_chat(user, "You detach the [pipename] from the underfloor.")
	else
		var/dpdir = get_logistics_dir()
		for(var/obj/structure/logistics_pipe/pipe in our_turf)
			if(pipe.dpdir & dpdir)
				to_chat(user, span_warning("There is already a logistics pipe at that location!"))
				return TRUE
		set_anchored(TRUE)
		to_chat(user, "You attach the [pipename] to the underfloor.")
	update_appearance(UPDATE_ICON_STATE)

/obj/structure/logistics_construct/welder_act(mob/living/user, obj/item/I)
	. = TRUE
	var/turf/our_turf = loc
	if(!isturf(our_turf))
		return
	if(HAS_TRAIT(src, TRAIT_UNDERFLOOR))
		to_chat(user, span_warning("You can only weld the [pipename] if the floor plating is removed."))
		return
	if(!anchored)
		to_chat(user, span_warning("You need to attach [pipename] to the plating first!"))
		return
	if(!I.use_tool(src, user, 2 SECONDS, volume = I.tool_volume) || !anchored)
		return
	to_chat(user, "The [pipename] has been welded in place!")
	var/obj/built = new pipe_type(loc, src)
	transfer_fingerprints_to(built)
	qdel(src)

/obj/structure/logistics_construct/rpd_act(mob/user, obj/item/rpd/our_rpd, mode)
	. = TRUE
	switch(mode)
		if(RPD_ROTATE_MODE)
			rotate()
		if(RPD_FLIP_MODE)
			flip()
		if(RPD_DELETE_MODE)
			our_rpd.delete_single_pipe(user, src)
		else
			return ..()

/obj/structure/logistics_construct/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	if(anchored)
		level = 1
		layer = initial(pipe_type.layer)
	else
		level = 2
		layer = initial(layer)
