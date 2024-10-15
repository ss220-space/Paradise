/obj/machinery/vending/autodrobe
	name = "\improper AutoDrobe"
	desc = "A vending machine for costumes."

	icon_state = "theater_off"
	panel_overlay = "theater_panel"
	screen_overlay = "theater"
	lightmask_overlay = "theater_lightmask"
	broken_overlay = "theater_broken"
	broken_lightmask_overlay = "theater_broken_lightmask"
	deny_overlay = "theater_deny"

	slogan_list = list("Dress for success!","Suited and booted!","It's show time!","Why leave style up to fate? Use AutoDrobe!")
	vend_delay = 15
	vend_reply = "Thank you for using AutoDrobe!"
	products = list(/obj/item/clothing/suit/chickensuit = 1,
					/obj/item/clothing/head/chicken = 1,
					/obj/item/clothing/under/gladiator = 1,
					/obj/item/clothing/head/helmet/gladiator = 1,
					/obj/item/clothing/under/gimmick/rank/captain/suit = 1,
					/obj/item/clothing/head/flatcap = 1,
					/obj/item/clothing/suit/storage/labcoat/mad = 1,
					/obj/item/clothing/glasses/gglasses = 1,
					/obj/item/clothing/shoes/jackboots = 1,
					/obj/item/clothing/under/schoolgirl = 1,
					/obj/item/clothing/under/blackskirt = 1,
					/obj/item/clothing/neck/cloak/toggle/owlwings = 1,
					/obj/item/clothing/under/owl = 1,
					/obj/item/clothing/mask/gas/owl_mask = 1,
					/obj/item/clothing/neck/cloak/toggle/owlwings/griffinwings = 1,
					/obj/item/clothing/under/griffin = 1,
					/obj/item/clothing/shoes/griffin = 1,
					/obj/item/clothing/head/griffin = 1,
					/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/under/suit_jacket = 1,
					/obj/item/clothing/head/that =1,
					/obj/item/clothing/under/kilt = 1,
					/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/glasses/monocle =1,
					/obj/item/clothing/head/bowlerhat = 1,
					/obj/item/cane = 1,
					/obj/item/clothing/under/sl_suit = 1,
					/obj/item/clothing/mask/fakemoustache = 1,
					/obj/item/clothing/suit/bio_suit/plaguedoctorsuit = 1,
					/obj/item/clothing/head/plaguedoctorhat = 1,
					/obj/item/clothing/mask/gas/plaguedoctor = 1,
					/obj/item/clothing/suit/apron = 1,
					/obj/item/clothing/under/waiter = 1,
					/obj/item/clothing/suit/jacket/miljacket = 1,
					/obj/item/clothing/suit/jacket/miljacket/white = 1,
					/obj/item/clothing/suit/jacket/miljacket/desert = 1,
					/obj/item/clothing/suit/jacket/miljacket/navy = 1,
					/obj/item/clothing/under/pirate = 1,
					/obj/item/clothing/suit/pirate_brown = 1,
					/obj/item/clothing/suit/pirate_black =1,
					/obj/item/clothing/under/pirate_rags =1,
					/obj/item/clothing/head/pirate = 1,
					/obj/item/clothing/head/bandana = 1,
					/obj/item/clothing/head/bandana = 1,
					/obj/item/clothing/under/soviet = 1,
					/obj/item/clothing/head/ushanka = 1,
					/obj/item/clothing/suit/imperium_monk = 1,
					/obj/item/clothing/mask/gas/cyborg = 1,
					/obj/item/clothing/suit/holidaypriest = 1,
					/obj/item/clothing/head/wizard/marisa/fake = 1,
					/obj/item/clothing/suit/wizrobe/marisa/fake = 1,
					/obj/item/clothing/under/sundress = 1,
					/obj/item/clothing/head/witchwig = 1,
					/obj/item/twohanded/staff/broom = 1,
					/obj/item/clothing/suit/wizrobe/fake = 1,
					/obj/item/clothing/head/wizard/fake = 1,
					/obj/item/twohanded/staff = 3,
					/obj/item/clothing/mask/gas/clown_hat/sexy = 1,
					/obj/item/clothing/under/rank/clown/sexy = 1,
					/obj/item/clothing/under/rank/clown/clussy = 1,
					/obj/item/clothing/mask/gas/mime/sexy = 1,
					/obj/item/clothing/under/sexymime = 1,
					/obj/item/clothing/mask/face/bat = 1,
					/obj/item/clothing/mask/face/bee = 1,
					/obj/item/clothing/mask/face/bear = 1,
					/obj/item/clothing/mask/face/raven = 1,
					/obj/item/clothing/mask/face/jackal = 1,
					/obj/item/clothing/mask/face/fox = 1,
					/obj/item/clothing/mask/face/tribal = 1,
					/obj/item/clothing/mask/face/rat = 1,
					/obj/item/clothing/suit/apron/overalls = 1,
					/obj/item/clothing/head/rabbitears =1,
					/obj/item/clothing/head/sombrero = 1,
					/obj/item/clothing/neck/poncho = 3,
					/obj/item/clothing/accessory/blue = 1,
					/obj/item/clothing/accessory/red = 1,
					/obj/item/clothing/accessory/black = 1,
					/obj/item/clothing/accessory/horrible = 1,
					/obj/item/clothing/under/maid = 1,
					/obj/item/clothing/under/janimaid = 1,
					/obj/item/clothing/under/jester = 1,
					/obj/item/clothing/head/jester = 1,
					/obj/item/clothing/under/pennywise = 1,
					/obj/item/clothing/mask/gas/clown_hat/pennywise = 1,
					/obj/item/clothing/head/rockso = 1,
					/obj/item/clothing/mask/gas/clown_hat/rockso = 1,
					/obj/item/clothing/under/rockso = 1,
					/obj/item/clothing/under/pants/camo = 1,
					/obj/item/clothing/mask/bandana = 1,
					/obj/item/clothing/mask/bandana/black = 1,
					/obj/item/clothing/shoes/singery = 1,
					/obj/item/clothing/under/singery = 1,
					/obj/item/clothing/shoes/singerb = 1,
					/obj/item/clothing/under/singerb = 1,
					/obj/item/clothing/suit/hooded/carp_costume = 1,
					/obj/item/clothing/suit/hooded/bee_costume = 1,
					/obj/item/clothing/suit/snowman = 1,
					/obj/item/clothing/head/snowman = 1,
					/obj/item/clothing/head/cueball = 1,
					/obj/item/clothing/under/red_chaps = 1,
					/obj/item/clothing/under/white_chaps = 1,
					/obj/item/clothing/under/tan_chaps = 1,
					/obj/item/clothing/under/brown_chaps = 1,
					/obj/item/clothing/under/scratch = 1,
					/obj/item/clothing/under/victdress = 1,
					/obj/item/clothing/under/victdress/red = 1,
					/obj/item/clothing/suit/victcoat = 1,
					/obj/item/clothing/suit/victcoat/red = 1,
					/obj/item/clothing/under/victsuit = 1,
					/obj/item/clothing/under/victsuit/redblk = 1,
					/obj/item/clothing/under/victsuit/red = 1,
					/obj/item/clothing/suit/tailcoat = 1,
					/obj/item/clothing/under/tourist_suit = 1,
					/obj/item/clothing/suit/draculacoat = 1,
					/obj/item/clothing/head/zepelli = 1,
					/obj/item/clothing/under/redhawaiianshirt = 1,
					/obj/item/clothing/under/pinkhawaiianshirt = 1,
					/obj/item/clothing/under/bluehawaiianshirt = 1,
					/obj/item/clothing/under/orangehawaiianshirt = 1,
					/obj/item/clothing/under/ussptracksuit_red = 4,
					/obj/item/clothing/under/ussptracksuit_blue = 4,
					/obj/item/clothing/under/dress50s = 3)
	contraband = list(/obj/item/clothing/suit/judgerobe = 1,
					/obj/item/clothing/head/powdered_wig = 1,
					/obj/item/gun/magic/wand = 1,
					/obj/item/clothing/mask/balaclava =1,
					/obj/item/clothing/under/syndicate/blackops_civ = 1,
					/obj/item/clothing/glasses/thermal_fake = 1,
					/obj/item/clothing/mask/horsehead = 2)
	premium = list(/obj/item/clothing/suit/hgpirate = 1,
					/obj/item/clothing/head/hgpiratecap = 1,
					/obj/item/clothing/head/helmet/roman/fake = 1,
					/obj/item/clothing/head/helmet/roman/legionaire/fake = 1,
					/obj/item/clothing/under/roman = 1,
					/obj/item/clothing/shoes/roman = 1,
					/obj/item/shield/riot/roman/fake = 1,
					/obj/item/clothing/under/cuban_suit = 1,
					/obj/item/clothing/head/cuban_hat = 1,
					/obj/item/clothing/under/ussptracksuit_black = 1,
					/obj/item/clothing/under/ussptracksuit_white = 1,
					/obj/item/clothing/under/steampunkdress = 1,
					/obj/item/clothing/suit/hooded/hijab = 1)
	refill_canister = /obj/item/vending_refill/autodrobe

/obj/machinery/vending/hatdispenser
	name = "\improper Hatlord 9000"
	desc = "It doesn't seem the slightest bit unusual. This frustrates you immensely."

	icon_state = "hats_off"
	panel_overlay = "hats_panel"
	screen_overlay = "hats"
	lightmask_overlay = "hats_lightmask"
	broken_overlay = "hats_broken"
	broken_lightmask_overlay = "hats_broken_lightmask"

	ads_list = list("Warning, not all hats are dog/monkey compatible. Apply forcefully with care.","Apply directly to the forehead.","Who doesn't love spending cash on hats?!","From the people that brought you collectable hat crates, Hatlord!")
	products = list(/obj/item/clothing/head/bowlerhat = 10,
					/obj/item/clothing/head/beaverhat = 10,
					/obj/item/clothing/head/boaterhat = 10,
					/obj/item/clothing/head/fedora = 10,
					/obj/item/clothing/head/fez = 10,
					/obj/item/clothing/head/beret = 10)
	contraband = list(/obj/item/clothing/head/bearpelt = 5)
	premium = list(/obj/item/clothing/head/soft/rainbow = 1)
	refill_canister = /obj/item/vending_refill/hatdispenser

/obj/machinery/vending/suitdispenser
	name = "\improper Suitlord 9000"
	desc = "You wonder for a moment why all of your shirts and pants come conjoined. This hurts your head and you stop thinking about it."

	icon_state = "suits_off"
	panel_overlay = "suits_panel"
	screen_overlay = "suits"
	lightmask_overlay = "suits_lightmask"
	broken_overlay = "suits_broken"
	broken_lightmask_overlay = "suits_broken_lightmask"

	ads_list = list("Pre-Ironed, Pre-Washed, Pre-Wor-*BZZT*","Blood of your enemies washes right out!","Who are YOU wearing?","Look dapper! Look like an idiot!","Dont carry your size? How about you shave off some pounds you fat lazy- *BZZT*")
	products = list(
		/obj/item/clothing/under/color/black = 10,
		/obj/item/clothing/under/color/blue = 10,
		/obj/item/clothing/under/color/green = 10,
		/obj/item/clothing/under/color/grey = 10,
		/obj/item/clothing/under/color/pink = 10,
		/obj/item/clothing/under/color/red = 10,
		/obj/item/clothing/under/color/white = 10,
		/obj/item/clothing/under/color/yellow = 10,
		/obj/item/clothing/under/color/lightblue = 10,
		/obj/item/clothing/under/color/aqua = 10,
		/obj/item/clothing/under/color/purple = 10,
		/obj/item/clothing/under/color/lightgreen = 10,
		/obj/item/clothing/under/color/lightblue = 10,
		/obj/item/clothing/under/color/lightbrown = 10,
		/obj/item/clothing/under/color/brown = 10,
		/obj/item/clothing/under/color/yellowgreen = 10,
		/obj/item/clothing/under/color/darkblue = 10,
		/obj/item/clothing/under/color/lightred = 10,
		/obj/item/clothing/under/color/darkred = 10,
		/obj/item/clothing/under/colour/skirt = 10
		)
	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 5,/obj/item/clothing/under/color/orange = 5, /obj/item/clothing/under/syndicate/tacticool/skirt = 5)
	premium = list(/obj/item/clothing/under/rainbow = 1)
	refill_canister = /obj/item/vending_refill/suitdispenser

/obj/machinery/vending/shoedispenser
	name = "\improper Shoelord 9000"
	desc = "Wow, hatlord looked fancy, suitlord looked streamlined, and this is just normal. The guy who designed these must be an idiot."

	icon_state = "shoes_off"
	icon_state = "shoes_off"
	panel_overlay = "shoes_panel"
	screen_overlay = "shoes"
	lightmask_overlay = "shoes_lightmask"
	broken_overlay = "shoes_broken"
	broken_lightmask_overlay = "shoes_broken_lightmask"

	ads_list = list("Put your foot down!","One size fits all!","IM WALKING ON SUNSHINE!","No hobbits allowed.","NO PLEASE WILLY, DONT HURT ME- *BZZT*")
	products = list(/obj/item/clothing/shoes/black = 10,/obj/item/clothing/shoes/brown = 10,/obj/item/clothing/shoes/blue = 10,/obj/item/clothing/shoes/green = 10,/obj/item/clothing/shoes/yellow = 10,/obj/item/clothing/shoes/purple = 10,/obj/item/clothing/shoes/red = 10,/obj/item/clothing/shoes/white = 10,/obj/item/clothing/shoes/sandal=10)
	contraband = list(/obj/item/clothing/shoes/orange = 5)
	premium = list(/obj/item/clothing/shoes/rainbow = 1)
	refill_canister = /obj/item/vending_refill/shoedispenser

//don't forget to change the refill size if you change the machine's contents!
/obj/machinery/vending/clothing
	name = "\improper ClothesMate" //renamed to make the slogan rhyme
	desc = "A vending machine for clothing."

	icon_state = "clothes_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	slogan_list = list("Dress for success!","Prepare to look swagalicious!","Look at all this free swag!","Why leave style up to fate? Use the ClothesMate!")
	vend_delay = 15
	vend_reply = "Thank you for using the ClothesMate!"
	products = list(/obj/item/clothing/head/that = 2,
					/obj/item/clothing/head/fedora = 1,
					/obj/item/clothing/glasses/monocle = 1,
					/obj/item/clothing/under/suit_jacket/navy = 2,
					/obj/item/clothing/under/kilt = 1,
					/obj/item/clothing/under/overalls = 1,
					/obj/item/clothing/under/suit_jacket/really_black = 2,
					/obj/item/clothing/suit/storage/lawyer/blackjacket = 2,
					/obj/item/clothing/under/pants/galifepants = 3,
					/obj/item/clothing/under/pants/sandpants = 3,
					/obj/item/clothing/under/pants/jeans = 3,
					/obj/item/clothing/under/pants/classicjeans = 2,
					/obj/item/clothing/under/pants/camo = 1,
					/obj/item/clothing/under/pants/blackjeans = 2,
					/obj/item/clothing/under/pants/khaki = 2,
					/obj/item/clothing/under/pants/white = 2,
					/obj/item/clothing/under/pants/red = 1,
					/obj/item/clothing/under/pants/black = 2,
					/obj/item/clothing/under/pants/tan = 2,
					/obj/item/clothing/under/pants/blue = 1,
					/obj/item/clothing/under/pants/track = 1,
					/obj/item/clothing/suit/jacket/miljacket = 1,
					/obj/item/clothing/head/beanie = 3,
					/obj/item/clothing/head/beanie/black = 3,
					/obj/item/clothing/head/beanie/red = 3,
					/obj/item/clothing/head/beanie/green = 3,
					/obj/item/clothing/head/beanie/darkblue = 3,
					/obj/item/clothing/head/beanie/purple = 3,
					/obj/item/clothing/head/beanie/yellow = 3,
					/obj/item/clothing/head/beanie/orange = 3,
					/obj/item/clothing/head/beanie/cyan = 3,
					/obj/item/clothing/head/beanie/christmas = 3,
					/obj/item/clothing/head/beanie/striped = 3,
					/obj/item/clothing/head/beanie/stripedred = 3,
					/obj/item/clothing/head/beanie/stripedblue = 3,
					/obj/item/clothing/head/beanie/stripedgreen = 3,
					/obj/item/clothing/head/beanie/rasta = 3,
					/obj/item/clothing/accessory/scarf/red = 1,
					/obj/item/clothing/accessory/scarf/green = 1,
					/obj/item/clothing/accessory/scarf/darkblue = 1,
					/obj/item/clothing/accessory/scarf/purple = 1,
					/obj/item/clothing/accessory/scarf/yellow = 1,
					/obj/item/clothing/accessory/scarf/orange = 1,
					/obj/item/clothing/accessory/scarf/lightblue = 1,
					/obj/item/clothing/accessory/scarf/white = 1,
					/obj/item/clothing/accessory/scarf/black = 1,
					/obj/item/clothing/accessory/scarf/zebra = 1,
					/obj/item/clothing/accessory/scarf/christmas = 1,
					/obj/item/clothing/accessory/stripedredscarf = 1,
					/obj/item/clothing/accessory/stripedbluescarf = 1,
					/obj/item/clothing/accessory/stripedgreenscarf = 1,
					/obj/item/clothing/accessory/waistcoat = 1,
					/obj/item/clothing/under/sundress = 2,
					/obj/item/clothing/under/stripeddress = 1,
					/obj/item/clothing/under/sailordress = 1,
					/obj/item/clothing/under/redeveninggown = 1,
					/obj/item/clothing/under/blacktango = 1,
					/obj/item/clothing/suit/jacket = 3,
					/obj/item/clothing/suit/jacket/motojacket = 3,
					/obj/item/clothing/glasses/regular = 2,
					/obj/item/clothing/glasses/sunglasses_fake = 2,
					/obj/item/clothing/head/sombrero = 1,
					/obj/item/clothing/neck/poncho = 1,
					/obj/item/clothing/suit/ianshirt = 1,
					/obj/item/clothing/shoes/laceup = 2,
					/obj/item/clothing/shoes/black = 4,
					/obj/item/clothing/shoes/sandal = 1,
					/obj/item/clothing/shoes/leather_boots = 3,
					/obj/item/clothing/gloves/brown_short_gloves = 3,
					/obj/item/clothing/gloves/fingerless = 2,
					/obj/item/storage/belt/fannypack = 1,
					/obj/item/storage/belt/fannypack/blue = 1,
					/obj/item/storage/belt/fannypack/red = 1,
					/obj/item/clothing/neck/mantle = 2,
					/obj/item/clothing/neck/mantle/old = 1,
					/obj/item/clothing/neck/mantle/regal = 2,
					/obj/item/clothing/neck/cloak/grey = 1)

	contraband = list(/obj/item/clothing/under/syndicate/tacticool = 1,
					/obj/item/clothing/under/syndicate/tacticool/skirt = 1,
					/obj/item/clothing/mask/balaclava = 1,
					/obj/item/clothing/under/syndicate/blackops_civ = 1,
					/obj/item/clothing/head/ushanka = 1,
					/obj/item/clothing/under/soviet = 1,
					/obj/item/storage/belt/fannypack/black = 1)

	premium = list(/obj/item/clothing/under/suit_jacket/checkered = 1,
				   /obj/item/clothing/head/mailman = 1,
				   /obj/item/clothing/under/rank/mailman = 1,
				   /obj/item/clothing/suit/jacket/leather = 1,
				   /obj/item/clothing/under/pants/mustangjeans = 1)

	refill_canister = /obj/item/vending_refill/clothing

/obj/machinery/vending/clothing/departament
	name = "\improper Broken Departament ClothesMate"
	desc = "Автомат-помощник по выдаче одежды отдела."
	slogan_list = list(
		"Одежда успешного работника!", "Похвала на глаза!", "Ну наконец-то нормально оделся!",
		"Одевай одежду, надевай еще и шляпку!", "Вот это гордость такое надевать!", "Выглядишь отпадно!",
		"Я бы и сам такое носил!", "А я думал, куда она подевалась...", "О, это была моя любимая!",
		"Производитель рекомендует этот фасон", "Ваша талия идеально сочетается с ней!",
		"Ваши глаза так и блистают с ней!", "Как же ты здорово выглядишь!", "И не скажешь что тебе не идёт!",
		"Ну жених!", "Постой на картонке, возможно найдем что поинтереснее!", "Бери-бери, не глазей!",
		"Возвраты не берем!", "Ну как на тебя шили!", "Только не стирайте в машинке.", "У нас лучшая одежда! То что вы взяли было не самым лучшим",
		"Не переживайте! Если моль её поела, значит она качественная!", "Вам идеально подошла бы другая одежда, но и эта подойдет!",
		"Выглядите стильно. По депортаменски!", "Вы теперь выглядите отделанным! Ну одежда отдела у вас!",
		"Отдел будет вам доволен, если вы нарядитесь в это!", "Ну красавец!"
		)
	vend_delay = 15
	vend_reply = "Спасибо за использование автомата-помощника в выборе одежды отдела!"
	products = list()
	contraband = list()
	premium = list()
	refill_canister = null

/obj/machinery/vending/clothing/departament/security
	name = "\improper Departament Security ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Отдела Службы Безопасности."

	icon_state = "clothes-dep-sec_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-sec"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-sec_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_SEC_DOORS)
	products = list(
		/obj/item/clothing/head/soft/sec		= 10,
		/obj/item/clothing/head/soft/sec/corp	= 10,
		/obj/item/clothing/head/beret/sec		= 10,
		/obj/item/clothing/head/beret/sec/black	= 10,
		/obj/item/clothing/head/officer		 	= 10,
		/obj/item/clothing/head/beret/brigphys  = 5,
		/obj/item/clothing/head/soft/brigphys   = 5,
		/obj/item/clothing/head/helmet/lightweighthelmet = 10,

		/obj/item/clothing/under/rank/security			= 10,
		/obj/item/clothing/under/rank/security/skirt 	= 10,
		/obj/item/clothing/under/rank/security/formal 	= 5,
		/obj/item/clothing/under/rank/security/corp 	= 5,
		/obj/item/clothing/under/rank/security2 		= 5,
		/obj/item/clothing/under/rank/dispatch 			= 5,

		/obj/item/clothing/suit/tracksuit/red				= 5,
		/obj/item/clothing/suit/hooded/wintercoat/security	= 5,
		/obj/item/clothing/suit/jacket/pilot	= 5,
		/obj/item/clothing/suit/armor/vest/sec_rps	= 5,
		/obj/item/clothing/suit/armor/secjacket = 5,

		/obj/item/clothing/mask/balaclava 		= 10,
		/obj/item/clothing/mask/bandana/red 	= 10,
		/obj/item/clothing/mask/bandana/black 	= 10,
		/obj/item/clothing/mask/secscarf 		= 10,

		/obj/item/clothing/gloves/color/black	= 10,
		/obj/item/clothing/gloves/color/red	= 10,

		/obj/item/clothing/shoes/jackboots 				= 10,
		/obj/item/clothing/shoes/jackboots/jacksandals 	= 10,
		/obj/item/clothing/shoes/jackboots/cross 		= 10,

		/obj/item/radio/headset/headset_sec		= 10, //No EARBANGPROTECT. Hehe...

		/obj/item/clothing/glasses/hud/security/sunglasses/tacticool = 5,

		/obj/item/clothing/accessory/scarf/black 	= 10,
		/obj/item/clothing/accessory/scarf/red 		= 10,
		/obj/item/clothing/neck/poncho/security     = 10,
		/obj/item/clothing/neck/cloak/security      = 10,
		/obj/item/clothing/accessory/armband/sec 	= 10,

		/obj/item/storage/backpack/security 		= 5,
		/obj/item/storage/backpack/satchel_sec 		= 5,
		/obj/item/storage/backpack/duffel/security 	= 5,

		//For trainings
		/obj/item/clothing/under/shorts/red			= 10,
		/obj/item/clothing/under/shorts/black		= 5,
		/obj/item/clothing/under/pants/red 			= 10,
		/obj/item/clothing/under/pants/track 		= 5,

		//For brig physician
		/obj/item/clothing/under/rank/security/brigphys = 3,
		/obj/item/clothing/under/rank/security/brigphys/skirt 	= 3,
		/obj/item/clothing/suit/storage/suragi_jacket/medsec = 3,
		/obj/item/clothing/suit/storage/brigdoc = 3,
		/obj/item/clothing/under/rank/security/brigmedical = 3,
		/obj/item/clothing/under/rank/security/brigmedical/skirt = 3
		)


	refill_canister = /obj/item/vending_refill/clothing/security

/obj/machinery/vending/clothing/departament/medical
	name = "\improper Departament Medical ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Медицинского Отдела."

	icon_state = "clothes-dep-med_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-med"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-med_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_MEDICAL)
	products = list(
		/obj/item/clothing/head/beret/med  			= 10,
		/obj/item/clothing/head/soft/paramedic		= 5,
		/obj/item/clothing/head/surgery/purple 		= 10,
		/obj/item/clothing/head/surgery/blue 		= 10,
		/obj/item/clothing/head/surgery/green 		= 10,
		/obj/item/clothing/head/surgery/lightgreen 	= 10,
		/obj/item/clothing/head/surgery/black 		= 10,
		/obj/item/clothing/head/headmirror 			= 10,

		/obj/item/clothing/under/rank/medical 				= 10,
		/obj/item/clothing/under/rank/medical/skirt 		= 10,
		/obj/item/clothing/under/rank/medical/intern 		= 10,
		/obj/item/clothing/under/rank/medical/intern/skirt 	= 10,
		/obj/item/clothing/under/rank/medical/intern/assistant 			= 10,
		/obj/item/clothing/under/rank/medical/intern/assistant/skirt 	= 10,
		/obj/item/clothing/under/rank/medical/blue 			= 10,
		/obj/item/clothing/under/rank/medical/green 		= 10,
		/obj/item/clothing/under/rank/medical/purple 		= 10,
		/obj/item/clothing/under/rank/medical/lightgreen 	= 10,
		/obj/item/clothing/under/medigown 					= 10,
		/obj/item/clothing/under/rank/nursesuit				= 10,
		/obj/item/clothing/under/rank/nurse					= 10,
		/obj/item/clothing/under/rank/orderly				= 10,
		/obj/item/clothing/under/rank/medical/paramedic		= 5,
		/obj/item/clothing/under/rank/medical/paramedic/skirt			= 5,

		/obj/item/clothing/suit/storage/labcoat 	= 10,
		/obj/item/clothing/suit/storage/suragi_jacket/medic = 10,
		/obj/item/clothing/suit/apron/surgical 		= 10,
		/obj/item/clothing/suit/storage/fr_jacket 	= 5,
		/obj/item/clothing/suit/hooded/wintercoat/medical	= 5,

		/obj/item/clothing/mask/surgical 		= 10,

		/obj/item/clothing/gloves/color/latex 	= 10,
		/obj/item/clothing/gloves/color/latex/nitrile	= 10,

		/obj/item/clothing/shoes/white 			= 10,
		/obj/item/clothing/shoes/sandal/white 	= 10,

		/obj/item/radio/headset/headset_med 	= 10,

		/obj/item/clothing/accessory/scarf/white 		= 10,
		/obj/item/clothing/accessory/scarf/lightblue 	= 10,
		/obj/item/clothing/accessory/stethoscope		= 10,
		/obj/item/clothing/accessory/armband/med 		= 10,
		/obj/item/clothing/accessory/armband/medgreen 	= 10,

		/obj/item/storage/backpack/satchel_med 		= 5,
		/obj/item/storage/backpack/medic 			= 5,
		/obj/item/storage/backpack/duffel/medical 	= 5,

		/obj/item/clothing/under/rank/virologist	= 2,
		/obj/item/clothing/under/rank/virologist/skirt = 2,
		/obj/item/clothing/suit/storage/labcoat/virologist = 2,
		/obj/item/clothing/suit/storage/suragi_jacket/virus = 2,
		/obj/item/storage/backpack/satchel_vir		= 2,
		/obj/item/storage/backpack/virology			= 2,
		/obj/item/storage/backpack/duffel/virology	= 2,

		/obj/item/clothing/under/rank/chemist		= 2,
		/obj/item/clothing/under/rank/chemist/skirt	= 2,
		/obj/item/clothing/suit/storage/labcoat/chemist = 2,
		/obj/item/clothing/suit/storage/suragi_jacket/chem 	= 2,
		/obj/item/storage/backpack/satchel_chem 	= 2,
		/obj/item/storage/backpack/chemistry		= 2,
		/obj/item/storage/backpack/duffel/chemistry	= 2,

		/obj/item/clothing/under/rank/geneticist	= 2,
		/obj/item/clothing/under/rank/geneticist/skirt = 2,
		/obj/item/clothing/suit/storage/labcoat/genetics = 2,
		/obj/item/clothing/suit/storage/suragi_jacket/genetics = 2,
		/obj/item/storage/backpack/satchel_gen 		= 2,
		/obj/item/storage/backpack/genetics			= 2,
		/obj/item/storage/backpack/duffel/genetics	= 2,

		/obj/item/clothing/under/rank/psych				= 2,
		/obj/item/clothing/under/rank/psych/turtleneck	= 2,
		/obj/item/clothing/under/rank/psych/skirt	= 2,

		/obj/item/clothing/suit/storage/labcoat/mortician 	= 2,
		/obj/item/clothing/under/rank/medical/mortician  	= 2,
		)


	refill_canister = /obj/item/vending_refill/clothing/medical

/obj/machinery/vending/clothing/departament/engineering
	name = "\improper Departament Engineering ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Инженерного Отдела."

	icon_state = "clothes-dep-eng_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-eng"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-eng_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_ENGINE_EQUIP)
	products = list(
		/obj/item/clothing/head/hardhat = 10,
		/obj/item/clothing/head/hardhat/orange = 10,
		/obj/item/clothing/head/hardhat/red = 10,
		/obj/item/clothing/head/hardhat/dblue = 10,
		/obj/item/clothing/head/beret/eng = 10,

		/obj/item/clothing/under/rank/engineer = 10,
		/obj/item/clothing/under/rank/engineer/skirt = 10,
		/obj/item/clothing/under/rank/engineer/trainee/assistant = 10,
		/obj/item/clothing/under/rank/engineer/trainee/assistant/skirt = 10,

		/obj/item/clothing/suit/storage/hazardvest = 10,
		/obj/item/clothing/suit/storage/suragi_jacket/eng = 5,
		/obj/item/clothing/suit/hooded/wintercoat/engineering = 5,

		/obj/item/clothing/mask/gas  = 10,
		/obj/item/clothing/mask/bandana/red 	= 10,
		/obj/item/clothing/mask/bandana/orange 	= 10,
		/obj/item/clothing/mask/bandana/red 	= 10,

		/obj/item/clothing/gloves/color/orange	= 10,
		/obj/item/clothing/gloves/color/fyellow = 3,

		/obj/item/clothing/shoes/workboots 		= 10,

		/obj/item/radio/headset/headset_eng 	= 10,

		/obj/item/clothing/accessory/scarf/yellow	= 10,
		/obj/item/clothing/accessory/scarf/orange	= 10,
		/obj/item/clothing/accessory/armband/engine = 10,

		/obj/item/storage/backpack/industrial = 5,
		/obj/item/storage/backpack/satchel_eng = 5,
		/obj/item/storage/backpack/duffel/engineering = 5,

		/obj/item/clothing/under/rank/atmospheric_technician = 3,
		/obj/item/clothing/under/rank/atmospheric_technician/skirt = 3,
		/obj/item/clothing/head/beret/atmos = 3,
		/obj/item/clothing/suit/hooded/wintercoat/engineering/atmos = 5,
		/obj/item/clothing/suit/storage/suragi_jacket/atmos = 5,
		/obj/item/storage/backpack/duffel/atmos = 3.
		)


	refill_canister = /obj/item/vending_refill/clothing/engineering

/obj/machinery/vending/clothing/departament/science
	name = "\improper Departament Science ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Научного Отдела."

	icon_state = "clothes-dep-sci_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-sci"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-sci_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_RESEARCH)
	products = list(
		/obj/item/clothing/head/beret/purple_normal = 10,
		/obj/item/clothing/head/beret/purple = 10,

		/obj/item/clothing/under/rank/scientist = 10,
		/obj/item/clothing/under/rank/scientist/skirt = 10,
		/obj/item/clothing/under/rank/scientist/student = 10,
		/obj/item/clothing/under/rank/scientist/student/skirt = 10,
		/obj/item/clothing/under/rank/scientist/student/assistant = 10,
		/obj/item/clothing/under/rank/scientist/student/assistant/skirt = 10,

		/obj/item/clothing/suit/storage/labcoat/science = 10,
		/obj/item/clothing/suit/storage/labcoat 		= 10,
		/obj/item/clothing/suit/storage/suragi_jacket/sci = 5,
		/obj/item/clothing/suit/hooded/wintercoat/medical/science = 5,

		/obj/item/clothing/gloves/color/latex 	= 10,
		/obj/item/clothing/gloves/color/white 	= 10,
		/obj/item/clothing/gloves/color/purple 	= 10,

		/obj/item/clothing/shoes/white 			= 10,
		/obj/item/clothing/shoes/slippers 		= 10,
		/obj/item/clothing/shoes/sandal/white 	= 10,

		/obj/item/radio/headset/headset_sci 		= 10,
		/obj/item/clothing/accessory/armband/science = 10,
		/obj/item/clothing/accessory/armband/yb 	= 10,
		/obj/item/clothing/accessory/scarf/purple 	= 10,

		/obj/item/storage/backpack/science 			= 5,
		/obj/item/storage/backpack/satchel_tox 		= 5,
		/obj/item/storage/backpack/duffel/science 	= 5,

		/obj/item/clothing/head/soft/black 		= 10,
		/obj/item/clothing/under/rank/roboticist 	= 10,
		/obj/item/clothing/under/rank/roboticist/skirt = 10,
		/obj/item/clothing/gloves/fingerless 	= 10,
		/obj/item/clothing/shoes/black 			= 10,
		)


	refill_canister = /obj/item/vending_refill/clothing/science

/obj/machinery/vending/clothing/departament/cargo
	name = "\improper Departament Cargo ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Отдела Поставок."

	icon_state = "clothes-dep-car_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-car"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-car_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_MINING)
	products = list(
		/obj/item/clothing/head/soft = 10,

		/obj/item/clothing/under/rank/cargotech 		= 10,
		/obj/item/clothing/under/rank/cargotech/skirt 	= 10,
		/obj/item/clothing/under/rank/cargotech/alt		= 5,
		/obj/item/clothing/under/rank/miner/lavaland 	= 10,
		/obj/item/clothing/under/overalls 				= 10,
		/obj/item/clothing/under/rank/miner/alt			= 5,


		/obj/item/clothing/mask/bandana/black 	= 10,
		/obj/item/clothing/mask/bandana/orange 	= 10,

		/obj/item/clothing/gloves/color/brown/cargo = 10,
		/obj/item/clothing/gloves/color/light_brown = 10,
		/obj/item/clothing/gloves/fingerless 	= 10,
		/obj/item/clothing/gloves/color/black 	= 10,

		/obj/item/clothing/shoes/brown = 10,
		/obj/item/clothing/shoes/workboots/mining = 10,
		/obj/item/clothing/shoes/jackboots 				= 10,
		/obj/item/clothing/shoes/jackboots/jacksandals 	= 10,

		/obj/item/radio/headset/headset_cargo = 10,

		/obj/item/clothing/accessory/armband/cargo = 10,

		/obj/item/storage/backpack/cargo = 10,
		/obj/item/storage/backpack/explorer = 5,
		/obj/item/storage/backpack/satchel_explorer = 5,
		/obj/item/storage/backpack/duffel = 5,

		/obj/item/clothing/under/pants/tan 		= 10,
		/obj/item/clothing/under/pants/track 	= 10,

		/obj/item/clothing/suit/storage/cargotech = 5,

		/obj/item/clothing/suit/hooded/wintercoat/cargo	= 5,
		/obj/item/clothing/suit/hooded/wintercoat/miner	= 5,
		)


	refill_canister = /obj/item/vending_refill/clothing/cargo


/obj/machinery/vending/clothing/departament/law
	name = "\improper Departament Law ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Юридического Отдела."

	icon_state = "clothes-dep-sec_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-sec"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-sec_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_LAWYER)
	products = list(
		/obj/item/clothing/under/rank/internalaffairs = 10,
		/obj/item/clothing/under/lawyer/female = 10,
		/obj/item/clothing/under/lawyer/black = 10,
		/obj/item/clothing/under/lawyer/red = 10,
		/obj/item/clothing/under/lawyer/blue = 10,
		/obj/item/clothing/under/lawyer/bluesuit = 10,
		/obj/item/clothing/under/lawyer/purpsuit = 10,
		/obj/item/clothing/under/lawyer/oldman = 10,
		/obj/item/clothing/under/blackskirt 	= 10,

		/obj/item/clothing/suit/storage/internalaffairs  = 10,
		/obj/item/clothing/suit/storage/lawyer/bluejacket = 5,
		/obj/item/clothing/suit/storage/lawyer/purpjacket = 5,
		/obj/item/clothing/under/suit_jacket = 5,
		/obj/item/clothing/under/suit_jacket/really_black = 5,
		/obj/item/clothing/under/suit_jacket/female = 5,
		/obj/item/clothing/under/suit_jacket/red = 5,
		/obj/item/clothing/under/suit_jacket/navy = 5,
		/obj/item/clothing/under/suit_jacket/tan = 5,
		/obj/item/clothing/under/suit_jacket/burgundy = 5,
		/obj/item/clothing/under/suit_jacket/charcoal = 5,

		/obj/item/clothing/gloves/color/white 	= 10,
		/obj/item/clothing/gloves/fingerless	= 10,

		/obj/item/clothing/shoes/laceup  		= 10,
		/obj/item/clothing/shoes/centcom 		= 10,
		/obj/item/clothing/shoes/brown 			= 10,
		/obj/item/clothing/shoes/sandal/fancy 	= 10,

		/obj/item/radio/headset/headset_iaa  	= 10,


		/obj/item/clothing/accessory/blue 		= 10,
		/obj/item/clothing/accessory/red 		= 10,
		/obj/item/clothing/accessory/black 		= 10,
		/obj/item/clothing/accessory/waistcoat	= 5,

		/obj/item/storage/backpack/satchel 	= 10,
		/obj/item/storage/briefcase			= 5,
		)


	refill_canister = /obj/item/vending_refill/clothing/law


/obj/machinery/vending/clothing/departament/service
	name = "\improper Departament Service ClothesMate"
	desc = "Автомат-помощник по выдаче одежды Сервисного отдела."
	req_access = list()
	products = list()
	refill_canister = /obj/item/vending_refill/

/obj/machinery/vending/clothing/departament/service/chaplain
	name = "\improper Departament Service ClothesMate Chaplain"
	desc = "Автомат-помощник по выдаче одежды Сервисного отдела церкви."

	icon_state = "clothes-dep-car_off"
	panel_overlay = "clothes_panel"
	screen_overlay = "clothes-dep-car"
	lightmask_overlay = "clothes_lightmask"
	broken_overlay = "clothes-dep-car_broken"
	broken_lightmask_overlay = "clothes_broken_lightmask"

	req_access = list(ACCESS_CHAPEL_OFFICE)
	products = list(
		/obj/item/clothing/under/rank/chaplain = 5,
		/obj/item/clothing/under/rank/chaplain/skirt = 5,
		/obj/item/clothing/suit/witchhunter = 2,
		/obj/item/clothing/head/witchhunter_hat = 2,
		/obj/item/clothing/suit/armor/riot/knight/templar = 1,
		/obj/item/clothing/head/helmet/riot/knight/templar = 1,
		/obj/item/clothing/under/wedding/bride_white = 1,
		/obj/item/clothing/suit/hooded/chaplain_hoodie = 2,
		/obj/item/radio/headset/headset_service = 5,
		/obj/item/clothing/suit/hooded/nun = 2,
		/obj/item/clothing/suit/holidaypriest = 2,
		/obj/item/clothing/head/bishopmitre = 2,
		/obj/item/clothing/neck/cloak/bishop = 2,
		/obj/item/clothing/head/blackbishopmitre = 2,
		/obj/item/clothing/neck/cloak/bishopblack = 2,
		/obj/item/storage/backpack/cultpack = 5,
		/obj/item/clothing/shoes/black = 5,
		/obj/item/clothing/shoes/laceup = 2,
		/obj/item/clothing/gloves/ring/gold = 2,
		/obj/item/clothing/gloves/ring/silver = 2
	)
	refill_canister = /obj/item/vending_refill/clothing/service/chaplain


/obj/machinery/vending/clothing/departament/service/botanical
	name = "\improper Departament Service ClothesMate Botanical"
	desc = "Автомат-помощник по выдаче одежды Сервисного отдела ботаники."
	req_access = list(ACCESS_HYDROPONICS)
	products = list(
		/obj/item/clothing/under/rank/hydroponics = 5,
		/obj/item/clothing/under/rank/hydroponics/skirt = 5,
		/obj/item/clothing/suit/storage/suragi_jacket/botany = 3,
		/obj/item/clothing/suit/apron = 4,
		/obj/item/clothing/suit/apron/overalls = 2,
		/obj/item/clothing/suit/hooded/wintercoat/hydro = 5,
		/obj/item/clothing/mask/bandana/botany = 4,
		/obj/item/clothing/accessory/scarf/green = 2,
		/obj/item/clothing/head/flatcap = 2,
		/obj/item/radio/headset/headset_service = 5,
		/obj/item/clothing/gloves/botanic_leather = 5,
		/obj/item/clothing/gloves/fingerless = 3,
		/obj/item/clothing/gloves/color/brown = 3,
		/obj/item/storage/backpack/botany = 5,
		/obj/item/storage/backpack/satchel_hyd = 5,
		/obj/item/storage/backpack/duffel/hydro = 5,
		/obj/item/clothing/shoes/brown = 4,
		/obj/item/clothing/shoes/sandal = 2,
		/obj/item/clothing/shoes/leather = 2
	)
	refill_canister = /obj/item/vending_refill/clothing/service/botanical

