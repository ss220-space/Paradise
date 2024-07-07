/proc/seedify(obj/item/O, t_max, obj/machinery/seed_extractor/extractor, mob/living/user)
	var/t_amount = 0
	if(t_max == -1)
		if(extractor)
			t_max = rand(1,4) * extractor.seed_multiplier
		else
			t_max = rand(1,4)

	var/seedloc = O.loc
	if(extractor)
		seedloc = extractor.loc

	if(istype(O, /obj/item/reagent_containers/food/snacks/grown/))
		var/obj/item/reagent_containers/food/snacks/grown/F = O
		if(F.seed)
			if(user && !user.drop_transfer_item_to_loc(O, extractor)) //couldn't drop the item
				return
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = F.seed.Copy()
				t_prod.forceMove(seedloc)
				t_amount++
			qdel(O)
			return 1

	else if(istype(O, /obj/item/grown))
		var/obj/item/grown/F = O
		if(F.seed)
			if(user && !user.drop_transfer_item_to_loc(O, extractor))
				return
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = F.seed.Copy()
				t_prod.forceMove(seedloc)
				t_amount++
			qdel(O)
		return 1

	return 0


/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "sextractor"
	density = TRUE
	anchored = TRUE
	var/list/piles = list()
	var/max_seeds = 1000
	var/pile_count = 1 //used for tracking unique piles
	var/seed_multiplier = 1
	var/vend_amount = 1

/obj/machinery/seed_extractor/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/seed_extractor(null)
	component_parts += new /obj/item/stock_parts/matter_bin(null)
	component_parts += new /obj/item/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/seed_extractor/Destroy()
	QDEL_LIST(piles)
	return ..()

/obj/machinery/seed_extractor/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_seeds = 1000 * B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		seed_multiplier = M.rating

/obj/machinery/seed_extractor/attackby(obj/item/O, mob/user, params)

	if(default_deconstruction_screwdriver(user, "sextractor_open", "sextractor", O))
		add_fingerprint(user)
		return

	if(exchange_parts(user, O))
		return

	if(default_unfasten_wrench(user, O))
		return

	if(default_deconstruction_crowbar(user, O))
		return

	if (istype(O,/obj/item/storage/bag/plants))
		add_fingerprint(user)
		var/obj/item/storage/P = O
		var/loaded = 0
		for(var/obj/item/seeds/G in P.contents)
			if(contents.len >= max_seeds)
				break
			++loaded
			G.add_fingerprint(user)
			add_seed(G)
		if (loaded)
			to_chat(user, "<span class='notice'>You put the seeds from \the [O.name] into [src].</span>")
		else
			to_chat(user, "<span class='notice'>There are no seeds in \the [O.name].</span>")
		return

	else if(seedify(O,-1, src, user))
		add_fingerprint(user)
		to_chat(user, "<span class='notice'>You extract some seeds.</span>")
		return
	else if (istype(O,/obj/item/seeds))
		if(add_seed(O))
			add_fingerprint(user)
			to_chat(user, "<span class='notice'>You add [O] to [name].</span>")
			updateUsrDialog()
		return
	else if(user.a_intent != INTENT_HARM)
		add_fingerprint(user)
		to_chat(user, "<span class='warning'>You can't extract any seeds from \the [O.name]!</span>")
	else
		return ..()

/obj/machinery/seed_extractor/attack_ai(mob/user)
	ui_interact(user)

/obj/machinery/seed_extractor/attack_hand(mob/user)
	ui_interact(user)

/obj/machinery/seed_extractor/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/seed_extractor/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/seed_extractor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SeedExtractor", name)
		ui.open()

//Расширенный инвентарь и tgui
/datum/seed_pile/extended
	var/id_string = ""
	var/list/seeds = list() //Храним список объектов, чтобы не искать циклом по contents

/datum/seed_pile/extended/New(obj/item/seeds/O)
	..(O.plantname, O.variant, O.lifespan, O.endurance, O.maturation, O.production, O.yield, O.potency)

	src.seeds += O

/obj/machinery/seed_extractor/proc/generate_strainText(obj/item/seeds/O) //Генерация отображаемого текста описания
	var/strain_text = ""

	for (var/datum/plant_gene/reagent/G in O.genes)
		if (strain_text !="")
			strain_text += ", "
		strain_text += "[G.get_name()]"

	for (var/datum/plant_gene/trait/G in O.genes)
		if (strain_text !="")
			strain_text += ", "
		strain_text += "[G.get_name()]"

	return strain_text

/obj/machinery/seed_extractor/proc/vend_seed(seed_id, seed_variant, amount)
	if(!seed_id)
		return
	var/datum/seed_pile/selected_pile
	for(var/datum/seed_pile/N in piles)
		if(N.id == seed_id && (N.variant == seed_variant || !seed_variant))
			amount = clamp(amount, 0, N.amount)
			N.amount -= amount
			selected_pile = N
			if(N.amount <= 0)
				piles -= N
			break
	if(!selected_pile)
		return
	var/amount_dispensed = 0
	for(var/obj/item/seeds/O in contents)
		if(amount_dispensed >= amount)
			break
		if(O.plantname == selected_pile.name && O.variant == selected_pile.variant && O.lifespan == selected_pile.lifespan && O.endurance == selected_pile.endurance && O.maturation == selected_pile.maturation && O.production == selected_pile.production && O.yield == selected_pile.yield && O.potency == selected_pile.potency)
			O.forceMove(loc)
			amount_dispensed++

/obj/machinery/seed_extractor/proc/add_seed(obj/item/seeds/O, mob/user)
	if(!O || !ishuman(usr) || !Adjacent(usr))
		return
	if(length(contents) >= max_seeds)
		to_chat(user, "<span class='notice'>[src] is full.</span>")
		return

	if(ismob(O.loc))
		var/mob/M = O.loc
		if(!M.drop_item_ground(O))
			to_chat(user,"<span class='warning'>[O] appears to be stuck to your hand!</span>")
			return
	else if(isstorage(O.loc))
		var/obj/item/storage/S = O.loc
		S.remove_from_storage(O, src)

	for(var/datum/seed_pile/N in piles) //this for loop physically hurts me
		if(O.plantname == N.name && O.variant == N.variant && O.lifespan == N.lifespan && O.endurance == N.endurance && O.maturation == N.maturation && O.production == N.production && O.yield == N.yield && O.potency == N.potency)
			N.amount++
			O.forceMove(src)
			return

	var/datum/seed_pile/new_pile = new(O.type, pile_count, O.plantname, O.variant, O.lifespan, O.endurance, O.maturation, O.production, O.yield, O.potency)
	pile_count++
	piles += new_pile
	O.forceMove(src)
	return

/obj/machinery/seed_extractor/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SeedExtractor", name)
		ui.open()

/obj/machinery/seed_extractor/ui_data(mob/user)
	var/list/data = list()

	data["icons"] = list()
	data["seeds"] = list()
	for(var/datum/seed_pile/O in piles)
		data["icons"][path2assetID(O.path)] = path2assetID(O.path)
		var/list/seed_info = list(
			"image" = path2assetID(O.path),
			"id" = O.id,
			"name" = O.name,
			"variant" = O.variant,
			"lifespan" = O.lifespan,
			"endurance" = O.endurance,
			"maturation" = O.maturation,
			"production" = O.production,
			"yield" = O.yield,
			"potency" = O.potency,
			"amount" = O.amount,
		)
		data["seeds"] += list(seed_info)

	return data

/obj/machinery/seed_extractor/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/seeds)
	)

/obj/machinery/seed_extractor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..())
		return
	. = FALSE
	switch(action)
		if("vend")
			vend_seed(params["seed_id"], params["seed_variant"], params["vend_amount"])
			add_fingerprint(usr)
			. = TRUE
		if("set_vend_amount")
			if(!length(params["vend_amount"]))
				return
			vend_amount = clamp(params["vend_amount"], 1, 25)
			add_fingerprint(usr)
			. = TRUE

/datum/seed_pile
	var/path
	var/id
	var/name = ""
	var/variant = ""
	var/lifespan = 0	//Saved stats
	var/endurance = 0
	var/maturation = 0
	var/production = 0
	var/yield = 0
	var/potency = 0
	var/amount = 0

/datum/seed_pile/New(path, id, name, variant, life, endurance, maturity, production, yield, potency, amount = 1)
	src.path = path
	src.id = id
	src.name = name
	src.variant = variant
	src.lifespan = life
	src.endurance = endurance
	src.maturation = maturity
	src.production = production
	src.yield = yield
	src.potency = potency
	src.amount = amount
