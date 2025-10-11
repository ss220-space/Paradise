GLOBAL_DATUM_INIT(alarm_manager, /datum/alarm_manager, new())

/datum/alarm_manager
	var/list/alarms = list(
		"Motion" = list(),
		"Fire" = list(),
		"Atmosphere" = list(),
		"Power" = list(),
		"Camera" = list(),
		"Burglar" = list(),
	)

/datum/alarm_manager/proc/trigger_alarm(alarm_type, area/source_area, list/alarm_data, obj/alarm_source)
	var/list/typed_alarms = alarms[alarm_type]
	var/area_name = source_area.name

	if(area_name in typed_alarms)
		var/list/existing_alarm = typed_alarms[area_name]
		var/list/source_UIDs = existing_alarm[3]
		source_UIDs |= alarm_source.UID()
		return TRUE

	typed_alarms[area_name] = list(
		get_area_name(source_area, TRUE),
		alarm_data,
		list(alarm_source.UID())
	)
	SEND_SIGNAL(src, COMSIG_TRIGGERED_ALARM, alarm_type, source_area, alarm_data, alarm_source)
	return TRUE

/datum/alarm_manager/proc/cancel_alarm(alarm_type, area/source_area, obj/alarm_source)
	var/list/typed_alarms = alarms[alarm_type]
	var/area_name = source_area.name

	if(!(area_name in typed_alarms))
		return

	var/list/existing_alarm = typed_alarms[area_name]
	var/list/source_UIDs = existing_alarm[3]
	source_UIDs -= alarm_source.UID()

	if(!length(source_UIDs))
		typed_alarms -= area_name
		SEND_SIGNAL(src, COMSIG_CANCELLED_ALARM, alarm_type, source_area, alarm_source, TRUE)
	else
		SEND_SIGNAL(src, COMSIG_CANCELLED_ALARM, alarm_type, source_area, alarm_source, FALSE)
