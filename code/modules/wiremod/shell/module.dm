/obj/item/mod/module/circuit
	name = "MOD circuit adapter module"
	desc = "Модуль МЭК, позволяющий установку интегральной схемы в модульные экзо-костюмы и взаимодействие с ними."
	module_type = MODULE_USABLE
	complexity = 1
	idle_power_cost = DEFAULT_CHARGE_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/circuit)
	cooldown_time = 0.5 SECONDS
	required_slots = list(ITEM_SLOT_BACK)

	/// A reference to the shell component, used to access the shell and its attached circuit
	var/datum/component/shell/shell
	/// List of installed action components
	var/list/obj/item/circuit_component/equipment_action/action_comps = list()

/obj/item/mod/module/circuit/get_ru_names()
	return list(
		NOMINATIVE = "модуль интегральной схемы",
		GENITIVE = "модуля интегральной схемы",
		DATIVE = "модулю интегральной схемы",
		ACCUSATIVE = "модуль интегральной схемы",
		INSTRUMENTAL = "модулем интегральной схемы",
		PREPOSITIONAL = "модуле интегральной схемы",
	)


/obj/item/mod/module/circuit/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_CIRCUIT_ACTION_COMPONENT_REGISTERED, PROC_REF(action_comp_registered))
	RegisterSignal(src, COMSIG_CIRCUIT_ACTION_COMPONENT_UNREGISTERED, PROC_REF(action_comp_unregistered))

	shell = AddComponent(/datum/component/shell, \
		list(new /obj/item/circuit_component/mod_adapter_core()), \
		capacity = SHELL_CAPACITY_LARGE, \
	)

/obj/item/mod/module/circuit/proc/override_power_usage(datum/source, amount)
	SIGNAL_HANDLER
	if(drain_power(amount))
		. = COMPONENT_OVERRIDE_POWER_USAGE

/obj/item/mod/module/circuit/proc/action_comp_registered(datum/source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	action_comps += action_comp

/obj/item/mod/module/circuit/proc/action_comp_unregistered(datum/source, obj/item/circuit_component/equipment_action/action_comp)
	SIGNAL_HANDLER
	action_comps -= action_comp
	for(var/ref in action_comp.granted_to)
		unpin_action(action_comp, locateUID(ref))
	QDEL_LIST_ASSOC_VAL(action_comp.granted_to)

/obj/item/mod/module/circuit/on_install()
	. = ..()
	if(!shell?.attached_circuit)
		return
	RegisterSignal(shell?.attached_circuit, COMSIG_CIRCUIT_PRE_POWER_USAGE, PROC_REF(override_power_usage))

/obj/item/mod/module/circuit/on_uninstall(deleting = FALSE)
	. = ..()
	if(!shell?.attached_circuit)
		return
	for(var/obj/item/circuit_component/equipment_action/action_comp in action_comps)
		for(var/ref in action_comp.granted_to)
			unpin_action(action_comp, locateUID(ref))
	UnregisterSignal(shell?.attached_circuit, COMSIG_CIRCUIT_PRE_POWER_USAGE)

/obj/item/mod/module/circuit/on_use()
	. = ..()
	if(!.)
		return
	if(!shell.attached_circuit)
		return
	shell.attached_circuit?.interact(mod.wearer)

/obj/item/mod/module/circuit/get_configuration(mob/user)
	. = ..()
	var/unnamed_action_index = 1
	for(var/obj/item/circuit_component/equipment_action/action_comp in action_comps)
		.[action_comp.UID()] = add_ui_configuration(action_comp.button_name.value || "Unnamed Action [unnamed_action_index++]", "pin", !!action_comp.granted_to[user.UID()])

/obj/item/mod/module/circuit/configure_edit(key, value)
	. = ..()
	var/obj/item/circuit_component/equipment_action/action_comp = locateUID(key)
	if(!istype(action_comp))
		return
	if(text2num(value))
		pin_action(action_comp, usr)
	else
		unpin_action(action_comp, usr)

/obj/item/mod/module/circuit/proc/pin_action(obj/item/circuit_component/equipment_action/action_comp, mob/user)
	if(!istype(user))
		return
	if(action_comp.granted_to[user.UID()]) // Sanity check - don't pin an action for a mob that has already pinned it
		return
	mod.add_item_action(new/datum/action/item_action/mod/pinnable/circuit(mod, user, src, action_comp))

/obj/item/mod/module/circuit/proc/unpin_action(obj/item/circuit_component/equipment_action/action_comp, mob/user)
	var/datum/action/item_action/mod/pinnable/circuit/action = action_comp.granted_to[user.UID()]
	if(!istype(action))
		return
	qdel(action)

/datum/action/item_action/mod/pinnable/circuit
	button_icon = 'icons/mob/actions/actions_bci.dmi'
	button_icon_state = "bci_blank"

	/// A reference to the module containing this action's component
	var/obj/item/mod/module/circuit/module

	/// A reference to the component this action triggers.
	var/obj/item/circuit_component/equipment_action/circuit_component

/datum/action/item_action/mod/pinnable/circuit/New(Target, mob/user, obj/item/mod/module/circuit/linked_module, obj/item/circuit_component/equipment_action/action_comp)
	. = ..()
	module = linked_module
	action_comp.granted_to[user.UID()] = src
	circuit_component = action_comp
	name = action_comp.button_name.value
	button_icon_state = "bci_[replacetextEx(LOWER_TEXT(action_comp.icon_options.value), " ", "_")]"

/datum/action/item_action/mod/pinnable/circuit/Destroy()
	circuit_component.granted_to -= pinner.UID()
	circuit_component = null

	return ..()

/datum/action/item_action/mod/pinnable/circuit/do_effect(trigger_flags)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = module.mod
	if(!istype(mod))
		return FALSE
	if(!mod.active || mod.activating)
		if(mod.wearer)
			module.balloon_alert(mod.wearer, "not active!")
		return FALSE
	circuit_component.user.set_output(owner)
	circuit_component.signal.set_output(COMPONENT_SIGNAL)

/// If the guy whose UI we are pinned to got deleted
/datum/action/item_action/mod/pinnable/circuit/pinner_deleted()
	module?.action_comps[circuit_component] -= pinner.UID()
	. = ..()

/obj/item/circuit_component/mod_adapter_core
	display_name = "ядро адаптера схем для МЭК"
	desc = "Позволяет считывать информацию о пользователе МЭКа и позволяет удаленно запускать и отключать МЭК."

	/// The MODsuit module this circuit is associated with
	var/obj/item/mod/module/attached_module

	// The name of the module to select
	var/datum/port/input/option/module_to_select

	/// The signal to toggle deployment of the modsuit
	var/datum/port/input/toggle_deploy

	/// The signal to toggle the suit
	var/datum/port/input/toggle_suit

	/// The signal to select a module
	var/datum/port/input/select_module

	/// A reference to the wearer of the MODsuit
	var/datum/port/output/wearer

	/// Whether or not the suit is deployed
	var/datum/port/output/deployed

	/// Whether or not the suit is activated
	var/datum/port/output/activated

	/// The name of the last selected module
	var/datum/port/output/selected_module

	/// A list of the names of all currently deployed parts
	var/datum/port/output/deployed_parts

	/// The signal that is triggered when a module is selected
	var/datum/port/output/on_module_selected

	/// The signal that is triggered when the suit is deployed by a signal
	var/datum/port/output/on_deploy

	/// The signal that is triggered when the suit has finished toggling itself after being activated by a signal
	var/datum/port/output/on_toggle_finish

/obj/item/circuit_component/mod_adapter_core/populate_options()
	module_to_select = add_option_port("Выбор модуля", list())

/obj/item/circuit_component/mod_adapter_core/populate_ports()
	// Input Signals
	toggle_deploy = add_input_port("Развертывание", PORT_TYPE_SIGNAL)
	toggle_suit = add_input_port("Запуск костюма", PORT_TYPE_SIGNAL)
	select_module = add_input_port("Выбор модуля", PORT_TYPE_SIGNAL)
	// States
	wearer = add_output_port("Пользователь", PORT_TYPE_USER)
	deployed = add_output_port("Развернуто", PORT_TYPE_NUMBER)
	activated = add_output_port("Запущено", PORT_TYPE_NUMBER)
	selected_module = add_output_port("Выбранный модуль", PORT_TYPE_STRING)
	deployed_parts = add_output_port("Развернутые части", PORT_TYPE_LIST(PORT_TYPE_STRING))
	// Output Signals
	on_module_selected = add_output_port("При выборе модуля", PORT_TYPE_SIGNAL)
	on_deploy = add_output_port("При развертвыении", PORT_TYPE_SIGNAL)
	on_toggle_finish = add_output_port("При завершении активации", PORT_TYPE_SIGNAL)

/obj/item/circuit_component/mod_adapter_core/register_shell(atom/movable/shell)
	. = ..()
	if(istype(shell, /obj/item/mod/module))
		attached_module = shell
		RegisterSignal(attached_module, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/obj/item/circuit_component/mod_adapter_core/unregister_shell(atom/movable/shell)
	if(attached_module)
		UnregisterSignal(attached_module, COMSIG_MOVABLE_MOVED)
		attached_module = null
	return ..()

/obj/item/circuit_component/mod_adapter_core/input_received(datum/port/input/port)
	if(!attached_module?.mod)
		return
	var/obj/item/mod/module/module
	for(var/obj/item/mod/module/potential_module as anything in attached_module.mod.modules)
		if(potential_module.name == module_to_select.value)
			module = potential_module
	if(COMPONENT_TRIGGERED_BY(toggle_suit, port))
		INVOKE_ASYNC(attached_module.mod, TYPE_PROC_REF(/obj/item/mod/control, toggle_activate), attached_module.mod.wearer)
	if(COMPONENT_TRIGGERED_BY(toggle_deploy, port))
		INVOKE_ASYNC(attached_module.mod, TYPE_PROC_REF(/obj/item/mod/control, quick_deploy), attached_module.mod.wearer)
	if(attached_module.mod.active && module && COMPONENT_TRIGGERED_BY(select_module, port))
		INVOKE_ASYNC(module, TYPE_PROC_REF(/obj/item/mod/module, on_select))

/obj/item/circuit_component/mod_adapter_core/proc/on_move(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(ismodcontrol(source.loc))
		var/obj/item/mod/control/mod = source.loc
		RegisterSignal(mod, COMSIG_MOD_MODULE_SELECTED, PROC_REF(on_module_select))
		RegisterSignal(mod, COMSIG_MOD_DEPLOYED, PROC_REF(on_mod_part_toggled))
		RegisterSignal(mod, COMSIG_MOD_RETRACTED, PROC_REF(on_mod_part_toggled))
		RegisterSignal(mod, COMSIG_MOD_TOGGLED, PROC_REF(on_mod_toggled))
		RegisterSignal(mod, COMSIG_MOD_MODULE_ADDED, PROC_REF(on_module_changed))
		RegisterSignal(mod, COMSIG_MOD_MODULE_REMOVED, PROC_REF(on_module_changed))
		RegisterSignal(mod, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_check))
		wearer.set_output(mod.wearer)
		var/modules_list = list()
		for(var/obj/item/mod/module/module in mod.modules)
			if(module.module_type != MODULE_PASSIVE)
				modules_list += module.name
		module_to_select.possible_options = modules_list
		if(length(module_to_select.possible_options))
			module_to_select.set_value(module_to_select.possible_options[1])
		return

	if(!ismodcontrol(old_loc))
		return
	UnregisterSignal(old_loc, list(COMSIG_MOD_MODULE_SELECTED, COMSIG_ITEM_EQUIPPED))
	UnregisterSignal(old_loc, COMSIG_MOD_DEPLOYED)
	UnregisterSignal(old_loc, COMSIG_MOD_RETRACTED)
	UnregisterSignal(old_loc, COMSIG_MOD_TOGGLED)
	UnregisterSignal(old_loc, COMSIG_MOD_MODULE_ADDED)
	UnregisterSignal(old_loc, COMSIG_MOD_MODULE_REMOVED)
	selected_module.set_output(null)
	wearer.set_output(null)
	deployed.set_output(FALSE)
	activated.set_output(FALSE)

/obj/item/circuit_component/mod_adapter_core/proc/on_module_select(datum/source, obj/item/mod/module/module)
	SIGNAL_HANDLER
	selected_module.set_output(module.name)
	on_module_selected.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_adapter_core/proc/on_module_changed()
	SIGNAL_HANDLER
	var/modules_list = list()
	for(var/obj/item/mod/module/module in attached_module.mod.modules)
		if(module.module_type != MODULE_PASSIVE)
			modules_list += module.name
	module_to_select.possible_options = modules_list
	if(length(module_to_select.possible_options))
		module_to_select.set_value(module_to_select.possible_options[1])

/obj/item/circuit_component/mod_adapter_core/proc/on_mod_part_toggled()
	SIGNAL_HANDLER
	var/string_list = list()
	var/is_deployed = TRUE
	for(var/obj/item/part as anything in attached_module.mod.get_parts())
		if(part.loc == attached_module.mod)
			is_deployed = FALSE
		else
			var/part_name = "Неизвестно"
			if(ismodhelmet(part))
				part_name = "Шлем"
			if(ismodchestplate(part))
				part_name = "Нагрудник"
			if(ismodgloves(part))
				part_name = "Перчатки"
			if(ismodshoes(part))
				part_name = "Ботинки"
			string_list += part_name
	deployed_parts.set_output(string_list)
	deployed.set_output(is_deployed)
	on_deploy.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_adapter_core/proc/on_mod_toggled()
	SIGNAL_HANDLER
	activated.set_output(attached_module.mod.active)
	on_toggle_finish.set_output(COMPONENT_SIGNAL)

/obj/item/circuit_component/mod_adapter_core/proc/equip_check()
	SIGNAL_HANDLER
	if(!attached_module.mod?.wearer)
		return
	wearer.set_output(attached_module.mod.wearer)
