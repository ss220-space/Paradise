//Abandon hope, everyone who enters here

//When changing reagents, remember about the horror hidden under the hood
/datum/cargo_quest/reagents
	quest_type_name = "Chemical"
	req_items = list(/obj/item/reagent_containers)
	bounty_jobs = (JOB_TITLE_CHEMIST)
	linked_departament = "Medical"

	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL)

	var/list/required_reagents = list()
	var/list/repeated_reagents = list(
			// Chemist order
			/datum/reagent/pyrosium = list("volume" = 30, "reward" = 75),
			/datum/reagent/napalm = list("volume" = 30, "reward" = 75),
			/datum/reagent/medicine/synthflesh = list("volume" = 30, "reward" = 80),
			/datum/reagent/acid/facid = list("volume" = 15, "reward" = 100),
			/datum/reagent/minttoxin = list("volume" = 15, "reward" = 100),
			/datum/reagent/medicine/sterilizine = list("volume" = 30, "reward" = 100),
			/datum/reagent/medicine/fomepizole = list("volume" = 20, "reward" = 125),
			/datum/reagent/medicine/mitocholide = list("volume" = 30, "reward" = 150),
			/datum/reagent/medicine/pen_acid = list("volume" = 30, "reward" = 175),
			/datum/reagent/sarin = list("volume" = 10, "reward" = 200),
			/datum/reagent/medicine/ab_stimulant = list("volume" = 5, "reward" = 500),
		)
	var/list/unique_reagents = list(
			// Mixed Order
			/datum/reagent/itching_powder = list("volume" = 30, "reward" = 100),
			/datum/reagent/fliptonium = list("volume" = 10, "reward" = 150),
			/datum/reagent/consumable/vhfcs = list("volume" = 30, "reward" = 200),
			/datum/reagent/rotatium = list("volume" = 15, "reward" = 200),
			/datum/reagent/bath_salts = list("volume" = 10, "reward" = 220),
			/datum/reagent/colorful_reagent = list("volume" = 15, "reward" = 225),
			/datum/reagent/capulettium_plus = list("volume" = 15, "reward" = 225),
			/datum/reagent/medicine/rezadone = list("volume" = 30, "reward" = 250),
			/datum/reagent/hairgrownium = list("volume" = 30, "reward" = 250),
			/datum/reagent/super_hairgrownium = list("volume" = 15, "reward" = 300),
			/datum/reagent/medicine/strange_reagent = list("volume" = 15, "reward" = 300),
			/datum/reagent/consumable/condensedcapsaicin = list("volume" = 30, "reward" = 300),
			/datum/reagent/glycerol = list("volume" = 30, "reward" = 380),
			/datum/reagent/hair_dye = list("volume" = 10, "reward" = 400),
			/datum/reagent/initropidril = list("volume" = 5, "reward" = 750),
		)

/datum/cargo_quest/reagents/update_interface_icon()
	interface_images += path2assetID(/obj/item/reagent_containers/glass/beaker/large)

/datum/cargo_quest/reagents/add_goal(difficultly)
	var/list/possible_reagents_list = repeated_reagents.Copy() + unique_reagents.Copy()
	var/our_reagent = pick(possible_reagents_list)
	required_reagents[our_reagent] += possible_reagents_list[our_reagent]
	cargo_quest_reward = possible_reagents_list[our_reagent]["reward"]
	q_storage.reward += cargo_quest_reward
	update_reagent_desc(our_reagent, possible_reagents_list[our_reagent]["volume"])
	if(our_reagent in unique_reagents)
		unique_reagents.Remove(our_reagent)

/datum/cargo_quest/reagents/proc/update_reagent_desc(reagent_id, volume)
	var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_id]
	desc += "[capitalize(format_text(initial(reagent.name)))], [volume] ед.<br>"

/datum/cargo_quest/reagents/check_required_item(atom/movable/check_item)
	if(!length(required_reagents))
		return FALSE

	var/obj/item/reagent_containers/container = check_item
	if(!container.reagents)
		return FALSE

	for(var/datum/reagent/R in container.reagents.reagent_list)
		if((R.id in required_reagents) && required_reagents[R.id]["volume"] <= R.volume)
			return TRUE

/datum/cargo_quest/reagents/length_quest()
	return length(required_reagents)

/datum/cargo_quest/reagents/drinks
	quest_type_name = "Drink"
	bounty_jobs = list(JOB_TITLE_BARTENDER)
	linked_departament = "Support"

	repeated_reagents = list(
		/datum/reagent/consumable/ethanol/b52 = list("volume" = 30,"reward" = 60),
		/datum/reagent/consumable/ethanol/bacchus_blessing = list("volume" = 30,"reward" = 100),
		/datum/reagent/consumable/ethanol/beepsky_smash = list("volume" = 30,"reward" = 60),
		/datum/reagent/consumable/ethanol/demonsblood = list("volume" = 30,"reward" = 40),
		/datum/reagent/consumable/ethanol/devilskiss = list("volume" = 30,"reward" = 40),
		/datum/reagent/consumable/ethanol/driestmartini = list("volume" = 30,"reward" = 40),
		/datum/reagent/consumable/ethanol/eggnog = list("volume" = 30,"reward" = 40),
		/datum/reagent/consumable/ethanol/flaming_homer = list("volume" = 30,"reward" = 60),
		/datum/reagent/ginsonic = list("volume" = 30,"reward" = 220),
		/datum/reagent/consumable/ethanol/hippies_delight = list("volume" = 30,"reward" = 130),
		/datum/reagent/consumable/ethanol/amnesia = list("volume" = 30,"reward" = 80),
		/datum/reagent/consumable/ethanol/threemileisland = list("volume" = 30,"reward" = 140),
		/datum/reagent/consumable/ethanol/neurotoxin = list("volume" = 30,"reward" = 140),
		/datum/reagent/consumable/ethanol/rainbow_sky = list("volume" = 30,"reward" = 160),
		/datum/reagent/consumable/ethanol/sbiten = list("volume" = 30,"reward" = 300),
		/datum/reagent/consumable/ethanol/singulo = list("volume" = 30,"reward" = 100),
		/datum/reagent/consumable/ethanol/suicider = list("volume" = 30,"reward" = 100),
		/datum/reagent/consumable/ethanol/moonlight_skuma = list("volume" = 30,"reward" = 120),
		/datum/reagent/consumable/ethanol/blue_moondrin = list("volume" = 30,"reward" = 150),
		/datum/reagent/consumable/ethanol/red_moondrin = list("volume" = 30,"reward" = 300),
		/datum/reagent/consumable/ethanol/nagasaki = list("volume" = 30,"reward" = 120),
		/datum/reagent/consumable/ethanol/alcomender = list("volume" = 30,"reward" = 100),
		/datum/reagent/consumable/ethanol/milk_plus = list("volume" = 30,"reward" = 60),
		/datum/reagent/consumable/ethanol/teslasingylo = list("volume" = 30,"reward" = 140),
		/datum/reagent/consumable/ethanol/telegol = list("volume" = 30,"reward" = 280),
		/datum/reagent/consumable/ethanol/inabox = list("volume" = 30,"reward" = 20),
		/datum/reagent/consumable/ethanol/monako = list("volume" = 30,"reward" = 40),
		/datum/reagent/consumable/ethanol/slime_drink = list("volume" = 30,"reward" = 40),
		/datum/reagent/consumable/ethanol/synthanol/restart = list("volume" = 30,"reward" = 200),
		/datum/reagent/consumable/drink/gibbfloats = list("volume" = 30,"reward" = 40),
		/datum/reagent/consumable/drink/cold/nuka_cola = list("volume" = 30,"reward" = 80),
		/datum/reagent/consumable/drink/pumpkin_latte = list("volume" = 30,"reward" = 40),
		/datum/reagent/consumable/drink/cold/zaza/fizzy = list("volume" = 30, "reward" = 30),
	)
	unique_reagents = list()

/datum/cargo_quest/reagents/drinks/update_interface_icon()
	for(var/reagent_id in required_reagents)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_id]
		if(reagent.drink_icon)
			interface_images += reagent_id
		else
			interface_images += path2assetID(/obj/item/reagent_containers/glass/beaker/large)
