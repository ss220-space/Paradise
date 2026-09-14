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
	var/datum/action/innate/pod/pod_eject/passanger_eject = new
	var/datum/action/innate/pod/pod_toggle_lights/lights_action = new
	var/datum/action/innate/pod/pod_panel/panel_action = new

	// tgui
	var/datum/ui_module/spacepod_control_panels/control_panels


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
	QDEL_NULL(cargo_hold)
	QDEL_NULL(systems)
	QDEL_NULL(cabin_air)
	QDEL_NULL(internal_tank)
	QDEL_NULL(ion_trail)
	QDEL_NULL(eject_action)
	QDEL_NULL(passanger_eject)
	QDEL_NULL(lights_action)
	QDEL_NULL(panel_action)
	QDEL_NULL(control_panels)
	occupant_sanity_check()
	if(pilot)
		eject_pilot()
	if(passengers)
		for(var/mob/passenger in passengers)
			eject_passenger(passenger)
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

	if(!unlocked)
		balloon_alert(user, "Замок закрыт")
		return ..()

	. = TRUE
	if(hatch_opened)
		hatch_opened = FALSE
		balloon_alert(user, "Люк техобслуживания закрыт")
	else
		hatch_opened = TRUE
		balloon_alert(user, "Люк техобслуживания открыт")

//MARK: attackby
/obj/spacepod/attackby(obj/item/item, mob/living/user, list/modifiers)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(item, /obj/item/spacepod_key))
		add_fingerprint(user)
		if(!systems.key_lock)
			balloon_alert(user, "нет замка!")
			return ATTACK_CHAIN_PROCEED
		var/obj/item/spacepod_key/key = item
		if(key.id != systems.key_lock.key_id)
			balloon_alert(user, "неправильный ключ!")
			return ATTACK_CHAIN_PROCEED
		toggle_lock(user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(assemble_process && istype(item, /obj/item/spacepod_module))
		var/obj/item/spacepod_module/module_obj = item
		add_fingerprint(user)
		if(!user.drop_transfer_item_to_loc(item, src))
			return ..()
		var/obj/item/spacepod_module/installed_module = module_obj.install_to(user, src)
		if(!installed_module)
			item.forceMove(src.loc)
			return ..()
		systems.add_module(src, module_obj)
		to_chat(user, span_notice("Модуль [module_obj.module_name] установлен."))
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!hatch_opened)
		return ..()

	// attach gun
	if(isgun(item) && systems.weapon != null)
		if(systems.weapon.install_gun(item))
			if(!user.drop_transfer_item_to_loc(item, src))
				return ..()
			item.forceMove(src)
			update_icon(UPDATE_ICON_STATE)
			return ATTACK_CHAIN_BLOCKED_ALL

	// sitch to assemble mode
	if(ismultitool(item))
		to_chat(user, span_notice("Системы космического челнока переведены в режим сборки."))
		assemble_process = TRUE
		return ATTACK_CHAIN_BLOCKED_ALL

	// refill fuel
	if(istype(item, /obj/item/tank/internals))
		var/obj/item/tank/internals/fuel_tank = item
		if(fuel_tank.air_contents.toxins() <= 0)
			to_chat(user, span_notice("Нет нужного топлива!"))
			return ATTACK_CHAIN_BLOCKED_ALL

		var availableFuel = fuel_tank.air_contents.toxins() * 10
		var/last_fuel = systems.fill_fuel_tanks(availableFuel)
		fuel_tank.air_contents.set_toxins(last_fuel / 10)
		to_chat(user, span_notice("Заправлено [availableFuel - last_fuel] топлива из [availableFuel]."))
		return ATTACK_CHAIN_BLOCKED_ALL

	// charge battery
	if(iscell(item) && systems.battery != null)
		var/charge_rate = 0.1
		var/obj/item/stock_parts/cell/cell_item = item
		var/free_charge = systems.battery.power_capacity - systems.battery.power
		var/used_charge = min(cell_item.charge * charge_rate, free_charge)
		systems.battery.power += used_charge
		cell_item.charge -= used_charge / charge_rate
		to_chat(user, span_notice("Аккумуляторная батарея заряжена на [used_charge] Ватт."))

	return ..()

/obj/spacepod/proc/toggle_lock(mob/user)
	if(!systems.key_lock)
		return
	unlocked = !unlocked
	if(unlocked)
		balloon_alert(user, "Замок открыт")
	else
		balloon_alert(user, "Замок закрыт")


//MARK: Attack hand
#define ACTION_CARGO_ACCESS "Доступ к хранилищу"
#define ACTION_REMOVE_PRIMARY_WEAPON "Извлечь основное вооружение"
#define ACTION_REMOVE_SECONDARY_WEAPON "Извлечь дополнительное вооружение"

/obj/spacepod/attack_hand(mob/user)
	if(user.a_intent == INTENT_GRAB && unlocked)
		eject_any_occupant(user)

	if(hatch_opened)
		var/list/options = list()
		options += ACTION_CARGO_ACCESS
		if(systems.weapon != null)
			if(systems.weapon.primary.weapon != null)
				options += ACTION_REMOVE_PRIMARY_WEAPON
			if(systems.weapon.secondary.weapon != null)
				options += ACTION_REMOVE_SECONDARY_WEAPON

		var/choice = length(options) == 1 ? options[1] : tgui_input_list(user, "Что вы хотите сделать?", "Доступ к челноку через люк", options)
		if(!choice)
			return
		switch(choice)
			if(ACTION_CARGO_ACCESS)
				cargo_hold.open(user)
			if(ACTION_REMOVE_PRIMARY_WEAPON)
				if(systems.weapon != null)
					remove_gun_from_systems(user, systems.weapon.primary.weapon)
			if(ACTION_REMOVE_SECONDARY_WEAPON)
				if(systems.weapon != null)
					remove_gun_from_systems(user, systems.weapon.secondary.weapon)

#undef ACTION_CARGO_ACCESS
#undef ACTION_REMOVE_PRIMARY_WEAPON
#undef ACTION_REMOVE_SECONDARY_WEAPON

/obj/spacepod/proc/remove_gun_from_systems(mob/user, obj/item/gun/selected_gun)
	if(selected_gun == null)
		to_chat(user, span_notice("Вооружение не установлено."))
		return
	var/obj/item/gun/removed_gun = systems.weapon.remove_gun(selected_gun)
	if(removed_gun == null)
		to_chat(user, span_notice("Вооружение не установлено."))
		return
	removed_gun.forceMove(src.loc)
	to_chat(user, span_notice("Вы извлекаете [removed_gun.declent_ru(NOMINATIVE)] из космического челнока."))


// MARK: Process (update)
/obj/spacepod/process(seconds_per_tick)
	systems.process_work(seconds_per_tick, src)
	if(systems && systems.life_support && systems.life_support.enable)
		give_air()
		regulate_temp()

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
	RemovePilotActions(pilot)
	control_panels.ui_close(pilot)
	pilot = null

/obj/spacepod/proc/eject_passenger(mob/living/passenger)
	passenger.forceMove(get_turf(src))
	passanger_eject.Remove(passenger)
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
		span_warning("[user] пытается открыть дверь и вытащить [target] из [declent_ru(GENITIVE)]!"),
		span_warning("Вы видите, как [user] пытается открыть дверь!")
	)
	if(!do_after(user, POD_OCCUPANT_EJECT_DURATION, src))
		target.visible_message(
			span_warning("[user] не смог открыть дверь!"),
			span_warning("Вы не дали [user] проникнуть в [declent_ru(NOMINATIVE)]!")
		)
		return

	target.Stun(2 SECONDS)
	if(pilot)
		eject_pilot()
	else
		eject_passenger(target)
	target.visible_message(
		span_warning("[user] распахивает дверь и достаёт [target] из [declent_ru(GENITIVE)]!"),
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

	visible_message(span_notice("[user] начинает забираться в [declent_ru(ACCUSATIVE)]."))
	if(!do_after(user, POD_ENTER_DURATION, src))
		balloon_alert(user, "посадка отменена")
		return

	if(!pilot || pilot == null)
		pilot = user
		user.forceMove(src)
		GrantPilotActions(user)
		add_fingerprint(user)
		playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
		return

	if(length(passengers) < max_passengers)
		passengers += user
		user.forceMove(src)
		passanger_eject.Grant(user, src)
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
	if(!systems.catapult || (!force && !systems.catapult.enable))
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
	if(systems.weapon == null)
		return // weapons not installed

	if(!systems.weapon.connection_power_net || !systems.weapon.enable)
		return // weapon module offline

	var/datum/spacepod_weapon_slot/selected_gun = null
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		selected_gun = systems.weapon.secondary
	else
		selected_gun = systems.weapon.primary

	if(selected_gun == null)
		return // selected gun not exists
	if(selected_gun.safety || selected_gun.charging)
		return // safety or charging process

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
	. = ..()


// MARK: Environment
/obj/spacepod/return_obj_air()
	RETURN_TYPE(/datum/gas_mixture)
	if(systems && systems.life_support && systems.life_support.enable)
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

	var/thrust = systems.get_total_thrust()
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
	if(!no_gravity(loc))
		move_delay *=  POD_GRAVITY_SPEED_MOD
	return move_delay

// MARK: Actions
/obj/spacepod/proc/GrantPilotActions(mob/living/user)
	eject_action.Grant(user, src)
	lights_action.Grant(user, src)
	//fire_action.Grant(user, src)
	panel_action.Grant(user, src)

/obj/spacepod/proc/RemovePilotActions(mob/living/user)
	eject_action.Remove(user)
	lights_action.Remove(user)
	//fire_action.Remove(user)
	panel_action.Remove(user)
