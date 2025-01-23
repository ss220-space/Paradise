GLOBAL_VAR(create_mob_html)
/datum/admins/proc/create_mob(var/mob/user)
	if(!GLOB.create_mob_html)
		var/mobjs = null
		mobjs = jointext(typesof(/mob), ";")
		GLOB.create_mob_html = file2text('html/create_object.html')
		GLOB.create_mob_html = replacetext(GLOB.create_mob_html, "null /* object types */", "\"[mobjs]\"")
		GLOB.create_mob_html = replacetext(GLOB.create_mob_html, "Create Object", "Create Mob")

	var/datum/browser/popup = new(user, "create_mob", "<div align='center'>Create Mob</div>", 550, 600)
	var/unique_content = GLOB.create_mob_html
	unique_content = replacetext(unique_content, "/* ref src */", UID())
	popup.set_content(unique_content)
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=1;can_resize=1")
	popup.add_stylesheet("dark_inputs", "html/dark_inputs.css")
	popup.open()
	onclose(user, "create_mob")
