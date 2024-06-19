/*
	The hud datum
	Used to show and hide huds for all the different mob types,
	including inventories and item quick actions.
*/

/datum/hud
	var/mob/mymob

	var/hud_shown = TRUE			//Used for the HUD toggle (F12)
	var/hud_version = 1				//Current displayed version of the HUD
	var/inventory_shown = TRUE		//the inventory
	var/hotkey_ui_hidden = FALSE	//This is to hide the buttons that can be used via hotkeys. (hotkeybuttons list of buttons)

	var/atom/movable/screen/lingchemdisplay
	var/atom/movable/screen/lingstingdisplay

	var/atom/movable/screen/guardianhealthdisplay

	var/atom/movable/screen/blobpwrdisplay
	var/atom/movable/screen/blobhealthdisplay
	var/atom/movable/screen/vampire_blood_display
	var/atom/movable/screen/ninja_energy_display
	var/atom/movable/screen/ninja_focus_display
	var/atom/movable/screen/wind_up_timer
	var/atom/movable/screen/alien_plasma_display
	var/atom/movable/screen/nightvisionicon
	var/atom/movable/screen/action_intent
	var/atom/movable/screen/zone_select
	var/atom/movable/screen/move_intent
	var/atom/movable/screen/module_store_icon
	var/atom/movable/screen/combo/combo_display

	var/atom/movable/screen/devil/soul_counter/devilsouldisplay

	var/list/static_inventory = list()		//the screen objects which are static
	var/list/toggleable_inventory = list()	//the screen objects which can be hidden
	var/list/hotkeybuttons = list()			//the buttons that can be used via hotkeys
	var/list/infodisplay = list()			//the screen objects that display mob info (health, alien plasma, etc...)
	var/list/inv_slots[SLOT_HUD_AMOUNT]			// /atom/movable/screen/inventory objects, ordered by their slot ID.
	/// List of atom/movable/screen/inventory/hand objects
	var/list/hand_slots

	var/atom/movable/screen/movable/action_button/hide_toggle/hide_actions_toggle
	var/action_buttons_hidden = FALSE

	/// Assoc list of key => "plane master groups"
	/// This is normally just the main window, but it'll occasionally contain things like spyglasses windows
	var/list/datum/plane_master_group/master_groups = list()
	///Assoc list of controller groups, associated with key string group name with value of the plane master controller ref
	var/list/atom/movable/plane_master_controller/plane_master_controllers = list()

	/// Think of multiz as a stack of z levels. Each index in that stack has its own group of plane masters
	/// This variable is the plane offset our mob/client is currently "on"
	/// We use it to track what we should show/not show
	/// Goes from 0 to the max (z level stack size - 1)
	var/current_plane_offset = 0

/datum/hud/New(mob/owner)
	mymob = owner
	hide_actions_toggle = new
	hide_actions_toggle.InitialiseIcon(mymob)

	hand_slots = list()

	var/datum/plane_master_group/main/main_group = new(PLANE_GROUP_MAIN)
	main_group.attach_to(src)

	for(var/mytype in subtypesof(/atom/movable/plane_master_controller))
		var/atom/movable/plane_master_controller/controller_instance = new mytype(src)
		plane_master_controllers[controller_instance.name] = controller_instance

	RegisterSignal(SSmapping, COMSIG_PLANE_OFFSET_INCREASE, PROC_REF(on_plane_increase))
	RegisterSignal(mymob, COMSIG_MOB_LOGIN, PROC_REF(client_refresh))
	RegisterSignal(mymob, COMSIG_MOB_LOGOUT, PROC_REF(clear_client))
	RegisterSignal(mymob, COMSIG_MOB_SIGHT_CHANGE, PROC_REF(update_sightflags))
	update_sightflags(mymob, mymob.sight, NONE)

/datum/hud/proc/client_refresh(datum/source)
	RegisterSignal(mymob.client, COMSIG_CLIENT_SET_EYE, PROC_REF(on_eye_change), TRUE)
	on_eye_change(null, null, mymob.client.eye)

/datum/hud/proc/clear_client(datum/source)
	if(mymob.client)
		UnregisterSignal(mymob.client, COMSIG_CLIENT_SET_EYE)

/datum/hud/proc/on_eye_change(datum/source, atom/old_eye, atom/new_eye)
	SIGNAL_HANDLER
	if(old_eye)
		UnregisterSignal(old_eye, COMSIG_MOVABLE_Z_CHANGED)
	if(new_eye)
		// By the time logout runs, the client's eye has already changed
		// There's just no log of the old eye, so we need to override
		// :sadkirby:
		RegisterSignal(new_eye, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(eye_z_changed), override = TRUE)
	eye_z_changed(new_eye)

/datum/hud/proc/update_sightflags(datum/source, new_sight, old_sight)
	// If neither the old and new flags can see turfs but not objects, don't transform the turfs
	// This is to ensure parallax works when you can't see holder objects
	if(should_sight_scale(new_sight) == should_sight_scale(old_sight))
		return

	for(var/group_key as anything in master_groups)
		var/datum/plane_master_group/group = master_groups[group_key]
		group.transform_lower_turfs(src, current_plane_offset)

/datum/hud/proc/should_use_scale()
	return should_sight_scale(mymob.sight)

/datum/hud/proc/should_sight_scale(sight_flags)
	return (sight_flags & (SEE_TURFS | SEE_OBJS)) != SEE_TURFS

/datum/hud/proc/eye_z_changed(atom/eye)
	SIGNAL_HANDLER
	update_parallax_pref() // If your eye changes z level, so should your parallax prefs
	var/turf/eye_turf = get_turf(eye)
	var/new_offset = GET_TURF_PLANE_OFFSET(eye_turf)
	if(current_plane_offset == new_offset)
		return
	var/old_offset = current_plane_offset
	current_plane_offset = new_offset

	SEND_SIGNAL(src, COMSIG_HUD_OFFSET_CHANGED, old_offset, new_offset)
	if(should_use_scale())
		for(var/group_key as anything in master_groups)
			var/datum/plane_master_group/group = master_groups[group_key]
			group.transform_lower_turfs(src, new_offset)

/datum/hud/Destroy()
	if(mymob.hud_used == src)
		mymob.hud_used = null

	QDEL_NULL(hide_actions_toggle)

	QDEL_NULL(module_store_icon)

	QDEL_LIST(static_inventory)

	inv_slots.Cut()
	action_intent = null
	zone_select = null
	move_intent = null
	hand_slots.Cut()

	QDEL_LIST(toggleable_inventory)

	QDEL_LIST(hotkeybuttons)

	QDEL_LIST(infodisplay)

	//clear mob refs to screen objects
	mymob.throw_icon = null
	mymob.healths = null
	mymob.healthdoll = null
	mymob.pullin = null
	mymob.stamina_bar = null

	//clear the rest of our reload_fullscreen
	lingchemdisplay = null
	lingstingdisplay = null
	blobpwrdisplay = null
	alien_plasma_display = null
	vampire_blood_display = null
	ninja_energy_display = null
	ninja_focus_display = null
	wind_up_timer = null
	nightvisionicon = null
	devilsouldisplay = null

	QDEL_LIST_ASSOC_VAL(master_groups)
	QDEL_LIST_ASSOC_VAL(plane_master_controllers)

	mymob = null
	return ..()

/datum/hud/proc/on_plane_increase(datum/source, old_max_offset, new_max_offset)
	SIGNAL_HANDLER
	build_plane_groups(old_max_offset + 1, new_max_offset)

/// Creates the required plane masters to fill out new z layers (because each "level" of multiz gets its own plane master set)
/datum/hud/proc/build_plane_groups(starting_offset, ending_offset)
	for(var/group_key in master_groups)
		var/datum/plane_master_group/group = master_groups[group_key]
		group.build_plane_masters(starting_offset, ending_offset)

/// Returns the plane master that matches the input plane from the passed in group
/datum/hud/proc/get_plane_master(plane, group_key = PLANE_GROUP_MAIN)
	var/plane_key = "[plane]"
	var/datum/plane_master_group/group = master_groups[group_key]
	return group.plane_masters[plane_key]

/// Returns a list of all plane masters that match the input true plane, drawn from the passed in group (ignores z layer offsets)
/datum/hud/proc/get_true_plane_masters(true_plane, group_key = PLANE_GROUP_MAIN)
	var/list/atom/movable/screen/plane_master/masters = list()
	for(var/plane in TRUE_PLANE_TO_OFFSETS(true_plane))
		masters += get_plane_master(plane, group_key)
	return masters

/// Returns all the planes belonging to the passed in group key
/datum/hud/proc/get_planes_from(group_key)
	var/datum/plane_master_group/group = master_groups[group_key]
	return group.plane_masters

/// Returns the corresponding plane group datum if one exists
/datum/hud/proc/get_plane_group(key)
	return master_groups[key]

/mob/proc/create_mob_hud()
	if(!client || hud_used)
		return
	hud_used = new /datum/hud(src)
	update_sight()
	SEND_SIGNAL(src, COMSIG_MOB_HUD_CREATED)

/datum/hud/proc/show_hud(version = 0)
	if(!ismob(mymob))
		return FALSE

	if(!mymob.client)
		return FALSE

	mymob.client.screen = list()

	var/display_hud_version = version
	if(!display_hud_version)	//If 0 or blank, display the next hud version
		display_hud_version = hud_version + 1
	if(display_hud_version > HUD_VERSIONS)	//If the requested version number is greater than the available versions, reset back to the first version
		display_hud_version = 1

	switch(display_hud_version)
		if(HUD_STYLE_STANDARD)	//Default HUD
			hud_shown = TRUE	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen += static_inventory
			if(toggleable_inventory.len && inventory_shown)
				mymob.client.screen += toggleable_inventory
			if(hotkeybuttons.len && !hotkey_ui_hidden)
				mymob.client.screen += hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

			mymob.client.screen += hide_actions_toggle

			if(action_intent)
				action_intent.screen_loc = initial(action_intent.screen_loc) //Restore intent selection to the original position
			. = TRUE

		if(HUD_STYLE_REDUCED)	//Reduced HUD
			hud_shown = FALSE	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen += infodisplay

			//These ones are a part of 'static_inventory', 'toggleable_inventory' or 'hotkeybuttons' but we want them to stay
			for(var/atom/movable/screen/inventory/hand/hand_box as anything in hand_slots)
				mymob.client.screen += hand_box	//we want the hands to be visible
			if(action_intent)
				mymob.client.screen += action_intent		//we want the intent switcher visible
				action_intent.screen_loc = ui_acti_alt	//move this to the alternative position, where zone_select usually is.
			. = FALSE

		if(HUD_STYLE_NOHUD)	//No HUD
			hud_shown = FALSE	//Governs behavior of other procs
			if(static_inventory.len)
				mymob.client.screen -= static_inventory
			if(toggleable_inventory.len)
				mymob.client.screen -= toggleable_inventory
			if(hotkeybuttons.len)
				mymob.client.screen -= hotkeybuttons
			if(infodisplay.len)
				mymob.client.screen -= infodisplay
			. = FALSE

	hud_version = display_hud_version
	persistent_inventory_update()
	mymob.update_action_buttons(1)
	reorganize_alerts()
	reload_fullscreen()
	update_parallax_pref()
	plane_masters_update()

	SEND_SIGNAL(mymob, COMSIG_MOB_HUD_REFRESHED, src)
	return TRUE


/datum/hud/proc/plane_masters_update()
	for(var/group_key in master_groups)
		var/datum/plane_master_group/group = master_groups[group_key]
		// Plane masters are always shown to OUR mob, never to observers
		group.refresh_hud()


/datum/hud/human/show_hud(version = 0)
	. = ..()
	if(!.)
		return
	hidden_inventory_update()


/datum/hud/robot/show_hud(version = 0)
	. = ..()
	if(!.)
		return
	update_robot_modules_display()


/datum/hud/proc/hidden_inventory_update()
	return


/datum/hud/proc/persistent_inventory_update()
	return


//Triggered when F12 is pressed (Unless someone changed something in the DMF)
/mob/verb/button_pressed_F12()
	set name = "F12"
	set hidden = TRUE

	if(hud_used && client)
		hud_used.show_hud() //Shows the next hud preset
		to_chat(usr, "<span class ='info'>Switched HUD mode. Press F12 to toggle.</span>")
	else
		to_chat(usr, "<span class ='warning'>This mob type does not use a HUD.</span>")


/datum/hud/proc/update_locked_slots()
	return


/mob/proc/remake_hud() //used for preference changes mid-round; can't change hud icons without remaking the hud.
	QDEL_NULL(hud_used)
	create_mob_hud()
	update_action_buttons_icon()
	if(hud_used)
		hud_used.show_hud(hud_used.hud_version)

