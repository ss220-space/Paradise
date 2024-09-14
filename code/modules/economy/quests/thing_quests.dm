/datum/cargo_quest/thing
	quest_type_name = "generic thing"
	var/list/easy_items
	var/list/normal_items
	var/list/hard_items
	var/list/very_hard_items
	/// If TRUE, the same items from this category will not be found in the same order
	var/unique_things = TRUE
	var/list/current_list

/datum/cargo_quest/thing/generate_goal_list(difficultly)

	var/list/difficult_list
	switch(difficultly)
		if(QUEST_DIFFICULTY_EASY)
			difficult_list = easy_items

		if(QUEST_DIFFICULTY_NORMAL)
			difficult_list = normal_items

		if(QUEST_DIFFICULTY_HARD)
			difficult_list = hard_items

		if(QUEST_DIFFICULTY_VERY_HARD)
			difficult_list = very_hard_items

	return difficult_list

/datum/cargo_quest/thing/add_goal(difficultly)
	var/list/difficult_list = generate_goal_list(difficultly)
	var/obj/generated_item = pick(difficult_list)

	q_storage.reward += difficult_list[generated_item]
	if(unique_things)
		difficult_list.Remove(generated_item)

	req_items += generated_item
	current_list = req_items.Copy()

	desc += "[capitalize(format_text(initial(generated_item.name)))] <br>"


/datum/cargo_quest/thing/update_interface_icon()
	if(item_for_show)
		interface_images += path2assetID(item_for_show)
		return
	for(var/our_item in req_items)
		var/obj/obj = our_item
		if(initial(obj.icon) && initial(obj.icon_state))
			interface_images += path2assetID(our_item)
		else
			interface_images += path2assetID(/obj/item/storage/box)

/datum/cargo_quest/thing/length_quest()
	return length(req_items)

/datum/cargo_quest/thing/check_required_item(atom/movable/check_item)
	if(check_item.type in current_list)
		current_list.Remove(check_item.type)
		return TRUE
	return FALSE

/datum/cargo_quest/thing/after_check()
	. = TRUE
	current_list = req_items.Copy()

/datum/cargo_quest/thing/xenobio
	quest_type_name = "Xenobiological extract"
	easy_items = list(
		/obj/item/slime_extract/grey = 45,
		/obj/item/slime_extract/orange = 90,
		/obj/item/slime_extract/purple = 90,
		/obj/item/slime_extract/blue = 90,
		/obj/item/slime_extract/metal = 90,
		/obj/item/slime_extract/yellow = 115,
		/obj/item/slime_extract/darkblue = 115,
		/obj/item/slime_extract/darkpurple = 115,
		/obj/item/slime_extract/silver = 115,
	)
	normal_items = list(
		/obj/item/slime_extract/bluespace = 170,
		/obj/item/slime_extract/sepia = 170,
		/obj/item/slime_extract/cerulean = 170,
		/obj/item/slime_extract/pyrite = 170,
		/obj/item/slime_extract/green = 215,
		/obj/item/slime_extract/red = 215,
		/obj/item/slime_extract/pink = 215,
		/obj/item/slime_extract/gold = 215
	)
	hard_items = list(
		/obj/item/slime_extract/adamantine = 270,
		/obj/item/slime_extract/oil = 270,
		/obj/item/slime_extract/black = 270,
		/obj/item/slime_extract/lightpink = 270,
		/obj/item/slime_extract/rainbow = 300
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)

/datum/cargo_quest/thing/organs
	quest_type_name = "Organ"
	normal_items = list(
		/obj/item/organ/internal/eyes/tajaran = 105,
		/obj/item/organ/internal/eyes/vulpkanin = 105,
		/obj/item/organ/internal/headpocket = 155,
		/obj/item/organ/internal/eyes/unathi = 170,
		/obj/item/organ/internal/eyes/nian = 170,
		/obj/item/organ/internal/liver/skrell = 170,
	)
	hard_items = list(
		/obj/item/organ/internal/kidneys/grey = 175,
		/obj/item/organ/internal/liver/kidan = 175,
		/obj/item/organ/internal/lungs/slime = 185,
		/obj/item/organ/internal/liver/grey = 200,
		/obj/item/organ/internal/heart/slime = 210,
		/obj/item/organ/internal/liver/diona = 300,
		/obj/item/organ/internal/lungs/unathi/ash_walker = 325,
		/obj/item/organ/internal/eyes/unathi/ash_walker = 350,
		/obj/item/organ/internal/eyes/unathi/ash_walker_shaman = 350,
		/obj/item/organ/internal/lantern = 400
	)
	very_hard_items = list(
		/obj/item/organ/internal/heart/cursed = 550,
		/obj/item/organ/internal/xenos/plasmavessel/hunter = 550,
		/obj/item/organ/internal/xenos/plasmavessel/drone = 550,
		/obj/item/organ/internal/xenos/neurotoxin/sentinel = 650,
		/obj/item/organ/internal/wryn/glands = 700,
		/obj/item/organ/internal/xenos/hivenode = 700,
		/obj/item/organ/internal/heart/plasmaman = 750,
		/obj/item/organ/internal/xenos/acidgland/sentinel = 750,
		/obj/item/organ/internal/xenos/acidgland/praetorian = 750,
		/obj/item/organ/internal/xenos/resinspinner = 750,
		/obj/item/organ/internal/xenos/neurotoxin = 850,
	)
	difficultly_flags = (QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD|QUEST_DIFFICULTY_VERY_HARD)

/datum/cargo_quest/thing/foods
	quest_type_name = "Food"
	easy_items = list(
		/obj/item/reagent_containers/food/snacks/friedegg = 10,
		/obj/item/reagent_containers/food/snacks/tofuburger = 10,
		/obj/item/reagent_containers/food/snacks/boiledpelmeni = 20,
		/obj/item/reagent_containers/food/snacks/omelette = 20,
		/obj/item/reagent_containers/food/snacks/cheeseburger = 30,
		/obj/item/reagent_containers/food/snacks/benedict = 30,
		/obj/item/reagent_containers/food/snacks/monkeyburger = 30,
		/obj/item/reagent_containers/food/snacks/hotdog = 30,
		/obj/item/reagent_containers/food/snacks/sausage = 20,
		/obj/item/reagent_containers/food/snacks/pastatomato = 20,
		/obj/item/reagent_containers/food/snacks/soup/tomatosoup = 20,
		/obj/item/reagent_containers/food/snacks/meatballspaghetti = 30,
		/obj/item/reagent_containers/food/snacks/smokedsausage = 30,
		/obj/item/reagent_containers/food/snacks/lasagna = 40,
		/obj/item/reagent_containers/food/snacks/candy/jellybean/purple = 50,
		/obj/item/reagent_containers/food/snacks/muffin = 60,
	)
	normal_items = list(
		/obj/item/reagent_containers/food/snacks/yakiimo = 50,
		/obj/item/reagent_containers/food/snacks/soup/beetsoup = 50,
		/obj/item/reagent_containers/food/snacks/fishburger = 60,
		/obj/item/reagent_containers/food/snacks/monkeysdelight = 60,
		/obj/item/reagent_containers/food/snacks/pancake/choc_chip_pancake = 60,
		/obj/item/reagent_containers/food/snacks/superbiteburger = 60,
		/obj/item/reagent_containers/food/snacks/sushi_TobikoEgg = 60,
		/obj/item/reagent_containers/food/snacks/sushi_Unagi = 60,
		/obj/item/reagent_containers/food/snacks/sliceable/salami = 60,
		/obj/item/reagent_containers/food/snacks/amanitajelly = 70,
		/obj/item/reagent_containers/food/snacks/candy/jawbreaker = 70,
		/obj/item/reagent_containers/food/snacks/plov = 70,
		/obj/item/reagent_containers/food/snacks/donut/chaos = 80,
		/obj/item/reagent_containers/food/snacks/sliceable/noel = 80,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly = 90,
		/obj/item/reagent_containers/food/snacks/aesirsalad = 90,
		/obj/item/reagent_containers/food/snacks/candy/sucker = 60,
		/obj/item/reagent_containers/food/snacks/appletart = 90,
		/obj/item/reagent_containers/food/snacks/chawanmushi = 90,
	)
	hard_items = list(
		/obj/item/reagent_containers/food/snacks/sashimi = 120,
		/obj/item/reagent_containers/food/snacks/meatsteak/vulpkanin = 100,
		/obj/item/reagent_containers/food/snacks/meatsteak/human = 100,
		/obj/item/reagent_containers/food/snacks/meatsteak/slime = 100,
		/obj/item/reagent_containers/food/snacks/meatsteak/skrell = 100,
		/obj/item/reagent_containers/food/snacks/meatsteak/tajaran = 100,
		/obj/item/reagent_containers/food/snacks/meatsteak/unathi = 100,
		/obj/item/reagent_containers/food/snacks/meatsteak/vox = 120,
		/obj/item/reagent_containers/food/snacks/meatsteak/wryn = 120,
		/obj/item/reagent_containers/food/snacks/meatsteak/kidan = 120,
		/obj/item/reagent_containers/food/snacks/meatsteak/diona = 120,
		/obj/item/reagent_containers/food/snacks/meatsteak/nian = 120,
		/obj/item/reagent_containers/food/snacks/meatsteak/drask = 120,
		/obj/item/reagent_containers/food/snacks/meatsteak/grey = 120,
		/obj/item/reagent_containers/food/snacks/vulpix/chilli = 120,
		/obj/item/reagent_containers/food/snacks/soup/stew = 130,
		/obj/item/reagent_containers/food/snacks/vulpix/cheese = 130,
		/obj/item/reagent_containers/food/snacks/vulpix = 130,
		/obj/item/reagent_containers/food/snacks/weirdoliviersalad = 130,
		/obj/item/reagent_containers/food/snacks/doner_mushroom = 130,
		/obj/item/reagent_containers/food/snacks/doner_vegan = 130,
		/obj/item/reagent_containers/food/snacks/tajaroni = 120,
		/obj/item/reagent_containers/food/snacks/boiledslimecore = 120,
		/obj/item/reagent_containers/food/snacks/sliceable/lizard = 120,
		/obj/item/reagent_containers/food/snacks/shawarma = 150,
		/obj/item/reagent_containers/food/snacks/dionaroast = 180,
		/obj/item/reagent_containers/food/snacks/fruitcup = 120,
		/obj/item/reagent_containers/food/snacks/candy/cotton/bad_rainbow = 200,
		/obj/item/reagent_containers/food/snacks/candy/cotton/rainbow = 150,
		/obj/item/reagent_containers/food/snacks/fried_vox = 120,
		/obj/item/reagent_containers/food/snacks/sliceable/bread/xeno = 200,
		/obj/item/reagent_containers/food/snacks/rofflewaffles = 150,
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)

/datum/cargo_quest/thing/miner
	quest_type_name = "Shaft Miner Loot"
	easy_items = list(
		/obj/item/crusher_trophy/legion_skull = 60,
		/obj/item/crusher_trophy/watcher_wing = 50,
		/obj/item/gem/topaz = 60,
		/obj/item/gem/emerald = 60,
		/obj/item/gem/sapphire = 60,
		/obj/item/gem/ruby = 60,
		/obj/item/crusher_trophy/goliath_tentacle = 95,
	)
	normal_items = list(
		/obj/item/gem/rupee = 130,
		/obj/item/gem/fdiamond = 220,
		/obj/item/crusher_trophy/blaster_tubes/magma_wing = 110,
		/obj/item/crusher_trophy/watcher_wing/ice_wing = 110,
	)
	hard_items = list(
		/obj/item/gem/magma = 260,
		/obj/item/gem/phoron = 350,
		/obj/item/gem/purple = 400,
		/obj/item/gem/amber = 400,
	)

	very_hard_items = list(
		/obj/item/gem/data = 450,
		/obj/item/gem/void = 500,
		/obj/effect/mob_spawn/human/ash_walker = 550,
		/obj/item/gem/bloodstone = 650,
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD|QUEST_DIFFICULTY_VERY_HARD)

/datum/cargo_quest/thing/minerals
	quest_type_name = "Minerals"
	var/list/required_minerals = list()
	unique_things = FALSE
	var/static/list/unique_minerals = list(/obj/item/stack/sheet/bluespace_crystal, /obj/item/stack/sheet/mineral/bananium, /obj/item/stack/sheet/mineral/tranquillite)
	req_items = list(/obj/item/stack/sheet)
	easy_items = list(
		/obj/item/stack/sheet/metal = list("reward" = 20, "amount" = 50),
		/obj/item/stack/sheet/mineral/gold = list("reward" = 70, "amount" = 20),
		/obj/item/stack/sheet/mineral/titanium = list("reward" = 60, "amount" = 30),
		/obj/item/stack/sheet/mineral/uranium = list("reward" = 65, "amount" = 15),
		/obj/item/stack/sheet/glass = list("reward" = 15, "amount" = 50),
	)
	normal_items = list(
		/obj/item/stack/sheet/mineral/diamond = list("reward" = 100, "amount" = 10),
		/obj/item/stack/sheet/plasteel = list("reward" = 90, "amount" = 30),
		/obj/item/stack/sheet/mineral/plasma = list("reward" = 120, "amount" = 40),
		/obj/item/stack/sheet/mineral/silver = list("reward" = 90, "amount" = 25)
	)
	hard_items = list(
		/obj/item/stack/sheet/bluespace_crystal = list("reward" = 220, "amount" = 7),
		/obj/item/stack/sheet/mineral/bananium = list("reward" = 340, "amount" = 4),
		/obj/item/stack/sheet/mineral/tranquillite = list("reward" = 440, "amount" = 4),
		/obj/item/stack/sheet/mineral/adamantine = list("reward" = 600, "amount" = 5)
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)


/datum/cargo_quest/thing/minerals/add_goal(difficultly)
	var/list/difficult_list = generate_goal_list(difficultly)
	var/obj/item/generated_mineral = pick(difficult_list)

	q_storage.reward += difficult_list[generated_mineral]["reward"]
	if(!required_minerals[generated_mineral])
		required_minerals += generated_mineral
	required_minerals[generated_mineral] += difficult_list[generated_mineral]["amount"]
	desc = list()
	for(var/mineral in required_minerals)
		var/obj/desc_mineral = mineral
		desc += "[capitalize(format_text(initial(desc_mineral.name)))],<br>  amount: [required_minerals[mineral]]<br>"
	if(generated_mineral in unique_minerals)
		difficult_list.Remove(generated_mineral)
	current_list = required_minerals.Copy()
	if(unique_things)
		difficult_list.Remove(generated_mineral)

/datum/cargo_quest/thing/minerals/check_required_item(atom/movable/check_item)
	if(!length(required_minerals))
		return FALSE

	var/obj/item/stack/sheet/sheet = check_item
	for(var/mineral in current_list)
		if(!istype(sheet, mineral))
			continue
		if(current_list[mineral] <= 0)
			continue
		current_list[mineral] -= sheet.get_amount()
		return TRUE

/datum/cargo_quest/thing/minerals/after_check()
	. = TRUE
	for(var/mineral in current_list)
		if((current_list[mineral] > 0) && (current_list[mineral] != required_minerals[mineral]))
			. = FALSE
			break
	current_list = required_minerals.Copy()

/datum/cargo_quest/thing/minerals/update_interface_icon()
	for(var/mineral in required_minerals)
		interface_images += path2assetID(mineral)

/datum/cargo_quest/thing/minerals/length_quest()
	var/stack_length
	for(var/mineral in required_minerals)
		stack_length += CEILING(required_minerals[mineral]/50, 1)
	return stack_length

/datum/cargo_quest/thing/minerals/plasma
	req_items = list(/obj/item/stack/sheet/mineral/plasma)
	normal_items = list(
		/obj/item/stack/sheet/mineral/plasma = list("reward" = 130, "amount" = 50),
	)
	difficultly_flags = (QUEST_DIFFICULTY_NORMAL)

/datum/cargo_quest/thing/seeds
	quest_type_name = "Seeds"
	easy_items = list(
		/obj/item/seeds/harebell = 0, //Why? - Becouse we can
		/obj/item/seeds/starthistle = 0,
		/obj/item/seeds/glowshroom/glowcap = 10,
		/obj/item/seeds/nettle/death = 10,
		/obj/item/seeds/ambrosia/gaia = 10,
		/obj/item/seeds/ambrosia/deus = 10,
		/obj/item/seeds/cotton/durathread = 20,
		/obj/item/seeds/grass/carpet = 20,
		/obj/item/seeds/tobacco/space = 20,
		/obj/item/seeds/tomato/blue/bluespace = 30,
		/obj/item/seeds/glowshroom/shadowshroom = 30,
		/obj/item/seeds/tomato/blood = 30,
		/obj/item/seeds/tomato/blue = 30,
		/obj/item/seeds/sunflower/novaflower = 30,
		/obj/item/seeds/carrot/parsnip = 30,
		/obj/item/seeds/tea/astra = 40,
		/obj/item/seeds/soya/olive/charc = 40,
		/obj/item/seeds/geranium = 40,
		/obj/item/seeds/lily = 40,
		/obj/item/seeds/geranium/forgetmenot = 40,
		/obj/item/seeds/coffee/robusta = 40,
		/obj/item/seeds/apple/gold = 50,
		/obj/item/seeds/soya/koi = 50,
		/obj/item/seeds/redbeet = 50,
		/obj/item/seeds/sunflower/moonflower = 50,
		/obj/item/seeds/chili/ice = 50,
		/obj/item/seeds/tomato/killer = 50,
		/obj/item/seeds/cocoapod/vanillapod = 50,
		/obj/item/seeds/plump/walkingmushroom = 50,

	)
	normal_items = list(
		/obj/item/seeds/onion/red = 60,
		/obj/item/seeds/firelemon = 60,
		/obj/item/seeds/cannabis/white = 60,
		/obj/item/seeds/cannabis/rainbow = 60,
		/obj/item/seeds/cherry/blue = 60,
		/obj/item/seeds/tower/steel = 60,
		/obj/item/seeds/berry/glow = 70,
		/obj/item/seeds/berry/poison = 70,
		/obj/item/seeds/wheat/oat = 70,
		/obj/item/seeds/chili/ghost = 70,
		/obj/item/seeds/corn/snapcorn = 70,
		/obj/item/seeds/cocoapod/bungotree = 70,
		/obj/item/seeds/grape/green = 70,
		/obj/item/seeds/banana/bluespace = 70,
		/obj/item/seeds/eggplant/eggy = 70,
		/obj/item/seeds/watermelon/holy = 70,
		/obj/item/seeds/orange_3d = 70,
		/obj/item/seeds/pumpkin/blumpkin = 80,
		/obj/item/seeds/cannabis/ultimate = 80,
		/obj/item/seeds/wheat/buckwheat = 80,
		/obj/item/seeds/cannabis/death = 80,
		/obj/item/seeds/potato/sweet = 80,
		/obj/item/seeds/berry/death = 80,
		/obj/item/seeds/banana/mime = 80,
		/obj/item/seeds/angel = 90,
		/obj/item/seeds/lavaland/cactus = 100,
		/obj/item/seeds/lavaland/ember = 100,
		/obj/item/seeds/lavaland/inocybe = 100,
		/obj/item/seeds/lavaland/polypore = 100,
		/obj/item/seeds/lavaland/porcini = 100,
	)


	very_hard_items = list(
		/obj/item/seeds/kudzu = 460,
		/obj/item/seeds/cherry/bomb = 640,
		/obj/item/seeds/apple/poisoned = 640,
		/obj/item/seeds/wheat/meat = 640,
		/obj/item/seeds/gatfruit = 760
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_VERY_HARD)

/datum/cargo_quest/thing/botanygenes
	quest_type_name = "Botany Genes on Disks"
	item_for_show = /obj/item/disk/plantgene
	req_items = list(/obj/item/disk/plantgene)
	var/list/required_genes = list()
	easy_items = list(
		/datum/plant_gene/trait/plant_type/fungal_metabolism = 60,
		/datum/plant_gene/trait/squash = 60,
		/datum/plant_gene/trait/repeated_harvest = 60,
		/datum/plant_gene/trait/maxchem = 60,
		/datum/plant_gene/trait/stinging = 90,
		/datum/plant_gene/trait/glow = 100,
	)
	normal_items = list(
		/datum/plant_gene/trait/battery = 110,
		/datum/plant_gene/trait/glow/red = 110,
		/datum/plant_gene/trait/slip = 110,
		/datum/plant_gene/trait/cell_charge = 110,
		/datum/plant_gene/trait/teleport = 130,
		/datum/plant_gene/trait/plant_type/weed_hardy = 150,
		/datum/plant_gene/trait/noreact = 160,
		/datum/plant_gene/trait/glow/shadow = 160,
	)
	hard_items = list(
		/datum/plant_gene/trait/plant_laughter = 200,
		/datum/plant_gene/trait/fire_resistance = 200,
		/datum/plant_gene/trait/glow/berry = 210,
		/datum/plant_gene/trait/smoke = 330,

	)

	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)

/datum/cargo_quest/thing/botanygenes/add_goal(difficultly)

	var/list/difficult_list = generate_goal_list(difficultly)
	var/datum/plant_gene/generated_gene = pick(difficult_list)

	q_storage.reward += difficult_list[generated_gene]
	if(unique_things)
		difficult_list.Remove(generated_gene)

	required_genes += generated_gene
	current_list = required_genes.Copy()

	desc += "[capitalize(format_text(initial(generated_gene.name)))] <br>"

/datum/cargo_quest/thing/botanygenes/length_quest()
	return length(required_genes)

/datum/cargo_quest/thing/botanygenes/check_required_item(atom/movable/check_item)
	if(!length(required_genes))
		return FALSE

	var/obj/item/disk/plantgene/genedisk = check_item

	for(var/gene in current_list)
		if(genedisk.gene?.type == gene)
			current_list.Remove(gene)
			return TRUE

	return FALSE

/datum/cargo_quest/thing/botanygenes/after_check()
	. = TRUE
	current_list = required_genes.Copy()

/datum/cargo_quest/thing/genes
	quest_type_name = "DNA Genes"
	item_for_show = /obj/item/dnainjector
	req_items = list(/obj/item/dnainjector)
	var/list/required_blocks = list()
	normal_items = list(
		"LISP" = 150,
		"MUTE" = 150,
		"RAD" = 150,
		"OBESITY" = 150,
		"SWEDE" = 150,
		"SCRAMBLE" = 150,
		"WEAK" = 150,
		"HORNS" = 150,
		"COMIC" = 150,
		"PARAPLEGIA" = 150,
	)

	hard_items = list(
		"SOBER" = 200,
		"PSYRESIST" = 200,
		"SHADOW" = 200,
		"CHAMELEON" = 200,
		"CRYO" = 200,
		"EAT" = 200,
		"JUMP" = 200,
		"IMMOLATE" = 200,
		"EMPATH" = 200,
		"STRONG" = 200,
		"BLINDNESS" = 200,
		"POLYMORPH" = 200,
		"COLOURBLIND" = 200,
		"DEAF" = 200,
		"CLUMSY" = 200,
		"COUGH" = 200,
		"GLASSES" = 200,
		"EPILEPSY" = 200,
		"WINGDINGS" = 200,
		"BREATHLESS" = 250,
		"COLD" = 200,
		"HALLUCINATION" = 200,
		"FARVISION" = 200,
	)
	very_hard_items = list(
		"NOPRINTS" = 250,
		"SHOCKIMMUNITY" = 200,
		"SMALLSIZE" = 250,
		"HULK" = 300,
		"TELE" = 300,
		"FIRE" = 350,
		"XRAY" = 350,
		"REMOTEVIEW" = 350,
		"REGENERATE" = 350,
		"INCREASERUN" = 350,
		"REMOTETALK" = 350,
		"MORPH" = 350,
	)
	difficultly_flags = (QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD|QUEST_DIFFICULTY_VERY_HARD)

/datum/cargo_quest/thing/genes/length_quest()
	return length(required_blocks)

/datum/cargo_quest/thing/genes/add_goal(difficultly)

	var/list/difficult_list = generate_goal_list(difficultly)

	var/generated_gene = pick(difficult_list)
	q_storage.reward += difficult_list[generated_gene]
	if(unique_things)
		difficult_list.Remove(generated_gene)

	for(var/block in GLOB.assigned_blocks)
		if(block == generated_gene)
			required_blocks += block
			break

	desc += "[generated_gene] <br>"
	current_list = required_blocks.Copy()

/datum/cargo_quest/thing/genes/check_required_item(atom/movable/check_item)

	if(!length(required_blocks))
		return FALSE

	var/obj/item/dnainjector/dnainjector = check_item
	if(!dnainjector.block)
		return FALSE

	for(var/block in current_list)
		if(block != GLOB.assigned_blocks[dnainjector.block])
			continue
		var/list/BOUNDS = GetDNABounds(dnainjector.block)
		if(dnainjector.buf.dna.SE[dnainjector.block] >= BOUNDS[DNA_ON_LOWERBOUND])
			current_list.Remove(block)
			return TRUE

	return FALSE

/datum/cargo_quest/thing/genes/after_check()
	. = TRUE
	current_list = required_blocks.Copy()


#define REQUIRED_BLOOD_AMOUNT 10
/datum/cargo_quest/thing/virus
	quest_type_name = "Viruses symptoms in vials (10u minimum)"
	item_for_show = /obj/item/reagent_containers/glass/beaker/vial
	req_items = list(/obj/item/reagent_containers/glass/beaker/vial)

	var/list/required_symptoms = list()

	normal_items = list(
		/datum/symptom/shivering = 90,
		/datum/symptom/fever = 90,
		/datum/symptom/sneeze = 130,
		/datum/symptom/itching = 130,
		/datum/symptom/headache = 130,
		/datum/symptom/cough = 130,
		/datum/symptom/oxygen = 140,
		/datum/symptom/painkiller = 150,
		/datum/symptom/epinephrine = 150,
		/datum/symptom/mind_restoration = 150,
		/datum/symptom/heal = 150,
		/datum/symptom/youth = 170,
		/datum/symptom/blood = 170,
		/datum/symptom/voice_change = 170,
		/datum/symptom/damage_converter = 170,
		/datum/symptom/sensory_restoration = 170,
		/datum/symptom/hallucigen = 170,

	)

	hard_items = list(
		/datum/symptom/viralevolution = 200,
		/datum/symptom/viraladaptation = 200,
		/datum/symptom/flesh_eating = 200,
		/datum/symptom/heal/metabolism = 200,
		/datum/symptom/fire = 210,
		/datum/symptom/vomit = 240,
		/datum/symptom/vitiligo = 250,
		/datum/symptom/choking = 250,
		/datum/symptom/heal/longevity = 250,
		/datum/symptom/beard = 250,
		/datum/symptom/booze = 285,
		/datum/symptom/weight_loss = 285,
		/datum/symptom/weakness = 285,
		/datum/symptom/revitiligo = 285,
		/datum/symptom/visionloss = 285,
		/datum/symptom/dizzy = 285,
		/datum/symptom/shedding = 285,
		/datum/symptom/vomit/projectile = 300,
		/datum/symptom/vomit/blood = 300,
		/datum/symptom/deafness = 300,
		/datum/symptom/confusion = 300,

	)
	difficultly_flags = (QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)

/datum/cargo_quest/thing/virus/length_quest()
	return length(required_symptoms)

/datum/cargo_quest/thing/virus/add_goal(difficultly)
	var/list/difficult_list = generate_goal_list(difficultly)

	var/datum/symptom/generated_symptom = pick(difficult_list)
	q_storage.reward += difficult_list[generated_symptom]
	if(unique_things)
		difficult_list.Remove(generated_symptom)

	required_symptoms += generated_symptom
	required_symptoms[generated_symptom] = REQUIRED_BLOOD_AMOUNT
	current_list = required_symptoms.Copy()

	desc += "[capitalize(format_text(initial(generated_symptom.name)))], [REQUIRED_BLOOD_AMOUNT]u<br>"

/datum/cargo_quest/thing/virus/check_required_item(atom/movable/check_item)

	if(!length(current_list))
		return FALSE

	var/obj/item/reagent_containers/glass/beaker/vial/vial = check_item
	if(!vial.reagents)
		return FALSE

	for(var/datum/reagent/blood/blood in vial.reagents.reagent_list)
		if(length(blood.data["diseases"] != 1)) // Only 1 virus
			continue
		var/datum/disease/virus/advance/virus = locate() in blood.data["diseases"]
		if(!virus || length(virus.symptoms) != 1) // And only 1 symptom
			continue
		var/datum/symptom/symptom = locate() in virus.symptoms
		if(!symptom)
			continue
		for(var/symp in current_list)
			if(symptom.type != symp)
				continue
			if(required_symptoms[symp] <= blood.volume)
				current_list.Remove(symp)
				return TRUE

	return FALSE

/datum/cargo_quest/thing/virus/after_check()
	. = TRUE
	current_list = required_symptoms.Copy()

#undef REQUIRED_BLOOD_AMOUNT

/datum/cargo_quest/thing/capsule
	quest_type_name = "Mob in lazarus capsule"
	item_for_show = /obj/item/mobcapsule
	req_items = list(/obj/item/mobcapsule)

	var/list/required_mobs = list()
	var/list/capsules

	normal_items = list(
		/mob/living/simple_animal/hostile/asteroid/goliath/beast = 180,
		/mob/living/simple_animal/hostile/asteroid/goldgrub = 120,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher = 130,
		/mob/living/simple_animal/hostile/asteroid/marrowweaver = 210,
	)
	hard_items = list(
		/mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient = 450,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing = 330,
		/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing = 350,
		/mob/living/simple_animal/hostile/asteroid/marrowweaver/frost = 350
	)
	difficultly_flags = (QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)

/datum/cargo_quest/thing/capsule/length_quest()
	return length(required_mobs)

/datum/cargo_quest/thing/capsule/add_goal(difficultly)
	var/list/difficult_list = generate_goal_list(difficultly)
	var/mob/generated_mob = pick(difficult_list)
	q_storage.reward += difficult_list[generated_mob]
	if(unique_things)
		difficult_list.Remove(generated_mob)

	required_mobs += generated_mob
	current_list = required_mobs.Copy()

	desc += "[capitalize(format_text(initial(generated_mob.name)))]<br>"

/datum/cargo_quest/thing/capsule/check_required_item(atom/movable/check_item)

	if(!length(current_list))
		return FALSE

	var/obj/item/mobcapsule/capsule = check_item
	if(!capsule.captured)
		return FALSE
	var/mob/living/simple_animal/captured_mob = capsule.captured

	for(var/mobtype in current_list)
		if(istype(captured_mob, mobtype))
			current_list.Remove(mobtype)
			LAZYADD(capsules, capsule)
			return TRUE
	return FALSE


/datum/cargo_quest/thing/capsule/after_check()
	. = TRUE
	current_list = required_mobs.Copy()

/datum/cargo_quest/thing/capsule/completed_quest()
	if(length(capsules))
		QDEL_LIST(capsules)
