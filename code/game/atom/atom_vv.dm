/atom/vv_get_dropdown()
	. = ..()
	VV_DROPDOWN_OPTION("", "--- /atom ---")
	if(!ismovable(src))
		var/turf/current_turf = get_turf(src)
		if(current_turf)
			. += "<a href='byond://?_src_=holder;adminplayerobservecoodjump=1;X=[current_turf.x];Y=[current_turf.y];Z=[current_turf.z]' style='display:none;'>Jump To</a>"
	VV_DROPDOWN_OPTION(VV_HK_SPIN_ANIMATION, "SpinAnimation")
	VV_DROPDOWN_OPTION(VV_HK_STOP_ALL_ANIMATIONS, "Stop All Animations")
	VV_DROPDOWN_OPTION(VV_HK_ATOM_SAY, "Atom Say")
	VV_DROPDOWN_OPTION(VV_HK_ADD_REAGENT, "Add Reagent")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EMP, "EMP Pulse")
	VV_DROPDOWN_OPTION(VV_HK_TRIGGER_EXPLOSION, "Explosion")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_REAGENTS, "Edit Reagents")
	VV_DROPDOWN_OPTION(VV_HK_TEST_MATRIXES, "Test Matrices")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_FILTERS, "Edit Filters")
	VV_DROPDOWN_OPTION(VV_HK_EDIT_COLOR_MATRIX, "Edit Color as Matrix")
	if(greyscale_colors)
		VV_DROPDOWN_OPTION(VV_HK_MODIFY_GREYSCALE, "Modify greyscale colors")

/atom/vv_do_topic(list/href_list)
	. = ..()

	if(!.)
		return

	if(href_list[VV_HK_ADD_REAGENT]) /* Made on /TG/, credit to them. */
		if(!check_rights(R_DEBUG|R_ADMIN))
			return
		usr.client?.try_add_reagent(src)

	if(href_list[VV_HK_EDIT_REAGENTS])
		if(!check_rights(R_DEBUG|R_ADMIN))
			return
		usr.client?.try_open_reagent_editor(src)

	if(href_list[VV_HK_TRIGGER_EXPLOSION])
		return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/admin_explosion, src)

	if(href_list[VV_HK_TRIGGER_EMP])
		return SSadmin_verbs.dynamic_invoke_verb(usr, /datum/admin_verb/admin_emp, src)

	if(href_list[VV_HK_ATOM_SAY])
		if(!check_rights(R_EVENT))
			return
		var/say_text = tgui_input_text(usr, "Введите текст, который будет озвучен объектом", "Введите текст", multiline = TRUE, encode = FALSE)
		atom_say(say_text)
		log_and_message_admins("atom_said on behalf of [src] the following: [say_text].")

	if(href_list[VV_HK_SPIN_ANIMATION])
		var/num_spins = tgui_alert(usr, "Do you want infinite spins?", "Spin Animation", list("Yes", "No"))
		if(num_spins == "No")
			num_spins = tgui_input_number(usr, "How many spins?", "Spin Animation")
		else if(num_spins == "Yes")
			num_spins = -1
		else
			return
		if(!num_spins)
			return
		var/spins_per_sec = tgui_input_number(usr, "How many spins per second?", "Spin Animation", round_value = FALSE)
		if(!spins_per_sec)
			return
		var/direction = tgui_alert(usr, "Which direction?", "Spin Animation", list("Clockwise", "Counter-clockwise"))
		switch(direction)
			if("Clockwise")
				direction = 1
			if("Counter-clockwise")
				direction = 0
			else
				return
		SpinAnimation(1 SECONDS / spins_per_sec, num_spins, direction)

	if(href_list[VV_HK_STOP_ALL_ANIMATIONS])
		var/result = tgui_alert(usr, "Are you sure?", "Stop Animating", list("Yes", "No"))
		if(result == "Yes")
			animate(src, transform = null, flags = ANIMATION_END_NOW)
		return

	if(href_list[VV_HK_AUTO_RENAME])
		var/new_name = tgui_input_text(usr, "What do you want to rename this to?", "Automatic Rename")
		// Check the new name against the chat filter. If it triggers the IC chat filter, give an option to confirm.
		if(new_name && (tgui_alert(usr, "Your selected name contains words restricted by IC chat filters. Confirm this new name?", "IC Chat Filter Conflict", list("Confirm", "Cancel")) != "Confirm"))
			vv_auto_rename(new_name)

	if(href_list[VV_HK_EDIT_FILTERS])
		usr.client?.open_filter_editor(src)

	if(href_list[VV_HK_EDIT_COLOR_MATRIX])
		usr.client?.open_color_matrix_editor(src)

	if(href_list[VV_HK_TEST_MATRIXES])
		usr.client?.open_matrix_tester(src)

/atom/vv_get_header()
	. = ..()
	var/refid = UID_of(src)
	. += "[VV_HREF_TARGETREF(refid, VV_HK_AUTO_RENAME, "<b id='name'>[src]</b>")]"
	. += "<br><font size='1'><a href='byond://?_src_=vars;rotatedatum=[refid];rotatedir=left'><<</a> <a href='byond://?_src_=vars;datumedit=[refid];varnameedit=dir' id='dir'>[dir2text(dir) || dir]</a> <a href='byond://?_src_=vars;rotatedatum=[refid];rotatedir=right'>>></a></font>"

/**
 * call back when a var is edited on this atom
 *
 * Can be used to implement special handling of vars
 *
 * At the atom level, if you edit a var named "color" it will add the atom colour with
 * admin level priority to the atom colours list
 *
 * Also, if GLOB.debugging_enabled is FALSE, it sets the [ADMIN_SPAWNED_1] flag on [flags_1][/atom/var/flags_1], which signifies
 * the object has been admin edited
 */
/atom/vv_edit_var(var_name, var_value)
	var/old_light_flags = light_flags
	switch(var_name)
		if(NAMEOF(src, light_range))
			if(light_system == STATIC_LIGHT)
				set_light(l_range = var_value)
			else
				set_light_range(var_value)
			. = TRUE

		if(NAMEOF(src, light_power))
			if(light_system == STATIC_LIGHT)
				set_light(l_power = var_value)
			else
				set_light_power(var_value)
			. = TRUE

		if(NAMEOF(src, light_color))
			if(light_system == STATIC_LIGHT)
				set_light(l_color = var_value)
			else
				set_light_color(var_value)
			. = TRUE

		if(NAMEOF(src, light_on))
			if(light_system == STATIC_LIGHT)
				set_light(l_on = var_value)
			else
				set_light_on(var_value)
			. = TRUE

		if(NAMEOF(src, light_flags))
			set_light_flags(var_value)
			// I'm sorry
			old_light_flags = var_value
			. = TRUE

		if(NAMEOF(src, opacity))
			set_opacity(var_value)
			. = TRUE

		if(NAMEOF(src, density))
			set_density(var_value)
			. = TRUE

		if(NAMEOF(src, base_pixel_x))
			set_base_pixel_x(var_value)
			. = TRUE

		if(NAMEOF(src, base_pixel_y))
			set_base_pixel_y(var_value)
			. = TRUE

	light_flags = old_light_flags
	if(!isnull(.))
		datum_flags |= DF_VAR_EDITED
		return .

	if(!GLOB.debugging_enabled)
		flags |= ADMIN_SPAWNED

	. = ..()

	switch(var_name)
		if(NAMEOF(src, color))
			add_atom_colour(color, ADMIN_COLOUR_PRIORITY)
			update_appearance()

/atom/proc/vv_auto_rename(new_name)
	name = new_name
