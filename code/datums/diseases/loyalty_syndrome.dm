/datum/disease/loyalty
	name = "Loyalty Syndrome"
	max_stages = 5
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Haloperidol"
	cures = list("haloperidol")
	cure_chance = 3
	agent = "Halomonas minomae"
	viable_mobtypes = list(/mob/living/carbon/human)
	visibility_flags = HIDDEN_SCANNER
	severity = MEDIUM
	var/is_master = FALSE
	var/mob/living/carbon/human/master
	var/timer = 0
	var/say_prob = 8
	var/weaken_prob = 1
	var/need_meating_message = FALSE
	var/need_master_death_message = FALSE

/datum/disease/loyalty/New(var/mob/living/carbon/human/new_master)
	if(new_master)
		master = new_master
	else
		is_master = TRUE

/datum/disease/loyalty/Contract(mob/M)
	var/mob/living/carbon/human/new_master = is_master ? affected_mob : master
	var/datum/disease/loyalty/copy = new(new_master)

	M.viruses += copy
	copy.affected_mob = M
	GLOB.active_diseases += copy
	copy.affected_mob.med_hud_set_status()

/datum/disease/loyalty/stage_act()
	..()
	if(affected_mob && !is_master && master && stage >= 4)
		var/message = ""
		var/health_change = 0
		var/see_master = FALSE

		if(master.stat == DEAD)
			if(need_master_death_message)
				affected_mob.emote("scream")
				to_chat(affected_mob, span_cultlarge("Внезапно всё ваше тело пронзает боль от осознания одной мысли. \n[span_reallybig("[master] мертв[genderize_ru(master.gender, "", "а", "о", "ы")]!")]"))
				need_master_death_message = FALSE
				affected_mob.adjustBrainLoss(50)
				addtimer(CALLBACK(affected_mob, TYPE_PROC_REF(/mob/living/carbon, emote), "cry"), rand(3, 10) SECONDS)
			return
		else
			need_master_death_message = TRUE

		if(master in view(affected_mob))
			see_master = TRUE
			timer = max(timer - round(timer/10 + 1) , 0)

			if(prob(weaken_prob))
				affected_mob.say(pick("Вы... слишком прекрасны, [master]...", "Ох...", "Я не достоин Вас...",\
						"Вы выглядите сногсшибательно!"))
				addtimer(CALLBACK(affected_mob, TYPE_PROC_REF(/mob/living/carbon, Weaken), 1 SECONDS), 3 SECONDS)
		else
			timer++
			need_meating_message = TRUE

		switch(timer)
			if(0 to 30)
				if(see_master)
					if(prob(say_prob))
						message = pick("[master], мне не хватает вашего внимания...", "[master], ваше присутствие вселяет в меня радость!",\
							"Вы так прекрасны, [master]!", "Рядом с вами я чувствую тепло в своём сердце, [master]",\
							"Позвольте мне пасть у ваших ног, [master]!", "Я тону в ваших бескрайних глазах, [master]!",\
							"Я заполучу вашу любовь, [master] ...любой ценой!")
					health_change = round(timer/30, 0.25) - 1
				else
					if(prob(say_prob))
						to_chat(affected_mob, span_notice(pick("Мне не следует отдаляться от [master]...", \
							"Я долж[genderize_ru(affected_mob.gender, "ен", "на", "но", "но")] вернуться, пока не поздно!")))

			if(31 to 60)
				if(need_meating_message && see_master)
					message = pick("Вот и вы, [master]")
					need_meating_message = FALSE

				if(!see_master)
					if(prob(say_prob))
						message = pick("Где же [master]...", "Вы же тут, [master]?", "Никто не видел [master]?")
						addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, affected_mob, \
							span_notice("Голос мастера шепчет [get_direction("откуда-то c ", "a")]")), 30)
					health_change = round(timer/240, 0.025)  //0.125 - 0.25 toxins

			if(61 to 120)
				if(need_meating_message && see_master)
					message = pick("Я нашёл вас, [master]!")
					need_meating_message = FALSE

				if(!see_master)
					if(prob(say_prob))
						message = pick("Я не могу без [master]!", "[master], где вы?!", "[master], прошу, вернитесь!")
						addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, affected_mob, \
							span_warning("Голос мастера зовёт меня [get_direction("откуда-то c ", "a")]!")), 30)
					health_change = round(timer/120, 0.125)  //0.5 - 1 toxins

			if(120 to INFINITY)
				if(need_meating_message && see_master)
					message = pick("Наконец то я снова обрёл вас, [master]!")
					need_meating_message = FALSE

				if(!see_master)
					if(prob(say_prob))
						message = pick("Я умираю без [master]!", "[master], умоляю, вернитесь!", "Я найду Вас!")
						addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, affected_mob, \
							span_userdanger("Голос мастера [pick("ужасающе вопит", "жалобно стонет", "кричит")] [get_direction("где-то на ", "e")]!!")), 30)
					health_change = round(timer/60, 0.5)  //2 - ∞ toxins

		if(timer <= 30)
			affected_mob.adjustOxyLoss(health_change)
			affected_mob.adjustBruteLoss(health_change)
			affected_mob.adjustFireLoss(health_change)
		affected_mob.adjustToxLoss(health_change)
		if(message != "")
			affected_mob.say(message)
	return

/datum/disease/loyalty/proc/get_direction(var/begin="", var/ending = "")
	if(affected_mob.z == master.z)
		. = begin
		. += dir2rustext(get_dir(affected_mob.loc, master.loc))
		. += ending
	else
		. = "где-то далеко отсюда"
