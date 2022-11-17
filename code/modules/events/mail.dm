// Создает ящик с личными посылками для членов экипажа //

/datum/event/mail
	endWhen = 3000

	// Список получателей //
	var/list/to_receive = list()



//Добавляем имя получателей посылки из общего списка рекордсов в список//
/datum/event/mail/setup()
	for(var/datum/data/record/G in GLOB.data_core.general)
		to_receive.Add(G.fields["name"], G.fields["rank"])

	// Никого нет. Значит и посылки не заслужили >:[ //
	if(!to_receive.len)
		log_debug("Никто не получил посылку. Ивент прерван.")
		kill(TRUE)

/datum/event/mail/announce()
	GLOB.command_announcement.Announce("Персональные посылки были отправлены на [station_name()] и будут доступны в отделе снабжения по прибытию грузового челнока.", pick("Планетарный экспресс", "Метеор Транспорт", "ТСФ Надежность", "Ко. Почтовые услоуги", "Курьеры Неподвижный Стержень"), zlevels = affecting_z)

/datum/event/proc/tick()
	var/obj/shuttle/docking_port/mobile/supply/supply = SSshuttle.supply

	//Если шаттл не на станции и бездейдействует - спавним посылочки.
	if(!is_station_level(SSshuttle.supply.z) && SSshuttle.supply.mode == SHUTTLE_IDLE)
		if(spawn_mail())
			kill()

/datum/event/proc/start()

/datum/event/mail/proc/spawn_mail()
	var/obj/structure/closet/crate/gift_crate = new()
	gift_crate.SetName("Почтовый ящик")

	for(var/letter in to_receive)












	if(!supply.addAtom(gift_crate))
		log_debug("Failed to add mail crate to the supply shuttle!")
		qdel(gift_crate)
		return FALSE

	return TRUE




/* var/gift_crate = new gift_crate(координаты)
if (chest.isFull)
   		 var/available_coordinates_for_chest = calculate_coords()
   		 if (!available_coordinates_for_chest)
     	 break
    	gift_crate = new gift_crate(available_coordinates_for_chest)
  		chest.add(to_receive) */
