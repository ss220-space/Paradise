/datum/event/vox_raiders
	name = "Воксы рейдеры"

/datum/event/vox_raiders/start()
	processing = FALSE //so it won't fire again in next tick
	if(num_station_players() < 25)
		message_admins("Vox raiders event failed to start. Not enough players.")
		return
	create_vox_team(4)
