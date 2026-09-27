/datum/antagonist/obsessed
	name = "Obsessed"
	job_rank = ROLE_OBSESSED
	special_role = SPECIAL_ROLE_OBSESSED
	replace_banned = FALSE
	antag_menu_name = "Одержимый"
	roundend_category = "одержимые"
	give_objectives = FALSE
	var/objectives_to_generate = 3
	var/datum/mind/obsession
	var/datum/brain_trauma/special/obsessed/trauma

/datum/antagonist/obsessed/Destroy(force)
	trauma = null
	obsession = null
	return ..()

/datum/antagonist/obsessed/greet()
	var/list/messages = list()
	messages.Add(span_userdanger("Вы одержимы [obsession.current.declent_ru(INSTRUMENTAL)]!"))
	messages.Add(span_danger("Голос в вашей голове требует, чтобы вы не отходили от предмета своей одержимости, а под конец — чтобы он достался только вам."))
	return messages

/datum/antagonist/obsessed/on_gain()
	forge_objectives()
	return ..()

/datum/antagonist/obsessed/proc/forge_objectives()
	if(!obsession)
		return

	var/list/objective_pool = list(/datum/objective/spendtime, /datum/objective/polaroid, /datum/objective/hug)
	if(obsession.assigned_role != JOB_TITLE_CAPTAIN)
		objective_pool += /datum/objective/assassinate/jealous

	for(var/index in 1 to objectives_to_generate)
		add_creepy_objective(pick_n_take(objective_pool))

	add_creepy_objective(/datum/objective/assassinate/obsessed)

	for(var/datum/objective/objective as anything in objectives)
		objective.update_explanation_text()

/datum/antagonist/obsessed/proc/add_creepy_objective(objective_type)
	var/datum/objective/objective = new objective_type
	objective.owner = owner
	objective.target = obsession
	objectives += objective

/datum/antagonist/obsessed/roundend_report_header()
	return span_header("Одержимыми были:<br>")

/datum/antagonist/obsessed/roundend_report()
	var/list/report = list()
	report += printplayer(owner)

	var/objectives_complete = TRUE
	var/count = 1
	for(var/datum/objective/objective as anything in objectives)
		if(objective.check_completion())
			report += "<b>Цель #[count]</b>: [objective.explanation_text] [span_greentext("Успех!")]"
		else
			objectives_complete = FALSE
			report += "<b>Цель #[count]</b>: [objective.explanation_text] [span_redtext("Провал.")]"
		count++

	if(trauma?.total_time_creeping)
		report += span_greentext("[name] провёл рядом с [obsession.current.declent_ru(INSTRUMENTAL)] в общей сложности [DisplayTimeText(trauma.total_time_creeping)]!")
	else
		report += span_redtext("[name] за весь раунд так и не подошёл к предмету своей одержимости!")

	if(objectives_complete)
		report += span_greentext("<big>Одержимый победил!</big>")
	else
		report += span_redtext("<big>Одержимый провалился!</big>")

	return report.Join("<br>")

/datum/antagonist/former_obsessed
	name = "Former Obsessed"
	special_role = SPECIAL_ROLE_OBSESSED
	antag_menu_name = "Бывший одержимый"
	show_in_roundend = FALSE
	silent = TRUE
	give_objectives = FALSE

/datum/objective/assassinate/obsessed
	name = "obsessed assassinate"
	antag_menu_name = "Убить предмет одержимости"

/datum/objective/assassinate/obsessed/update_explanation_text()
	if(!target?.current)
		explanation_text = "Свободная цель"
		return
	explanation_text = "Убейте [target.current.real_name], [target.assigned_role]. Никто больше не должен получить [target.current.declent_ru(GENITIVE)]."

/datum/objective/assassinate/jealous
	name = "jealous assassinate"
	antag_menu_name = "Убить коллегу"
	var/datum/mind/envied

/datum/objective/assassinate/jealous/update_explanation_text()
	envied = target
	target = find_coworker(envied)
	if(!target?.current)
		explanation_text = "Свободная цель"
		return
	explanation_text = "Убейте [target.current.real_name], коллегу [envied.current.declent_ru(GENITIVE)]."

/datum/objective/assassinate/jealous/proc/find_coworker(datum/mind/envied_mind)
	var/list/all_coworkers = list()
	var/list/viable_coworkers = list()
	var/list/department = get_department(envied_mind.assigned_role)

	for(var/mob/living/carbon/human/coworker in GLOB.alive_mob_list)
		if(!coworker.mind || coworker.mind == envied_mind || !coworker.mind.assigned_role)
			continue
		if(coworker.mind.offstation_role || coworker.mind.has_antag_datum(/datum/antagonist/obsessed))
			continue
		all_coworkers += coworker.mind
		if(coworker.mind.assigned_role in department)
			viable_coworkers += coworker.mind

	if(length(viable_coworkers))
		return pick(viable_coworkers)
	if(length(all_coworkers))
		return pick(all_coworkers)

/datum/objective/assassinate/jealous/proc/get_department(job_title)
	for(var/list/department as anything in list(GLOB.command_positions, GLOB.engineering_positions, GLOB.medical_positions, GLOB.science_positions, GLOB.security_positions, GLOB.support_positions, GLOB.supply_positions, GLOB.civilian_positions))
		if(job_title in department)
			return department
	return list()

/datum/objective/spendtime
	name = "spendtime"
	antag_menu_name = "Побыть рядом"
	var/timer = 5 MINUTES

/datum/objective/spendtime/update_explanation_text()
	if(!target?.current)
		explanation_text = "Свободная цель"
		return

	var/datum/antagonist/obsessed/creeper = owner.has_antag_datum(/datum/antagonist/obsessed)
	creeper?.trauma?.creeping_objective = src
	explanation_text = "Проведите [DisplayTimeText(timer)] рядом с [target.current.declent_ru(INSTRUMENTAL)], пока [GEND_HE_SHE(target.current)] жив[GEND_A_O_Y(target.current)]."

/datum/objective/spendtime/check_completion()
	return timer <= 0

/datum/objective/hug
	name = "hugs"
	antag_menu_name = "Обнять"
	var/hugs_needed

/datum/objective/hug/update_explanation_text()
	if(!hugs_needed)
		hugs_needed = rand(4, 6)

	if(!target?.current)
		explanation_text = "Свободная цель"
		return
	explanation_text = "Обнимите [target.current.declent_ru(ACCUSATIVE)] [hugs_needed] раз, пока [GEND_HE_SHE(target.current)] жив[GEND_A_O_Y(target.current)]."

/datum/objective/hug/check_completion()
	var/datum/antagonist/obsessed/creeper = owner.has_antag_datum(/datum/antagonist/obsessed)
	if(!creeper?.trauma)
		return FALSE
	return creeper.trauma.obsession_hug_count >= hugs_needed

/datum/objective/polaroid
	name = "polaroid"
	antag_menu_name = "Сфотографировать"

/datum/objective/polaroid/update_explanation_text()
	if(!target?.current)
		explanation_text = "Свободная цель"
		return
	explanation_text = "Сфотографируйте [target.current.declent_ru(ACCUSATIVE)], пока [GEND_HE_SHE(target.current)] жив[GEND_A_O_Y(target.current)], и сохраните снимок при себе."

/datum/objective/polaroid/check_completion()
	var/target_uid = target?.current?.UID()
	if(!target_uid)
		return FALSE

	for(var/datum/mind/creeper as anything in get_owners())
		if(!isliving(creeper.current))
			continue
		for(var/obj/item/photo/picture in creeper.current.get_all_contents())
			if(target_uid in picture.mobs_seen)
				return TRUE
	return FALSE
