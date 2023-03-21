// Base chemicals
GLOBAL_LIST_INIT(base_chemicals, list("water","oxygen","nitrogen","hydrogen","potassium","mercury","carbon",
							"chlorine","fluorine","phosphorus","lithium","sulfur","sacid","radium",
							"iron","aluminum","silicon","sugar","ethanol"))
// Standard chemicals
GLOBAL_LIST_INIT(standard_chemicals, list("slimejelly","blood","water","lube","charcoal","toxin","cyanide",
								"morphine","syntmorphine","epinephrine","space_drugs","oxygen","copper",
								"nitrogen","hydrogen","potassium","mercury","sulfur","carbon","chlorine",
								"fluorine","sodium","phosphorus","lithium","sugar","sacid","facid",
								"glycerol","radium","mutadone","thermite","mutagen","virusfood","iron",
								"gold","silver","uranium","aluminum","silicon","fuel","cleaner","atrazine",
								"plasma","teporone","lexorin","silver_sulfadiazine","salbutamol",
								"perfluorodecalin","omnizine","synaptizine","haloperidol","potass_iodide",
								"pen_acid","mannitol","oculine","styptic_powder","methamphetamine",
								"cryoxadone","spaceacillin","carpotoxin","lsd","fluorosurfactant",
								"fluorosurfactant","ethanol","ammonia","diethylamine","antihol","pancuronium",
								"lipolicide","condensedcapsaicin","frostoil","amanitin","psilocybin",
								"enzyme","nothing","salglu_solution","antifreeze","neurotoxin", "jestosterone"))
// Rare chemicals
GLOBAL_LIST_INIT(rare_chemicals, list("minttoxin","syndicate_nanites", "xenomicrobes"))
// Standard medicines
GLOBAL_LIST_INIT(standard_medicines, list("charcoal","toxin","cyanide","morphine","syntmorphine","epinephrine","space_drugs",
								"mutadone","mutagen","teporone","lexorin","silver_sulfadiazine",
								"salbutamol","perfluorodecalin","omnizine","synaptizine","haloperidol",
								"potass_iodide","pen_acid","mannitol","oculine","styptic_powder",
								"methamphetamine","spaceacillin","carpotoxin","lsd","ethanol","ammonia",
								"diethylamine","antihol","pancuronium","lipolicide","condensedcapsaicin",
								"frostoil","amanitin","psilocybin","nothing","salglu_solution","neurotoxin"))
// Rare medicines
GLOBAL_LIST_INIT(rare_medicines, list("syndicate_nanites","minttoxin","blood", "xenomicrobes"))
// Drinks
GLOBAL_LIST_INIT(drinks, list("beer2","hot_coco","orangejuice","tomatojuice","limejuice","carrotjuice",
					"berryjuice","poisonberryjuice","watermelonjuice","lemonjuice","banana",
					"nothing","potato","milk","soymilk","cream","coffee","tea","icecoffee",
					"icetea","cola","nuka_cola","spacemountainwind","thirteenloko","dr_gibb",
					"space_up","lemon_lime","beer","whiskey","gin","rum","vodka","holywater",
					"tequila","vermouth","wine","tonic","kahlua","cognac","ale","sodawater",
					"ice","bilk","atomicbomb","threemileisland","goldschlager","patron","gintonic",
					"cubalibre","whiskeycola","martini","vodkamartini","whiterussian","screwdrivercocktail",
					"booger","bloodymary","gargleblaster","bravebull","tequilasunrise","toxinsspecial",
					"beepskysmash","salglu_solution","irishcream","manlydorf","longislandicedtea",
					"moonshine","b52","irishcoffee","margarita","blackrussian","manhattan",
					"manhattan_proj","whiskeysoda","antifreeze","barefoot","snowwhite","demonsblood",
					"vodkatonic","ginfizz","bahama_mama","singulo","sbiten","devilskiss","red_mead",
					"mead","iced_beer","grog","aloe","andalusia","alliescocktail","soy_latte",
					"cafe_latte","acidspit","amasec","neurotoxin","hippiesdelight","bananahonk",
					"silencer","changelingsting","irishcarbomb","syndicatebomb","erikasurprise","driestmartini","flamingmoe",
					"ethanol","cider","specialwhiskey","absinthe","hooch","mojito","sake","suicider","ginsonic","applejack",
					"jackrose","drunkenblumpkin","eggnog","dragonsbreath","synthanol","robottears","trinary","servo",
					"uplink","synthnsoda","synthignon","fruit_wine","bacchus_blessing","fernet","fernet_cola","rainbow_sky","champagne",
					"aperol","jagermeister","schnaps","sambuka","bluecuracao","bitter","sheridan","black_blood","light_storm",
					"cream_heaven","negroni","hirosima","nagasaki","chocolate_sheridan","panamian",
					"pegu_club","jagermachine","blue_cybesauo","alcomender","amnesia","johnny","cosmospoliten","oldfashion",
					"french_75","gydroseridan","milk_plus","teslasingylo","light","bees_knees","aviation","fizz","brandy_crusta",
					"aperolspritz","sidecar","daiquiri","tuxedo","telegol","horse_neck","cuban_sunset","sake_bomb","blue_havai",
					"woo_woo","mulled_wine","white_bear","vampiro","queen_mary","inabox","beer_berry_royal","sazerac","monako",
					"irishempbomb","codelibre","blackicp","slime_drink","innocent_erp","nasty_slush","blue_lagoon","green_fairy",
					"home_lebovsky","top_billing","trans_siberian_express","sun","tick_tack","uragan_shot","new_yorker",
					"blue_moondrin","red_moondrin","pineapplejuice","poisonberryjuice","applejuice",
					"grapejuice","cafe_mocha","chocolatepudding","vanillapudding","cherryshake","bluecherryshake","pumpkin_latte",
					"gibbfloats","pumpkinjuice","blumpkinjuice","grapesoda","icecoco","alcohol_free_beer")) //holy fuck why so many

//Liver Toxins list
GLOBAL_LIST_INIT(liver_toxins, list("toxin", "plasma", "sacid", "facid", "cyanide","amanitin", "carpotoxin"))

//Random chem blacklist
GLOBAL_LIST_INIT(blocked_chems, list("polonium", "initropidril", "concentrated_initro",
							"sodium_thiopental", "ketamine", "coniine",
							"adminordrazine", "nanites", "hellwater",
							"mutationtoxin", "amutationtoxin", "venom",
							"spore", "stimulants", "stimulative_agent",
							"syndicate_nanites", "ripping_tendrils", "boiling_oil",
							"envenomed_filaments", "lexorin_jelly", "kinetic",
							"cryogenic_liquid", "dark_matter", "b_sorium",
							"reagent", "life","dragonsbreath", "nanocalcium", "bungotoxin"))

GLOBAL_LIST_INIT(safe_chem_list, list("antihol", "charcoal", "epinephrine", "insulin", "teporone","silver_sulfadiazine", "salbutamol",
									  "omnizine", "stimulants", "synaptizine", "potass_iodide", "oculine", "mannitol", "styptic_powder",
									  "spaceacillin", "salglu_solution", "sal_acid", "cryoxadone", "blood", "synthflesh", "hydrocodone",
									  "mitocholide", "rezadone"))

GLOBAL_LIST_INIT(safe_chem_applicator_list, list("silver_sulfadiazine", "styptic_powder", "synthflesh"))
