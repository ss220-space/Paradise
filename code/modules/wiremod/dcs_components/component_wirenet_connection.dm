/datum/component/circuit_component_wirenet_connection

	var/atom/movable/tracked_shell

	var/atom/movable/tracked_movable
	var/obj/structure/cable/tracked_node
	var/datum/powernet/tracked_powernet

	/// Callback to invoke when the component is connected to a powernet
	var/datum/callback/connection_callback

	/// Callback to invoke when the component is disconnected from a powernet
	var/datum/callback/disconnection_callback

/datum/component/circuit_component_wirenet_connection/Initialize(datum/callback/connection_callback, datum/callback/disconnection_callback)
	. = ..()
	if(!is_circuit_component(parent))
		return COMPONENT_INCOMPATIBLE

	src.connection_callback = connection_callback
	src.disconnection_callback = disconnection_callback

/datum/component/circuit_component_wirenet_connection/Destroy(force)
	. = ..()
	connection_callback = null
	disconnection_callback = null

/datum/component/circuit_component_wirenet_connection/RegisterWithParent()
	RegisterSignal(parent, COMSIG_CIRCUIT_COMPONENT_ADDED, PROC_REF(on_parent_added_to_circuit))
	RegisterSignal(parent, COMSIG_CIRCUIT_COMPONENT_REMOVED, PROC_REF(on_parent_removed_from_circuit))

/datum/component/circuit_component_wirenet_connection/UnregisterFromParent()
	unset_shell()
	UnregisterSignal(parent, list(COMSIG_CIRCUIT_COMPONENT_PERFORM_ACTION, COMSIG_CIRCUIT_COMPONENT_ADDED, COMSIG_CIRCUIT_COMPONENT_REMOVED))

/datum/component/circuit_component_wirenet_connection/proc/on_parent_added_to_circuit(_source, obj/item/integrated_circuit/circuit)
	SIGNAL_HANDLER
	RegisterSignal(circuit, COMSIG_CIRCUIT_SET_SHELL, PROC_REF(on_circuit_set_shell))
	RegisterSignal(circuit, COMSIG_CIRCUIT_SHELL_REMOVED, PROC_REF(unset_shell))
	if(!circuit.shell)
		return

	set_shell(circuit.shell)

/datum/component/circuit_component_wirenet_connection/proc/on_parent_removed_from_circuit(_source, obj/item/integrated_circuit/circuit)
	SIGNAL_HANDLER
	unset_shell()
	UnregisterSignal(circuit, list(COMSIG_CIRCUIT_SET_SHELL, COMSIG_CIRCUIT_SHELL_REMOVED))

/datum/component/circuit_component_wirenet_connection/proc/on_circuit_set_shell(_source, atom/movable/shell)
	SIGNAL_HANDLER
	set_shell(shell)

/datum/component/circuit_component_wirenet_connection/proc/set_shell(atom/movable/new_shell)
	tracked_shell = new_shell
	if(!isassembly(new_shell))
		set_tracked_movable(new_shell)
		return

	RegisterSignal(new_shell, list(COMSIG_ASSEMBLY_ATTACHED, COMSIG_ASSEMBLY_ADDED_TO_BUTTON), PROC_REF(on_assembly_shell_attached))
	RegisterSignal(new_shell, list(COMSIG_ASSEMBLY_DETACHED, COMSIG_ASSEMBLY_REMOVED_FROM_BUTTON), PROC_REF(on_assembly_shell_detached))

/datum/component/circuit_component_wirenet_connection/proc/unset_shell()
	SIGNAL_HANDLER
	unset_tracked_movable()

	if(!tracked_shell)
		return

	if(isassembly(tracked_shell))
		UnregisterSignal(tracked_shell, list(COMSIG_ASSEMBLY_ATTACHED, COMSIG_ASSEMBLY_DETACHED, COMSIG_ASSEMBLY_ADDED_TO_BUTTON, COMSIG_ASSEMBLY_REMOVED_FROM_BUTTON))

	tracked_shell = null

/datum/component/circuit_component_wirenet_connection/proc/on_assembly_shell_attached(_source, atom/holder)
	SIGNAL_HANDLER
	if(!ismovable(holder))
		return

	set_tracked_movable(holder)

/datum/component/circuit_component_wirenet_connection/proc/on_assembly_shell_detached()
	SIGNAL_HANDLER
	unset_tracked_movable()

/datum/component/circuit_component_wirenet_connection/proc/set_tracked_movable(atom/movable/new_tracked_movable)
	if(tracked_movable == new_tracked_movable) //Should only happen when an assembly holder the assembly was attached to calls on_attach when it itself is attached to something
		return

	tracked_movable = new_tracked_movable
	RegisterSignal(new_tracked_movable, COMSIG_MOVABLE_SET_ANCHORED, PROC_REF(on_tracked_movable_set_anchored))
	RegisterSignal(new_tracked_movable, COMSIG_QDELETING, PROC_REF(unset_tracked_movable))
	if(!tracked_movable.anchored)
		return

	try_set_tracked_node()

/datum/component/circuit_component_wirenet_connection/proc/unset_tracked_movable()
	SIGNAL_HANDLER
	unset_tracked_node()

	if(!tracked_movable)
		return

	UnregisterSignal(tracked_movable, list(COMSIG_MOVABLE_SET_ANCHORED, COMSIG_QDELETING))
	tracked_movable = null

/datum/component/circuit_component_wirenet_connection/proc/on_tracked_movable_set_anchored(atom/movable/source, now_anchored)
	SIGNAL_HANDLER
	if(now_anchored)
		try_set_tracked_node()
		return

	unset_tracked_node()

/datum/component/circuit_component_wirenet_connection/proc/try_set_tracked_node()
	SIGNAL_HANDLER
	if(tracked_node)
		unset_tracked_node()

	var/turf/our_turf = get_turf(tracked_movable)
	var/obj/structure/cable/node = our_turf.get_cable_node()

	if(!node)
		return

	set_tracked_node(node)

/datum/component/circuit_component_wirenet_connection/proc/set_tracked_node(obj/structure/cable/node)
	tracked_node = node
	RegisterSignal(tracked_movable, COMSIG_MOVABLE_MOVED, PROC_REF(unset_tracked_node)) //Because of wack cases of something pushing an anchored object
	RegisterSignal(node, COMSIG_CABLE_ADDED_TO_POWERNET, PROC_REF(set_tracked_powernet))
	RegisterSignal(node, COMSIG_CABLE_REMOVED_FROM_POWERNET, PROC_REF(unset_tracked_powernet))
	RegisterSignal(node, COMSIG_QDELETING, PROC_REF(unset_tracked_node))
	if(!node.powernet)
		return

	set_tracked_powernet(node.powernet)

/datum/component/circuit_component_wirenet_connection/proc/unset_tracked_node()
	SIGNAL_HANDLER
	unset_tracked_powernet()

	if(!tracked_node)
		return

	UnregisterSignal(tracked_movable, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(tracked_node, list(COMSIG_CABLE_ADDED_TO_POWERNET, COMSIG_CABLE_REMOVED_FROM_POWERNET, COMSIG_QDELETING))
	tracked_node = null

/datum/component/circuit_component_wirenet_connection/proc/set_tracked_powernet(datum/powernet/source)
	SIGNAL_HANDLER
	tracked_powernet = source
	connection_callback?.Invoke(source)

/datum/component/circuit_component_wirenet_connection/proc/unset_tracked_powernet()
	SIGNAL_HANDLER
	if(!tracked_powernet)
		return

	disconnection_callback?.Invoke(tracked_powernet)
	tracked_powernet = null

