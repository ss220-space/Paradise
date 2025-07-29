/**********************Prisoners' Console**************************/

/obj/machinery/mineral/labor_claim_console
	name = "point claim console"
	desc = "Консоль с электромагнитным записывающим устройством для учета добытой заключенными руды."
	ru_names = list(
		NOMINATIVE = "консоль учета добытой руды",
		GENITIVE = "консоли учета добытой руды",
		DATIVE = "консоли учета добытой руды",
		ACCUSATIVE = "консоль учета добытой руды",
		INSTRUMENTAL = "консолью учета добытой руды",
		PREPOSITIONAL = "консоли учета добытой руды"
	)
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = FALSE
	anchored = TRUE
	var/obj/machinery/mineral/stacking_machine/laborstacker/stacking_machine = null
	var/machinedir = SOUTH
	var/obj/item/card/id/prisoner/inserted_id
	var/obj/machinery/door/airlock/release_door
	var/door_tag = "prisonshuttle"
	var/obj/item/radio/intercom/announcer
	var/static/list/sheet_values

/obj/machinery/mineral/labor_claim_console/Initialize()
	. = ..()
	announcer = new /obj/item/radio/intercom(null)
	announcer.follow_target = src
	announcer.config(list(SEC_FREQ_NAME = 0))

	if(!sheet_values)
		for(var/sheet_type in subtypesof(/obj/item/stack/sheet))
			var/obj/item/stack/sheet/sheet = sheet_type
			if(!initial(sheet.point_value) || (initial(sheet.merge_type) && initial(sheet.merge_type) != sheet_type)) //ignore no-value sheets and x/fifty subtypes
				continue
			sheet_values += list(list("ore" = initial(sheet.name), "value" = initial(sheet.point_value)))
		sheet_values = sortTim(sheet_values, cmp = /proc/cmp_sheet_list)

/obj/machinery/mineral/labor_claim_console/Destroy()
	. = ..()
	QDEL_NULL(announcer)

/proc/cmp_sheet_list(list/a, list/b)
	return a["value"] - b["value"]


/obj/machinery/mineral/labor_claim_console/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/card/id/prisoner))
		add_fingerprint(user)
		if(inserted_id)
			to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] уже содержит другую ID-карту."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		inserted_id = I
		to_chat(user, span_notice("Вы вставили [I.declent_ru(ACCUSATIVE)] в [declent_ru(ACCUSATIVE)]."))
		SStgui.update_uis(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/mineral/labor_claim_console/attack_hand(mob/user)
	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)

/obj/machinery/mineral/labor_claim_console/attack_ghost(mob/user)
	attack_hand(user)

/obj/machinery/mineral/labor_claim_console/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LaborClaimConsole", name)
		ui.open()

/obj/machinery/mineral/labor_claim_console/ui_data(mob/user)
	var/list/data = list()
	var/can_go_home = FALSE

	data["emagged"] = emagged
	data["id_inserted"] = inserted_id != null
	if(inserted_id)
		data["id_name"] = inserted_id.registered_name
		data["id_points"] = inserted_id.mining_points
		data["id_goal"] = inserted_id.goal
	if(check_auth())
		can_go_home = TRUE

	if(stacking_machine)
		data["unclaimed_points"] = stacking_machine.points

	data["ores"] = sheet_values
	data["can_go_home"] = can_go_home

	return data

/obj/machinery/mineral/labor_claim_console/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("handle_id")
			if(inserted_id)
				inserted_id.forceMove_turf()
				usr.put_in_hands(inserted_id, ignore_anim = FALSE)
				inserted_id = null
			else
				var/obj/item/I = usr.get_active_hand()
				if(istype(I, /obj/item/card/id/prisoner))
					if(!usr.drop_transfer_item_to_loc(I, src))
						return
					inserted_id = I
		if("claim_points")
			if(!inserted_id)
				return
			inserted_id.mining_points += stacking_machine.points
			stacking_machine.points = 0
			to_chat(usr, "Очки переведены.")
		if("move_shuttle")
			if(!alone_in_area(get_area(src), usr))
				to_chat(usr, span_warning("Освобождение возможно только при отсутствии других заключенных."))
			else
				switch(SSshuttle.moveShuttle("laborcamp", "laborcamp_home", TRUE, usr))
					if(1)
						to_chat(usr, span_notice("Шаттл не обнаружен."))
					if(2)
						to_chat(usr, span_notice("Шаттл уже на станции."))
					if(3)
						to_chat(usr, span_notice("Не удалось получить разрешение на стыковку."))
					else
						if(!emagged)
							var/message = "[inserted_id.registered_name] вернулся на станцию. Минералы и ID-карта заключенного готовы к выдаче."
							announcer.autosay(message, "Labor Camp Controller", SEC_FREQ_NAME)
						to_chat(usr, span_notice("Сообщение получено, шаттл будет отправлен в ближайшее время."))
						add_misc_logs(usr, "used [src] to call the laborcamp shuttle")

	return TRUE

/obj/machinery/mineral/labor_claim_console/proc/check_auth()
	if(emagged)
		return TRUE //Shuttle is emagged, let any ol' person through
	return (istype(inserted_id) && inserted_id.mining_points >= inserted_id.goal) //Otherwise, only let them out if the prisoner's reached his quota.

/obj/machinery/mineral/labor_claim_console/emag_act(mob/user)
	if(!(emagged))
		emagged = TRUE
		if(user)
			to_chat(user, span_warning("PZZTTPFFFT"))


/**********************Prisoner Collection Unit**************************/
/obj/machinery/mineral/stacking_machine/laborstacker
	damage_deflection = 21
	var/points = 0 //The unclaimed value of ore stacked.

/obj/machinery/mineral/stacking_machine/laborstacker/process_sheet(obj/item/stack/sheet/inp)
	points += inp.point_value * inp.amount
	..()


/obj/machinery/mineral/stacking_machine/laborstacker/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/sheet) && user.can_unEquip(I))
		add_fingerprint(user)
		var/obj/item/stack/sheet/sheet = I
		points += sheet.point_value * sheet.amount
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/**********************Point Lookup Console**************************/
/obj/machinery/mineral/labor_points_checker
	name = "points checking console"
	desc = "Консоль для проверки заключенными прогресса выполнения квоты. Просто проведите картой заключенного."
	ru_names = list(
		NOMINATIVE = "консоль проверки очков",
		GENITIVE = "консоли проверки очков",
		DATIVE = "консоли проверки очков",
		ACCUSATIVE = "консоль проверки очков",
		INSTRUMENTAL = "консолью проверки очков",
		PREPOSITIONAL = "консоли проверки очков"
	)
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = FALSE
	anchored = TRUE

/obj/machinery/mineral/labor_points_checker/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.examinate(src)


/obj/machinery/mineral/labor_points_checker/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	var/obj/item/card/id/prisoner/prisoner_id = I.GetID()
	if(prisoner_id)
		add_fingerprint(user)
		if(!istype(prisoner_id, /obj/item/card/id/prisoner))
			to_chat(user, span_warning("Ошибка: Недействительная ID-карта."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("<b>ID: [prisoner_id.registered_name]</b>"))
		to_chat(user, span_notice("Накоплено очков: [prisoner_id.mining_points]"))
		to_chat(user, span_notice("Квота: [prisoner_id.goal]"))
		to_chat(user, span_notice("Зарабатывайте очки, доставляя переработанные минералы на упаковочную машину шаттла каторги. Выполните квоту для получения освобождения."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()
