// Crew has to create dna vault
// Cargo can order DNA samplers + DNA vault boards
// DNA vault requires x animals ,y plants, z human dna
// DNA vaults require high tier stock parts and cold
// After completion each crewmember can receive single upgrade chosen out of 2 for the mob.

/datum/station_goal/dna_vault
	name = "DNA Vault"
	var/animal_count
	var/human_count
	var/plant_count

/datum/station_goal/dna_vault/New()
	..()

	animal_count = rand(15, 20) // might be too few given ~15 roundstart stationside ones
	human_count = rand(round(0.75 * SSticker.mode.num_players_started()), SSticker.mode.num_players_started()) // 75%+ roundstart population.
	var/non_standard_plants = non_standard_plants_count()
	plant_count = rand(round(0.5 * non_standard_plants),round(0.7 * non_standard_plants))

/datum/station_goal/dna_vault/proc/non_standard_plants_count()
	. = 0
	for(var/obj/item/seeds/seeds as anything in subtypesof(/obj/item/seeds)) // put a cache if it's used anywhere else
		if(initial(seeds.rarity))
			.++

/datum/station_goal/dna_vault/get_report()
	return {"<b>DNA Vault construction</b><br>
	Our long term prediction systems say there's 99% chance of system-wide cataclysm in near future. As such, we need you to construct a DNA Vault aboard your station.
	<br><br>
	The DNA Vault needs to contain samples of:
	<ul style='margin-top: 10px; margin-bottom: 10px;'>
	 <li>[animal_count] unique animal data.</li>
	 <li>[plant_count] unique non-standard plant data.</li>
	 <li>[human_count] unique sapient humanoid DNA data.</li>
	</ul>
	The base vault parts should be available for shipping by your cargo shuttle."}

/datum/station_goal/dna_vault/on_report()
	var/datum/supply_packs/P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/dna_vault]"]
	P.special_enabled = TRUE
	supply_list.Add(P)

	P = SSshuttle.supply_packs["[/datum/supply_packs/misc/station_goal/dna_probes]"]
	P.special_enabled = TRUE
	supply_list.Add(P)

/datum/station_goal/dna_vault/check_completion()
	if(..())
		return TRUE
	for(var/obj/machinery/dna_vault/V in GLOB.machines)
		if(V.animals.len >= animal_count && V.plants.len >= plant_count && V.dna.len >= human_count && is_station_contact(V.z))
			return TRUE
	return FALSE

/obj/item/dna_probe
	name = "DNA Sampler"
	desc = "Can be used to take chemical and genetic samples of pretty much anything."
	icon = 'icons/obj/hypo.dmi'
	item_state = "sampler_hypo"
	icon_state = "sampler_hypo"
	item_flags = NOBLUDGEON
	var/list/animals = list()
	var/list/plants = list()
	var/list/dna = list()

/obj/item/dna_probe/proc/clear_data()
	animals = list()
	plants = list()
	dna = list()

GLOBAL_LIST_INIT(non_simple_animals, typecacheof(list(/mob/living/carbon/human/lesser/monkey,/mob/living/carbon/alien)))

/obj/item/dna_probe/afterattack(atom/target, mob/user, proximity, params)
	..()
	if(!proximity || !target)
		return
	//tray plants
	if(istype(target,/obj/machinery/hydroponics))
		var/obj/machinery/hydroponics/H = target
		if(!H.myseed)
			return
		if(!H.harvest)// So it's bit harder.
			to_chat(user, "<span clas='warning'>Plants needs to be ready to harvest to perform full data scan.</span>") //Because space dna is actually magic
			return
		if(plants[H.myseed.type])
			to_chat(user, "<span class='notice'>Plant data already present in local storage.</span>")
			return
		plants[H.myseed.type] = 1
		to_chat(user, "<span class='notice'>Plant data added to local storage.</span>")

	//animals
	if(isanimal(target) || is_type_in_typecache(target, GLOB.non_simple_animals))
		if(isanimal(target))
			var/mob/living/simple_animal/A = target
			if(!A.healable)//simple approximation of being animal not a robot or similar
				to_chat(user, "<span class='warning'>No compatible DNA detected</span>")
				return
		if(animals[target.type])
			to_chat(user, "<span class='notice'>Animal data already present in local storage.</span>")
			return
		animals[target.type] = 1
		to_chat(user, "<span class='notice'>Animal data added to local storage.</span>")

	//humans
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(HAS_TRAIT(H, TRAIT_NO_DNA))
			to_chat(user, "<span class='notice'>This humanoid doesn't have DNA.</span>")
			return
		if(dna[H.dna.uni_identity])
			to_chat(user, "<span class='notice'>Humanoid data already present in local storage.</span>")
			return
		dna[H.dna.uni_identity] = 1
		to_chat(user, "<span class='notice'>Humanoid data added to local storage.</span>")


/obj/item/circuitboard/machine/dna_vault
	board_name = "DNA Vault"
	build_path = /obj/machinery/dna_vault
	origin_tech = "engineering=2;combat=2;bluespace=2" // No freebies!
	req_components = list(
							/obj/item/stock_parts/capacitor/super = 5,
							/obj/item/stock_parts/manipulator/pico = 5,
							/obj/item/stack/cable_coil = 2)

/obj/structure/filler
	name = "big machinery part"
	density = TRUE
	anchored = TRUE
	invisibility = INVISIBILITY_ABSTRACT
	smoothing_groups = SMOOTH_GROUP_FILLER
	var/obj/machinery/parent

/obj/structure/filler/Destroy()
	parent = null
	return ..()

/obj/structure/filler/ex_act()
	return

/obj/machinery/dna_vault
	name = "DNA Vault"
	desc = "Break glass in case of apocalypse."
	icon = 'icons/obj/machines/dna_vault.dmi'
	icon_state = "vault"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 5000
	pixel_x = -32
	pixel_y = -64
	luminosity = 1

	//High defaults so it's not completed automatically if there's no station goal
	var/animals_max = 100
	var/plants_max = 100
	var/dna_max = 100
	var/list/animals
	var/list/plants
	var/list/dna

	var/completed = FALSE
	var/static/list/power_lottery

	var/list/obj/structure/fillers

/obj/machinery/dna_vault/New()
	// TODO: Replace this, bsa and gravgen with some big machinery datum
	var/list/occupied

	for(var/direct in list(EAST, WEST, SOUTHEAST, SOUTHWEST))
		LAZYADD(occupied, get_step(src, direct))

	LAZYADD(occupied, locate(x + 1, y - 2, z))
	LAZYADD(occupied, locate(x - 1, y - 2, z))

	for(var/type in occupied)
		var/obj/structure/filler/filler = new(type)
		filler.parent = src
		LAZYADD(fillers, filler)

	if(SSticker.mode)
		for(var/datum/station_goal/dna_vault/G in SSticker.mode.station_goals)
			animals_max = G.animal_count
			plants_max = G.plant_count
			dna_max = G.human_count
			break

	..()

/obj/machinery/dna_vault/update_icon_state()
	icon_state = "initial(icon_state)[stat & NOPOWER ? "off" : ""]"

/obj/machinery/dna_vault/power_change(forced = FALSE)
	if(!..())
		return

	update_icon(UPDATE_ICON_STATE)


/obj/machinery/dna_vault/Destroy()
	QDEL_LIST(fillers)
	return ..()

/obj/machinery/dna_vault/attack_ghost(mob/user)
	if(stat & (BROKEN | MAINT))
		return

	return ui_interact(user)

/obj/machinery/dna_vault/attack_hand(mob/user)
	if(..())
		return TRUE

	ui_interact(user)

/obj/machinery/dna_vault/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		roll_powers(user)
		ui = new(user, src, "DnaVault", name)
		ui.open()

/obj/machinery/dna_vault/proc/roll_powers(mob/user)
	if(LAZYIN(power_lottery, user))
		return

	var/list/genes

	for(var/datum/dna/gene/basic/vault/gene in GLOB.dna_genes)
		if(!initial(gene.name))
			continue

		if(gene.is_active(user))
			continue

		if(!gene.can_activate(user))
			continue

		LAZYADD(genes, initial(gene.name))

	if(!LAZYLEN(genes))
		CRASH("[src] rolled 0 genes.")

	var/list/picked_genes

	LAZYADD(picked_genes, pick_n_take(genes))
	LAZYADD(picked_genes, pick_n_take(genes))

	LAZYSET(power_lottery, user, picked_genes)

/obj/machinery/dna_vault/ui_data(mob/user)
	var/list/data = list(
		"plants" = LAZYLEN(plants),
		"plants_max" = plants_max,
		"animals" = LAZYLEN(animals),
		"animals_max" = animals_max,
		"dna" = LAZYLEN(dna),
		"dna_max" = dna_max,
		"completed" = completed,
		"used" = TRUE,
		"choiceA" = "",
		"choiceB" = ""
	)
	if(user && completed)
		var/list/genes = power_lottery[user]

		if(LAZYLEN(genes))
			data["used"] = FALSE
			data["choiceA"] = genes[1]
			data["choiceB"] = genes[2]

		else if(genes)
			data["used"] = TRUE

	return data

/obj/machinery/dna_vault/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("gene")
			if(!can_upgrade(usr, params["choice"]))
				return TRUE
			
			upgrade(usr, params["choice"])

			return TRUE

/obj/machinery/dna_vault/proc/check_goal()
	if(LAZYLEN(plants) >= plants_max && LAZYLEN(animals) >= animals_max && LAZYLEN(dna) >= dna_max)
		completed = TRUE


/obj/machinery/dna_vault/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/dna_probe))
		add_fingerprint(user)

		var/obj/item/dna_probe/probe = I
		var/uploaded = 0

		for(var/plant in probe.plants)
			if(!LAZYACCESS(plants, plant))
				uploaded++
				LAZYSET(plants, plant, 1)

		for(var/animal in probe.animals)
			if(!LAZYACCESS(animals, animal))
				uploaded++
				LAZYSET(animals, animal, 1)

		for(var/ui in probe.dna)
			if(!LAZYACCESS(dna, ui))
				uploaded++
				LAZYSET(dna, ui, 1)

		if(!uploaded)
			to_chat(user, span_warning("The [probe.name] has no relevant datapoints."))
			return ATTACK_CHAIN_PROCEED

		check_goal()
		to_chat(user, span_notice("You have uploaded <b>[uploaded]</b> new datapoints."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/machinery/dna_vault/proc/can_upgrade(mob/living/carbon/human/human, upgrade_name)
	if(!istype(human) || !upgrade_name)
		return FALSE

	if(!LAZYIN(power_lottery[human], upgrade_name))
		return FALSE

	if(!completed)
		return FALSE

	if(HAS_TRAIT(human, TRAIT_NO_DNA))
		balloon_alert(human, "ДНК не обнаружено!")
		return FALSE

	return TRUE

/obj/machinery/dna_vault/proc/upgrade(mob/living/carbon/human/human, upgrade_name)
	for(var/datum/dna/gene/basic/vault/gene as anything in subtypesof(/datum/dna/gene/basic/vault))
		if(initial(gene.name) != upgrade_name)
			continue

		if(gene.is_active(human))
			return FALSE

		if(!gene.can_activate(human))
			return FALSE

		gene.activate(human)
		break

	LAZYNULL(power_lottery[human])
