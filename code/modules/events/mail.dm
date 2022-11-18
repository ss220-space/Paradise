// Creates boxes in cargo shuttle with mail for crew

/datum/event/mail
	endWhen = 3000


	var/list/to_receive = list()



//Get a name and rank in out list
/datum/event/mail/setup()
	for(var/datum/data/record/G in GLOB.data_core.general)
		to_receive.Add(G.fields["name"])

	// No names, no gains.
	if(!to_receive.len)
		log_debug("Никто не получил посылку. Ивент прерван.")
		kill(TRUE)

/datum/event/mail/announce()
	GLOB.command_announcement.Announce("Персональные посылки были отправлены на [station_name()] и будут доступны в отделе снабжения по прибытию грузового челнока.", pick("Планетарный экспресс", "Метеор Транспорт", "ТСФ Надежность", "Ко. Почтовые услоуги", "Курьеры Неподвижный Стержень"), zlevels = affecting_z)

/datum/event/proc/tick()
	var/obj/shuttle/docking_port/mobile/supply/supply = SSshuttle.supply

	if(!is_station_level(SSshuttle.supply.z) && SSshuttle.supply.mode == SHUTTLE_IDLE)
		if(spawn_mail())
			kill()

/datum/event/proc/start()

/datum/event/mail/proc/spawn_mail()
	var/obj/structure/largecrate/mail = new()
	mail.SetName("Почтовый ящик")

	for(var/name in to_receive)
		var/obj/item/storage/box/large/mail = new()
		mail.SetName("Ящик для [name]")

		if(prob(15))
		if(prob(2))
		var/mail_path = pick(traitor_mail)*2

		var/obj/item/smallDelivery/parcel = new /obj/item/smallDelivery()
		psrcel.SetName("normal-sized parcel (to [name])")
		mail.forceMove(parcel)

	if(!supply.addAtom(mail))
		log_debug("Failed to add mail crate to the supply shuttle!")
		qdel(mail)
		return FALSE

	return TRUE




/* var/gift_crate = new gift_crate(координаты)
if (chest.isFull)
   		 var/available_coordinates_for_chest = calculate_coords()
   		 if (!available_coordinates_for_chest)
     	 break
    	gift_crate = new gift_crate(available_coordinates_for_chest)
  		chest.add(to_receive) */
