/**
 * ## nobody wants to learn matrix math!
 *
 * More than just a completely true statement, this datum is created as a tgui interface
 * allowing you to modify each vector until you know what you're doing.
 * Much like filteriffic, 'nobody wants to learn matrix math' is meant for developers like you and I
 * to implement interesting matrix transformations without the hassle if needing to know... algebra? Damn, i'm stupid.
 */
/datum/transform_matrix_editor
	var/atom/target
	var/matrix/testing_matrix

/datum/transform_matrix_editor/New(atom/target)
	src.target = target
	testing_matrix = matrix(target.transform)

/datum/transform_matrix_editor/Destroy(force, ...)
	QDEL_NULL(testing_matrix)
	target = null
	return ..()

/datum/transform_matrix_editor/ui_state(mob/user)
	return GLOB.admin_state

/datum/transform_matrix_editor/ui_close(mob/user)
	qdel(src)

/datum/transform_matrix_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MatrixMathTester")
		ui.open()

/datum/transform_matrix_editor/ui_data()
	var/list/data = list()
	data["matrix_a"] = testing_matrix.a
	data["matrix_b"] = testing_matrix.b
	data["matrix_c"] = testing_matrix.c
	data["matrix_d"] = testing_matrix.d
	data["matrix_e"] = testing_matrix.e
	data["matrix_f"] = testing_matrix.f
	data["pixelated"] = target.appearance_flags & PIXEL_SCALE
	return data

/datum/transform_matrix_editor/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	if(!check_rights(R_VAREDIT))
		return

	switch(action)
		if("change_var")
			var/matrix_var_name = params["var_name"]
			var/matrix_var_value = params["var_value"]
			if(!testing_matrix.vv_edit_var(matrix_var_name, matrix_var_value))
				to_chat(src, "Ваше изменение было отклонено объектом. Это ошибка матричного тестера, а не ваша вина. Напишите об этом в баг репорты.", confidential = TRUE)
				return
			set_transform()
		if("scale")
			testing_matrix.Scale(params["x"], params["y"])
			set_transform()
		if("translate")
			testing_matrix.Translate(params["x"], params["y"])
			set_transform()
		if("shear")
			testing_matrix.Shear(params["x"], params["y"])
			set_transform()
		if("turn")
			testing_matrix.Turn(params["angle"])
			set_transform()
		if("toggle_pixel")
			target.appearance_flags ^= PIXEL_SCALE

/datum/transform_matrix_editor/proc/set_transform()
	animate(target, transform = testing_matrix, time = 0.5 SECONDS)
	testing_matrix = matrix(target.transform)

/client/proc/open_matrix_tester(atom/in_atom)
	if(holder)
		var/datum/transform_matrix_editor/matrix_tester = new(in_atom)
		matrix_tester.ui_interact(mob)
