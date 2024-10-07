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
			// Botanic order
			"thc" = list("volume" = 30, "reward" = 100),
			"moonlin" = list("volume" = 30, "reward" = 100),
			"growthserum" = list("volume" = 15, "reward" = 100),
			"tirizene" = list("volume" = 30, "reward" = 125),
			"synaptizine" = list("volume" = 30, "reward" = 125),
			"weak_omnizine" = list("volume" = 30, "reward" = 125),
			"earthsblood" = list("volume" = 30, "reward" = 150),

			// Chemist order
			"pyrosium" = list("volume" = 30, "reward" = 75),
			"napalm" = list("volume" = 30, "reward" = 75),
			"synthflesh" = list("volume" = 30, "reward" = 80),
			"facid" = list("volume" = 15, "reward" = 100),
			"minttoxin" = list("volume" = 15, "reward" = 100),
			"sterilizine" = list("volume" = 30, "reward" = 100),
			"fomepizole" = list("volume" = 20, "reward" = 125),
			"mitocholide" = list("volume" = 30, "reward" = 150),
			"pen_acid" = list("volume" = 30, "reward" = 175),
			"sarin" = list("volume" = 10, "reward" = 200),
			"antiburn_stimulant" = list("volume" = 5, "reward" = 500),
		)
	var/list/unique_reagents = list(
			// Mixed Order
			"itching_powder" = list("volume" = 30, "reward" = 100),
			"fliptonium" = list("volume" = 10, "reward" = 150),
			"vhfcs" = list("volume" = 30, "reward" = 200),
			"rotatium" = list("volume" = 15, "reward" = 200),
			"bath_salts" = list("volume" = 10, "reward" = 220),
			"colorful_reagent" = list("volume" = 15, "reward" = 225),
			"capulettium_plus" = list("volume" = 15, "reward" = 225),
			"rezadone" = list("volume" = 30, "reward" = 250),
			"hairgrownium" = list("volume" = 30, "reward" = 250),
			"super_hairgrownium" = list("volume" = 15, "reward" = 300),
			"strange_reagent" = list("volume" = 15, "reward" = 300),
			"condensedcapsaicin" = list("volume" = 30, "reward" = 300),
			"glycerol" = list("volume" = 30, "reward" = 380),
			"hair_dye" = list("volume" = 10, "reward" = 400),
			"initropidril" = list("volume" = 5, "reward" = 750),
		)

/datum/cargo_quest/reagents/update_interface_icon()
	interface_images += path2assetID(/obj/item/reagent_containers/glass/beaker/large)

/datum/cargo_quest/reagents/add_goal(difficultly)
	var/list/possible_reagents_list = repeated_reagents.Copy() + unique_reagents.Copy()
	var/our_reagent = pick(possible_reagents_list)
	required_reagents[our_reagent] += possible_reagents_list[our_reagent]
	cargo_quest_reward = possible_reagents_list[our_reagent]["reward"]
	q_storage.reward += cargo_quest_reward
	update_desc(our_reagent, possible_reagents_list[our_reagent]["volume"])
	if(our_reagent in unique_reagents)
		unique_reagents.Remove(our_reagent)

/datum/cargo_quest/reagents/proc/update_desc(reagent_id, volume)
	var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_id]
	desc += "[capitalize(format_text(initial(reagent.name)))], [volume]u<br>"

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
		"b52" = list("volume" = 30,"reward" = 60),
		"bacchus_blessing" = list("volume" = 30,"reward" = 100),
		"beepskysmash" = list("volume" = 30,"reward" = 60),
		"demonsblood" = list("volume" = 30,"reward" = 40),
		"devilskiss" = list("volume" = 30,"reward" = 40),
		"driestmartini" = list("volume" = 30,"reward" = 40),
		"eggnog" = list("volume" = 30,"reward" = 40),
		"flamingmoe" = list("volume" = 30,"reward" = 60),
		"ginsonic" = list("volume" = 30,"reward" = 220),
		"hippiesdelight" = list("volume" = 30,"reward" = 130),
		"amnesia" = list("volume" = 30,"reward" = 80),
		"threemileisland" = list("volume" = 30,"reward" = 140),
		"neurotoxin" = list("volume" = 30,"reward" = 140),
		"rainbow_sky" = list("volume" = 30,"reward" = 160),
		"sbiten" = list("volume" = 30,"reward" = 300),
		"singulo" = list("volume" = 30,"reward" = 100),
		"suicider" = list("volume" = 30,"reward" = 100),
		"moonlight_skuma" = list("volume" = 30,"reward" = 120),
		"blue_moondrin" = list("volume" = 30,"reward" = 150),
		"red_moondrin" = list("volume" = 30,"reward" = 300),
		"nagasaki" = list("volume" = 30,"reward" = 120),
		"alcomender" = list("volume" = 30,"reward" = 100),
		"milk_plus" = list("volume" = 30,"reward" = 60),
		"teslasingylo" = list("volume" = 30,"reward" = 140),
		"telegol" = list("volume" = 30,"reward" = 280),
		"inabox" = list("volume" = 30,"reward" = 20),
		"monako" = list("volume" = 30,"reward" = 40),
		"slime_drink" = list("volume" = 30,"reward" = 40),
		"restart" = list("volume" = 30,"reward" = 200),
		"gibbfloats" = list("volume" = 30,"reward" = 40),
		"nuka_cola" = list("volume" = 30,"reward" = 80),
		"pumpkin_latte" = list("volume" = 30,"reward" = 40),
		"zazafizzy" = list("volume" = 30, "reward" = 30)
	)
	unique_reagents = list()


/datum/cargo_quest/reagents/drinks/update_interface_icon()
	for(var/reagent_id in required_reagents)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_id]
		if(reagent.drink_icon)
			interface_images += reagent_id
		else
			interface_images += path2assetID(/obj/item/reagent_containers/glass/beaker/large)
