/datum/status_effect/selfdestruct
	id = "self-destruct"
	duration = 20 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/selfdestruct

/atom/movable/screen/alert/status_effect/selfdestruct
	name = "Самоуничтожение"
	desc = "Запущен процесс вашего самоуничтожения с помощью консоли Научного руководителя."
	icon_state = "hacked"

/datum/status_effect/selfdestruct/tick(seconds_between_ticks)
	var/mob/living/silicon/robot/borg = owner
	if(borg.stat == DEAD)
		return

	borg.adjustBruteLoss(15 * seconds_between_ticks)
	borg.adjustFireLoss(15 * seconds_between_ticks)

	if(!borg.cell)
		return

	borg.cell.charge = max(0, borg.cell.charge - 500)
