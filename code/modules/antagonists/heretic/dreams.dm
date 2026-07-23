#define DREAM_VIEW_RANGE	5

/datum/antagonist/heretic/proc/get_dreams(mob/living/carbon/sleeper, list/dreams)
	SIGNAL_HANDLER
	if(!length(GLOB.reality_smash_track?.smashes))
		return
	dreams += "Вы бродите по лесу вокруг Обители"
	dreams += "Вы видите " + pick("пруд", "колодец", "озеро", "лужу", "ручей", "реку", "болото")

	if(isnull(dreams_allowed_typecaches_by_root_type))
		dreams_allowed_typecaches_by_root_type = list()
		for(var/type in dreams_what_you_can_see)
			dreams_allowed_typecaches_by_root_type[type] = typecacheof(type) - dreams_what_you_cant_see

	var/list/all_objects = oview(DREAM_VIEW_RANGE, pick(GLOB.reality_smash_track.smashes))
	var/something_found = FALSE
	for(var/object_type in dreams_allowed_typecaches_by_root_type)
		var/list/filtered_objects = typecache_filter_list(all_objects, dreams_allowed_typecaches_by_root_type[object_type])
		if(!filtered_objects.len)
			continue

		if(!something_found)
			dreams += "Вы видите отражение на поверхности воды"
			something_found = TRUE

		var/obj/found_object = pick(filtered_objects)
		dreams += found_object.declent_ru(NOMINATIVE)

	if(!something_found)
		dreams += pick("Вода полностью чёрная", "Отражение слишкмо размыто", "Вы бесцельно бродите")
	else
		dreams += "Изображения на поверхности воды постепенно рассеиваются"

	dreams += "Вы чувствуете сильную усталость"

#undef DREAM_VIEW_RANGE
