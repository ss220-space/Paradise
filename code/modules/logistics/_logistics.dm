GLOBAL_LIST_EMPTY(logistics_nets)

/datum/element/logistics_compatible
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/logistics_compatible/Attach(datum/target)
	. = ..()
	if(!ismachinery(target))
		return ELEMENT_INCOMPATIBLE
	ADD_TRAIT(target, TRAIT_LOGISTICS_COMPATIBLE, ELEMENT_TRAIT(type))
	RegisterSignal(target, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE, PROC_REF(on_host_initialized))

/datum/element/logistics_compatible/Detach(datum/source)
	UnregisterSignal(source, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE)
	REMOVE_TRAIT(source, TRAIT_LOGISTICS_COMPATIBLE, ELEMENT_TRAIT(type))
	return ..()

/datum/element/logistics_compatible/proc/on_host_initialized(obj/machinery/machine)
	SIGNAL_HANDLER
	machine.try_install_logistics_preset()
