/*
 * MARK: Paper
 * also scraps of paper
 */

/*
/obj/item/paper
	name = "paper"
	desc = "Пустой листок бумаги."
	gender = FEMALE
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	layer = 4
	pressure_resistance = 0
	slot_flags = ITEM_SLOT_HEAD
	body_parts_covered = HEAD
	resistance_flags = FLAMMABLE
	max_integrity = 50
	attack_verb = list("стукнул")
	permeability_coefficient = 0.01
	dog_fashion = /datum/dog_fashion/head
	drop_sound = 'sound/items/handling/drop/paper_drop.ogg'
	pickup_sound =  'sound/items/handling/pickup/paper_pickup.ogg'
	custom_price = PAYCHECK_MIN * 0.05
	var/header //Above the main body, displayed at the top
	var/info		//What's actually written on the paper.
	var/footer	//The bottom stuff before the stamp but after the body
	var/info_links	//A different version of the paper which includes html links at fields and EOF
	var/stamps		//The (text for the) stamps on the paper.
	var/fields = 0		//Amount of user created fields
	var/language = LANGUAGE_GALACTIC_COMMON //The language of paper. For now using only in case of Thetta
	var/list/stamped
	///Prevents stamp overflow
	var/stamp_limit = 20
	var/list/stamp_overlays
	var/rigged = 0
	var/spam_flag = 0
	var/contact_poison // Reagent ID to transfer on contact
	var/contact_poison_volume = 0
	var/contact_poison_poisoner = null
	var/paper_width = 400 //Width of the window that opens
	var/paper_width_big = 600
	var/paper_height = 400 //Height of the window that opens
	var/paper_height_big = 700
	var/joinable = TRUE

	var/const/deffont = "Verdana"
	var/const/signfont = "Times New Roman"
	var/const/crayonfont = "Comic Sans MS"
	var/time = "00:00"
*/

/**
 * Paper is now using markdown (like in github pull notes) for ALL rendering
 * so we do loose a bit of functionality but we gain in easy of use of
 * paper and getting rid of that crashing bug
 */
/obj/item/paper
	name = "paper"
	desc = "Пустой листок бумаги."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "paper"
	item_state = "paper"
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	pressure_resistance = 0
	resistance_flags = FLAMMABLE
	max_integrity = 50
	drop_sound = 'sound/items/handling/drop/paper_drop.ogg'
	pickup_sound = 'sound/items/handling/pickup/paper_pickup.ogg'
	dog_fashion = /datum/dog_fashion/head
	attack_verb = list("стукнул")
	body_parts_covered = HEAD
	slot_flags = ITEM_SLOT_HEAD
	permeability_coefficient = 0.01
	custom_price = PAYCHECK_MIN * 0.05
	interaction_flags_click = NEED_DEXTERITY|NEED_HANDS|ALLOW_RESTING
	//scatter_distance = 8
/*
	item_flags = SKIP_FANTASY_ON_SPAWN
	custom_materials = list(/datum/material/paper = HALF_SHEET_MATERIAL_AMOUNT / 2)
	color = COLOR_WHITE
*/
	/// Lazylist of raw, unsanitised, unparsed text inputs that have been made to the paper.
	var/list/datum/paper_input/raw_text_inputs
	/// Lazylist of all raw stamp data to be sent to tgui.
	var/list/datum/paper_stamp/raw_stamp_data
	/// Lazylist of all fields that have had some input added to them.
	var/list/datum/paper_field/raw_field_input_data

	/// Whether the icon should show little scribbly written words when the paper has some text on it.
	var/show_written_words = TRUE

	/// Helper cache that contains a list of all icon_states that are currently stamped on the paper.
	var/list/stamp_cache

	/// Reagent to transfer to the user when they pick the paper up without proper protection.
	var/contact_poison
	/// Volume of contact_poison to transfer to the user when they pick the paper up without proper protection.
	var/contact_poison_volume = 0
	/// Whoever poisoned that paper
	var/mob/contact_poison_poisoner

	/// Default raw text to fill this paper with on init.
	var/default_raw_text

	/// The number of input fields
	var/input_field_count = 0

	/// Paper can be shown via cameras. When that is done, a deep copy of the paper is made and stored as a var on the camera.
	/// The paper is located in nullspace, and holds a weak ref to the camera that once contained it so the paper can do some
	/// state checking on if it should be shown to a viewer.
	var/datum/weakref/camera_holder

	///If TRUE, staff can read paper everywhere, but usually from requests panel.
	var/request_state = FALSE

	///If this paper can be selected as a candidate for a future message in a bottle when spawned outside of mapload. Doesn't affect manually doing that.
	var/can_become_message_in_bottle = TRUE

	/// Assoc Lazylist of REF()s to mobs that are viewing the paper while holding a writing tool to what that tool's writing implement details are
	VAR_FINAL/list/writers

/obj/item/paper/get_ru_names()
	return alist(
		NOMINATIVE = "бумага",
		GENITIVE = "бумаги",
		DATIVE = "бумаге",
		ACCUSATIVE = "бумагу",
		INSTRUMENTAL = "бумагой",
		PREPOSITIONAL = "бумаге",
	)

/obj/item/paper/Initialize(mapload)
	. = ..()

	if(default_raw_text)
		add_raw_text(default_raw_text)

	update_appearance()

	// if(can_become_message_in_bottle && !mapload && prob(MESSAGE_BOTTLE_CHANCE))
	// 	LAZYADD(SSpersistence.queued_message_bottles, src)

	AddElement(/datum/element/burn_on_item_ignition)
	RegisterSignal(src, COMSIG_ATOM_IGNITED_BY_ITEM, PROC_REF(close_paper_ui))

/obj/item/paper/Destroy()
	camera_holder = null
	clear_paper()
	// LAZYREMOVE(SSpersistence.queued_message_bottles, src)
	return ..()

/obj/item/paper/proc/close_paper_ui()
	SIGNAL_HANDLER
	SStgui.close_uis(src)

// /obj/item/paper/update_overlays()
// 	return LAZYCOPY(stamp_overlays)

/obj/item/paper/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to fold it into a paper plane.")
	if(!in_range(user, src) && !isobserver(user))
		. += span_warning("You're too far away to read it!")
		return

	if(user.is_blind())
		to_chat(user, span_warning("You are blind and can't read anything!"))
		return

	if(user.can_write(src))
		ui_interact(user)
		return
	. += span_warning("You cannot read it!")

/// Determines whether this paper has been written or stamped to.
/obj/item/paper/proc/is_empty()
	return !(LAZYLEN(raw_text_inputs) || LAZYLEN(raw_stamp_data))

/// Returns a deep copy list of raw_text_inputs, or null if the list is empty or doesn't exist.
/obj/item/paper/proc/copy_raw_text()
	if(!LAZYLEN(raw_text_inputs))
		return null

	var/list/datum/paper_input/copy_text = list()

	for(var/datum/paper_input/existing_input as anything in raw_text_inputs)
		copy_text += existing_input.make_copy()

	return copy_text

/// Returns a deep copy list of raw_field_input_data, or null if the list is empty or doesn't exist.
/obj/item/paper/proc/copy_field_text()
	if(!LAZYLEN(raw_field_input_data))
		return null

	var/list/datum/paper_field/copy_text = list()

	for(var/datum/paper_field/existing_input as anything in raw_field_input_data)
		copy_text += existing_input.make_copy()

	return copy_text

/// Returns a deep copy list of raw_stamp_data, or null if the list is empty or doesn't exist. Does not copy overlays or stamp_cache, only the tgui rendered stamps.
/obj/item/paper/proc/copy_raw_stamps()
	if(!LAZYLEN(raw_stamp_data))
		return null

	var/list/datum/paper_field/copy_stamps = list()

	for(var/datum/paper_stamp/existing_input as anything in raw_stamp_data)
		copy_stamps += existing_input.make_copy()

	return copy_stamps

/**
 * This proc copies this sheet of paper to a new
 * sheet. Used by carbon papers and the photocopier machine.
 *
 * Arguments
 * * paper_type - Type path of the new paper to create. Can copy anything to anything.
 * * location - Where to spawn in the new copied paper.
 * * colored - If true, the copied paper will be coloured and will inherit all colours.
 * * greyscale_override - If set to a colour string and coloured is false, it will override the default of COLOR_WEBSAFE_DARK_GRAY when copying.
 */
/obj/item/paper/proc/copy(paper_type = /obj/item/paper, atom/location = loc, colored = TRUE, greyscale_override = null)
	var/obj/item/paper/new_paper
	if(ispath(paper_type, /obj/item/paper))
		new_paper = new paper_type(location)
	else if(istype(paper_type, /obj/item/paper))
		new_paper = paper_type
	else
		CRASH("invalid paper_type [paper_type], paper type path or instance expected")

	new_paper.raw_text_inputs = copy_raw_text()
	new_paper.raw_field_input_data = copy_field_text()

	if(colored)
		new_paper.color = color
	else
		var/new_color = greyscale_override || COLOR_WEBSAFE_DARK_GRAY
		for(var/datum/paper_input/text as anything in new_paper.raw_text_inputs)
			text.colour = new_color

		for(var/datum/paper_field/text as anything in new_paper.raw_field_input_data)
			text.field_data.colour = new_color

	new_paper.input_field_count = input_field_count
	new_paper.raw_stamp_data = copy_raw_stamps()
	new_paper.stamp_cache = stamp_cache?.Copy()
	new_paper.update_icon_state()
	new_paper.copy_overlays(src)
	return new_paper

/**
 * This simple helper adds the supplied raw text to the paper, appending to the end of any existing contents.
 *
 * This a God proc that does not care about paper max length and expects sanity checking beforehand if you want to respect it.
 *
 * The caller is expected to handle updating icons and appearance after adding text, to allow for more efficient batch adding loops.
 * * Arguments:
 * * text - The text to append to the paper.
 * * font - The font to use.
 * * color - The font color to use.
 * * bold - Whether this text should be rendered completely bold.
 * * advanced_html - Boolean that is true when the writer has R_FUN permission, which sanitizes less HTML (such as images) from the new paper_input
 */
/obj/item/paper/proc/add_raw_text(text, font, color, bold, advanced_html)
	var/new_input_datum = new /datum/paper_input(
		text,
		font,
		color,
		bold,
		advanced_html,
	)

	input_field_count += get_input_field_count(text)

	LAZYADD(raw_text_inputs, new_input_datum)

/**
 * This simple helper adds the supplied input field data to the paper.
 *
 * It will not overwrite any existing input field data by default and will early return FALSE if this scenario happens unless overwrite is
 * set properly.
 *
 * Other than that, this is a God proc that does not care about max length or out-of-range IDs and expects sanity checking beforehand if
 * you want to respect it.
 *
 * * Arguments:
 * * field_id - The ID number of the field to which this data applies.
 * * text - The text to append to the paper.
 * * font - The font to use.
 * * color - The font color to use.
 * * bold - Whether this text should be rendered completely bold.
 * * overwrite - If TRUE, will overwrite existing field ID's data if it exists.
 */
/obj/item/paper/proc/add_field_input(field_id, text, font, color, bold, signature_name, overwrite = FALSE)
	var/datum/paper_field/field_data_datum = null

	var/is_signature = ((text == "%sign") || (text == "%s") || (text == "\[sign\]"))
	var/is_date = ((text == "%date") || (text == "%d") || (text == "\[date\]"))
	var/is_time = ((text == "%time") || (text == "%t") || (text == "\[time\]"))

	var/field_text = text
	if(is_signature)
		field_text = signature_name
	else if(is_date)
		field_text = GLOB.current_date_string
	else if(is_time)
		field_text = station_time_timestamp()

	var/field_font = is_signature ? SIGNATURE_FONT : font

	for(var/datum/paper_field/field_input in raw_field_input_data)
		if(field_input.field_index == field_id)
			if(!overwrite)
				return FALSE
			field_data_datum = field_input
			break

	if(!field_data_datum)
		var/new_field_input_datum = new /datum/paper_field(
			field_id,
			field_text,
			field_font,
			color,
			bold,
			is_signature,
		)
		LAZYADD(raw_field_input_data, new_field_input_datum)
		return TRUE

	var/new_input_datum = new /datum/paper_input(
		field_text,
		field_font,
		color,
		bold,
	)

	field_data_datum.field_data = new_input_datum;
	field_data_datum.is_signature = is_signature;

	return TRUE

/**
 * This simple helper adds the supplied stamp to the paper, appending to the end of any existing stamps.
 *
 * This a God proc that does not care about stamp max count and expects sanity checking beforehand if you want to respect it.
 *
 * It does however respect the overlay limit and will not apply any overlays past the cap.
 *
 * The caller is expected to handle updating icons and appearance after adding text, to allow for more efficient batch adding loops.
 * * Arguments:
 * * stamp_class - Div class for the stamp.
 * * stamp_x - X coordinate to render the stamp in tgui.
 * * stamp_y - Y coordinate to render the stamp in tgui.
 * * rotation - Degrees of rotation for the stamp to be rendered with in tgui.
 * * stamp_icon_state - Icon state for the stamp as part of overlay rendering.
* * stamp_icon_state - An alternate Icon file can be passed for the stamp as part of overlay rendering if desired
 */
/obj/item/paper/proc/add_stamp(stamp_class, stamp_x, stamp_y, rotation, stamp_icon_state, stamp_icon = 'icons/obj/service/bureaucracy.dmi')
	var/new_stamp_datum = new /datum/paper_stamp(stamp_class, stamp_x, stamp_y, rotation)
	LAZYADD(raw_stamp_data, new_stamp_datum);

	if(LAZYLEN(stamp_cache) > MAX_PAPER_STAMPS_OVERLAYS)
		return

	var/mutable_appearance/stamp_overlay = mutable_appearance(stamp_icon, "paper_[stamp_icon_state]", appearance_flags = KEEP_APART | RESET_COLOR)
	stamp_overlay.pixel_w = rand(-2, 2)
	stamp_overlay.pixel_z = rand(-3, 2)
	add_overlay(stamp_overlay)
	LAZYADD(stamp_cache, stamp_icon_state)

/// Removes all input and all stamps from the paper, clearing it completely.
/obj/item/paper/proc/clear_paper()
	LAZYNULL(raw_text_inputs)
	LAZYNULL(raw_stamp_data)
	LAZYNULL(raw_field_input_data)
	LAZYNULL(stamp_cache)

	cut_overlays()
	update_appearance()

/obj/item/paper/pickup(user)
	if(contact_poison && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/obj/item/clothing/gloves/G = H.gloves
		if(!istype(G) || G.transfer_prints)
			H.reagents.add_reagent(contact_poison, contact_poison_volume)
			contact_poison = null
			add_attack_logs(src, user, "Picked up [src], the paper poisoned by [contact_poison_poisoner]")
	. = ..()

/obj/item/paper/update_icon_state()
	if(LAZYLEN(raw_text_inputs) && show_written_words)
		icon_state = "[initial(icon_state)]_words"
	else
		icon_state = initial(icon_state)
	return ..()

GAME_VERB_SRC(/obj/item/paper, rename, usr, "Rename paper", null)

	if(!usr.can_read(src) || usr.is_blind() || INCAPACITATED_IGNORING(usr, INCAPABLE_RESTRAINTS|INCAPABLE_GRAB) || (isobserver(usr) && !usr.can_admin_interact()))
		return
	if(ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(HAS_TRAIT(H, TRAIT_CLUMSY) && prob(25))
			to_chat(H, span_warning("You cut yourself on the paper! Ahhhh! Ahhhhh!"))
			H.damageoverlaytemp = 9001
			H.update_damage_hud()
			return
	var/n_name = tgui_input_text(usr, "Enter a paper label", "Paper Labelling", max_length = MAX_NAME_LEN)
	if(isnull(n_name) || n_name == "")
		return
	if(((loc == usr || istype(loc, /obj/item/clipboard))) && !usr.stat)
		name = "paper[(n_name ? "- '[n_name]'" : null)]"
	add_fingerprint(usr)
	update_static_data()

/obj/item/paper/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] scratches a grid on [user.p_their()] wrist with the paper! It looks like [user.p_theyre()] trying to commit sudoku..."))
	return BRUTELOSS

/obj/item/paper/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click [src] to fold it into a paper plane.")
	if(!in_range(user, src) && !isobserver(user))
		. += span_warning("You're too far away to read it!")
		return

	if(user.is_blind())
		to_chat(user, span_warning("You are blind and can't read anything!"))
		return

	if(user.can_read(src))
		ui_interact(user)
		return
	. += span_warning("You cannot read it!")

/obj/item/paper/ui_status(mob/user, datum/ui_state/state)
	// Are we on fire?  Hard to read if so
	if(resistance_flags & ON_FIRE)
		return UI_CLOSE
	if(camera_holder && can_show_to_mob_through_camera(user) || request_state)
		return UI_UPDATE
	if(!in_range(user, src) && !isobserver(user))
		return UI_CLOSE
	if(INCAPACITATED_IGNORING(user, INCAPABLE_RESTRAINTS|INCAPABLE_GRAB) || (isobserver(user) && !user.can_admin_interact()))
		return UI_UPDATE
	// Even harder to read if your blind...braile? humm
	// .. or if you cannot read
	if(user.is_blind())
		to_chat(user, span_warning("You are blind and can't read anything!"))
		return UI_CLOSE
	if(!user.can_read(src))
		return UI_CLOSE
	if(ismovable(loc) && loc.IsContainedAtomAccessible(src, user))
		return UI_INTERACTIVE
	return ..()

// /obj/item/paper/can_interact(mob/user)
// 	if(ismovable(loc) && loc.IsContainedAtomAccessible(src, user))
// 		return TRUE
// 	return ..()

/obj/item/paper/click_alt(mob/living/user)
	// if(HAS_TRAIT(user, TRAIT_PAPER_MASTER))
	// 	make_plane(user, /obj/item/paperplane/syndicate)
	// 	return CLICK_ACTION_SUCCESS
	make_plane(user, /obj/item/paperplane)
	return CLICK_ACTION_SUCCESS

/**
 * Paper plane folding
 * Makes a paperplane depending on args and returns it.
 *
 * Arguments:
 * * mob/living/user - who's folding
 * * plane_type - what it will be folded into (path)
 */
/obj/item/paper/proc/make_plane(mob/living/user, plane_type = /obj/item/paperplane)
	loc.balloon_alert(user, "folded into a plane")
	user.temporarily_remove_item_from_inventory(src)
	var/obj/item/paperplane/new_plane = new plane_type(loc, src)
	if(user.Adjacent(new_plane))
		user.put_in_hands(new_plane)
	return new_plane

/obj/item/paper/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	// Enable picking paper up by clicking on it with a clipboard, paper bin, or folder
	if(istype(tool, /obj/item/clipboard) || istype(tool, /obj/item/paper_bin) || istype(tool, /obj/item/folder))
		tool.item_interaction(user, src)
		return ITEM_INTERACT_SUCCESS

	// Handle writing items.
	var/writing_stats = tool.get_writing_implement_details()

	if(!writing_stats)
		ui_interact(user)
		return NONE

	if(writing_stats["interaction_mode"] == MODE_WRITING)
		if(!user.can_write(tool))
			return ITEM_INTERACT_BLOCKING
		if(get_total_length() >= MAX_PAPER_LENGTH)
			to_chat(user, span_warning("This sheet of paper is full!"))
			return ITEM_INTERACT_BLOCKING

		ui_interact(user)
		return ITEM_INTERACT_SUCCESS

	// Handle stamping items.
	if(writing_stats["interaction_mode"] == MODE_STAMPING)
		if(!user.can_read(src) || user.is_blind())
			//The paper's stampable window area is assumed approx 300x400
			add_stamp(writing_stats["stamp_class"], rand(0, 300), rand(0, 400), rand(0, 360), writing_stats["stamp_icon_state"], stamp_icon = writing_stats["stamp_icon"])
			user.visible_message(span_notice("[user] blindly stamps [src] with \the [tool]!"))
			to_chat(user, span_notice("You stamp [src] with \the [tool] the best you can!"))
			playsound(src, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)
		else
			to_chat(user, span_notice("You ready your stamp over the paper! "))
			ui_interact(user)
		return ITEM_INTERACT_SUCCESS

	ui_interact(user)
	return NONE

/// Secondary right click interaction to quickly stamp things
/obj/item/paper/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	var/list/writing_stats = tool.get_writing_implement_details()

	if(!length(writing_stats))
		return NONE
	if(writing_stats["interaction_mode"] != MODE_STAMPING)
		return NONE
	if(!user.can_read(src) || user.is_blind()) // Just leftclick instead
		return NONE

	add_stamp(writing_stats["stamp_class"], rand(1, 300), rand(1, 400), stamp_icon_state = writing_stats["stamp_icon_state"], stamp_icon = writing_stats["stamp_icon"])
	user.visible_message(
		span_notice("[user] quickly stamps [src] with [tool] without looking."),
		span_notice("You quickly stamp [src] with [tool] without looking."),
	)
	playsound(src, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)

	return ITEM_INTERACT_BLOCKING // Stop the UI from opening.

/**
 * Attempts to ui_interact the paper to the given user, with some sanity checking
 * to make sure the camera still exists via the weakref and that this paper is still
 * attached to it.
 */
/obj/item/paper/proc/show_through_camera(mob/living/user)
	if(!can_show_to_mob_through_camera(user))
		return

	return ui_interact(user)

/obj/item/paper/proc/can_show_to_mob_through_camera(mob/living/user)
	var/obj/machinery/camera/held_to_camera = camera_holder.resolve()

	if(!held_to_camera)
		return FALSE

	if(isAI(user))
		var/mob/living/silicon/ai/ai_user = user
		if(ai_user.control_disabled || (ai_user.stat == DEAD))
			return FALSE

		return TRUE

	if(user.client?.eye != held_to_camera)
		return FALSE

	return TRUE

/obj/item/paper/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/simple/stamps),
		get_asset_datum(/datum/asset/simple/logos),
	)

/obj/item/paper/ui_interact(mob/user, datum/tgui/ui)
	if(!user.client) //bro stop trying to open UI on AI man ur gonna drive me nuts man comeon man
		return
	if(resistance_flags & ON_FIRE)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		var/list/writing_info = get_viewer_writing_implement_details(user)
		if(writing_info)
			add_writer(user, writing_info, update = FALSE)

		ui = new(user, src, "PaperSheet", name)
		if(!ui.open())
			ui_close(user)
			return
		/**
		 * these signals are for checking whether the ui viewer is holding a writing tool.
		 * (whether they are holding a writing tool matters for the state of the ui)
		 *
		 * we have to do this rigamarole, rather than just checking on ui_data calls,
		 * because if we set this ui to autoupdate, it causes weird rendering issues.
		 * rather than figure out why those are happening, it was easier to just turn off autoupdate.
		 */
		RegisterSignals(user, list(
			COMSIG_MOB_UNEQUIPPED_ITEM,
			COMSIG_MOB_EQUIPPED_ITEM,
			COMSIG_MOB_SWAP_HANDS,
			COMSIG_MOB_TRANSFORMING_ITEM, // specifically for pens
		), PROC_REF(viewer_writing_state_change))
		RegisterSignal(user, COMSIG_MOB_LOGOUT, TYPE_PROC_REF(/datum, ui_close))
		// please see the above comment if you want to re-enable autoupdate
		ui.set_autoupdate(FALSE)

/obj/item/paper/ui_close(mob/user)
	. = ..()
	if(LAZYACCESS(writers, user.UID()))
		remove_writer(user, update = FALSE)
	UnregisterSignal(user, list(
		COMSIG_MOB_UNEQUIPPED_ITEM,
		COMSIG_MOB_EQUIPPED_ITEM,
		COMSIG_MOB_SWAP_HANDS,
		COMSIG_MOB_TRANSFORMING_ITEM,
		COMSIG_MOB_LOGOUT,
	))

/// Generically check if we are holding a writing tool to update our writer status
/obj/item/paper/proc/viewer_writing_state_change(mob/living/source)
	SIGNAL_HANDLER

	var/list/writing_info = get_viewer_writing_implement_details(source)
	if(writing_info)
		if(!LAZYACCESS(writers, source.UID()))
			add_writer(source, writing_info)

	else
		if(LAZYACCESS(writers, source.UID()))
			remove_writer(source)

/// Add passed mob with passed writing info to the list of writers, then updates their ui
/obj/item/paper/proc/add_writer(mob/living/user, list/writing_info, update = TRUE)
	PRIVATE_PROC(TRUE)
	set waitfor = FALSE

	LAZYSET(writers, user.UID(), writing_info)
	if(update)
		ui_interact(user)

/// Remove passed mob from the list of writers, then updates their ui
/obj/item/paper/proc/remove_writer(mob/living/user, update = TRUE)
	PRIVATE_PROC(TRUE)
	set waitfor = FALSE

	LAZYREMOVE(writers, user.UID())
	if(update)
		ui_interact(user)

/obj/item/paper/proc/get_viewer_writing_implement_details(mob/living/user)
	if(istype(loc, /obj/structure/noticeboard))
		var/obj/structure/noticeboard/noticeboard = loc
		if(!noticeboard.allowed(user))
			return null

	var/obj/item/holding = user.get_active_hand()
	. = holding?.get_writing_implement_details()

	// Use a clipboard's pen, if applicable
	if(istype(loc, /obj/item/clipboard))
		var/obj/item/clipboard/clipboard = loc
		. ||= clipboard.containedpen?.get_writing_implement_details()

	return .

/obj/item/paper/ui_data(mob/user)
	var/list/data = list()

	data["held_item_details"] = LAZYACCESS(writers, user.UID())

	return data

/obj/item/paper/ui_static_data(mob/user)
	var/list/static_data = list()

	static_data["user_name"] = user.real_name

	static_data += convert_to_data()

	static_data["max_length"] = MAX_PAPER_LENGTH
	static_data["max_input_field_length"] = MAX_PAPER_INPUT_FIELD_LENGTH

	static_data["default_pen_font"] = PEN_FONT
	static_data["default_pen_color"] = COLOR_BLACK
	static_data["signature_font"] = FOUNTAIN_PEN_FONT

	return static_data

/obj/item/paper/proc/convert_to_data()
	var/list/data = list()

	data[LIST_PAPER_RAW_TEXT_INPUT] = list()
	for(var/datum/paper_input/text_input as anything in raw_text_inputs)
		data[LIST_PAPER_RAW_TEXT_INPUT] += list(text_input.to_list())

	data[LIST_PAPER_RAW_FIELD_INPUT] = list()
	for(var/datum/paper_field/field_input as anything in raw_field_input_data)
		data[LIST_PAPER_RAW_FIELD_INPUT] += list(field_input.to_list())

	data[LIST_PAPER_RAW_STAMP_INPUT] = list()
	for(var/datum/paper_stamp/stamp_input as anything in raw_stamp_data)
		data[LIST_PAPER_RAW_STAMP_INPUT] += list(stamp_input.to_list())

	data[LIST_PAPER_COLOR] = color ? color : COLOR_WHITE
	data[LIST_PAPER_NAME] = name

	return data

/obj/item/paper/proc/write_from_data(list/data)
	for(var/list/input as anything in data[LIST_PAPER_RAW_TEXT_INPUT])
		add_raw_text(input[LIST_PAPER_RAW_TEXT], input[LIST_PAPER_FONT], input[LIST_PAPER_FIELD_COLOR], input[LIST_PAPER_BOLD], input[LIST_PAPER_ADVANCED_HTML])

	for(var/list/field as anything in data[LIST_PAPER_RAW_FIELD_INPUT])
		var/list/input = field[LIST_PAPER_FIELD_DATA]
		add_field_input(field[LIST_PAPER_FIELD_INDEX], input[LIST_PAPER_RAW_TEXT], input[LIST_PAPER_FONT], input[LIST_PAPER_FIELD_COLOR], input[LIST_PAPER_BOLD], field[LIST_PAPER_IS_SIGNATURE])

	for(var/list/stamp as anything in data[LIST_PAPER_RAW_STAMP_INPUT])
		add_stamp(stamp[LIST_PAPER_CLASS], stamp[LIST_PAPER_STAMP_X], stamp[LIST_PAPER_STAMP_Y], stamp[LIST_PAPER_ROTATION])

	var/new_color = data[LIST_PAPER_COLOR]
	if(new_color != COLOR_WHITE)
		add_atom_colour(new_color, FIXED_COLOUR_PRIORITY)

	name = data[LIST_PAPER_NAME]

/obj/item/paper/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	var/mob/user = ui.user

	switch(action)
		if("add_stamp")
			var/obj/item/holding = user.get_active_hand()
			var/stamp_info = holding?.get_writing_implement_details()
			if(!stamp_info || (stamp_info["interaction_mode"] != MODE_STAMPING))
				to_chat(src, span_warning("You can't stamp with the [holding]!"))
				return TRUE

			var/stamp_class = stamp_info["stamp_class"];

			// If the paper is on an unwritable noticeboard, this usually shouldn't be possible.
			if(istype(loc, /obj/structure/noticeboard))
				var/obj/structure/noticeboard/noticeboard = loc
				if(!noticeboard.allowed(user))
					// log_paper("[key_name(user)] tried to add stamp to [name] when it was on an unwritable noticeboard: \"[stamp_class]\"")
					return TRUE

			var/stamp_x = text2num(params["x"])
			var/stamp_y = text2num(params["y"])
			var/stamp_rotation = text2num(params["rotation"])
			var/stamp_icon_state = stamp_info["stamp_icon_state"]
			var/stamp_icon = stamp_info["stamp_icon"]

			if (LAZYLEN(raw_stamp_data) >= MAX_PAPER_STAMPS)
				to_chat(usr, pick("You try to stamp but you miss!", "There is nowhere else you can stamp!"))
				return TRUE

			add_stamp(stamp_class, stamp_x, stamp_y, stamp_rotation, stamp_icon_state, stamp_icon)
			user.visible_message(span_notice("[user] stamps [src] with \the [holding.name]!"), span_notice("You stamp [src] with \the [holding.name]!"))
			playsound(src, 'sound/items/handling/standard_stamp.ogg', 50, vary = TRUE)

			update_appearance()
			ui.close()
			update_static_data_for_all_viewers()
			return TRUE
		if("add_text")
			var/paper_input = params["text"]

			paper_input = replacetext(paper_input, "\[sign\]", "*[user.real_name]*")
			paper_input = replacetext(paper_input, "\[time\]", station_time_timestamp())
			paper_input = replacetext(paper_input, "\[date\]", GLOB.current_date_string)
			paper_input = replacetext(paper_input, "\[station\]", station_name())
			paper_input = replacetext(paper_input, "\[field\]", "\[____\]")

			var/this_input_length = length_char(paper_input)

			if(this_input_length == 0)
				to_chat(user, pick("Writing block strikes again!", "You forgot to write anything!"))
				return TRUE

			// If the paper is on an unwritable noticeboard, this usually shouldn't be possible.
			if(istype(loc, /obj/structure/noticeboard))
				var/obj/structure/noticeboard/noticeboard = loc
				if(!noticeboard.allowed(user))
					// log_paper("[key_name(user)] tried to write to [name] when it was on an unwritable noticeboard: \"[paper_input]\"")
					return TRUE

			var/obj/item/holding = user.get_active_hand()
			// Use a clipboard's pen, if applicable
			if(istype(loc, /obj/item/clipboard))
				var/obj/item/clipboard/clipboard = loc
				// This is just so you can still use a stamp if you're holding one. Otherwise, it'll
				// use the clipboard's pen, if applicable.
				if(!istype(holding, /obj/item/stamp) && clipboard.containedpen)
					holding = clipboard.containedpen

			// As of the time of writing, can_write outputs a message to the user so we don't have to.
			if(!user.can_write(holding))
				return TRUE

			var/current_length = get_total_length()
			var/new_length = current_length + this_input_length

			// tgui should prevent this outcome.
			if(new_length > MAX_PAPER_LENGTH)
				// log_paper("[key_name(user)] tried to write to [name] when it would exceed the length limit by [new_length - MAX_PAPER_LENGTH] characters: \"[paper_input]\"")
				return TRUE

			// Safe to assume there are writing implement details as user.can_write(...) fails with an invalid writing implement.
			var/writing_implement_data = holding.get_writing_implement_details()

			playsound(src, SFX_WRITING_PEN, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE, SOUND_FALLOFF_EXPONENT + 3, ignore_walls = FALSE)

			add_raw_text(paper_input, writing_implement_data["font"], writing_implement_data["color"], writing_implement_data["use_bold"], check_rights_for(user?.client, R_EVENT))

			// log_paper("[key_name(user)] wrote to [name]: \"[paper_input]\"")
			to_chat(user, "You have added to your paper masterpiece!");

			update_static_data_for_all_viewers()
			update_appearance()
			return TRUE
		if("fill_input_field")
			// If the paper is on an unwritable noticeboard, this usually shouldn't be possible.
			if(istype(loc, /obj/structure/noticeboard))
				var/obj/structure/noticeboard/noticeboard = loc
				if(!noticeboard.allowed(user))
					// log_paper("[key_name(user)] tried to write to the input fields of [name] when it was on an unwritable noticeboard!")
					return TRUE

			var/obj/item/holding = user.get_active_hand()
			// Use a clipboard's pen, if applicable
			if(istype(loc, /obj/item/clipboard))
				var/obj/item/clipboard/clipboard = loc
				// This is just so you can still use a stamp if you're holding one. Otherwise, it'll
				// use the clipboard's pen, if applicable.
				if(!istype(holding, /obj/item/stamp) && clipboard.containedpen)
					holding = clipboard.containedpen

			// As of the time of writing, can_write outputs a message to the user so we don't have to.
			if(!user.can_write(holding))
				return TRUE

			// Safe to assume there are writing implement details as user.can_write(...) fails with an invalid writing implement.
			var/writing_implement_data = holding.get_writing_implement_details()
			var/list/field_data = params["field_data"]

			for(var/field_key in field_data)
				var/field_text = field_data[field_key]
				var/text_length = length_char(field_text)
				if(text_length > MAX_PAPER_INPUT_FIELD_LENGTH)
					// log_paper("[key_name(user)] tried to write to field [field_key] with text over the max limit ([text_length] out of [MAX_PAPER_INPUT_FIELD_LENGTH]) with the following text: [field_text]")
					return TRUE
				if(text2num(field_key) >= input_field_count)
					// log_paper("[key_name(user)] tried to write to invalid field [field_key] (when the paper only has [input_field_count] fields) with the following text: [field_text]")
					return TRUE

				// if(!add_field_input(field_key, field_text, writing_implement_data["font"], writing_implement_data["color"], writing_implement_data["use_bold"], user.real_name))
					// log_paper("[key_name(user)] tried to write to field [field_key] when it already has data, with the following text: [field_text]")

			update_static_data_for_all_viewers()
			return TRUE

/obj/item/paper/proc/get_input_field_count(raw_text)
	var/static/regex/field_regex = new(@"\[_+\]","g")

	var/counter = 0
	while(field_regex.Find(raw_text))
		counter++

	return counter

/obj/item/paper/ui_host(mob/user)
	if(istype(loc, /obj/structure/noticeboard))
		return loc
	return ..()

/obj/item/paper/proc/get_total_length()
	var/total_length = 0
	for(var/datum/paper_input/entry as anything in raw_text_inputs)
		total_length += length_char(entry.raw_text)

	return total_length

/// Get a single string representing the text on a page
/obj/item/paper/proc/get_raw_text()
	var/paper_contents = ""
	for(var/datum/paper_input/line as anything in raw_text_inputs)
		paper_contents += line.raw_text + "/"
	return paper_contents

// MARK: Paper datum
/// A single instance of a saved raw input onto paper.
/datum/paper_input
	/// Raw, unsanitised, unparsed text for an input.
	var/raw_text = ""
	/// Font to draw the input with.
	var/font = ""
	/// Colour to draw the input with.
	var/colour = ""
	/// Whether to render the font bold or not.
	var/bold = FALSE
	/// Whether the creator of this input field has the R_FUN permission, thus allowing less sanitization
	var/advanced_html = FALSE

/datum/paper_input/New(_raw_text, _font, _colour, _bold, _advanced_html)
	raw_text = _raw_text
	font = _font
	colour = _colour
	bold = _bold
	advanced_html = _advanced_html

/datum/paper_input/proc/make_copy()
	return new /datum/paper_input(raw_text, font, colour, bold, advanced_html)

/datum/paper_input/proc/to_list()
	return list(
		LIST_PAPER_RAW_TEXT = raw_text,
		LIST_PAPER_FONT = font,
		LIST_PAPER_FIELD_COLOR = colour,
		LIST_PAPER_BOLD = bold,
		LIST_PAPER_ADVANCED_HTML = advanced_html,
	)

/// Returns the raw contents of the input as html, with **ZERO SANITIZATION**
/datum/paper_input/proc/to_raw_html()
	var/final = raw_text
	if(font || colour)
		final = "<font[" color='[colour]'"][" face='[font]'"]>[final]</font>"
	if(bold)
		final = "<b>[final]</b>"
	return final

/// A single instance of a saved stamp on paper.
/datum/paper_stamp
	/// Asset class of the for rendering in tgui
	var/class = ""
	/// X position of stamp.
	var/stamp_x = 0
	/// Y position of stamp.
	var/stamp_y = 0
	/// Rotation of stamp in degrees. 0 to 359.
	var/rotation = 0

/datum/paper_stamp/New(_class, _stamp_x, _stamp_y, _rotation)
	class = _class
	stamp_x = _stamp_x
	stamp_y = _stamp_y
	rotation = _rotation

/datum/paper_stamp/proc/make_copy()
	return new /datum/paper_stamp(class, stamp_x, stamp_y, rotation)

/datum/paper_stamp/proc/to_list()
	return list(
		LIST_PAPER_CLASS = class,
		LIST_PAPER_STAMP_X = stamp_x,
		LIST_PAPER_STAMP_Y = stamp_y,
		LIST_PAPER_ROTATION = rotation,
	)

/// A reference to some data that replaces a modifiable input field at some given index in paper raw input parsing.
/datum/paper_field
	/// When tgui parses the raw input, if it encounters a field_index matching the nth user input field, it will disable it and replace it with the field_data.
	var/field_index = -1
	/// The data that tgui should substitute in-place of the input field when parsing.
	var/datum/paper_input/field_data = null
	/// If TRUE, requests tgui to render this field input in a more signature-y style.
	var/is_signature = FALSE

/datum/paper_field/New(_field_index, raw_text, font, colour, bold, _is_signature)
	field_index = _field_index
	field_data = new /datum/paper_input(raw_text, font, colour, bold)
	is_signature = _is_signature

/datum/paper_field/proc/make_copy()
	return new /datum/paper_field(field_index, field_data.raw_text, field_data.font, field_data.colour, field_data.bold, is_signature)

/datum/paper_field/proc/to_list()
	return list(
		LIST_PAPER_FIELD_INDEX = field_index,
		LIST_PAPER_FIELD_DATA = field_data.to_list(),
		LIST_PAPER_IS_SIGNATURE = is_signature,
	)

// /obj/item/paper/proc/show_content(mob/user, forceshow = FALSE, forcestars = FALSE, infolinks, view = TRUE, window_options, special_text = null)
// 	var/datum/asset/assets = get_asset_datum(/datum/asset/simple/paper)
// 	assets.send(user)

// 	var/data
// 	var/stars = (!user.say_understands(null, GLOB.all_languages[language]) && !forceshow) || forcestars
// 	if(stars) //assuming all paper is written in common is better than hardcoded type checks
// 		data = "[header][stars(info)][footer][stamps]"
// 	else
// 		data = "[header]<div id='markdown'>[infolinks ? info_links : info]</div>[footer][stamps]"
// 	if(CONFIG_GET(flag/twitch_censor))
// 		for(var/char in GLOB.twitch_censor_list)
// 			data = replacetext(data, char, GLOB.twitch_censor_list[char])
// 	if(view)
// 		if(!istype(src, /obj/item/paper/form) && length(info) > 1024)
// 			paper_width = paper_width_big
// 			paper_height = paper_height_big
// 		var/datum/browser/popup = new(user, "Paper[UID()]", , paper_width, paper_height)
// 		popup.include_default_stylesheet = FALSE
// 		popup.set_content(special_text || data)
// 		if(window_options)
// 			popup.set_window_options(window_options)
// 		if(!stars)
// 			popup.add_script("marked.js", 'html/browser/marked.js')
// 			popup.add_script("marked-paradise.js", 'html/browser/marked-paradise.js')
// 		popup.add_head_content("<title>[name]</title>")
// 		popup.open()
// 	return data

// /obj/item/paper/click_alt(mob/living/carbon/human/user)
// 	if(is_pen(user.get_active_hand()))
// 		rename(user)
// 		return CLICK_ACTION_SUCCESS
// 	if(user.is_in_hands(src))
// 		ProcFoldPlane(user, src)
// 		return CLICK_ACTION_SUCCESS

// /obj/item/paper/proc/rename(mob/user)
// 	if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
// 		to_chat(user, span_warning("You cut yourself on the paper."))
// 		return
// 	if(!user.is_literate())
// 		to_chat(user, span_notice("You don't know how to read."))
// 		return
// 	var/n_name = rename_interactive(user)
// 	if(isnull(n_name))
// 		return
// 	if(n_name != "")
// 		desc = "This is a paper titled '" + name + "'."
// 	else
// 		desc = initial(desc)
// 	add_fingerprint(user)

// /obj/item/paper/attack_self(mob/living/user as mob)
// 	user.examinate(src)
// 	if(rigged && !spam_flag && (SSholiday.holidays && SSholiday.holidays[APRIL_FOOLS]))
// 		spam_flag = TRUE
// 		addtimer(VARSET_CALLBACK(src, spam_flag, FALSE), 3 SECONDS)
// 		playsound(loc, 'sound/items/bikehorn.ogg', 50, TRUE)

// /obj/item/paper/attack_ai(mob/living/silicon/ai/user)
// 	var/dist
// 	if(isAI(user) && user.current) //is AI
// 		dist = get_dist(src, user.current)
// 	else //cyborg or AI not seeing through a camera
// 		dist = get_dist(src, user)
// 	if(dist < 2)
// 		show_content(user, forceshow = TRUE)
// 	else
// 		show_content(user, forcestars = TRUE)

// /obj/item/paper/attack(mob/living/carbon/human/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
// 	. = ..()
// 	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !ishuman(target))
// 		return .

// 	switch(user.zone_selected)
// 		if(BODY_ZONE_PRECISE_EYES)
// 			user.visible_message(
// 				span_warning("[user] is trying to show the paper to [target]."),
// 				span_notice("You hold up a paper and try to show it to [target]."),
// 			)
// 			if(!do_after(user, 0.7 SECONDS, target, NONE))
// 				to_chat(user, span_warning("You fail to show the paper to [target]."))
// 				return .
// 			user.visible_message(
// 				span_notice("[user] shows the paper to [target]."),
// 				span_notice("You hold up a paper and show it to [target]."),
// 			)
// 			target.examinate(src)

// 		if(BODY_ZONE_PRECISE_MOUTH)
// 			if(target == user)
// 				to_chat(user, span_notice("You wipe off your face with [src]."))
// 			else
// 				user.visible_message(
// 					span_warning("[user] starts to wipe [target]'s face clean with [src]."),
// 					span_notice("You start to wipe off [target]'s face."),
// 				)
// 				if(!do_after(user, 1 SECONDS, target))
// 					return .
// 				user.visible_message(
// 					span_notice("[user] wipes [target]'s face clean with [src]."),
// 					span_notice("You wipe off [target]'s face."),
// 				)
// 			target.lip_style = null
// 			target.lip_color = null
// 			target.update_body()

// /obj/item/paper/attack_animal(mob/living/simple_animal/pet/dog/doggo)
// 	if(!isdog(doggo)) // Only dogs can eat homework.
// 		return
// 	doggo.changeNext_move(CLICK_CD_MELEE)
// 	if(world.time < doggo.last_eaten + 30 SECONDS)
// 		to_chat(doggo, span_warning("You are too full to try eating [src] now."))
// 		return

// 	doggo.visible_message(
// 		span_warning("[doggo] starts chewing the corner of [src]!"),
// 		span_notice("You start chewing the corner of [src]."),
// 		span_warning("You hear a quiet gnawing, and the sound of paper rustling.")
// 	)
// 	playsound(src, 'sound/effects/pageturn2.ogg', 100, TRUE)
// 	if(!do_after(doggo, 10 SECONDS, src, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
// 		return

// 	if(world.time < doggo.last_eaten + 30 SECONDS) // Check again to prevent eating multiple papers at once.
// 		to_chat(doggo, span_warning("You are too full to try eating [src] now."))
// 		return
// 	doggo.last_eaten = world.time

// 	// 90% chance of a crumpled paper with illegible text.
// 	if(prob(90))
// 		var/message_ending = "."
// 		var/obj/item/paper/crumpled/crumped = new(loc)
// 		crumped.name = name
// 		if(info) // Something written on the paper.
// 			crumped.info = "<i>Whatever was once written here has been made completely illegible by a combination of chew marks and saliva.</i>"
// 			message_ending = ", the drool making it an unreadable mess!"
// 		crumped.update_icon()
// 		qdel(src)

// 		doggo.visible_message(
// 			span_warning("[doggo] finishes eating [src][message_ending]"),
// 			span_notice("You finish eating [src][message_ending]")
// 		)
// 		doggo.emote("bark")

// 	// 10% chance of the paper just being eaten entirely.
// 	else
// 		doggo.visible_message(
// 			span_warning("[doggo] swallows [src] whole!"),
// 			span_notice("You swallow [src] whole. Tasty!")
// 		)
// 		playsound(doggo, 'sound/items/eatfood.ogg', 50, TRUE)
// 		qdel(src)

// /obj/item/paper/proc/addtofield(id, text, links = 0)
// 	if(id > MAX_PAPER_FIELDS)
// 		return

// 	var/locid = 0
// 	var/laststart = 1
// 	var/textindex = 1
// 	while(locid <= MAX_PAPER_FIELDS)
// 		var/istart = 0
// 		if(links)
// 			istart = findtext_char(info_links, "<span class=\"paper_field\">", laststart)
// 		else
// 			istart = findtext_char(info, "<span class=\"paper_field\">", laststart)

// 		if(!istart)
// 			return // No field found with matching id

// 		laststart = istart+1
// 		locid++
// 		if(locid == id)
// 			var/iend = 1
// 			if(links)
// 				iend = findtext_char(info_links, "</span>", istart)
// 			else
// 				iend = findtext_char(info, "</span>", istart)

// 			textindex = iend
// 			break

// 	if(links)
// 		var/before = copytext_char(info_links, 1, textindex)
// 		var/after = copytext_char(info_links, textindex)
// 		info_links = before + text + after
// 	else
// 		var/before = copytext_char(info, 1, textindex)
// 		var/after = copytext_char(info, textindex)
// 		info = before + text + after
// 		updateinfolinks()

// /obj/item/paper/proc/updateinfolinks()
// 	info_links = info
// 	for(var/i in 1 to fields)
// 		var/write_1 = "<font face=\"[deffont]\"><a href='byond://?src=[UID()];write=[i]'>write</a></font>"
// 		var/write_2 = "<font face=\"[deffont]\"><a href='byond://?src=[UID()];auto_write=[i]'><span style=\"color: #409F47; font-size: 10px\">\[a\]</span></a></font>"
// 		addtofield(i, "[write_1][write_2]", 1)
// 	info_links = info_links + "<font face=\"[deffont]\"><a href='byond://?src=[UID()];write=end'>write</a></font>" + "<font face=\"[deffont]\"><a href='byond://?src=[UID()];auto_write=end'><span style=\"color: #409F47; font-size: 10px\">\[A\]</span></a></font>"

// /obj/item/paper/proc/parsepencode(t, obj/item/pen/P, mob/user as mob)
// 	t = pencode_to_html(html_encode(t), usr, P, TRUE, TRUE, TRUE, deffont, signfont, crayonfont)
// 	return t

// /obj/item/paper/proc/populatefields()
// 	//Count the fields
// 	var/laststart = 1
// 	while(fields < MAX_PAPER_FIELDS)
// 		var/i = findtext_char(info, "<span class=\"paper_field\">", laststart)
// 		if(!i)
// 			break
// 		laststart = i+1
// 		fields++

/obj/item/paper/proc/openhelp(mob/user)
	var/datum/browser/popup = new(user, "paper_help", "Pen Help")
	popup.set_content({"
		<b><center>Crayon&Pen commands</center></b><br>
		<br>
		\[br\] : Creates a linebreak.<br>
		\[center\] - \[/center\] : Centers the text.<br>
		\[h1\] - \[/h1\] : Makes the text a first level heading<br>
		\[h2\] - \[/h2\] : Makes the text a second level heading<br>
		\[h3\] - \[/h3\] : Makes the text a third level heading<br>
		\[b\] - \[/b\] : Makes the text <b>bold</b>.<br>
		\[i\] - \[/i\] : Makes the text <i>italic</i>.<br>
		\[u\] - \[/u\] : Makes the text <u>underlined</u>.<br>
		\[large\] - \[/large\] : Increases the <font size = \"4\">size</font> of the text.<br>
		\[sign\] : Inserts a signature of your name in a foolproof way.<br>
		\[field\] : Inserts an invisible field which lets you start type from there. Useful for forms.<br>
		<br>
		<b><center>Pen exclusive commands</center></b><br>
		\[small\] - \[/small\] : Decreases the <font size = \"1\">size</font> of the text.<br>
		\[list\] - \[/list\] : A list.<br>
		\[*\] : A dot used for lists.<br>
		\[hr\] : Adds a horizontal rule.
		\[time\] : Inserts the current station time in HH:MM:SS.<br>"})
	popup.open(FALSE)

// /obj/item/paper/proc/topic_href_write(mob/user, id, input_element)
// 	var/obj/item/item_write = user.get_active_hand() // Check to see if he still got that darn pen, also check if he's using a crayon or pen.
// 	add_hiddenprint(user) // No more forging nasty documents as someone else, you jerks
// 	if(!is_pen(item_write) && !iscrayon(item_write))
// 		return

// 	if(is_pen(item_write)) // Can't use TRAIT_TRANSFORM_ACTIVE cause you can click multipen or fountain pen
// 		var/obj/item/pen/writing_pen = item_write
// 		if(!writing_pen.can_write)
// 			balloon_alert(user, "защёлкнуто!")
// 			return

// 	if(loc != user && !Adjacent(user, recurse = 2) && !loc.Adjacent(user))
// 		return // If paper is not in usr, then it must be near them

// 	input_element = parsepencode(input_element, item_write, user) // Encode everything from pencode to html

// 	if(QDELETED(src) || !loc || (loc != user && !Adjacent(user, recurse = 2) && !loc.Adjacent(user)))
// 		return

// 	if(id != "end")
// 		addtofield(text2num(id), input_element) // He wants to edit a field, let him.
// 	else
// 		info += input_element // Oh, he wants to edit to the end of the file, let him.

// 	populatefields()
// 	updateinfolinks()
// 	item_write.on_write(src, user)
// 	show_content(user, forceshow = TRUE, infolinks = TRUE)
// 	update_icon()

// /obj/item/paper/Topic(href, href_list)
// 	..()
// 	if(!usr || usr.incapacitated || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
// 		return

// 	if(href_list["auto_write"])
// 		var/id = href_list["auto_write"]

// 		var/const/sign_text = "\[Поставить подпись\]"
// 		var/const/account_text = "\[Написать номер аккаунта\]"
// 		var/const/pin_text = "\[Написать пин-код\]"
// 		var/const/time_text = "\[Написать текущее время\]"
// 		var/const/date_text = "\[Написать текущую дату\]"
// 		var/const/station_text = "\[Написать название станции\]"
// 		var/const/gender_text = "\[Указать пол\]"
// 		var/const/species_text = "\[Указать расу\]"

// 		var/list/menu_list = list()	// text items in the menu

// 		menu_list.Add(usr.real_name)	// the real name of the character, even if it is hidden

// 		if(usr.real_name != usr.name && lowertext(usr.name) != lowertext(UNKNOWN_NAME_RUS))	// if the player is masked or the name is different a new answer option is added
// 			menu_list.Add(usr.name)

// 		if(usr.job)
// 			menu_list.Add(get_job_title_ru(usr.job))	// job

// 		menu_list.Add(sign_text)	//signature

// 		if(usr.mind?.initial_account?.account_number)
// 			menu_list.Add(account_text)	// account number

// 		if(usr.mind?.initial_account?.remote_access_pin)
// 			menu_list.Add(pin_text)	// account pin-code

// 		menu_list.Add(
// 			time_text,		// time
// 			date_text,		// date
// 			station_text,	// station name
// 			gender_text,	// gender
// 		)

// 		if(usr.dna?.species)
// 			menu_list.Add(species_text)	//current

// 		var/input_element = tgui_input_list(usr, "Выберите текст который хотите добавить:", "Выбор пункта", menu_list)
// 		if(!input_element)
// 			return

// 		switch(input_element)	//format selected menu items in pencode and internal data
// 			if(sign_text)
// 				input_element = "\[sign\]"
// 			if(time_text)
// 				input_element = "\[time\]"
// 			if(date_text)
// 				input_element = "\[date\]"
// 			if(station_text)
// 				input_element = "\[station\]"
// 			if(account_text)
// 				input_element = usr.mind.initial_account.account_number
// 			if(pin_text)
// 				input_element = usr.mind.initial_account.remote_access_pin
// 			if(gender_text)
// 				input_element = usr.gender
// 			if(species_text)
// 				input_element = usr.dna.species

// 		topic_href_write(usr, id, input_element)

// 	if(href_list["write"])
// 		var/id = href_list["write"]																			/* Becаuse HTML */
// 		var/input_element = tgui_input_text(usr, "Enter what you want to write:", "Write", multiline = TRUE, max_length = 3000, encode = FALSE)

// 		topic_href_write(usr, id, input_element)

// /obj/item/paper/attackby(obj/item/I, mob/living/user, params)
// 	if(resistance_flags & ON_FIRE)
// 		return ATTACK_CHAIN_BLOCKED_ALL

// 	if(I.get_temperature())
// 		if(!Adjacent(user)) //to prevent issues as a result of telepathically lighting a paper
// 			return ATTACK_CHAIN_BLOCKED_ALL

// 		add_fingerprint(user)
// 		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(10))
// 			user.visible_message(
// 				span_warning("[user] accidentally ignites [user.p_them()]self!"),
// 				span_userdanger("You miss the paper and accidentally light yourself on fire!"),
// 			)
// 			user.drop_item_ground(I)
// 			user.adjust_fire_stacks(1)
// 			user.IgniteMob()
// 			return ATTACK_CHAIN_BLOCKED_ALL

// 		user.drop_item_ground(src)
// 		user.visible_message(
// 			span_danger("[user] lights [src] ablaze with [I]!"),
// 			span_danger("You light [src] on fire!"),
// 		)
// 		fire_act()
// 		return ATTACK_CHAIN_BLOCKED_ALL

// 	if(is_pen(I) || iscrayon(I))
// 		add_fingerprint(user)
// 		if(!user.is_literate())
// 			to_chat(user, span_warning("You don't know how to write!"))
// 			return ATTACK_CHAIN_PROCEED
// 		var/obj/item/pen/multi/robopen/robopen = I
// 		if(istype(I, /obj/item/pen/multi/robopen) && robopen.mode == 2)
// 			robopen.RenamePaper(user,src)
// 		else
// 			show_content(user, infolinks = TRUE)
// 		return ATTACK_CHAIN_BLOCKED_ALL

// 	if(istype(I, /obj/item/stamp))
// 		if(!Adjacent(user, recurse = 2))
// 			return ATTACK_CHAIN_PROCEED
// 		add_fingerprint(user)
// 		if(istype(I, /obj/item/stamp/clown) && (user.mind && (user.mind.assigned_role != JOB_TITLE_CLOWN)))
// 			to_chat(user, span_userdanger("You are totally unable to use the stamp. HONK!"))
// 			return ATTACK_CHAIN_PROCEED
// 		stamp(I)
// 		to_chat(user, span_notice("You have stamped the paper with [I]."))
// 		playsound(user, 'sound/items/handling/standard_stamp.ogg', 50, TRUE)
// 		return ATTACK_CHAIN_PROCEED

// 	if(!istype(I, /obj/item/paper) && !istype(I, /obj/item/photo))
// 		return ..()

// 	add_fingerprint(user)

// 	if(istype(I, /obj/item/paper/carbon))
// 		var/obj/item/paper/carbon/carbon_paper = I
// 		if(!carbon_paper.iscopy && !carbon_paper.copied)
// 			to_chat(user, span_notice("Take off the carbon copy first."))
// 			return .

// 	if(!joinable)
// 		return ATTACK_CHAIN_PROCEED

// 	if(loc == user && !user.can_unEquip(src))
// 		return ATTACK_CHAIN_PROCEED

// 	if(!user.drop_transfer_item_to_loc(I, src))
// 		return ATTACK_CHAIN_PROCEED

// 	. = ATTACK_CHAIN_BLOCKED_ALL

// 	var/obj/item/paper_bundle/bundle = new(drop_location(), FALSE)
// 	transfer_fingerprints_to(bundle)
// 	bundle.add_fingerprint(user)

// 	if(name != "paper")
// 		bundle.name = name
// 	else if(I.name != "paper" && I.name != "photo")
// 		bundle.name = I.name

// 	to_chat(user, span_notice("You clip the [I.name] to [(name == "paper") ? "the paper" : name]."))

// 	if(loc == user)
// 		user.transfer_item_to_loc(src, bundle, silent = TRUE)
// 		user.put_in_hands(bundle)
// 	else
// 		bundle.pixel_x = pixel_x
// 		bundle.pixel_y = pixel_y
// 		forceMove(bundle)

// 	close_window(user, "[istype(I, /obj/item/paper) ? "Paper" : "Photo"][I.UID()]")
// 	close_window(user, "Paper[UID()]")
// 	bundle.papers += src
// 	bundle.papers += I
// 	bundle.amount++
// 	bundle.update_appearance(UPDATE_ICON|UPDATE_DESC)

/obj/item/paper/fire_act(exposed_temperature, exposed_volume)
	..()
	if(!(resistance_flags & FIRE_PROOF))
		default_raw_text = "<i>Heat-curled corners and sooty words offer little insight. Whatever was once written on this page has been rendered illegible through fire.</i>"

// /obj/item/paper/proc/stamp(obj/item/stamp/stamp, no_pixel_shift = FALSE, special_stamped, special_icon_state)
// 	var/obj/item/stamp/stamp_path
// 	if(!ispath(stamp, /obj/item/stamp))
// 		if(istype(stamp, /obj/item/stamp))
// 			stamp_path = stamp.type
// 		else
// 			CRASH("Wrong argument passed as a stamp value ([stamp]).")
// 	else
// 		stamp_path = stamp

// 	var/stamp_count = LAZYLEN(stamped)
// 	if(stamp_count >= stamp_limit)
// 		return //can't fret over every stamp

// 	LAZYADD(stamped, stamp_path)

// 	var/new_icon_state = istype(stamp, /obj/item/stamp/chameleon) ? stamp.icon_state : special_icon_state ? special_icon_state : initial(stamp_path.icon_state)

// 	if(!stamps)
// 		stamps = "<hr>"
// 	stamps += special_stamped ? special_stamped : "<img src=large_[new_icon_state].png>"

// 	var/mutable_appearance/stampoverlay = mutable_appearance('icons/obj/service/bureaucracy.dmi', "paper_[new_icon_state]")
// 	var/stamp_offset_w
// 	var/stamp_offset_z
// 	if(no_pixel_shift)
// 		stamp_offset_w = 0
// 		stamp_offset_z = 0
// 	else if(ispath(stamp_path, /obj/item/stamp/captain) || ispath(stamp_path, /obj/item/stamp/centcom))
// 		stamp_offset_w = rand(-2, 0)
// 		stamp_offset_z = rand(-1, 2)
// 	else
// 		stamp_offset_w = rand(-2, 2)
// 		stamp_offset_z = rand(-3, 2)
// 	stampoverlay.pixel_w = stamp_offset_w
// 	stampoverlay.pixel_z = stamp_offset_z
// 	LAZYADD(stamp_overlays, stampoverlay)
// 	update_icon(UPDATE_OVERLAYS)
