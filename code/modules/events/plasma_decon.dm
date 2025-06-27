/datum/event/plasma_decon
	name = "Дезакцивация плазмы"

/datum/event/plasma_decon/announce()
	GLOB.priority_announcement.Announce("Активирована экспериментальная система дезакцивации плазмы. Пожалуйста, стойте подальше от вентиляционных отверстий и не вдыхайте выходящий дым.", "ВНИМАНИЕ: ПРОТОКОЛ DECON!")

/datum/event/plasma_decon/start()// This only contains vent_pumps so don't bother with type checking
	for(var/obj/machinery/atmospherics/unary/vent_pump/vent as anything in GLOB.all_vent_pumps)
		if(vent && vent.loc && is_station_level(vent.loc.z))
			var/datum/effect_system/fluid_spread/smoke/freezing/decon/smoke = new
			smoke.set_up(amount = 7, location = get_turf(vent), blast_radius = 7)
			smoke.start()
