///MOD Module - A special device installed in a MODsuit allowing the suit to do new stuff.
/obj/item/mod/module
	name = "MOD module"
	gender = MALE
	icon = 'icons/obj/clothing/modsuit/mod_modules.dmi'
	icon_state = "module"
	/// If it can be removed
	var/removable = TRUE
	/// If it's passive, togglable, usable or active
	var/module_type = MODULE_PASSIVE
	/// Is the module active
	var/active = FALSE
	/// How much space it takes up in the MOD
	var/complexity = 0
	/// Power use when idle
	var/idle_power_cost = DEFAULT_CHARGE_DRAIN * 0
	/// Power use when active
	var/active_power_cost = DEFAULT_CHARGE_DRAIN * 0
	/// Power use when used, we call it manually
	var/use_energy_cost = DEFAULT_CHARGE_DRAIN * 0
	/// ID used by their TGUI
	var/tgui_id
	/// Linked MODsuit
	var/obj/item/mod/control/mod
	/// If we're an active module, what item are we?
	var/obj/item/device
	/// Overlay given to the user when the module is inactive
	var/overlay_state_inactive
	/// Overlay given to the user when the module is active
	var/overlay_state_active
	/// Overlay given to the user when the module is used, lasts until cooldown finishes
	var/overlay_state_use
	/// Icon file for the overlay.
	var/overlay_icon_file = 'icons/mob/clothing/modsuit/mod_modules.dmi'

	/// Does the overlay use the control unit's colors?
	var/use_mod_colors = FALSE
	/// What modules are we incompatible with?
	var/list/incompatible_modules = list()
	/// Cooldown after use
	var/cooldown_time = 0
	/// The mouse button needed to use this module
	var/used_signal
	/// Are all parts needed active- have we ran on_part_activation
	var/part_activated = FALSE
	/// Do we need the parts to be extended to run process
	var/part_process = TRUE
	/// List of UIDs mobs we are pinned to, linked with their action buttons
	var/list/pinned_to = list()
	/// flags that let the module ability be used in odd circumstances
	var/allow_flags = NONE
	/// A list of slots required in the suit to work. Formatted like list(x|y, z, ...) where either x or y are required and z is required.
	var/list/required_slots = list()
	/// If TRUE worn overlay will be masked with the suit, preventing any bits from poking out of its controur
	var/mask_worn_overlay = FALSE
	/// Timer for the cooldown
	COOLDOWN_DECLARE(cooldown_timer)
	sprite_sheets = list(
		SPECIES_VULPKANIN = 'icons/mob/clothing/modsuit/species/vulpkanin/mod_modules.dmi',
		SPECIES_TAJARAN = 'icons/mob/clothing/modsuit/species/tajaran/mod_modules.dmi',
		SPECIES_UNATHI = 'icons/mob/clothing/modsuit/species/unathi/mod_modules.dmi',
		SPECIES_DRASK = 'icons/mob/clothing/modsuit/species/grey/mod_modules.dmi',
		SPECIES_GREY = 'icons/mob/clothing/modsuit/species/drask/mod_modules.dmi',
		SPECIES_VOX = 'icons/mob/clothing/modsuit/species/vox/mod_modules.dmi',
	)

/obj/item/mod/module/get_ru_names()
	return list(
		NOMINATIVE = "модуль МЭК",
		GENITIVE = "модуля МЭК",
		DATIVE = "модулю МЭК",
		ACCUSATIVE = "модуль МЭК",
		INSTRUMENTAL = "модулем МЭК",
		PREPOSITIONAL = "модуле МЭК",
	)

/obj/item/mod/module/Initialize(mapload)
	. = ..()
	if(module_type != MODULE_ACTIVE || !ispath(device))
		return

	if(!length(required_slots))
		stack_trace("[src] has no required_slots")

	//TODO MODSUIT: выглядит как костыль
	device = new device(src)
	device.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	device.slot_flags = NONE
	device.w_class = WEIGHT_CLASS_HUGE
	device.materials = null

	RegisterSignal(device, COMSIG_QDELETING, PROC_REF(on_device_deletion))
	RegisterSignal(src, COMSIG_ATOM_EXITED, PROC_REF(on_exit))

/obj/item/mod/module/Destroy()
	mod?.uninstall(src)
	if(device)
		UnregisterSignal(device, COMSIG_QDELETING)
		QDEL_NULL(device)

	return ..()

/obj/item/mod/module/examine(mob/user)
	. = ..()
	if(length(required_slots))
		var/list/slot_strings = list()
		for(var/slot in required_slots)
			var/list/slot_list = parse_slot_flags(slot)
			slot_strings += russian_list(slot_list, and_text = " или ")
		. += span_notice("Совместимые элементы МЭК: <b>[russian_list(slot_strings)]</b>")
	. += span_notice("Стоимость модуля: <b>[complexity]</b> единиц[declension_ru(complexity, "а", "ы", "")].")

/// Looks through the MODsuit's parts to see if it has the parts required to support this module
/obj/item/mod/module/proc/has_required_parts(list/parts, need_active = FALSE)
	if(!length(required_slots))
		return TRUE
	var/total_slot_flags = NONE
	for(var/part_slot in parts)
		if(need_active)
			var/datum/mod_part/part_datum = parts[part_slot]
			if(!part_datum.sealed)
				continue
		total_slot_flags |= text2num(part_slot)
	var/list/needed_slots = required_slots.Copy()
	for(var/needed_slot in needed_slots)
		if(!(needed_slot & total_slot_flags))
			break
		needed_slots -= needed_slot
	return !length(needed_slots)

/// Called when the module is selected from the TGUI, radial or the action button
/obj/item/mod/module/proc/on_select(mob/activator)
	if(((!mod.active || mod.activating) && !(allow_flags & MODULE_ALLOW_INACTIVE)) || module_type == MODULE_PASSIVE)
		if(mod.wearer)
			balloon_alert(mod.wearer, "модуль неактивен!")
		return

	if(!mod.wearer && !(allow_flags & MODULE_ALLOW_UNWORN)) //No wearer and cannot be used unworn
		balloon_alert(activator, "модуль не экипирован!")
		return
	if(((!mod.active || mod.activating) && !(allow_flags & (MODULE_ALLOW_INACTIVE | MODULE_ALLOW_UNWORN))) || module_type == MODULE_PASSIVE) // not active
		balloon_alert(activator, "модуль неактивен!")
		return

	if(!has_required_parts(mod.mod_parts, need_active = TRUE) && !(allow_flags & MODULE_ALLOW_UNWORN)) // Doesn't have parts
		balloon_alert(activator, "элементы неактивны!")
		var/list/slot_strings = list()
		for(var/slot in required_slots)
			var/list/slot_list = parse_slot_flags(slot)
			slot_strings += russian_list(slot_list, and_text = " или ")
		to_chat(activator, span_warning("Для работы модуля необходимо, чтобы были развёрнуты данные элементы: [russian_list(slot_strings)]"))
		playsound(src, 'sound/machines/scanbuzz.ogg', 25, TRUE, SILENCED_SOUND_EXTRARANGE)
		return

	if(module_type != MODULE_USABLE)
		if(active)
			deactivate(activator)
		else
			activate(activator)
	else
		used(activator)
	SEND_SIGNAL(mod, COMSIG_MOD_MODULE_SELECTED, src)

/// Apply a cooldown until this item can be used again
/obj/item/mod/module/proc/start_cooldown(applied_cooldown)
	if(isnull(applied_cooldown))
		applied_cooldown = cooldown_time
	COOLDOWN_START(src, cooldown_timer, applied_cooldown)
	SEND_SIGNAL(src, COMSIG_MODULE_COOLDOWN_STARTED, applied_cooldown)

/// Called when the module is activated
/obj/item/mod/module/proc/activate(mob/activator)
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		balloon_alert(activator, "на перезарядке!")
		return FALSE
	if(!mod.active || mod.activating || !mod.get_charge())
		balloon_alert(activator, "недостаточно энергии!")
		return FALSE
	//Used in time travel module, if we port it
	if(!(allow_flags & MODULE_ALLOW_PHASEOUT) && istype(mod.wearer.loc, /obj/effect/dummy/phased_mob))
		//specifically a to_chat because the user is phased out.
		to_chat(activator, span_warning("Сейчас вы не можете использовать данный модуль."))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MODULE_TRIGGERED, mod.wearer) & MOD_ABORT_USE)
		return FALSE
	if(module_type == MODULE_ACTIVE)
		if(mod.selected_module && !mod.selected_module.deactivate(display_message = FALSE))
			return FALSE
		mod.selected_module = src
		if(device)
			if(mod.wearer.put_in_hands(device))
				balloon_alert(activator, "устройство развёрнуто")
				RegisterSignal(mod.wearer, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
				RegisterSignal(mod.wearer, COMSIG_MOB_KEY_DROP_ITEM_DOWN, PROC_REF(dropkey))
			else
				balloon_alert(activator, "нельзя развернуть!")
				mod.wearer.drop_transfer_item_to_loc(device, src, TRUE)
				return FALSE
		else
			var/used_button = MIDDLE_CLICK
			update_signal(used_button)
			to_chat(mod.wearer, span_notice("\"[capitalize(declent_ru(NOMINATIVE))]\" активирован[GEND_A_O_Y(src)]. Используйте <b>СКМ</b> для управления."))
	active = TRUE
	SEND_SIGNAL(src, COMSIG_MODULE_ACTIVATED)
	on_activation(activator)
	update_clothing_slots()
	return TRUE

/// Called when the module is deactivated
/obj/item/mod/module/proc/deactivate(mob/activator, display_message = TRUE, deleting = FALSE)
	active = FALSE
	if(module_type == MODULE_ACTIVE)
		mod.selected_module = null
		if(display_message)
			balloon_alert(mod.wearer, "устройство свёрнуто")
		if(device)
			mod.wearer.drop_transfer_item_to_loc(device, src, TRUE)
			UnregisterSignal(mod.wearer, COMSIG_ATOM_EXITED)
			UnregisterSignal(mod.wearer, COMSIG_MOB_KEY_DROP_ITEM_DOWN)
		else
			UnregisterSignal(mod.wearer, used_signal)
			used_signal = null
	SEND_SIGNAL(src, COMSIG_MODULE_DEACTIVATED, mod.wearer)
	on_deactivation(activator, display_message = TRUE, deleting = FALSE)
	update_clothing_slots()
	return TRUE

/// Call to update all slots visually affected by this module
/obj/item/mod/module/proc/update_clothing_slots()
	if(!mod.wearer)
		return

	var/updated_slots = mod.slot_flags
	if(mask_worn_overlay)
		for(var/obj/item/part as anything in mod.get_parts())
			updated_slots |= part.slot_flags
	else if(length(required_slots))
		for(var/slot in required_slots)
			updated_slots |= slot
	mod.wearer.update_clothing(updated_slots)

/// Called when the module is used
/obj/item/mod/module/proc/used(mob/activator)
	if(!COOLDOWN_FINISHED(src, cooldown_timer))
		balloon_alert(activator, "на перезарядке!")
		return FALSE
	if(!check_power(use_energy_cost))
		balloon_alert(activator, "недостаточно энергии!")
		return FALSE
	if(!(allow_flags & MODULE_ALLOW_PHASEOUT) && istype(mod.wearer.loc, /obj/effect/dummy/phased_mob))
		//specifically a to_chat because the user is phased out.
		to_chat(activator, span_warning("Сейчас вы не можете использовать данный модуль."))
		return FALSE
	if(SEND_SIGNAL(src, COMSIG_MODULE_TRIGGERED, mod.wearer) & MOD_ABORT_USE)
		return FALSE
	start_cooldown()
	if(mod.wearer)
		addtimer(CALLBACK(mod.wearer, TYPE_PROC_REF(/mob, update_clothing), mod.slot_flags), cooldown_time+1) //need to run it a bit after the cooldown starts to avoid conflicts
	update_clothing_slots()
	SEND_SIGNAL(src, COMSIG_MODULE_USED)
	on_use(activator)
	return TRUE

/// Called when an activated module without a device is used
/obj/item/mod/module/proc/on_select_use(atom/target)
	if(!(allow_flags & MODULE_ALLOW_INCAPACITATED) && (mod.wearer.incapacitated() || HAS_TRAIT(mod.wearer, TRAIT_HANDS_BLOCKED)))
		return FALSE
	mod.wearer.face_atom(target)
	if(!used())
		return FALSE
	return TRUE

/// Called when an activated module without a device is active and the user alt/middle-clicks
/obj/item/mod/module/proc/on_special_click(mob/source, atom/target)
	SIGNAL_HANDLER

	on_select_use(target)
	return COMSIG_MOB_CANCEL_CLICKON

/// Called on the MODsuit's process
/obj/item/mod/module/proc/on_process(seconds_per_tick)
	if(part_process && !part_activated)
		return FALSE
	if(active)
		if(!drain_power(active_power_cost * seconds_per_tick))
			deactivate()
			return FALSE
		on_active_process(seconds_per_tick)
	else
		drain_power(idle_power_cost * seconds_per_tick)
	return TRUE

/// Called from the module's activate()
/obj/item/mod/module/proc/on_activation(mob/activator)
	return

/// Called from the module's deactivate()
/obj/item/mod/module/proc/on_deactivation(mob/activator, display_message = TRUE, deleting = FALSE)
	return

/// Called from the module's used()
/obj/item/mod/module/proc/on_use(mob/activator)
	return

/// Called on the MODsuit's process if it is an active module
/obj/item/mod/module/proc/on_active_process()
	return

/// Called from MODsuit's install() proc, so when the module is installed
/obj/item/mod/module/proc/on_install()
	SHOULD_CALL_PARENT(TRUE)

	if(mask_worn_overlay)
		for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
			RegisterSignal(part, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS, PROC_REF(add_module_overlay))
		return

	if(!length(required_slots))
		RegisterSignal(mod, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS, PROC_REF(add_module_overlay))
		return

	var/obj/item/part = mod.get_part_from_slot(required_slots[1])
	RegisterSignal(part, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS, PROC_REF(add_module_overlay))

/// Called from MODsuit's uninstall() proc, so when the module is uninstalled
/obj/item/mod/module/proc/on_uninstall(deleting = FALSE)
	SHOULD_CALL_PARENT(TRUE)

	if(mask_worn_overlay)
		for(var/obj/item/part as anything in mod.get_parts(all = TRUE))
			UnregisterSignal(part, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS)
		return

	if(!length(required_slots))
		UnregisterSignal(mod, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS)
		return

	var/obj/item/part = mod.get_part_from_slot(required_slots[1])
	UnregisterSignal(part, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS)

/// Called when the MODsuit is activated
/obj/item/mod/module/proc/on_part_activation()
	return

/// Called when the MODsuit is deactivated
/obj/item/mod/module/proc/on_part_deactivation(deleting = FALSE)
	return

/// Called when the MODsuit is equipped
/obj/item/mod/module/proc/on_equip()
	return

/// Called when the MODsuit is unequipped
/obj/item/mod/module/proc/on_unequip()
	return

/obj/item/mod/module/proc/drain_power(amount)
	if(!check_power(amount))
		return FALSE
	mod.subtract_charge(amount)
	return TRUE

/// Checks if there is enough power in the suit
/obj/item/mod/module/proc/check_power(amount)
	return mod.check_charge(amount)

/// Adds additional things to the MODsuit ui_data()
/obj/item/mod/module/proc/add_ui_data()
	return list()

/// Creates a list of configuring options for this module
/obj/item/mod/module/proc/get_configuration()
	return list()

/// Generates an element of the get_configuration list with a display name, type and value
/obj/item/mod/module/proc/add_ui_configuration(display_name, type, value, list/values)
	return list("display_name" = display_name, "type" = type, "value" = value, "values" = values)

/// Receives configure edits from the TGUI and edits the vars
/obj/item/mod/module/proc/configure_edit(key, value)
	return

/// Called when the device moves to a different place on active modules
/obj/item/mod/module/proc/on_exit(datum/source, atom/movable/part, direction)
	SIGNAL_HANDLER

	if(!active)
		return
	if(part.loc == src)
		return
	if(part.loc == mod.wearer)
		return
	if(part == device)
		deactivate(display_message = FALSE)

/// Called when the device gets deleted on active modules
/obj/item/mod/module/proc/on_device_deletion(datum/source)
	SIGNAL_HANDLER

	if(source != device)
		return
	device.moveToNullspace()
	device = null
	qdel(src)

/// Adds the worn overlays to the suit.
/obj/item/mod/module/proc/add_module_overlay(obj/item/source, list/overlays, mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	SIGNAL_HANDLER

	if(isinhands)
		return

	var/list/added_overlays = generate_worn_overlay(source, standing)
	if(!added_overlays)
		return

	if(!mask_worn_overlay)
		overlays += added_overlays
		return

	for(var/mutable_appearance/overlay as anything in added_overlays)
		overlay.add_filter("mod_mask_overlay", 1, alpha_mask_filter(icon = icon(draw_target.icon, draw_target.icon_state)))
		overlays += overlay

/// Generates an icon to be used for the suit's worn overlays
/obj/item/mod/module/proc/generate_worn_overlay(obj/item/source, mutable_appearance/standing)
	if(!mask_worn_overlay)
		if(!has_required_parts(mod.mod_parts, need_active = TRUE))
			return
	else
		var/datum/mod_part/part_datum = mod.get_part_datum(source)
		if(!part_datum?.sealed)
			return

	. = list()
	var/used_overlay = get_current_overlay_state()
	if(!used_overlay)
		return

	var/used_icon_file = overlay_icon_file
	if(sprite_sheets[mod.wearer?.dna?.species?.name])
		used_icon_file = sprite_sheets[mod.wearer?.dna?.species?.name]

	var/mutable_appearance/module_icon = mutable_appearance(used_icon_file, used_overlay, layer = standing.layer + 0.1)
	if(use_mod_colors)
		module_icon.color = mod.color
		if(mod.cached_color_filter)
			module_icon = filter_appearance_recursive(module_icon, mod.cached_color_filter)

	. += module_icon
	SEND_SIGNAL(src, COMSIG_MODULE_GENERATE_WORN_OVERLAY, ., standing)

/obj/item/mod/module/proc/get_current_overlay_state()
	if(overlay_state_use && !COOLDOWN_FINISHED(src, cooldown_timer))
		return overlay_state_use
	if(overlay_state_active && active)
		return overlay_state_active
	if(overlay_state_inactive)
		return overlay_state_inactive
	return null

/// Updates the signal used by active modules to be activated
/obj/item/mod/module/proc/update_signal(value)
	switch(value)
		if(MIDDLE_CLICK)
			mod.selected_module.used_signal = COMSIG_MOB_MIDDLECLICKON
		if(ALT_CLICK)
			mod.selected_module.used_signal = COMSIG_MOB_ALTCLICKON
	RegisterSignal(mod.wearer, mod.selected_module.used_signal, TYPE_PROC_REF(/obj/item/mod/module, on_special_click))

/// Pins the module to the user's action buttons
/obj/item/mod/module/proc/pin(mob/user)
	if(module_type == MODULE_PASSIVE)
		return

	var/datum/action/item_action/mod/pinnable/module/existing_action = pinned_to[user.UID()]
	if(existing_action)
		mod.remove_item_action(existing_action)
		return

	var/datum/action/item_action/mod/pinnable/module/new_action = new(mod, user, src)
	mod.add_item_action(new_action)

	to_chat(mod.wearer, span_notice("Действие \"[new_action]\" закреплено на панели!"))

/// On drop key, concels a device item.
/obj/item/mod/module/proc/dropkey(mob/living/user)
	SIGNAL_HANDLER

	if(user.get_active_hand() != device)
		return
	deactivate()
	return

///Anomaly Locked - Causes the module to not function without an anomaly.
/obj/item/mod/module/anomaly_locked
	name = "MOD anomaly locked module"
	desc = "Модуль, требующий для функционирования ядро аномалии."
	incompatible_modules = list()
	/// The core item the module runs off.
	var/obj/item/assembly/signaler/core/core
	/// Accepted types of anomaly cores.
	var/list/accepted_anomalies = list(/obj/item/assembly/signaler/core)
	/// If this one starts with a core in.
	var/prebuilt = FALSE
	/// If the core is removable once socketed.
	var/core_removable = TRUE

/obj/item/mod/module/anomaly_locked/Initialize(mapload)
	. = ..()
	var/list/cashed_anomalies = accepted_anomalies.Copy()
	accepted_anomalies.Cut()
	for(var/anomaly in cashed_anomalies)
		accepted_anomalies += subtypesof(anomaly)
	if(!prebuilt || !length(accepted_anomalies))
		update_core_powers()
		return
	var/core_path = pick(cashed_anomalies)
	core = new core_path(src)
	update_icon(UPDATE_ICON_STATE)

/obj/item/mod/module/anomaly_locked/Destroy()
	QDEL_NULL(core)
	return ..()

/obj/item/mod/module/anomaly_locked/examine(mob/user)
	. = ..()
	if(!length(accepted_anomalies))
		return
	if(core)
		. += span_notice("К модулю прикреплен[GEND_A_O_Y(core)] [core.declent_ru(NOMINATIVE)]. \
						[core_removable ? "Мо[PLUR_JET_GUT(core)] быть откручен[GEND_A_O_Y(core)]." : "Конструкция модуля не позволяет извлечь ядро."]")
		return
	var/list/core_list = list()
	for(var/path in accepted_anomalies)
		var/atom/core_dummy = new path
		core_list += core_dummy.declent_ru(NOMINATIVE)
		qdel(core_dummy)
	. += span_notice("Для работы модуля требуется [russian_list(core_list, and_text = " или ")]")
	if(!core_removable)
		. += span_notice("Конструкция модуля не позволяет извлечь ядро.")

/obj/item/mod/module/anomaly_locked/on_select()
	if(!core)
		balloon_alert(mod.wearer, "ядро не установлено!")
		return
	return ..()

/obj/item/mod/module/anomaly_locked/on_process()
	. = ..()
	if(!core)
		return FALSE

/obj/item/mod/module/anomaly_locked/on_active_process()
	if(!core)
		return FALSE
	return TRUE

/obj/item/mod/module/anomaly_locked/attackby(obj/item/item, mob/living/user, list/modifiers, list/attack_modifiers)
	. = ..()
	if(!(item.type in accepted_anomalies))
		return

	if(core)
		balloon_alert(user, "ядро уже есть!")
		return ATTACK_CHAIN_BLOCKED_ALL

	if(!user.transfer_item_to_loc(item, src))
		return ATTACK_CHAIN_BLOCKED_ALL

	core = item
	balloon_alert(user, "ядро установлено")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	update_icon(UPDATE_ICON_STATE)
	update_core_powers()

/obj/item/mod/module/anomaly_locked/proc/update_core_powers()
	return

/obj/item/mod/module/anomaly_locked/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!core)
		balloon_alert(user, "ядро отсутствует!")
		return
	if(!core_removable)
		balloon_alert(user, "ядро нельзя извлечь!")
		return
	balloon_alert(user, "извлечение ядра...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "извлечение ядра прервано!")
		return
	balloon_alert(user, "ядро извлечено")
	core.forceMove(drop_location())
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(core)
	core = null
	update_icon(UPDATE_ICON_STATE)

/obj/item/mod/module/anomaly_locked/update_icon_state()
	icon_state = initial(icon_state) + (core ? "-core" : "")
	return ..()
