GLOBAL_VAR(create_turf_html)
/datum/admins/proc/create_turf(var/mob/user)
	if(!GLOB.create_turf_html)
		var/turfjs = null
		turfjs = jointext(typesof(/turf), ";")
		GLOB.create_turf_html = file2text('html/create_object.html')
		GLOB.create_turf_html = replacetext(GLOB.create_turf_html, "null /* object types */", "\"[turfjs]\"")
		GLOB.create_turf_html = replacetext(GLOB.create_turf_html, "Create Object", "Create Turf")

	var/datum/browser/popup = new(user, "create_turf", "<div align='center'>Create Turf</div>", 550, 600)
	var/unique_content = GLOB.create_turf_html
	unique_content = replacetext(unique_content, "/* ref src */", UID())
	popup.set_content(unique_content)
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=1;can_resize=1")
	popup.add_stylesheet("dark_inputs", "html/dark_inputs.css")
	popup.open()
	onclose(user, "create_turf")
