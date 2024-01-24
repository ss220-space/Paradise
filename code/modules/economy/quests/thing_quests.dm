/datum/cargo_quest/thing
	quest_type_name = "generic thing"
	var/list/easy_items
	var/list/normal_items
	var/list/hard_items
	var/list/very_hard_items
	/// If TRUE, the same items from this category will not be found in the same order
	var/unique_things = FALSE

/datum/cargo_quest/thing/generate_goal(difficultly, request_obj, target_reward)
	if(request_obj)
		req_items += request_obj
		q_storage.reward += target_reward
		return

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

	var/obj/generated_item = pick(difficult_list)
	q_storage.reward += difficult_list[generated_item]
	if(unique_things)
		difficult_list.Remove(generated_item)
	req_items += generated_item

	desc += "[capitalize(format_text(initial(generated_item.name)))] <br>"


/datum/cargo_quest/thing/update_interface_icon()
	var/list/new_interface_icons = list()
	var/list/new_interface_icon_states = list()

	for(var/our_item in req_items)
		var/obj/obj = our_item
		if(initial(obj.icon) && initial(obj.icon_state))
			new_interface_icons += initial(obj.icon)
			new_interface_icon_states += initial(obj.icon_state)
		else
			new_interface_icons += 'icons/obj/storage.dmi'
			new_interface_icon_states += "box"

	interface_icons = new_interface_icons
	interface_icon_states = new_interface_icon_states

/datum/cargo_quest/thing/length_quest()
	return length(req_items)

/datum/cargo_quest/thing/check_required_item(atom/movable/check_item)
	if(check_item.type in req_items)
		req_items.Remove(check_item.type)
		return TRUE
	return FALSE

/datum/cargo_quest/thing/xenobio
	quest_type_name = "Xenobiological extract"
	easy_items = list(
		/obj/item/slime_extract/grey = 25,
		/obj/item/slime_extract/orange = 60,
		/obj/item/slime_extract/purple = 60,
		/obj/item/slime_extract/blue = 60,
		/obj/item/slime_extract/metal = 60,
		/obj/item/slime_extract/yellow = 85,
		/obj/item/slime_extract/darkblue = 85,
		/obj/item/slime_extract/darkpurple = 85,
		/obj/item/slime_extract/silver = 85,
	)
	normal_items = list(
		/obj/item/slime_extract/bluespace = 115,
		/obj/item/slime_extract/sepia = 115,
		/obj/item/slime_extract/cerulean = 115,
		/obj/item/slime_extract/pyrite = 115,
		/obj/item/slime_extract/green = 145,
		/obj/item/slime_extract/red = 145,
		/obj/item/slime_extract/pink = 145,
		/obj/item/slime_extract/gold = 145
	)
	hard_items = list(
		/obj/item/slime_extract/adamantine = 200,
		/obj/item/slime_extract/oil = 200,
		/obj/item/slime_extract/black = 200,
		/obj/item/slime_extract/lightpink = 200,
		/obj/item/slime_extract/rainbow = 270
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
		/obj/item/organ/internal/lungs/slime = 185,
		/obj/item/organ/internal/heart/slime = 210,
		/obj/item/organ/external/wing/nian = 210
	)
	hard_items = list(
		/obj/item/organ/internal/liver/diona = 300,
		/obj/item/organ/internal/lungs/unathi/ash_walker = 325,
		/obj/item/organ/internal/lantern = 400
	)
	very_hard_items = list(
		/obj/item/organ/internal/heart/cursed = 550,
		/obj/item/organ/internal/xenos/plasmavessel/hunter = 550,
		/obj/item/organ/internal/xenos/plasmavessel/drone = 550,
		/obj/item/organ/internal/xenos/neurotoxin = 650,
		/obj/item/organ/internal/wryn/glands = 700,
		/obj/item/organ/internal/xenos/hivenode = 700,
		/obj/item/organ/internal/heart/plasmaman = 750,
		/obj/item/organ/internal/xenos/acidgland/sentinel = 750,
		/obj/item/organ/internal/xenos/acidgland/praetorian = 750,
		/obj/item/organ/internal/xenos/resinspinner = 750,
		/obj/item/organ/internal/xenos/acidgland/queen = 900,
		/obj/item/organ/internal/xenos/plasmavessel/queen = 900
	)
	difficultly_flags = (QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD|QUEST_DIFFICULTY_VERY_HARD)

/datum/cargo_quest/thing/foods
	quest_type_name = "Food"
	easy_items = list(
		/obj/item/reagent_containers/food/snacks/boiledpelmeni = 20,
		/obj/item/reagent_containers/food/snacks/superbiteburger = 30,
		/obj/item/reagent_containers/food/snacks/yakiimo = 40,
		/obj/item/reagent_containers/food/snacks/sushi_TobikoEgg = 40,
		/obj/item/reagent_containers/food/snacks/sushi_Unagi = 40,
		/obj/item/reagent_containers/food/snacks/sliceable/salami = 40,
		/obj/item/reagent_containers/food/snacks/amanitajelly = 50,
		/obj/item/reagent_containers/food/snacks/donut/chaos = 50,
		/obj/item/reagent_containers/food/snacks/sliceable/noel = 50,
		/obj/item/reagent_containers/food/snacks/monstermeat/bearmeat = 50,
		/obj/item/reagent_containers/food/snacks/sashimi = 60,
		/obj/item/reagent_containers/food/snacks/fishburger = 60,
		/obj/item/reagent_containers/food/snacks/donut/jelly/slimejelly = 60,
		/obj/item/reagent_containers/food/snacks/candy/sucker = 60,
		/obj/item/reagent_containers/food/snacks/appletart = 60,
		/obj/item/reagent_containers/food/snacks/vulpix/chilli = 60,
		/obj/item/reagent_containers/food/snacks/vulpix/cheese = 60,
		/obj/item/reagent_containers/food/snacks/vulpix = 60,
		/obj/item/reagent_containers/food/snacks/candy/jawbreaker = 70,
		/obj/item/reagent_containers/food/snacks/doner_mushroom = 70,
		/obj/item/reagent_containers/food/snacks/tajaroni = 70,
		/obj/item/reagent_containers/food/snacks/boiledslimecore = 70,
		/obj/item/reagent_containers/food/snacks/sliceable/lizard = 70,
		/obj/item/reagent_containers/food/snacks/dionaroast = 80,
		/obj/item/reagent_containers/food/snacks/chawanmushi = 90,
		/obj/item/reagent_containers/food/snacks/candy/cotton/bad_rainbow = 100,
		/obj/item/reagent_containers/food/snacks/candy/cotton/rainbow = 100,
		/obj/item/reagent_containers/food/snacks/fried_vox = 100
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY)

/datum/cargo_quest/thing/miner
	quest_type_name = "Shaft Miner Loot"
	unique_things = TRUE
	easy_items = list(
		/obj/item/crusher_trophy/legion_skull = 50,
		/obj/item/crusher_trophy/watcher_wing = 50,
		/obj/item/gem/topaz = 60,
		/obj/item/gem/emerald = 60,
		/obj/item/gem/sapphire = 60,
		/obj/item/gem/ruby = 60,
		/obj/item/gem/fdiamond = 60,
		/obj/item/crusher_trophy/goliath_tentacle = 80,
		/obj/item/crusher_trophy/blaster_tubes/magma_wing = 100,
		/obj/item/crusher_trophy/watcher_wing/ice_wing = 100,
	)
	normal_items = list(
		/obj/item/gem/rupee = 130,
		/obj/item/borg/upgrade/modkit/lifesteal = 145,
		/obj/item/voodoo = 180,
		/obj/item/gem/magma = 220
	)
	hard_items = list(
		/obj/item/crusher_trophy/blaster_tubes = 260,
		/obj/item/grenade/clusterbuster/inferno = 270,
		/obj/item/gem/phoron = 350,
		/obj/item/gem/purple = 400,
		/obj/item/gem/amber = 400,
	)

	very_hard_items = list(
		/obj/item/gem/data = 450,
		/obj/item/gem/void = 500,
		/obj/effect/mob_spawn/human/ash_walker = 550,
		/obj/item/gem/bloodstone = 650,
		/obj/item/crusher_trophy/vortex_talisman = 700,
		/obj/item/crusher_trophy/tail_spike = 750,
		/obj/item/crusher_trophy/adaptive_intelligence_core = 850,
		/obj/item/crusher_trophy/demon_claws = 1000,
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD|QUEST_DIFFICULTY_VERY_HARD)

/datum/cargo_quest/thing/minerals
	quest_type_name = "Minerals"
	var/list/required_minerals = list()
	var/static/list/unique_minerals = list(/obj/item/stack/sheet/bluespace_crystal, /obj/item/stack/sheet/mineral/bananium, /obj/item/stack/sheet/mineral/tranquillite)
	req_items = list(/obj/item/stack/sheet)
	easy_items = list(
		/obj/item/stack/sheet/metal = list("reward" = 40, "amount" = 50),
		/obj/item/stack/sheet/mineral/gold = list("reward" = 90, "amount" = 20),
		/obj/item/stack/sheet/mineral/titanium = list("reward" = 70, "amount" = 30),
		/obj/item/stack/sheet/mineral/uranium = list("reward" = 80, "amount" = 15),
		/obj/item/stack/sheet/glass = list("reward" = 25, "amount" = 50),
	)
	normal_items = list(
		/obj/item/stack/sheet/mineral/diamond = list("reward" = 130, "amount" = 10),
		/obj/item/stack/sheet/plasteel/lowplasma = list("reward" = 120, "amount" = 30),
		/obj/item/stack/sheet/mineral/plasma = list("reward" = 150, "amount" = 40),
		/obj/item/stack/sheet/mineral/silver = list("reward" = 100, "amount" = 25)
	)
	hard_items = list(
		/obj/item/stack/sheet/bluespace_crystal = list("reward" = 250, "amount" = 7),
		/obj/item/stack/sheet/mineral/bananium = list("reward" = 370, "amount" = 4),
		/obj/item/stack/sheet/mineral/tranquillite = list("reward" = 480, "amount" = 4),
		/obj/item/stack/sheet/mineral/adamantine = list("reward" = 310, "amount" = 20)
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)


/datum/cargo_quest/thing/minerals/generate_goal(difficultly, request_obj, target_reward)
	var/list/difficult_list
	switch(difficultly)
		if(QUEST_DIFFICULTY_EASY)
			difficult_list = easy_items

		if(QUEST_DIFFICULTY_NORMAL)
			difficult_list = normal_items

		if(QUEST_DIFFICULTY_HARD)
			difficult_list = hard_items

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

/datum/cargo_quest/thing/minerals/check_required_item(atom/movable/check_item)
	if(!length(required_minerals))
		return FALSE

	var/obj/item/stack/sheet/sheet = check_item
	var/used_mineral
	for(var/mineral in required_minerals)
		if(istype(sheet, mineral))
			var/used = min(sheet.get_amount(), required_minerals[mineral])
			sheet.use(used)
			used_mineral = TRUE
			required_minerals[mineral] -= used
			if(required_minerals[mineral] == 0)
				required_minerals.Remove(mineral)
			if(QDELETED(sheet))
				return TRUE

	if(used_mineral)
		return TRUE

/datum/cargo_quest/thing/minerals/update_interface_icon()
	var/list/new_interface_icons = list()
	var/list/new_interface_icon_states = list()

	for(var/mineral in required_minerals)
		var/obj/obj = mineral
		new_interface_icons += initial(obj.icon)
		new_interface_icon_states += initial(obj.icon_state)

	interface_icons = new_interface_icons
	interface_icon_states = new_interface_icon_states

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
		/obj/item/seeds/wheat/meat = 10,
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
		/obj/item/seeds/lavaland/cactus = 30,
		/obj/item/seeds/lavaland/ember = 30,
		/obj/item/seeds/lavaland/inocybe = 30,
		/obj/item/seeds/lavaland/polypore = 30,
		/obj/item/seeds/lavaland/porcini = 30,
		/obj/item/seeds/tea/astra = 40,
		/obj/item/seeds/soya/olive/charc = 40,
		/obj/item/seeds/poppy/geranium = 40,
		/obj/item/seeds/poppy/lily = 40,
		/obj/item/seeds/coffee/robusta = 40,
		/obj/item/seeds/apple/gold = 50,
		/obj/item/seeds/soya/koi = 50,
		/obj/item/seeds/redbeet = 50,
		/obj/item/seeds/sunflower/moonflower = 50,
		/obj/item/seeds/chili/ice = 50,
		/obj/item/seeds/tomato/killer = 50,
		/obj/item/seeds/cocoapod/vanillapod = 50,
		/obj/item/seeds/plump/walkingmushroom = 50,
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
		/obj/item/seeds/angel = 90
	)

	hard_items = list(
		/obj/item/seeds/kudzu = 230,
		/obj/item/seeds/cherry/bomb = 370,
		/obj/item/seeds/apple/poisoned = 370,
		/obj/item/seeds/gatfruit = 430
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_HARD)

/datum/cargo_quest/thing/botanygenes
	quest_type_name = "Botany Genes on Disks"
	interface_icons = list('icons/obj/module.dmi')
	interface_icon_states = list("datadisk_hydro")
	req_items = list(/obj/item/disk/plantgene)
	var/list/required_genes = list()
	easy_items = list(
		/datum/plant_gene/trait/plant_type/fungal_metabolism = 75,
		/datum/plant_gene/trait/squash = 75,
		/datum/plant_gene/trait/repeated_harvest = 75,
		/datum/plant_gene/trait/maxchem = 75,
		/datum/plant_gene/trait/stinging = 100,
		/datum/plant_gene/trait/glow = 110,
	)
	normal_items = list(
		/datum/plant_gene/trait/battery = 125,
		/datum/plant_gene/trait/slip = 125,
		/datum/plant_gene/trait/cell_charge = 125,
		/datum/plant_gene/trait/teleport = 150,
		/datum/plant_gene/trait/plant_type/weed_hardy = 160,
		/datum/plant_gene/trait/noreact = 180,
		/datum/plant_gene/trait/glow/shadow = 180,
	)
	hard_items = list(
		/datum/plant_gene/trait/plant_laughter = 220,
		/datum/plant_gene/trait/fire_resistance = 220,
		/datum/plant_gene/trait/glow/berry = 240,
		/datum/plant_gene/trait/smoke = 330,
		/datum/plant_gene/trait/glow/red = 370,
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)

/datum/cargo_quest/thing/botanygenes/generate_goal(difficultly, request_obj, target_reward)

	var/datum/plant_gene/generated_gene
	switch(difficultly)
		if(QUEST_DIFFICULTY_EASY)
			generated_gene = pick(easy_items)
			q_storage.reward += easy_items[generated_gene]
		if(QUEST_DIFFICULTY_NORMAL)
			generated_gene = pick(normal_items)
			q_storage.reward += normal_items[generated_gene]
		if(QUEST_DIFFICULTY_HARD)
			generated_gene = pick(hard_items)
			q_storage.reward += hard_items[generated_gene]

	required_genes += generated_gene

	desc += "[capitalize(format_text(initial(generated_gene.name)))] <br>"

/datum/cargo_quest/thing/botanygenes/update_interface_icon()
	return

/datum/cargo_quest/thing/botanygenes/length_quest()
	return length(required_genes)

/datum/cargo_quest/thing/botanygenes/check_required_item(atom/movable/check_item)
	if(!length(required_genes))
		return FALSE

	var/obj/item/disk/plantgene/genedisk = check_item

	for(var/gene in required_genes)
		if(genedisk.gene?.type == gene)
			required_genes.Remove(gene)
			return TRUE

	return FALSE

/datum/cargo_quest/thing/genes
	quest_type_name = "DNA Genes"
	interface_icons = list('icons/obj/hypo.dmi')
	interface_icon_states = list("dnainjector")

	req_items = list(/obj/item/dnainjector)
	var/list/required_blocks = list()
	normal_items = list(
		"LISP" = 100,
		"MUTE" = 100,
		"RAD" = 100,
		"FAT" = 100,
		"SWEDE" = 100,
		"SCRAMBLE" = 100,
		"WEAK" = 100,
		"HORNS" = 100,
		"COMIC" = 100,
		"SOBER" = 150,
		"PSYRESIST" = 150,
		"SHADOW" = 150,
		"CHAMELEON" = 150,
		"CRYO" = 150,
		"EAT" = 150,
		"JUMP" = 150,
		"IMMOLATE" = 150,
		"EMPATH" = 150,
		"POLYMORPH" = 150,
		"STRONG" = 150,
	)

	hard_items = list(
		"BLINDNESS" = 200,
		"COLOURBLIND" = 200,
		"DEAF" = 200,
		"HULK" = 250,
		"TELE" = 250,
		"FIRE" = 300,
		"XRAY" = 300,
		"CLUMSY" = 200,
		"COUGH" = 200,
		"GLASSES" = 200,
		"EPILEPSY" = 200,
		"WINGDINGS" = 200,
		"BREATHLESS" = 250,
		"REMOTEVIEW" = 300,
		"REGENERATE" = 300,
		"INCREASERUN" = 300,
		"REMOTETALK" = 300,
		"MORPH" = 300,
		"COLD" = 200,
		"HALLUCINATION" = 200,
		"NOPRINTS" = 250,
		"SHOCKIMMUNITY" = 200,
		"SMALLSIZE" = 250
	)
	difficultly_flags = (QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)

/datum/cargo_quest/thing/genes/update_interface_icon()
	return

/datum/cargo_quest/thing/genes/length_quest()
	return length(required_blocks)

/datum/cargo_quest/thing/genes/generate_goal(difficultly, request_obj, target_reward)

	var/generated_gene = pick(hard_items)
	q_storage.reward += hard_items[generated_gene]

	for(var/block in GLOB.assigned_blocks)
		if(block == generated_gene)
			required_blocks += block
			break

	desc += "[generated_gene] <br>"

/datum/cargo_quest/thing/genes/check_required_item(atom/movable/check_item)

	if(!length(required_blocks))
		return FALSE

	var/obj/item/dnainjector/dnainjector = check_item
	if(!dnainjector.block)
		return FALSE

	for(var/block in required_blocks)
		if(block != GLOB.assigned_blocks[dnainjector.block])
			continue
		var/list/BOUNDS = GetDNABounds(dnainjector.block)
		if(dnainjector.buf.dna.SE[dnainjector.block] >= BOUNDS[DNA_ON_LOWERBOUND])
			required_blocks.Remove(block)
			return TRUE

	return FALSE


#define REQUIRED_BLOOD_AMOUNT 10
/datum/cargo_quest/thing/virus
	quest_type_name = "Viruses symptoms in vials (10u minimum)"
	interface_icons = list('icons/obj/chemical.dmi')
	interface_icon_states = list("vial")
	req_items = list(/obj/item/reagent_containers/glass/beaker/vial)

	var/list/required_symptoms = list()

	easy_items = list(
		/datum/symptom/shivering = 70,
		/datum/symptom/fever = 70,
		/datum/symptom/sneeze = 90,
		/datum/symptom/itching = 90,
		/datum/symptom/headache = 90,
		/datum/symptom/cough = 90,
		/datum/symptom/oxygen = 100,
		/datum/symptom/painkiller = 110,
		/datum/symptom/epinephrine = 110,
		/datum/symptom/mind_restoration = 110,
		/datum/symptom/heal = 110,
	)
	normal_items = list(
		/datum/symptom/youth = 130,
		/datum/symptom/blood = 150,
		/datum/symptom/voice_change = 150,
		/datum/symptom/damage_converter = 150,
		/datum/symptom/sensory_restoration = 150,
		/datum/symptom/hallucigen = 150,
		/datum/symptom/viralevolution = 175,
		/datum/symptom/viraladaptation = 175,
		/datum/symptom/flesh_eating = 175,
		/datum/symptom/heal/metabolism = 175,
		/datum/symptom/fire = 190,
		/datum/symptom/vomit = 200,
		/datum/symptom/vitiligo = 200,
		/datum/symptom/choking = 200,
		/datum/symptom/heal/longevity = 200,
		/datum/symptom/beard = 200
	)

	hard_items = list(
		/datum/symptom/booze = 225,
		/datum/symptom/weight_loss = 225,
		/datum/symptom/weakness = 225,
		/datum/symptom/revitiligo = 225,
		/datum/symptom/visionloss = 225,
		/datum/symptom/dizzy = 225,
		/datum/symptom/shedding = 225,
		/datum/symptom/vomit/projectile = 275,
		/datum/symptom/vomit/blood = 275,
		/datum/symptom/deafness = 275,
		/datum/symptom/confusion = 275
	)
	difficultly_flags = (QUEST_DIFFICULTY_EASY|QUEST_DIFFICULTY_NORMAL|QUEST_DIFFICULTY_HARD)

/datum/cargo_quest/thing/virus/update_interface_icon()
	return

/datum/cargo_quest/thing/virus/length_quest()
	return length(required_symptoms)

/datum/cargo_quest/thing/virus/generate_goal(difficultly, request_obj, target_reward)
	var/datum/symptom/generated_symptom

	switch(difficultly)
		if(QUEST_DIFFICULTY_EASY)
			generated_symptom = pick(easy_items)
			q_storage.reward += easy_items[generated_symptom]

		if(QUEST_DIFFICULTY_NORMAL)
			generated_symptom = pick(normal_items)
			q_storage.reward += normal_items[generated_symptom]

		if(QUEST_DIFFICULTY_HARD)
			generated_symptom = pick(hard_items)
			q_storage.reward += hard_items[generated_symptom]

	required_symptoms += generated_symptom
	required_symptoms[generated_symptom] = REQUIRED_BLOOD_AMOUNT

	desc += "[capitalize(format_text(initial(generated_symptom.name)))] <br>"

/datum/cargo_quest/thing/virus/check_required_item(atom/movable/check_item)

	if(!length(required_symptoms))
		return FALSE

	var/obj/item/reagent_containers/glass/beaker/vial/vial = check_item
	if(!vial.reagents)
		return FALSE

	var/has_symptom
	for(var/datum/reagent/blood/blood in vial.reagents.reagent_list)
		if(length(blood.data["diseases"] != 1)) // Only 1 virus
			continue
		var/datum/disease/virus/advance/virus = locate() in blood.data["diseases"]
		if(!virus || length(virus.symptoms) != 1) // And only 1 symptom
			continue
		var/datum/symptom/symptom = locate() in virus.symptoms
		if(!symptom)
			continue
		for(var/symp in required_symptoms)
			if(symptom.type != symp)
				continue
			required_symptoms[symp] -= blood.volume
			has_symptom = TRUE
			if(required_symptoms[symp] <= 0)
				required_symptoms.Remove(symp)


	if(has_symptom)
		return TRUE

	return FALSE
