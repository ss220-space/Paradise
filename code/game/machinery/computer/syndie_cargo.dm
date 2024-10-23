GLOBAL_LIST_INIT(data_storages, list()) //list of all cargo console data storage datums

/********************
    SUPPLY ORDER //доработать
 ********************/
/datum/syndie_supply_order

	var/ordernum
	var/datum/syndie_supply_packs/object = null
	var/orderedby = null
	var/orderedbyRank
	var/comment = null
	var/crates


/datum/syndie_supply_order/proc/generateRequisition(atom/_loc)
	if(!object)
		return

	var/obj/item/paper/reqform = new /obj/item/paper(_loc)
	playsound(_loc, 'sound/goonstation/machines/printer_thermal.ogg', 50, 1)
	reqform.name = "Requisition Form - [crates] '[object.name]' for [orderedby]"

	reqform.info = {"<h3>Syndicate RaMSS 'Taipan' Supply Requisition Form</h3><hr>
					INDEX: #[ordernum]<br>
					REQUESTED BY: [orderedby]<br>
					RANK: [orderedbyRank]<br>
					REASON: [comment]<br>
					SUPPLY CRATE TYPE: [object.name]<br>
					NUMBER OF CRATES: [crates]<br>
					CONTENTS:<br>
					[object.manifest]
					<hr>
					STAMP BELOW TO APPROVE THIS REQUISITION:<br>"}

	reqform.update_icon()	//Fix for appearing blank when printed.

/datum/syndie_supply_order/proc/createObject(atom/_loc, errors=0, var/datum/syndie_data_storage/data_storage) // тут код создающий ящики
	if(!object)
		return

	//create the crate
	var/atom/crate = new object.containertype(_loc)
	crate.name = "[object.containername] [comment ? "([comment])":"" ]"
	var/obj/structure/closet/OBJ = get_obj_in_atom_without_warning(crate)
	if(object.access)
		OBJ.req_access = list(text2num(object.access))

	//create the manifest slip
	var/obj/item/paper/manifest/slip = new /obj/item/paper/manifest()
	slip.erroneous = errors
	slip.points = object.cost
	slip.ordernumber = ordernum

	var/stationName = "Syndicate RaMSS 'Taipan' Supply Mannifest"
	var/packagesAmt = data_storage.shoppinglist.len + ((errors & MANIFEST_ERROR_COUNT) ? rand(1,2) : 0)

	slip.name = "Shipping Manifest - '[object.name]' for [orderedby]"

	slip.info = {"<h3>Syndicate RaMSS 'Taipan' Shipping Manifest</h3><hr><br>
				Order: #[ordernum]<br>
				Destination: [stationName]<br>
				Requested By: [orderedby]<br>
				Rank: [orderedbyRank]<br>
				Reason: [comment]<br>
				Supply Crate Type: [object.name]<br>
				[packagesAmt] PACKAGES IN THIS SHIPMENT<br>
				CONTENTS:<br><ul>"}

	//we now create the actual contents
	var/list/contains
	if(istype(object, /datum/syndie_supply_packs/misc/randomised)) // тут выбирается рандомный контент для всяких шляп
		var/datum/syndie_supply_packs/misc/randomised/SO = object
		contains = list()
		if(length(object.contains))
			for(var/j in 1 to SO.num_contained)
				contains += pick(object.contains)
	else
		contains = object.contains

	for(var/typepath in contains)
		if(!typepath)	continue
		var/atom/A = new typepath(crate)
		var/obj/item/stack/AO = get_obj_in_atom_without_warning(A)
		if(object.amount && A.vars.Find("amount") && AO?.amount)
			AO.amount = object.amount
		slip.info += "<li>[A.name]</li>"	//add the item to the manifest (even if it was misplaced)

	if(istype(crate, /obj/structure/closet/critter)) // critter crates do not actually spawn mobs yet and have no contains var, but the manifest still needs to list them
		var/obj/structure/closet/critter/CritCrate = crate
		if(CritCrate.content_mob)
			var/mob/crittername = CritCrate.content_mob
			slip.info += "<li>[initial(crittername.name)]</li>"

	if((errors & MANIFEST_ERROR_ITEM))
		//secure and large crates cannot lose items
		if(findtext("[object.containertype]", "/secure/") || findtext("[object.containertype]","/largecrate/"))
			errors &= ~MANIFEST_ERROR_ITEM
		else
			var/lostAmt = max(round(crate.contents.len/10), 1)
			//lose some of the items
			while(--lostAmt >= 0)
				qdel(pick(crate.contents))

	//manifest finalisation
	slip.info += "</ul><br>"
	slip.info += "CHECK CONTENTS AND STAMP BELOW THE LINE TO CONFIRM RECEIPT OF GOODS<hr>" // And now this is actually meaningful.
	slip.loc = crate
	if(istype(crate, /obj/structure/closet/crate))
		var/obj/structure/closet/crate/CR = crate
		CR.manifest = slip
		CR.update_icon(UPDATE_OVERLAYS)
	if(istype(crate, /obj/structure/largecrate))
		var/obj/structure/largecrate/LC = crate
		LC.manifest = slip
		LC.update_icon(UPDATE_OVERLAYS)


/***************************
    Хранилище данных.
	Консоли её находят и используют как сервер для снхронизации данных.
	Если консоль построить в зоне без хранилища данных, консоль создаст новое хранилище данных в своей зоне при попытке синхронизации через кнопку "Link pads"
	Такой подход позволяет игрокам построить собственное синдикарго
 **************************/
/datum/syndie_data_storage

/****************************
Код со времён когда этот обьект был абстрактным эффектом вместо датума, оставлен на всякий случай.

	layer = TURF_LAYER
	density = FALSE
	icon = 'icons/effects/mapping_helpers.dmi'
	icon_state = null
	invisibility = INVISIBILITY_ABSTRACT
	desc = "This shit has the data for the syndie cargo consoles, so it can be synchronized between them, they don't function normally without it"
***************************/

	/// Available money amount
	var/area/cargoarea
	var/cash = 5000
	var/cash_per_slip = 20			//points gained per slip returned
	var/cash_per_crate = 50			//points gained per crate returned
	var/cash_per_intel = 2500		//points gained per intel returned
	var/cash_per_plasma = 100		//points gained per plasma returned
	var/cash_per_design = 500		//points gained per research design returned
	var/cash_per_gem = 2000			//points gained per gem returned
	var/cash_multiplier = 100		//points bonus for plants, tech disks, etc.
	var/blackmarket_message = null	//Remarks from Black Market on how well you checked the last order.
/***************************
Возможные статусы для телепадов
	"Pads not linked!" 	// Статус только что построенной консоли.
	"Pads on cooldown"
	"Pads ready"
**************************/
	var/telepads_status = "Pads not linked!" // позже впиши изменения статуса и интегрируй с интерфейсом
	var/linked_pads = list() // the pads that will be used to sell our goods
	var/receiving_pads = list() // the pad that will receive our bought goods
	var/last_teleport //to handle the cooldown, but for all the pads, and cooldown will be higher
	var/pads_cooldown = 0 // pads cooldown time, fills dynamically below
	var/wait_time = 0 //wait till cooldown end
	var/is_cooldown = FALSE //are we on cooldown?

	var/list/shoppinglist = list()
	var/list/requestlist = list()
	var/orderNum = 0
	var/list/syndie_supply_packs = list()

	var/list/discoveredPlants = list()	//Typepaths for unusual plants we've already sent Black Market, associated with their potencies
	var/list/techLevels = list()
	var/list/researchDesigns = list()
	var/sold_atoms = ""

/datum/syndie_data_storage/proc/sync()
	linked_pads = list() 	// Обнуление на случай повторной синхронизации.
	receiving_pads = list() // Мы же не хотим два одинаковых обьекта в одном списке
	pads_cooldown = 0
	for(var/obj/machinery/syndiepad/P in GLOB.syndiepads)
		if(get_area(P) != cargoarea)
			continue
		if(P.receive && P.console_link)
			pads_cooldown += P.teleport_cooldown
			P.id = "syndie_cargo_receive" // все привязанные телепады пытаются отправлять посылки на z2 и получать оттуда же
			receiving_pads += P
			continue
		if(!P.receive && P.console_link)
			pads_cooldown += P.teleport_cooldown
			P.target_id = "syndie_cargo_load" // все привязанные телепады пытаются отправлять посылки на z2 и получать оттуда же
			linked_pads += P
			continue
	pads_cooldown = round(pads_cooldown)
	if (length(receiving_pads) && length(linked_pads))
		telepads_status = "Pads ready"
	else
		if(usr) //Во избежание рантаймов по to_chat при автоматической раундстарт синхронизации синдипадов
			to_chat(usr, span_warning("Synchronization failure! There's no pads in [cargoarea]!"))
		telepads_status = "Pads not linked!"

/datum/syndie_data_storage/proc/cooldown()
	if(is_cooldown)
		telepads_status = "Pads on cooldown"
		wait_time = round((last_teleport + pads_cooldown - world.time) / 10)
		if(wait_time <=0)
			wait_time = 0
			telepads_status = "Pads ready"
			is_cooldown = FALSE
		return wait_time
	return 0


/datum/syndie_data_storage/proc/generateSupplyOrder(packId, _orderedby, _orderedbyRank, _comment, _crates)
	if(!packId)
		return
	var/datum/syndie_supply_packs/SP = locateUID(packId)
	if(!SP)
		return

	var/datum/syndie_supply_order/O = new()
	O.ordernum = orderNum
	O.object = SP
	O.orderedby = _orderedby
	O.orderedbyRank = _orderedbyRank
	O.comment = _comment
	O.crates = _crates

	orderNum += 1
	requestlist += O

	return O

/datum/syndie_data_storage/proc/DataStorageInitialize() //Вызывать сразу после создания хранилища данных
	GLOB.data_storages += src
	for(var/typepath in subtypesof(/datum/syndie_supply_packs))
		var/datum/syndie_supply_packs/SP = typepath
		if(initial(SP.name) == "HEADER")		// To filter out group headers
			continue
		syndie_supply_packs["[typepath ]"] = new SP
	sync()
	orderNum = rand(1,9000)

/datum/syndie_data_storage/Destroy(force)
	if(!force)
		return QDEL_HINT_LETMELIVE
	GLOB.data_storages -= src
	linked_pads = null
	receiving_pads = null
	shoppinglist = null
	syndie_supply_packs = null
	discoveredPlants = null
	techLevels = null
	researchDesigns = null
	return ..()
/***************************
    Консоль заказов синдикарго
 **************************/
/obj/machinery/computer/syndie_supplycomp
	name = "Supply Pad Console"
	desc = "Used to order supplies by using syndiepads!"
	icon_screen = "syndinavigation"
	icon_keyboard = "syndie_key"
	req_access = list(ACCESS_SYNDICATE_CARGO)
	circuit = /obj/item/circuitboard/syndicatesupplycomp
	/// Is this a public console
	var/is_public = FALSE
	var/datum/syndie_data_storage/data_storage = null

/obj/machinery/computer/syndie_supplycomp/Initialize(mapload)
	..()
	GLOB.syndie_cargo_consoles += src
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/syndie_supplycomp/LateInitialize()
	. = ..()
	compSync()

/obj/machinery/computer/syndie_supplycomp/Destroy()
	circuit = null
	data_storage = null
	GLOB.syndie_cargo_consoles -= src
	return ..()

/obj/machinery/computer/syndie_supplycomp/proc/compSync()
	if(data_storage == null)
		for(var/datum/syndie_data_storage/S in GLOB.data_storages)
			if(S.cargoarea == get_area(src))
				data_storage = S
		if(data_storage == null)
			data_storage = new /datum/syndie_data_storage
			data_storage.cargoarea = get_area(src)
			data_storage.DataStorageInitialize(get_area(src))

/obj/machinery/computer/syndie_supplycomp/proc/buy() // Этот код заточен под поиск точек для спавна, активации траты энергии и анимации падов

	if(!length(data_storage.shoppinglist))
		return

	var/list/spawnTurfs = list()
	var/list/recievingPads = data_storage.receiving_pads
	for(var/j in 1 to length(recievingPads))
		spawnTurfs += get_turf(recievingPads[j])

	for(var/datum/syndie_supply_order/SO in data_storage.shoppinglist)
		if(!SO.object)
			throw EXCEPTION("Supply Order [SO] has no object associated with it.")
			continue

		var/turf/T = pick_n_take(spawnTurfs)		//turf we will place it in
		for(var/obj/machinery/syndiepad/recieving_pad as anything in recievingPads)
			recieving_pad.use_power(10000 / recieving_pad.power_efficiency)
			flick("[initial(recieving_pad.icon_state)]-beam", recieving_pad)
			playsound(get_turf(recieving_pad), 'sound/weapons/emitter2.ogg', 25, TRUE)

		if(!T)
			data_storage.shoppinglist.Cut(1, data_storage.shoppinglist.Find(SO))
			return

		var/errors = 0
		if(prob(5))
			errors |= MANIFEST_ERROR_COUNT
		if(prob(5))
			errors |= MANIFEST_ERROR_NAME
		if(prob(5))
			errors |= MANIFEST_ERROR_ITEM
		SO.createObject(T, errors, data_storage) //А уже тут вызов штуки делающей коробки

	data_storage.shoppinglist.Cut()


/obj/machinery/computer/syndie_supplycomp/proc/sell() //Этот код ищет зоны где находятся телепады отправки и продаёт ящики и товар в них

	var/plasma_count = 0
	var/crate_count = 0

	var/msg = "<center>---[station_time_timestamp()]---</center><br>"
	var/cashEarned
	var/list/sellArea = list()

	var/list/DSLP = data_storage.linked_pads

	for(var/k in 1 to length(DSLP))
		sellArea = get_turf(DSLP[k])
		for(var/atom/movable/MA in sellArea)
			if(MA.anchored)
				continue
			var/mob/MB = get_mob_in_atom_without_warning(MA)
			if(MB?.stat || isliving(MA)) // Если окажется что на паде труп или живое существо, то это защитит его от уничтожения
				continue
			if(istype(MA,/obj/structure/closet/crate/syndicate) || istype(MA,/obj/structure/closet/crate/secure/syndicate))
				++crate_count
				msg += "We received your special delievery, after mandatory inspection of it's contents you will receive what was promised to you... <br> "
				continue

			data_storage.sold_atoms += "[MA.name]"

			// Must be in a crate (or a critter crate)!
			if(istype(MA,/obj/structure/closet/crate) || istype(MA,/obj/structure/closet/critter))
				data_storage.sold_atoms += ":"
				if(!MA.contents.len)
					data_storage.sold_atoms += " (empty)"
				++crate_count

				var/find_slip = 1
				for(var/atom/thing in MA)
					var/obj/OT = get_obj_in_atom_without_warning(thing)
					var/mob/MT = get_mob_in_atom_without_warning(thing)
					if(isobj(thing))
						data_storage.sold_atoms += " [OT.name]"
					else if(ismob(thing))
						data_storage.sold_atoms += " [MT.name]"
					else
						data_storage.sold_atoms += "Not Specified"
					// Sell manifests
//					data_storage.sold_atoms += " [thing.name]"

					if(find_slip && istype(thing,/obj/item/paper/manifest))
						var/obj/item/paper/manifest/slip = thing
						var/slip_stamped_len = LAZYLEN(slip.stamped)
						if(slip_stamped_len) //yes, the clown stamp will work. clown is the highest authority on the station, it makes sense
							// Did they mark it as erroneous?
							var/denied = 0
							for(var/i in 1 to slip_stamped_len)
								if(slip.stamped[i] == /obj/item/stamp/denied)
									denied = 1
									break
							if(slip.erroneous && denied) // Caught a mistake
								cashEarned = slip.points - data_storage.cash_per_crate
								data_storage.cash += cashEarned // For now, give a full refund for paying attention (minus the crate cost)
								msg += "[span_good("+[cashEarned]")]: Station correctly denied package [slip.ordernumber]: "
								if(slip.erroneous & MANIFEST_ERROR_NAME)
									msg += "Destination station incorrect. "
								else if(slip.erroneous & MANIFEST_ERROR_COUNT)
									msg += "Packages incorrectly counted. "
								else if(slip.erroneous & MANIFEST_ERROR_ITEM)
									msg += "Package incomplete. "
								msg += "Credits refunded.<br>"
							else if(!slip.erroneous && !denied) // Approving a proper order awards the relatively tiny cash_per_slip
								data_storage.cash += data_storage.cash_per_slip
								msg += "[span_good("+[data_storage.cash_per_slip]")]: Package [slip.ordernumber] accorded.<br>"
							else // You done goofed.
								if(slip.erroneous)
									msg += "[span_good("+0")]: Station approved package [slip.ordernumber] despite error: "
									if(slip.erroneous & MANIFEST_ERROR_NAME)
										msg += "Destination station incorrect."
									else if(slip.erroneous & MANIFEST_ERROR_COUNT)
										msg += "Packages incorrectly counted."
									else if(slip.erroneous & MANIFEST_ERROR_ITEM)
										msg += "We found unshipped items on our dock."
									msg += "  Don't dissapoint us like that!<br>"
								else
									cashEarned = round(data_storage.cash_per_crate - slip.points)
									data_storage.cash += cashEarned
									msg += "[span_bad("[cashEarned]")]: Station denied package [slip.ordernumber]. Our records show no fault on our part.<br>"
							find_slip = 0
						continue

					// Sell plasma
					if(istype(thing, /obj/item/stack/sheet/mineral/plasma))
						var/obj/item/stack/sheet/mineral/plasma/P = thing
						plasma_count += P.amount

					// Sell intel
					if(istype(thing, /obj/item/documents))
						var/obj/item/documents/docs = thing
						if(INTEREST_SYNDICATE & docs.sell_interest)
							cashEarned = round(data_storage.cash_per_intel * docs.sell_multiplier)
							data_storage.cash += cashEarned
							msg += "[span_good("+[cashEarned]")]: Received enemy intelligence.<br>"

					// Sell tech levels
					if(istype(thing, /obj/item/disk/tech_disk))
						var/obj/item/disk/tech_disk/disk = thing
						if(!disk.stored) continue
						var/datum/tech/tech = disk.stored

						var/cost = tech.getCost(data_storage.techLevels[tech.id]) * data_storage.cash_multiplier
						if(cost)
							data_storage.techLevels[tech.id] = tech.level
							data_storage.cash += cost
							msg += "[span_good("+[cost]")]: [tech.name] - new data.<br>"

					// Sell designs
					if(istype(thing, /obj/item/disk/design_disk))
						var/obj/item/disk/design_disk/disk = thing
						if(!disk.blueprint)
							continue
						var/datum/design/design = disk.blueprint
						if(design.id in data_storage.researchDesigns)// This design has already been sent to Black Market
							continue
						data_storage.cash += data_storage.cash_per_design
						data_storage.researchDesigns += design.id
						msg += "[span_good("+[data_storage.cash_per_design]")]: [design.name] design.<br>"

					// Sell exotic plants
					if(istype(thing, /obj/item/seeds))
						var/obj/item/seeds/S = thing
						if(!S.rarity) // Mundane species
							msg += "[span_bad("+0")]: We don't need samples of mundane species \"[capitalize(S.species)]\".<br>"
						else if(data_storage.discoveredPlants[S.type]) // This species has already been sent to Black Market
							var/potDiff = S.potency - data_storage.discoveredPlants[S.type] // Compare it to the previous best
							if(potDiff > 0) // This sample is better
								data_storage.discoveredPlants[S.type] = S.potency
								msg += "[span_good("+[(potDiff * data_storage.cash_multiplier)]")]: New sample of \"[capitalize(S.species)]\" is superior. Good work.<br>"
								data_storage.cash += (potDiff * data_storage.cash_multiplier)
							else // This sample is worthless
								msg += "[span_bad("+0")]: New sample of \"[capitalize(S.species)]\" is not more potent than existing sample ([data_storage.discoveredPlants[S.type]] potency).<br>"
						else // This is a new discovery!
							data_storage.discoveredPlants[S.type] = S.potency
							msg += "[span_good("[(S.rarity + S.potency)*data_storage.cash_multiplier]")]: New species discovered: \"[capitalize(S.species)]\". Excellent work.<br>"
							data_storage.cash += (S.rarity + S.potency)*data_storage.cash_multiplier// That's right, no bonus for potency.  Send a crappy sample first to "show improvement" later
					// Sell gems
					if(istype(thing, /obj/item/gem))
						var/obj/item/gem/Gem = thing
						cashEarned = round(Gem.sell_multiplier * data_storage.cash_per_gem)
						msg += "[span_good("+[cashEarned]")]: Received [Gem.name]. Great work.<br>"
						data_storage.cash += cashEarned
						qdel(thing, force = TRUE) //ovveride for special gems

					if(!QDELETED(thing))
						qdel(thing)
			qdel(MA)
			data_storage.sold_atoms += "."

	if(plasma_count > 0)
		cashEarned = round(plasma_count * data_storage.cash_per_plasma)
		msg += "[span_good("+[cashEarned]")]: Received [plasma_count] unit(s) of exotic material.<br>"
		data_storage.cash += cashEarned

	if(crate_count > 0)
		cashEarned = round(crate_count * data_storage.cash_per_crate)
		msg += "[span_good("+[cashEarned]")]: Received [crate_count] crate(s).<br>"
		data_storage.cash += cashEarned

	data_storage.blackmarket_message += "[msg]<hr>"


/obj/machinery/computer/syndie_supplycomp/public
	name = "Supply Ordering Console"
	desc = "Used to order supplies from cargo staff."
	circuit = /obj/item/circuitboard/syndicatesupplycomp/public
	req_access = list()
	is_public = TRUE

/obj/machinery/computer/syndie_supplycomp/emag_act(mob/user)
	if(user)
		to_chat(user, span_notice("The electronic systems in this console are far too advanced for your primitive hacking peripherals."))
	return


/obj/machinery/computer/syndie_supplycomp/attack_hand(var/mob/user as mob)
	if(..())
		return TRUE

	if(!allowed(user) && !isobserver(user))
		to_chat(user, span_warning("Access denied."))
		playsound(src, pick('sound/machines/button.ogg', 'sound/machines/button_alternate.ogg', 'sound/machines/button_meloboom.ogg'), 20)
		return 1
	add_fingerprint(user)
	ui_interact(user)
	return


/obj/machinery/computer/syndie_supplycomp/attackby(obj/item/I, mob/living/carbon/human/user, params)
	if(user.a_intent == INTENT_HARM || !powered() || !ishuman(user))
		return ..()

	if(istype(I, /obj/item/stack/spacecash))
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		add_fingerprint(user)
		//consume the money
		var/obj/item/stack/spacecash/cash = I
		playsound(loc, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 50, TRUE)
		data_storage.cash += cash.amount
		to_chat(user, span_info("You insert [cash] into [src]."))
		data_storage.blackmarket_message += "[span_good("+[cash.amount]")]: [user.get_authentification_name()] adds credits to the console.<br>"
		SStgui.update_uis(src)
		qdel(cash)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/machinery/computer/syndie_supplycomp/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SyndieCargoConsole", name)
		ui.open()

/obj/machinery/computer/syndie_supplycomp/ui_data(mob/user)
	var/list/data = list()

	var/list/requests_list = list()

	for(var/datum/syndie_supply_order/SO as anything in data_storage.requestlist)
		if(!SO.comment)
			SO.comment = "No comment."
		requests_list += list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment, "command1" = list("confirmorder" = SO.ordernum), "command2" = list("rreq" = SO.ordernum)))
	data["requests"] = requests_list // покупки с активными кнопками approve/deny

	var/list/orders_list = list()
	for(var/datum/syndie_supply_order/SO as anything in data_storage.shoppinglist)
		orders_list += list(list("ordernum" = SO.ordernum, "supply_type" = SO.object.name, "orderedby" = SO.orderedby, "comment" = SO.comment))
	data["orders"] = orders_list

	data["is_public"] = is_public
	data["canapprove"] = !is_public // возможно стоит тут позже ужесточить проверки и смотреть на активность телепадов
	data["cash"] = data_storage.cash
	data["telepads_status"] = data_storage.telepads_status
	data["wait_time"] = data_storage.cooldown()
	data["is_cooldown"] = data_storage.is_cooldown

	return data

/obj/machinery/computer/syndie_supplycomp/ui_static_data(mob/user)
	var/list/data = list()
	var/list/packs_list = list()

	for(var/set_name in data_storage.syndie_supply_packs)
		var/datum/syndie_supply_packs/pack = data_storage.syndie_supply_packs[set_name]
		packs_list.Add(list(list("name" = pack.name, "cost" = pack.cost, "ref" = "[pack.UID()]", "contents" = pack.ui_manifest, "cat" = pack.group)))

	data["supply_packs"] = packs_list

	var/list/categories = list() // meow
	for(var/category in GLOB.all_syndie_supply_groups)
		categories.Add(list(list("name" = get_syndie_supply_group_name(category), "category" = category)))
	data["categories"] = categories
	data["adminAddCash"] = (check_rights(R_ADMIN, FALSE, user)) ? "(ADMIN) Add Cash!" : null
	return data

/obj/machinery/computer/syndie_supplycomp/proc/is_authorized(mob/user)
	if(allowed(user))
		return TRUE

	if(user.can_admin_interact())
		return TRUE

	return FALSE

/obj/machinery/computer/syndie_supplycomp/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return

	// If its not a public console, and they aint authed, dont let them use this
	if(!is_public && !is_authorized(usr))
		return
	. = TRUE
	switch(action)
		if("withdraw")
			var/cash_sum = input(usr, "Amount", "How much money do you wish to withdraw") as null|num
			if(cash_sum <= 0 || (!is_public && !is_authorized(usr)) || ..())
				return
			if(in_range(usr, src)) //эта проверка нужна чтобы деньги не могли снять при этом отойдя далеко от консоли
				withdraw_cash(round(cash_sum), usr)
		if("teleport")
			if(data_storage.telepads_status == "Pads not linked!"|| data_storage == null)
				//Проверка на наличие хранилища данных
				if(!data_storage)
					compSync()
				//Проверка на синхронизацию телепадов
				if(length(data_storage.linked_pads))
					data_storage.sync()

			var/list/DSLP = data_storage.linked_pads

			if(data_storage.telepads_status == "Pads ready")
				sell()
				//Телепорт
				investigate_log("[key_name_log(usr)] has sold '[data_storage.sold_atoms]' using syndicate cargo. Remaining credits: [data_storage.cash]", INVESTIGATE_SYNDIE_CARGO)
				data_storage.sold_atoms = null
				for(var/obj/machinery/syndiepad/linked_pad as anything in DSLP)
					linked_pad.checks(usr)
				data_storage.last_teleport = world.time
				data_storage.is_cooldown = TRUE
				buy()

		if("order")
			var/amount = 1
			if(params["multiple"] == "1") // 1 is a string here. DO NOT MAKE THIS A BOOLEAN YOU DORK
				var/num_input = tgui_input_number(ui.user, "Amount", "How many crates?", max_value = 20)
				if(!num_input || (!is_public && !is_authorized(usr)) || ..()) // Make sure they dont walk away
					return

			var/datum/syndie_supply_packs/SP = locateUID(params["crate"])
			if(!istype(SP))
				return

			var/reason = tgui_input_text(ui.user, "Reason", "Why do you require this item?", encode = FALSE, timeout = 60 SECONDS)
			if(!reason || (!is_public && !is_authorized(usr)) || ..())
				// Cancel if they take too long, they dont give a reason, they aint authed, or if they walked away
				return
			reason = sanitize(copytext_char(reason, 1, MAX_MESSAGE_LEN))

			var/idname = "*None Provided*"
			var/idrank = "*None Provided*"

			if(ishuman(usr))
				var/mob/living/carbon/human/H = usr
				idname = H.get_authentification_name()
				idrank = H.get_assignment()
			else if(issilicon(usr))
				idname = usr.real_name

			//make our supply_order datums
			for(var/i in 1 to amount)
				var/datum/syndie_supply_order/O = data_storage.generateSupplyOrder(params["crate"], idname, idrank, reason, amount)
				if(!O)
					return
				if(i == 1)
					O.generateRequisition(loc)

		if("approve")
			// Public consoles cant approve stuff
			if(is_public)
				return

			var/ordernum = text2num(params["ordernum"])
			var/datum/syndie_supply_order/O
			var/datum/syndie_supply_packs/P
			for(var/i in 1 to length(data_storage.requestlist))
				var/datum/syndie_supply_order/SO = data_storage.requestlist[i]
				if(SO.ordernum == ordernum)
					O = SO
					P = O.object
					if(data_storage.cash >= P.cost)
						data_storage.requestlist.Cut(i,i+1)
						data_storage.cash -= P.cost
						data_storage.shoppinglist += O
						investigate_log("[key_name_log(usr)] has authorized an order for [P.name]. Remaining credits: [data_storage.cash].", INVESTIGATE_SYNDIE_CARGO)
					else
						to_chat(usr, span_warning("There are insufficient credits for this request."))
					break

		if("deny")
			var/ordernum = text2num(params["ordernum"])
			for(var/i in 1 to length(data_storage.requestlist))
				var/datum/syndie_supply_order/SO = data_storage.requestlist[i]
				if(SO.ordernum == ordernum)
					// If we are on a public console, only allow cancelling of our own orders
					if(is_public)
						var/obj/item/card/id/I = usr.get_id_card()
						if(I && SO.orderedby == I.registered_name)
							data_storage.requestlist.Cut(i,i+1)
							break
					// If we arent public, were cargo access. CANCELLATIONS FOR EVERYONE
					else
						data_storage.requestlist.Cut(i,i+1)
						break

		// Popup to show CC message logs. Its easier this way to avoid box-spam in TGUI
		if("showMessages")
			// Public consoles cant view messages
			if(is_public)
				return
			var/datum/browser/bmmsg_browser = new(usr, "ccmsg", "Black Market Cargo Message Log", 800, 600)
			bmmsg_browser.set_content(data_storage.blackmarket_message)
			bmmsg_browser.open()
		if("add_money") //Admin button. Used to reward or tax cargo with the money.
			var/money2add = round(input("Введите сколько кредитов вы хотите добавить") as null|num)
			message_admins("[key_name_admin(usr)] added [money2add] credits to the cargo console at [data_storage.cargoarea.name]")
			log_admin("[key_name_admin(usr)] added [money2add] credits to the cargo console at [data_storage.cargoarea.name]")
			usr.investigate_log("added [money2add] credits to the cargo console at [data_storage.cargoarea.name]", INVESTIGATE_SYNDIE_CARGO)
			data_storage.cash += money2add
			if(money2add > 0)
				data_storage.blackmarket_message += "[span_good("+[money2add]")]: We are pleased with your work. Here's your reward.<br>"
			else if(money2add < 0)
				data_storage.blackmarket_message += "[span_bad("[money2add]")]: Don't anger us anymore! You won't be able to get away with such a little tax again.<br>"


	add_fingerprint(usr)


/obj/machinery/computer/syndie_supplycomp/proc/withdraw_cash(cash_sum, mob/user)
	if(cash_sum <= data_storage.cash)
		data_storage.cash -= cash_sum
		playsound(src, 'sound/machines/chime.ogg', 50, TRUE)
		var/obj/item/stack/spacecash/C = new(drop_location(), cash_sum)
		to_chat(user, span_info("The machine give you [C]!"))
		var/mob/living/carbon/human/H = user
		var/name = H.get_authentification_name()
		data_storage.blackmarket_message += "[span_bad("-[cash_sum]")]: [name] withdraws credits from the console.<br>"
		user.put_in_hands(C, ignore_anim = FALSE)
	else
		to_chat(user, span_notice("Нельзя снять больше денег, чем доступно в консоли!"))
		return
