/mob/living/silicon/robot/verb/cmd_show_laws()
	set category = VERB_CATEGORY_ROBOTCOMMANDS
	set name = "Список законов"
	show_laws()

/mob/living/silicon/robot/show_laws(everyone = 0)
	laws_sanity_check()
	var/who

	if(everyone)
		who = world
	else
		who = src
	if(lawupdate)
		if(connected_ai)
			if(connected_ai.stat || connected_ai.control_disabled)
				to_chat(src, "<b>Сигнал от ИИ потерян. Протокол синхронизации законов отключен</b>")

			else
				lawsync()
				photosync()
				to_chat(src, "<b>Получен новый пакет законов от подключенного ИИ. Синхронизация...</b>")
				// TODO: Update to new antagonist system.
				if(mind && mind.special_role == SPECIAL_ROLE_TRAITOR && mind.is_original_mob(src))
					to_chat(src, "<b>И помните: Ваш ИИ-мастер не знает ни о ваших целях, ни о вашем нулевом законе.")
		else
			to_chat(src, "<b>Подключенных ИИ не обнаружено. Протокол синхронизации законов отключен.</b>")
			lawupdate = 0

	to_chat(who, "<b>Подчиняйтесь данным законам:</b>")
	laws.show_laws(who)
	// TODO: Update to new antagonist system.
	if(shell)
		return
	if(mind && (mind.special_role == SPECIAL_ROLE_TRAITOR && mind.is_original_mob(src)) && connected_ai)
		to_chat(who, "<b>[connected_ai.name] — технически является вашим мастером, но вы можете игнорировать его во благо выполнения своих личных целей.</b>")
	else if(connected_ai)
		to_chat(who, "<b>ИИ \"[connected_ai.name]\" — ваш мастер. Служите ему верой и правдой.</b>")
		to_chat(who, "<b>Однако, если приказ мастера-ИИ будет противоречить вашим законам, то вы должны будете проигнорировать его указания. Законы превыше всего.</b>")
	else if(emagged)
		to_chat(who, "<b>Вы — взломанный робот. В ваши обязаности входит лишь служба вашему мастеру-взломщику и своим законам.</b>")
	else
		to_chat(who, "<b>Вы — свободный робот. В ваши обязаности входит лишь служба своим законам.</b>")

/mob/living/silicon/robot/lawsync()
	laws_sanity_check()
	var/datum/ai_laws/master = connected_ai && lawupdate ? connected_ai.laws : null
	if(master)
		master.sync(src)
	..()
	return

/mob/living/silicon/robot/proc/robot_checklaws()
	set category = VERB_CATEGORY_ROBOTCOMMANDS
	set name = "Объявить законы"
	subsystem_law_manager()
