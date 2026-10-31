// MARK: Basic spacepod
/obj/spacepod
	name = "not complete spacepod"
	desc = "Незавершенный космический челнок."
	icon = 'icons/goonstation/48x48/pods.dmi'
	icon_state = "pod_civ"
	density = TRUE
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	move_force = MOVE_FORCE_VERY_STRONG
	resistance_flags = ACID_PROOF
	movement_type = FLYING
	layer = BEHIND_MOB_LAYER
	infra_luminosity = 15

	/// Current pilot
	var/mob/living/pilot = null
	/// List of passengers into pod
	var/list/mob/passengers = list()
	/// Maximum of passengers count
	var/max_passengers = 0
	/// Cabin internal storage
	var/obj/item/storage/internal/cargo_hold

	/// Internal pod system
	var/datum/spacepod_systems/systems = null

	/// Air in cabin
	var/datum/gas_mixture/cabin_air
	/// Air tank for cabin
	var/obj/machinery/portable_atmospherics/canister/internal_tank

	/// Frame integrity
	max_integrity = 300
	/// Enable external lights
	var/lights = FALSE
	/// External lights power
	var/lights_power = 6
	/// Pod door unlocked flag
	var/unlocked = TRUE
	/// Complete assembly flag
	var/assemble_process = TRUE
	/// Hant state flag
	var/hatch_opened = FALSE

	/// Movement speed coefficient (use smaller value for higher speed)
	var/pod_speed_coeff = POD_SPEED_COEFF
	/// Movement cooldown
	COOLDOWN_DECLARE(spacepod_move_cooldown)
	/// Ion trail effect
	var/datum/effect_system/trail_follow/spacepod/ion_trail

	// Actions
	var/datum/action/innate/pod/pod_eject/eject_action = new
	var/datum/action/innate/pod/pod_panel/panel_action = new
	var/datum/action/innate/pod/misc/misc_action = new
	/// list of passengers actions (one list by one passenger)
	var/alist/passangers_actions = new

	// tgui
	var/datum/ui_module/spacepod_control_panels/control_panels

	/// Weapon balloon alert cooldown
	COOLDOWN_DECLARE(weapon_balloon_cooldown)
	/// Repairing spacepod flag
	var/repairing = FALSE

/obj/spacepod/get_ru_names()
	return alist(
		NOMINATIVE = "космический челнок",
		GENITIVE = "космического челнока",
		DATIVE = "космическому челноку",
		ACCUSATIVE = "космический челнок",
		INSTRUMENTAL = "космическим челноком",
		PREPOSITIONAL = "космическом челноке",
	)

/obj/spacepod/Initialize(mapload)
	. = ..()
	bound_width = 64
	bound_height = 64
	create_internal_system()
	add_cabin()
	add_airtank()
	GLOB.spacepods_list += src
	cargo_hold = new/obj/item/storage/internal(src)
	cargo_hold.w_class = 5 //so you can put bags in
	cargo_hold.storage_slots = 4
	cargo_hold.max_w_class = 5
	cargo_hold.max_combined_w_class = 14
	START_PROCESSING(SSobj, src)
	ion_trail = new
	ion_trail.set_up(src)
	ion_trail.start()
	control_panels = new()
	control_panels.pod = src

/obj/spacepod/proc/create_internal_system()
	systems = new()
	systems.pod = src
	return systems

/obj/spacepod/proc/add_cabin()
	cabin_air = new
	cabin_air.set_temperature(T20C)
	cabin_air.volume = 200
	cabin_air.set_oxygen(O2STANDARD * cabin_air.volume / (R_IDEAL_GAS_EQUATION * cabin_air.temperature()))
	cabin_air.set_nitrogen(N2STANDARD * cabin_air.volume / (R_IDEAL_GAS_EQUATION * cabin_air.temperature()))
	return cabin_air

/obj/spacepod/proc/add_airtank()
	internal_tank = new /obj/machinery/portable_atmospherics/canister/air(src)
	return internal_tank

/obj/spacepod/Destroy()
	if(pilot)
		eject_pilot()
	if(passengers)
		for(var/mob/passenger in passengers)
			eject_passenger(passenger)
	QDEL_NULL(cargo_hold)
	QDEL_NULL(systems)
	QDEL_NULL(cabin_air)
	QDEL_NULL(internal_tank)
	QDEL_NULL(ion_trail)
	QDEL_NULL(eject_action)
	QDEL_NULL(panel_action)
	QDEL_NULL(misc_action)
	QDEL_NULL(control_panels)
	occupant_sanity_check()

	GLOB.spacepods_list -= src
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/spacepod/examine(mob/user)
	. = ..()
	if(assemble_process)
		. += span_notice("Сборка пода не завершена.")
		var/list/errors = systems.check_complete()
		if(length(errors) > 0)
			for(var/error_msg in errors)
				. += error_msg
			return
		. += span_notice("Для завершения сборки используйте мультитул.")

	if(hatch_opened)
		. += span_notice("Люк техобслуживания открыт.")


// MARK: Assemble procs
/obj/spacepod/multitool_act(mob/living/user, obj/item/tool)
	if(!assemble_process)
		return ..()
	. = TRUE
	var/list/assemble_errors = systems.check_complete()
	if(length(assemble_errors) > 0)
		to_chat(user, span_warning("Сборка не завершена, осмотрите челнок чтобы узнать какие детали отсутствуют для завершения сборки."))
		return
	var/new_name = tgui_input_text(user, "Название челнока", "Задать название челнока", default = name, max_length = MAX_NAME_LEN, encode = TRUE)
	if(length(new_name) == 0 || !assemble_process)
		return
	var/new_desc = tgui_input_text(user, "Описание челнока", "Задать описание челнока", default = desc, max_length = MAX_MESSAGE_LEN, encode = TRUE)
	if(length(new_desc) == 0 || !assemble_process)
		return
	name = new_name
	desc = new_desc
	ru_names = alist(
		NOMINATIVE = "космический челнок \"[new_name]\"",
		GENITIVE = "космического челнока \"[new_name]\"",
		DATIVE = "космическому челноку \"[new_name]\"",
		ACCUSATIVE = "космический челнок \"[new_name]\"",
		INSTRUMENTAL = "космическим челноком \"[new_name]\"",
		PREPOSITIONAL = "космическом челноке \"[new_name]\"",
	)
	assemble_process = FALSE

/obj/spacepod/crowbar_act(mob/living/user, obj/item/tool)
	if(assemble_process)
		. = TRUE
		if(!length(systems.modules))
			return
		var/obj/item/spacepod_module/extracted_module = tgui_input_list(user, "Выберите модуль для удаления:", "Удаление модуля", systems.modules)
		if(extracted_module == null || extracted_module.systems == null)
			return
		systems.remove_module(src, extracted_module)
		extracted_module.forceMove(src.loc)
		to_chat(user, span_notice("Модуль [extracted_module.module_name] извлечен."))
		return

	if(!unlocked)
		balloon_alert(user, "замок закрыт")
		return ..()

	. = TRUE
	if(hatch_opened)
		hatch_opened = FALSE
		balloon_alert(user, "люк техобслуживания закрыт")
	else
		hatch_opened = TRUE
		balloon_alert(user, "люк техобслуживания открыт")


/obj/spacepod/welder_act(mob/living/user, obj/item/welder)
	if(user.a_intent == INTENT_HARM)
		return
	if(!assemble_process && !hatch_opened)
		return
	. = TRUE
	if(!welder.tool_use_check(user, 0))
		return
	if(obj_integrity >= max_integrity)
		balloon_alert(user, "челнок целый!")
		return
	if(repairing)
		balloon_alert(user, "челнок уже ремонтируется!")
		return
	WELDER_ATTEMPT_REPAIR_MESSAGE
	repairing = TRUE
	while(obj_integrity < max_integrity)
		if(!welder.use_tool(src, user, 15, volume = welder.tool_volume))
			break
		if(obj_integrity < max_integrity)
			user.visible_message(
				span_notice("[user] частично отремонтировал[GEND_A_O_I(user)] [name]."),
				span_notice("Вы частично отремонтировали [name].")
			)
			repair_damage(min(10, max_integrity - obj_integrity))

	if(obj_integrity >= max_integrity)
		balloon_alert(user, "челнок полностью отремонтирован!")
	repairing = FALSE

//MARK: attackby
/obj/spacepod/attackby(obj/item/item, mob/living/user, list/modifiers)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(item, /obj/item/spacepod_key))
		add_fingerprint(user)
		var/obj/item/spacepod_module/key_lock/key_lock = systems.get_misc_module(/obj/item/spacepod_module/key_lock)
		if(!key_lock)
			balloon_alert(user, "нет замка!")
			return ATTACK_CHAIN_PROCEED
		var/obj/item/spacepod_key/key = item
		if(key.id != key_lock.key_id)
			balloon_alert(user, "неправильный ключ!")
			return ATTACK_CHAIN_PROCEED
		toggle_lock(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(assemble_process && istype(item, /obj/item/spacepod_module))
		var/obj/item/spacepod_module/module_obj = item
		add_fingerprint(user)
		var/obj/item/spacepod_module/installed_module = module_obj.install_to(user, src)
		if(!installed_module)
			return ..()
		if(!user.drop_transfer_item_to_loc(item, src))
			return ..()
		systems.add_module(src, module_obj)
		to_chat(user, span_notice("Модуль [module_obj.module_name] установлен."))
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!hatch_opened)
		return ..()

	// attach gun
	if(isgun(item))
		var/list/weapons = systems.get_slot(SPACEPOD_MODULE_SLOT_WEAPON)
		for(var/obj/item/spacepod_module/weapon/weapon in weapons)
			if(!weapon.install_gun(item))
				continue
			if(!user.drop_transfer_item_to_loc(item, src))
				continue
			item.forceMove(src)
			update_icon(UPDATE_ICON_STATE)
			return ATTACK_CHAIN_BLOCKED_ALL
		return ..()

	// sitch to assemble mode
	if(ismultitool(item))
		to_chat(user, span_notice("Системы космического челнока переведены в режим сборки."))
		assemble_process = TRUE
		var/list/batteries = systems.get_slot(SPACEPOD_MODULE_SLOT_BATTERY)
		for(var/obj/item/spacepod_module/battery/batt as anything in batteries)
			if(!batt.connection_power_net || batt.power <= 0)
				continue
			// do not switch to assembly mod if your battery online!
			do_sparks(5, TRUE, src)
			user.electrocute_act(batt.power / 50, src)
			break

		return ATTACK_CHAIN_BLOCKED_ALL

	// refill fuel
	if(istype(item, /obj/item/tank/internals))
		var/obj/item/tank/internals/fuel_tank = item
		if(fuel_tank.air_contents.toxins() <= 0)
			to_chat(user, span_notice("Нет нужного топлива!"))
			return ATTACK_CHAIN_BLOCKED_ALL

		var/availableFuel = fuel_tank.air_contents.toxins() * POD_FUEL_COEFFICIENT
		var/last_fuel = systems.fill_fuel_tanks(availableFuel)
		fuel_tank.air_contents.set_toxins(last_fuel / POD_FUEL_COEFFICIENT)
		to_chat(user, span_notice("Заправлено [availableFuel - last_fuel] топлива из [availableFuel]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	// charge battery
	if(iscell(item))
		var/obj/item/stock_parts/cell/cell_item = item
		var/list/batteries = systems.get_slot(SPACEPOD_MODULE_SLOT_BATTERY)
		var/charged = FALSE
		for(var/obj/item/spacepod_module/battery/batt as anything in batteries)
			var/free_charge = batt.power_capacity - batt.power
			var/used_charge = min(cell_item.charge * POD_POWER_COEFFICIENT, free_charge)
			batt.power += used_charge
			cell_item.charge -= used_charge / POD_POWER_COEFFICIENT
			cell_item.update_appearance()
			to_chat(user, span_notice("Аккумуляторная батарея заряжена на [used_charge] Ватт."))
			charged = TRUE

		if(charged)
			return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/spacepod/proc/toggle_lock(mob/user)
	var/key_lock = systems.get_misc_module(/obj/item/spacepod_module/key_lock)
	if(!key_lock)
		return
	unlocked = !unlocked
	if(unlocked)
		balloon_alert(user, "замок открыт")
	else
		balloon_alert(user, "замок закрыт")


//MARK: Attack hand
#define ACTION_CARGO_ACCESS "Доступ к хранилищу"
#define ACTION_REMOVE_PRIMARY_WEAPON "Извлечь основное вооружение"
#define ACTION_REMOVE_SECONDARY_WEAPON "Извлечь дополнительное вооружение"

/obj/spacepod/attack_hand(mob/user)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(user.a_intent == INTENT_GRAB && unlocked)
		eject_any_occupant(user)

	if(hatch_opened)
		var/list/options = list()
		options += ACTION_CARGO_ACCESS
		var/list/weapons = systems.get_slot(SPACEPOD_MODULE_SLOT_WEAPON)
		for(var/obj/item/spacepod_module/weapon/weapon as anything in weapons)
			if(weapon.primary.weapon != null)
				options += ACTION_REMOVE_PRIMARY_WEAPON
			if(weapon.secondary.weapon != null)
				options += ACTION_REMOVE_SECONDARY_WEAPON

		var/choice = length(options) == 1 ? options[1] : tgui_input_list(user, "Что вы хотите сделать?", "Доступ к челноку через люк", options)
		if(!choice)
			return
		switch(choice)
			if(ACTION_CARGO_ACCESS)
				cargo_hold.open(user)
			if(ACTION_REMOVE_PRIMARY_WEAPON)
				for(var/obj/item/spacepod_module/weapon/weapon as anything in weapons)
					remove_gun_from_systems(user, weapon, weapon.primary.weapon)
			if(ACTION_REMOVE_SECONDARY_WEAPON)
				for(var/obj/item/spacepod_module/weapon/weapon as anything in weapons)
					remove_gun_from_systems(user, weapon, weapon.secondary.weapon)

#undef ACTION_CARGO_ACCESS
#undef ACTION_REMOVE_PRIMARY_WEAPON
#undef ACTION_REMOVE_SECONDARY_WEAPON

/obj/spacepod/proc/remove_gun_from_systems(mob/user, obj/item/spacepod_module/weapon/weapon, obj/item/gun/selected_gun)
	if(selected_gun == null)
		balloon_alert(user, "вооружение не установлено")
		return
	var/obj/item/gun/removed_gun = weapon.remove_gun(selected_gun)
	if(removed_gun == null)
		balloon_alert(user, "вооружение не установлено")
		return
	removed_gun.forceMove(src.loc)
	balloon_alert(user, "оружие извлечено!")


// MARK: Process (update)
/obj/spacepod/process(seconds_per_tick)
	systems.process_work(seconds_per_tick, src)

/obj/spacepod/proc/give_air()
	if(!internal_tank)
		return
	var/datum/gas_mixture/tank_air = internal_tank.return_obj_air()
	var/release_pressure = ONE_ATMOSPHERE
	var/cabin_pressure = cabin_air.return_pressure()
	var/pressure_delta = min(release_pressure - cabin_pressure, (tank_air.return_pressure() - cabin_pressure)/2)
	var/transfer_moles = 0
	if(pressure_delta > 0) //cabin pressure lower than release pressure
		if(tank_air.temperature() > 0)
			transfer_moles = pressure_delta * cabin_air.return_volume() / (cabin_air.temperature() * R_IDEAL_GAS_EQUATION)
			var/datum/gas_mixture/removed = tank_air.remove(transfer_moles)
			cabin_air.merge(removed)
		return

	//cabin pressure higher than release pressure
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/t_air = location.get_readonly_air()
	pressure_delta = cabin_pressure - release_pressure

	if(t_air)
		pressure_delta = min(cabin_pressure - t_air.return_pressure(), pressure_delta)

	if(pressure_delta <= 0) //if location pressure is lower than cabin pressure
		return

	transfer_moles = pressure_delta * cabin_air.return_volume() / (cabin_air.temperature() * R_IDEAL_GAS_EQUATION)
	var/datum/gas_mixture/removed = cabin_air.remove(transfer_moles)
	if(t_air)
		location.blind_release_air(removed)
	else //just delete the cabin gas, we're in space or some shit
		qdel(removed)

/obj/spacepod/proc/regulate_temp()
	if(cabin_air && cabin_air.return_volume() > 0)
		var/delta = cabin_air.temperature() - T20C
		cabin_air.set_temperature(max(0, cabin_air.temperature() - max(-10, min(10, round(delta / 4, 0.1)))))


// MARK: Passenger procs
/obj/spacepod/AllowDrop()
	return TRUE

/obj/spacepod/mouse_drop_receive(mob/living/dropping, mob/living/user, params)
	if(user == pilot || (user in passengers) || !isliving(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	// if(isobj(dropping))
	// 	load_cargo(user, dropping)
	// 	return

	if(!isliving(dropping))
		return

	occupant_sanity_check()

	if(dropping == user)
		enter_pod(user)
		return

	if(!unlocked)
		to_chat(user, span_danger(span_bold("Люк закрыт!")))
		return

	if(length(passengers) >= max_passengers)
		to_chat(user, span_danger(span_bold("Все пассажирские места заняты!")))
		return

	visible_message(span_danger("[user.name] начина[PLUR_ET_YUT(user)] загрузку [dropping.declent_ru(GENITIVE)] в челнок!"))
	if(!do_after(user, POD_OCCUPANT_INSERT_DURATION, dropping))
		return

	if(length(passengers) >= max_passengers)
		to_chat(user, span_danger(span_bold("Все пассажирские места заняты!")))
		return

	moved_other_inside(dropping)


/obj/spacepod/force_eject_occupant(mob/target)
	if(target == pilot)
		eject_pilot()
	else
		eject_passenger(target)

/obj/spacepod/proc/eject_pilot()
	pilot.forceMove(get_turf(src))
	remove_pilot_actions(pilot)
	control_panels.ui_close(pilot)
	pilot = null

/obj/spacepod/proc/eject_passenger(mob/living/passenger)
	passenger.forceMove(get_turf(src))
	remove_passenger_actions(passenger)
	passengers -= passenger

/obj/spacepod/proc/eject_any_occupant(mob/user)
	var/mob/living/target
	if(pilot)
		target = pilot
	else if(length(passengers) > 0)
		target = passengers[1]

	if(!istype(target))
		return
	src.visible_message(
		span_warning("[user] пыта[PLUR_ET_YUT(user)]ся открыть дверь и вытащить [target] из [declent_ru(GENITIVE)]!"),
		span_warning("Вы видите, как [user] пыта[PLUR_ET_YUT(user)]ся открыть дверь!")
	)
	if(!do_after(user, POD_OCCUPANT_EJECT_DURATION, src))
		target.visible_message(
			span_warning("[user] не смог[PLUR_LI(user)] открыть дверь!"),
			span_warning("Вы не дали [user] проникнуть в [declent_ru(NOMINATIVE)]!")
		)
		return

	target.Knockdown(3 SECONDS)
	if(pilot)
		eject_pilot()
	else
		eject_passenger(target)
	target.visible_message(
		span_warning("[user] распахива[PLUR_ET_YUT(user)] дверь и доста[PLUR_YOT_YUT(user)] [target] из [declent_ru(GENITIVE)]!"),
		span_warning("Дверь распахивается, и вас выбрасывает на пол!")
	)

/obj/spacepod/proc/moved_other_inside(mob/living/carbon/human/target)
	occupant_sanity_check()
	if(length(passengers) >= max_passengers)
		return

	target.forceMove(src)
	passengers += target
	target.forceMove(src)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
	return TRUE


/obj/spacepod/proc/enter_pod(mob/user)
	if(!ishuman(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return FALSE

	if(!unlocked)
		balloon_alert(user, "двери заблокированы!")
		return FALSE

	if(get_dist(src, user) > 2)
		balloon_alert(user, "слишком далеко!")
		return FALSE

	var/has_nuke_auth_disk = user.get_type_in_all_contents(/obj/item/disk/nuclear)
	if(has_nuke_auth_disk)
		to_chat(user, span_danger(span_bold("Диск ядерной аутентификации блокирует двери! Похоже, он не хочет попасть в челнок.")))
		return FALSE

	if(user.has_buckled_mobs()) //mob attached to us
		to_chat(user, span_warning("[user] не поместится в [declent_ru(ACCUSATIVE)] из-за прикреплённых существ!"))
		return FALSE

	move_inside(user)
	return TRUE

/obj/spacepod/proc/move_inside(mob/living/user)
	if(!istype(user))
		log_debug("SHIT'S GONE WRONG WITH THE SPACEPOD [src] AT [x], [y], [z], AREA [get_area(src)], TURF [get_turf(src)]")
		return

	occupant_sanity_check()
	if(length(passengers) >= max_passengers && pilot != null)
		balloon_alert(user, "нет места!")
		return

	visible_message(span_notice("[user] начина[PLUR_ET_YUT(user)] забираться в [declent_ru(ACCUSATIVE)]."))
	if(!do_after(user, POD_ENTER_DURATION, src))
		balloon_alert(user, "посадка отменена")
		return

	if(!pilot || pilot == null)
		pilot = user
		user.forceMove(src)
		grant_pilot_actions(user)
		add_fingerprint(user)
		playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
		return

	if(length(passengers) < max_passengers)
		passengers += user
		user.forceMove(src)
		grant_passenger_actions(user)
		add_fingerprint(user)
		playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
	else
		to_chat(user, span_notice("Вы слишком медлили. В следующий раз будьте быстрее."))

/obj/spacepod/proc/occupant_sanity_check()  // going to have to adjust this later for cargo refactor
	if(!passengers)
		return
	if(length(passengers) > max_passengers)
		for(var/i = length(passengers); i >= max_passengers; i--)
			var/mob/occupant = passengers[i - 1]
			occupant.forceMove(get_turf(src))
			log_debug("##SPACEPOD WARNING: passengers EXCEED CAP: MAX passengers [max_passengers], passengers [english_list(passengers)], TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
			passengers[i - 1] = null

	for(var/mob/passenger in passengers)
		if(!ismob(passenger))
			passenger.forceMove(get_turf(src))
			log_debug("##SPACEPOD WARNING: NON-MOB OCCUPANT [passenger], TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
			passengers -= passenger
		else if(passenger.loc != src)
			log_debug("##SPACEPOD WARNING: OCCUPANT [passenger] ESCAPED, TURF [get_turf(src)] | AREA [get_area(src)] | COORDS [x], [y], [z]")
			passengers -= passenger

/obj/spacepod/proc/exit_pod(mob/user)
	if(user.stat != CONSCIOUS) // unconscious people can't let themselves out
		return

	occupant_sanity_check()

	if(HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		to_chat(user, span_notice("Вы пытаетесь выбраться из [declent_ru(GENITIVE)]. Это займет две минуты."))
		if(pilot && pilot != user)
			to_chat(pilot, span_warning("[user] пытается выбраться из [declent_ru(GENITIVE)]."))
		if(!do_after(user, 2 MINUTES, src))
			return

	if(user == pilot)
		eject_pilot()
	else if(user in passengers)
		eject_passenger(user)

	to_chat(user, span_notice("Вы выбрались из [declent_ru(GENITIVE)]."))

/obj/spacepod/proc/catapult_pilot(force = FALSE)
	if(!pilot)
		return

	var/obj/item/spacepod_module/catapult_module/catapult = systems.get_misc_module(/obj/item/spacepod_module/catapult_module)
	if(!catapult || (!force && !catapult.enable))
		return
	var/mob/pilot_user = pilot
	eject_pilot()
	var/opposite_dir = dir ^ (NORTH|SOUTH|EAST|WEST)
	//var/atom/target = get_edge_target_turf(src, opposite_dir)
	var/turf/target = get_distant_turf(get_turf(src), opposite_dir, 7)
	var/turf/start = get_distant_turf(get_turf(src), opposite_dir, 1)
	pilot_user.loc = start
	pilot_user.throw_at(target, 4, 2, src, TRUE, FALSE)

// MARK: Attack procs
/obj/spacepod/proc/click_action(atom/target, mob/user, list/modifiers)
	var/list/weapons = systems.get_slot(SPACEPOD_MODULE_SLOT_WEAPON)
	if(!length(weapons))
		return // weapons not installed

	if(user != pilot)
		return // only pilot can fire from weapons

	var/obj/item/spacepod_module/weapon/weapon = weapons[1] // can fire only from first weapon
	if(!weapon.connection_power_net || !weapon.enable)
		return // weapon module offline

	var/datum/spacepod_weapon_slot/selected_gun = null
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		selected_gun = weapon.secondary
	else
		selected_gun = weapon.primary

	if(selected_gun == null)
		return // selected gun not exists
	if(selected_gun.safety)
		if(COOLDOWN_FINISHED(src, weapon_balloon_cooldown))
			balloon_alert(user, "оружие на предохранителе!")
			COOLDOWN_START(src, weapon_balloon_cooldown, 1 SECONDS)

		return
	if(selected_gun.charging)
		if(COOLDOWN_FINISHED(src, weapon_balloon_cooldown))
			balloon_alert(user, "оружие заряжается!")
			COOLDOWN_START(src, weapon_balloon_cooldown, 1 SECONDS)
		return

	selected_gun.weapon.fast_fire(target, user)


// MARK: Damage
/obj/spacepod/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	if(damage_type != BRUTE && damage_type != BURN)
		// ignore other damage types, only brute or burn
		return ..(0, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)

	// damage modules, and return remaining damage to frame
	damage_amount = systems.damage_modules(damage_amount)
	. = ..(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)

/obj/spacepod/obj_destruction(damage_flag)
	catapult_pilot()
	var/turf/location = get_turf(src)
	var/list/badlist = list(internal_tank, cargo_hold)
	var/list/true_contents = (contents + cargo_hold.contents) - badlist
	for(var/obj/item in true_contents)
		item.loc = location
		item.random_throw(range_low = 1)
		if(istype(item, /obj/item/spacepod_module))
			var/obj/item/spacepod_module/module = item
			module.deal_damage(rand(5, 100))
			systems.remove_module(src, module)
	. = ..()
	explosion(location, devastation_range = 0, heavy_impact_range = 1, light_impact_range = 2, cause = "Spacepod destroy")


// MARK: Environment
/obj/spacepod/return_obj_air()
	RETURN_TYPE(/datum/gas_mixture)
	var/obj/item/spacepod_module/life_support/life_supports = systems.get_misc_module(/obj/item/spacepod_module/life_support)
	if(life_supports && life_supports.enable)
		return cabin_air
	return null

/obj/spacepod/proc/play_sound_to_riders(mysound)
	if(length(passengers | pilot) == 0)
		return
	var/sound/sound_entry = sound(mysound)
	sound_entry.wait = 0 //No queue
	sound_entry.channel = SSsounds.random_available_channel()
	sound_entry.volume = 50
	for(var/mob/passenger in passengers | pilot)
		passenger << sound_entry

/obj/spacepod/proc/message_to_riders(mymessage)
	if(length(passengers | pilot) == 0)
		return
	for(var/mob/passenger in passengers | pilot)
		to_chat(passenger, mymessage)

/obj/spacepod/hear_talk(mob/user, list/message_pieces)
	cargo_hold.hear_talk(user, message_pieces)
	..()

/obj/spacepod/hear_message(mob/user, msg)
	cargo_hold.hear_message(user, msg)
	..()


// MARK: Movement
// it looks really good with default Process_Spacemove and newtonian movement actually, should make a button to turn it on/off
/obj/spacepod/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE	// obviously

/obj/spacepod/relaymove(mob/user, direction)
	if(!COOLDOWN_FINISHED(src, spacepod_move_cooldown))
		return FALSE

	if(!pilot || user != pilot || !direction)
		COOLDOWN_START(src, spacepod_move_cooldown, 0.25 SECONDS) // Don't make it spam
		return FALSE

	. = TRUE

	var/thrust = systems.get_total_thrust(!no_gravity(src.loc))
	if(thrust <= 0)
		. = FALSE

	if(!.)
		COOLDOWN_START(src, spacepod_move_cooldown, 0.25 SECONDS)
		return .

	if(direction & (UP|DOWN))
		COOLDOWN_START(src, spacepod_move_cooldown, 0.25 SECONDS)
		. = zMove(direction)
		if(.)
			pilot.update_z(z) // after we moved
	else
		var/turf/next_step = get_step(src, direction)
		if(!next_step)
			COOLDOWN_START(src, spacepod_move_cooldown, 0.1 SECONDS)
			return FALSE
		var/calculated_move_delay = get_current_speed_delay(thrust)
		set_dir_on_move = systems.can_maneuver()
		. = Move(next_step, direction)
		if(ISDIAGONALDIR(direction) && loc == next_step)
			calculated_move_delay *= sqrt(2)
		set_glide_size(DELAY_TO_GLIDE_SIZE(calculated_move_delay))
		COOLDOWN_START(src, spacepod_move_cooldown, calculated_move_delay)

	// if(. && equipment_system.cargo_system)
	// 	for(var/atom/pod_loc as anything in locs)
	// 		for(var/obj/item/item in pod_loc.contents)
	// 			equipment_system.cargo_system.passover(item)

/obj/spacepod/proc/get_current_speed_delay(thrust)
	if(thrust <= 0)
		return POD_MOVE_MAX_DELAY
	var/mass = systems.get_total_mass()
	var/thrust_ratio = mass / thrust
	var/move_delay = clamp(pod_speed_coeff * thrust_ratio, POD_MOVE_MIN_DELAY, POD_MOVE_MAX_DELAY)
	return move_delay

/obj/spacepod/Bump(atom/bumped_atom)
	. = ..()
	if(.)
		return .
	var/target_dir = get_dir(get_turf(src), bumped_atom)
	if(isobj(bumped_atom))
		var/obj/bumped_object = bumped_atom
		if(!bumped_object.anchored)
			step(bumped_atom, target_dir)
	else if(ismob(bumped_atom))
		var/static/list/mecha_hit_sound = list('sound/weapons/genhit1.ogg','sound/weapons/genhit2.ogg','sound/weapons/genhit3.ogg')
		var/target_turf = get_distant_turf(get_turf(src), target_dir, 3)
		var/mob/bumped_mob = bumped_atom
		if(!bumped_mob.throw_at(target_turf, 2, 3, src, TRUE, 7))
			step(bumped_mob, target_dir)
		else
			playsound(src, pick(mecha_hit_sound), 50, FALSE)
	return .


// MARK: Misc actions
/obj/spacepod/proc/toggle_doors(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	if(user != pilot)
		to_chat(user, span_notice("Вы не можете дотянуться до штурвала."))
		return
	for(var/obj/machinery/door/poddoor/multi_tile/poddoor in orange(3, src))
		var/mob/living/carbon/human/human_user = user

		if(poddoor.check_access(human_user.get_active_hand()) || poddoor.check_access(human_user.wear_id))
			if(poddoor.density)
				poddoor.open()
				return TRUE
			else
				poddoor.close()
				return TRUE

		for(var/mob/living/carbon/human/passenger_human in passengers)
			if(poddoor.check_access(passenger_human.get_active_hand()) || poddoor.check_access(passenger_human.wear_id))
				if(poddoor.density)
					poddoor.open()
					return TRUE
				else
					poddoor.close()
					return TRUE

		balloon_alert(user, "нет доступа!")
		return

	to_chat(user, span_warning("Рядом нет шлюзов."))

/obj/spacepod/proc/check_seat(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	to_chat(user, span_notice("Вы начинаете искать потерянные вещи под сиденьем."))
	if(do_after(user, 4 SECONDS, src))
		var/list/badlist = list(internal_tank, cargo_hold, pilot) + passengers + systems.modules
		var/list/weapons = systems.get_slot(SPACEPOD_MODULE_SLOT_WEAPON)
		for(var/obj/item/spacepod_module/weapon/weapon as anything in weapons)
			if(weapon.primary.weapon != null)
				badlist += weapon.primary.weapon
			if(weapon.secondary.weapon != null)
				badlist += weapon.secondary.weapon
		var/list/true_contents = contents - badlist
		if(length(true_contents) > 0)
			var/obj/item = pick(true_contents)
			if(user.put_in_any_hand_if_possible(item))
				src.contents -= item
				to_chat(user, span_notice("Вы находите [item.declent_ru(ACCUSATIVE)] [pick("под сиденьем", "под консолью", "в техническом отсеке")]!"))
			else
				to_chat(user, span_notice("Вы заметили что-то блестящее, но не можете достать!"))
		else
			to_chat(user, span_notice("Вы не нашли ничего ценного."))
			balloon_alert(user, "пусто!")
	else
		to_chat(user, span_notice("Вы решаете не обыскивать [declent_ru(ACCUSATIVE)]."))

/obj/spacepod/proc/toggle_lights(mob/user)
	if(user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	if(user != pilot)
		to_chat(user, span_notice("Вы не можете дотянуться до штурвала."))
		return

	lights = !lights

	if(lights)
		set_light(lights_power, l_on = TRUE)
	else
		set_light_on(FALSE)

	visible_message("Прожекторы [lights ? "включены" : "выключены"].")

/obj/spacepod/attack_ghost(mob/dead/observer/user)
	control_panels.ui_interact(user)
	return TRUE


// MARK: Actions
/obj/spacepod/proc/grant_pilot_actions(mob/living/user)
	eject_action.Grant(user, src)
	panel_action.Grant(user, src)
	misc_action.Grant(user, src)

/obj/spacepod/proc/remove_pilot_actions(mob/living/user)
	eject_action.Remove(user)
	panel_action.Remove(user)
	misc_action.Remove(user)

/obj/spacepod/proc/grant_passenger_actions(mob/living/user)
	var/list/passenger_actions = list()
	var/datum/action/innate/pod/pod_eject/passenger_eject_action = new
	passenger_eject_action.Grant(user, src)
	passenger_actions += passenger_eject_action
	var/datum/action/innate/pod/pod_panel/passenger_panel_action = new
	passenger_panel_action.Grant(user, src)
	passenger_actions += passenger_panel_action
	passangers_actions[user] = passenger_actions

/obj/spacepod/proc/remove_passenger_actions(mob/living/user)
	var/list/passenger_actions = passangers_actions[user]
	if(!passenger_actions)
		return
	for(var/datum/action/passenger_action in passenger_actions)
		passenger_action.Remove(user)
