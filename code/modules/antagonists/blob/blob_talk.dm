/datum/action/innate/blob
	icon_icon = 'icons/mob/actions/actions.dmi'
	background_icon_state = "bg_default_on"

/datum/action/innate/blob/comm
	name = "Blob Telepathy"
	desc = "Телепатически отправляет сообщение всем блобам, иблобернаутам и зараженным блобом"
	button_icon_state = "alien_whisper"
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND

/datum/action/innate/blob/comm/Activate()
	var/input = stripped_input(usr, "Выберите сообщение для отправки другому блобу.", "Blob Telepathy", "")
	if(!input || !IsAvailable())
		return
	blob_talk(usr, input)
	return

/proc/blob_talk(mob/living/user, message)
	add_say_logs(user, message, language = "BLOB")

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	var/rendered = "<i><span class='blob'>Blob Telepathy,</span> <span class='name'>[user.name]</span> states, <span class='blob'>\"[message]\"</span></i>"

	for(var/mob/M in GLOB.mob_list)
		if(isovermind(M) || isobserver(M) || isblobbernaut(M) || isblobinfected(M.mind))
			M.show_message(rendered, 2)
