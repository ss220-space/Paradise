/obj/item/paper/agent_info
	name = "Agent information"
	info = ""
	var/content

/obj/item/paper/agent_info/proc/choose_agent(mob/user)
	. = TRUE
	var/list/crew = list()
	for (var/mob/living/carbon/human/H in GLOB.mob_list) // Also catonic/dead agents
		if(H?.mind?.assigned_role)
			crew[H?.real_name] = H

	var/choise = input(user, "О каком агенте написано в отчете?","Выбор агента", null) as null|anything in crew

	if(!choise)
		return FALSE

	var/mob/living/carbon/human/target = crew[choise]

	if(!target)
		to_chat(user, span_warning("Цель больше не существует."))
		return FALSE

	var/datum/antagonist/traitor/traitor = target?.mind?.has_antag_datum(/datum/antagonist/traitor)
	var/datum/antagonist/vampire/vampire = target?.mind?.has_antag_datum(/datum/antagonist/vampire)
	var/datum/antagonist/changeling/changeling = target?.mind?.has_antag_datum(/datum/antagonist/changeling)
	var/datum/antagonist/thief/thief = target?.mind?.has_antag_datum(/datum/antagonist/thief)

	if(!traitor && !vampire && !changeling)
		info = "Согласно последним разведданным, " + choise + " не имеет никаких прямых связей с синдикатом."
		return

	if(traitor)
		info += choise + " является агентом " + (traitor?.affiliate ? "нанятым " + traitor?.affiliate.name : "с неизвестным нанимателем") + ".<br>"
		info += "Назначеные " + (target.gender == FEMALE ? "ей " : "ему ") + "нанимателем цели следующие:"
		var/obj_num = 1
		for(var/datum/objective/objective in traitor.objectives)
			info += "<B>Objective #[obj_num]</B>: [objective.explanation_text]<br>"
			obj_num++

		var/TC_uses = 0
		var/used_uplink = FALSE
		var/purchases = ""
		for(var/obj/item/uplink/uplink in GLOB.world_uplinks)
			if(uplink?.uplink_owner && uplink.uplink_owner == target.mind.key)
				TC_uses += uplink.used_TC
				purchases += uplink.purchase_log
				used_uplink = TRUE

		if(used_uplink)
			text += " (использовал" + ((target.gender == FEMALE ? "a " : " ")) + "[TC_uses] TC) [purchases]<br>"

	if(vampire)
		info += choise + " обладает способностями " + (vampire.isAscended() ? "высшего " : "") + "вампира " + (vampire.subclass ? "подкласса \"" + vampire.subclass.name + "\"" : "без подкласса") + ".<br>"

	if(changeling)
		info += choise + " обладает способностями генокрада.<br>"

	if(thief)
		info += choise + " является членом гильдии воров.<br>"

/obj/item/paper/agent_info/examine(mob/user)
	if(!is_MI13_agent(user))
		to_chat(user, span_warning("Вы не можете разобрать содержимое."))
		return

	if(info)
		return ..()

	if(user.is_literate())
		if(in_range(user, src) || istype(user, /mob/dead/observer))
			if(choose_agent(user))
				show_content(user)
		else
			. += span_notice("Вам нужно подойти поближе, чтобы прочитать то что здесь написано.")
	else
		. += span_notice("Вы не умеете читать.")
