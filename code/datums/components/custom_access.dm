/**
 * # Access Control Override Component
 *
 * A lightweight component that dynamically overrides the parent object's standard 'req_access'
 * requirements, replacing them with the access configurations copied from an inserted control item.
 *
 * This allows players to customize access requirements for machines, consoles, or lockers in-round
 * by inserting access electronics. The component clones the data and deletes the item on initialization.
 *
 * ## Initialization Requirements:
 * Requires an instance of [/obj/item/access_control/electronics_in] and [mob/user] upon creation
 * to extract and copy the access configurations.
 *
 * ## Implementation Notes for Developers:
 * You must manually handle the conditions under which this component is attached to a parent object
 * (e.g., when a console is nearly disassembled, a locker is hacked open, or a new machine is built).
 * Supports [COMSIG_ITEM_CHECK_CUSTOM_ACCESS] to dynamically detect if this component is already attached.
 * Sends [COMSIG_CUSTOM_ACCESS_REMOVAL_ATTEMPT] to the parent before allowing players to crowbar the electronics out.
 */

/datum/component/custom_access
	dupe_mode = COMPONENT_DUPE_UNIQUE
	var/list/copied_accesses = list()
	var/copied_one_access
	var/emagged

/datum/component/custom_access/Initialize(electronics_in, mob/user)
	var/obj/item/access_control/installing_electronics = electronics_in
	copied_accesses = installing_electronics.selected_accesses.Copy()
	copied_one_access = installing_electronics.one_access
	emagged = installing_electronics.emagged
	var/obj/parent_obj = parent
	playsound(parent_obj, 'sound/items/deconstruct.ogg', 40, TRUE)
	qdel(installing_electronics)

/datum/component/custom_access/RegisterWithParent()
	RegisterSignal(parent, COMSIG_OBJ_ALLOWED, PROC_REF(check_access))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_CROWBAR), PROC_REF(on_crowbar_act))
	RegisterSignal(parent, COMSIG_ATOM_EMAG_ACT, PROC_REF(on_emag_act))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ITEM_CHECK_CUSTOM_ACCESS, PROC_REF(check_this_component))
	RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(on_object_deconstruct))

/datum/component/custom_access/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_OBJ_ALLOWED,
		COMSIG_ATOM_TOOL_ACT(TOOL_CROWBAR),
		COMSIG_ATOM_EMAG_ACT,
		COMSIG_ATOM_EXAMINE
		))

/datum/component/custom_access/proc/check_access(datum/source, mob/accessor)
	SIGNAL_HANDLER

	if(emagged)
		return COMPONENT_OBJ_ALLOW

	if(has_access(copied_accesses, copied_one_access, accessor.get_access()))
		return COMPONENT_OBJ_ALLOW

	return COMPONENT_OBJ_DISALLOW

/datum/component/custom_access/proc/on_crowbar_act(datum/source, mob/living/user, obj/item/tool)
	SIGNAL_HANDLER

	var/obj/parent_obj = parent

	if(SEND_SIGNAL(parent_obj, COMSIG_CUSTOM_ACCESS_REMOVAL_ATTEMPT) & COMPONENT_BLOCK_ACCESS_REMOVAL)
		to_chat(user, span_notice("Невозможно вытащить плату! Требуется частично разобрать [parent_obj.declent_ru(ACCUSATIVE)]."))
		return NONE

	if(!parent_obj.allowed(user))
		parent_obj.balloon_alert(user, "нет доступа!")
		return NONE

	playsound(parent_obj, 'sound/items/deconstruct.ogg', 40, TRUE)
	drop_new_access_control()
	return ITEM_INTERACT_SUCCESS

/datum/component/custom_access/proc/drop_new_access_control()
	var/obj/parent_obj = parent
	var/obj/item/access_control/access_control = new(get_turf(parent_obj))
	access_control.selected_accesses = copied_accesses
	access_control.one_access = copied_one_access
	access_control.emagged = emagged
	access_control.update_appearance(UPDATE_ICON_STATE)
	qdel(src)

/datum/component/custom_access/proc/on_emag_act(datum/source, mob/user)
	SIGNAL_HANDLER

	var/obj/parent_obj = parent
	INVOKE_ASYNC(src, PROC_REF(async_parent_emag_act), user)
	emagged = TRUE

/datum/component/custom_access/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_notice("Установлена плата доступа. [emagged ? "Плата испорчена и подлежит замене." : ""]")

/datum/component/custom_access/proc/check_this_component(datum/source, mob/user)
	SIGNAL_HANDLER

	to_chat(user, span_notice("Сначала вытащите старую плату доступа!"))
	return COMPONENT_CUSTOM_ACCESS_EXIST

/datum/component/custom_access/proc/on_object_deconstruct(datum/source, disassembled)
	SIGNAL_HANDLER

	drop_new_access_control()

/datum/component/custom_access/proc/async_parent_emag_act(mob/user)
	var/obj/parent_obj = parent
	parent_obj.emag_act(user)
