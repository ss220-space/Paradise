/datum/component/virtual_entity
	COOLDOWN_DECLARE(alert_cooldown)

/datum/component/virtual_entity/Initialize(obj/machinery/quantum_server/server)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	if(server)
		RegisterSignal(server, COMSIG_BITRUNNER_SERVER_EMAGGED, PROC_REF(on_server_emagged))

/datum/component/virtual_entity/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE, PROC_REF(on_pre_move))

/datum/component/virtual_entity/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_MOVABLE_PRE_MOVE)

/datum/component/virtual_entity/proc/on_server_emagged(datum/source)
	SIGNAL_HANDLER

	var/obj/machinery/quantum_server/server = source
	server.announce_jailbreak(parent)
	qdel(src)

/datum/component/virtual_entity/proc/on_pre_move(atom/movable/source, atom/new_location)
	SIGNAL_HANDLER

	var/area/destination = get_area(new_location)
	if(isnull(destination) || !(destination.area_flags & VIRTUAL_SAFE_AREA))
		return

	if(COOLDOWN_FINISHED(src, alert_cooldown))
		source.balloon_alert(source, "за границей домена!")
		COOLDOWN_START(src, alert_cooldown, 2 SECONDS)

	return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
