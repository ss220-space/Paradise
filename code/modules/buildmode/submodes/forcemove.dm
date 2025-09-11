// This tool calls forceMove() on an object/mob that is selected with right-click.
// Once the atom is moved, its selection is cleared to avoid any further moves by accident.
/datum/buildmode_mode/forcemove
	key = "forcemove"
	var/atom/movable/selected_atom		// The atom we want to move
	var/image/selected_overlay			// Overlay for the selected atom only visible for the build mode user

/datum/buildmode_mode/forcemove/show_help(mob/user)
	to_chat(user, span_purple(chat_box_examine(
		"[span_bold("Выбрать точку назначения")] -> ЛКМ на obj/mob\n\
		[span_bold("Выбрать атом для перемещения")] -> ПКМ на obj/mob\n\
		\n\
		Сначала вам нужно выбрать атом, который может быть перемещён, а затем щёлкнуть левой кнопкой мыши по месту назначения."))
	)

/datum/buildmode_mode/forcemove/handle_click(mob/user, params, atom/A)
	var/list/modifiers = params2list(params)

	var/left_click = LAZYACCESS(modifiers, LEFT_CLICK)
	var/right_click = LAZYACCESS(modifiers, RIGHT_CLICK)

	// Selecting the atom to move
	if(right_click)
		if(!ismovable(A) || iseffect(A))
			to_chat(user, span_danger("Вы не можете перемещать эффекты, турфы и зоны."))
			return

		// If we had something previously selected, handle its signal and overlay
		if(selected_atom)
			UnregisterSignal(selected_atom, COMSIG_QDELETING)

		if(selected_overlay)
			remove_selected_overlay(user)

		// We ensure it properly gets GC'd
		selected_atom = A
		RegisterSignal(selected_atom, COMSIG_QDELETING, PROC_REF(on_selected_atom_deleted))

		// Green overlay for selection
		selected_overlay = image(icon = selected_atom.icon, loc = A, icon_state = selected_atom.icon_state)
		selected_overlay.color = "#15d12d"
		user.client.images += selected_overlay

		to_chat(user, span_notice("'[capitalize(selected_atom.declent_ru(NOMINATIVE))]' [genderize_ru(selected_atom.gender, "выбран", "выбрана", "выбрано", "выбраны")] для перемещения."))
		return

	// Selecting the destination to move to
	if(!left_click)
		return

	var/atom/destination = A

	if(!selected_atom)
		to_chat(user, span_danger("Выберите атом для перемещения (ПКМ)."))
		return

	// Block these as they can only lead to issues
	if(iseffect(destination) || isobserver(destination))
		to_chat(user, span_danger("Нельзя перемещать атомы в эффекты или в призраков."))
		return

	selected_atom.forceMove(destination)

	to_chat(user, span_notice("'[capitalize(selected_atom.declent_ru(NOMINATIVE))]' [genderize_ru(selected_atom.gender, "перемещён", "перемещена", "перемещено", "перемещены")] '[destination.declent_ru(ACCUSATIVE)]'."))
	log_admin("Build Mode: [key_name(user)] forcemoved [selected_atom] to [destination] at ([destination.x],[destination.y],[destination.z]).")

	UnregisterSignal(selected_atom, COMSIG_QDELETING)
	selected_atom = null
	remove_selected_overlay(user)

// Remove the green selection (only visible for the user)
/datum/buildmode_mode/forcemove/proc/remove_selected_overlay(mob/user)
	user.client.images -= selected_overlay
	selected_overlay = null

// If it gets deleted mid-movement, remove the overlay and its attachment to the forcemove tool
/datum/buildmode_mode/forcemove/proc/on_selected_atom_deleted()
	SIGNAL_HANDLER
	UnregisterSignal(selected_atom, COMSIG_QDELETING)
	selected_atom = null
