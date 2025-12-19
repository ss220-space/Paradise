
/datum/cargo_quest/thing
	quest_type_name = "шаблонный предмет"
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
	var/obj/item_path = pick(difficult_list)
	var/atom/AM = new item_path(locate(1, 1, 1))
	var/object_name = AM.declent_ru(NOMINATIVE)
	qdel(AM)

	q_storage.reward += difficult_list[item_path]
	if(unique_things)
		difficult_list.Remove(item_path)

	req_items += item_path
	current_list = req_items.Copy()

	desc += "[capitalize(object_name)]<br>"

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
	quest_type_name = "Экстракты слаймов"
	bounty_jobs = list(
		JOB_TITLE_CMO,
		JOB_TITLE_DOCTOR,
		JOB_TITLE_MINING_MEDIC,
		JOB_TITLE_GENETICIST,
		JOB_TITLE_PSYCHIATRIST,
		JOB_TITLE_CHEMIST,
		JOB_TITLE_VIROLOGIST,
		JOB_TITLE_PARAMEDIC,
		JOB_TITLE_CORONER,
		JOB_TITLE_INTERN,
	)
	linked_departament = "Science"

	easy_items = list(
		/obj/item/slime_extract/grey = 30,
		/obj/item/slime_extract/orange = 90,
		/obj/item/slime_extract/purple = 90,
		/obj/item/slime_extract/blue = 90,
		/obj/item/slime_extract/metal = 90,
	)
	normal_items = list(
		/obj/item/slime_extract/yellow = 125,
		/obj/item/slime_extract/darkblue = 125,
		/obj/item/slime_extract/darkpurple = 125,
		/obj/item/slime_extract/silver = 125,
		/obj/item/slime_extract/bluespace = 180,
		/obj/item/slime_extract/sepia = 180,
		/obj/item/slime_extract/cerulean = 180,
		/obj/item/slime_extract/pyrite = 190,
	)
	hard_items = list(
		/obj/item/slime_extract/green = 225,
		/obj/item/slime_extract/red = 225,
		/obj/item/slime_extract/pink = 225,
		/obj/item/slime_extract/gold = 225,
	)
	very_hard_items = list(
		/obj/item/slime_extract/adamantine = 270,
		/obj/item/slime_extract/oil = 270,
		/obj/item/slime_extract/black = 270,
		/obj/item/slime_extract/lightpink = 300,
		/obj/item/slime_extract/rainbow = 500,
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD|QUEST_DIFFICULTY_VERY_HARD)

/datum/cargo_quest/thing/organs
	quest_type_name = "Органы"
	bounty_jobs = list(
		JOB_TITLE_CMO,
		JOB_TITLE_DOCTOR,
		JOB_TITLE_MINING_MEDIC,
		JOB_TITLE_GENETICIST,
		JOB_TITLE_PSYCHIATRIST,
		JOB_TITLE_CHEMIST,
		JOB_TITLE_VIROLOGIST,
		JOB_TITLE_PARAMEDIC,
		JOB_TITLE_CORONER,
		JOB_TITLE_INTERN,
	)
	linked_departament = "Medical"

	easy_items = list(
		/obj/item/organ/internal/kidneys = 20,
		/obj/item/organ/internal/eyes = 30,
		/obj/item/organ/internal/lungs = 50,
		/obj/item/organ/internal/liver = 50,
	)
	normal_items = list(
		/obj/item/organ/internal/kidneys/unathi = 150,
		/obj/item/organ/internal/kidneys/tajaran = 150,
		/obj/item/organ/internal/kidneys/skrell = 150,
		/obj/item/organ/internal/liver/vulpkanin = 150,
		/obj/item/organ/internal/liver/tajaran = 150,
		/obj/item/organ/internal/eyes/tajaran = 175,
		/obj/item/organ/internal/eyes/vulpkanin = 175,
		/obj/item/organ/internal/headpocket = 175,
		/obj/item/organ/internal/eyes/unathi = 175,
		/obj/item/organ/internal/eyes/nian = 175,
		/obj/item/organ/internal/liver/skrell = 175,
		/obj/item/organ/internal/lungs/skrell = 175,
		/obj/item/organ/internal/lungs/tajaran = 175,
		/obj/item/organ/internal/lungs/vulpkanin = 175,
	)
	hard_items = list(
		/obj/item/organ/internal/kidneys/grey = 350,
		/obj/item/organ/internal/liver/kidan = 350,
		/obj/item/organ/internal/lungs/slime = 350,
		/obj/item/organ/internal/liver/grey = 350,
		/obj/item/organ/internal/heart/slime = 350,
		/obj/item/organ/internal/lungs/unathi/ash_walker = 350,
		/obj/item/organ/internal/eyes/unathi/ash_walker = 350,

	)
	very_hard_items = list(
		/obj/item/organ/internal/lantern = 500,
		/obj/item/organ/internal/wryn/glands = 700,
		/obj/item/organ/internal/heart/plasmaman = 750,
		/obj/item/organ/internal/eyes/unathi/ash_walker_shaman = 500,
		/obj/item/organ/internal/xenos/plasmavessel/hunter = 550,
		/obj/item/organ/internal/xenos/plasmavessel/drone = 550,
		/obj/item/organ/internal/xenos/neurotoxin/sentinel = 650,
		/obj/item/organ/internal/xenos/hivenode = 700,
		/obj/item/organ/internal/xenos/acidgland/sentinel = 750,
		/obj/item/organ/internal/xenos/acidgland/praetorian = 750,
		/obj/item/organ/internal/xenos/resinspinner = 750,
		/obj/item/organ/internal/xenos/neurotoxin = 850,
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD|QUEST_DIFFICULTY_VERY_HARD)

/datum/cargo_quest/thing/foods
	quest_type_name = "Продукты питания"
	bounty_jobs = list(JOB_TITLE_CHEF)
	linked_departament = "Support"

	easy_items = list(
		/obj/item/reagent_containers/food/snacks/friedegg = 10,
		/obj/item/reagent_containers/food/snacks/tofuburger = 20,
		/obj/item/reagent_containers/food/snacks/omelette = 20,
		/obj/item/reagent_containers/food/snacks/tofukabob = 20,
		/obj/item/reagent_containers/food/snacks/icecreamsandwich = 20,
		/obj/item/reagent_containers/food/snacks/sliceable/bread = 20,
		/obj/item/reagent_containers/food/snacks/boiledpelmeni = 30,
		/obj/item/reagent_containers/food/snacks/cheeseburger = 30,
		/obj/item/reagent_containers/food/snacks/benedict = 40,
		/obj/item/reagent_containers/food/snacks/monkeyburger = 40,
		/obj/item/reagent_containers/food/snacks/hotdog = 40,
		/obj/item/reagent_containers/food/snacks/toastedsandwich = 40,
		/obj/item/reagent_containers/food/snacks/twobread = 40,
		/obj/item/reagent_containers/food/snacks/sausage = 40,
		/obj/item/reagent_containers/food/snacks/soup/tomatosoup = 40,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/margherita = 40,
		/obj/item/reagent_containers/food/snacks/pancake = 50,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/macpizza = 50,
		/obj/item/reagent_containers/food/snacks/pastatomato = 60,
		/obj/item/reagent_containers/food/snacks/meatballspaghetti = 30,
		/obj/item/reagent_containers/food/snacks/smokedsausage = 60,
		/obj/item/reagent_containers/food/snacks/lasagna = 80,
		/obj/item/reagent_containers/food/snacks/muffin = 60,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/meatpizza = 60,
		/obj/item/reagent_containers/food/snacks/sliceable/plaincake = 80,
		/obj/item/reagent_containers/food/snacks/sliceable/cheesecake = 100,
		/obj/item/reagent_containers/food/snacks/sliceable/bread/tofu = 100,
		/obj/item/reagent_containers/food/snacks/sliceable/bread/meat = 100,
	)
	normal_items = list(
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/hawaiianpizza = 120,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/mushroompizza = 120,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/vegetablepizza = 120,
		/obj/item/reagent_containers/food/snacks/yakiimo = 150,
		/obj/item/reagent_containers/food/snacks/soup/beetsoup = 150,
		/obj/item/reagent_containers/food/snacks/fishburger = 160,
		/obj/item/reagent_containers/food/snacks/monkeysdelight = 160,
		/obj/item/reagent_containers/food/snacks/candy/jellybean/purple = 200,
		/obj/item/reagent_containers/food/snacks/pancake/choc_chip_pancake = 160,
		/obj/item/reagent_containers/food/snacks/superbiteburger = 160,
		/obj/item/reagent_containers/food/snacks/sushi_TobikoEgg = 160,
		/obj/item/reagent_containers/food/snacks/sushi_Unagi = 160,
		/obj/item/reagent_containers/food/snacks/sliceable/salami = 160,
		/obj/item/reagent_containers/food/snacks/amanitajelly = 170,
		/obj/item/reagent_containers/food/snacks/candy/jawbreaker = 170,
		/obj/item/reagent_containers/food/snacks/plov = 170,
		/obj/item/reagent_containers/food/snacks/donut/chaos = 180,
		/obj/item/reagent_containers/food/snacks/sliceable/noel = 180,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly = 190,
		/obj/item/reagent_containers/food/snacks/aesirsalad = 190,
		/obj/item/reagent_containers/food/snacks/candy/sucker = 160,
		/obj/item/reagent_containers/food/snacks/appletart = 190,
		/obj/item/reagent_containers/food/snacks/chawanmushi = 190,
	)
	hard_items = list(
		/obj/item/reagent_containers/food/snacks/sashimi = 220,
		/obj/item/reagent_containers/food/snacks/sliceable/pizza/diablo = 200,
		/obj/item/reagent_containers/food/snacks/meatsteak/vulpkanin = 200,
		/obj/item/reagent_containers/food/snacks/meatsteak/human = 200,
		/obj/item/reagent_containers/food/snacks/meatsteak/slime = 200,
		/obj/item/reagent_containers/food/snacks/meatsteak/skrell = 200,
		/obj/item/reagent_containers/food/snacks/meatsteak/tajaran = 200,
		/obj/item/reagent_containers/food/snacks/meatsteak/unathi = 200,
		/obj/item/reagent_containers/food/snacks/meatsteak/vox = 220,
		/obj/item/reagent_containers/food/snacks/meatsteak/wryn = 220,
		/obj/item/reagent_containers/food/snacks/meatsteak/kidan = 220,
		/obj/item/reagent_containers/food/snacks/meatsteak/diona = 220,
		/obj/item/reagent_containers/food/snacks/meatsteak/nian = 220,
		/obj/item/reagent_containers/food/snacks/meatsteak/drask = 220,
		/obj/item/reagent_containers/food/snacks/meatsteak/grey = 220,
		/obj/item/reagent_containers/food/snacks/vulpix/chilli = 220,
		/obj/item/reagent_containers/food/snacks/soup/stew = 230,
		/obj/item/reagent_containers/food/snacks/vulpix/cheese = 230,
		/obj/item/reagent_containers/food/snacks/vulpix = 230,
		/obj/item/reagent_containers/food/snacks/weirdoliviersalad = 230,
		/obj/item/reagent_containers/food/snacks/doner_mushroom = 230,
		/obj/item/reagent_containers/food/snacks/doner_vegan = 230,
		/obj/item/reagent_containers/food/snacks/tajaroni = 220,
		/obj/item/reagent_containers/food/snacks/boiledslimecore = 220,
		/obj/item/reagent_containers/food/snacks/sliceable/lizard = 220,
		/obj/item/reagent_containers/food/snacks/shawarma = 250,
		/obj/item/reagent_containers/food/snacks/dionaroast = 250,
		/obj/item/reagent_containers/food/snacks/fruitcup = 280,
		/obj/item/reagent_containers/food/snacks/candy/cotton/bad_rainbow = 300,
		/obj/item/reagent_containers/food/snacks/candy/cotton/rainbow = 350,
		/obj/item/reagent_containers/food/snacks/fried_vox = 320,
		/obj/item/reagent_containers/food/snacks/sliceable/bread/xeno = 300,
		/obj/item/reagent_containers/food/snacks/rofflewaffles = 350,
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)


/datum/cargo_quest/thing/miner
	quest_type_name = "Добыча с Лазиса"
	bounty_jobs = list(JOB_TITLE_MINER)

	easy_items = list(
		/obj/item/gem/topaz = 80,
		/obj/item/gem/emerald = 80,
		/obj/item/gem/sapphire = 80,
		/obj/item/gem/ruby = 80,
	)
	normal_items = list(
		/obj/item/gem/rupee = 130,
		/obj/item/gem/fdiamond = 220,
		/obj/item/gem/magma = 260,
	)
	hard_items = list(
		/obj/item/gem/phoron = 350,
		/obj/item/gem/purple = 400,
		/obj/item/gem/amber = 400,
	)

	very_hard_items = list(
		/obj/item/gem/data = 450,
		/obj/item/gem/void = 500,
		/obj/item/gem/bloodstone = 650,
		/obj/effect/mob_spawn/human/ash_walker = 1000,
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD|QUEST_DIFFICULTY_VERY_HARD)


/datum/cargo_quest/thing/minerals
	quest_type_name = "Минералы"
	bounty_jobs = list(JOB_TITLE_MINER)

	var/list/required_minerals = list()
	unique_things = FALSE
	var/static/list/unique_minerals = list(/obj/item/stack/sheet/bluespace_crystal, /obj/item/stack/sheet/mineral/bananium, /obj/item/stack/sheet/mineral/tranquillite)
	req_items = list(/obj/item/stack/sheet)
	easy_items = list(
		/obj/item/stack/sheet/glass = list("reward" = 15, "amount" = 50),
		/obj/item/stack/sheet/wood = list("reward" = 15, "amount" = 50),
		/obj/item/stack/sheet/metal = list("reward" = 20, "amount" = 50),
		/obj/item/stack/sheet/cardboard = list("reward" = 20, "amount" = 20),
		/obj/item/stack/sheet/mineral/silver = list("reward" = 30, "amount" = 5),
		/obj/item/stack/sheet/mineral/titanium = list("reward" = 30, "amount" = 5),
		/obj/item/stack/sheet/mineral/plasma = list("reward" = 40, "amount" = 15),
		/obj/item/stack/sheet/mineral/uranium = list("reward" = 45, "amount" = 5),
		/obj/item/stack/sheet/mineral/gold = list("reward" = 50, "amount" = 5),
	)
	normal_items = list(
		/obj/item/stack/sheet/plastic = list("reward" = 100, "amount" = 50),
		/obj/item/stack/sheet/mineral/diamond = list("reward" = 100, "amount" = 5),
		/obj/item/stack/sheet/leather = list("reward" = 60, "amount" = 10),
		/obj/item/stack/sheet/mineral/gold = list("reward" = 70, "amount" = 15),
		/obj/item/stack/sheet/mineral/titanium = list("reward" = 60, "amount" = 15),
		/obj/item/stack/sheet/mineral/uranium = list("reward" = 65, "amount" = 15),
		/obj/item/stack/sheet/plasteel = list("reward" = 90, "amount" = 30),
		/obj/item/stack/sheet/mineral/plasma = list("reward" = 120, "amount" = 30),
		/obj/item/stack/sheet/mineral/silver = list("reward" = 90, "amount" = 15),
		/obj/item/stack/sheet/plasteel = list("reward" = 90, "amount" = 15),
		/obj/item/stack/sheet/sinew = list("reward" = 100, "amount" = 5),
		/obj/item/stack/sheet/bone = list("reward" = 100, "amount" = 5),
	)
	hard_items = list(
		/obj/item/stack/sheet/plasmaglass = list("reward" = 200, "amount" = 50),
		/obj/item/stack/sheet/mineral/diamond = list("reward" = 200, "amount" = 10),
		/obj/item/stack/sheet/mineral/gold = list("reward" = 200, "amount" = 30),
		/obj/item/stack/sheet/mineral/titanium = list("reward" = 150, "amount" = 30),
		/obj/item/stack/sheet/mineral/uranium = list("reward" = 150, "amount" = 30),
		/obj/item/stack/sheet/mineral/silver = list("reward" = 150, "amount" = 30),
		/obj/item/stack/sheet/durathread = list("reward" = 150, "amount" = 10),
		/obj/item/stack/sheet/cartilage_plate = list("reward" = 190, "amount" = 5),
	)
	very_hard_items = list(
		/obj/item/stack/sheet/bluespace_crystal = list("reward" = 220, "amount" = 5),
		/obj/item/stack/sheet/mineral/bananium = list("reward" = 340, "amount" = 4),
		/obj/item/stack/sheet/mineral/tranquillite = list("reward" = 440, "amount" = 4),
		/obj/item/stack/sheet/mineral/adamantine = list("reward" = 600, "amount" = 5),
	)

	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD|QUEST_DIFFICULTY_VERY_HARD)

/datum/cargo_quest/thing/minerals/add_goal(difficultly)
	var/list/difficult_list = generate_goal_list(difficultly)
	var/obj/item/item_path = pick(difficult_list)
	cargo_quest_reward = difficult_list[item_path]["reward"]
	q_storage.reward += cargo_quest_reward
	if(!required_minerals[item_path])
		required_minerals += item_path
	required_minerals[item_path] += difficult_list[item_path]["amount"]
	desc = list()
	for(var/mineral in required_minerals)
		var/atom/AM = new mineral(locate(1, 1, 1))
		var/object_name = AM.declent_ru(NOMINATIVE)
		qdel(AM)

		desc += "[capitalize(object_name)]<br>Объём: [required_minerals[mineral]]<br>"
	if(item_path in unique_minerals)
		difficult_list.Remove(item_path)
	current_list = required_minerals.Copy()
	if(unique_things)
		difficult_list.Remove(item_path)

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
	quest_type_name = "Семена"
	bounty_jobs = list(JOB_TITLE_BOTANIST)
	linked_departament = "Support"

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
		/obj/item/seeds/gatfruit = 760,
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_VERY_HARD)

/datum/cargo_quest/thing/botanygenes
	quest_type_name = "Дискеты с генами растений"
	item_for_show = /obj/item/disk/plantgene
	req_items = list(/obj/item/disk/plantgene)
	bounty_jobs = list(JOB_TITLE_BOTANIST)
	linked_departament = "Support"

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
	quest_type_name = "Дискеты с генами гуманоидов"
	item_for_show = /obj/item/dnainjector
	req_items = list(/obj/item/dnainjector)
	bounty_jobs = list(JOB_TITLE_GENETICIST)
	linked_departament = "Medical"

	var/list/required_blocks = list()
	normal_items = list(
		"LISP" = 200,
		"MUTE" = 200,
		"RAD" = 200,
		"OBESITY" = 200,
		"SWEDE" = 200,
		"SCRAMBLE" = 200,
		"WEAK" = 200,
		"HORNS" = 200,
		"COMIC" = 200,
		"PARAPLEGIA" = 200,
	)

	hard_items = list(
		"SOBER" = 250,
		"PSYRESIST" = 250,
		"SHADOW" = 250,
		"CHAMELEON" = 250,
		"CRYO" = 250,
		"EAT" = 250,
		"JUMP" = 250,
		"IMMOLATE" = 250,
		"EMPATH" = 250,
		"STRONG" = 250,
		"BLINDNESS" = 250,
		"POLYMORPH" = 250,
		"COLOURBLIND" = 250,
		"DEAF" = 250,
		"CLUMSY" = 250,
		"COUGH" = 250,
		"GLASSES" = 250,
		"EPILEPSY" = 250,
		"WINGDINGS" = 250,
		"BREATHLESS" = 250,
		"COLD" = 250,
		"HALLUCINATION" = 250,
		"FARVISION" = 250,
	)
	very_hard_items = list(
		"NOPRINTS" = 300,
		"SHOCKIMMUNITY" = 300,
		"SMALLSIZE" = 300,
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
	quest_type_name = "Вирусные симптомы в пробирках (минимум 10 ед.)"
	item_for_show = /obj/item/reagent_containers/glass/beaker/vial
	req_items = list(/obj/item/reagent_containers/glass/beaker/vial)
	bounty_jobs = list(JOB_TITLE_VIROLOGIST)
	linked_departament = "Medical"

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

	desc += "[capitalize(format_text(initial(generated_symptom.name)))], [REQUIRED_BLOOD_AMOUNT] ед.<br>"

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
	quest_type_name = "Существо в капсуле Лазаря"
	item_for_show = /obj/item/mobcapsule
	req_items = list(/obj/item/mobcapsule)

	var/list/required_mobs = list()
	var/list/capsules
	bounty_jobs = list(JOB_TITLE_MINER)

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
		/mob/living/simple_animal/hostile/asteroid/marrowweaver/frost = 350,
	)
	difficultly_flags = (QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)

/datum/cargo_quest/thing/capsule/length_quest()
	return length(required_mobs)

/datum/cargo_quest/thing/capsule/add_goal(difficultly)
	var/list/difficult_list = generate_goal_list(difficultly)
	var/mob/item_path = pick(difficult_list)
	var/atom/AM = new item_path(locate(1, 1, 1))
	var/object_name = AM.declent_ru(NOMINATIVE)
	qdel(AM)

	cargo_quest_reward = difficult_list[item_path]
	q_storage.reward += cargo_quest_reward
	if(unique_things)
		difficult_list.Remove(item_path)

	required_mobs += item_path
	current_list = required_mobs.Copy()

	desc += "[capitalize(object_name)]<br>"

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
