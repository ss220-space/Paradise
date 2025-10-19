/datum/status_effect/selfdestruct
	id = "self-destruct"
	duration = 20 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/selfdestruct

/atom/movable/screen/alert/status_effect/selfdestruct
	name = "Самоуничтожение"
	desc = "Запущен процесс вашего самоуничтожения с помощью консоли директора исследований."
	icon_state = "hacked"

/datum/status_effect/selfdestruct/tick(seconds_between_ticks)
	var/mob/living/silicon/robot/borg = owner
	if(borg.stat != DEAD)
		borg.adjustBruteLoss(10)
		borg.adjustFireLoss(10)
	else
		return
	if(borg.cell && borg.cell.charge > 500)
		borg.cell.charge = borg.cell.charge - 500
