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

/// Sends a fake station announcement only to the hallucinator.
/datum/hallucination/station_message/proc/announce_to_hallucinator(message, title, alert_sound)
	to_chat(hallucinator, "<div class='announcement minor'><h1>[html_encode(title)]</h1><p>[html_encode(message)]</p></div>", MESSAGE_TYPE_WARNING)

	var/sound_file = alert_sound ? alert_sound : 'sound/misc/notice2.ogg'
	if(sound_file)
		hallucinator.playsound_local(null, sound_file, 100)

/datum/hallucination/station_message/blob_alert

/datum/hallucination/station_message/blob_alert/do_fake_alert()
	announce_to_hallucinator(
		"Подтверждена вспышка биологической угрозы 5-го уровня на борту [station_name()]. Всему персоналу надлежит сдержать её распространение любой ценой!",
		"Биологическая угроза",
		'sound/misc/notice1.ogg',
	)

/datum/hallucination/station_message/shuttle_dock

/datum/hallucination/station_message/shuttle_dock/do_fake_alert()
	announce_to_hallucinator(
		"Эвакуационный шаттл пристыковался к станции. У вас есть 3 минуты чтобы подняться на борт эвакуационного шаттла.",
		"Прибытие эвакуационного шаттла",
		null,
	)

/datum/hallucination/station_message/malf_ai

/datum/hallucination/station_message/malf_ai/do_fake_alert()
	if(!length(GLOB.ai_list))
		return CANCEL_FAKE_ALERT
	announce_to_hallucinator(
		"Во всех системах станции обнаружены вредоносные процессы, пожалуйста, деактивируйте ваш ИИ, чтобы предотвратить возможное повреждение его ядра морали.",
		"Аномалия",
		'sound/misc/notice1.ogg',
	)

/datum/hallucination/station_message/cult_summon

/datum/hallucination/station_message/cult_summon/do_fake_alert()
	var/list/manifest_names = list()
	for(var/datum/data/record/record as anything in GLOB.data_core.general)
		if(record.fields["name"] == hallucinator.real_name)
			continue
		if(record.fields["rank"] in GLOB.security_positions)
			continue
		manifest_names += record.fields["name"]

	if(!length(manifest_names))
		return CANCEL_FAKE_ALERT

	var/turf/fake_summon_turf = get_safe_random_station_turf()
	if(!fake_summon_turf)
		return CANCEL_FAKE_ALERT

	announce_to_hallucinator(
		"Осколки древнего бога призываются [pick(manifest_names)] в [get_area(fake_summon_turf)] из неизвестного измерения. Сорвите ритуал любой ценой!",
		"[command_name()] Дела высших измерений",
		null,
	)

/datum/hallucination/station_message/meteors
	random_hallucination_weight = 2

/datum/hallucination/station_message/meteors/do_fake_alert()
	announce_to_hallucinator(
		"Метеоры обнаружены на курсе столкновения со станцией.",
		"Метеоритная тревога",
		null,
	)

/datum/hallucination/station_message/cult_summon/clock_cult_ark

/datum/hallucination/station_message/cult_summon/clock_cult_ark/start()
	hallucinator.playsound_local(hallucinator, 'sound/magic/clockwork/clockcult_gateway_charging.ogg', 50, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(play_gateway_disrupted_sound)), 15 SECONDS)
	return TRUE

/datum/hallucination/station_message/cult_summon/clock_cult_ark/proc/play_gateway_disrupted_sound()
	if(QDELETED(src))
		return

	hallucinator.playsound_local(hallucinator, 'sound/magic/clockwork/clockcult_gateway_disrupted.ogg', 50, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, PROC_REF(play_distant_explosion_sound)), 2.7 SECONDS)

/datum/hallucination/station_message/cult_summon/clock_cult_ark/proc/play_distant_explosion_sound()
	if(QDELETED(src))
		return

	hallucinator.playsound_local(get_turf(hallucinator), SFX_EXPLOSION_CREAKING, 50, FALSE, pressure_affected = FALSE)
	qdel(src)

/datum/hallucination/station_message/cc_execution

/datum/hallucination/station_message/cc_execution/do_fake_alert()
	var/bounty = rand(5000, 50000)
	announce_to_hallucinator(
		"[hallucinator.real_name] настоящим приказом был лишён защиты Космического Закона и приговорён к смертной казне. Всему экипажу разрешено и рекомендуется исполнить приговор. Между членами экипажа принявшими участие в процессе казни будет автоматически распределено денежное вознаграждение в размере [bounty] кредит[DECL_CREDIT(bounty)].",
		ANNOUNCE_CCKILL_RU,
		'sound/announcer/classic/commandreport.ogg',
	)

/datum/hallucination/station_message/ert

/datum/hallucination/station_message/ert/do_fake_alert()
	announce_to_hallucinator(
		"Внимание, [station_name()]. Мы предпринимаем шаги для отправки отряда быстрого реагирования для ликвидации [hallucinator.real_name]. Ожидайте.",
		ANNOUNCE_ERT_ACTIVATE_RU,
		null,
	)

#undef CANCEL_FAKE_ALERT
