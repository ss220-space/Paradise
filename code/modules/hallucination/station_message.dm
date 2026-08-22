#define CANCEL_FAKE_ALERT -1

/// Fake station advertisements.
/datum/hallucination/station_message
	abstract_hallucination_parent = /datum/hallucination/station_message
	random_hallucination_weight = 1
	hallucination_tier = HALLUCINATION_TIER_RARE
	/// if TRUE, skip on deaf hallucinators
	var/require_hearing = TRUE

/datum/hallucination/station_message/start()
	if(require_hearing && HAS_TRAIT(hallucinator, TRAIT_DEAF))
		return FALSE
	if(do_fake_alert() == CANCEL_FAKE_ALERT)
		return FALSE

	qdel(src) // To be implemented by subtypes, call parent for easy cleanup
	return TRUE

/datum/hallucination/station_message/proc/do_fake_alert()
	return CANCEL_FAKE_ALERT

/datum/hallucination/station_message/blob_alert
	require_hearing = TRUE

/datum/hallucination/station_message/blob_alert/do_fake_alert()
	GLOB.minor_announcement.announce(
		message = "Подтверждена вспышка биологической угрозы 5-го уровня на борту [station_name()]. Всему персоналу надлежит сдержать её распространение любой ценой!",
		new_title = "Биологическая угроза",
		new_sound = ANNOUNCER_OUTBREAK5,
	)

/datum/hallucination/station_message/shuttle_dock

/datum/hallucination/station_message/shuttle_dock/do_fake_alert()
	GLOB.minor_announcement.announce(
		message = "[SSshuttle.emergency] пристыковался к станции. У вас есть [DisplayTimeText(SSshuttle.emergency.timeLeft())] чтобы подняться на борт эвакуационного шаттла.",
		new_title = "Прибытие эвакуационного шаттла",
		new_sound = ANNOUNCER_SHUTTLEDOCK,
	)

/datum/hallucination/station_message/malf_ai
	require_hearing = TRUE

/datum/hallucination/station_message/malf_ai/do_fake_alert()
	if(!length(GLOB.ai_list))
		return CANCEL_FAKE_ALERT

	GLOB.minor_announcement.announce(
		message = "Во всех системах станции обнаружены вредоносные процессы, пожалуйста, деактивируйте ваш ИИ, чтобы предотвратить возможное повреждение его ядра морали.",
		new_title = "Аномалия",
		new_sound = ANNOUNCER_AIMALF,
	)

/datum/hallucination/station_message/cult_summon
	require_hearing = TRUE

/datum/hallucination/station_message/cult_summon/do_fake_alert()
	var/mob/living/carbon/human/totally_real_cult_leader = random_non_sec_crewmember()
	if(!totally_real_cult_leader)
		return CANCEL_FAKE_ALERT

	var/area/hallucinator_area = get_area(hallucinator)
	var/list/station_areas = list()
	for(var/area/possible_area as anything in GLOB.areas)
		if(possible_area == hallucinator_area || !is_station_level(possible_area.z))
			continue
		station_areas += possible_area

	if(!length(station_areas))
		return CANCEL_FAKE_ALERT

	var/area/fake_summon_area = pick(station_areas)

	GLOB.minor_announcement.announce(
		message = "Осколки древнего бога призываются [totally_real_cult_leader.real_name] в [fake_summon_area] из неизвестного измерения. Сорвите ритуал любой ценой!",
		new_title = "[command_name()] Дела высших измерений",
	)

/datum/hallucination/station_message/meteors
	random_hallucination_weight = 2
	require_hearing = TRUE

/datum/hallucination/station_message/meteors/do_fake_alert()
	GLOB.minor_announcement.announce(
		message = "Метеоры обнаружены на курсе столкновения со станцией.",
		new_title = "Метеоритная тревога",
		new_sound = ANNOUNCER_METEORS,
	)

/datum/hallucination/station_message/clock_cult_ark
	random_hallucination_weight = 0

/datum/hallucination/station_message/clock_cult_ark/start()
	hallucinator.playsound_local(hallucinator, 'sound/magic/clockwork/clockcult_gateway_charging.ogg', 50, FALSE, pressure_affected = FALSE)
	hallucinator.playsound_local(hallucinator, 'sound/magic/clockwork/clockcult_gateway_disrupted.ogg', 50, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(play_distant_explosion_sound)), 2.7 SECONDS)
	return TRUE

/datum/hallucination/station_message/clock_cult_ark/proc/play_distant_explosion_sound()
	if(QDELETED(src))
		return

	hallucinator.playsound_local(get_turf(hallucinator), SFX_EXPLOSION_CREAKING, 50, FALSE, pressure_affected = FALSE)
	qdel(src)

#undef CANCEL_FAKE_ALERT
