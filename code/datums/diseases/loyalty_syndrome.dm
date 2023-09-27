#define STAGE_TIME 60

/datum/disease/loyalty
	name = "Loyalty Syndrome"
	max_stages = 5
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	disease_flags = CAN_CARRY|CURABLE
	cure_text = "Anti-Psychotics"
	cures = list("haloperidol")
	cure_chance = 5
	agent = "Halomonas minomae"
	viable_mobtypes = list(/mob/living/carbon/human)
	visibility_flags = HIDDEN_SCANNER
	severity = DANGEROUS
	var/is_master = FALSE
	var/mob/living/carbon/human/master
	var/timer = 0
	var/say_prob = 5
	var/say_cooldown = 3      //anti-spam cooldown
	var/say_timer = 0
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
				addtimer(CALLBACK(affected_mob, TYPE_PROC_REF(/mob/living/carbon/human, emote), "cry"), rand(3, 10) SECONDS)
			return
		else
			need_master_death_message = TRUE

		say_timer++

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
			if(0 to STAGE_TIME)
				if(see_master)
					if(say_timer > say_cooldown && prob(say_prob + say_timer))
						message = pick("[master], мне не хватает вашего внимания...", "[master], ваше присутствие вселяет в меня радость!",\
							"Вы так прекрасны, [master]!", "Рядом с вами я чувствую тепло в своём сердце, [master]",\
							"Позвольте мне пасть у ваших ног, [master]!", "Я тону в ваших бескрайних глазах, [master]!",\
							"Я заполучу вашу любовь, [master] ...любой ценой!")
					health_change = round(timer/STAGE_TIME, 0.25) - 1
				else
					if(prob(say_prob))
						to_chat(affected_mob, span_notice(pick("Мне не следует отдаляться от [master]...", \
							"Я долж[genderize_ru(affected_mob.gender, "ен", "на", "но", "ны")] вернуться, пока не поздно!")))

			if((STAGE_TIME + 1) to (2 * STAGE_TIME))
				if(need_meating_message && see_master)
					message = pick("Вот и вы, [master]")
					need_meating_message = FALSE

				if(!see_master)
					if(say_timer > say_cooldown && prob(say_prob + say_timer))
						message = pick("Где же [master]...", "Вы же тут, [master]?", "Никто не видел [master]?")
						addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, affected_mob, \
							span_notice("Странный голос шепчет [get_direction("откуда-то c ", "a")]")), rand(2, 20) SECONDS)
					health_change = round(timer/(8 * STAGE_TIME), 0.025)  //0.125 - 0.25 toxins

			if((2 * STAGE_TIME + 1) to (4 * STAGE_TIME))
				if(need_meating_message && see_master)
					message = pick("[genderize_ru(affected_mob.gender, "Я нашёл", "Я нашла", "Я нашло", "Мы нашли")] вас, [master]!")
					need_meating_message = FALSE

				if(!see_master)
					if(say_timer > say_cooldown && prob(say_prob + say_timer))
						message = pick("Я не могу без [master]!", "[master], где вы?!", "[master], прошу, вернитесь!")
						addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, affected_mob, \
							span_warning("Странный голос зовёт меня [get_direction("откуда-то c ", "a")]!")), rand(2, 20) SECONDS)
					health_change = round(timer/(6 * STAGE_TIME), 0.125)  //0.33 - 0.66 toxins

			if((4 * STAGE_TIME + 1) to INFINITY)
				if(need_meating_message && see_master)
					message = pick("Наконец то [genderize_ru(affected_mob.gender, "я снова обрёл", "я снова обрёла", "я снова обрёло", "мы снова обрёли")] вас, [master]!")
					need_meating_message = FALSE

				if(!see_master)
					if(say_timer > say_cooldown && prob(say_prob + say_timer))
						message = pick("Я умираю без [master]!", "[master], умоляю, вернитесь!", "Я найду Вас!")
						addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, affected_mob, \
							span_userdanger("Странный голос [pick("ужасающе вопит", "жалобно стонет", "кричит")] [get_direction("где-то на ", "e")]!!")), rand(2, 20) SECONDS)
					health_change = round(timer/(4 * STAGE_TIME), 0.25)  //1 - ∞ toxins

		if(timer <= STAGE_TIME)
			affected_mob.adjustOxyLoss(health_change)
			affected_mob.adjustBruteLoss(health_change)
			affected_mob.adjustFireLoss(health_change)
		affected_mob.adjustToxLoss(health_change)
		if(message != "")
			affected_mob.say(message)
			say_timer = 0
	return

/datum/disease/loyalty/proc/get_direction(var/begin="", var/ending = "")
	if(affected_mob.z == master.z)
		. = begin
		. += dir2rustext(get_dir(affected_mob.loc, master.loc))
		. += ending
	else
		. = "где-то далеко отсюда"

/datum/disease/loyalty/Copy()
	var/mob/living/carbon/human/new_master = is_master ? affected_mob : master
	var/datum/disease/loyalty/copy = new(new_master)
	return copy

#undef STAGE_TIME
