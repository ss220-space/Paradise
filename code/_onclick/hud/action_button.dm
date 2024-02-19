/obj/screen/movable/action_button
	var/datum/action/linked_action
	var/actiontooltipstyle = ""
	screen_loc = null
	var/ordered = TRUE
	var/datum/keybinding/mob/trigger_action_button/linked_keybind

/obj/screen/movable/action_button/MouseDrop(atom/over_object, src_location, over_location, src_control, over_control, params)
	if(locked && could_be_click_lag()) // in case something bad happend and game realised we dragged our ability instead of pressing it
		Click()
		drag_start = 0
		return
	drag_start = 0
	if(locked)
		to_chat(usr, span_warning("Action button \"[name]\" is locked, unlock it first."))
		closeToolTip(usr)
		return
	if((istype(over_object, /obj/screen/movable/action_button) && !istype(over_object, /obj/screen/movable/action_button/hide_toggle)))
		var/obj/screen/movable/action_button/our_button = over_object
		var/list/actions = usr.actions
		actions.Swap(actions.Find(linked_action), actions.Find(our_button.linked_action))
		moved = FALSE
		ordered = TRUE
		our_button.moved = FALSE
		our_button.ordered = TRUE
		closeToolTip(usr)
		usr.update_action_buttons()
	else if(istype(over_object, /obj/screen/movable/action_button/hide_toggle))
		closeToolTip(usr)
	else
		closeToolTip(usr)
		return ..()


/obj/screen/movable/action_button/Click(location,control,params)
	var/list/modifiers = params2list(params)
	if(modifiers["ctrl"] && modifiers["shift"])
		INVOKE_ASYNC(src, PROC_REF(set_to_keybind), usr)
		return TRUE
	if(usr.next_click > world.time)
		return FALSE
	usr.changeNext_click(1)
	if(modifiers["shift"])
		if(locked)
			to_chat(usr, span_warning("Action button \"[name]\" is locked, unlock it first."))
			return TRUE
		moved = FALSE
		usr.update_action_buttons(TRUE) //redraw buttons that are no longer considered "moved"
		return TRUE
	if(modifiers["ctrl"])
		locked = !locked
		to_chat(usr, span_notice("Action button \"[name]\" [locked ? "" : "un"]locked."))
		return TRUE
	if(modifiers["alt"])
		AltClick(usr)
		return TRUE
	if(modifiers["middle"])
		linked_action.Trigger(left_click = FALSE)
		return TRUE
	linked_action.Trigger(left_click = TRUE)
	linked_action.UpdateButtonIcon()
	transform = transform.Scale(0.8, 0.8)
	var/prev_alpha = alpha
	alpha = clamp(prev_alpha - 55, 0, 200)
	animate(src, transform = matrix(), time = 0.3 SECONDS, alpha = prev_alpha)
	return TRUE

/obj/screen/movable/action_button/proc/set_to_keybind(mob/user)
	var/keybind_to_set_to = sanitize_russian_key_to_english(input(user, "What keybind do you want to set this action button to? You can use non-single keys, but they must be in the correct case, f.e. \"Space\" or \"CtrlE\"") as text)
	if(length(keybind_to_set_to) == 1)
		keybind_to_set_to = uppertext(keybind_to_set_to)
	if(keybind_to_set_to)
		if(linked_keybind)
			clean_up_keybinds(user)
		var/datum/keybinding/mob/trigger_action_button/triggerer = new
		triggerer.linked_action = linked_action
		user.client.active_keybindings[keybind_to_set_to] += list(triggerer)
		linked_keybind = triggerer
		triggerer.binded_to = keybind_to_set_to
		to_chat(user, span_info("[src] has been binded to [keybind_to_set_to]!"))
	else if(linked_keybind)
		clean_up_keybinds(user)
		to_chat(user, span_info("Your active keybinding on [src] has been cleared."))


/obj/screen/movable/action_button/AltClick(mob/user)
	. = linked_action.AltTrigger()
	linked_action.UpdateButtonIcon()

/obj/screen/movable/action_button/proc/clean_up_keybinds(mob/owner)
	if(linked_keybind)
		owner.client.active_keybindings[linked_keybind.binded_to] -= (linked_keybind)
		if(!length(owner.client.active_keybindings[linked_keybind.binded_to]))
			owner.client.active_keybindings[linked_keybind.binded_to] = null
			owner.client.active_keybindings -= linked_keybind.binded_to
		QDEL_NULL(linked_keybind)


//Hide/Show Action Buttons ... Button
/obj/screen/movable/action_button/hide_toggle
	name = "Hide Buttons"
	desc = "Shift-click any button to reset its position, and Control-click it to lock/unlock its position. \
	<br> Alt-click this button to reset all buttons to their default positions. \
	<br> Control-Shift-click on any button to bind it to a hotkey."
	icon = 'icons/mob/actions/actions.dmi'
	icon_state = "bg_default"
	var/hidden = FALSE


/obj/screen/movable/action_button/hide_toggle/MouseDrop(over_object)
	if(istype(over_object, /obj/screen/movable/action_button))
		closeToolTip(usr)
	else
		closeToolTip(usr)
		return ..()


/obj/screen/movable/action_button/hide_toggle/Click(location,control,params)
	if(usr.next_click > world.time)
		return FALSE
	usr.changeNext_click(1)
	var/list/modifiers = params2list(params)
	if(modifiers["alt"])
		AltClick(usr)
		return TRUE

	usr.hud_used.action_buttons_hidden = !usr.hud_used.action_buttons_hidden

	hidden = usr.hud_used.action_buttons_hidden
	if(hidden)
		name = "Show Buttons"
	else
		name = "Hide Buttons"
	update_icon(UPDATE_OVERLAYS)
	usr.update_action_buttons()


/obj/screen/movable/action_button/hide_toggle/AltClick(mob/user)
	for(var/datum/action/action as anything in user.actions)
		var/obj/screen/movable/action_button/our_button = action.button
		our_button.moved = FALSE
	if(moved)
		moved = FALSE
	user.update_action_buttons(reload_screen = TRUE)
	to_chat(user, span_notice("Action button positions have been reset."))


/obj/screen/movable/action_button/hide_toggle/proc/InitialiseIcon(mob/living/user)
	if(isalien(user))
		icon = 'icons/mob/actions/actions.dmi'
		icon_state = "bg_alien"
	else
		icon = initial(icon)
		icon_state = "bg_default"
		if(user.client) // Apply the client's UI style
			icon = ui_style2icon(user.client.prefs.UI_style)
			icon_state = "template"
	if(user.client)
		alpha = user.client.prefs.UI_style_alpha
		color = user.client.prefs.UI_style_color
	update_icon(UPDATE_OVERLAYS)


/obj/screen/movable/action_button/hide_toggle/update_overlays()
	. = ..()
	var/image/img = image(initial(icon), src, hidden ? "show" : "hide")
	img.appearance_flags = RESET_COLOR|RESET_ALPHA
	. += img


/obj/screen/movable/action_button/MouseEntered(location, control, params)
	if(!QDELETED(src))
		if(!linked_keybind)
			openToolTip(usr, src, params, title = name, content = desc, theme = actiontooltipstyle)
		else
			var/list/desc_information = list()
			desc_information += desc
			desc_information += "This action is currently bound to the [linked_keybind.binded_to] key."
			desc_information = desc_information.Join(" ")
			openToolTip(usr, src, params, title = name, content = desc_information, theme = actiontooltipstyle)


/obj/screen/movable/action_button/MouseExited()
	closeToolTip(usr)


/mob/proc/update_action_buttons_icon()
	for(var/datum/action/action as anything in actions)
		action.UpdateButtonIcon()


//This is the proc used to update all the action buttons.
/mob/proc/update_action_buttons(reload_screen)
	if(!hud_used || !client)
		return

	if(hud_used.hud_shown != HUD_STYLE_STANDARD)
		return

	var/button_number = 0

	if(hud_used.action_buttons_hidden)
		for(var/datum/action/action as anything in actions)
			action.button.screen_loc = null
			if(reload_screen)
				client.screen += action.button
	else
		for(var/datum/action/action as anything in actions)
			action.override_location() // If the action has a location override, call it
			action.UpdateButtonIcon()

			var/obj/screen/movable/action_button/our_button = action.button
			if(our_button.ordered)
				button_number++
			if(!our_button.moved)
				our_button.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number)
			else
				our_button.screen_loc = our_button.moved
			if(reload_screen)
				client.screen += our_button

		if(!button_number)
			hud_used.hide_actions_toggle.screen_loc = null
			return

	if(!hud_used.hide_actions_toggle.moved)
		hud_used.hide_actions_toggle.screen_loc = hud_used.ButtonNumberToScreenCoords(button_number+1)
	else
		hud_used.hide_actions_toggle.screen_loc = hud_used.hide_actions_toggle.moved
	if(reload_screen)
		client.screen += hud_used.hide_actions_toggle


#define AB_MAX_COLUMNS 10

/datum/hud/proc/ButtonNumberToScreenCoords(number) // TODO : Make this zero-indexed for readabilty
	var/row = round((number - 1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1

	var/coord_col = "+[col-1]"
	var/coord_col_offset = 4 + 2 * col

	var/coord_row = "[row ? -row : "+0"]"

	return "WEST[coord_col]:[coord_col_offset],NORTH[coord_row]:-6"


/datum/hud/proc/SetButtonCoords(obj/screen/button,number)
	var/row = round((number-1)/AB_MAX_COLUMNS)
	var/col = ((number - 1)%(AB_MAX_COLUMNS)) + 1
	var/x_offset = 32*(col-1) + 4 + 2*col
	var/y_offset = -32*(row+1) + 26

	var/matrix/M = matrix()
	M.Translate(x_offset,y_offset)
	button.transform = M

