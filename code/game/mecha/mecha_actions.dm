/obj/mecha
	//Action datums
	var/datum/action/innate/mecha/mech_eject/eject_action = new
	var/datum/action/innate/mecha/mech_toggle_internals/internals_action = new
	var/datum/action/innate/mecha/mech_toggle_lights/lights_action = new
	var/datum/action/innate/mecha/mech_view_stats/stats_action = new
	var/datum/action/innate/mecha/mech_defence_mode/defense_action = new
	var/datum/action/innate/mecha/mech_overload_mode/overload_action = new
	var/datum/action/innate/mecha/mech_toggle_thrusters/thrusters_action = new
	var/datum/effect_system/fluid_spread/smoke/smoke_system = new //not an action, but trigged by one
	var/datum/action/innate/mecha/mech_smoke/smoke_action = new
	var/datum/action/innate/mecha/mech_zoom/zoom_action = new
	var/datum/action/innate/mecha/mech_toggle_phasing/phasing_action = new
	var/datum/action/innate/mecha/mech_switch_damtype/switch_damtype_action = new
	var/datum/action/innate/mecha/mech_energywall/energywall_action = new
	var/datum/action/innate/mecha/mech_strafe/strafe_action = new
	var/list/module_actions = list()

/obj/mecha/proc/GrantActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Grant(user, src)
	internals_action.Grant(user, src)
	lights_action.Grant(user, src)
	stats_action.Grant(user, src)
	if(strafe_allowed)
		strafe_action.Grant(user, src)
	for(var/obj/item/mecha_parts/mecha_equipment/equipment_mod in equipment)
		equipment_mod.give_targeted_action()

/obj/mecha/proc/RemoveActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Remove(user)
	internals_action.Remove(user)
	lights_action.Remove(user)
	stats_action.Remove(user)
	if(strafe_allowed)
		strafe_action.Remove(user)
	for(var/obj/item/mecha_parts/mecha_equipment/equipment_mod in equipment)
		equipment_mod.remove_targeted_action()

/datum/action/innate/mecha
	check_flags = AB_CHECK_HANDS_BLOCKED|AB_CHECK_CONSCIOUS|AB_CHECK_INCAPACITATED
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/mecha/chassis

/datum/action/innate/mecha/Grant(mob/living/L, obj/mecha/M)
	if(M)
		chassis = M
	. = ..()

/datum/action/innate/mecha/Destroy()
	chassis = null
	return ..()

/datum/action/innate/mecha/mech_eject
	name = "Выйти из меха"
	button_icon_state = "mech_eject"

/datum/action/innate/mecha/mech_eject/Activate()
	if(!owner)
		return
	if(!chassis || chassis.occupant != owner)
		return
	chassis.go_out()

/datum/action/innate/mecha/mech_toggle_internals
	name = "Переключить баллон"
	desc = "Переключает подачу воздуха из внутреннего баллона, защищая от вакуума и разреженной атмосферы."
	button_icon_state = "mech_internals_off"

/datum/action/innate/mecha/mech_toggle_internals/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.use_internal_tank = !chassis.use_internal_tank
	button_icon_state = "mech_internals_[chassis.use_internal_tank ? "on" : "off"]"
	chassis.occupant_message("Теперь воздух поступает [chassis.use_internal_tank ? "из внутреннего баллона" : "из окружающей среды"].")
	chassis.log_message("Источник воздуха изменён на [chassis.use_internal_tank ? "внутренний баллон" : "внешнюю среду"].")
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_lights
	name = "Переключить прожектор"
	desc = "Переключает мощный осветительный модуль."
	button_icon_state = "mech_lights_off"

/datum/action/innate/mecha/mech_toggle_lights/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.lights = !chassis.lights
	if(chassis.lights)
		chassis.set_light(chassis.lights_power, null, chassis.lights_color, l_on = TRUE)
		button_icon_state = "mech_lights_on"
	else
		chassis.set_light(-chassis.lights_power, l_on = TRUE)
		button_icon_state = "mech_lights_off"
	chassis.occupant_message("Прожектор [chassis.lights ? "включен" : "выключен"].")
	chassis.log_message("Прожектор [chassis.lights ? "включен" : "выключен"].")
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_view_stats
	name = "Панель управления"
	button_icon_state = "mech_view_stats"

/datum/action/innate/mecha/mech_view_stats/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/datum/browser/popup = new(chassis.occupant, "exosuit", "[chassis.name]")
	popup.include_default_stylesheet = FALSE
	popup.set_content(chassis.get_stats_html())
	popup.add_script("byjax", 'html/js/byjax.js')
	popup.add_script("dropdown", 'html/js/dropdowns.js')
	chassis.config_dropdown(popup)
	popup.open(FALSE)

/datum/action/innate/mecha/mech_defence_mode
	name = "Режим защиты"
	desc = "Активирует усиленное бронирование, снижая урон, но ограничивая подвижность."
	button_icon_state = "mech_defense_mode_off"

/datum/action/innate/mecha/mech_defence_mode/Activate(forced_state = null)
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(!isnull(forced_state))
		chassis.defence_mode = forced_state
	else
		chassis.defence_mode = !chassis.defence_mode
	button_icon_state = "mech_defense_mode_[chassis.defence_mode ? "on" : "off"]"
	if(chassis.defence_mode)
		chassis.deflect_chance = chassis.defence_mode_deflect_chance
		chassis.occupant_message(span_notice("[chassis.declent_ru(NOMINATIVE)]: Режим защиты активирован."))
		chassis.set_anchored(TRUE)
		RegisterSignal(chassis, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(Activate))
	else
		UnregisterSignal(chassis, COMSIG_MOVABLE_SET_ANCHORED)
		chassis.deflect_chance = initial(chassis.deflect_chance)
		chassis.occupant_message(span_danger("[chassis.declent_ru(NOMINATIVE)]: Режим защиты деактивирован."))
		chassis.set_anchored(FALSE)
	chassis.log_message("Переключение режима защиты.")
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_overload_mode
	name = "Режим перегрузки"
	desc = "Запуск форсаж приводов. Скорость увеличивается, но шасси быстро изнашивается."
	button_icon_state = "mech_overload_off"

/datum/action/innate/mecha/mech_overload_mode/Activate(forced_state = null)
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.obj_integrity < chassis.max_integrity - chassis.max_integrity / 3)
		chassis.occupant_message(span_danger("Шасси слишком повреждено для разгона!"))
		return // Can't activate them if the mech is too damaged
	if(!isnull(forced_state))
		chassis.leg_overload_mode = forced_state
	else
		chassis.leg_overload_mode = !chassis.leg_overload_mode
	button_icon_state = "mech_overload_[chassis.leg_overload_mode ? "on" : "off"]"
	chassis.log_message("Активирована перегрузка приводов шасси.")
	if(chassis.leg_overload_mode)
		chassis.leg_overload_mode = 1
		// chassis.bumpsmash = 1
		chassis.step_in = min(1, round(chassis.step_in / 2))
		chassis.step_energy_drain = max(chassis.overload_step_energy_drain_min, chassis.step_energy_drain * chassis.leg_overload_coeff)
		chassis.occupant_message(span_danger("[chassis.declent_ru(NOMINATIVE)]: Режим перегрузки включен."))
	else
		chassis.leg_overload_mode = 0
		// chassis.bumpsmash = 0
		chassis.step_in = initial(chassis.step_in)
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		chassis.occupant_message(span_notice("[chassis.declent_ru(NOMINATIVE)]: Режим перегрузки выключен."))
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_thrusters
	name = "Маневровые двигатели"
	button_icon_state = "mech_thrusters_off"

/datum/action/innate/mecha/mech_toggle_thrusters/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.get_charge() > 0)
		chassis.thrusters_active = !chassis.thrusters_active
		button_icon_state = "mech_thrusters_[chassis.thrusters_active ? "on" : "off"]"
		chassis.log_message("Переключение маневровых двигателей.")
		chassis.occupant_message("<font color='[chassis.thrusters_active ? "blue" : "red"]'>Двигатели [chassis.thrusters_active ? "активны" : "отключены"].</font>")
	if(chassis.thrusters_active)
		chassis.icon_state = "[chassis.icon_state]-thruster"
	else
		chassis.icon_state = splittext(chassis.icon_state, "-")[1]

/datum/action/innate/mecha/mech_smoke
	name = "Дым"
	button_icon_state = "mech_smoke"

/datum/action/innate/mecha/mech_smoke/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.smoke_ready && chassis.smoke > 0)
		chassis.smoke_system.start()
		chassis.smoke--
		chassis.smoke_ready = FALSE
		addtimer(CALLBACK(chassis, TYPE_PROC_REF(/obj/mecha, set_smoke_ready)), chassis.smoke_cooldown)
	else
		chassis.occupant_message(span_warning("У вас либо закончился дым, либо он еще не готов."))

/datum/action/innate/mecha/mech_zoom
	name = "Приближение"
	button_icon_state = "mech_zoom_off"

/datum/action/innate/mecha/mech_zoom/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(owner.client)
		chassis.zoom_mode = !chassis.zoom_mode
		button_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
		chassis.log_message("Режим приближения переключён.")
		chassis.occupant_message("<font color='[chassis.zoom_mode ? "blue" : "red"]'>Приближение [chassis.zoom_mode ? "вкл" : "выкл"].</font>")
		if(chassis.zoom_mode)
			owner.client.AddViewMod("mecha", 12)
			SEND_SOUND(owner, sound(chassis.zoomsound, volume = 50))
		else
			owner.client.RemoveViewMod("mecha")
		UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_phasing
	name = "Фазовый переход"
	desc = "Позволяет проходить сквозь стены и объекты."
	button_icon_state = "mech_phasing_off"

/datum/action/innate/mecha/mech_toggle_phasing/Activate()
	if(!owner || !chassis || chassis.occupant != owner || !is_teleport_allowed(chassis.z))
		return
	chassis.phasing = !chassis.phasing
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.occupant_message("<font color=\"[chassis.phasing ? "#00f\">Фазовый переход вкл" : "#f00\">Фазовый переход выкл"]</font>")
	UpdateButtonIcon()


/datum/action/innate/mecha/mech_switch_damtype
	name = "Смена инструментов"
	button_icon_state = "mech_damtype_brute"

/datum/action/innate/mecha/mech_switch_damtype/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/new_damtype
	switch(chassis.damtype)
		if("tox")
			new_damtype = "brute"
			chassis.occupant_message("Руки экзокостюма сжимаются в кулаки.")
		if("brute")
			new_damtype = "fire"
			chassis.occupant_message("Из руки выдвигается раскалённый резак.")
		if("fire")
			new_damtype = "tox"
			chassis.occupant_message("Из ладони выдвигается леденящая кровь пласталевая игла.")
	chassis.damtype = new_damtype
	button_icon_state = "mech_damtype_[new_damtype]"
	playsound(src, 'sound/mecha/mechmove01.ogg', 50, 1)
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_energywall
	name = "Энергостена"
	button_icon_state = "energywall"

/datum/action/innate/mecha/mech_energywall/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.wall_ready)
		new chassis.wall_type(get_turf(chassis), chassis)
		if(chassis.large_wall)
			if(chassis.dir == SOUTH || chassis.dir == NORTH)
				new chassis.wall_type(get_step(chassis, EAST), chassis)
				new chassis.wall_type(get_step(chassis, WEST), chassis)
			else
				new chassis.wall_type(get_step(chassis, NORTH), chassis)
				new chassis.wall_type(get_step(chassis, SOUTH), chassis)
		chassis.wall_ready = FALSE
		addtimer(CALLBACK(chassis, TYPE_PROC_REF(/obj/mecha, set_wall_ready)), chassis.wall_cooldown)
	else
		chassis.occupant_message(span_warning("Энергостена ещё не готова!"))

/////////////////////////////////// STRAFE PROCS ////////////////////////////////////////////////
/datum/action/innate/mecha/mech_strafe
	name = "Боковое движение"
	desc = "Переключает режим бокового движения. Отключается при зажатом Alt."
	button_icon_state = "strafe"

/datum/action/innate/mecha/mech_strafe/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.toggle_strafe()

/obj/mecha/click_alt(mob/living/user) //Strafing is toggled by interface button or by Alt-clicking on mecha
	if(!occupant || occupant != user)
		return
	toggle_strafe()
	return CLICK_ACTION_SUCCESS

/**
 * Proc that toggles strafe mode of the mecha ON/OFF
 *
 * Arguments
 * * silent - if we want to stop showing messages for mecha pilot and prevent logging
 */
/obj/mecha/proc/toggle_strafe(silent = FALSE)
	if(!strafe_allowed)
		occupant_message("Этот мех не поддерживает боковое движение!")
		return
	var/datum/action/innate/mecha/mech_strafe/mech_strafe = locate(/datum/action/innate/mecha/mech_strafe) in occupant.actions
	if(!mech_strafe)
		return
	strafe = !strafe
	mech_strafe.button_icon_state = "strafe[strafe ? "_on" : ""]"
	mech_strafe.UpdateButtonIcon()
	if(!silent)
		occupant_message("<font color='[strafe ? "green" : "red"]'>Боковое движение [strafe ? "вкл" : "выкл"].")
		log_message("Боковое движение [strafe ? "вкл" : "выкл"].")

/datum/action/innate/mecha/select_module
	name = "Hey, you shouldn't see it"
	var/obj/item/mecha_parts/mecha_equipment/equipment

/datum/action/innate/mecha/select_module/Grant(mob/living/L, obj/mecha/M, obj/item/mecha_parts/mecha_equipment/_equipment)
	if(!_equipment)
		return FALSE
	equipment = _equipment
	name = "Переключить модуль на [equipment.declent_ru(ACCUSATIVE)]"
	icon_icon = equipment.icon
	button_icon_state = equipment.icon_state
	. = ..()

/datum/action/innate/mecha/select_module/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	equipment.select_module()
/datum/action/innate/mecha/toggle_module
	var/obj/item/mecha_parts/mecha_equipment/equipment

/datum/action/innate/mecha/toggle_module/Grant(mob/living/L, obj/mecha/M, obj/item/mecha_parts/mecha_equipment/_equipment)
	if(!_equipment)
		return FALSE
	equipment = _equipment
	name = "Переключить модуль [equipment.declent_ru(ACCUSATIVE)]"
	icon_icon = equipment.icon
	button_icon_state = equipment.icon_state
	. = ..()

/datum/action/innate/mecha/toggle_module/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	equipment.toggle_module()
