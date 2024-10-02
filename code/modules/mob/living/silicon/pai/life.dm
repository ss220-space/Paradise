#define PAI_CHEMICALS_COOLDOWN 15 SECONDS

/mob/living/silicon/pai/Life(seconds, times_fired)
	. = ..()
	if(QDELETED(src) || stat == DEAD)
		return

	if(silence_time)
		if(world.timeofday >= silence_time)
			silence_time = null
			if(stat != DEAD)
				to_chat(src, span_notice("<font color=green>Модуль связи восстановлен. Функции передачи речи и сообщений восстановлены.</font>") )

	if(installed_software["doorjack"])
		var/datum/pai_software/door_jack/DJ = installed_software["doorjack"]
		if(DJ.cable)
			if(get_dist(src, DJ.cable) > 1)
				visible_message(span_warning("Кабель данных, подключенный к пИИ, быстро втягивается обратно!"))
				QDEL_NULL(DJ.cable)

	if(installed_software["sec_chem"])
		if(chemicals < initial(chemicals))
			if(world.time > (last_change_chemicals + PAI_CHEMICALS_COOLDOWN))
				chemicals += 5
				last_change_chemicals = world.time

/mob/living/silicon/pai/updatehealth(reason = "none given", should_log = FALSE)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return ..()
	set_health(maxHealth - getBruteLoss() - getFireLoss())
	update_stat("updatehealth([reason])", should_log)

#undef PAI_CHEMICALS_COOLDOWN
