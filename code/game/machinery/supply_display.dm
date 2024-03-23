/obj/machinery/status_display/supply_display
	name = "дисплей статуса доставки"
	is_supply = TRUE


/obj/machinery/status_display/supply_display/update()
	if(SSshuttle.supply.mode == SHUTTLE_IDLE)
		if(is_station_level(SSshuttle.supply.z))
			message1 = "ГРУЗ"
			message2 = "ГОТОВ"
		else
			message1 = "ВРЕМЯ"
			message2 = station_time_timestamp("hh:mm")
	else
		message1 = "ГРУЗ"
		message2 = SSshuttle.supply.getTimerStr()
		if(length(message2) > DISPLAY_CHARS_PER_LINE)
			message2 = "Error"

	update_display(message1, message2)

