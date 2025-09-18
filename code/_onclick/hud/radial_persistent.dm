/// Can be provided to choices in radial menus if you want to provide more information
/datum/radial_menu_choice
	/// Required -- what to display for this button
	var/image

	/// If provided, this will be the name the radial slice hud button. This has priority over everything else.
	var/name

	/// If provided, will display an info button that will put this text in your chat
	var/info

/datum/radial_menu_choice/Destroy(force)
	. = ..()
	QDEL_NULL(image)


/*
	A derivative of radial menu which persists onscreen until closed and invokes a callback each time an element is clicked
*/

/atom/movable/screen/radial/persistent/center
	name = "Close Menu"
	icon_state = "radial_center"

/atom/movable/screen/radial/persistent/center/Click(location, control, params)
	if(usr.client == parent.current_user)
		parent.element_chosen(null, usr, params)

/atom/movable/screen/radial/persistent/center/MouseEntered(location, control, params)
	. = ..()
	icon_state = "radial_center_focus"

/atom/movable/screen/radial/persistent/center/MouseExited(location, control, params)
	. = ..()
	icon_state = "radial_center"


/datum/radial_menu/persistent
	var/uniqueid
	var/datum/callback/select_proc_callback


/datum/radial_menu/persistent/New()
	close_button = new /atom/movable/screen/radial/persistent/center
	close_button.parent = src


/datum/radial_menu/persistent/element_chosen(choice_id, mob/user, params)
	select_proc_callback.Invoke(choices_values[choice_id], params)


///Version of wait used by persistent radial menus.
/datum/radial_menu/persistent/wait()
	while(!QDELETED(src))
		if(custom_check_callback && next_check < world.time)
			custom_check_callback.Invoke()
			next_check = world.time + check_delay

		stoplag(1)


/datum/radial_menu/persistent/proc/change_choices(list/newchoices, tooltips = FALSE, animate = FALSE, keep_same_page = FALSE)
	if(!newchoices.len)
		return

	//button_animation_flags = NONE
	Reset()
	set_choices(newchoices,tooltips)


/datum/radial_menu/persistent/Destroy()
	select_proc_callback = null
	GLOB.radial_menus -= uniqueid
	Reset()
	hide()
	. = ..()
