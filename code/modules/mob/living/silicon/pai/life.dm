/mob/living/silicon/pai/Life(seconds, times_fired)
	. = ..()
	if(QDELETED(src) || stat == DEAD)
		return
	if(silence_time)
		if(world.timeofday >= silence_time)
			silence_time = null
			to_chat(src, "<font color=green>Коммуникативные контуры инициализированы. Функции речи и отправки сообщений восстановлены.</font>")

	if(installed_software["doorjack"])
		var/datum/pai_software/door_jack/DJ = installed_software["doorjack"]
		if(DJ.cable)
			if(get_dist(src, DJ.cable) > 1)
				visible_message("<span class='warning'>Подключенный к [src] дата-кабель быстро наматывается обратно на катушку!</span>")
				QDEL_NULL(DJ.cable)

/mob/living/silicon/pai/updatehealth(reason = "none given")
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
	else
		health = 100 - getBruteLoss() - getFireLoss()
		update_stat("updatehealth([reason])")
