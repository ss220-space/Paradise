/datum/component/blob_turf_consuming
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Number of attempts of consume neede for consume
	var/consumes_needed = 0
	/// Total number of attempts of consume
	var/total_consumes = 0

/datum/component/blob_turf_consuming/Initialize(_consumes_needed)
	if(!isturf(parent))
		return COMPONENT_INCOMPATIBLE

	consumes_needed = _consumes_needed

/datum/component/blob_turf_consuming/RegisterWithParent()
	RegisterSignal(parent, COMSIG_TRY_CONSUME_TURF, PROC_REF(on_try_consume))

/datum/component/blob_turf_consuming/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_TRY_CONSUME_TURF)


/datum/component/blob_turf_consuming/InheritComponent(datum/component/blob_turf_consuming/new_comp , i_am_original, _consumes_needed)
	if(new_comp)
		consumes_needed = new_comp.consumes_needed
	else
		consumes_needed = _consumes_needed


/datum/component/blob_turf_consuming/proc/on_try_consume()
	total_consumes++
	if(total_consumes >= consumes_needed)
		var/turf/total_turf = parent
		total_turf.blob_consume()
		return
	return COMPONENT_CANT_CONSUME
