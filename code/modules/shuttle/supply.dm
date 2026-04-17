/obj/item/paper/manifest
	name = "supply manifest"
	var/erroneous = 0
	var/points = 0
	var/ordernumber = 0

/obj/item/paper/manifest/get_ru_names()
	return list(
		NOMINATIVE = "манифест снабжения",
		GENITIVE = "манифеста снабжения",
		DATIVE = "манифесту снабжения",
		ACCUSATIVE = "манифест снабжения",
		INSTRUMENTAL = "манифестом снабжения",
		PREPOSITIONAL = "манифесте снабжения",
	)

/obj/docking_port/mobile/supply
	name = "supply shuttle"
	id = "supply"
	callTime = 1200

	dir = 8
	width = 12
	dwidth = 5
	height = 7
	roundstart_move = "supply_away"

/obj/docking_port/mobile/supply/proc/forbidden_atoms_check(atom/A)
	var/static/list/cargo_blacklist = list(
		/obj/structure/blob,
		/obj/structure/spider/spiderling,
		/obj/item/disk/nuclear,
		/obj/machinery/nuclearbomb,
		/obj/item/beacon,
		/obj/machinery/the_singularitygen,
		/obj/singularity,
		/obj/machinery/teleport/station,
		/obj/machinery/teleport/hub,
		/obj/machinery/telepad,
		/obj/machinery/telepad_cargo,
		/obj/machinery/clonepod,
		/obj/effect/hierophant,
		/obj/item/warp_cube,
		/obj/machinery/quantumpad,
		/obj/structure/extraction_point,
		/obj/item/paicard
	)
	if(A)
		if(isliving(A))
			if(!istype(A.loc, /obj/item/mobcapsule))
				return TRUE
			var/mob/living/living = A
			if(living.client) //You cannot get out of the capsule and you will be destroyed. Saving clients
				return TRUE
		if(is_type_in_list(A, cargo_blacklist))
			return TRUE
		for(var/thing in A)
			if(.(thing))
				return TRUE

	return FALSE

/obj/docking_port/mobile/supply/register()
	if(!..())
		return 0
	SSshuttle.supply = src
	return 1

/obj/docking_port/mobile/supply/canMove()
	if(is_station_level(z))
		return forbidden_atoms_check(areaInstance)
	return ..()

/obj/docking_port/mobile/supply/request(obj/docking_port/stationary/S)
	if(mode != SHUTTLE_IDLE)
		return 2
	return ..()

/obj/docking_port/mobile/supply/dock(obj/docking_port/stationary/S1, force, transit)
	. = ..()
	if(.)	return .

	buy(S1)
	sell(S1)

/obj/docking_port/mobile/supply/proc/buy(obj/docking_port/stationary/destination)
	if(!is_station_level(destination.z))
		return 1

	if(!length(SSshuttle.shoppinglist))
		return 2

	var/list/emptyTurfs = list()
	for(var/turf/simulated/T in areaInstance)
		if(T.density)
			continue

		var/contcount
		for(var/atom/A in T.contents)
			if(!A.simulated)
				continue

			if(is_light(A))
				continue

			if(istype(A, /obj/machinery/light))
				continue //hacky but whatever, shuttles need three spots each for this shit
			contcount++

		if(contcount)
			continue

		emptyTurfs += T

	for(var/datum/supply_order/SO in SSshuttle.shoppinglist)
		if(!SO.object)
			stack_trace("Supply Order [SO] has no object associated with it.")
			continue

		var/turf/T = pick_n_take(emptyTurfs)		//turf we will place it in
		if(!T)
			SSshuttle.shoppinglist.Cut(1, SSshuttle.shoppinglist.Find(SO))
			return

		var/errors = 0
		if(prob(5))
			errors |= MANIFEST_ERROR_COUNT
			investigate_log("Supply order #[SO] generated a manifest with packages incorrectly counted.", INVESTIGATE_CARGO)
		if(prob(5))
			errors |= MANIFEST_ERROR_NAME
			investigate_log("Supply order #[SO] generated a manifest with destination station incorrect.", INVESTIGATE_CARGO)
		if(prob(5))
			errors |= MANIFEST_ERROR_ITEM
			investigate_log("Supply order #[SO] generated a manifest with package incomplete.", INVESTIGATE_CARGO)
		SO.createObject(T, errors)

	SSshuttle.shoppinglist.Cut()

/obj/docking_port/mobile/supply/proc/sell(obj/docking_port/stationary/destination)
	if(destination.z != level_name_to_num(CENTCOMM))		//we only sell when we are -at- centcomm
		return TRUE

	var/crate_count = 0
	var/quest_reward

	var/msg = "<center>---[station_time_timestamp()]---</center><br>"
	var/pointsEarned

	for(var/atom/movable/MA in areaInstance)
		if(MA.anchored)
			continue
		if(istype(MA, /mob/dead))
			continue
		SSshuttle.sold_atoms += " [MA.declent_ru(NOMINATIVE)]"

		if(istype(MA, /obj/structure/bigDelivery))
			quest_reward += SScargo_quests.check_delivery(MA)

		// Must be in a crate (or a critter crate)!
		if(istype(MA,/obj/structure/closet/crate) || istype(MA,/obj/structure/closet/crate/critter))
			SSshuttle.sold_atoms += ":"
			if(!length(MA.contents))
				SSshuttle.sold_atoms += " (пусто)"
			++crate_count

			var/find_slip = TRUE
			for(var/obj/item/thing in MA)
				// Sell manifests
				SSshuttle.sold_atoms += " [thing.declent_ru(NOMINATIVE)]"
				if(find_slip && istype(thing,/obj/item/paper/manifest))
					var/obj/item/paper/manifest/slip = thing
					// TODO: Check for a signature, too.
					var/slip_stamped_len = LAZYLEN(slip.stamped)
					if(slip_stamped_len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
						// Did they mark it as erroneous?
						var/denied = FALSE
						for(var/i in 1 to slip_stamped_len)
							if(slip.stamped[i] == /obj/item/stamp/denied)
								denied = TRUE
						if(slip.erroneous && denied) // Caught a mistake by Centcom (IDEA: maybe Centcom rarely gets offended by this)
							pointsEarned = slip.points - SSshuttle.points_per_crate
							SSshuttle.points += pointsEarned // For now, give a full refund for paying attention (minus the crate cost)
							msg += "[span_good("+[pointsEarned]")]: Объект корректно отклонил груз [slip.ordernumber]: "
							if(slip.erroneous & MANIFEST_ERROR_NAME)
								msg += "Некорректный пункт назначения. "
							else if(slip.erroneous & MANIFEST_ERROR_COUNT)
								msg += "Ошибочный подсчёт грузов. "
							else if(slip.erroneous & MANIFEST_ERROR_ITEM)
								msg += "Недокомплектованный груз. "
							msg += "Очки возвращены.<br>"
						else if(!slip.erroneous && !denied) // Approving a proper order awards the relatively tiny points_per_slip
							SSshuttle.points += SSshuttle.points_per_slip
							msg += "[span_good("+[SSshuttle.points_per_slip]")]: Груз [slip.ordernumber] обозначен корректно.<br>"
						else // You done goofed.
							if(slip.erroneous)
								msg += "[span_good("+0")]: Груз [slip.ordernumber] одобрен, несмотря на ошибку: "
								if(slip.erroneous & MANIFEST_ERROR_NAME)
									msg += "Некорректный пункт назначения."
								else if(slip.erroneous & MANIFEST_ERROR_COUNT)
									msg += "Ошибочный подсчёт грузов."
								else if(slip.erroneous & MANIFEST_ERROR_ITEM)
									msg += "Обнаружены незафиксированные грузы."
								msg += "  Будьте внимательнее.<br>"
							else
								pointsEarned = round(SSshuttle.points_per_crate - slip.points)
								SSshuttle.points += pointsEarned
								msg += "[span_bad("[pointsEarned]")]: Объект отклонил груз [slip.ordernumber]. Отчёты показывают, что ошибка не на нашей стороне.<br>"
						find_slip = FALSE
					continue

				// Sell intel
				if(istype(thing, /obj/item/documents))
					var/obj/item/documents/docs = thing
					if(INTEREST_NANOTRASEN & docs.sell_interest)
						pointsEarned = round(SSshuttle.points_per_intel * docs.sell_multiplier)
						SSshuttle.points += pointsEarned
						msg += "[span_good("+[pointsEarned]")]: Получены важные разведданые.<br>"

				// Send tech levels
				if(istype(thing, /obj/item/disk/tech_disk))
					var/obj/item/disk/tech_disk/disk = thing
					if(!disk.stored) continue
					var/datum/tech/tech = disk.stored

					var/cost = tech.getCost(SSshuttle.techLevels[tech.id])
					if(tech.level >= 7)
						SScapitalism.base_account.credit(7000, "Благодарность за вклад в науку.", "Терминал Института \"Нанотрейзен\" №[rand(111,333)]", "Институт \"Нанотрейзен\"")
					if(cost)
						SSshuttle.techLevels[tech.id] = tech.level
						for(var/mob/mob in GLOB.player_list)
							if(!mob.mind)
								continue
							for(var/datum/job_objective/further_research/objective in mob.mind.job_objectives)
								objective.unit_completed(round(cost / 3))
						msg += "[tech.name] — новые данные.<br>"

		if(istype(MA, /obj/structure/closet/crate/critter/mecha))
			var/obj/structure/closet/crate/critter/mecha/crate = MA
			if(crate.console && crate.quest)
				for(var/category in crate.quest.reward)
					crate.quest.reward[category] -= crate.penalty
					if(crate.quest.reward[category] < 0)
						crate.quest.reward[category] = 0
					crate.console.points[category] += crate.quest.reward[category]
				pointsEarned = crate.quest.reward["robo"] * 30
				SSshuttle.points += pointsEarned
				if(crate.quest.id)
					var/datum/money_account/A = get_money_account(crate.quest.id.associated_account_number)
					if(A)
						A.money += crate.quest.maximum_cash - round(crate.quest.maximum_cash * crate.penalty / 4)
				SSshuttle.cargo_money_account.money += crate.quest.maximum_cash - round(crate.quest.maximum_cash * crate.penalty / 4)
				crate.console.on_quest_complete()
				msg += "[span_good("+[pointsEarned]")]: Получен запрошенный экзоскелет: [crate.quest.name].<br>"
				crate.quest.id.robo_bounty = null
				crate.quest = null

		qdel(MA, force = TRUE)
		SSshuttle.sold_atoms += "."

	if(quest_reward > 0)
		msg += "[span_good("+[quest_reward]")]: Получены очки за заказы.<br>"
		SSshuttle.points += quest_reward

	if(crate_count > 0)
		pointsEarned = round(crate_count * SSshuttle.points_per_crate)
		msg += "[span_good("+[pointsEarned]")]: Получен[declension_ru(crate_count, "", "ы", "о")] [crate_count] ящик[DECL_CREDIT(crate_count)].<br>"
		SSshuttle.points += pointsEarned

	SSshuttle.centcom_message += "[msg]<hr>"

/********************
	SUPPLY ORDER
 ********************/
/datum/supply_order
	var/ordernum
	var/datum/supply_packs/object = null
	var/orderedby = null
	var/orderedbyRank
	var/comment = null
	var/crates

/datum/supply_order/proc/generateRequisition(atom/_loc)
	if(!object)
		return

	var/obj/item/paper/reqform = new /obj/item/paper(_loc)
	playsound(_loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, TRUE)
	reqform.name = "запрос на поставку — [crates] \"[object.name]\" для [orderedby]"
	reqform.ru_names = new /list(6)
	reqform.ru_names = list(
		NOMINATIVE = "запрос на поставку — [crates] \"[object.name]\" для [orderedby]",
		GENITIVE = "запроса на поставку — [crates] \"[object.name]\" для [orderedby]",
		DATIVE = "запросу на поставку — [crates] \"[object.name]\" для [orderedby]",
		ACCUSATIVE = "запрос на поставку — [crates] \"[object.name]\" для [orderedby]",
		INSTRUMENTAL = "запросом на поставку — [crates] \"[object.name]\" для [orderedby]",
		PREPOSITIONAL = "запросе на поставку — [crates] \"[object.name]\" для [orderedby]",
	)
	reqform.info += "<h3>[station_name()] — запрос на поставку грузов</h3><hr>"
	reqform.info += "ИНДЕКС: №[SSshuttle.ordernum]<br>"
	reqform.info += "ЗАПРОСИВШИЙ: [orderedby]<br>"
	reqform.info += "ПРИОРИТЕТ: [orderedbyRank]<br>"
	reqform.info += "ПРИЧИНА: [comment]<br>"
	reqform.info += "ТИП ГРУЗА: [object.name]<br>"
	reqform.info += "КОЛИЧЕСТВО ЯЩИКОВ: [crates]<br>"
	reqform.info += "ТРЕБОВАНИЯ К ДОСТУПУ: [object.access ? get_access_desc(object.access) : "Нет"]<br>"
	reqform.info += "СОДЕРЖИМОЕ:<br>"
	reqform.info += object.manifest
	reqform.info += "<hr>"
	reqform.info += "ПОСТАВЬТЕ ПЕЧАТЬ НИЖЕ ДЛЯ ОДОБРЕНИЯ ЗАПРОСА:<br>"

	reqform.update_icon()	//Fix for appearing blank when printed.

	return reqform

/datum/supply_order/proc/createObject(atom/_loc, errors=0)
	if(!object)
		return
	//create the crate
	var/atom/Crate = new object.containertype(_loc)
	Crate.name = "[object.containername] [comment ? "([comment])":"" ]"
	Crate.ru_names = new /list(6)
	for(var/i = 1; i <= 6; i++)
		if(i < length(object.container_ru_names))
			Crate.ru_names[i] = "[object.container_ru_names[i]] [comment ? "([comment])":"" ]"
		else
			Crate.ru_names[i] = Crate.name

	if(object.access)
		Crate:req_access = list(text2num(object.access))

	//create the manifest slip
	var/obj/item/paper/manifest/slip = new()
	slip.erroneous = errors
	slip.points = object.cost
	slip.ordernumber = ordernum

	var/stationName = (errors & MANIFEST_ERROR_NAME) ? new_station_name() : station_name()
	var/packagesAmt = length(SSshuttle.shoppinglist) + ((errors & MANIFEST_ERROR_COUNT) ? rand(1,2) : 0)

	slip.name = "Манифест поставки – \"[object.name]\" для [orderedby]"
	slip.ru_names = new /list(6)
	slip.ru_names = list(
		NOMINATIVE = "манифест поставки – \"[object.name]\" для [orderedby]",
		GENITIVE = "манифеста поставки – \"[object.name]\" для [orderedby]",
		DATIVE = "манифесту поставки – \"[object.name]\" для [orderedby]",
		ACCUSATIVE = "манифест поставки – \"[object.name]\" для [orderedby]",
		INSTRUMENTAL = "манифестом поставки – \"[object.name]\" для [orderedby]",
		PREPOSITIONAL = "манифесте поставки – \"[object.name]\" для [orderedby]",
	)
	slip.info = "<h3>[command_name()] Манифест поставки</h3><hr><br>"
	slip.info +="Заказ: №[ordernum]<br>"
	slip.info +="Пункт назначения: [stationName]<br>"
	slip.info +="Запросивший: [orderedby]<br>"
	slip.info +="Приоритет: [orderedbyRank]<br>"
	slip.info +="Причина: [comment]<br>"
	slip.info +="Тип груза: [object.name]<br>"
	slip.info +="Требования к доступу: [object.access ? get_access_desc(object.access) : "Нет"]<br>"
	slip.info +="[packagesAmt] ЯЩИК[declension_ru(packagesAmt, "", "А", "ОВ")] В ЗАКАЗЕ<br>"
	slip.info +="СОДЕРЖИМОЕ:<br><ul>"

	//we now create the actual contents
	var/list/contains
	if(istype(object, /datum/supply_packs/misc/randomised))
		var/datum/supply_packs/misc/randomised/SO = object
		contains = list()
		if(length(object.contains))
			for(var/j=1, j<=SO.num_contained, j++)
				contains += pick(object.contains)
	else
		contains = object.contains

	for(var/typepath in contains)
		if(!typepath)	continue
		var/atom/A = new typepath(Crate)
		if(object.amount && A.vars.Find("amount") && A:amount)
			A:amount = object.amount
		slip.info += "<li>[A.declent_ru(NOMINATIVE)]</li>"	//add the item to the manifest (even if it was misplaced)

	if(istype(Crate, /obj/structure/closet/crate/critter)) // critter crates do not actually spawn mobs yet and have no contains var, but the manifest still needs to list them
		var/obj/structure/closet/crate/critter/CritCrate = Crate
		if(CritCrate.content_mob)
			var/mob/crittername = CritCrate.content_mob
			slip.info += "<li>[crittername.declent_ru(NOMINATIVE)]</li>"

	if(errors & MANIFEST_ERROR_ITEM)
		//secure and large crates cannot lose items
		if(findtext("[object.containertype]", "/secure/") || findtext("[object.containertype]","/largecrate/"))
			errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lostAmt = max(round(length(Crate.contents)/10), 1)
			//lose some of the items
			while(--lostAmt >= 0)
				qdel(pick(Crate.contents))

	//manifest finalisation
	slip.info += "</ul><br>"
	slip.info += "ПРОВЕРЬТЕ СОДЕРЖИМОЕ И ПОСТАВЬТЕ ПЕЧАТЬ ПОД ЛИНИЕЙ, ЧТОБЫ ПОДТВЕРДИТЬ КОРРЕКТНОСТЬ МАНИФЕСТА<hr>" // And now this is actually meaningful.
	slip.loc = Crate
	if(istype(Crate, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/CR = Crate
		CR.manifest = slip
		CR.update_icon(UPDATE_OVERLAYS)
		CR.announce_beacons = object.announce_beacons.Copy()
	if(istype(Crate, /obj/structure/closet/crate/large))
		var/obj/structure/closet/crate/large/LC = Crate
		LC.manifest = slip
		LC.update_icon(UPDATE_OVERLAYS)

	return Crate

/***************************
	ORDER/REQUESTS CONSOLE
 **************************/
/obj/machinery/computer/supplycomp
	name = "Supply Shuttle Console"
	desc = "Компьютер, используемый для оформления заказов на поставку. Предназначен для пользования персоналом Отдела снабжения."
	icon_screen = "supply"
	req_access = list(ACCESS_CARGO)
	circuit = /obj/item/circuitboard/supplycomp
	/// Is this a public console (Confirm + Shuttle controls are not visible)
	var/is_public = FALSE
	/// Can we order special supplies
	var/hacked = FALSE
	/// Can we order contraband
	var/can_order_contraband = FALSE

/obj/machinery/computer/supplycomp/get_ru_names()
	return list(
		NOMINATIVE = "консоль оформления заказов",
		GENITIVE = "консоли оформления заказов",
		DATIVE = "консоли оформления заказов",
		ACCUSATIVE = "консоль оформления заказов",
		INSTRUMENTAL = "консолью оформления заказов",
		PREPOSITIONAL = "консоли оформления заказов",
	)

/obj/machinery/computer/supplycomp/public
	name = "Supply Ordering Console"
	desc = "Используется для оформления заказов. Предназначено для общего пользования."
	icon_screen = "request"
	circuit = /obj/item/circuitboard/ordercomp
	req_access = list()
	is_public = TRUE

/obj/machinery/computer/supplycomp/public/get_ru_names()
	return list(
		NOMINATIVE = "публичная консоль оформления заказов",
		GENITIVE = "публичной консоли оформления заказов",
		DATIVE = "публичной консоли оформления заказов",
		ACCUSATIVE = "публичную консоль оформления заказов",
		INSTRUMENTAL = "публичной консолью оформления заказов",
		PREPOSITIONAL = "публичной консоли оформления заказов",
	)

/obj/machinery/computer/supplycomp/Initialize(mapload, obj/structure/computerframe/frame)
	. = ..()

	var/obj/item/circuitboard/supplycomp/my_circuit = src.frame.circuit
	if(!istype(my_circuit))
		return

	can_order_contraband = my_circuit.contraband_enabled

/obj/machinery/computer/supplycomp/attack_ai(mob/user as mob)
	return attack_hand(user)

/obj/machinery/computer/supplycomp/attack_hand(mob/user as mob)
	if(!allowed(user) && !isobserver(user))
		user.balloon_alert(user, "отказано в доступе!")
		playsound(src, SFX_BUTTON_DENIED, 20)
		return 1

	if(..())
		return TRUE

	add_fingerprint(user)
	ui_interact(user)
	return

/obj/machinery/computer/supplycomp/emag_act(mob/user)
	if(!hacked)
		add_attack_logs(user, src, "emagged")
		if(user)
			user.balloon_alert(user, "открыты дополнительные заказы")
		hacked = TRUE
		return

/obj/machinery/computer/supplycomp/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoConsole", DECLENT_RU_CAP(src, NOMINATIVE))
		ui.open()

/obj/machinery/computer/supplycomp/ui_data(mob/user)
	var/list/data = list()

	var/list/requests_list = list()
	for(var/set_name in SSshuttle.requestlist)
		var/datum/supply_order/SO = set_name
		if(SO)
			if(!SO.comment)
				SO.comment = "Без комментариев."
			var/list/pack_techs = list()
			if(length(SO.object.required_tech))
				for(var/tech_id in SO.object.required_tech)
					pack_techs += "[CallTechName(tech_id)]: [SO.object.required_tech[tech_id]];  "
			requests_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment, "command1" = list("confirmorder" = SO.ordernum), "command2" = list("rreq" = SO.ordernum), "pack_techs" = pack_techs.Join(""))))
	data["requests"] = requests_list

	var/list/orders_list = list()
	for(var/set_name in SSshuttle.shoppinglist)
		var/datum/supply_order/SO = set_name
		if(SO)
			orders_list.Add(list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment)))
	data["orders"] = orders_list

	data["is_public"] = is_public

	data["canapprove"] = (SSshuttle.supply.getDockedId() == "supply_away") && !(SSshuttle.supply.mode != SHUTTLE_IDLE) && !is_public
	data["points"] = round(SSshuttle.points)
	data["credits"] = SSshuttle.cargo_money_account.money

	data["moving"] = SSshuttle.supply.mode != SHUTTLE_IDLE
	data["at_station"] = SSshuttle.supply.getDockedId() == "supply_home"
	data["timeleft"] = SSshuttle.supply.timeLeft(600)
	data["can_launch"] = !SSshuttle.supply.canMove()

	return data

/obj/machinery/computer/supplycomp/ui_static_data(mob/user)
	var/list/data = list()
	var/list/packs_list = list()

	for(var/set_name in SSshuttle.supply_packs)
		var/datum/supply_packs/pack = SSshuttle.supply_packs[set_name]
		var/has_sale = pack.cost < initial(pack.cost)
		var/is_enough_techs = TRUE
		for(var/tech_id in pack.required_tech)
			if(!SSshuttle.techLevels[tech_id] || pack.required_tech[tech_id] > SSshuttle.techLevels[tech_id])
				is_enough_techs = FALSE
		if((pack.hidden && hacked) || (pack.contraband && can_order_contraband) || (pack.special && pack.special_enabled) || (!pack.contraband && !pack.hidden && !pack.special))
			packs_list.Add(list(list("name" = pack.name, "cost" = pack.cost, "creditsCost" = pack.credits_cost, "ref" = "[pack.UID()]", "contents" = pack.ui_manifest, "cat" = pack.group, "has_sale" = has_sale, "is_enough_techs" = is_enough_techs)))

	data["supply_packs"] = packs_list

	var/list/categories = list() // meow
	for(var/category in GLOB.all_supply_groups)
		categories.Add(list(list("name" = get_supply_group_name(category), "category" = category)))
	if(!(src.can_order_contraband))
		categories.Cut(SUPPLY_CONTRABAND) //cutting contraband category
	data["categories"] = categories

	return data

/obj/machinery/computer/supplycomp/proc/is_authorized(mob/user)
	if(allowed(user))
		return TRUE

	if(user.can_admin_interact())
		return TRUE

	return FALSE

/obj/machinery/computer/supplycomp/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	// If its not a public console, and they aint authed, dont let them use this
	if(!is_public && !is_authorized(usr))
		return

	if(!SSshuttle)
		stack_trace("The SSshuttle controller datum is missing somehow.")
		return

	. = TRUE
	add_fingerprint(usr)

	switch(action)
		if("moveShuttle")
			// Public consoles cant move the shuttle. Dont allow exploiters.
			if(is_public)
				return
			if(SSshuttle.supply.canMove())
				to_chat(usr, span_warning("По соображениям безопасности шаттл снабжения не может перемещать живые организмы, ядерное оружие или маячки перемещния."))
			else if(SSshuttle.supply.getDockedId() == "supply_home")
				SSshuttle.toggleShuttle("supply", "supply_home", "supply_away", 1)
				investigate_log("[key_name_log(usr)] has sent the supply shuttle away. Remaining points: [SSshuttle.points]. Shuttle contents: [SSshuttle.sold_atoms]", INVESTIGATE_CARGO)
			else if(!SSshuttle.supply.request(SSshuttle.getDock("supply_home")))
				if(LAZYLEN(SSshuttle.shoppinglist) && prob(10))
					var/datum/supply_order/O = new /datum/supply_order()
					O.ordernum = SSshuttle.ordernum
					O.object = SSshuttle.supply_packs[pick(SSshuttle.supply_packs)]
					O.orderedby = random_name(pick(MALE,FEMALE), species = SPECIES_HUMAN)
					SSshuttle.shoppinglist += O
					investigate_log("Random [O.object] crate added to supply shuttle", INVESTIGATE_CARGO)

		if("order")

			var/datum/supply_packs/P = locateUID(params["crate"])
			if(!istype(P))
				return
/*

			if(P.times_ordered >= P.order_limit && P.order_limit != -1) //If the crate has reached the limit, do not allow it to be ordered.
				to_chat(usr, span_warning("[P.name] is out of stock, and can no longer be ordered."))	// Unused for now (Crate limit #3056).
				return	*/

			var/amount = 1
			if(params["multiple"])
				var/num_input = tgui_input_number(ui.user, "Объём заказа", "Укажите количество ящиков", max_value = 20, min_value = 1)
				if(isnull(num_input) || (!is_public && !is_authorized(ui.user)) || ..()) // Make sure they dont walk away
					return
				amount = num_input

			var/timeout = world.time + (60 SECONDS) // If you dont type the reason within a minute, theres bigger problems here
			var/reason = tgui_input_text(ui.user, "Причина заказа", "Напишите причину заказа", encode = FALSE, timeout = timeout)
			if(!reason || (!is_public && !is_authorized(ui.user)) || ..())
				// Cancel if they take too long, they dont give a reason, they aint authed, or if they walked away
				return
			reason = sanitize(copytext_char(reason, 1, 100)) //Preventing tgui overflow

			var/idname = "*Не указано*"
			var/idrank = "*Не указано*"

			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				idname = H.get_authentification_name()
				idrank = H.get_assignment()
			else if(issilicon(usr))
				idname = usr.real_name

			investigate_log("[key_name_log(usr)] made an order for [P.name] with amount [amount]. Points: [SSshuttle.points].", INVESTIGATE_CARGO)
			//make our supply_order datums
			for(var/i = 1; i <= amount; i++)
				var/datum/supply_order/O = SSshuttle.generateSupplyOrder(params["crate"], idname, idrank, reason, amount)
				if(!O)
					return
				if(i == 1)
					O.generateRequisition(loc)

		if("approve")
			// Public consoles cant approve stuff
			if(is_public)
				return
			if(SSshuttle.supply.getDockedId() != "supply_away" || SSshuttle.supply.mode != SHUTTLE_IDLE)
				return

			var/ordernum = text2num(params["ordernum"])
			var/datum/supply_order/O
			var/datum/supply_packs/P
			for(var/i=1, i<=length(SSshuttle.requestlist), i++)
				var/datum/supply_order/SO = SSshuttle.requestlist[i]
				if(SO.ordernum == ordernum)
					O = SO
					P = O.object
/*					if(P.times_ordered >= P.order_limit && P.order_limit != -1) //If this order would put it over the limit, deny it. Unused for now (Crate limit #3056).
						to_chat(usr, span_warning("[P.name] is out of stock, and can no longer be ordered."))	*/
					if(P.can_approve(usr))
						SSshuttle.requestlist.Cut(i,i+1)
						SSshuttle.points -= P.cost
						if(P.credits_cost)
							SSshuttle.cargo_money_account.money -= P.credits_cost
						SSshuttle.shoppinglist += O
						P.times_ordered += 1
						investigate_log("[key_name_log(usr)] has authorized an order for [P.name]. Remaining points: [SSshuttle.points].", INVESTIGATE_CARGO)
					break

		if("deny")
			var/ordernum = text2num(params["ordernum"])
			for(var/i=1, i<=length(SSshuttle.requestlist), i++)
				var/datum/supply_order/SO = SSshuttle.requestlist[i]
				if(SO.ordernum == ordernum)
					// If we are on a public console, only allow cancelling of our own orders
					if(is_public)
						var/obj/item/card/id/I = usr.get_id_card()
						if(I && SO.orderedby == I.registered_name)
							SSshuttle.requestlist.Cut(i,i+1)
							break
					// If we arent public, were cargo access. CANCELLATIONS FOR EVERYONE
					else
						SSshuttle.requestlist.Cut(i,i+1)
						break

		// Popup to show CC message logs. Its easier this way to avoid box-spam in TGUI
		if("showMessages")
			// Public consoles cant view messages
			if(is_public)
				return
			var/datum/browser/ccmsg_browser = new(usr, "ccmsg", "Журнал сообщений снабжения Центрального командования.", 800, 600)
			ccmsg_browser.set_content(SSshuttle.centcom_message)
			ccmsg_browser.open()

