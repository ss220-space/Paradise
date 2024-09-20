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

/datum/action/innate/blob/self_burst
	icon_icon = 'icons/mob/blob.dmi'
	button_icon = 'icons/mob/blob.dmi'
	background_icon_state = "block"
	button_icon_state = "ui_tocore"
	name = "Self burst"
	desc = "Позволяет лопнуть носителя и превратиться в блоба досрочно."
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND

/datum/action/innate/blob/self_burst/Activate()
	var/input = alert(usr,"Вы действительно хотите лопнуть себя и превратиться в блоба досрочно? Это действие необратимо.", "", "Да", "Нет") == "Да"
	if(!input || !IsAvailable())
		return
	var/datum/antagonist/blob_infected/blob = usr?.mind?.has_antag_datum(/datum/antagonist/blob_infected)
	if(!blob)
		return
	blob.burst_blob()
	return

/proc/blob_talk(mob/living/user, message)
	add_say_logs(user, message, language = "BLOB")

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	var/rendered = "<i><span class='blob'>Blob Telepathy,</span> <span class='name'>[user.name]</span> states, <span class='blob'>\"[message]\"</span></i>"
	for(var/mob/M in GLOB.mob_list)
		if(isovermind(M) || isblobbernaut(M) || isblobinfected(M.mind))
			M.show_message(rendered, 2)
		else if(isobserver(M) && !isnewplayer(M))
			var/rendered_ghost = "<i><span class='blob'>Blob Telepathy,</span> <span class='name'>[user.name]</span> \
			<a href='byond://?src=[M.UID()];follow=[user.UID()]'>(F)</a> states, <span class='blob'>\"[message]\"</span></i>"
			M.show_message(rendered_ghost, 2)

