// Карта состояния Mountain Wars — окно осмотра раненого, как в Barotrauma.
//
// Открывается само, когда осматриваешь бойца вплотную: кукла тела с подсветкой
// повреждений по конечностям, показатели жизни и лечение прямо из окна.
//
// Механики своей здесь нет ни грамма. Всё, что окно умеет делать с пациентом, оно
// делает штатной цепочкой удара предметом — melee_attack_chain, той же самой, что
// отрабатывает клик бинтом по бойцу. Значит все задержки, сообщения, проверки
// расстояния и особенности каждого предмета работают ровно как в игре, а окно
// остаётся вьюером с двумя кнопками. Дублировать лечение своим кодом нельзя:
// разойдётся при первой же правке аптечки.

/// Зоны в порядке отрисовки куклы, сверху вниз. Точных зон вроде глаз и рта здесь
/// нет: лечению они не нужны, а куклу засоряют.
#define MW_CHART_ZONES list(\
	BODY_ZONE_HEAD,\
	BODY_ZONE_CHEST,\
	BODY_ZONE_PRECISE_GROIN,\
	BODY_ZONE_L_ARM,\
	BODY_ZONE_R_ARM,\
	BODY_ZONE_PRECISE_L_HAND,\
	BODY_ZONE_PRECISE_R_HAND,\
	BODY_ZONE_L_LEG,\
	BODY_ZONE_R_LEG,\
	BODY_ZONE_PRECISE_L_FOOT,\
	BODY_ZONE_PRECISE_R_FOOT,\
)

// MARK: Состояние окна
// Окно закрывается само, стоит отойти от раненого: осмотр — это руки на теле, а не
// взгляд издалека. Отдельное состояние, а не готовый human_adjacent_state, потому что
// тот меряет расстояние до src_object, а у датума карты нет своей клетки — считать
// надо от пациента.
GLOBAL_DATUM_INIT(mw_chart_state, /datum/ui_state/mw_chart, new)

// Сюда приходит не сам датум карты, а то, что вернул её ui_host() — то есть пациент.
// Так устроен /datum/proc/ui_status: он зовёт can_use_topic(ui_host(user), ...).
// Проверка на тип датума здесь молча закрывала окно, не оставляя следа в логах.
/datum/ui_state/mw_chart/can_use_topic(atom/patient, mob/user)
	if(!ishuman(patient) || QDELETED(patient))
		return UI_CLOSE
	if(!isliving(user) || user.incapacitated())
		return UI_CLOSE
	if(!patient.Adjacent(user))
		return UI_CLOSE
	return UI_INTERACTIVE

// MARK: Карта
// Карта висит на самом пациенте и одна на всех: у койки может стоять двое медиков,
// и данные им нужны одни и те же. Живёт до смерти моба вместе с ним.
//
// Сам вар — /mob/living/carbon/human/var/mw_chart — объявлен в human_defines.dm рядом с
// остальными варами типа: в этой кодбазе вар обязан стоять в блоке своего типа, а
// объявлять тип второй раз здесь нельзя.

/datum/mw_bodychart
	var/mob/living/carbon/human/patient

/datum/mw_bodychart/New(mob/living/carbon/human/new_patient)
	patient = new_patient
	RegisterSignal(patient, COMSIG_QDELETING, PROC_REF(on_patient_gone))

/datum/mw_bodychart/Destroy(force)
	if(patient)
		UnregisterSignal(patient, COMSIG_QDELETING)
		patient.mw_chart = null
		patient = null
	return ..()

/datum/mw_bodychart/proc/on_patient_gone(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/mw_bodychart/ui_state(mob/user)
	return GLOB.mw_chart_state

/// Хост — пациент: по нему tgui сам закроет окно, если тело уедет с z-уровня.
/datum/mw_bodychart/ui_host(mob/user)
	return patient

/datum/mw_bodychart/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MwBodyChart", "Осмотр: [patient.name]")
		ui.open()

/datum/mw_bodychart/ui_data(mob/user)
	var/list/data = list()
	data["patient"] = patient.name
	data["dead"] = patient.stat == DEAD
	data["unconscious"] = patient.stat == UNCONSCIOUS
	data["health"] = round(patient.health)
	data["max_health"] = patient.maxHealth
	data["pulse"] = patient.get_pulse(GETPULSE_TOOL)
	data["blood_percent"] = round(patient.blood_volume / BLOOD_VOLUME_NORMAL * 100)
	data["oxy"] = round(patient.getOxyLoss())
	data["tox"] = round(patient.getToxLoss())
	data["selected"] = user.zone_selected
	var/obj/item/held = user.get_active_hand()
	data["held_item"] = held?.declent_ru(NOMINATIVE)
	data["helping"] = user.a_intent == INTENT_HELP

	var/list/limbs = list()
	for(var/zone in MW_CHART_ZONES)
		var/obj/item/organ/external/limb = patient.get_organ(zone)
		if(!limb)
			limbs += list(list("zone" = zone, "missing" = TRUE))
			continue
		limbs += list(list(
			"zone" = zone,
			"name" = limb.declent_ru(NOMINATIVE),
			"brute" = round(limb.brute_dam),
			"burn" = round(limb.burn_dam),
			"max_damage" = limb.max_damage,
			// Кровотечение к максимуму этой же конечности: 0.5 у кисти и у груди —
			// это очень разный литраж в минуту.
			"bleeding" = limb.max_bleeding_amount ? round(limb.bleeding_amount / limb.max_bleeding_amount, 0.01) : 0,
			"arterial" = limb.has_arterial_bleeding(),
			"internal" = limb.has_internal_bleeding(),
			"fracture" = limb.has_fracture(),
			"splinted" = limb.is_splinted(),
			"tourniquet" = !!limb.tourniquet,
			"embedded" = LAZYLEN(limb.embedded_objects),
			"infected" = limb.has_infected_wound(),
			"robotic" = limb.is_robotic(),
		))
	data["limbs"] = limbs
	return data

/datum/mw_bodychart/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	var/mob/living/user = ui.user
	switch(action)
		if("select")
			select_zone(user, params["zone"])
			return TRUE
		if("treat")
			select_zone(user, params["zone"])
			var/obj/item/held = user.get_active_hand()
			if(!held)
				to_chat(user, span_warning("В руке ничего нет."))
				return TRUE
			if(user.a_intent != INTENT_HELP)
				to_chat(user, span_warning("Не с этим намерением — переключитесь на помощь, иначе выйдет не лечение."))
				return TRUE
			// Асинхронно: внутри цепочки почти у любого бинта сидит do_after, а ui_act
			// спать не должен.
			INVOKE_ASYNC(held, TYPE_PROC_REF(/obj/item, melee_attack_chain), user, patient)
			return TRUE

/// Выбор зоны идёт через сам селектор из HUD, а не присваиванием zone_selected:
/// иначе выбранная в окне рука разойдётся с подсвеченной на панели прицела.
/datum/mw_bodychart/proc/select_zone(mob/user, zone)
	if(!(zone in MW_CHART_ZONES))
		return
	var/atom/movable/screen/zone_sel/selector = user.hud_used?.zone_select
	if(istype(selector))
		selector.set_selected_zone(zone)
	else
		user.zone_selected = zone

// MARK: Открытие по осмотру
// Зовётся из /mob/living/carbon/human/examine() — единственная правка вне модуля.
//
// Сигналом COMSIG_ATOM_EXAMINE это не сделать так, чтобы работало на всех: сигнал
// вешается на конкретного моба, то есть покрыл бы только бойцов, прошедших через
// add_member(). Заспавненный админом человек, наблюдатель, вселившийся в тело — мимо.
// Глобального COMSIG_GLOB_MOB_CREATED в этой сборке нет: define объявлен, а рассылки
// нет ни одной. Поэтому прямой вызов, а режим отсекается первой строкой — в обычном
// раунде проц выходит сразу.
/mob/living/carbon/human/proc/mw_examine_chart(mob/user, list/examine_list)
	if(!istype(SSticker?.mode, /datum/game_mode/mountain_wars))
		return
	if(!isliving(user) || !user.client || user.incapacitated())
		return
	if(!Adjacent(user))
		examine_list += span_notice("Чтобы осмотреть раны, нужно подойти вплотную.")
		return
	examine_list += span_notice("Вы осматриваете раны.")
	if(!mw_chart)
		mw_chart = new(src)
	mw_chart.ui_interact(user)

#undef MW_CHART_ZONES
