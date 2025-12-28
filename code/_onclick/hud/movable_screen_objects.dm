
//////////////////////////
//Movable Screen Objects//
//   By RemieRichards	//
//////////////////////////

//Movable Screen Object
//Not tied to the grid, places it's center where the cursor is

/atom/movable/screen/movable
	var/snap2grid = FALSE
	var/moved = FALSE
	var/locked = TRUE
	var/x_off = -16
	var/y_off = -16

//Snap Screen Object
//Tied to the grid, snaps to the nearest turf

/atom/movable/screen/movable/snap
	snap2grid = TRUE

/atom/movable/screen/movable/mouse_drop_dragged(atom/over, mob/user, src_location, over_location, params)
	var/position = mouse_params_to_position(params)
	if(!position)
		return

	screen_loc = position

/// Takes mouse parmas as input, returns a string representing the appropriate mouse position
/atom/movable/screen/movable/proc/mouse_params_to_position(params)
	var/list/modifiers = params2list(params)

	//No screen-loc information? abort.
	if(!LAZYACCESS(modifiers, SCREEN_LOC))
		return
	var/client/our_client = usr.client
	var/list/offset	= screen_loc_to_offset(LAZYACCESS(modifiers, SCREEN_LOC))
	if(snap2grid) //Discard Pixel Values
		offset[1] = FLOOR(offset[1], ICON_SIZE_X) // drops any pixel offset
		offset[2] = FLOOR(offset[2], ICON_SIZE_Y) // drops any pixel offset
	else //Normalise Pixel Values (So the object drops at the center of the mouse, not 16 pixels off)
		offset[1] += x_off
		offset[2] += y_off
	return offset_to_screen_loc(offset[1], offset[2], our_client?.view)

/atom/movable/screen/movable/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(locked) //no! I am locked! begone!
		return

	var/list/modifiers = params2list(params)

	//No screen-loc information? abort.
	if(!LAZYACCESS(modifiers, SCREEN_LOC))
		return

	//Split screen-loc up into X+Pixel_X and Y+Pixel_Y
	var/list/screen_loc_params = splittext(LAZYACCESS(modifiers, SCREEN_LOC), ",")

	//Split X+Pixel_X up into list(X, Pixel_X)
	var/list/screen_loc_X = splittext(screen_loc_params[1],":")

	//Split Y+Pixel_Y up into list(Y, Pixel_Y)
	var/list/screen_loc_Y = splittext(screen_loc_params[2],":")

	if(snap2grid) //Discard Pixel Values
		screen_loc = "[screen_loc_X[1]],[screen_loc_Y[1]]"

	else //Normalise Pixel Values (So the object drops at the center of the mouse, not 16 pixels off)
		var/pix_X = text2num(screen_loc_X[2]) + x_off
		var/pix_Y = text2num(screen_loc_Y[2]) + y_off
		screen_loc = "[screen_loc_X[1]]:[pix_X],[screen_loc_Y[1]]:[pix_Y]"

	moved = screen_loc

//Debug procs
/client/proc/test_movable_UI()
	set category = STATPANEL_DEBUG
	set name = "Spawn Movable UI Object"

	var/atom/movable/screen/movable/M = new()
	M.name = "Movable UI Object"
	M.icon_state = "block"
	M.maptext = MAPTEXT("Movable")
	M.maptext_width = 64

	var/screen_l = tgui_input_text(usr, "Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)", "Spawn Movable UI Object")
	if(!screen_l)
		return

	M.screen_loc = screen_l

	screen += M

/client/proc/test_snap_UI()
	set category = STATPANEL_DEBUG
	set name = "Spawn Snap UI Object"

	var/atom/movable/screen/movable/snap/S = new()
	S.name = "Snap UI Object"
	S.icon_state = "block"
	S.maptext = MAPTEXT("Snap")
	S.maptext_width = 64

	var/screen_l = tgui_input_text(usr, "Where on the screen? (Formatted as 'X,Y' e.g: '1,1' for bottom left)", "Spawn Snap UI Object")
	if(!screen_l)
		return

	S.screen_loc = screen_l

	screen += S
