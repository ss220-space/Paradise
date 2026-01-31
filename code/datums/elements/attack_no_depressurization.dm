/datum/element/attack_no_depressurization
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

/datum/element/attack_no_depressurization/Attach(datum/target)
	. = ..()
	RegisterSignal(target, COMSIG_TOOL_USE, PROC_REF(check_tool_use))
	RegisterSignal(target, COMSIG_ITEM_PRE_ATTACKBY, PROC_REF(check_attack))

/datum/element/attack_no_depressurization/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_TOOL_USE)
	UnregisterSignal(target, COMSIG_ITEM_PRE_ATTACKBY)

/datum/element/attack_no_depressurization/proc/check_tool_use(atom/target, mob/living/user)
	SIGNAL_HANDLER
	to_chat(user, span_userdanger("АААААААААААААА"))
	for(var/turf/turf_check in range(1, target))
		var/area/area_check = get_area(turf_check)
		if(isspaceturf(turf_check) || istype(area_check, /area/space))
			to_chat(user, span_danger("Вы не можете это сделать, это действие может привести к разгерметизации!"))
			return COMPONENT_BLOCK_TOOL_CHAIN

/datum/element/attack_no_depressurization/proc/check_attack(atom/target, mob/living/user)
	SIGNAL_HANDLER
	to_chat(user, span_userdanger("АААААААААААААА"))
	for(var/turf/turf_check in range(1, target))
		var/area/area_check = get_area(turf_check)
		if(isspaceturf(turf_check) || istype(area_check, /area/space))
			to_chat(user, span_danger("Вы не можете это сделать, это действие может привести к разгерметизации!"))
			return COMPONENT_CANCEL_ATTACK_CHAIN
