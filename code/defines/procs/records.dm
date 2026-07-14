/proc/CreateGeneralRecord()
	var/mob/living/carbon/human/dummy = new()
	dummy.mind = new()
	var/icon/front = new(get_id_photo(dummy), dir = SOUTH)
	var/icon/side = new(get_id_photo(dummy), dir = WEST)
	var/datum/data/record/record = new /datum/data/record()
	record.fields["name"] = "New Record"
	record.fields["id"] = text("[]", add_zero(num2hex(rand(1, SHORT_REAL_LIMIT), 2), 6))
	record.fields["rank"] = NOJOB_STATUS_RUS
	record.fields["real_rank"] = NOJOB_STATUS_RUS
	record.fields["sex"] = "Male"
	record.fields["age"] = UNKNOWN_STATUS_RUS
	record.fields["fingerprint"] = UNKNOWN_STATUS_RUS
	record.fields["p_stat"] = "Active"
	record.fields["m_stat"] = "Stable"
	record.fields["species"] = SPECIES_HUMAN
	record.fields["home_system"]	= UNKNOWN_STATUS_RUS
	record.fields["citizenship"]	= UNKNOWN_STATUS_RUS
	record.fields["faction"]		= UNKNOWN_STATUS_RUS
	record.fields["religion"]	= UNKNOWN_STATUS_RUS
	record.fields["photo_front"]	= front
	record.fields["photo_side"]	= side
	GLOB.data_core.general += record

	qdel(dummy)
	return record

/proc/CreateSecurityRecord(name as text, id as text)
	var/datum/data/record/record = new /datum/data/record()
	record.fields["name"] = name
	record.fields["id"] = id
	record.name = text("Security Record #[id]")
	record.fields["criminal"] = "None"
	record.fields["mi_crim"] = "None"
	record.fields["mi_crim_d"] = "No minor crime convictions."
	record.fields["ma_crim"] = "None"
	record.fields["ma_crim_d"] = "No major crime convictions."
	record.fields["notes"] = "No notes."
	LAZYINITLIST(record.fields["comments"])
	GLOB.data_core.security += record
	return record

/proc/find_security_record(field, value)
	return find_record(field, value, GLOB.data_core.security)

/proc/find_record(field, value, list/L)
	for(var/datum/data/record/record in L)
		if(record.fields[field] == value)
			return record
