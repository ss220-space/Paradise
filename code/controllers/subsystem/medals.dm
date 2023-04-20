SUBSYSTEM_DEF(medals)
	name = "Medals"
	flags = SS_NO_FIRE
	var/hub_enabled = FALSE
	///List of achievements
	var/list/datum/award/achievement/achievements = list()
	///List of scores
	var/list/datum/award/score/scores = list()
	///List of all awards
	var/list/datum/award/awards = list()

/datum/controller/subsystem/medals/Initialize(timeofday)
	if(config.medal_hub_address && config.medal_hub_password)
		hub_enabled = TRUE
		for(var/T in subtypesof(/datum/award/achievement))
			var/instance = new T
			achievements[T] = instance
			awards[T] = instance

	for(var/T in subtypesof(/datum/award/score))
		var/instance = new T
		scores[T] = instance
		awards[T] = instance

	update_metadata()

	for(var/i in GLOB.clients)
		var/client/C = i
		if(!C.achievements.initialized)
			C.achievements.InitializeData()
	..()

/datum/controller/subsystem/medals/Shutdown()
	save_achievements_to_db()

/datum/controller/subsystem/medals/proc/save_achievements_to_db()
	var/list/data_to_save = list()
	for(var/owner_ckey in GLOB.achievement_data)
		var/datum/achievement_data/AC_DC = GLOB.achievement_data[owner_ckey]
		data_to_save += AC_DC.get_changed_data()
	if(!length(data_to_save))
		return
	SSdbcore.MassInsert(format_table_name("achievements"),data_to_save,duplicate_key = TRUE)

/datum/controller/subsystem/medals/proc/update_metadata()
	var/list/current_metadata = list()
	//select metadata here
	var/datum/db_query/Q = SSdbcore.NewQuery("SELECT achievement_key,achievement_version FROM [format_table_name("achievement_metadata")]")
	if(!Q.Execute(async = TRUE))
		qdel(Q)
		return
	else
		while(Q.NextRow())
			current_metadata[Q.item[1]] = text2num(Q.item[2])
		qdel(Q)
	var/list/to_update = list()
	for(var/T in awards)
		var/datum/award/A = awards[T]
		if(!A.database_id)
			continue
		if(!current_metadata[A.database_id] || current_metadata[A.database_id] < A.achievement_version)
			to_update += list(A.get_metadata_row())
	if(to_update.len)
		SSdbcore.MassInsert(format_table_name("achievement_metadata"),to_update,duplicate_key = TRUE)
