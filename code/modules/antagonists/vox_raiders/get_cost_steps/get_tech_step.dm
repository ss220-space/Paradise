/datum/get_cost_step/get_tech/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return process_object.origin_tech && !temp_values[TRAIDER_VALUE_ORIGIN_TECH]

/datum/get_cost_step/get_tech/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	temp_values[TRAIDER_VALUE_ORIGIN_TECH] = params2list(process_object.origin_tech)

/datum/get_cost_step/get_tech_from_disk/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return istype(process_object, /obj/item/disk/tech_disk) && !temp_values[TRAIDER_VALUE_ORIGIN_TECH]

/datum/get_cost_step/get_tech_from_disk/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	var/obj/item/disk/tech_disk/disk = process_object
	var/datum/tech/disk_tech = disk.stored
	var/list/tech_list = list()
	if(disk_tech.id)
		tech_list[disk_tech.id] = disk_tech.level
	temp_values[TRAIDER_VALUE_ORIGIN_TECH] = tech_list
