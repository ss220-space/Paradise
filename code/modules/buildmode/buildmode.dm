#define BM_SWITCHSTATE_NONE	0
#define BM_SWITCHSTATE_MODE	1
#define BM_SWITCHSTATE_DIR	2

/datum/click_intercept/buildmode
	var/build_dir = SOUTH
	var/datum/buildmode_mode/mode

	// SECTION UI

	// Switching management
	var/switch_state = BM_SWITCHSTATE_NONE
	var/switch_width = 4
	// modeswitch UI
	var/atom/movable/screen/buildmode/mode/modebutton
	var/list/modeswitch_buttons = list()
	// dirswitch UI
	var/atom/movable/screen/buildmode/bdir/dirbutton
	var/list/dirswitch_buttons = list()
	/// Item preview for selected item.
	var/atom/movable/screen/buildmode/preview_item/preview

/datum/click_intercept/buildmode/New()
	mode = new /datum/buildmode_mode/basic(src)
	. = ..()
	mode.enter_mode(src)

/datum/click_intercept/buildmode/Destroy()
	close_switchstates()
	close_preview()
	QDEL_NULL(mode)
	QDEL_LIST(modeswitch_buttons)
	QDEL_LIST(dirswitch_buttons)
	modebutton = null
	dirbutton = null
	return ..()

/datum/click_intercept/buildmode/create_buttons()
	// keep a reference so we can update it upon mode switch
	modebutton = new /atom/movable/screen/buildmode/mode(src)
	buttons += modebutton
	buttons += new /atom/movable/screen/buildmode/help(src)
	// keep a reference so we can update it upon dir switch
	dirbutton = new /atom/movable/screen/buildmode/bdir(src)
	buttons += dirbutton
	buttons += new /atom/movable/screen/buildmode/quit(src)
	// build the list of modeswitching buttons
	build_options_grid(subtypesof(/datum/buildmode_mode), modeswitch_buttons, /atom/movable/screen/buildmode/modeswitch)
	build_options_grid(GLOB.alldirs, dirswitch_buttons, /atom/movable/screen/buildmode/dirswitch)

/datum/click_intercept/buildmode/proc/build_options_grid(list/elements, list/buttonslist, buttontype)
	var/pos_idx = 0
	for(var/thing in elements)
		var/x = pos_idx % switch_width
		var/y = FLOOR(pos_idx / switch_width, 1)
		var/atom/movable/screen/buildmode/B = new buttontype(src, thing)
		// extra .5 for a nice offset look
		B.screen_loc = "NORTH-[(1 + 0.5 + y*1.5)],WEST+[0.5 + x*1.5]"
		buttonslist += B
		pos_idx++

/datum/click_intercept/buildmode/proc/close_switchstates()
	switch(switch_state)
		if(BM_SWITCHSTATE_MODE)
			close_modeswitch()
		if(BM_SWITCHSTATE_DIR)
			close_dirswitch()

/datum/click_intercept/buildmode/proc/toggle_modeswitch()
	if(switch_state == BM_SWITCHSTATE_MODE)
		close_modeswitch()
	else
		close_switchstates()
		open_modeswitch()

/datum/click_intercept/buildmode/proc/open_modeswitch()
	switch_state = BM_SWITCHSTATE_MODE
	holder.screen += modeswitch_buttons

/datum/click_intercept/buildmode/proc/close_modeswitch()
	switch_state = BM_SWITCHSTATE_NONE
	holder.screen -= modeswitch_buttons

/datum/click_intercept/buildmode/proc/toggle_dirswitch()
	if(switch_state == BM_SWITCHSTATE_DIR)
		close_dirswitch()
	else
		close_switchstates()
		open_dirswitch()

/datum/click_intercept/buildmode/proc/open_dirswitch()
	switch_state = BM_SWITCHSTATE_DIR
	holder.screen += dirswitch_buttons

/datum/click_intercept/buildmode/proc/close_dirswitch()
	switch_state = BM_SWITCHSTATE_NONE
	holder.screen -= dirswitch_buttons

/datum/click_intercept/buildmode/proc/preview_selected_item(atom/typepath)
	close_preview()
	preview = new /atom/movable/screen/buildmode/preview_item(src)
	preview.name = initial(typepath.name)

	// Scale the preview if it's bigger than one tile
	var/mutable_appearance/preview_overlay = get_small_overlay(new /mutable_appearance(typepath))
	preview_overlay.appearance_flags |= TILE_BOUND
	preview_overlay.layer = FLOAT_LAYER
	preview_overlay.plane = FLOAT_PLANE
	preview.add_overlay(preview_overlay)

	holder.screen += preview

/datum/click_intercept/buildmode/proc/close_preview()
	if(isnull(preview))
		return
	holder.screen -= preview
	QDEL_NULL(preview)

/datum/click_intercept/buildmode/proc/change_mode(newmode)
	mode.exit_mode(src)
	QDEL_NULL(mode)
	close_switchstates()
	mode = new newmode(src)
	mode.enter_mode(src)
	modebutton.update_icon()

/datum/click_intercept/buildmode/proc/change_dir(newdir)
	build_dir = newdir
	close_dirswitch()
	dirbutton.update_icon()
	return TRUE

/datum/click_intercept/buildmode/InterceptClickOn(user, params, atom/object)
	mode.handle_click(user, params, object)

/proc/togglebuildmode(mob/user as mob in  GLOB.player_list)
	set name = "Toggle Build Mode"
	set category = STATPANEL_ADMIN_EVENT

	if(user.client)
		if(istype(user.client.click_intercept, /datum/click_intercept/buildmode))
			var/datum/click_intercept/buildmode/buildmode = user.client.click_intercept
			buildmode.quit()
			log_admin("[key_name(user)] has left build mode.")
		else
			new/datum/click_intercept/buildmode(user.client)
			message_admins("[key_name_admin(user)] has entered build mode.")
			log_admin("[key_name(user)] has entered build mode.")

#undef BM_SWITCHSTATE_NONE
#undef BM_SWITCHSTATE_MODE
#undef BM_SWITCHSTATE_DIR
