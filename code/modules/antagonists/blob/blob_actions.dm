/datum/action/innate/blob
	icon_icon = 'icons/mob/actions/actions.dmi'
	background_icon_state = "bg_default_on"

/datum/action/innate/blob/comm
	name = "Телепатия блоба"
	desc = "Телепатически отправляет сообщение всем блобам, миньенам блоба и зараженным блобом организмам"
	button_icon_state = "alien_whisper"
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND

/datum/action/innate/blob/comm/Activate()
	var/input = tgui_input_text(usr, "Выберите сообщение для отправки другим блобам.", "Телепатия Блоба", "")
	if(!input || !IsAvailable())
		return
	blob_talk(input)
	return

/datum/action/innate/blob/comm/proc/blob_talk(message)

	message = trim(copytext(sanitize(message), 1, MAX_MESSAGE_LEN))

	if(!message)
		return

	add_say_logs(usr, message, language = "BLOB")
	var/rendered = span_blob("<b>\[Blob Telepathy\] <span class='name'>[usr.name]</span> states, [message]")
	relay_to_list_and_observers(rendered, GLOB.blob_telepathy_mobs, usr)

/datum/action/innate/blob/self_burst
	icon_icon = 'icons/hud/blob.dmi'
	button_icon = 'icons/hud/blob.dmi'
	background_icon_state = "block"
	button_icon_state = "ui_tocore"
	name = "Лопнуть носителя"
	desc = "Позволяет лопнуть носителя и превратиться в блоба досрочно."
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND

/datum/action/innate/blob/self_burst/Activate()
	var/input = tgui_alert(usr,"Вы действительно хотите лопнуть себя и превратиться в блоба досрочно? Это действие необратимо.", "", list("Да", "Нет")) == "Да"
	if(!input || !IsAvailable())
		return
	var/datum/antagonist/blob_infected/blob = usr?.mind?.has_antag_datum(/datum/antagonist/blob_infected)
	if(!blob)
		return
	blob.burst_blob()
	return

/datum/action/innate/blob/minion_talk
	background_icon_state = "bg_default"
	button_icon_state = "talk_around"
	name = "Сказать окружающим"
	desc = "Вы скажете введенный текст окружающим вас мобам"
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND

/datum/action/innate/blob/minion_talk/Activate()

	var/speak_text = tgui_input_text(usr, "Что вы хотите сказать?", "Сказать окружающим", null)

	if(!speak_text)
		return

	add_say_logs(usr, speak_text, language = "BLOB mob_say")
	usr.atom_say(speak_text)
