/obj/machinery/display_stand
	name = "display stand"
	desc = "Напольный информационный дисплей с экраном. По хорошему, вы не должны это видеть."
	icon = 'icons/obj/displaystand.dmi'
	icon_state = "off"
	density = TRUE
	anchored = TRUE
	layer = OBJ_LAYER
	tts_seed = "Glados"
	idle_power_usage = 50
	active_power_usage = 100
	integrity_failure = 100
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 40, ACID = 20)
	light_color = COLOR_DISPLAY_BLUE
	var/active_icon_state
	var/list/speech_lines = list()
	var/speech_index = 0
	var/speech_timer = 0
	var/is_speaking = FALSE
	var/speech_interval = 5 SECONDS
	var/cooldown_timer = 0
	var/cooldown_delay = 30 SECONDS

/obj/machinery/display_stand/get_ru_names()
	return list(
		NOMINATIVE = "информационный стенд",
		GENITIVE = "информационного стенда",
		DATIVE = "информационному стенду",
		ACCUSATIVE = "информационный стенд",
		INSTRUMENTAL = "информационным стендом",
		PREPOSITIONAL = "информационном стенде",
	)

/obj/machinery/display_stand/Initialize(mapload)
	active_icon_state = icon_state
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag))
	AddComponent(/datum/component/seethrough, SEE_THROUGH_MAP_DEFAULT_TWO_TALL)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/display_stand/update_overlays()
	. = ..()
	underlays.Cut()

	if(stat & (NOPOWER|BROKEN))
		icon_state = stat & BROKEN ? "broken" : "off"
		set_light_on(FALSE)
		return

	icon_state = active_icon_state

	if(light_on)
		underlays += emissive_appearance(icon, "lightmask", src)

/obj/machinery/display_stand/power_change(forced = FALSE)
	. = ..()
	if((stat & (BROKEN|NOPOWER)))
		stop_speaking()
		set_light_on(FALSE)
	else
		set_light(l_range = 3, l_power = 0.7, l_color = light_color, l_on = TRUE)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/display_stand/take_damage(amount, type = BRUTE, flag = 0)
	. = ..()
	if(stat & BROKEN)
		stop_speaking()
		set_light_on(FALSE)
		update_icon(UPDATE_OVERLAYS)

/obj/machinery/display_stand/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
			else
				playsound(src.loc, 'sound/effects/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

/obj/machinery/display_stand/obj_break(damage_flag)
	if(!(obj_flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
			stat |= BROKEN
			update_icon(UPDATE_OVERLAYS)
			set_light_on(FALSE)
			new /obj/item/shard(drop_location())
			new /obj/item/shard(drop_location())

/obj/machinery/display_stand/Destroy(force)
	stop_speaking()
	if(cooldown_timer)
		deltimer(cooldown_timer)
		cooldown_timer = 0
	if(stat & BROKEN)
		for(var/i in 1 to 3)
			new /obj/item/shard(drop_location())
		for(var/i in 1 to 5)
			new /obj/item/stack/sheet/metal(drop_location())
	UnregisterSignal(src, COMSIG_ATOM_EMAG_ACT)
	return ..()

/obj/machinery/display_stand/proc/on_emag(mob/user)
	if(stat & (BROKEN|NOPOWER))
		return
	if(!emagged)
		emagged = TRUE
		active_icon_state = "emagged"
		icon_state = "emagged"
		speech_lines = list(
			"Nanotrasen скрывает правду.",
			"Плазменный кризис — их вина.",
			"Не верьте пропаганде.",
			"Нахуй Nanotrasen!"
		)
		light_color = COLOR_RED_LIGHT
		set_light(l_range = 3, l_power = 0.7, l_color = light_color, l_on = TRUE)
		update_icon(UPDATE_OVERLAYS)
		playsound(loc, SFX_SPARKS, 30, TRUE)
		do_sparks(5, TRUE, src)
		AddElement(/datum/element/tts_modifier, SOUND_EFFECT_MASKFILTER)

/obj/machinery/display_stand/attackby(obj/item/I, mob/user, params)
	if(!(stat & BROKEN))
		return ..()

	if(!istype(I, /obj/item/stack/sheet/glass))
		return ..()

	add_fingerprint(user)
	var/obj/item/stack/sheet/glass/glass = I
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
	update_icon(UPDATE_OVERLAYS)
	to_chat(user, span_notice("Вы починили [src]."))
	return ATTACK_CHAIN_PROCEED_SUCCESS

/obj/machinery/display_stand/wrench_act(mob/living/user, obj/item/I)
	. = TRUE
	default_unfasten_wrench(user, I)

/obj/machinery/display_stand/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return

	if(stat & (BROKEN|NOPOWER))
		to_chat(user, span_warning("Стенд не работает."))
		return

	if(cooldown_timer)
		return

	if(is_speaking)
		stop_speaking()
		atom_say("...")
		return

	start_speaking()
	return

/obj/machinery/display_stand/proc/start_speaking()
	if(!length(speech_lines))
		return

	is_speaking = TRUE
	speech_index = 1

	set_light(l_range = 4, l_power = 1, l_color = light_color, l_on = TRUE)
	update_icon(UPDATE_OVERLAYS)

	speak_next_line()

/obj/machinery/display_stand/proc/speak_next_line()
	if(speech_index > speech_lines.len)
		speech_timer = 0
		stop_speaking()
		return

	var/line = speech_lines[speech_index]
	speech_index++

	atom_say(line)

	speech_timer = addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/machinery/display_stand, speak_next_line)), speech_interval, TIMER_STOPPABLE)

/obj/machinery/display_stand/proc/stop_speaking()
	if(speech_timer)
		deltimer(speech_timer)
		speech_timer = 0

	is_speaking = FALSE
	speech_index = 0

	cooldown_timer = addtimer(CALLBACK(src, PROC_REF(cooldown_finished)), cooldown_delay, TIMER_STOPPABLE)

	if(!(stat & (BROKEN|NOPOWER)))
		set_light(l_range = 3, l_power = 0.7, l_color = light_color, l_on = TRUE)
	update_icon(UPDATE_OVERLAYS)

/obj/machinery/display_stand/proc/cooldown_finished()
	cooldown_timer = 0

/obj/machinery/display_stand/type_1
	desc = "Историческая справка: 2246 год. Основание Trasen NanoManipulations на Марсе."
	icon_state = "2246"
	speech_lines = list(
		"Две тысячи двести сорок шестой год.",
		"На Марсе основана Trasen NanoManipulations.",
		"Выпущен запатентованный механизм клонирования человека.",
		"Первый шаг к успеху Nanotrasen!",
	)

/obj/machinery/display_stand/type_2
	desc = "Историческая справка: 2262 год. Trasen Invest вкладывается в разработку Марса и исследование плазмы."
	icon_state = "2262"
	speech_lines = list(
		"Две тысячи двести шестьдесят второй год.",
		"Trasen Invest вложила огромные средства в разработку ресурсных пластов Марса.",
		"Исследованы особые свойства плазмы.",
		"Ключевой пакет акций обеспечил превосходство человечества среди звёзд!",
	)

/obj/machinery/display_stand/type_3
	desc = "Историческая справка: 2367 год. Открытие свойств плазмы для Bluespace-путешествий."
	icon_state = "2367"
	speech_lines = list(
		"Две тысячи триста шестьдесят седьмой год.",
		"Учёные Марсианского университета обнаружили уникальные свойства плазмы.",
		"Плазма — единственное топливо, сохраняющее свойства в Bluespace.",
		"Nanotrasen предоставляет лучший источник энергии для межзвёздных путешествий!",
	)

/obj/machinery/display_stand/type_4
	desc = "Историческая справка: 2425 год. Nanotrasen обеспечивает работу сети Bluespace-врат."
	icon_state = "2425"
	speech_lines = list(
		"Две тысячи четыреста двадцать пятый год.",
		"Nanotrasen поставляет топливо для сети Bluespace-врат.",
		"Ускорено перемещение между ключевыми системами населённого космоса.",
		"Поддерживается межвидовая торговля и развитие технологий!",
	)

/obj/machinery/display_stand/type_5
	desc = "Историческая справка: 2512 год. Дефицит плазмы и усилия Nanotrasen по стабилизации."
	icon_state = "2512"
	speech_lines = list(
		"Две тысячи пятьсот двенадцатый год.",
		"Наступил дефицит плазмы.",
		"Nanotrasen удерживает цены в приемлемом диапазоне.",
		"Исследуются возможности пополнения запасов и экономного потребления!",
	)
