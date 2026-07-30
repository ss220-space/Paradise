#define VOX_TRADE_HIGHRISK_REWARD 2500
#define VOX_TRADE_VALUABLE_HIGHRISK_REWARD 5000

/datum/get_cost_step/highrisk_step
	var/list/highrisk_list = list()
	var/list/valuable_highrisk_list = list(
		/obj/item/areaeditor/blueprints/ce,
		/obj/item/disk/nuclear,
		/obj/item/clothing/suit/armor/reactive,
		/obj/item/documents,
	)

/datum/get_cost_step/highrisk_step/New()
	. = ..()
	for(var/theft_type in subtypesof(/datum/theft_objective))
		highrisk_list += new theft_type

/datum/get_cost_step/highrisk_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	for(var/datum/theft_objective/objective in highrisk_list)
		if(!istype(process_object, objective.typepath))
			continue

		var/temp_value = VOX_TRADE_HIGHRISK_REWARD
		if(objective.special_equipment)
			temp_value *= 2

		if(objective.protected_jobs)
			for(var/job in objective.protected_jobs)
				switch(job)
					if(JOB_TITLE_CAPTAIN, JOB_TITLE_HOS)
						temp_value *= 2
					else
						temp_value *= 1.5

		temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM_PRECIOUS] += temp_value

		if(process_object in valuable_highrisk_list)
			temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM_PRECIOUS] += VOX_TRADE_VALUABLE_HIGHRISK_REWARD

#undef VOX_TRADE_HIGHRISK_REWARD
#undef VOX_TRADE_VALUABLE_HIGHRISK_REWARD
