/*
Система квестов или "Контрактов" для карго на тайпане.
Работает следующим образом. У карго есть хранилище квестов,
в нём есть три слота под квесты. Квесты могут быть:
	* ограничены временем
	* скрыты пока ты не выберешь сам квест(За выбор скрытого квеста идёт доп награда при выполнении)
	* уникальны (Пресеты заданые в коде)
В начале производится генерация квестов с выбором рандомного типа квеста для каждого из слотов.
Потом на основе выбранного типа, создаётся сам квест. После этого игроки должны выбрать активный квест.
Пока есть активный квест, другие квесты недоступны. Невыполнение квеста вовремя или отказ от квеста
приведёт к пенальти (снятие денег) зависящего от сложности квеста и замене активного квеста.
За выполнение квеста в награду даются кредиты и возможно другие безделушки.
*/

//GLOBAL_LIST_INIT(premade_syndie_quests, list(/datum/cargo_quest/grenade/death_kiss,,,,,,,,,))

//У сложностей такие значения потому, что она будет учитываться при подсчёте награды за квест
#define QUEST_DIFFICULTY_EASY 	5000
#define QUEST_DIFFICULTY_NORMAL 10000
#define QUEST_DIFFICULTY_HARD 	15000

/datum/cargo_quests_storage
	//Активный квест выбранный в консоли
	var/datum/cargo_quest/current_quest
	//Сгенерированные квесты. Одновременно может существовать только 3 Квеста
	var/datum/cargo_quest/quest_one
	var/datum/cargo_quest/quest_two
	var/datum/cargo_quest/quest_three
	//Возможные виды квестов для генерации
	var/list/possible_quest_types = list(
		"virus",
		"mecha",
		"grenade",
		"plants",
/*
		"weapons_and_implants",
		"genes",
		"bots",
		"minerals",
		"tech",
		"organs_and_bodyparts",
*/
	)
	//Список используемых в генерации симптомов для вирусов
	//Цифры для "Веса" симптомов, определялись по их level-у, но инвертировано. Ака 6 = 1, 5 = 2 и т.д.
	var/list/virus_simptoms = list(
	/datum/symptom/headache = 6,
	/datum/symptom/itching = 6,
	/datum/symptom/fever = 5,
	/datum/symptom/shivering = 5,
	/datum/symptom/booze = 4,
	/datum/symptom/choking = 4,
	/datum/symptom/heal/longevity = 4,
	/datum/symptom/heal/metabolism = 4,
	/datum/symptom/viralevolution = 4,
	/datum/symptom/viraladaptation = 4,
	/datum/symptom/vomit = 4,
	/datum/symptom/weakness = 4,
	/datum/symptom/weight_loss = 4,
	/datum/symptom/beard = 3,
	/datum/symptom/confusion = 3,
	/datum/symptom/damage_converter = 3,
	/datum/symptom/deafness = 3,
	/datum/symptom/dizzy = 3,
	/datum/symptom/sensory_restoration = 3,
	/datum/symptom/shedding = 3,
	/datum/symptom/vitiligo = 3,
	/datum/symptom/revitiligo = 3,
	/datum/symptom/sneeze = 3,
	/datum/symptom/blood = 2,
	/datum/symptom/epinephrine = 2,
	/datum/symptom/hallucigen = 2,
	/datum/symptom/painkiller = 2,
	/datum/symptom/mind_restoration = 2,
	/datum/symptom/visionloss = 2,
	/datum/symptom/youth = 2,
	/datum/symptom/flesh_eating = 1,
//	/datum/symptom/genetic_mutation = 1, //У нас вырублен, но я оставлю это тут на всякий
	/datum/symptom/heal = 1,
	/datum/symptom/oxygen = 1,
	/datum/symptom/voice_change = 1,
	)
	//Химикаты - Медицинские
	var/list/medical_chems = list(
	//Простые
	"charcoal" = 95,
	"cryoxadone" = 80,
	"mannitol" = 90,
	"salbutamol" = 95,
	"salglu_solution" = 95,
	"silver_sulfadiazine" = 90,
	"styptic_powder" = 90,
	"synthflesh" = 80,
	//Продвинутые
	"atropine" = 75,
	"calomel" = 75,
	"mutadone" = 75,
	"omnizine" = 60,
	"pen_acid" = 70,
	"perfluorodecalin" = 85,
	"sal_acid" = 80,
	//Уникальные
	"sterilizine" = 80,
	"antihol" = 75,
	"degreaser" = 60,
	"diphenhydramine" = 60,
	"ephedrine" = 70,
	"epinephrine" = 80,
	"ether" = 80,
	"haloperidol" = 70,
	"hydrocodone" = 70,
	"insulin" = 50,
	"liquid_solder" = 85,
	"mitocholide" = 60,
	"morphine" = 60,
	"earthsblood" = 60,
	"nanocalcium" = 40,
	"oculine" = 70,
	"potass_iodide" = 90,
	"rezadone" = 60,
	"spaceacillin" = 85,
	"stimulants" = 50,
	"strange_reagent" = 40,
	"teporone" = 70,
	"lavaland_extract" = 40,
	)
	//Химикаты - Наркотики
	var/list/drug_chems = list(
	"aranesp" = 80,
	"bath_salts" = 60,
	"crank" = 60,
	"jenkem" = 90,
	"krokodil" = 50,
	"lsd" = 70,
	"methamphetamine" = 80,
	"nicotine" = 70,
	"space_drugs" = 90,
	"surge" = 90,
	"thc" = 50,							//Tetrahydrocannabinol
	"ultralube" = 70,
	)
	//Химикаты - Пиротехнические
	var/list/pyrotech_chems = list(
	"blackpowder" = 50,
	"clf3" = 70,						//Chlorine Trifluoride
	"cryostylane" = 90,
	"firefighting_foam" = 90,
	"flash_powder" = 90,
	"liquid_dark_matter" = 90,
	"napalm" = 80,
	"phlogiston" = 70,
	"pyrosium" = 90,
	"sonic_powder" = 90,
	"sorium" = 90,
//	"stabilizing_agent" = 90,
	"teslium" = 50,
	)
	//Химикаты - Яды/Токсины
	var/list/toxin_chems = list(
	"????" = 90,
	"amanitin" = 70,
	"atrazine" = 90,
	"capulettium" = 80,
	"capulettium_plus" = 60,
	"carpotoxin" = 60,
	"jestosterone" = 50,
	"coniine" = 50,
//	"curare" = 90,						//Не достать без аплинка...
	"cyanide" = 70,
	"formaldehyde" = 90,
	"glyphosate" = 70,
	"heparin" = 50,
	"histamine" = 40,
	"initropidril" = 1,
	"itching_powder" = 70,
	"ketamine" = 60,
	"lipolicide" = 50,
	"neurotoxin" = 80,
	"pancuronium" = 80,
	"pestkiller" = 90,
//	"polonium" = 90,					//Не достать без аплинка...
	"rotatium" = 10,
	"sarin" = 60,
//	"sodium_thiopental" = 90,			//Не достать без аплинка...
	"sulfonal" = 70,
//	"venom" = 90,						//Не достать без аплинка...
	)
	//Химикаты - Разные
	var/list/misc_chems = list(
	"colorful_reagent" = 70,
	"drying_agent" = 90,				//Chlorine Trifluoride
	"fliptonium" = 40,
	"facid" = 70,						//FluoroSulfuric Acid
	"hairgrownium" = 60,
	"holywater" = 80,
	"jestosterone" = 60,
	"lye" = 90,
	"hair_dye" = 30,
	"sodiumchloride" = 80,
	"cleaner" = 80,
	"lube" = 90,
	"super_hairgrownium" = 40,
	"synthanol" = 80,
	"thermite" = 70,
	"mutagen" = 90,						//Unstable mutagen
	"stable_mutagen" = 70,
	)

	var/list/plants = list(
	/obj/item/reagent_containers/food/snacks/grown/shell/eggy = 90,
	/obj/item/reagent_containers/food/snacks/grown/shell/gatfruit = 1,
//	/obj/item/reagent_containers/food/snacks/grown/ambrosia = 100,
	/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris = 100,
	/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus = 60,
	/obj/item/reagent_containers/food/snacks/grown/ambrosia/gaia = 70,
//	/obj/item/reagent_containers/food/snacks/grown/ambrosia/cruciatus = 100, 	//Есть только в аплинке
	/obj/item/reagent_containers/food/snacks/grown/apple = 100,
	/obj/item/reagent_containers/food/snacks/grown/apple/poisoned = 1,
	/obj/item/reagent_containers/food/snacks/grown/apple/gold = 60,
	/obj/item/reagent_containers/food/snacks/grown/banana = 100,
	/obj/item/reagent_containers/food/snacks/grown/banana/mime = 85,
	/obj/item/reagent_containers/food/snacks/grown/banana/bluespace = 70,
	/obj/item/reagent_containers/food/snacks/grown/soybeans = 100,
	/obj/item/reagent_containers/food/snacks/grown/koibeans = 80,
	/obj/item/reagent_containers/food/snacks/grown/berries = 100,
	/obj/item/reagent_containers/food/snacks/grown/berries/poison = 90,
	/obj/item/reagent_containers/food/snacks/grown/berries/death = 70,
	/obj/item/reagent_containers/food/snacks/grown/berries/glow = 80,
	/obj/item/reagent_containers/food/snacks/grown/cherries = 100,
	/obj/item/reagent_containers/food/snacks/grown/bluecherries = 90,
	/obj/item/reagent_containers/food/snacks/grown/grapes = 100,
	/obj/item/reagent_containers/food/snacks/grown/grapes/green = 100,
	/obj/item/reagent_containers/food/snacks/grown/cannabis = 100,
	/obj/item/reagent_containers/food/snacks/grown/cannabis/rainbow = 60,
	/obj/item/reagent_containers/food/snacks/grown/cannabis/death = 60,
	/obj/item/reagent_containers/food/snacks/grown/cannabis/white = 60,
	/obj/item/reagent_containers/food/snacks/grown/cannabis/ultimate = 31,
	/obj/item/reagent_containers/food/snacks/grown/wheat = 100,
	/obj/item/reagent_containers/food/snacks/grown/oat = 100,
	/obj/item/reagent_containers/food/snacks/grown/rice = 100,
	/obj/item/reagent_containers/food/snacks/grown/meatwheat = 90,
	/obj/item/reagent_containers/food/snacks/grown/chili = 100,
	/obj/item/reagent_containers/food/snacks/grown/icepepper = 80,
	/obj/item/reagent_containers/food/snacks/grown/ghost_chili = 80,
//	/obj/item/reagent_containers/food/snacks/grown/citrus = 100,
	/obj/item/reagent_containers/food/snacks/grown/citrus/lime = 100,
	/obj/item/reagent_containers/food/snacks/grown/citrus/orange = 100,
	/obj/item/reagent_containers/food/snacks/grown/citrus/lemon = 100,
	/obj/item/reagent_containers/food/snacks/grown/citrus/orange_3d = 90,
	/obj/item/reagent_containers/food/snacks/grown/firelemon = 90,
	/obj/item/reagent_containers/food/snacks/grown/cocoapod = 100,
	/obj/item/reagent_containers/food/snacks/grown/vanillapod = 90,
	/obj/item/reagent_containers/food/snacks/grown/bungofruit = 85,
	/obj/item/reagent_containers/food/snacks/grown/bungopit = 85,
	/obj/item/reagent_containers/food/snacks/grown/corn = 100,
	/obj/item/reagent_containers/food/snacks/grown/eggplant = 100,
	/obj/item/reagent_containers/food/snacks/grown/poppy = 100,
	/obj/item/reagent_containers/food/snacks/grown/poppy/lily = 100,
	/obj/item/reagent_containers/food/snacks/grown/poppy/geranium = 100,
	/obj/item/reagent_containers/food/snacks/grown/harebell = 100,
	/obj/item/reagent_containers/food/snacks/grown/moonflower = 85,
	/obj/item/reagent_containers/food/snacks/grown/garlic = 100,
	/obj/item/reagent_containers/food/snacks/grown/grass = 100,
//	/obj/item/reagent_containers/food/snacks/grown/grass/carpet = 1,
	/obj/item/reagent_containers/food/snacks/grown/comfrey = 100,
	/obj/item/reagent_containers/food/snacks/grown/aloe = 100,
	/obj/item/reagent_containers/food/snacks/grown/kudzupod = 70,
	/obj/item/reagent_containers/food/snacks/grown/watermelon = 100,
	/obj/item/reagent_containers/food/snacks/grown/holymelon = 80,
	/obj/item/reagent_containers/food/snacks/grown/cabbage = 100,
	/obj/item/reagent_containers/food/snacks/grown/sugarcane = 100,
	/obj/item/reagent_containers/food/snacks/grown/cherry_bomb = 1,
//	/obj/item/reagent_containers/food/snacks/grown/mushroom = 100,
	/obj/item/reagent_containers/food/snacks/grown/mushroom/reishi = 100,
	/obj/item/reagent_containers/food/snacks/grown/mushroom/amanita = 100,
	/obj/item/reagent_containers/food/snacks/grown/mushroom/angel = 70,
	/obj/item/reagent_containers/food/snacks/grown/mushroom/libertycap = 100,
	/obj/item/reagent_containers/food/snacks/grown/mushroom/plumphelmet = 100,
	/obj/item/reagent_containers/food/snacks/grown/mushroom/walkingmushroom = 70,
	/obj/item/reagent_containers/food/snacks/grown/mushroom/chanterelle = 100,
	/obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom = 80,
	/obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom/glowcap = 70,
	/obj/item/reagent_containers/food/snacks/grown/mushroom/glowshroom/shadowshroom = 70,
	/obj/item/reagent_containers/food/snacks/grown/mushroom/fungus = 100,
	/obj/item/reagent_containers/food/snacks/grown/nymph_pod = 100,
	/obj/item/reagent_containers/food/snacks/grown/onion = 100,
	/obj/item/reagent_containers/food/snacks/grown/onion/red = 90,
	/obj/item/reagent_containers/food/snacks/grown/peanuts = 100,
	/obj/item/reagent_containers/food/snacks/grown/pineapple = 100,
	/obj/item/reagent_containers/food/snacks/grown/potato = 100,
	/obj/item/reagent_containers/food/snacks/grown/potato/wedges = 100,
	/obj/item/reagent_containers/food/snacks/grown/potato/sweet = 90,
	/obj/item/reagent_containers/food/snacks/grown/pumpkin = 100,
	/obj/item/reagent_containers/food/snacks/grown/blumpkin = 80,
//	/obj/item/reagent_containers/food/snacks/grown/random = 1,
	/obj/item/reagent_containers/food/snacks/grown/carrot = 100,
	/obj/item/reagent_containers/food/snacks/grown/carrot/wedges = 100,
	/obj/item/reagent_containers/food/snacks/grown/parsnip = 100,
	/obj/item/reagent_containers/food/snacks/grown/whitebeet = 100,
	/obj/item/reagent_containers/food/snacks/grown/redbeet = 100,
	/obj/item/reagent_containers/food/snacks/grown/tea = 100,
	/obj/item/reagent_containers/food/snacks/grown/tea/astra = 80,
	/obj/item/reagent_containers/food/snacks/grown/coffee = 100,
	/obj/item/reagent_containers/food/snacks/grown/coffee/robusta = 80,
	/obj/item/reagent_containers/food/snacks/grown/tobacco = 100,
	/obj/item/reagent_containers/food/snacks/grown/tobacco/space = 80,
	/obj/item/reagent_containers/food/snacks/grown/tomato = 100,
	/obj/item/reagent_containers/food/snacks/grown/tomato/blood = 80,
	/obj/item/reagent_containers/food/snacks/grown/tomato/blue = 80,
	/obj/item/reagent_containers/food/snacks/grown/tomato/blue/bluespace = 50,
	/obj/item/reagent_containers/food/snacks/grown/tomato/killer = 70,
//	/obj/item/reagent_containers/food/snacks/grown/ash_flora = 1,
//	/obj/item/reagent_containers/food/snacks/grown/ash_flora/shavings = 1,
//	/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_leaf = 1,
//	/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_cap = 1,
//	/obj/item/reagent_containers/food/snacks/grown/ash_flora/mushroom_stem = 1,
//	/obj/item/reagent_containers/food/snacks/grown/ash_flora/cactus_fruit = 1,
//	/obj/item/seeds/sample/alienweed = 1,
	/obj/item/seeds/ambrosia = 100,
	/obj/item/seeds/ambrosia/deus = 60,
	/obj/item/seeds/ambrosia/gaia = 70,
//	/obj/item/seeds/ambrosia/cruciatus = 100,		//Есть только в аплинке
	/obj/item/seeds/apple = 100,
	/obj/item/seeds/apple/poisoned = 1,
	/obj/item/seeds/apple/gold = 60,
	/obj/item/seeds/banana = 100,
	/obj/item/seeds/banana/mime = 85,
	/obj/item/seeds/banana/bluespace = 70,
	/obj/item/seeds/soya = 100,
	/obj/item/seeds/soya/koi = 80,
	/obj/item/seeds/berry = 100,
	/obj/item/seeds/berry/poison = 90,
	/obj/item/seeds/berry/death = 70,
	/obj/item/seeds/berry/glow = 80,
	/obj/item/seeds/cherry = 100,
	/obj/item/seeds/cherry/blue = 90,
	/obj/item/seeds/cherry/bomb = 1,
	/obj/item/seeds/grape = 100,
	/obj/item/seeds/grape/green = 100,
	/obj/item/seeds/cannabis = 100,
	/obj/item/seeds/cannabis/rainbow = 60,
	/obj/item/seeds/cannabis/death = 60,
	/obj/item/seeds/cannabis/white = 60,
	/obj/item/seeds/cannabis/ultimate = 31,
	/obj/item/seeds/wheat = 100,
	/obj/item/seeds/wheat/oat = 100,
	/obj/item/seeds/wheat/rice = 100,
	/obj/item/seeds/wheat/meat = 100,
	/obj/item/seeds/chili = 100,
	/obj/item/seeds/chili/ice = 80,
	/obj/item/seeds/chili/ghost = 80,
	/obj/item/seeds/lime = 100,
	/obj/item/seeds/orange = 100,
	/obj/item/seeds/lemon = 100,
	/obj/item/seeds/firelemon = 90,
	/obj/item/seeds/orange_3d = 90,
	/obj/item/seeds/cocoapod = 100,
	/obj/item/seeds/cocoapod/vanillapod = 90,
	/obj/item/seeds/cocoapod/bungotree = 85,
	/obj/item/seeds/corn = 100,
	/obj/item/seeds/corn/snapcorn = 90,
	/obj/item/seeds/cotton = 100,
	/obj/item/seeds/cotton/durathread = 90,
	/obj/item/seeds/eggplant = 100,
	/obj/item/seeds/eggplant/eggy = 90,
	/obj/item/seeds/poppy = 100,
	/obj/item/seeds/poppy/lily = 100,
	/obj/item/seeds/poppy/geranium = 100,
	/obj/item/seeds/harebell = 100,
	/obj/item/seeds/sunflower = 100,
	/obj/item/seeds/sunflower/moonflower = 85,
	/obj/item/seeds/sunflower/novaflower = 80,
	/obj/item/seeds/garlic = 100,
	/obj/item/seeds/grass = 100,
//	/obj/item/seeds/grass/carpet = 1,
	/obj/item/seeds/comfrey = 100,
	/obj/item/seeds/aloe = 100,
	/obj/item/seeds/kudzu = 70,
	/obj/item/seeds/watermelon = 100,
	/obj/item/seeds/watermelon/holy = 80,
	/obj/item/seeds/starthistle = 100,
	/obj/item/seeds/cabbage = 100,
	/obj/item/seeds/sugarcane = 100,
	/obj/item/seeds/gatfruit = 1,
	/obj/item/seeds/reishi = 100,
	/obj/item/seeds/amanita = 100,
	/obj/item/seeds/angel = 100,
	/obj/item/seeds/liberty = 100,
	/obj/item/seeds/plump = 100,
	/obj/item/seeds/plump/walkingmushroom = 70,
	/obj/item/seeds/chanter = 100,
	/obj/item/seeds/glowshroom = 80,
	/obj/item/seeds/glowshroom/glowcap = 70,
	/obj/item/seeds/glowshroom/shadowshroom = 70,
	/obj/item/seeds/fungus = 100,
	/obj/item/seeds/nettle = 100,
	/obj/item/seeds/nettle/death = 80,
	/obj/item/seeds/nymph = 100,
	/obj/item/seeds/onion = 100,
	/obj/item/seeds/onion/red = 90,
	/obj/item/seeds/peanuts = 100,
	/obj/item/seeds/pineapple = 100,
	/obj/item/seeds/potato = 100,
	/obj/item/seeds/potato/sweet = 90,
	/obj/item/seeds/pumpkin = 100,
	/obj/item/seeds/pumpkin/blumpkin = 80,
//	/obj/item/seeds/random = 1,
//	/obj/item/seeds/random/labelled = 1,
//	/obj/item/seeds/replicapod = 1,
	/obj/item/seeds/carrot = 100,
	/obj/item/seeds/carrot/parsnip = 100,
	/obj/item/seeds/whitebeet = 100,
	/obj/item/seeds/redbeet = 100,
	/obj/item/seeds/tea = 100,
	/obj/item/seeds/tea/astra = 80,
	/obj/item/seeds/coffee = 100,
	/obj/item/seeds/coffee/robusta = 80,
	/obj/item/seeds/tobacco = 100,
	/obj/item/seeds/tobacco/space = 80,
	/obj/item/seeds/tomato = 100,
	/obj/item/seeds/tomato/blood = 80,
	/obj/item/seeds/tomato/blue = 80,
	/obj/item/seeds/tomato/blue/bluespace = 50,
	/obj/item/seeds/tomato/killer = 70,
	/obj/item/seeds/tower = 100,
	/obj/item/seeds/tower/steel = 80,
	/obj/item/seeds/bamboo = 100,
//	/obj/item/seeds/lavaland = 1,
//	/obj/item/seeds/lavaland/cactus = 1,
//	/obj/item/seeds/lavaland/polypore = 1,
//	/obj/item/seeds/lavaland/porcini = 1,
//	/obj/item/seeds/lavaland/inocybe = 1,
//	/obj/item/seeds/lavaland/ember = 1,
//	/obj/item/grown = 1,
	/obj/item/grown/bananapeel = 100,
//	/obj/item/grown/bananapeel/traitorpeel = 1,				// Из аплинка
//	/obj/item/grown/bananapeel/clownfish = 1,
	/obj/item/grown/bananapeel/mimanapeel = 85,
	/obj/item/grown/bananapeel/bluespace = 70,
//	/obj/item/grown/bananapeel/specialpeel = 1,
	/obj/item/grown/corncob = 100,
	/obj/item/grown/snapcorn = 90,
	/obj/item/grown/cotton = 100,
	/obj/item/grown/cotton/durathread = 90,
	/obj/item/grown/sunflower = 100,
	/obj/item/grown/novaflower = 80,
//	/obj/item/grown/nettle = 1,
	/obj/item/grown/nettle/basic = 100,
	/obj/item/grown/nettle/death = 80,
	/obj/item/grown/log = 100,
//	/obj/item/grown/log/tree = 1,
	/obj/item/grown/log/steel = 80,
	/obj/item/grown/log/bamboo = 100,
	)

	var/list/plants_traits = list(
//	/datum/plant_gene/trait/plant_type/alien_properties
//	/datum/plant_gene/trait/plant_type/fungal_metabolism
//	/datum/plant_gene/trait/plant_type/weed_hardy
	/datum/plant_gene/trait/fire_resistance = 1,
	/datum/plant_gene/trait/smoke = 2,
	/datum/plant_gene/trait/stinging = 1,
	/datum/plant_gene/trait/battery = 1,
	/datum/plant_gene/trait/repeated_harvest = 3,
	/datum/plant_gene/trait/maxchem = 2,
	/datum/plant_gene/trait/noreact = 2,
	/datum/plant_gene/trait/teleport = 1,
	/datum/plant_gene/trait/glow/berry = 3,
	/datum/plant_gene/trait/glow/red = 3,
	/datum/plant_gene/trait/glow/shadow = 2,
	/datum/plant_gene/trait/glow = 3,
	/datum/plant_gene/trait/cell_charge = 2,
	/datum/plant_gene/trait/slip = 1,
	/datum/plant_gene/trait/squash = 2,
	)

	var/list/weapons_and_implants = list(
	/obj/item/bodybag = 10,
	)
	//Список мехов для генерации
	var/list/mechs = list(
	/obj/mecha/makeshift = 50,
	/obj/mecha/combat/durand = 20,
	/obj/mecha/combat/gygax = 20,
	/obj/mecha/working/ripley/firefighter = 15,
	/obj/mecha/working/clarke = 15,
	/obj/mecha/medical/odysseus = 10,
	/obj/mecha/working/ripley = 10,
	/obj/mecha/combat/honker = 10,
	/obj/mecha/combat/reticence = 10,
	/obj/mecha/combat/durand/rover = 5,
	/obj/mecha/combat/gygax/dark = 5,
	)
	//Эквип подходящий каждому меху за парой исключений
	//Эта пара исключений должна оставаться вверху списка для правильной работы кода
	var/list/mechs_equipment_all = list(
	/obj/item/mecha_parts/mecha_equipment/drill = 100,					//Все кроме одиссея и локермеха
	/obj/item/mecha_parts/mecha_equipment/drill/diamonddrill = 91,		//Все кроме одиссея и локермеха
	/obj/item/mecha_parts/mecha_equipment/mining_scanner = 100,
	/obj/item/mecha_parts/mecha_equipment/generator = 100,
	/obj/item/mecha_parts/mecha_equipment/anticcw_armor_booster = 91,
	/obj/item/mecha_parts/mecha_equipment/wormhole_generator = 89,
	/obj/item/mecha_parts/mecha_equipment/gravcatapult = 89,
	/obj/item/mecha_parts/mecha_equipment/repair_droid = 89,
	/obj/item/mecha_parts/mecha_equipment/generator/nuclear = 88,
	/obj/item/mecha_parts/mecha_equipment/teleporter = 87,
	/obj/item/mecha_parts/mecha_equipment/antiproj_armor_booster = 87,
	/obj/item/mecha_parts/mecha_equipment/tesla_energy_relay = 87,
	/obj/item/mecha_parts/mecha_equipment/rcd = 79,
	)
	//Эквип подходящий только Хонк Меху
	var/list/mechs_equipment_honk = list(
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/banana_mortar = 100,
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/mousetrap_mortar = 100,
	/obj/item/mecha_parts/mecha_equipment/weapon/honker = 95,
	)
	//Эквип подходящий только Молчуну
	var/list/mechs_equipment_reticence = list(
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine/silenced = 100,
	/obj/item/mecha_parts/mecha_equipment/mimercd = 100,
	)
	//Эквип подходящий только кларку, рипли и огнеборцу
	var/list/mechs_equipment_working = list(
	/obj/item/mecha_parts/mecha_equipment/cable_layer = 100,
	/obj/item/mecha_parts/mecha_equipment/hydraulic_clamp = 100,
	/obj/item/mecha_parts/mecha_equipment/extinguisher = 100,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/plasma = 87,
	)
	//Эквип подходящий только одиссею с одним исключением
	var/list/mechs_equipment_medical = list(
	/obj/item/mecha_parts/mecha_equipment/medical/sleeper = 92,
	/obj/item/mecha_parts/mecha_equipment/medical/syringe_gun = 75,
	/obj/item/mecha_parts/mecha_equipment/medical/rescue_jaw = 74,								//Только одиссей и огнеборец
	)
	//Эквип подходящий только боевым мехам, Хонку, Молчуну и емагнутому рипли/огнеборцу
	//Нельзя Локермеху, Кларку, рипли, огнеборцу, одиссею
	var/list/mechs_equipment_weapons = list(
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/disabler = 97,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/taser = 97,
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/scattershot = 96,
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/lmg = 96,
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack/flashbang = 92,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser = 91,
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/carbine = 91,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/laser/heavy = 88,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/ion = 84,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/tesla = 84,
	/obj/item/mecha_parts/mecha_equipment/weapon/energy/immolator = 84,
	/obj/item/mecha_parts/mecha_equipment/weapon/ballistic/missile_rack = 84,
	)
	var/list/rare_misc_from_nt = list(
	/obj/item/bodybag = 10,
	)
	var/list/genes = list(
	/obj/item/bodybag = 10,
	)
	var/list/bot_types = list(
	/obj/item/bodybag = 10,
	)
	var/list/minerals = list(
	/obj/item/bodybag = 10,
	)

	// В этом списке не должно быть органов которые обычно не достать.
	// Всё должно быть более менее достижимо силами генетики, химии, ботаники и медицины
	// А так же ничего механического
	var/list/organs_and_bodyparts = list(
	//Внешние органы
	//Встречаются в квестах чаще внутренних

	//Обычные расы, в основном хуманы
	/obj/item/organ/external/arm = 100,
	/obj/item/organ/external/arm/right = 100,
	/obj/item/organ/external/chest = 100,
	/obj/item/organ/external/foot = 100,
	/obj/item/organ/external/foot/right = 100,
	/obj/item/organ/external/groin = 100,
	/obj/item/organ/external/hand = 100,
	/obj/item/organ/external/hand/right = 100,
	/obj/item/organ/external/head = 100,
	/obj/item/organ/external/leg = 100,
	/obj/item/organ/external/leg/right = 100,
	//Дионы
	/obj/item/organ/external/arm/diona = 70,
	/obj/item/organ/external/arm/right/diona = 70,
	/obj/item/organ/external/chest/diona = 70,
	/obj/item/organ/external/foot/diona = 70,
	/obj/item/organ/external/foot/right/diona = 70,
	/obj/item/organ/external/groin/diona = 70,
	/obj/item/organ/external/hand/diona = 70,
	/obj/item/organ/external/hand/right/diona = 70,
	/obj/item/organ/external/head/diona = 70,
	/obj/item/organ/external/leg/diona = 70,
	/obj/item/organ/external/leg/right/diona = 70,
	//Слаймы
	/obj/item/organ/external/arm/unbreakable = 50,
	/obj/item/organ/external/arm/right/unbreakable = 50,
	/obj/item/organ/external/chest/unbreakable = 50,
	/obj/item/organ/external/foot/unbreakable = 50,
	/obj/item/organ/external/foot/right/unbreakable = 50,
	/obj/item/organ/external/groin/unbreakable = 50,
	/obj/item/organ/external/hand/unbreakable = 50,
	/obj/item/organ/external/hand/right/unbreakable = 50,
	/obj/item/organ/external/head/unbreakable = 50,
	/obj/item/organ/external/leg/unbreakable = 50,
	/obj/item/organ/external/leg/right/unbreakable = 50,
	//Хвосты
	/obj/item/organ/external/tail/monkey = 60,
	/obj/item/organ/external/tail/monkey/tajaran = 60,
	/obj/item/organ/external/tail/monkey/unathi = 60,
	/obj/item/organ/external/tail/monkey/vulpkanin = 60,
	/obj/item/organ/external/tail/tajaran = 60,
	/obj/item/organ/external/tail/unathi = 60,
	/obj/item/organ/external/tail/vox = 60,
	/obj/item/organ/external/tail/vulpkanin = 60,
	// Внутренние органы
	// Квесты на них должны генериться реже

	// Обычные расы, в основном хуманы
	/obj/item/organ/internal/appendix = 50,
	/obj/item/organ/internal/brain = 50,
	/obj/item/organ/internal/ears = 50,
	/obj/item/organ/internal/eyes = 50,
	/obj/item/organ/internal/heart = 50,
	/obj/item/organ/internal/kidneys = 50,
	/obj/item/organ/internal/liver = 50,
	/obj/item/organ/internal/lungs = 50,
	//Дионы
	/obj/item/organ/internal/appendix/diona = 30,
	/obj/item/organ/internal/brain/diona = 30,
	/obj/item/organ/internal/eyes/diona = 30,
	/obj/item/organ/internal/kidneys/diona = 30,
	/obj/item/organ/internal/liver/diona = 30,
	/obj/item/organ/internal/lungs/diona = 30,
	//Таяры
	/obj/item/organ/internal/brain/tajaran = 40,
	/obj/item/organ/internal/eyes/tajaran = 40,
	/obj/item/organ/internal/heart/tajaran = 40,
	/obj/item/organ/internal/kidneys/tajaran = 40,
	/obj/item/organ/internal/liver/tajaran = 40,
	/obj/item/organ/internal/lungs/tajaran = 40,
	//Фарва
	/obj/item/organ/internal/eyes/tajaran/farwa = 50,
	//Унатхи
	/obj/item/organ/internal/brain/unathi = 35,
	/obj/item/organ/internal/eyes/unathi = 35,
	/obj/item/organ/internal/heart/unathi = 35,
	/obj/item/organ/internal/liver/unathi = 35,
	/obj/item/organ/internal/kidneys/unathi = 35,
	/obj/item/organ/internal/lungs/unathi = 35,
	//Слаймы
	/obj/item/organ/internal/brain/slime = 15,
	/obj/item/organ/internal/heart/slime = 15,
	/obj/item/organ/internal/lungs/slime= 15,
	//Вульпы
	/obj/item/organ/internal/brain/vulpkanin = 30,
	/obj/item/organ/internal/eyes/vulpkanin = 30,
	/obj/item/organ/internal/heart/vulpkanin = 30,
	/obj/item/organ/internal/kidneys/vulpkanin = 30,
	/obj/item/organ/internal/liver/vulpkanin = 30,
	/obj/item/organ/internal/lungs/vulpkanin = 30,
	//Вольпины
	/obj/item/organ/internal/eyes/vulpkanin/wolpin = 50,
	)

/datum/cargo_quests_storage/proc/QuestStorageInitialize() //Вызывать сразу после создания хранилища квестов
	for(var/i in 1 to 3)
		generate_quest()

////////////////////////////
//Основной прок генерирующий 1 квест с посланным в него типом.
////////////////////////////
/datum/cargo_quests_storage/proc/generate_quest(var/quest_type = null)
	if(!quest_type)
		quest_type = pick(possible_quest_types)

	var/datum/cargo_quest/quest
	if(!quest_one)
		quest_one = new /datum/cargo_quest
		quest = quest_one
	else if(!quest_two)
		quest_two = new /datum/cargo_quest
		quest = quest_two
	else if(!quest_three)
		quest_three = new /datum/cargo_quest
		quest = quest_three
	else
		return

	quest.generate_difficulty()
	switch(quest_type)
		if("virus")
			quest.quest_type = "virus"
			generate_virus_info(quest)
		if("mecha")
			quest.quest_type = "mecha"
			generate_mecha_info(quest)
		if("grenade")
			quest.quest_type = "grenade"
			generate_grenade_info(quest)
		if("plants")
			quest.quest_type = "plants"
			generate_plants_info(quest)

////////////////////////////
//Прок генерирующий квест на вирус и необходимые симптомы для него
////////////////////////////
/datum/cargo_quests_storage/proc/generate_virus_info(var/datum/cargo_quest/quest)
	if(!quest)
		log_debug("Quest generation attempted without a quest datum reference!")
		return
	if(!quest.quest_difficulty)
		quest.generate_difficulty()
	log_debug("Generating quest of type \"Virus\"")
	quest.req_item = /datum/disease/advance
	quest.current_list += (virus_simptoms)
	var/symptom_count
	switch(quest.quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			symptom_count = 4
			for(var/item in quest.current_list)
				if(quest.current_list[item] <= 2)	// Удаляем редкие симптомы
					quest.current_list -= item
		if(QUEST_DIFFICULTY_NORMAL)
			symptom_count = 5
			for(var/item in quest.current_list)
				if(quest.current_list[item] == 1)	// Удаляем самые редкие симптомы
					quest.current_list -= item
		if(QUEST_DIFFICULTY_HARD)
			symptom_count = 6
			for(var/item in quest.current_list)
				if(quest.current_list[item] >= 4)	// Удаляем самые частые симптомы
					quest.current_list -= item

	//вписать выбор нужной иконки
	for(var/i in 1 to symptom_count)
		var/current_simptom = pickweight(quest.current_list)
		log_debug("Chosen simptoms: [current_simptom]")
		quest.req_else += (current_simptom)
		quest.current_list -= current_simptom
	log_debug("Generation end")

////////////////////////////
//Прок генерирующий квест на Меха и необходимый эквип для него
////////////////////////////
/datum/cargo_quests_storage/proc/generate_mecha_info(var/datum/cargo_quest/quest)
	if(!quest)
		log_debug("Quest generation attempted without a quest datum reference!")
		return
	if(!quest.quest_difficulty)
		quest.generate_difficulty()
	var/list/mecha_list = list(mechs)
	switch(quest.quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			for(var/item in mecha_list)
				if(mecha_list[item] <= 15)	// Удаляем редких мехов
					mecha_list -= item
		if(QUEST_DIFFICULTY_NORMAL)
			for(var/item in mecha_list)
				if(mecha_list[item] <= 5)	// Удаляем самых редких мехов
					mecha_list -= item
		if(QUEST_DIFFICULTY_HARD)
			for(var/item in mecha_list)
				if(mecha_list[item] > 15)	// Удаляем самых частых мехов
					mecha_list -= item

	quest.req_item = pickweight(mechs)
	var/req_mech = quest.req_item
	var/list/mech_equipment_all_cut = list()
	mech_equipment_all_cut.Add(mechs_equipment_all)
	mech_equipment_all_cut.Cut(1,3)
	var/max_equip
	//вписать выбор нужной иконки
	log_debug("Generating quest of type \"Mecha\"")
	if(req_mech == /obj/mecha/combat/honker)
		quest.current_list += (mechs_equipment_all)
		quest.current_list += (mechs_equipment_honk)
		if(quest.quest_difficulty == QUEST_DIFFICULTY_HARD)
			quest.current_list += (mechs_equipment_weapons)
		max_equip = 3
		log_debug("Chosen mech: Honker")
	else if(req_mech == /obj/mecha/combat/reticence)
		quest.current_list += (mechs_equipment_all)
		quest.current_list += (mechs_equipment_reticence)
		if(quest.quest_difficulty == QUEST_DIFFICULTY_HARD)
			quest.current_list += (mechs_equipment_weapons)
		max_equip = 3
		log_debug("Chosen mech: Reticence")
	else if(req_mech == /obj/mecha/working/ripley || req_mech == /obj/mecha/working/ripley/firefighter)
		quest.current_list += (mechs_equipment_all)
		quest.current_list += (mechs_equipment_working)
		if(quest.quest_difficulty == QUEST_DIFFICULTY_HARD)
			quest.current_list += (mechs_equipment_weapons)
		max_equip = 6
		log_debug("Chosen mech: Ripley or Firefighter")
	else if(req_mech == /obj/mecha/working/clarke)
		quest.current_list += (mechs_equipment_all)
		quest.current_list += (mechs_equipment_working)
		max_equip = 4
		log_debug("Chosen mech: Clarke")
	else if(req_mech == /obj/mecha/medical/odysseus)
		quest.current_list += (mechs_equipment_medical)
		max_equip = 3
		log_debug("Chosen mech: Medical")
	else if(req_mech == /obj/mecha/makeshift)
		quest.current_list += (mech_equipment_all_cut)
		max_equip = 2
		log_debug("Chosen mech: Makeshift")
	else
		quest.current_list += (mechs_equipment_all)
		quest.current_list += (mechs_equipment_weapons)
		max_equip = 3
		log_debug("Chosen mech: Battle Mech")
	for(var/i in 1 to max_equip)
		var/current_equipment = pickweight(quest.current_list)
		quest.req_else += (current_equipment)
		quest.current_list -= (current_equipment)
	log_debug("Generation end")

////////////////////////////
//Прок генерирующий квест на гранаты и необходимые в гранатах химикаты
////////////////////////////
/datum/cargo_quests_storage/proc/generate_grenade_info(var/datum/cargo_quest/quest)
	if(!quest)
		log_debug("Quest generation attempted without a quest datum reference!")
		return
	if(!quest.quest_difficulty)
		quest.generate_difficulty()

	var/grenade_type = pick("explosive", "smoke", "foam")
	var/chem_type = pick("drugs","medical","toxin","misc")

	switch(quest.quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			grenade_type = pick("explosive", "smoke")
			chem_type = pick("drugs","medical","toxin")
		if(QUEST_DIFFICULTY_NORMAL)
			chem_type = pick("drugs","medical","toxin")
		if(QUEST_DIFFICULTY_HARD)
			grenade_type = pick("smoke", "foam")

	quest.req_item = /obj/item/grenade/chem_grenade
	log_debug("Generating quest of type \"Grenade\"")
	switch(grenade_type)
		if("explosive")
			log_debug("Chosen grenade type: Explosive")
			quest.req_item = /obj/item/grenade/chem_grenade/pyro
			//вписать выбор нужной иконки
			quest.current_list += (pyrotech_chems)
		if("smoke")
			log_debug("Chosen grenade type: Smoke")
			if(chem_type == "drugs")
				quest.current_list += (drug_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "medical")
				quest.current_list += (medical_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "toxin")
				quest.current_list += (toxin_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "misc")
				quest.current_list += (misc_chems)
				//вписать выбор нужной иконки
			quest.req_else = list("smoke_powder" = 30)
		if("foam")
			log_debug("Chosen grenade type: Foam")
			if(chem_type == "drugs")
				quest.current_list += (drug_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "medical")
				quest.current_list += (medical_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "toxin")
				quest.current_list += (toxin_chems)
				//вписать выбор нужной иконки
			else if(chem_type == "misc")
				quest.current_list += (misc_chems)
				//вписать выбор нужной иконки
			quest.req_else = list("fluorosurfactant" = 30)

	var/max_chems // от 3 до 10 химикатов
	switch(quest.quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			for(var/item in quest.current_list)
				if(quest.current_list[item] < 50)	// Удаляем редкие химикаты ("<" здесь и должно быть)
					quest.current_list -= item
			max_chems = pick(3, 4, 5, 6)
		if(QUEST_DIFFICULTY_NORMAL)
			for(var/item in quest.current_list)
				if(quest.current_list[item] <= 30)	// Удаляем самые редкие химикаты
					quest.current_list -= item
			max_chems = pick(5, 6, 7, 8)
		if(QUEST_DIFFICULTY_HARD)
			for(var/item in quest.current_list)
				if(quest.current_list[item] >= 70)	// Удаляем частые химикаты
					quest.current_list -= item
			max_chems = pick(7, 8, 9, 10)

	for(var/i in 1 to max_chems)
		var/current_chem = pickweight(quest.current_list)
		var/current_value = (pick(10, 20, 30, 40, 50))
		quest.req_else += list(trim(current_chem) = current_value) 	// trim() тут скорее для обхода логики листа по которой, вместо того текста,
		quest.current_list -= current_chem							// что хранит current_chem он просто писал "current_chem" Если знаете вариант лучше, сообщите. Спасибо.
	log_debug("Generation end")

////////////////////////////
//Прок генерирующий квест на растение и необходимые трейты для него
////////////////////////////
/datum/cargo_quests_storage/proc/generate_plants_info(var/datum/cargo_quest/quest)
	if(!quest)
		log_debug("Quest generation attempted without a quest datum reference!")
		return
	if(!quest.quest_difficulty)
		quest.generate_difficulty()
	log_debug("Generating quest of type \"Plants\"")
	var/traits_count = pick(2,3,4,5)
	quest.current_list += plants
	switch(quest.quest_difficulty)
		if(QUEST_DIFFICULTY_EASY)
			traits_count = pick(2,3)
			for(var/item in quest.current_list)
				if(quest.current_list[item] <= 85)	// Удаляем редкие растения
					quest.current_list -= item
		if(QUEST_DIFFICULTY_NORMAL)
			traits_count = pick(3,4)
			for(var/item in quest.current_list)
				if(quest.current_list[item] <= 60)	// Удаляем самые редкие растения
					quest.current_list -= item
		if(QUEST_DIFFICULTY_HARD)
			traits_count = pick(4,5)
			for(var/item in quest.current_list)
				if(quest.current_list[item] > 60)	// Удаляем частые растения
					quest.current_list -= item

	quest.req_item = pickweight(quest.current_list)
	//вписать выбор нужной иконки
	for(var/i in 1 to traits_count)
		var/current_trait = pickweight(plants_traits)// Трейтов у растений довольно мало, а вот самих растений много, не вижу смысла резать список
		log_debug("Chosen traits: [current_trait]")
		quest.req_else += (current_trait)
		quest.current_list -= current_trait
	log_debug("Generation end")
//TODO:
/datum/cargo_quests_storage/proc/populate_quest_window()

//TODO:
/datum/cargo_quests_storage/proc/check_quest_completion()

/datum/cargo_quest
	var/active = FALSE 								// Выбран ли квест игроками или нет?
	var/quest_type = "mecha"						// Тип Квеста. Список типов есть выше.
	var/quest_name = ""								// Название квеста
	var/quest_desc = ""								// Описание квеста
	var/quest_icon = null							// Иконка для этого квеста которая будет показана в интерфейсе
	var/quest_difficulty = QUEST_DIFFICULTY_EASY	// EASY, NORMAL, HARD.
	var/quest_reward = 0 							// Кредиты выдаваемые в награду за квест
	var/stealth = FALSE								// Скрыто ли содержимое нашего квеста до его активации?
	var/list/quest_reward_else = list() 			// Лист предметов выдающихся в дополнение, за выполнение квеста.
	var/quest_time_minutes = -1						// Время в МИНУТАХ за которое надо успеть сделать квест или автопровал. Если время < 0, значит ограничения по времени нет.
	var/list/current_list = list()					// Временный лист для дебага. Удалю когда квест система официально будет закончена и заменю все места где он применяется временными листами

	var/req_item = null								// Тип предмета который нам надо произвести
	var/list/req_else = list()						// Дополнительные штуки которые будут проверяться в зависимости от типа квеста
	var/req_quantity = 0							// Требуемое количество предметов

// Генерирует сложность квеста.
/datum/cargo_quest/proc/generate_difficulty()
	if(prob(50))
		quest_difficulty = QUEST_DIFFICULTY_EASY
		log_debug("Quest difficulty: Easy")
	else if(prob(50))
		quest_difficulty = QUEST_DIFFICULTY_NORMAL
		log_debug("Quest difficulty: Normal")
	else
		quest_difficulty = QUEST_DIFFICULTY_HARD
		log_debug("Quest difficulty: Hard")

//TODO:
/datum/cargo_quest/proc/generate_reward()


///////////////////////////////
// Уникальные заранее созданные квесты. Со своим описанием, требованиями и т.д.
///////////////////////////////

/datum/cargo_quest/grenade
	quest_type = "grenade"
	req_item = /obj/item/grenade/chem_grenade

/datum/cargo_quest/grenade/death_kiss
	quest_name = "Поцелуй смерти"
	quest_desc = "Порой на поле боя нужны радикальные меры... Клиент запросил пару смертельно опасных, дымовых гранат с инитропидрилом."
	quest_icon = null
	quest_difficulty = QUEST_DIFFICULTY_NORMAL
	quest_time_minutes = 10
	req_else = list("smoke_powder" = 30, "initropidril" = 50)
	req_quantity = 3
	quest_reward = 50000
	quest_reward_else = list(/obj/item/stack/sheet/mineral/diamond = 10)
