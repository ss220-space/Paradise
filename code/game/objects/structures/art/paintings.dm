/*
 * Canvas & drawing system, ported from /tg/station (grid-based version) onto Paradise master220.
 * Scope: drawing only. The cross-round persistence subsystem, patron/curator credit economy,
 * museum and painting-copy machinery were intentionally NOT ported (see heretic-port notes).
 *
 * Paint tools provide a hex colour via get_paint_tool_color(): the palette (full 24-bit colour),
 * crayons (their fixed colour) and soap/rag (erase to the blank canvas colour).
 */

#define MAX_PAINTING_ZOOM_OUT 3


/// Lightweight metadata for a painting. The persistence-related fields are kept inert for compat.
/datum/painting
	/// Title of the artwork.
	var/title = "Untitled Artwork"
	/// Real name of whoever finalized the painting.
	var/creator_name
	/// Ckey of whoever finalized the painting.
	var/creator_ckey
	/// Patron name (economy unported - stays null).
	var/patron_name
	/// Patron ckey (economy unported - stays null).
	var/patron_ckey
	/// Human-readable description of the medium used (oil, crayon, ink...).
	var/medium
	/// In-world date the painting was finalized.
	var/creation_date
	/// Round id the painting was created in.
	var/creation_round_id
	/// Grid width.
	var/width = 11
	/// Grid height.
	var/height = 11
	/// md5 of the raw pixel data, used to dedupe.
	var/md5
	/// Frame appearance variant key (matches the frame_* states in artstuff.dmi).
	var/frame_type = "simple"
	/// Always FALSE here - we don't load paintings from json persistence.
	var/loaded_from_json = FALSE
	/// Patronage value (economy unported - stays 0).
	var/credit_value = 0


// --- Painting tool colour hooks ---------------------------------------------
// Base no-op; specific tools override to remember the chosen colour.

/obj/item/proc/set_painting_tool_color(chosen_color)
	return

/// Common helper for tools that can access the entire colour space (palette).
/obj/item/proc/pick_painting_tool_color(mob/living/carbon/human/user, default_color)
	var/chosen_color = input(user, "Выберите цвет", "[src]", default_color) as color|null
	if(!chosen_color || QDELETED(src) || IS_DEAD_OR_INCAP(user) || !user.is_holding(src))
		return

	set_painting_tool_color(chosen_color)

/obj/item/toy/crayon/set_painting_tool_color(chosen_color)
	colour = chosen_color


///////////
// EASEL //
///////////

/obj/structure/easel
	name = "мольберт"
	ru_names = alist(
		NOMINATIVE = "мольберт",
		GENITIVE = "мольберта",
		DATIVE = "мольберту",
		ACCUSATIVE = "мольберт",
		INSTRUMENTAL = "мольбертом",
		PREPOSITIONAL = "мольберте"
	)
	desc = "Только для лучших произведений искусства!"
	gender = MALE
	icon = 'icons/obj/art/artstuff.dmi'
	icon_state = "easel"
	density = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 60
	var/obj/item/canvas/painting = null


//Adding canvases
/obj/structure/easel/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(!istype(I, /obj/item/canvas))
		return ..()

	var/obj/item/canvas/canvas = I
	user.drop_transfer_item_to_loc(canvas, get_turf(src), silent = FALSE)
	painting = canvas
	canvas.layer = layer + 0.1
	user.visible_message(span_notice("[user] ставит [canvas] на [src]."), span_notice("Вы ставите [canvas] на [src]."))
	return ATTACK_CHAIN_BLOCKED_ALL


//Stick to the easel like glue
/obj/structure/easel/Move()
	var/turf/turf = get_turf(src)
	. = ..()
	if(painting && painting.loc == turf) //Only move if it's near us.
		painting.forceMove(get_turf(src))
		return

	painting = null


////////////
// CANVAS //
////////////

/obj/item/canvas
	name = "холст"
	ru_names = alist(
		NOMINATIVE = "холст",
		GENITIVE = "холста",
		DATIVE = "холсту",
		ACCUSATIVE = "холст",
		INSTRUMENTAL = "холстом",
		PREPOSITIONAL = "холсте"
	)
	desc = "Нарисуйте свою душу на этом холсте!"
	gender = MALE
	icon = 'icons/obj/art/artstuff.dmi'
	icon_state = "11x11"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	var/width = 11
	var/height = 11
	var/list/grid
	/// empty canvas color
	var/canvas_color = "#ffffff"
	/// Is it clean canvas or was there something painted on it at some point, used to decide when to show wip splotch overlay
	var/used = FALSE
	var/finalized = FALSE //Blocks edits
	/// Whether a grid should be shown in the UI if the canvas is editable and the viewer is holding a painting tool.
	var/show_grid = TRUE
	var/icon_generated = FALSE
	var/icon/generated_icon
	var/datum/painting/painting_metadata

	// Painting overlay offset when framed
	var/framed_offset_x = 11
	var/framed_offset_y = 10

	/**
	 * How big the grid cells that compose the painting are in the UI (multiplied by zoom).
	 * This impacts the size of the UI, so smaller values are generally better for bigger canvases and vice-versa
	 */
	var/pixels_per_unit = 9

	///A list that keeps track of the current zoom value for each current viewer.
	var/list/zoom_by_observer

	SET_BASE_PIXEL(11, 10)


/obj/item/canvas/Initialize(mapload)
	. = ..()
	reset_grid()
	// The painting is drawn as a differently-sized, pixel-offset overlay using a runtime-generated icon.
	// Without KEEP_TOGETHER, Paradise's plane-master renderer treats it as a separate render unit and it
	// never shows on the object - the canvas stays blank. KEEP_TOGETHER flattens object + overlay into one
	// sprite so the art actually appears (matches TG's ADD_KEEP_TOGETHER on the canvas).
	appearance_flags |= KEEP_TOGETHER

	painting_metadata = new
	painting_metadata.title = "Untitled Artwork"
	painting_metadata.creation_round_id = GLOB.round_id
	painting_metadata.width = width
	painting_metadata.height = height


/obj/item/canvas/Destroy()
	painting_metadata = null
	return ..()


/obj/item/canvas/proc/reset_grid()
	grid = new /list(width, height)
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			grid[x][y] = canvas_color


/obj/item/canvas/attack_self(mob/user)
	. = ..()
	ui_interact(user)


/obj/item/canvas/ui_host(mob/user)
	if(istype(loc, /obj/structure/sign/painting))
		return loc

	return ..()


/obj/item/canvas/ui_state(mob/user)
	if(isobserver(user))
		return GLOB.observer_state

	if(finalized)
		return GLOB.physical_state

	return GLOB.default_state


/obj/item/canvas/ui_status(mob/user, datum/ui_state/state)
	if(state == GLOB.default_state || !state)
		return ..()

	//Skip the can_interact() check from atom/ui_status() and let them zoom in/out!
	var/src_object = ui_host(user)
	return state.can_use_topic(src_object, user)


/obj/item/canvas/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(ui)
		return

	ui = new(user, src, "Canvas", name)
	ui.open()


/obj/item/canvas/attackby(obj/item/I, mob/living/user, list/modifiers, list/attack_modifiers)
	if(user.a_intent == INTENT_HARM)
		return ..()

	ui_interact(user)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/item/canvas/ui_static_data(mob/user)
	. = ..()
	.["px_per_unit"] = pixels_per_unit
	.["max_zoom"] = MAX_PAINTING_ZOOM_OUT


/obj/item/canvas/ui_data(mob/user)
	. = ..()
	.["grid"] = grid
	.["zoom"] = LAZYACCESS(zoom_by_observer, user.key) || (finalized ? 1 : MAX_PAINTING_ZOOM_OUT)
	.["name"] = painting_metadata.title
	.["author"] = painting_metadata.creator_name
	.["patron"] = painting_metadata.patron_name
	.["medium"] = painting_metadata.medium
	.["date"] = painting_metadata.creation_date
	.["finalized"] = finalized
	.["editable"] = !finalized
	.["show_plaque"] = istype(loc, /obj/structure/sign/painting)
	.["show_grid"] = show_grid
	var/obj/item/painting_implement = user.get_active_hand()
	if(!painting_implement)
		.["paint_tool_color"] = null
		.["paint_tool_palette"] = null
		.["palette_can_add"] = FALSE
		return

	.["paint_tool_color"] = get_paint_tool_color(painting_implement)
	.["paint_tool_palette"] = get_paint_tool_palette(painting_implement)
	// Whether the palette has room for another colour (drives the "+" button's enabled state, like tg).
	var/obj/item/paint_palette/palette = painting_implement
	.["palette_can_add"] = istype(palette) && length(palette.palette_colors) < palette.max_colors


/obj/item/canvas/examine(mob/user)
	. = ..()
	ui_interact(user)


/obj/item/canvas/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if(isobserver(usr))
		return FALSE

	var/mob/living/carbon/human/user = usr
	switch(action)
		if("paint", "fill")
			if(finalized)
				return TRUE

			var/obj/item/I = user.get_active_hand()
			var/tool_color = get_paint_tool_color(I)
			if(!tool_color)
				return FALSE

			if(action == "fill")
				var/x = params["x"]
				var/y = params["y"]
				if(!canvas_fill(x, y, tool_color))
					return FALSE

			else
				var/list/data = params["data"]
				for(var/point in data)
					var/x = text2num(point["x"])
					var/y = text2num(point["y"])
					grid[x][y] = tool_color

			var/medium = get_paint_tool_medium(I)
			if(medium && painting_metadata.medium && painting_metadata.medium != medium)
				painting_metadata.medium = "Смешанная техника"
			else
				painting_metadata.medium = medium
			used = TRUE
			// Bake the actual drawing onto the canvas right away so it's visible on the object itself
			// (e.g. lying on the floor) without having to be finalized — not just a generic splotch.
			bake_drawing()
			. = TRUE

		if("select_color")
			var/obj/item/painting_implement = user.get_active_hand()
			painting_implement?.set_painting_tool_color(params["selected_color"])
			. = TRUE

		if("select_color_from_coords")
			var/obj/item/painting_implement = user.get_active_hand()
			if(!painting_implement)
				return FALSE

			var/x = text2num(params["x"])
			var/y = text2num(params["y"])
			painting_implement.set_painting_tool_color(grid[x][y])
			. = TRUE

		if("change_palette")
			// Right-click on a palette swatch: recolour that specific slot. Only the multi-colour palette
			// has slots; for any other tool there's nothing to change.
			var/obj/item/paint_palette/palette = user.get_active_hand()
			if(!istype(palette))
				return FALSE
			var/chosen_color = input(user, "Выберите новый цвет", palette, params["old_color"]) as color|null
			if(!chosen_color || IS_DEAD_OR_INCAP(user) || !user.is_holding(palette))
				return FALSE

			palette.change_palette_color(text2num(params["color_index"]), chosen_color)
			. = TRUE

		if("add_palette_color")
			// The "+" button: pick a colour and append a new slot (up to the palette's capacity), like tg.
			var/obj/item/paint_palette/palette = user.get_active_hand()
			if(!istype(palette) || length(palette.palette_colors) >= palette.max_colors)
				return FALSE
			var/chosen_color = input(user, "Выберите цвет для добавления", palette, COLOR_WHITE) as color|null
			if(!chosen_color || IS_DEAD_OR_INCAP(user) || !user.is_holding(palette))
				return FALSE

			palette.add_palette_color(chosen_color)
			. = TRUE

		if("remove_palette_color")
			// Right-click the "+" button removes a slot (tg lets you trim the palette; we keep at least one).
			var/obj/item/paint_palette/palette = user.get_active_hand()
			if(!istype(palette))
				return FALSE

			palette.remove_palette_color(text2num(params["color_index"]))
			. = TRUE

		if("toggle_grid")
			. = TRUE
			show_grid = !show_grid

		if("finalize")
			. = TRUE
			finalize(user)

		if("zoom_in")
			. = TRUE
			LAZYINITLIST(zoom_by_observer)
			if(!zoom_by_observer[user.key])
				zoom_by_observer[user.key] = 2
			else
				zoom_by_observer[user.key] = min(zoom_by_observer[user.key] + 1, MAX_PAINTING_ZOOM_OUT)

		if("zoom_out")
			. = TRUE
			LAZYINITLIST(zoom_by_observer)
			if(!zoom_by_observer[user.key])
				zoom_by_observer[user.key] = MAX_PAINTING_ZOOM_OUT - 1
			else
				zoom_by_observer[user.key] = max(zoom_by_observer[user.key] - 1, 1)


/obj/item/canvas/ui_close(mob/user)
	. = ..()
	LAZYREMOVE(zoom_by_observer, user.key)


/obj/item/canvas/proc/finalize(mob/user)
	if(finalized)
		return

	if(!try_rename(user))
		return

	painting_metadata.creator_ckey = user.ckey
	painting_metadata.creator_name = user.real_name
	painting_metadata.creation_date = time2text(world.realtime, "DDD MMM DD hh:mm:ss YYYY")
	painting_metadata.creation_round_id = GLOB.round_id
	generate_proper_overlay()
	finalized = TRUE

	SStgui.update_uis(src)


/obj/item/canvas/update_overlays()
	. = ..()
	if(icon_generated)
		// Offset the painting with pixel_w/pixel_z (the "bound" world-pixel offsets), exactly like tg. Plain
		// pixel_x/pixel_y trip /atom/update_icon's float-layer guard and get dropped by Paradise's plane-master
		// renderer so the canvas shows blank on the floor. KEEP_TOGETHER (set in Initialize) flattens the
		// overlay onto the canvas.
		// Leave the overlay on the default FLOAT_LAYER (no explicit layer = layer): FLOAT_LAYER inherits the
		// parent's layer AND plane, so the painting also composites in the HUD hand slot. Hardcoding the
		// world-space object layer made the overlay render on the floor but get dropped on the HUD plane, so a
		// held canvas showed only the blank white base sprite. The float-layer guard only fires for pixel_x/
		// pixel_y, which we never set, so FLOAT_LAYER is safe here.
		var/mutable_appearance/detail = mutable_appearance(generated_icon)
		detail.pixel_w = 1
		detail.pixel_z = 1
		. += detail
		return

	if(!used)
		return

	var/mutable_appearance/detail = mutable_appearance(icon, "[icon_state]wip")
	detail.pixel_w = 1
	detail.pixel_z = 1
	. += detail


/obj/item/canvas/proc/generate_proper_overlay()
	bake_drawing()

/**
 * (Re)bakes the actual drawing onto the canvas object as an overlay from the current grid.
 *
 * Called as a live preview every time the canvas is painted (so a work-in-progress painting shows its
 * real art on the object itself — lying on the floor, in hand, on an easel — instead of only the generic
 * "wip" splotch), and once more when the painting is finalized.
 */
/obj/item/canvas/proc/bake_drawing()
	// Persistence subsystem (which created data/paintings/) isn't ported; use the always-present data/ root.
	var/png_filename = "data/temp_painting.png"
	var/image_data = get_data_string()
	var/result = rustg_dmi_create_png(png_filename, "[width]", "[height]", image_data)
	if(result)
		CRASH("Error generating painting png : [result]")
	painting_metadata.md5 = md5(LOWER_TEXT(image_data))
	// Load through fcopy_rsc(): the scratch file is always written under the same name, and
	// new/icon(path) caches the runtime resource by filename - it won't refresh on rewrite and
	// the icon never reaches clients, so the painting renders blank on the floor. fcopy_rsc()
	// caches by content, giving a fresh, properly-transmitted icon on every (re)bake.
	generated_icon = new(fcopy_rsc(png_filename))
	icon_generated = TRUE
	update_appearance()


/obj/item/canvas/proc/get_data_string()
	var/list/data = list()
	for(var/y in 1 to height)
		for(var/x in 1 to width)
			data += grid[x][y]

	return data.Join("")


/obj/item/canvas/proc/get_paint_tool_color(obj/item/painting_implement)
	if(!painting_implement)
		return

	if(istype(painting_implement, /obj/item/paint_palette))
		var/obj/item/paint_palette/palette = painting_implement
		return palette.current_color

	if(istype(painting_implement, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon = painting_implement
		return crayon.colour

	if(istype(painting_implement, /obj/item/soap) || istype(painting_implement, /obj/item/reagent_containers/glass/rag))
		return canvas_color


/// Returns the palette's selectable colour slots for the UI, or null for tools without a palette.
/// Each entry is list("color" = hex, "is_selected" = whether it's the active paint colour).
/obj/item/canvas/proc/get_paint_tool_palette(obj/item/painting_implement)
	if(!istype(painting_implement, /obj/item/paint_palette))
		return null

	var/obj/item/paint_palette/palette = painting_implement
	var/list/data = list()
	for(var/swatch_color in palette.palette_colors)
		data += list(list("color" = swatch_color, "is_selected" = (swatch_color == palette.current_color)))

	return data


/// Generates medium description
/obj/item/canvas/proc/get_paint_tool_medium(obj/item/painting_implement)
	if(!painting_implement)
		return

	if(istype(painting_implement, /obj/item/paint_palette))
		return "Масло на холсте"

	if(istype(painting_implement, /obj/item/toy/crayon))
		return "Следы мелка на холсте"

	if(istype(painting_implement, /obj/item/soap) || istype(painting_implement, /obj/item/reagent_containers/glass/rag))
		return //These are just for cleaning, ignore them

	return "Неизвестный материал"


/obj/item/canvas/proc/try_rename(mob/user)
	var/new_name = tgui_input_text(user, "Как вы хотите назвать картину?", "Назовите свой шедевр", max_length = MAX_NAME_LEN)
	if(isnull(new_name))
		return FALSE

	if(new_name != painting_metadata.title && user.can_perform_action(src))
		painting_metadata.title = new_name

	switch(tgui_alert(user, "Хотите ли вы оставить подпись или остаться анонимным?", "Подписать рисунок?", list("Да", "Нет", "Отмена")))
		if("Да")
			return TRUE

		if("Нет")
			painting_metadata.creator_name = "Аноним"
			return TRUE

	return FALSE


///The pixel to the right matches the previous color we're flooding over
#define CANVAS_FILL_R_MATCH (1<<0)
///The pixel to the left matches the previous color we're flooding over
#define CANVAS_FILL_L_MATCH (1<<1)

//a macro for the stringized key for coordinates to check later
#define CANVAS_COORD(x, y) "[x]-[y]"
///queues a coordinate on the canvas for future cycles.
#define QUEUE_CANVAS_COORD(x, y, queue) \
	if(y && !queue[CANVAS_COORD(x, y)]) {\
		queue[CANVAS_COORD(x, y)] = list(x, y);\
	}

/**
 * Span-based 4-dir flood fill used by the bucket tool in the UI.
 */
/obj/item/canvas/proc/canvas_fill(x, y, new_color)
	var/prev_color = grid[x][y]
	if(prev_color == new_color)
		return FALSE

	var/list/queue_right = list()
	var/list/queue_left = list()
	var/go_right = TRUE
	var/list/coords = list(x, y)

	while(coords)
		var/list/curr_line = grid[x]
		var/list/right_line = x < width ? grid[x+1] : null
		var/list/left_line = x > 1 ? grid[x-1] : null
		var/list/curr_queue = go_right ? queue_right : queue_left
		var/r_line_start
		var/l_line_start

		//go up first (y = 1 is the upper border)
		while(y >= 1 && curr_line[y] == prev_color)
			var/return_flags = canvas_scan_step(x, y, queue_left, queue_right, left_line, right_line, l_line_start, r_line_start, prev_color)
			if(return_flags & CANVAS_FILL_R_MATCH)
				r_line_start = y
			else
				r_line_start = null

			if(return_flags & CANVAS_FILL_L_MATCH)
				l_line_start = y
			else
				l_line_start = null

			curr_line[y] = new_color
			curr_queue -= CANVAS_COORD(x, y)
			y--

		QUEUE_CANVAS_COORD(x + 1, r_line_start, queue_right)
		QUEUE_CANVAS_COORD(x - 1, l_line_start, queue_left)
		r_line_start = l_line_start = null

		//set y to the pixel immediately below the starting y
		y = coords[2] + 1

		//then go down (y = height is the bottom border)
		while(y <= height && curr_line[y] == prev_color)
			var/return_flags = canvas_scan_step(x, y, queue_left, queue_right, left_line, right_line, l_line_start, r_line_start, prev_color)
			if(!(return_flags & CANVAS_FILL_R_MATCH))
				r_line_start = null
			else if(!r_line_start)
				r_line_start = y

			if(!(return_flags & CANVAS_FILL_L_MATCH))
				l_line_start = null
			else if(!l_line_start)
				l_line_start = y

			curr_line[y] = new_color
			curr_queue -= CANVAS_COORD(x, y)
			y++

		QUEUE_CANVAS_COORD(x + 1, r_line_start, queue_right)
		QUEUE_CANVAS_COORD(x - 1, l_line_start, queue_left)

		//Pick the next set of coords from the queue (and change direction if necessary)
		if(!length(curr_queue))
			var/list/other_queue = go_right ? queue_left : queue_right
			coords = other_queue[other_queue[1]]
			other_queue.Cut(1, 2)
			go_right = !go_right
		else
			coords = curr_queue[curr_queue[1]]
			curr_queue.Cut(1, 2)

		x = coords?[1]
		y = coords?[2]

	return TRUE


/**
 * The step of canvas_fill() that scans the pixels to the immediate right and left of our coord.
 */
/proc/canvas_scan_step(x, y, list/queue_left, list/queue_right, list/left_line, list/right_line, left_pos, right_pos, prev_color)
	if(left_line)
		if(left_line[y] == prev_color)
			. += CANVAS_FILL_L_MATCH
		else
			QUEUE_CANVAS_COORD(x - 1, left_pos, queue_left)

	if(!right_line)
		return

	if(right_line[y] == prev_color)
		. += CANVAS_FILL_R_MATCH
	else
		QUEUE_CANVAS_COORD(x + 1, right_pos, queue_right)


#undef CANVAS_FILL_R_MATCH
#undef CANVAS_FILL_L_MATCH
#undef CANVAS_COORD
#undef QUEUE_CANVAS_COORD


// --- Canvas sizes -----------------------------------------------------------

/obj/item/canvas/nineteen_nineteen
	name = "холст (19x19)"
	ru_names = alist(
		NOMINATIVE = "холст (19x19)",
		GENITIVE = "холста (19x19)",
		DATIVE = "холсту (19x19)",
		ACCUSATIVE = "холст (19x19)",
		INSTRUMENTAL = "холстом (19x19)",
		PREPOSITIONAL = "холсте (19x19)"
	)
	icon_state = "19x19"
	width = 19
	height = 19
	SET_BASE_PIXEL(7, 7)
	framed_offset_x = 7
	framed_offset_y = 7


/obj/item/canvas/twentythree_nineteen
	name = "холст (23x19)"
	ru_names = alist(
		NOMINATIVE = "холст (23x19)",
		GENITIVE = "холста (23x19)",
		DATIVE = "холсту (23x19)",
		ACCUSATIVE = "холст (23x19)",
		INSTRUMENTAL = "холстом (23x19)",
		PREPOSITIONAL = "холсте (23x19)"
	)
	icon_state = "23x19"
	width = 23
	height = 19
	SET_BASE_PIXEL(5, 7)
	framed_offset_x = 5
	framed_offset_y = 7
	pixels_per_unit = 8


/obj/item/canvas/twentythree_twentythree
	name = "холст (23x23)"
	ru_names = alist(
		NOMINATIVE = "холст (23x23)",
		GENITIVE = "холста (23x23)",
		DATIVE = "холсту (23x23)",
		ACCUSATIVE = "холст (23x23)",
		INSTRUMENTAL = "холстом (23x23)",
		PREPOSITIONAL = "холсте (23x23)"
	)
	icon_state = "23x23"
	width = 23
	height = 23
	SET_BASE_PIXEL(5, 5)
	framed_offset_x = 5
	framed_offset_y = 5
	pixels_per_unit = 8


/obj/item/canvas/twentyfour_twentyfour
	name = "холст (24x24)"
	ru_names = alist(
		NOMINATIVE = "холст (24x24)",
		GENITIVE = "холста (24x24)",
		DATIVE = "холсту (24x24)",
		ACCUSATIVE = "холст (24x24)",
		INSTRUMENTAL = "холстом (24x24)",
		PREPOSITIONAL = "холсте (24x24)"
	)
	desc = "Слишком велик для стандартной рамки."
	icon_state = "24x24"
	width = 24
	height = 24
	SET_BASE_PIXEL(4, 4)
	framed_offset_x = 4
	framed_offset_y = 4
	pixels_per_unit = 8


// Oversized canvases. Their sprites live in the 64x64 sheet, so the icon is swapped in Initialize (the
// 32x32 "24x24" state from artstuff.dmi is kept as the spawn/craft-menu icon, matching TG). item_scaling
// shrinks the big sprite while it's lying on a turf so it doesn't sprawl across tiles. Too big for the
// standard painting frame (not in accepted_canvas_types), same as TG.
/obj/item/canvas/thirtysix_twentyfour
	name = "холст (36x24)"
	ru_names = alist(
		NOMINATIVE = "холст (36x24)",
		GENITIVE = "холста (36x24)",
		DATIVE = "холсту (36x24)",
		ACCUSATIVE = "холст (36x24)",
		INSTRUMENTAL = "холстом (36x24)",
		PREPOSITIONAL = "холсте (36x24)"
	)
	desc = "Очень большой холст, чтобы выплеснуть свою душу. Для рамы понадобится стена побольше."
	icon_state = "24x24"
	width = 36
	height = 24
	SET_BASE_PIXEL(-4, 4)
	framed_offset_x = 14
	framed_offset_y = 4
	pixels_per_unit = 7
	w_class = WEIGHT_CLASS_BULKY


/obj/item/canvas/thirtysix_twentyfour/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/item_scaling, 1, 0.8)
	icon = 'icons/obj/art/artstuff_64x64.dmi'
	icon_state = "36x24"


/obj/item/canvas/fortyfive_twentyseven
	name = "холст (45x27)"
	ru_names = alist(
		NOMINATIVE = "холст (45x27)",
		GENITIVE = "холста (45x27)",
		DATIVE = "холсту (45x27)",
		ACCUSATIVE = "холст (45x27)",
		INSTRUMENTAL = "холстом (45x27)",
		PREPOSITIONAL = "холсте (45x27)"
	)
	desc = "Самый большой холст на космическом рынке. Для рамы понадобится стена побольше."
	icon_state = "24x24"
	width = 45
	height = 27
	SET_BASE_PIXEL(-8, 2)
	framed_offset_x = 9
	framed_offset_y = 4
	pixels_per_unit = 6
	w_class = WEIGHT_CLASS_BULKY


/obj/item/canvas/fortyfive_twentyseven/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/item_scaling, 1, 0.7)
	icon = 'icons/obj/art/artstuff_64x64.dmi'
	icon_state = "45x27"


/////////////
// PALETTE //
/////////////

/// Painting utility holding several colour slots (like TG): click a swatch in the Canvas UI to make it
/// the active colour, right-click a swatch to recolour that slot.
/obj/item/paint_palette
	name = "палитра"
	ru_names = alist(
		NOMINATIVE = "палитра",
		GENITIVE = "палитры",
		DATIVE = "палитре",
		ACCUSATIVE = "палитру",
		INSTRUMENTAL = "палитрой",
		PREPOSITIONAL = "палитре"
	)
	desc = "Кисть в комплекте. ЛКМ по ячейке - выбрать цвет, ПКМ - изменить. Кнопка «+» добавляет цвет, ПКМ по «+» - удаляет."
	gender = FEMALE
	icon = 'icons/obj/art/artstuff.dmi'
	icon_state = "palette"
	w_class = WEIGHT_CLASS_TINY
	/// Currently selected paint colour (one of palette_colors, or a custom pick).
	var/current_color = COLOR_BLACK
	/// The selectable colour slots shown in the Canvas UI. Each is individually recolourable.
	var/list/palette_colors
	/// Maximum number of colour slots the palette can hold (the "+" button stops adding past this), like tg.
	var/max_colors = 16


/obj/item/paint_palette/Initialize(mapload)
	. = ..()
	palette_colors = list(
		COLOR_BLACK,
		COLOR_WHITE,
		COLOR_RED,
		COLOR_ORANGE,
		COLOR_YELLOW,
		COLOR_GREEN,
		COLOR_BLUE,
		COLOR_PURPLE,
	)
	current_color = palette_colors[1]


/obj/item/paint_palette/attack_self(mob/user, modifiers)
	. = ..()
	pick_painting_tool_color(user, current_color)


/obj/item/paint_palette/set_painting_tool_color(chosen_color)
	current_color = chosen_color


/// Recolour a palette slot (1-based index) and make it the active colour.
/obj/item/paint_palette/proc/change_palette_color(index, new_color)
	if(!isnum(index) || index < 1 || index > length(palette_colors))
		return
	palette_colors[index] = new_color
	current_color = new_color


/// Append a new colour slot (up to max_colors) and make it active. Driven by the "+" button.
/obj/item/paint_palette/proc/add_palette_color(new_color)
	if(length(palette_colors) >= max_colors)
		return
	palette_colors += new_color
	current_color = new_color


/// Remove a colour slot (1-based index). Always keeps at least one slot so the palette is never empty.
/obj/item/paint_palette/proc/remove_palette_color(index)
	if(!isnum(index) || index < 1 || index > length(palette_colors))
		return
	if(length(palette_colors) <= 1)
		return
	palette_colors.Cut(index, index + 1)
	if(!(current_color in palette_colors))
		current_color = palette_colors[1]


////////////
// FRAMES //
////////////

/obj/item/wallframe
	name = "рама"
	icon = 'icons/obj/signs.dmi'
	icon_state = "frame-empty"
	resistance_flags = FLAMMABLE
	w_class = WEIGHT_CLASS_SMALL
	var/result_path
	var/pixel_shift = 0


/obj/item/wallframe/proc/try_build(turf/on_wall, mob/user)
	if(get_dist(on_wall, user) > 1)
		balloon_alert(user, "вы слишком далеко!")
		return FALSE

	var/floor_to_wall = get_dir(user, on_wall)
	if(!(floor_to_wall in GLOB.cardinal))
		balloon_alert(user, "встаньте ровно у стены!")
		return FALSE

	var/turf/turf = get_turf(user)
	if(!isfloorturf(turf))
		balloon_alert(user, "нельзя поместить здесь!")
		return FALSE

	return iswallturf(on_wall)


/obj/item/wallframe/proc/attach(turf/on_wall, mob/user)
	if(!result_path)
		qdel(src)
		return

	var/floor_to_wall = get_dir(user, on_wall)
	var/obj/hanging_object = new result_path(get_turf(user), floor_to_wall, TRUE)
	hanging_object.setDir(floor_to_wall)
	if(pixel_shift)
		switch(floor_to_wall)
			if(NORTH)
				hanging_object.pixel_y = pixel_shift
			if(SOUTH)
				hanging_object.pixel_y = -pixel_shift
			if(EAST)
				hanging_object.pixel_x = pixel_shift
			if(WEST)
				hanging_object.pixel_x = -pixel_shift

	after_attach(hanging_object)


/obj/item/wallframe/proc/after_attach(obj/attached_to)
	transfer_fingerprints_to(attached_to)


/obj/item/wallframe/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	. = ..()
	if(!proximity_flag || !iswallturf(target))
		return
	if(!try_build(target, user))
		return
	attach(target, user)
	qdel(src)
	return ATTACK_CHAIN_BLOCKED


/obj/item/wallframe/screwdriver_act(mob/living/user, obj/item/tool)
	var/turf/wall_turf = get_step(get_turf(user), user.dir)
	if(!iswallturf(wall_turf))
		return
	if(!try_build(wall_turf, user))
		return TRUE
	attach(wall_turf, user)
	qdel(src)
	return TRUE


/obj/item/wallframe/painting
	name = "рама"
	ru_names = alist(
		NOMINATIVE = "рама",
		GENITIVE = "рамы",
		DATIVE = "раме",
		ACCUSATIVE = "раму",
		INSTRUMENTAL = "рамой",
		PREPOSITIONAL = "раме"
	)
	desc = "Идеальная витрина для ваших любимых воспоминаний."
	gender = FEMALE
	icon = 'icons/obj/signs.dmi'
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting
	pixel_shift = 30


/obj/structure/sign/painting
	name = "картина"
	ru_names = alist(
		NOMINATIVE = "картина",
		GENITIVE = "картины",
		DATIVE = "картине",
		ACCUSATIVE = "картину",
		INSTRUMENTAL = "картиной",
		PREPOSITIONAL = "картине"
	)
	desc = "Искусство или \"Исскуство\"? Зависит только от вас."
	icon = 'icons/obj/signs.dmi'
	icon_state = "frame-empty"
	base_icon_state = "frame"
	resistance_flags = FLAMMABLE
	///Canvas we're currently displaying.
	var/obj/item/canvas/current_canvas
	///Description set when canvas is added.
	var/desc_with_canvas = "Произведение искусства, заключённое в раму."
	var/persistence_id
	/// The list of canvas types accepted by this frame
	var/list/accepted_canvas_types = list(
		/obj/item/canvas,
		/obj/item/canvas/nineteen_nineteen,
		/obj/item/canvas/twentythree_nineteen,
		/obj/item/canvas/twentythree_twentythree,
		/obj/item/canvas/twentyfour_twentyfour,
	)
	/// the type of wallframe it 'disassembles' into
	var/wallframe_type = /obj/item/wallframe/painting


/obj/structure/sign/painting/Initialize(mapload, dir, building)
	. = ..()
	// See /obj/item/canvas/Initialize(): the framed painting + frame are runtime/offset overlays that need
	// KEEP_TOGETHER to render in Paradise's plane-master system.
	appearance_flags |= KEEP_TOGETHER
	if(dir)
		setDir(dir)


/obj/structure/sign/painting/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(!current_canvas && istype(I, /obj/item/canvas))
		frame_canvas(user, I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!current_canvas || current_canvas.painting_metadata.title != initial(current_canvas.painting_metadata.title) || !istype(I, /obj/item/pen))
		return ..()

	if(!try_rename(user))
		return ..()

	SStgui.update_uis(src)
	return ATTACK_CHAIN_BLOCKED_ALL


/obj/structure/sign/painting/examine(mob/user)
	. = ..()
	if(!current_canvas)
		return

	current_canvas.ui_interact(user)
	. += span_notice("Для удаления картины используйте кусачки.")


/obj/structure/sign/painting/wirecutter_act(mob/living/user, obj/item/I)
	if(!current_canvas)
		var/obj/item/wallframe/frame = new wallframe_type(drop_location())
		frame.name = initial(frame.name)
		qdel(src)
		return ATTACK_CHAIN_SUCCESS

	current_canvas.forceMove(drop_location())
	to_chat(user, span_notice("Вы вынимаете картину из рамы."))
	return ATTACK_CHAIN_SUCCESS


/obj/structure/sign/painting/Exited(atom/movable/movable, atom/newloc)
	. = ..()
	if(movable != current_canvas)
		return

	current_canvas = null
	update_appearance()


/obj/structure/sign/painting/proc/frame_canvas(mob/user, obj/item/canvas/new_canvas)
	if(!(new_canvas.type in accepted_canvas_types))
		to_chat(user, span_warning("[new_canvas] не влезает в эту раму."))
		return FALSE

	if(!user.drop_transfer_item_to_loc(new_canvas, src))
		return FALSE

	current_canvas = new_canvas
	if(!current_canvas.finalized)
		current_canvas.finalize(user)

	to_chat(user, span_notice("Вы поместили картину в раму."))
	update_appearance()
	return TRUE


/obj/structure/sign/painting/proc/try_rename(mob/user)
	if(current_canvas.painting_metadata.title != initial(current_canvas.painting_metadata.title))
		return FALSE

	if(!current_canvas.try_rename(user))
		return FALSE

	SStgui.update_uis(current_canvas)
	return TRUE


/obj/structure/sign/painting/update_icon_state(updates = ALL)
	. = ..()
	// Stops the frame icon_state from poking out behind the paintings; we have proper frame overlays in artstuff.dmi.
	icon = current_canvas?.generated_icon ? null : initial(icon)


/obj/structure/sign/painting/update_name(updates)
	name = current_canvas ? "картина - [current_canvas.painting_metadata.title]" : initial(name)
	return ..()


/obj/structure/sign/painting/update_desc(updates)
	desc = current_canvas ? desc_with_canvas : initial(desc)
	return ..()


/obj/structure/sign/painting/update_overlays()
	. = ..()
	if(!current_canvas?.generated_icon)
		return

	// Concrete layer for the same reason as /obj/item/canvas/update_overlays(): a FLOAT_LAYER overlay with
	// pixel offsets won't render in Paradise's plane-master system.
	var/mutable_appearance/painting = mutable_appearance(current_canvas.generated_icon, layer = layer)
	painting.pixel_w = current_canvas.framed_offset_x
	painting.pixel_z = current_canvas.framed_offset_y
	. += painting
	var/frame_type = current_canvas.painting_metadata.frame_type
	. += mutable_appearance(current_canvas.icon, "[current_canvas.icon_state]frame_[frame_type]") //add the frame


//////////////
// CRAFTING //
//////////////

/datum/crafting_recipe/easel
	name = "Мольберт"
	result = /obj/structure/easel
	reqs = list(/obj/item/stack/sheet/wood = 5)
	time = 5 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/canvas
	name = "Холст (11x11)"
	result = /obj/item/canvas
	reqs = list(
		/obj/item/stack/sheet/cloth = 2,
		/obj/item/stack/sheet/wood = 1,
	)
	time = 5 SECONDS
	category = CAT_MISC

/datum/crafting_recipe/canvas/nineteen
	name = "Холст (19x19)"
	result = /obj/item/canvas/nineteen_nineteen
	reqs = list(
		/obj/item/stack/sheet/cloth = 3,
		/obj/item/stack/sheet/wood = 2,
	)

/datum/crafting_recipe/canvas/twentythree_nineteen
	name = "Холст (23x19)"
	result = /obj/item/canvas/twentythree_nineteen
	reqs = list(
		/obj/item/stack/sheet/cloth = 3,
		/obj/item/stack/sheet/wood = 2,
	)

/datum/crafting_recipe/canvas/twentythree
	name = "Холст (23x23)"
	result = /obj/item/canvas/twentythree_twentythree
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/stack/sheet/wood = 2,
	)

/datum/crafting_recipe/canvas/twentyfour
	name = "Холст (24x24)"
	result = /obj/item/canvas/twentyfour_twentyfour
	reqs = list(
		/obj/item/stack/sheet/cloth = 4,
		/obj/item/stack/sheet/wood = 2,
	)

/datum/crafting_recipe/canvas/thirtysix_twentyfour
	name = "Холст (36x24)"
	result = /obj/item/canvas/thirtysix_twentyfour
	reqs = list(
		/obj/item/stack/sheet/cloth = 5,
		/obj/item/stack/sheet/wood = 3,
	)

/datum/crafting_recipe/canvas/fortyfive_twentyseven
	name = "Холст (45x27)"
	result = /obj/item/canvas/fortyfive_twentyseven
	reqs = list(
		/obj/item/stack/sheet/cloth = 6,
		/obj/item/stack/sheet/wood = 3,
	)

/datum/crafting_recipe/paint_palette
	name = "Палитра художника"
	result = /obj/item/paint_palette
	reqs = list(/obj/item/stack/sheet/wood = 1)
	time = 3 SECONDS
	category = CAT_MISC


#undef MAX_PAINTING_ZOOM_OUT
