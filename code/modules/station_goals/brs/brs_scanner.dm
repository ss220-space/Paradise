/datum/component/bluespace_rift_scanner
	var/max_range

/datum/component/bluespace_rift_scanner/Initialize(max_range)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.max_range = max_range

/datum/component/bluespace_rift_scanner/RegisterWithParent()
	RegisterSignal(parent, COMSIG_SCANNING_RIFTS, PROC_REF(scan))

/datum/component/bluespace_rift_scanner/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_SCANNING_RIFTS)

/datum/component/bluespace_rift_scanner/proc/scan()
	SIGNAL_HANDLER
	return COMPONENT_SCANNED_NOTHING