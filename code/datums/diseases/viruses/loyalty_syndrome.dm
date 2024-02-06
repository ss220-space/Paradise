#define STAGE_TIME 60

/datum/disease/virus/loyalty
	name = "Loyalty Syndrome"
	agent = "Halomonas minomae"
	desc = "A disease that causes acute mass insanity for a certain person, as well as various obsessions"
	max_stages = 5
	spread_flags = CONTACT
	permeability_mod = 0.8
	can_immunity = FALSE
	cure_text = "Anti-Psychotics"
	cures = list("haloperidol")
	cure_prob = 8
	visibility_flags = HIDDEN_HUD
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

/datum/disease/virus/loyalty/New(var/mob/living/carbon/human/new_master)
	..()
	if(new_master)
		master = new_master
	else
		is_master = TRUE

/datum/disease/virus/loyalty/Contract(mob/living/M, act_type, is_carrier = FALSE, need_protection_check = FALSE, zone)
	if(!CanContract(M, act_type, need_protection_check, zone))
		return FALSE

	var/mob/living/carbon/human/new_master = is_master ? affected_mob : master
	var/datum/disease/virus/loyalty/copy = new(new_master)

	//recontract cured master
	if(new_master == M)
		copy.is_master = TRUE

	M.diseases += copy
	copy.affected_mob = M
	GLOB.active_diseases += copy
	copy.carrier = is_carrier
	copy.affected_mob.med_hud_set_status()
	return copy

/datum/disease/virus/loyalty/stage_act()
	if(!..())
		return FALSE

	if(affected_mob && !is_master && master && stage >= 4)
		var/message = ""
		var/health_change = 0
		var/see_master = FALSE

		if(QDELETED(master))
			if(need_master_death_message)
				death_of_master(span_cultlarge("Внезапно всё ваше тело пронзает боль от осознания одной мысли. \n[span_reallybig("[master.real_name] больше нет с нами")]"))
			return FALSE

		if(master.stat == DEAD)
			if(need_master_death_message)
				death_of_master(span_cultlarge("Внезапно всё ваше тело пронзает боль от осознания одной мысли. \n[span_reallybig("[master.real_name] мертв[genderize_ru(master.gender, "", "а", "о", "ы")]!")]"))
			return FALSE
		else
			need_master_death_message = TRUE

		say_timer++

		if(master in view(affected_mob))
			see_master = TRUE
			timer = max(timer - round(timer/10 + 1) , 0)

			if(prob(weaken_prob))
				affected_mob.say(pick("Вы... слишком прекрасны, [master.real_name]...", "Ох...", "Я не достоин Вас...",\
						"Вы выглядите сногсшибательно!"))
				addtimer(CALLBACK(affected_mob, TYPE_PROC_REF(/mob/living/carbon, Weaken), 1 SECONDS), 3 SECONDS)
		else
			timer++
			need_meating_message = TRUE

		switch(timer)
			if(0 to STAGE_TIME)
				if(see_master)
					if(say_timer > say_cooldown && prob(say_prob + say_timer))
						message = pick("[master.real_name], мне не хватает вашего внимания...", "[master.real_name], ваше присутствие вселяет в меня радость!",\
							"Вы так прекрасны, [master.real_name]!", "Рядом с вами я чувствую тепло в своём сердце, [master.real_name]",\
							"Позвольте мне пасть у ваших ног, [master.real_name]!", "Я тону в ваших бескрайних глазах, [master.real_name]!",\
							"Я заполучу вашу любовь, [master.real_name] ...любой ценой!")
					health_change = round(timer/STAGE_TIME, 0.25) - 1
				else
					if(prob(say_prob))
						to_chat(affected_mob, span_notice(pick("Мне не следует отдаляться от [master.real_name]...", \
							"Я долж[genderize_ru(affected_mob.gender, "ен", "на", "но", "ны")] вернуться, пока не поздно!")))

			if((STAGE_TIME + 1) to (2 * STAGE_TIME))
				if(need_meating_message && see_master)
					message = pick("Вот и вы, [master.real_name]")
					need_meating_message = FALSE

				if(!see_master)
					if(say_timer > say_cooldown && prob(say_prob + say_timer))
						message = pick("Где же [master.real_name]...", "Вы же тут, [master.real_name]?", "Никто не видел [master.real_name]?")
						addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, affected_mob, \
							span_notice("Странный голос шепчет [get_direction("откуда-то c ", "a")]")), rand(2, 20) SECONDS)
					health_change = round(timer/(8 * STAGE_TIME), 0.025)  //0.125 - 0.25 toxins

			if((2 * STAGE_TIME + 1) to (4 * STAGE_TIME))
				if(need_meating_message && see_master)
					message = pick("[genderize_ru(affected_mob.gender, "Я нашёл", "Я нашла", "Я нашло", "Мы нашли")] вас, [master.real_name]!")
					need_meating_message = FALSE

				if(!see_master)
					if(say_timer > say_cooldown && prob(say_prob + say_timer))
						message = pick("Я не могу без [master.real_name]!", "[master.real_name], где вы?!", "[master.real_name], прошу, вернитесь!")
						addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, affected_mob, \
							span_warning("Странный голос зовёт меня [get_direction("откуда-то c ", "a")]!")), rand(2, 20) SECONDS)
					health_change = round(timer/(6 * STAGE_TIME), 0.125)  //0.33 - 0.66 toxins

			if((4 * STAGE_TIME + 1) to INFINITY)
				if(need_meating_message && see_master)
					message = pick("Наконец то [genderize_ru(affected_mob.gender, "я снова обрёл", "я снова обрёла", "я снова обрёло", "мы снова обрёли")] вас, [master.real_name]!")
					need_meating_message = FALSE

				if(!see_master)
					if(say_timer > say_cooldown && prob(say_prob + say_timer))
						message = pick("Я умираю без [master.real_name]!", "[master.real_name], умоляю, вернитесь!", "Я найду Вас!")
						addtimer(CALLBACK(GLOBAL_PROC, /proc/to_chat, affected_mob, \
							span_userdanger("Странный голос [pick("ужасающе вопит", "жалобно стонет", "кричит")] [get_direction("где-то на ", "e")]!!")), rand(2, 20) SECONDS)
					health_change = round(timer/(4 * STAGE_TIME), 0.25)  //1 - ∞ toxins

		if(affected_mob.z == master.z)
			if(timer <= STAGE_TIME)
				affected_mob.adjustOxyLoss(health_change)
				affected_mob.adjustBruteLoss(health_change)
				affected_mob.adjustFireLoss(health_change)
			affected_mob.adjustToxLoss(health_change)
		if(message != "")
			affected_mob.say(message)
			say_timer = 0
	return

/datum/disease/virus/loyalty/proc/get_direction(var/begin="", var/ending = "")
	if(affected_mob.z == master.z)
		. = begin
		. += dir2rustext(get_dir(affected_mob.loc, master.loc))
		. += ending
	else
		. = "где-то далеко отсюда"

/datum/disease/virus/loyalty/Copy()
	var/mob/living/carbon/human/new_master = is_master ? affected_mob : master
	var/datum/disease/virus/loyalty/copy = new(new_master)
	return copy

/datum/disease/virus/loyalty/proc/death_of_master(message)
	affected_mob.emote("scream")
	to_chat(affected_mob, message)
	need_master_death_message = FALSE
	affected_mob.adjustBrainLoss(50)
	addtimer(CALLBACK(affected_mob, TYPE_PROC_REF(/mob/living/carbon/human, emote), "cry"), rand(3, 10) SECONDS)
#undef STAGE_TIME
