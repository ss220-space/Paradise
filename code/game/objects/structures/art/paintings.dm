#define MAX_PAINTING_ZOOM_OUT 3

///////////
// EASEL //
///////////

/obj/structure/easel
	name = "мольберт"
	ru_names = list(
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
	canvas.layer = layer+0.1
	user.visible_message(span_notice("[user] puts \the [canvas] on \the [src]."),span_notice("You place \the [canvas] on \the [src]."))
	return ATTACK_CHAIN_BLOCKED_ALL


//Stick to the easel like glue
/obj/structure/easel/Move()
	var/turf/turf = get_turf(src)
	. = ..()
	if(painting && painting.loc == turf) //Only move if it's near us.
		painting.forceMove(get_turf(src))
		return

	painting = null


/obj/item/canvas
	name = "холст"
	ru_names = list(
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
	//flags_1 = UNPAINTABLE_1
	resistance_flags = FLAMMABLE
	//interaction_flags_atom = parent_type::interaction_flags_atom | INTERACT_ATOM_ALLOW_USER_LOCATION
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
	///boolean that blocks persistence from saving it. enabled from printing copies, because we do not want to save copies.
	var/no_save = FALSE

	///reference to the last patron's mind datum, used to allow them (and no others) to change the frame before the round ends.
	var/datum/weakref/last_patron

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

	painting_metadata = new
	painting_metadata.title = "Untitled Artwork"
	painting_metadata.creation_round_id = GLOB.round_id
	painting_metadata.width = width
	painting_metadata.height = height
	ADD_KEEP_TOGETHER(src, INNATE_TRAIT)


/obj/item/canvas/Destroy()
	last_patron = null
	/*
	if(istype(loc,/obj/structure/sign/painting))
		var/obj/structure/sign/painting/frame = loc
		frame.remove_art_element(painting_metadata.credit_value)
	*/
	painting_metadata = null
	return ..()


/obj/item/canvas/proc/reset_grid()
	grid = new/list(width,height)
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			grid[x][y] = canvas_color


/obj/item/canvas/attack_self(mob/user)
	. = ..()
	ui_interact(user)


/obj/item/canvas/ui_host(mob/user)
	if(istype(loc,/obj/structure/sign/painting))
		return loc

	return ..()


/obj/item/canvas/ui_state(mob/user)
	if(isobserver(user))
		return GLOB.observer_state

	if(finalized)
		return GLOB.hold_or_view_state

	return GLOB.default_state


/obj/item/canvas/ui_status(mob/user, datum/ui_state/state)
	if(state == GLOB.default_state || !state)
		return ..()

	//Skip the can_interact() check from atom/ui_status() and let them zoom in/out!
	var/src_object = ui_host(user)
	return state.can_use_topic(src_object, user)


/obj/item/canvas/ui_interact(mob/user, datum/tgui/ui)
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
	.["editable"] = !finalized //Ideally you should be able to draw moustaches on existing paintings in the gallery but that's not implemented yet
	.["show_plaque"] = istype(loc,/obj/structure/sign/painting)
	.["show_grid"] = show_grid
	.["paint_tool_palette"] = null
	var/obj/item/painting_implement = user.get_active_hand()
	if(!painting_implement)
		.["paint_tool_color"] = null
		return

	.["paint_tool_color"] = get_paint_tool_color(painting_implement)
	SEND_SIGNAL(painting_implement, COMSIG_PAINTING_TOOL_GET_ADDITIONAL_DATA, .)


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
				painting_metadata.medium = "Mixed medium"
			else
				painting_metadata.medium = medium
			used = TRUE
			update_appearance()
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
			var/obj/item/painting_implement = user.get_active_hand()
			if(!painting_implement)
				return FALSE
			//I'd have this done inside the signal, but that'd have to be asynced,
			//while we want the UI to be updated after the color is chosen, not before.
			var/chosen_color = input(user, "Pick new color", painting_implement, params["old_color"]) as color|null
			if(!chosen_color || IS_DEAD_OR_INCAP(user) || !user.is_holding(painting_implement))
				return FALSE

			SEND_SIGNAL(painting_implement, COMSIG_PAINTING_TOOL_PALETTE_COLOR_CHANGED, chosen_color, params["color_index"])
			. = TRUE

		if("toggle_grid")
			. = TRUE
			show_grid = !show_grid

		if("finalize")
			. = TRUE
			finalize(user)

		if("patronage")
			. = TRUE
			patron(user)

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
	if(painting_metadata.loaded_from_json || finalized)
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


#define CURATOR_PERCENTILE_CUT 0.225
#define SERVICE_PERCENTILE_CUT 0.125


/**
 * Gets ID card from a mob.
 * Argument:
 * * hand_firsts - boolean that checks the hands of the mob first if TRUE.
 */
/mob/living/carbon/human/proc/get_idcard(hand_first)
	if(!length(get_held_items())) //Early return for mobs without hands.
		return

	//Check hands
	var/obj/item/held_item = get_active_hand()
	if(held_item) //Check active hand
		. = held_item.GetID()

	if(.) //If there is no id, check the other hand
		return

	held_item = get_inactive_hand()
	if(!held_item)
		return

	. = held_item.GetID()


/obj/item/canvas/proc/patron(mob/user)
	if(!finalized || !ishuman(user))
		return

	if(!painting_metadata.loaded_from_json)
		if(tgui_alert(user, "Картина ещё не архивирована и будет утеряна в конце смены, если её не поместить в удобную раму. \
							Продолжить?", "Несохранённая картина", list("Да", "Нет")) != "Да")
			return

	var/mob/living/carbon/human/human_user = user
	var/obj/item/card/id/id_card = human_user.get_idcard(TRUE)
	if(!id_card)
		to_chat(user, span_warning("У вас даже нет id карты, а вы хотите стать меценатом?"))
		return

	var/datum/money_account/account = get_money_account(id_card.associated_account_number)
	if(!account)
		to_chat(user, span_warning("Аккаунт не найден."))
		return

	if(account.money < painting_metadata.credit_value)
		to_chat(user, span_warning("Вы не можете себе этого позволить."))
		return

	var/sniped_amount = painting_metadata.credit_value
	var/offer_amount = tgui_input_number(user, "Какую сумму вы готовы предложить?", "Предоставляемая Сумма", (painting_metadata.credit_value + 1), account.money, painting_metadata.credit_value)
	if(!offer_amount || QDELETED(user) || QDELETED(src) || !istype(loc, /obj/structure/sign/painting) || !user.can_perform_action(loc, FORBID_TELEKINESIS_REACH))
		return

	if(sniped_amount != painting_metadata.credit_value)
		return

	if(!account.charge(-offer_amount))
		to_chat(user, span_warning("Ошибка транзакции. Попробуйте ещё раз."))
		return

	var/datum/money_account/service_account = GLOB.department_accounts["Support"]
	service_account.charge(offer_amount * SERVICE_PERCENTILE_CUT)
/*
	if(istype(loc, /obj/structure/sign/painting))
		var/obj/structure/sign/painting/frame = loc
		frame.remove_art_element(painting_metadata.credit_value)
		frame.add_art_element(offer_amount)
*/
	painting_metadata.patron_ckey = user.ckey
	painting_metadata.patron_name = user.real_name
	painting_metadata.credit_value = offer_amount
	last_patron = WEAKREF(user.mind)

	to_chat(user, span_notice("Фонд \"Nanotrasen Trust\" благодарит вас за ваш вклад. Теперь вы официальный владелец этой картины."))
	var/list/possible_frames = SSpersistent_paintings.get_available_frames(offer_amount)
	if(possible_frames.len <= 1) // Not much room for choices here.
		return

	if(tgui_alert(user, "Хотите изменить внешний вид рамки сейчас? Вы сможете сделать это позже, нажав Alt+клик, если являетесь владельцем.", \
						"Рабка", list("Да", "Нет")) != "Да")
		return

	if(!can_select_frame(user))
		return

	SStgui.close_uis(src) // Close the examine ui so that the radial menu doesn't end up covered by it and people don't get confused.
	select_new_frame(user, possible_frames)


#undef CURATOR_PERCENTILE_CUT
#undef SERVICE_PERCENTILE_CUT

/obj/item/canvas/proc/select_new_frame(mob/user, list/candidates)
	var/possible_frames = candidates || SSpersistent_paintings.get_available_frames(painting_metadata.credit_value)
	var/list/radial_options = list()
	for(var/frame_name in possible_frames)
		radial_options[frame_name] = image(icon, "[icon_state]frame_[frame_name]")

	var/result = show_radial_menu(user, loc, radial_options, radius = 60, custom_check = CALLBACK(src, PROC_REF(can_select_frame), user))
	if(!result)
		return

	painting_metadata.frame_type = result
	var/obj/structure/sign/painting/our_frame = loc
	our_frame.balloon_alert(user, "рамка теперь [result]")
	our_frame.update_appearance()


/obj/item/canvas/proc/can_select_frame(mob/user)
	if(!istype(loc, /obj/structure/sign/painting))
		return FALSE

	if(IS_DEAD_OR_INCAP(user))
		return FALSE

	if(!last_patron)
		return FALSE

	return TRUE


/obj/item/canvas/update_overlays()
	. = ..()
	if(icon_generated)
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
	if(icon_generated)
		return

	var/png_filename = "data/paintings/temp_painting.png"
	var/image_data = get_data_string()
	rustg_dmi_create_png(png_filename, "[width]", "[height]", image_data)
	painting_metadata.md5 = md5(LOWER_TEXT(image_data))
	generated_icon = new(png_filename)
	icon_generated = TRUE
	update_appearance()


/obj/item/canvas/proc/get_data_string()
	var/list/data = list()
	for(var/y in 1 to height)
		for(var/x in 1 to width)
			data += grid[x][y]

	return data.Join("")


//Todo make this element ?
/obj/item/canvas/proc/get_paint_tool_color(obj/item/painting_implement)
	if(!painting_implement)
		return

	if(istype(painting_implement, /obj/item/paint_palette))
		var/obj/item/paint_palette/palette = painting_implement
		return palette.current_color

	if(istype(painting_implement, /obj/item/toy/crayon))
		var/obj/item/toy/crayon/crayon = painting_implement
		return crayon.colour

	else if(istype(painting_implement, /obj/item/pen))
		var/obj/item/pen/pen = painting_implement
		return pen.colour

	else if(istype(painting_implement, /obj/item/soap) || istype(painting_implement, /obj/item/reagent_containers/glass/rag))
		return canvas_color


/// Generates medium description
/obj/item/canvas/proc/get_paint_tool_medium(obj/item/painting_implement)
	if(!painting_implement)
		return

	if(istype(painting_implement, /obj/item/paint_palette))
		return "Масло на холсте"

	else if(istype(painting_implement, /obj/item/toy/crayon/spraycan))
		return "Краска из балончика на холсте"

	else if(istype(painting_implement, /obj/item/toy/crayon))
		return "Следы мелка на холсте"

	else if(istype(painting_implement, /obj/item/pen))
		return "Чернила на холсте"

	else if(istype(painting_implement, /obj/item/soap) || istype(painting_implement, /obj/item/reagent_containers/glass/rag))
		return //These are just for cleaning, ignore them

	else
		return "Неизвестный материал"


/obj/item/canvas/proc/try_rename(mob/user)
	if(painting_metadata.loaded_from_json) // No renaming old paintings
		return TRUE

	var/new_name = tgui_input_text(user, "Как вы хотите назвать картину?", "Назовите свой шедевр", max_length = MAX_NAME_LEN)
	//new_name = reject_bad_name(new_name, allow_numbers = TRUE, ascii_only = FALSE, strict = TRUE, cap_after_symbols = FALSE)
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
 * A proc that adopts a span-based, 4-dir (correct me if I'm wrong) flood fill algorithm used
 * by the bucked tool in the UI, to facilitate coloring larger portions of the canvas.
 * If you have never used the bucket/flood tool on an image editor, I suggest you do it
 * now so you know what I'm basically talking about.
 *
 * @ param x The point on the x axys where we start flooding our canvas. The arg is later used to store the current x
 * @ param y The point on the y axys where we start flooding the canvas. The arg is later used to store the current y
 * @ param new_color The new color that floods over the old one
 */
/obj/item/canvas/proc/canvas_fill(x, y, new_color)
	var/prev_color = grid[x][y]
	//If the colors are the same, don't do anything.
	if(prev_color == new_color)
		return FALSE

	//The queue for coordinates to the right of the current line
	var/list/queue_right = list()
	//Inversely for those to our left
	var/list/queue_left = list()
	//Whether we're currently checking the right or left queue.
	var/go_right = TRUE

	//The current coordinates. The only reason this is outside the loop
	//is because we first go up, then reset our vertical position to just below
	//the starting position and go down from there.
	var/list/coords = list(x, y)

	//Basically, the way it works is that each cycle we first go up, then down until we
	//either reach the vertical borders of the raster or find a pixel that is not of the color we want
	//to flood. As we do this, we try to queue a minimum of coordinates to our
	//left and right to use for future cycles, moving horizontally in one direction until there are no
	//more queued coordinates for that dir. Then we turn around and repeat
	//until both left and right queues are completely empty.
	while(coords)
		//The current vertical line, the right and the left ones.
		var/list/curr_line = grid[x]
		var/list/right_line = x < width ? grid[x+1] : null
		var/list/left_line = x > 1 ? grid[x-1] : null
		//the queue we're on, depending on direction
		var/list/curr_queue = go_right ? queue_right : queue_left
		//Instead of queueing every point to our left and right that shares our prevous color,
		//Causing a lot of empty cycles, we only queue an extremity of a vertical segment
		//delimited by pixels of other colors or the y boundaries of the raster. To do this,
		//we need to track where the segment (called line for simplicity) starts (or ends).
		var/r_line_start
		var/l_line_start

		//go up first (y = 1 is the upper border is)
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
			curr_queue -= CANVAS_COORD(x, y) //remove it from the queue if possible.
			y--

		//Any unqueued coordinate is queued and cleared before the next half of the cycle
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
 * The step of canvas_fill() that scans the pixels to the immediate right and left of our coord and see if they need to be queue'd or not.
 * Kept as a separate proc to reduce copypasted code.
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


/obj/item/wallframe
	icon = 'icons/obj/machines/wallmounts.dmi'
	//custom_materials = list(/datum/material/iron= SHEET_MATERIAL_AMOUNT * 2)
	//obj_flags = CONDUCTS_ELECTRICITY
	item_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/result_path
	var/wall_external = FALSE // For frames that are external to the wall they are placed on, like light fixtures and cameras.
	var/pixel_shift //The amount of pixels


/obj/item/wallframe/proc/try_build(turf/on_wall, mob/user)
	if(get_dist(on_wall,user) > 1)
		balloon_alert(user, "вы слишком далеко!")
		return

	var/floor_to_wall = get_dir(user, on_wall)
	if(!(floor_to_wall in GLOB.cardinal))
		balloon_alert(user, "встаньте ровно у стены!")
		return

	var/turf/turf = get_turf(user)
	var/area/area = get_area(turf)
	if(!isfloorturf(turf))
		balloon_alert(user, "нельзя поместить здесь!")
		return

	if(area.always_unpowered)
		balloon_alert(user, "нельзя поместить здесь!")
		return

	return TRUE


/obj/item/wallframe/proc/attach(turf/on_wall, mob/user)
	if(!result_path)
		qdel(src)
		return

	playsound(src.loc, 'sound/machines/click.ogg', 75, TRUE)
	user.visible_message(span_notice("[user.declent_ru(NOMINATIVE)] присоединил [declent_ru(ACCUSATIVE)] к стене."),
						span_notice("Вы присоединили [declent_ru(ACCUSATIVE)] к стене."),
						span_hear("Вы слышите клики."))

	var/floor_to_wall = get_dir(user, on_wall)
	var/obj/hanging_object = new result_path(get_turf(user), floor_to_wall, TRUE)
	hanging_object.setDir(floor_to_wall)
	if(!pixel_shift)
		after_attach(hanging_object)
		return

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


/obj/item/wallframe/screwdriver_act(mob/living/user, obj/item/tool)
	// For camera-building borgs
	var/turf/wall_turf = get_step(get_turf(user), user.dir)
	if(!iswallturf(wall_turf))
		return

	wall_turf.attackby(src, user)


/obj/item/wallframe/wrench_act(mob/living/user, obj/item/tool)
	var/metal_amt = 3//round(custom_materials[GET_MATERIAL_REF(/datum/material/iron)]/SHEET_MATERIAL_AMOUNT) //Replace this shit later
	var/glass_amt = 3//round(custom_materials[GET_MATERIAL_REF(/datum/material/glass)]/SHEET_MATERIAL_AMOUNT) //Replace this shit later

	if(!metal_amt && !glass_amt)
		return FALSE

	to_chat(user, span_notice("Вы отсоединяете [declent_ru(ACCUSATIVE)]."))
	tool.play_tool_sound(src)
	if(metal_amt)
		new /obj/item/stack/sheet/metal(get_turf(src), metal_amt)

	if(glass_amt)
		new /obj/item/stack/sheet/glass(get_turf(src), glass_amt)

	qdel(src)
	return


/obj/item/canvas/nineteen_nineteen
	name = "холст (19x19)"
	ru_names = list(
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
	ru_names = list(
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
	ru_names = list(
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
	ru_names = list(
		NOMINATIVE = "холст (24x24)",
		GENITIVE = "холста (24x24)",
		DATIVE = "холсту (24x24)",
		ACCUSATIVE = "холст (24x24)",
		INSTRUMENTAL = "холстом (24x24)",
		PREPOSITIONAL = "холсте (24x24)"
	)
	desc = "Помимо того, что он слишком велик для стандартной рамки, \
			ИИ может использовать его в качестве дисплея из своей внутренней базы данных после того, как вы его повесите."
	icon_state = "24x24"
	width = 24
	height = 24
	SET_BASE_PIXEL(4, 4)
	framed_offset_x = 4
	framed_offset_y = 4
	pixels_per_unit = 8



/obj/item/canvas/thirtytwo_thirtytwo
	name = "холст (32x32)"
	ru_names = list(
		NOMINATIVE = "холст (32x32)",
		GENITIVE = "холста (32x32)",
		DATIVE = "холсту (32x32)",
		ACCUSATIVE = "холст (32x32)",
		INSTRUMENTAL = "холстом (32x32)",
		PREPOSITIONAL = "холсте (32x32)"
	)
	desc = "Помимо того, что он слишком велик для стандартной рамки, \
			ИИ может использовать его в качестве дисплея из своей внутренней базы данных после того, как вы его повесите."
	icon_state = "32x32"
	width = 32
	height = 32


/obj/item/canvas/thirtysix_twentyfour
	name = "холст (36x24)"
	ru_names = list(
		NOMINATIVE = "холст (36x24)",
		GENITIVE = "холста (36x24)",
		DATIVE = "холсту (36x24)",
		ACCUSATIVE = "холст (36x24)",
		INSTRUMENTAL = "холстом (36x24)",
		PREPOSITIONAL = "холсте (36x24)"
	)
	desc = "Очень большой холст, на котором можно изобразить свою душу. \
			Чтобы повесить картину на стену, понадобится большая рамка рамка."
	icon_state = "24x24" //The vending spritesheet needs the icons to be 32x32. We'll set the actual icon on Initialize.
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
	ru_names = list(
		NOMINATIVE = "холст (45x27)",
		GENITIVE = "холста (45x27)",
		DATIVE = "холсту (45x27)",
		ACCUSATIVE = "холст (45x27)",
		INSTRUMENTAL = "холстом (45x27)",
		PREPOSITIONAL = "холсте (45x27)"
	)
	desc = "Самый большой холст, доступный на рынке. Чтобы повесить его на стену, понадобится большая рамка."
	icon_state = "24x24" //Ditto
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


/obj/item/wallframe/painting
	name = "рама"
	ru_names = list(
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
	//custom_materials = list(/datum/material/wood =SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	//flags_1 = NONE
	icon_state = "frame-empty"
	result_path = /obj/structure/sign/painting
	pixel_shift = 30


/obj/structure/sign/painting
	name = "картина"
	ru_names = list(
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
	//custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)
	resistance_flags = FLAMMABLE
	//buildable_sign = FALSE
	///Canvas we're currently displaying.
	var/obj/item/canvas/current_canvas
	///Description set when canvas is added.
	var/desc_with_canvas
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


/*
/obj/structure/sign/painting/get_save_vars()
	return ..() - NAMEOF(src, icon)
*/

/obj/structure/sign/painting/Initialize(mapload, dir, building)
	. = ..()
	SSpersistent_paintings.painting_frames += src
	if(!dir)
		return

	setDir(dir)


/obj/structure/sign/painting/Destroy()
	. = ..()
	SSpersistent_paintings.painting_frames -= src


/obj/structure/sign/painting/attackby(obj/item/I, mob/user, list/modifiers, list/attack_modifiers)
	if(!current_canvas && istype(I, /obj/item/canvas))
		frame_canvas(user,I)

	else if(!current_canvas || current_canvas.painting_metadata.title != initial(current_canvas.painting_metadata.title) || !istype(I,/obj/item/pen))
		return ..()

	if(!try_rename(user))
		return

	SStgui.update_uis(src)

/*
/obj/structure/sign/painting/knock_down(mob/living/user)
	var/turf/drop_turf
	if(user)
		drop_turf = get_turf(user)
	else
		drop_turf = drop_location()

	current_canvas?.forceMove(drop_turf)
	var/obj/item/wallframe/frame = new wallframe_type(drop_turf)
	frame.update_integrity(get_integrity()) //Transfer how damaged it is.
*/

/obj/structure/sign/painting/examine(mob/user)
	. = ..()
	if(persistence_id)
		. += span_notice("Любая картина, размещённая здесь, будет архивирована в конце смены.")

	if(!current_canvas)
		return

	current_canvas.ui_interact(user)
	. += span_notice("Для удаления картины используйте кусачки.")
	if(user?.mind != current_canvas.last_patron)
		return

	. += span_notice("<b>Alt-клик</b>, чтобы выбрать новый внешний вид рамы этой картины.")


/obj/structure/sign/painting/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	if(!current_canvas)
		return

	current_canvas.forceMove(drop_location())
	to_chat(user, span_notice("Вы вынимаете картину из рамы."))
	return TRUE


/obj/structure/sign/painting/Exited(atom/movable/movable, atom/newloc)
	. = ..()
	if(movable != current_canvas)
		return

	//if(!QDELETED(current_canvas))
	//	remove_art_element(current_canvas.painting_metadata.credit_value)

	current_canvas = null
	update_appearance()


/obj/structure/sign/painting/click_alt(mob/user)
	if(!current_canvas?.can_select_frame(user))
		return CLICK_ACTION_BLOCKING

	INVOKE_ASYNC(current_canvas, TYPE_PROC_REF(/obj/item/canvas, select_new_frame), user)
	return CLICK_ACTION_SUCCESS


/obj/structure/sign/painting/proc/frame_canvas(mob/user, obj/item/canvas/new_canvas)
	if(!(new_canvas.type in accepted_canvas_types))
		to_chat(user, span_warning("[new_canvas.declent_ru(NOMINATIVE)] не влезет в эту рамку."))
		return FALSE

	if(!user.drop_transfer_item_to_loc(new_canvas, src))
		return FALSE

	current_canvas = new_canvas
	if(!current_canvas.finalized)
		current_canvas.finalize(user)

	to_chat(user,span_notice("Вы поместиили [current_canvas.declent_ru(ACCUSATIVE)] в раму."))
	//add_art_element()
	//update_appearance()
	return TRUE


/obj/structure/sign/painting/proc/try_rename(mob/user)
	if(current_canvas.painting_metadata.title != initial(current_canvas.painting_metadata.title))
		return

	if(!current_canvas.try_rename(user))
		return

	SStgui.update_uis(current_canvas)


/obj/structure/sign/painting/update_icon_state(updates=ALL)
	. = ..()
	// Stops the frame icon_state from poking out behind the paintings. we have proper frame overlays in artstuff.dmi.
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

	var/mutable_appearance/painting = mutable_appearance(current_canvas.generated_icon)
	painting.pixel_w = current_canvas.framed_offset_x
	painting.pixel_z = current_canvas.framed_offset_y
	. += painting
	var/frame_type = current_canvas.painting_metadata.frame_type
	. += mutable_appearance(current_canvas.icon,"[current_canvas.icon_state]frame_[frame_type]") //add the frame


/**
 * Loads a painting from SSpersistence. Called globally by said subsystem when it inits
 *
 * Deleting paintings leaves their json, so this proc will remove the json and try again if it finds one of those.
 */
/obj/structure/sign/painting/proc/load_persistent()
	if(!persistence_id)
		return FALSE

	var/list/valid_paintings = SSpersistent_paintings.get_paintings_with_tag(persistence_id)
	if(!length(valid_paintings))
		return FALSE //aborts loading anything this category has no usable paintings

	var/datum/painting/painting = pick(valid_paintings)
	var/png = "data/paintings/images/[painting.md5].png"
	var/icon/I = new(png)
	var/obj/item/canvas/new_canvas
	var/w = I.Width()
	var/h = I.Height()
	for(var/turf in typesof(/obj/item/canvas))
		new_canvas = turf
		if(initial(new_canvas.width) != w || initial(new_canvas.height) != h)
			continue

		if(!(new_canvas in accepted_canvas_types))
			CRASH("Found painting with canvas size not compatible with this frame. Canvas type: [new_canvas]")

		new_canvas = new turf(src)
		break

	if(!istype(new_canvas))
		CRASH("Found painting size with no matching canvas type")

	new_canvas.painting_metadata = painting
	new_canvas.fill_grid_from_icon(I)
	new_canvas.generated_icon = I
	new_canvas.icon_generated = TRUE
	new_canvas.finalized = TRUE
	new_canvas.name = "painting - [painting.title]"
	current_canvas = new_canvas
	//add_art_element()
	current_canvas.update_appearance()
	update_appearance()
	return TRUE


/*
/obj/structure/sign/painting/proc/add_art_element()
	var/artistic_value = get_art_value(current_canvas.painting_metadata.credit_value)
	if(artistic_value)
		AddElement(/datum/element/art, artistic_value)

/obj/structure/sign/painting/proc/remove_art_element(patronage)
	var/artistic_value = get_art_value(patronage)
	if(artistic_value)
		RemoveElement(/datum/element/art, artistic_value)
*/


/obj/structure/sign/painting/proc/get_art_value(patronage)
	switch(patronage)
		if(PATRONAGE_SUPERB_FRAME to INFINITY)
			return GREAT_ART

		if(PATRONAGE_EXCELLENT_FRAME to PATRONAGE_SUPERB_FRAME)
			return GOOD_ART

		if(PATRONAGE_NICE_FRAME to PATRONAGE_EXCELLENT_FRAME)
			return OK_ART

	return 0


/obj/structure/sign/painting/proc/save_persistent()
	if(!persistence_id || !current_canvas || current_canvas.no_save || current_canvas.painting_metadata.loaded_from_json)
		return

	if(SANITIZE_FILENAME(persistence_id) != persistence_id)
		stack_trace("Invalid persistence_id - [persistence_id]")
		return

	var/data = current_canvas.get_data_string()
	var/md5 = md5(LOWER_TEXT(data))
	var/list/current = SSpersistent_paintings.paintings[persistence_id]
	if(!current)
		current = list()

	for(var/datum/painting/entry in SSpersistent_paintings.paintings)
		if(entry.md5 != md5) // No duplicates
			continue

		return

	current_canvas.painting_metadata.md5 = md5
	if(!current_canvas.painting_metadata.tags)
		current_canvas.painting_metadata.tags = list(persistence_id)
	else
		current_canvas.painting_metadata.tags |= persistence_id

	var/png_directory = "data/paintings/images/"
	var/png_path = png_directory + "[md5].png"
	rustg_dmi_create_png(png_path, "[current_canvas.width]", "[current_canvas.height]", data)
	SSpersistent_paintings.paintings += current_canvas.painting_metadata


/obj/item/canvas/proc/fill_grid_from_icon(icon/I)
	var/h = I.Height() + 1
	for(var/x in 1 to width)
		for(var/y in 1 to height)
			grid[x][y] = I.GetPixel(x,h-y)


/obj/item/wallframe/painting/large
	name = "большая рама"
	ru_names = list(
		NOMINATIVE = "большая рама",
		GENITIVE = "большой рамы",
		DATIVE = "большой раме",
		ACCUSATIVE = "большую раму",
		INSTRUMENTAL = "большой рамой",
		PREPOSITIONAL = "большой раме"
	)
	desc = "Идеальная витрина для ваших любимых воспоминаний. \
			Убедитесь, что на стене достаточно места."
	//custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT*2)
	icon_state = "frame-large-empty"
	result_path = /obj/structure/sign/painting/large
	pixel_shift = 0 //See [/obj/structure/sign/painting/large/proc/finalize_size]


/obj/item/wallframe/painting/large/try_build(turf/on_wall, mob/user)
	. = ..()
	if(!.)
		return

	var/our_dir = get_dir(user, on_wall)
	var/check_dir = our_dir & (EAST|WEST) ? NORTH : EAST
	var/turf/simulated/wall/second_wall = get_step(on_wall, check_dir)
	if(istype(second_wall))
		return

	to_chat(user, span_warning("Слишком мало места!"))
	return FALSE


/obj/item/wallframe/painting/large/after_attach(obj/object)
	. = ..()
	var/obj/structure/sign/painting/large/our_frame = object
	our_frame.finalize_size()


/obj/structure/sign/painting/large
	icon = 'icons/obj/art/artstuff_64x64.dmi'
	//custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT*2)
	accepted_canvas_types = list(
		/obj/item/canvas/thirtysix_twentyfour,
		/obj/item/canvas/fortyfive_twentyseven,
	)
	wallframe_type = /obj/item/wallframe/painting/large


/obj/structure/sign/painting/large/Initialize(mapload)
	. = ..()
	// Necessary so that the painting is framed correctly by the frame overlay when flipped.
	ADD_KEEP_TOGETHER(src, INNATE_TRAIT)
	if(!mapload)
		return

	finalize_size()


/**
 * This frame is visually put between two wall turfs and it has an icon that's bigger than 32px, and because
 * of the way it's designed, the pixel_shift variable from the wallframe item won't do.
 * Also we want higher bounds so it actually covers an extra wall turf, so that it can count toward check_wall_item calls for
 * that wall turf.
 */
/obj/structure/sign/painting/large/proc/finalize_size()
	switch(dir)
		if(SOUTH)
			pixel_y = -32
			bound_width = 64

		if(NORTH)
			bound_width = 64

		if(WEST)
			// Totally intended so that the frame sprite doesn't spill behind the wall and get partly covered by the darkness plane.
			// Ditto for the ones below.
			pixel_x = -29
			bound_height = 64

		if(EAST)
			bound_height = 64


/obj/structure/sign/painting/large/frame_canvas(mob/user, obj/item/canvas/new_canvas)
	. = ..()
	if(!.)
		return

	set_painting_offsets()


/obj/structure/sign/painting/large/load_persistent()
	. = ..()
	if(!.)
		return

	set_painting_offsets()


/obj/structure/sign/painting/large/proc/set_painting_offsets()
	switch(dir)
		if(EAST)
			transform = transform.Turn(90)
			pixel_x += 29
			pixel_y += 29

		if(WEST)
			transform = transform.Turn(-90)

		if(NORTH)
			pixel_y += 29


/obj/structure/sign/painting/large/Exited(atom/movable/movable, atom/newloc)
	if(movable != current_canvas)
		return ..()

	switch(dir)
		if(EAST)
			transform = transform.Turn(-90)
			pixel_x -= 29
			pixel_y -= 29

		if(WEST)
			transform = transform.Turn(90)

		if(NORTH)
			pixel_y -= 29

	return ..()


#define AVAILABLE_PALETTE_SPACE 14 // Enough to fill two radial menu pages


/// Simple painting utility.
/obj/item/paint_palette
	name = "палитра"
	ru_names = list(
		NOMINATIVE = "палитра",
		GENITIVE = "палитры",
		DATIVE = "палитре",
		ACCUSATIVE = "палитру",
		INSTRUMENTAL = "палитрой",
		PREPOSITIONAL = "палитре"
	)
	desc = "кисть включена"
	gender = FEMALE
	icon = 'icons/obj/art/artstuff.dmi'
	icon_state = "palette"
	lefthand_file = 'icons/mob/inhands/equipment/palette_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/palette_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	///Chosen paint color
	var/current_color = COLOR_BLACK


/obj/item/paint_palette/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/palette, AVAILABLE_PALETTE_SPACE, current_color)


/obj/item/paint_palette/attack_self(mob/user, modifiers)
	. = ..()
	pick_painting_tool_color(user, current_color)


/obj/item/paint_palette/set_painting_tool_color(chosen_color)
	. = ..()
	current_color = chosen_color


/datum/crafting_recipe/canvas
	name = "Холст"
	result = /obj/item/canvas
	reqs = list(/obj/item/stack/sheet/cloth = 4,
				/obj/item/stack/sheet/wood = 2,)
	time = 5 SECONDS
	category = CAT_MISC
	var/static/list/sizes = list(
		"19x19" = /obj/item/canvas/nineteen_nineteen,
		"23x19" = /obj/item/canvas/twentythree_nineteen,
		"23x23" = /obj/item/canvas/twentythree_twentythree,
		"24x24" = /obj/item/canvas/twentyfour_twentyfour,
		"32x32" = /obj/item/canvas/thirtytwo_thirtytwo,
		"36x24" = /obj/item/canvas/thirtysix_twentyfour,
		"45x27" = /obj/item/canvas/fortyfive_twentyseven,
	)


/datum/crafting_recipe/canvas/spawn_result(list/result_list, mob/user = usr)
	var/control_mode = tgui_input_list(usr, "Выберите желаемый размер", "Выбор размера", sizes, "19x19")
	return ..(list(sizes[control_mode]), user)


#undef AVAILABLE_PALETTE_SPACE
#undef MAX_PAINTING_ZOOM_OUT
