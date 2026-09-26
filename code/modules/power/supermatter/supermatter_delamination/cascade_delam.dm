/datum/sm_delam/cascade
	/// The supermatter crystal that initiated the cascade.
	var/obj/machinery/power/supermatter_crystal/delam_sm
	/// The evacuation rift created during the cascade.
	var/obj/cascade_portal/delam_rift

/datum/sm_delam/cascade/Destroy()
	delam_sm = null
	delam_rift = null
	return ..()

/datum/sm_delam/cascade/can_select(obj/machinery/power/supermatter_crystal/sm)
	if(!sm.is_main_engine)
		return FALSE
	var/total_moles = sm.absorbed_gasmix.total_moles()
	if(total_moles < MOLE_PENALTY_THRESHOLD * sm.absorption_ratio)
		return FALSE
	var/cached_gas_percentage = sm.gas_percentage
	for(var/gas_id in list(TLV_ANTINOBLIUM, TLV_HYPERNOBLIUM))
		var/percent = cached_gas_percentage[gas_id]
		if(!percent || percent < 0.4)
			return FALSE
	return TRUE

/datum/sm_delam/cascade/delam_progress(obj/machinery/power/supermatter_crystal/sm)
	if(!..())
		return FALSE

	radio_announce(
		"ОПАСНОСТЬ: ЧАСТОТА КОЛЕБАНИЙ ГИПЕРСТРУКТУРЫ ВЫШЛА ЗА ДОПУСТИМЫЕ ПРЕДЕЛЫ.",
		DECLENT_RU_CAP(sm, NOMINATIVE),
		sm.damage >= sm.emergency_point ? sm.emergency_channel : sm.warning_channel,
		sm,
	)
	var/list/messages = list(
		"Пространство будто бы смещается вокруг вас...",
		"Вы слышите высокий звенящий звук.",
		"Вы чувствуете покалывание, бегущее по спине.",
		"Что-то ощущается совершенно неправильно.",
		"Гнетущее чувство ужаса захлёстывает вас.",
	)
	dispatch_announcement_to_players(span_danger(pick(messages)), should_play_sound = FALSE)

	return TRUE

/datum/sm_delam/cascade/on_select(obj/machinery/power/supermatter_crystal/sm)
	message_admins("[sm] is heading towards a cascade. [ADMIN_VERBOSEJMP(sm)]")
	sm.investigate_log("is heading towards a cascade.", INVESTIGATE_ENGINE)

	sm.warp = new(sm)
	sm.vis_contents += sm.warp
	animate(sm.warp, time = 1, transform = matrix().Scale(0.5,0.5))
	animate(time = 9, transform = matrix())

	addtimer(CALLBACK(src, PROC_REF(announce_cascade), sm), 2 MINUTES)

/datum/sm_delam/cascade/on_deselect(obj/machinery/power/supermatter_crystal/sm)
	message_admins("[sm] will no longer cascade. [ADMIN_VERBOSEJMP(sm)]")
	sm.investigate_log("will no longer cascade.", INVESTIGATE_ENGINE)

	sm.vis_contents -= sm.warp
	QDEL_NULL(sm.warp)

/datum/sm_delam/cascade/delaminate(obj/machinery/power/supermatter_crystal/sm)
	message_admins("Supermatter [sm] at [ADMIN_VERBOSEJMP(sm)] triggered a cascade delam.")
	sm.investigate_log("triggered a cascade delam.", INVESTIGATE_ENGINE)

	effect_explosion(sm)
	effect_emergency_state()
	effect_cascade_demoralize()

	GLOB.major_announcement.announce(
		message = "В вашем секторе произошло событие резонансного сдвига типа C. Сканирование указывает на локальный поток колебаний, затрагивающий пространственную и гравитационную субструктуру. \
			Образовалось множество резонансных очагов. Пожалуйста, ожидайте.",
		new_title = "Ассоциация наблюдения за звёздами \"Нанотрейзен\"",
		new_sound = 'sound/AI/spanomalies.ogg',
	)

	delam_sm = sm
	addtimer(CALLBACK(src, PROC_REF(delaminate_step2)), 2 SECONDS)
	return ..()

/datum/sm_delam/cascade/proc/delaminate_step2()
	effect_strand_shuttle()
	addtimer(CALLBACK(src, PROC_REF(delaminate_step3)), 5 SECONDS)

/datum/sm_delam/cascade/proc/delaminate_step3()
	delam_rift = effect_evac_rift_start()
	RegisterSignal(delam_rift, COMSIG_QDELETING, PROC_REF(end_round_holder))
	SSsupermatter_cascade.can_fire = TRUE
	SSsupermatter_cascade.cascade_initiated = TRUE
	effect_crystal_mass(delam_sm, delam_rift)

/datum/sm_delam/cascade/examine(obj/machinery/power/supermatter_crystal/sm)
	return list(span_bolddanger("Кристалл вибрирует с невероятной скоростью, искривляя пространство вокруг себя!"))

/datum/sm_delam/cascade/overlays(obj/machinery/power/supermatter_crystal/sm)
	return list()

/datum/sm_delam/cascade/count_down_messages(obj/machinery/power/supermatter_crystal/sm)
	var/list/messages = list()
	messages += "РАССЛОЕНИЕ КРИСТАЛЛА НЕМИНУЕМО! Суперматерия достигла критического разрушения целостности. Превышены пределы гармонической частоты. Не удалось задействовать поле дестабилизации причинности."
	messages += "Кристаллическая гиперструктура возвращается к безопасным рабочим параметрам. Гармоническая частота восстановлена в аварийных пределах. Запущен антирезонансный фильтр."
	messages += "до стабилизации, вызванной резонансом."
	return messages

/datum/sm_delam/cascade/proc/announce_cascade(obj/machinery/power/supermatter_crystal/sm)
	if(QDELETED(sm))
		return FALSE
	if(!can_select(sm))
		return FALSE
	GLOB.major_announcement.announce(
		message = "В вашем секторе произошло событие резонансного сдвига типа C. Сканирование указывает на локальный поток колебаний, затрагивающий пространственную и гравитационную субструктуру. \
			Образовалось множество резонансных очагов. Пожалуйста, ожидайте.",
		new_title = "Ассоциация наблюдения за звёздами \"Нанотрейзен\"",
		new_sound = 'sound/misc/airraid.ogg',
	)
	return TRUE

/// Signal calls cant sleep, we gotta do this.
/datum/sm_delam/cascade/proc/end_round_holder()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(effect_evac_rift_end))
