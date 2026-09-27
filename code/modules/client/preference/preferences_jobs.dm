#define JOB_PREF_HIGH 1
#define JOB_PREF_MEDIUM 2
#define JOB_PREF_LOW 3
#define JOB_PREF_NEVER 4

/datum/ui_module/job_preferences
	name = "Предпочитаемые должности"

/datum/ui_module/job_preferences/ui_state(mob/user)
	return GLOB.always_state

/datum/ui_module/job_preferences/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "JobPreferences", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/ui_module/job_preferences/ui_data(mob/user)
	var/list/data = list()
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return data

	var/list/jobs = list()
	for(var/datum/job/job as anything in SSjobs.occupations)
		if(job.admin_only || job.hidden_from_job_prefs || !job.can_novice_play(user.client))
			continue
		jobs += list(list(
			"title" = job.title,
			"name" = get_job_title_ru(prefs.GetPlayerAltTitle(job)),
			"department" = job.department,
			"color" = job.selection_color,
			"head" = (job.title in GLOB.command_positions) || job.title == JOB_TITLE_AI,
			"exclusive" = is_exclusive_job(job),
			"priority" = get_priority(prefs, job),
			"restriction" = get_restriction(user, job),
			"alt_titles" = !!length(job.alt_titles),
			"muted" = is_job_title_muted(prefs.job_support_low, job.title),
		))

	data["jobs"] = jobs
	data["alternate_option"] = prefs.alternate_option
	data["wiki"] = !!CONFIG_GET(string/wikiurl)
	return data

/datum/ui_module/job_preferences/ui_act(action, list/params)
	if(..())
		return
	var/mob/user = usr
	var/datum/preferences/prefs = user.client?.prefs
	if(!prefs)
		return

	switch(action)
		if("set_job_preference")
			var/datum/job/job = SSjobs.GetJob(params["job"])
			if(!job || job.admin_only || job.hidden_from_job_prefs || get_restriction(user, job))
				return
			var/level = params["level"]
			if(!(level in list(JOB_PREF_HIGH, JOB_PREF_MEDIUM, JOB_PREF_LOW, JOB_PREF_NEVER)))
				return
			if(is_exclusive_job(job))
				if((get_priority(prefs, job) == JOB_PREF_NEVER) == (level == JOB_PREF_NEVER))
					return
				prefs.UpdateJobPreference(user, job.title, level)
				return TRUE
			prefs.SetJobPreferenceLevel(job, level)
			return TRUE

		if("alt_title")
			var/datum/job/job = SSjobs.GetJob(params["job"])
			if(!length(job?.alt_titles))
				return
			var/list/choices = list(get_job_title_ru(job.title)) + job.alt_titles
			var/choice = tgui_input_list(user, "Выберите альтернативное название для должности \"[get_job_title_ru(job.title)]\".", "Альтернативные названия", choices)
			if(!choice)
				return
			prefs.SetPlayerAltTitle(job, job_title_ru_to_en(choice))
			return TRUE

		if("set_alternate_option")
			var/option = params["option"]
			if(!(option in list(GET_RANDOM_JOB, BE_ASSISTANT, RETURN_TO_LOBBY)))
				return
			prefs.alternate_option = option
			return TRUE

		if("reset")
			prefs.ResetJobs()
			return TRUE

		if("wiki")
			var/wiki_url = CONFIG_GET(string/wikiurl)
			if(!wiki_url)
				to_chat(user, span_danger("Данный URL-адрес отсутствует в конфигурации сервера."))
				return
			if(tgui_alert(user, "Вы хотите открыть страницу с информацией о выборе профессии в своём браузере?", "Выбор профессии", list("Да", "Нет")) == "Да")
				user << link("[wiki_url]/index.php/Job_Selection_and_Assignment")

		if("save")
			SStgui.close_uis(src)
			prefs.ShowChoices(user)

/datum/ui_module/job_preferences/proc/is_exclusive_job(datum/job/job)
	return job.title in list(JOB_TITLE_CIVILIAN, JOB_TITLE_PRISONER, JOB_TITLE_INVESTOR)

/datum/ui_module/job_preferences/proc/get_priority(datum/preferences/prefs, datum/job/job)
	for(var/level in JOB_PREF_HIGH to JOB_PREF_LOW)
		if(prefs.GetJobDepartment(job, level) & job.flag)
			return level
	return JOB_PREF_NEVER

/datum/ui_module/job_preferences/proc/get_restriction(mob/user, datum/job/job)
	var/client/user_client = user.client
	if(jobban_isbanned(user, job_title_ru_to_en(job.title)))
		return "Забанено"
	var/available_in_playtime = job.available_in_playtime(user_client)
	if(available_in_playtime)
		return "[get_exp_format(available_in_playtime)] за [job.get_exp_req_type()]"
	if(job.barred_by_disability(user_client))
		return "Инвалидность"
	if(!job.player_old_enough(user_client))
		var/available_in_days = job.available_in_days(user_client)
		return "Через [available_in_days] [declension_ru(available_in_days, "день", "дня", "дней")]"
	if(!job.character_old_enough(user_client))
		var/age_limit = get_age_limits(GLOB.all_species[user_client.prefs.species], job.min_age_type)
		return "Возраст от [age_limit] [declension_ru(age_limit, "года", "лет", "лет")]"
	if(!job.check_custom_requirements(user_client))
		return "Нужно достижение"

#undef JOB_PREF_HIGH
#undef JOB_PREF_MEDIUM
#undef JOB_PREF_LOW
#undef JOB_PREF_NEVER
