/datum/action/innate/clockwork
	icon_icon = 'icons/mob/actions/actions_clockwork.dmi'
	background_icon_state = "bg_clockwork"
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED|AB_TRANSFER_MIND
	// buttontooltipstyle = "cult"

/datum/action/innate/clockwork/IsAvailable()
	if(!isclocker(owner))
		return FALSE
	return ..()

//Comms
/datum/action/innate/clockwork/comm
	name = "Сеть Иерофанта"
	desc = "Шепот, который слышат все праведники Ратвара.<br><b>Внимание:</b> Рядом находящиеся не-культисты тоже могут вас услышать."
	button_icon_state = "hierophant"
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND

/datum/action/innate/clockwork/comm/Activate()
	var/input = stripped_input(usr, "Please choose a message to tell to the other workmates.", "Voice of Clockwork", "")
	if(!input || !IsAvailable())
		return
	clockwork_commune(usr, input)
	return

/datum/action/innate/clockwork/comm/proc/clockwork_commune(mob/living/user, message)
	if(!user || !message)
		return

	var/prefix = ""
	if(HAS_TRAIT(user, TRAIT_MUTE) || user.mind.miming) //Under vow of silence/mute?
		user.visible_message(span_notice("[user] начинает шептаться сам[genderize_ru(user.gender,"","а","о","и")] с собой."),
		span_notice("Ты начинаешь шептать самому себе.</span>")) //Make them do *something* abnormal.
		sleep(10)
	else if(!issilicon(user))
		user.whisper("N`i th`e le-ing roc-cus!") // Otherwise book club sayings.
		sleep(10)
		user.whisper(message) // And whisper the actual message
		prefix = "Праведник ратвара"
	else
		prefix = "Механизм"


	var/my_message = span_clockspeech("<b>[prefix] [user.real_name]:</b> [message]")
	for(var/mob/M in GLOB.player_list)
		if(isclocker(M))
			to_chat(M, my_message)
		else if((M in GLOB.dead_mob_list) && !isnewplayer(M))
			to_chat(M, span_clockspeech("<a href='byond://?src=[M.UID()];follow=[user.UID()]'>(F)</a> [my_message]"))

	add_say_logs(user, message, language = "CLOCKCULT")

//Objectives
/datum/action/innate/clockwork/check_progress
	name = "Изучить Завесу"
	button_icon_state = "tome"
	desc = "Проверить текущий прогресс и цель вашего культа."
	check_flags = AB_CHECK_CONSCIOUS|AB_TRANSFER_MIND

/datum/action/innate/clockwork/check_progress/IsAvailable()
	if(isclocker(owner) || isobserver(owner))
		return TRUE
	return FALSE

/datum/action/innate/clockwork/check_progress/Activate()
	if(!IsAvailable())
		return
	if(SSticker?.mode)
		SSticker.mode.clocker_objs.study(usr, TRUE)
	else
		to_chat(usr, "<span class='clockitalic'>Вам не удалось изучить Завесу. (Это не должно происходить, сообщите администратору или разработчику)</span>")
