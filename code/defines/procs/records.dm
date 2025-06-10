/proc/CreateGeneralRecord()
	var/mob/living/carbon/human/dummy = new()
	dummy.mind = new()
	var/icon/front = new(get_id_photo(dummy), dir = SOUTH)
	var/icon/side = new(get_id_photo(dummy), dir = WEST)
	var/datum/data/record/G = new /datum/data/record()
	G.fields["name"] = "Новая Запись"
	G.fields["id"] = text("[]", add_zero(num2hex(rand(1, 1.6777215E7), 2), 6))
	G.fields["rank"] = "Не Присвоено"
	G.fields["real_rank"] = "Не Присвоено"
	G.fields["sex"] = "Мужской"
	G.fields["age"] = "Unknown"
	G.fields["fingerprint"] = "Unknown"
	G.fields["p_stat"] = "Active"
	G.fields["m_stat"] = "Stable"
	G.fields["species"] = SPECIES_HUMAN
	G.fields["home_system"]	= "Unknown"
	G.fields["citizenship"]	= "Unknown"
	G.fields["faction"]		= "Unknown"
	G.fields["religion"]	= "Unknown"
	G.fields["photo_front"]	= front
	G.fields["photo_side"]	= side
	GLOB.data_core.general += G

	qdel(dummy)
	return G

/proc/CreateSecurityRecord(var/name as text, var/id as text)
	var/datum/data/record/R = new /datum/data/record()
	R.fields["name"] = name
	R.fields["id"] = id
	R.name = text("Security Record #[id]")
	R.fields["criminal"] = "Нет"
	R.fields["mi_crim"] = "Нет"
	R.fields["mi_crim_d"] = "Отсутствие судимостей за Малозначительные преступления."
	R.fields["ma_crim"] = "Нет"
	R.fields["ma_crim_d"] = "Отсутствие судимостей за тяжкие преступления."
	R.fields["notes"] = "Нет примечаний."
	GLOB.data_core.security += R
	return R

/proc/find_security_record(field, value)
	return find_record(field, value, GLOB.data_core.security)

/proc/find_record(field, value, list/L)
	for(var/datum/data/record/R in L)
		if(R.fields[field] == value)
			return R
