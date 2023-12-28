SUBSYSTEM_DEF(holiday)
	name = "Holiday"
	init_order = INIT_ORDER_HOLIDAY // 4
	flags = SS_NO_FIRE
	ss_id = "holiday"
	var/list/holidays

/datum/controller/subsystem/holiday/Initialize()
	if(!CONFIG_GET(flag/allow_holidays))
		return //Holiday stuff was not enabled in the config!

	var/YY = text2num(time2text(world.timeofday, "YY")) 	// get the current year
	var/MM = text2num(time2text(world.timeofday, "MM")) 	// get the current month
	var/DD = text2num(time2text(world.timeofday, "DD")) 	// get the current day

	for(var/H in subtypesof(/datum/holiday))
		var/datum/holiday/holiday = new H()
		if(holiday.shouldCelebrate(DD, MM, YY))
			holiday.celebrate()
			if(!holidays)
				holidays = list()
			holidays[holiday.name] = holiday

/datum/controller/subsystem/holiday/OnMasterLoad()
	if(holidays)
		holidays = shuffle(holidays)
		world.update_status()
		for(var/holiday in holidays)
			var/datum/holiday/H = holidays[holiday]
			//do event_chance'ing inside handle_event
			H.handle_event()
