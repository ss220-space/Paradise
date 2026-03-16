// Special AI/pAI PDAs that cannot explode.
/obj/item/pda/silicon
	detonate = 0
	ttone = "data"

/obj/item/pda/silicon/proc/set_name_and_job(newname as text, newjob as text, newrank as null|text)
	owner = newname
	ownjob = newjob
	if(newrank)
		ownrank = newrank
	else
		ownrank = ownjob

	custom_name = newname
	update_appearance(UPDATE_NAME)

//rework
/obj/item/pda/silicon/verb/cmd_send_pdamesg()
	set category = VERB_CATEGORY_AIIM
	set name = "Сообщение на КПК"
	set src in usr

	if(!can_use(usr))
		return
	var/datum/data/pda/app/old_messenger/old_messenger = find_program(/datum/data/pda/app/old_messenger)
	if(!old_messenger)
		to_chat(usr, span_warning("Cannot use old_messenger!"))
	var/list/plist = old_messenger.available_pdas()
	if(plist)
		var/c = tgui_input_list(usr, "Please select a PDA", "Send message", sortList(plist))
		if(!c) // if the user hasn't selected a PDA file we can't send a message
			return
		var/selected = plist[c]
		old_messenger.create_message(selected, usr)

/obj/item/pda/silicon/verb/cmd_show_message_log()
	set category = VERB_CATEGORY_AIIM
	set name = "Журнал сообщений"
	set src in usr

	if(!can_use(usr))
		return
	var/datum/data/pda/app/old_messenger/M = find_program(/datum/data/pda/app/old_messenger)
	if(!M)
		to_chat(usr, span_warning("Cannot use old_messenger!"))
	var/HTML = ""
	for(var/index in M.tnote)
		var/obj/item/pda/target_pda = locateUID(index["target"])
		HTML += "<i><b>[index["sent"] ? "&rarr; To" : "&larr; From"] <a href='byond://?src=[M.UID()];choice=Message;target=[index["target"]]'>[QDELETED(target_pda) ? "Error#1133: Unable to find UserName." : "[target_pda.owner] ([target_pda.ownjob])"]</a>:</b></i><br>[index["message"]]<br>"
	var/datum/browser/popup = new(usr, "log", "AI PDA Message Log", 400, 444)
	popup.set_window_options("border=1;can_resize=1;can_close=1;can_minimize=0")
	popup.set_content(HTML)
	popup.open(FALSE)

//rework
/obj/item/pda/silicon/verb/cmd_toggle_pda_receiver()
	set category = VERB_CATEGORY_AIIM
	set name = "Приём сообщений"
	set src in usr

	if(!can_use(usr))
		return
	var/datum/data/pda/app/old_messenger/M = find_program(/datum/data/pda/app/old_messenger)
	M.toff = !M.toff
	to_chat(usr, span_notice("PDA sender/receiver toggled [(M.toff ? "Off" : "On")]!"))

/obj/item/pda/silicon/verb/cmd_toggle_pda_silent()
	set category = VERB_CATEGORY_AIIM
	set name = "Беззвучный режим"
	set src in usr

	if(!can_use(usr))
		return

	silent = !silent
	to_chat(usr, span_notice("PDA ringer toggled [(silent ? "Off" : "On")]!"))

/obj/item/pda/silicon/attack_self(mob/user as mob)
	if((honkamt > 0) && (prob(60))) //For clown virus.
		honkamt--
		playsound(loc, 'sound/items/bikehorn.ogg', 30, TRUE)
	return

/obj/item/pda/silicon/ai/can_use()
	var/mob/living/silicon/ai/AI = usr
	if(!istype(AI))
		return 0
	return ..() && !AI.check_unable(AI_CHECK_WIRELESS)

/obj/item/pda/silicon/robot/can_use()
	var/mob/living/silicon/robot/R = usr
	if(!istype(R))
		return 0
	return ..() && R.cell.charge > 0

/obj/item/pda/silicon/pai
	ttone = "assist"

/obj/item/pda/silicon/pai/can_use()
	var/mob/living/silicon/pai/pAI = usr
	if(!istype(pAI))
		return FALSE
	if(!pAI.installed_software["old_messenger"])
		to_chat(usr, span_warning("You have not purchased the digital old_messenger!"))
		return FALSE
	return ..() && !pAI.silence_time
