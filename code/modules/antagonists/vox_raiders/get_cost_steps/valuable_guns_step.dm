/datum/get_cost_step/valuable_guns_step
	var/list/valuable_guns_dict = list(
		/obj/item/gun/energy/taser = 300,
		/obj/item/gun/energy/disabler = 100,
		/obj/item/gun/energy/lasercannon = 400,

		/obj/item/gun/energy/gun/blueshield = 300,
		/obj/item/gun/energy/gun/nuclear = 300,
		/obj/item/gun/energy/gun/advtaser = 500,
		/obj/item/gun/energy/gun = 150,

		/obj/item/gun/energy/pulse = 3000,
		/obj/item/gun/energy/ionrifle = 1000,
		/obj/item/gun/energy/decloner = 500,
		/obj/item/gun/energy/floragun = 500,
		/obj/item/gun/energy/meteorgun = 500,
		/obj/item/gun/energy/mindflayer = 500,
		/obj/item/gun/energy/wormhole_projector = 800,
		/obj/item/gun/energy/laser/instakill = 10000,
		/obj/item/gun/energy/laser/scatter = 500,
		/obj/item/gun/energy/sniperrifle = 1000,
		/obj/item/gun/energy/specter = 200,
		/obj/item/gun/energy/anomaly_stabilizer = 100,
		/obj/item/gun/energy/plasmacutter/adv = 300,
		/obj/item/gun/energy/laser = 200,
		/obj/item/gun/energy/kinetic_accelerator/crossbow = 500,

		/obj/item/gun/magic/staff = 10000,
		/obj/item/gun/magic/wand = 5000,
		/obj/item/gun/magic = 2000,

		/obj/item/gun/projectile/automatic/toy = 10,
		/obj/item/gun/projectile/automatic/lr30 = 800,
		/obj/item/gun/projectile/automatic/ik60 = 1000,
		/obj/item/gun/projectile/automatic/pistol = 300,
		/obj/item/gun/projectile/automatic/l6_saw = 3000,
		/obj/item/gun/projectile/automatic/sniper_rifle = 2000,
		/obj/item/gun/projectile/automatic = 500,
		/obj/item/gun/projectile/shotgun/winchester/cargo = 500,
		/obj/item/gun/projectile = 300,

		/obj/item/gun/projectile/revolver/rocketlauncher = 1000,
		/obj/item/gun/medbeam = 2000,
		/obj/item/gun/throw/crossbow = 300,
		/obj/item/gun/syringe = 200,
	)

/datum/get_cost_step/valuable_guns_step/can_process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	return isgun(process_object)

/datum/get_cost_step/valuable_guns_step/process_object(obj/process_object, obj/machinery/vox_trader/trader, list/temp_values)
	for(var/valuable_type in valuable_guns_dict)
		if(!istype(process_object, valuable_type))
			continue
		temp_values[TRAIDER_VALUE_TEMP_VALUES_SUM_PRECIOUS] += valuable_guns_dict[valuable_type]
		break
