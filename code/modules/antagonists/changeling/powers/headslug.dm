/datum/action/changeling/headslug
	name = "Новая надежда"
	desc = "Мы жертвуем своим нынешним телом, чтобы сбежать."
	helptext = "Мы становимся маленьким и хрупким существом, которое может подсадить яйцо в новое тело для нас. Можно использовать будучи мёртвым. Можно использовать в низшей форме."
	button_icon_state = "last_resort"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	req_stat = DEAD
	bypass_fake_death = TRUE

/datum/action/changeling/headslug/try_to_sting(mob/user, mob/target)
	if(tgui_alert(user, "Мы уверены, что покидаем это тело?", "Sting", list("Да", "Нет")) != "Да")
		return
	..()

/datum/action/changeling/headslug/sting_action(mob/user)
	explosion(get_turf(user), devastation_range = 0, heavy_impact_range = 0, light_impact_range = 2, flash_range = 0, silent = TRUE)

	for(var/mob/living/carbon/human/victim in range(2, user))
		to_chat(victim, span_userdanger("Вас ослепил фонтан крови!"))
		victim.Stun(2 SECONDS)
		victim.EyeBlurry(40 SECONDS)
		var/obj/item/organ/internal/eyes/eyes = victim.get_int_organ(/obj/item/organ/internal/eyes)
		if(istype(eyes))
			eyes.internal_receive_damage(5, silent = TRUE)
		victim.AdjustConfused(6 SECONDS)

	for(var/mob/living/silicon/silicon in range(2, user))
		to_chat(silicon, span_userdanger("Ваши сенсоры залиты кровью!"))
		silicon.Weaken(6 SECONDS)

	var/turf/our_turf = get_turf(user)
	var/datum/mind/user_mind = user.mind
	addtimer(CALLBACK(src, PROC_REF(headslug_appear), user_mind, our_turf), 0.5 SECONDS)	// So it's not killed in explosion

	user.gib()
	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE

/datum/action/changeling/headslug/proc/headslug_appear(datum/mind/user_mind, turf/cling_turf)

	var/mob/living/simple_animal/hostile/headslug/crab = new(cling_turf)
	crab.origin = user_mind

	if(cling.evented) // change colour to native for this slug
		crab.icon_state = "headslugevent"
		crab.icon_living = "headslugevent"
		crab.icon_dead = "headslug_deadevent"

	if(crab.origin)
		crab.origin.active = TRUE
		crab.origin.transfer_to(crab)
		to_chat(crab, span_warning("Вы вырываетесь из останков своего прежнего тела в потоке крови!"))
		to_chat(crab, span_changeling("Наши яйца могут быть отложены в любом мертвом гуманоиде, но не в низших формах. Используйте <b>Alt-Click</b> на подходящем мобе и сохраняйте спокойствие в течение 5 секунд."))
		to_chat(crab, span_notice("Хотя эта форма погибнет после откладывания яйца, наше истинное «я» возродится со временем."))
