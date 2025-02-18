/client/proc/cinematic()
	set name = "Play Cinematic"
	set category = "Admin.Event"
	set desc = "Shows a cinematic." // Intended for testing but I thought it might be nice for events on the rare occasion Feel free to comment it out if it's not wanted.

	if(!SSticker)
		return

	var/datum/cinematic/choice = tgui_input_list(usr, "Choose a cinematic to play to everyone in the server.", "Choose Cinematic", sort_list(subtypesof(/datum/cinematic), cmp = /proc/cmp_typepaths_asc))
	if(!choice || !ispath(choice, /datum/cinematic))
		return

	play_cinematic(choice, world)

