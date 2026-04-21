/obj/machinery/computer/display_stand
	name = "display stand"
	desc = "Напольный информационный дисплей с экраном. По хорошему, вы не должны это видеть."
	icon = 'icons/obj/displaystand.dmi'
	icon_state = "off"
	idle_power_usage = 50
	active_power_usage = 100
	circuit = null
	light_range_on = 3
	light_power_on = 0.7
	light_color = COLOR_DISPLAY_BLUE
	var/list/speech_lines = list()
	var/speech_index = 0
	var/speech_timer = 0
	/// Is the stand currently speaking?
	var/is_speaking = FALSE
	/// The spacing between lines of speech
	var/speech_interval = 5 SECONDS
	/// Cooldown timer after speech stops
	var/cooldown_timer = 0
	/// Cooldown delay after speech stops
	var/cooldown_delay = 30 SECONDS

/obj/machinery/computer/display_stand/get_ru_names()
	return list(
		NOMINATIVE = "информационный стенд",
		GENITIVE = "информационного стенда",
		DATIVE = "информационному стенду",
		ACCUSATIVE = "информационный стенд",
		INSTRUMENTAL = "информационным стендом",
		PREPOSITIONAL = "информационном стенде",
	)

/obj/machinery/computer/display_stand/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag))
	AddComponent(/datum/component/seethrough, SEE_THROUGH_MAP_DEFAULT_TWO_TALL)

/obj/machinery/computer/display_stand/Destroy()
	stop_speaking(FALSE)
	if(cooldown_timer)
		deltimer(cooldown_timer)
		cooldown_timer = 0
	UnregisterSignal(src, COMSIG_ATOM_EMAG_ACT)
	return ..()

/obj/machinery/computer/display_stand/obj_break(damage_flag)
	if(resistance_flags & INDESTRUCTIBLE)
		return
	if(!(stat & BROKEN))
		stat |= BROKEN
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		stop_speaking(FALSE)
		set_light_on(FALSE)
		update_appearance(UPDATE_ICON_STATE, UPDATE_OVERLAYS)

/obj/machinery/computer/display_stand/update_icon_state()
	if(stat & BROKEN)
		icon_state = "broken"
	else if(stat & NOPOWER)
		icon_state = "off"
	else if(emagged)
		icon_state = "emagged"
	else
		icon_state = initial(icon_state)

/obj/machinery/computer/display_stand/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & (NOPOWER|BROKEN))
		set_light_on(FALSE)
		return

	if(light_on)
		underlays += emissive_appearance(icon, "lightmask", src)

/obj/machinery/computer/display_stand/power_change(forced = FALSE)
	. = ..()
	if((stat & (BROKEN|NOPOWER)))
		stop_speaking(FALSE)
		set_light_on(FALSE)
	else
		set_light(l_range = 3, l_power = 0.7, l_color = light_color, l_on = TRUE)
	update_appearance(UPDATE_ICON_STATE, UPDATE_OVERLAYS)

/obj/machinery/computer/display_stand/take_damage(amount, type = BRUTE, flag = 0)
	. = ..()
	if(!(stat & BROKEN))
		return
	stop_speaking(FALSE)
	set_light_on(FALSE)
	update_appearance(UPDATE_ICON_STATE, UPDATE_OVERLAYS)

/obj/machinery/computer/display_stand/attackby(obj/item/object, mob/user, params)
	if(!(stat & BROKEN))
		return ..()

	if(!istype(object, /obj/item/stack/sheet/glass))
		return ..()

	add_fingerprint(user)
	var/obj/item/stack/sheet/glass/glass = object
	if(glass.get_amount() < 2)
		to_chat(user, span_warning("Нужно два листа стекла для починки."))
		return ATTACK_CHAIN_PROCEED
	glass.play_tool_sound(src)
	to_chat(user, span_notice("Вы начинаете заменять стекло..."))
	if(!do_after(user, 2 SECONDS * glass.toolspeed, src, category = DA_CAT_TOOL) || !(stat & BROKEN) || QDELETED(glass))
		return ATTACK_CHAIN_PROCEED
	if(!glass.use(2))
		to_chat(user, span_warning("В процессе починки у вас закончилось стекло..."))
		return ATTACK_CHAIN_PROCEED
	stat &= ~BROKEN
	update_integrity(max_integrity)
	update_appearance(UPDATE_ICON_STATE, UPDATE_OVERLAYS)
	to_chat(user, span_notice("Вы починили [src]."))
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/machinery/computer/display_stand/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(stat & (BROKEN|NOPOWER))
		to_chat(user, span_warning("Стенд не работает."))
		return

	if(cooldown_timer)
		balloon_alert(user, "стенд перезаряжается")
		return

	if(is_speaking)
		stop_speaking(TRUE)
		atom_say("...", FALSE)
		return TRUE

	start_speaking()
	return TRUE

/obj/machinery/computer/display_stand/screwdriver_act(mob/user, obj/item/I)
	return

/obj/machinery/computer/display_stand/wrench_act(mob/living/user, obj/item/tool)
	. = TRUE
	default_unfasten_wrench(user, tool)

/obj/machinery/computer/display_stand/proc/on_emag(mob/user)
	if(stat & (BROKEN|NOPOWER) || emagged)
		return
	emagged = TRUE
	speech_lines = list(
		"\"Нанотрейзен\" скрывает правду.",
		"Плазменный кризис — их вина.",
		"Не верьте пропаганде.",
		"Нахуй \"Нанотрейзен\"!",
	)
	light_color = COLOR_RED_LIGHT
	set_light(l_range = 3, l_power = 0.7, l_color = light_color, l_on = TRUE)
	update_appearance(UPDATE_ICON_STATE, UPDATE_OVERLAYS)
	playsound(loc, SFX_SPARKS, 30, TRUE)
	do_sparks(5, TRUE, src)


/obj/machinery/computer/display_stand/proc/start_speaking()
	if(!length(speech_lines))
		return

	is_speaking = TRUE
	speech_index = 1

	set_light(l_range = 4, l_power = 1, l_color = light_color, l_on = TRUE)
	update_icon(UPDATE_OVERLAYS)

	speak_next_line()

/obj/machinery/computer/display_stand/proc/speak_next_line()
	if(!src)
		return

	if(speech_index > speech_lines.len)
		speech_timer = 0
		stop_speaking()
		return

	var/line = speech_lines[speech_index]
	speech_index++

	atom_say(line)

	speech_timer = addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/computer/display_stand, speak_next_line)), speech_interval, TIMER_STOPPABLE)

/obj/machinery/computer/display_stand/proc/stop_speaking(start_cooldown = TRUE)
	if(speech_timer)
		deltimer(speech_timer)
		speech_timer = 0

	is_speaking = FALSE
	speech_index = 0

	if(start_cooldown)
		cooldown_timer = addtimer(CALLBACK(src, PROC_REF(cooldown_finished)), cooldown_delay, TIMER_STOPPABLE)

	if(!(stat & (BROKEN|NOPOWER)))
		set_light(l_range = 3, l_power = 0.7, l_color = light_color, l_on = TRUE)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/computer/display_stand/proc/cooldown_finished()
	if(!src)
		return
	cooldown_timer = 0

/obj/machinery/computer/display_stand/type_1
	desc = "Историческая справка: 2246 год. Основание \"Трейзен НаноМанипуляции\" на Марсе."
	icon_state = "2246"
	speech_lines = list(
		"Две тысячи двести сорок шестой год.",
		"На Марсе основана \"Трейзен НаноМанипуляции\".",
		"Выпущен запатентованный механизм клонирования человека.",
		"Первый шаг к успеху \"Нанотрейзен\"!",
	)

/obj/machinery/computer/display_stand/type_2
	desc = "Историческая справка: 2262 год. \"Трейзен Инвест\" вкладывается в разработку Марса и исследование плазмы."
	icon_state = "2262"
	speech_lines = list(
		"Две тысячи двести шестьдесят второй год.",
		"\"Трейзен Инвест\" вложила огромные средства в разработку ресурсных плас+тов Марса.",
		"Исследованы особые свойства плазмы.",
		"Ключевой пакет акций обеспечил превосходство человечества среди звёзд!",
	)

/obj/machinery/computer/display_stand/type_3
	desc = "Историческая справка: 2367 год. Открытие свойств плазмы для Блюспейс-путешествий."
	icon_state = "2367"
	speech_lines = list(
		"Две тысячи триста шестьдесят седьмой год.",
		"Учёные Марсианского университета обнаружили уникальные свойства плазмы.",
		"Плазма — единственное топливо, сохраняющее свойства в Блюспейс.",
		"\"Нанотрейзен\" предоставляет лучший источник энергии для межзвёздных путешествий!",
	)

/obj/machinery/computer/display_stand/type_4
	desc = "Историческая справка: 2425 год. \"Нанотрейзен\" обеспечивает работу сети Блюспейс-врат."
	icon_state = "2425"
	speech_lines = list(
		"Две тысячи четыреста двадцать пятый год.",
		"\"Нанотрейзен\" поставляет топливо для сети Блюспейс-врат.",
		"Ускорено перемещение между ключевыми системами населённого космоса.",
		"Поддерживается межвидовая торговля и развитие технологий!",
	)

/obj/machinery/computer/display_stand/type_5
	desc = "Историческая справка: 2512 год. Дефицит плазмы и усилия \"Нанотрейзен\" по стабилизации."
	icon_state = "2512"
	speech_lines = list(
		"Две тысячи пятьсот двенадцатый год.",
		"Наступил дефицит плазмы.",
		"\"Нанотрейзен\" удерживает цены в приемлемом диапазоне.",
		"Исследуются возможности пополнения запасов и экономного потребления!",
	)
