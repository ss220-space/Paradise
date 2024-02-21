/datum/cargo_quest/reagents
	quest_type_name = "Chemical"
	req_items = list(/obj/item/reagent_containers)
	interface_icon = 'icons/obj/chemical.dmi'
	interface_icon_state = "beakerlarge"

	difficultly_flags = (QUEST_DIFFICULTY_EASY)

	var/list/required_reagents = list()
	var/list/repeated_reagents = list("antiburn_stimulant" = list("volume" = 5, "reward" = 110),
			"synthflesh" = list("volume" = 50, "reward" = 75),
			"rezadone" = list("volume" = 30, "reward" = 80),
			"sterilizine" = list("volume" = 50, "reward" = 50),
			"earthsblood" = list("volume" = 50, "reward" = 120),
			"pen_acid" = list("volume" = 50, "reward" = 50),
			"mitocholide" = list("volume" = 50, "reward" = 75),
			"condensedcapsaicin" = list("volume" = 30, "reward" = 90),
			"napalm" = list("volume" = 50, "reward" = 65),
			"thc" = list("volume" = 30, "reward" = 90),
			"fliptonium" = list("volume" = 10, "reward" = 90),
			"glycerol" = list("volume" = 30, "reward" = 110),
			"weak_omnizine" = list("volume" = 30, "reward" = 45),
			"super_hairgrownium" = list("volume" = 15, "reward" = 110),
		)
	var/list/unique_reagents = list("strange_reagent" = list("volume" = 15, "reward" = 80),
			"fomepizole" = list("volume" = 20, "reward" = 60),
	  		"synaptizine" = list("volume" = 50, "reward" = 150),
			"hair_dye" = list("volume" = 10, "reward" = 110),
			"colorful_reagent" = list("volume" = 10, "reward" = 120),
			"vhfcs" = list("volume" = 30, "reward" = 135),
			"moonlin" = list("volume" = 40, "reward" = 75),
			"tirizene" = list("volume" = 40, "reward" = 90),
			"bath_salts" = list("volume" = 10, "reward" = 120),
			"growthserum" = list("volume" = 15, "reward" = 55)
			)

/datum/cargo_quest/reagents/add_goal(difficultly)
	var/list/possible_reagents_list = repeated_reagents.Copy() + unique_reagents.Copy()
	var/our_reagent = pick(possible_reagents_list)
	required_reagents[our_reagent] += possible_reagents_list[our_reagent]
	q_storage.reward += possible_reagents_list[our_reagent]["reward"]
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
	repeated_reagents = list(
		"b52" = list("volume" = 30,"reward" = 60),
		"bacchus_blessing" = list("volume" = 30,"reward" = 100),
		"beepskysmash" = list("volume" = 30,"reward" = 60),
		"demonsblood" = list("volume" = 30,"reward" = 40),
		"devilskiss" = list("volume" = 30,"reward" = 40),
		"driestmartini" = list("volume" = 30,"reward" = 40),
		"eggnog" = list("volume" = 30,"reward" = 40),
		"flamingmoe" = list("volume" = 30,"reward" = 40),
		"ginsonic" = list("volume" = 30,"reward" = 80),
		"hippiesdelight" = list("volume" = 30,"reward" = 60),
		"amnesia" = list("volume" = 30,"reward" = 80),
		"threemileisland" = list("volume" = 30,"reward" = 80),
		"neurotoxin" = list("volume" = 30,"reward" = 80),
		"rainbow_sky" = list("volume" = 30,"reward" = 100),
		"sbiten" = list("volume" = 30,"reward" = 60),
		"singulo" = list("volume" = 30,"reward" = 80),
		"suicider" = list("volume" = 30,"reward" = 60),
		"moonlight_skuma" = list("volume" = 30,"reward" = 60),
		"blue_moondrin" = list("volume" = 30,"reward" = 60),
		"red_moondrin" = list("volume" = 30,"reward" = 100),
		"nagasaki" = list("volume" = 30,"reward" = 60),
		"alcomender" = list("volume" = 30,"reward" = 80),
		"milk_plus" = list("volume" = 30,"reward" = 60),
		"teslasingylo" = list("volume" = 30,"reward" = 140),
		"telegol" = list("volume" = 30,"reward" = 140),
		"inabox" = list("volume" = 30,"reward" = 20),
		"monako" = list("volume" = 30,"reward" = 40),
		"slime_drink" = list("volume" = 30,"reward" = 40),
		"restart" = list("volume" = 30,"reward" = 140),
		"gibbfloats" = list("volume" = 30,"reward" = 40),
		"nuka_cola" = list("volume" = 30,"reward" = 60),
		"pumpkin_latte" = list("volume" = 30,"reward" = 40),
		"zazafizzy" = list("volume" = 30, "reward" = 20)
	)
	unique_reagents = list()


/datum/cargo_quest/reagents/drinks/update_interface_icon()
	for(var/reagent_id in required_reagents)
		var/datum/reagent/reagent = GLOB.chemical_reagents_list[reagent_id]
		if(reagent.drink_icon)
			interface_images += icon2base64(icon('icons/obj/drinks.dmi', reagent.drink_icon, SOUTH, 1))
		else
			interface_images += icon2base64(icon('icons/obj/chemical.dmi', "beakerlarge", SOUTH, 1))
