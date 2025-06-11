/datum/status_effect/rust_corruption
	alert_type = null
	id = "rust_turf_effects"
	tick_interval = 2 SECONDS

/datum/status_effect/rust_corruption/tick(seconds_between_ticks)
	if(issilicon(owner))
		owner.adjustBruteLoss(10 * seconds_between_ticks)
		return

	owner.Disgust(5 * seconds_between_ticks)
	owner.reagents?.remove_all(0.75 * seconds_between_ticks)
