//Прочие автоматы, которые я не смог отнести к определённой категории.

/obj/machinery/vending/assist

	icon_state = "generic_off"
	panel_overlay = "generic_panel"
	screen_overlay = "generic"
	lightmask_overlay = "generic_lightmask"
	broken_overlay = "generic_broken"
	broken_lightmask_overlay = "generic_broken_lightmask"

	products = list(	/obj/item/assembly/prox_sensor = 5,/obj/item/assembly/igniter = 3,/obj/item/assembly/signaler = 4,
						/obj/item/wirecutters = 1, /obj/item/cartridge/signal = 4)
	contraband = list(/obj/item/flashlight = 5,/obj/item/assembly/timer = 2, /obj/item/assembly/voice = 2, /obj/item/assembly/health = 2)
	ads_list = list("Only the finest!","Have some tools.","The most robust equipment.","The finest gear in space!")
	refill_canister = /obj/item/vending_refill/assist

/obj/machinery/vending/cart
	name = "\improper PTech"
	desc = "Cartridges for PDA's."
	slogan_list = list("Карточки в дорогу!")

	icon_state = "cart_off"
	panel_overlay = "cart_panel"
	screen_overlay = "cart"
	lightmask_overlay = "cart_lightmask"
	broken_overlay = "cart_broken"
	broken_lightmask_overlay = "cart_broken_lightmask"
	deny_overlay = "cart_deny"

	products = list(/obj/item/pda =10,/obj/item/eftpos = 6,/obj/item/cartridge/medical = 10,/obj/item/cartridge/chemistry = 10,
					/obj/item/cartridge/engineering = 10,/obj/item/cartridge/atmos = 10,/obj/item/cartridge/janitor = 10,
					/obj/item/cartridge/signal/toxins = 10,/obj/item/cartridge/signal = 10)
	contraband = list(/obj/item/cartridge/clown = 1,/obj/item/cartridge/mime = 1)
	prices = list(/obj/item/pda =300,/obj/item/eftpos = 200,/obj/item/cartridge/medical = 200,/obj/item/cartridge/chemistry = 150,/obj/item/cartridge/engineering = 100,
					/obj/item/cartridge/atmos = 75,/obj/item/cartridge/janitor = 100,/obj/item/cartridge/signal/toxins = 150,
					/obj/item/cartridge/signal = 75)
	refill_canister = /obj/item/vending_refill/cart

/obj/machinery/vending/cart/free
	prices = list()

/obj/machinery/vending/magivend
	name = "\improper MagiVend"
	desc = "A magic vending machine."

	icon_state = "magivend_off"
	panel_overlay = "magivend_panel"
	screen_overlay = "magivend"
	lightmask_overlay = "magivend_lightmask"
	broken_overlay = "magivend_broken"
	broken_lightmask_overlay = "magivend_broken_lightmask"

	slogan_list = list("Sling spells the proper way with MagiVend!","Be your own Houdini! Use MagiVend!")
	vend_delay = 15
	vend_reply = "Have an enchanted evening!"
	ads_list = list("FJKLFJSD","AJKFLBJAKL","1234 LOONIES LOL!",">MFW","Kill them fuckers!","GET DAT FUKKEN DISK","HONK!","EI NATH","Destroy the station!","Admin conspiracies since forever!","Space-time bending hardware!")
	products = list(/obj/item/clothing/head/wizard = 5,
					/obj/item/clothing/suit/wizrobe = 5,
					/obj/item/clothing/head/wizard/red = 5,
					/obj/item/clothing/suit/wizrobe/red = 5,
					/obj/item/clothing/shoes/sandal = 5,
					/obj/item/clothing/suit/wizrobe/clown = 5,
					/obj/item/clothing/head/wizard/clown = 5,
					/obj/item/clothing/mask/gas/clownwiz = 5,
					/obj/item/clothing/shoes/clown_shoes/magical = 5,
					/obj/item/clothing/suit/wizrobe/mime = 5,
					/obj/item/clothing/head/wizard/mime = 5,
					/obj/item/clothing/mask/gas/mime/wizard = 5,
					/obj/item/clothing/head/wizard/marisa = 5,
					/obj/item/clothing/suit/wizrobe/marisa = 5,
					/obj/item/clothing/shoes/sandal/marisa = 5,
					/obj/item/twohanded/staff/broom = 5,
					/obj/item/clothing/head/wizard/black = 5,
					/obj/item/clothing/head/wizard/fluff/dreamy = 5,
					/obj/item/twohanded/staff = 10,
					/obj/item/clothing/head/helmet/space/plasmaman/wizard = 5,
					/obj/item/clothing/under/plasmaman/wizard = 5,
					/obj/item/tank/internals/plasmaman/belt/full = 5,
					/obj/item/clothing/mask/breath = 5,
					/obj/item/tank/internals/emergency_oxygen/double/vox = 5,
					/obj/item/clothing/mask/breath/vox = 5)
	contraband = list(/obj/item/reagent_containers/glass/bottle/wizarditis = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	tiltable = FALSE

/obj/machinery/vending/artvend
	name = "\improper ArtVend"
	desc = "A vending machine for art supplies."
	slogan_list = list("Stop by for all your artistic needs!","Color the floors with crayons, not blood!","Don't be a starving artist, use ArtVend. ","Don't fart, do art!")
	ads_list = list("Just like Kindergarten!","Now with 1000% more vibrant colors!","Screwing with the janitor was never so easy!","Creativity is at the heart of every spessman.")
	vend_delay = 15

	icon_state = "artvend_off"
	panel_overlay = "artvend_panel"
	screen_overlay = "artvend"
	lightmask_overlay = "artvend_lightmask"
	broken_overlay = "artvend_broken"
	broken_lightmask_overlay = "artvend_broken_lightmask"

	products = list(
		/obj/item/toy/crayon/spraycan = 2,
		/obj/item/stack/cable_coil/random = 10,
		/obj/item/camera = 4,
		/obj/item/camera_film = 6,
		/obj/item/storage/photo_album = 2,
		/obj/item/stack/wrapping_paper = 4,
		/obj/item/stack/tape_roll = 5,
		/obj/item/stack/packageWrap = 4,
		/obj/item/storage/fancy/crayons = 4,
		/obj/item/storage/fancy/glowsticks_box = 3,
		/obj/item/hand_labeler = 4,
		/obj/item/paper = 10,
		/obj/item/c_tube = 10,
		/obj/item/pen = 5,
		/obj/item/pen/blue = 5,
		/obj/item/pen/red = 5)
	contraband = list(
		/obj/item/toy/crayon/mime = 1,
		/obj/item/toy/crayon/rainbow = 1,
		/obj/item/weaponcrafting/receiver = 1
)
	premium = list(/obj/item/poster/random_contraband = 5
	)
	prices = list(
		/obj/item/toy/crayon/spraycan = 50,
		/obj/item/stack/cable_coil/random = 30,
		/obj/item/camera = 20,
		/obj/item/camera_film = 10,
		/obj/item/storage/photo_album = 10,
		/obj/item/stack/wrapping_paper = 20,
		/obj/item/stack/tape_roll = 20,
		/obj/item/stack/packageWrap = 10,
		/obj/item/storage/fancy/crayons = 35,
		/obj/item/storage/fancy/glowsticks_box = 100,
		/obj/item/hand_labeler = 30,
		/obj/item/paper = 5,
		/obj/item/c_tube = 10,
		/obj/item/pen = 5,
		/obj/item/pen/blue = 10,
		/obj/item/pen/red = 10,
		/obj/item/toy/crayon/mime = 50,
		/obj/item/toy/crayon/rainbow = 50,
		/obj/item/weaponcrafting/receiver = 250
	)

/obj/machinery/vending/crittercare
	name = "\improper CritterCare"
	desc = "A vending machine for pet supplies."
	slogan_list = list("Stop by for all your animal's needs!","Cuddly pets deserve a stylish collar!","Pets in space, what could be more adorable?","Freshest fish eggs in the system!","Rocks are the perfect pet, buy one today!")
	ads_list = list("House-training costs extra!","Now with 1000% more cat hair!","Allergies are a sign of weakness!","Dogs are man's best friend. Remember that Vulpkanin!"," Heat lamps for Unathi!"," Vox-y want a cracker?")
	vend_delay = 15

	icon_state = "crittercare_off"
	panel_overlay = "crittercare_panel"
	screen_overlay = "crittercare"
	lightmask_overlay = "crittercare_lightmask"
	broken_overlay = "crittercare_broken"
	broken_lightmask_overlay = "crittercare_broken_lightmask"

	products = list(
		/obj/item/clothing/accessory/petcollar = 5,
		/obj/item/storage/firstaid/aquatic_kit/full = 5,
		/obj/item/fish_eggs/goldfish = 5,
		/obj/item/fish_eggs/clownfish = 5,
		/obj/item/fish_eggs/shark = 5,
		/obj/item/fish_eggs/feederfish = 10,
		/obj/item/fish_eggs/salmon = 5,
		/obj/item/fish_eggs/catfish = 5,
		/obj/item/fish_eggs/glofish = 5,
		/obj/item/fish_eggs/electric_eel = 5,
		/obj/item/fish_eggs/crayfish = 5,
		/obj/item/fish_eggs/shrimp = 10,
		/obj/item/toy/pet_rock = 5,
		/obj/item/pet_carrier/normal = 3,
		/obj/item/pet_carrier = 5,
		/obj/item/reagent_containers/food/condiment/animalfeed = 5,
		/obj/item/reagent_containers/glass/pet_bowl = 3,
	)

	prices = list(
		/obj/item/clothing/accessory/petcollar = 50,
		/obj/item/storage/firstaid/aquatic_kit/full = 60,
		/obj/item/fish_eggs/goldfish = 10,
		/obj/item/fish_eggs/clownfish = 10,
		/obj/item/fish_eggs/shark = 10,
		/obj/item/fish_eggs/feederfish = 5,
		/obj/item/fish_eggs/salmon = 10,
		/obj/item/fish_eggs/catfish = 10,
		/obj/item/fish_eggs/glofish = 10,
		/obj/item/fish_eggs/electric_eel = 10,
		/obj/item/fish_eggs/crayfish = 50,
		/obj/item/fish_eggs/shrimp = 5,
		/obj/item/toy/pet_rock = 100,
		/obj/item/pet_carrier/normal = 250,
		/obj/item/pet_carrier = 100,
		/obj/item/reagent_containers/food/condiment/animalfeed = 100,
		/obj/item/reagent_containers/glass/pet_bowl = 50,
	)

	contraband = list(/obj/item/fish_eggs/babycarp = 5)
	premium = list(/obj/item/toy/pet_rock/fred = 1, /obj/item/toy/pet_rock/roxie = 1)
	refill_canister = /obj/item/vending_refill/crittercare

/obj/machinery/vending/crittercare/free
	prices = list()

/obj/machinery/vending/pai
	name = "\improper RoboFriends"
	desc = "Wonderful vendor of PAI friends"

	icon_state = "paivend_off"
	panel_overlay = "paivend_panel"
	screen_overlay = "paivend"
	lightmask_overlay = "paivend_lightmask"
	broken_overlay = "paivend_broken"
	broken_lightmask_overlay = "paivend_broken_lightmask"

	ads_list = list("А вы любите нас?","Мы твои друзья!","Эта покупка войдет в историю","Я ПАИ простой, купишь меня, а я тебе друга!","Спасибо за покупку.")
	resistance_flags = FIRE_PROOF
	products = list(
		/obj/item/paicard = 10,
		/obj/item/pai_cartridge/female = 10,
		/obj/item/pai_cartridge/doorjack = 5,
		/obj/item/pai_cartridge/memory = 5,
		/obj/item/pai_cartridge/reset = 5,
		/obj/item/robot_parts/l_arm = 1,
		/obj/item/robot_parts/r_arm = 1
	)
	contraband = list(
		/obj/item/pai_cartridge/syndi_emote = 1,
		/obj/item/pai_cartridge/snake = 1
	)
	prices = list(
		/obj/item/paicard = 200,
		/obj/item/robot_parts/l_arm = 550,
		/obj/item/robot_parts/r_arm = 550,
		/obj/item/pai_cartridge/female = 150,
		/obj/item/pai_cartridge/doorjack = 400,
		/obj/item/pai_cartridge/syndi_emote = 650,
		/obj/item/pai_cartridge/snake = 600,
		/obj/item/pai_cartridge/reset = 500,
		/obj/item/pai_cartridge/memory = 350
	)
	refill_canister = /obj/item/vending_refill/pai

/obj/machinery/vending/centdrobe
	name = "\improper MagiVend"
	desc = "A magic vending machine."

	icon_state = "magivend_off"
	panel_overlay = "magivend_panel"
	screen_overlay = "magivend"
	lightmask_overlay = "magivend_lightmask"
	broken_overlay = "magivend_broken"
	broken_lightmask_overlay = "magivend_broken_lightmask"

	slogan_list = list("Sling spells the proper way with MagiVend!","Be your own Houdini! Use MagiVend!")
	vend_delay = 15
	vend_reply = "Have an enchanted evening!"
	ads_list = list("FJKLFJSD","AJKFLBJAKL","1234 LOONIES LOL!",">MFW","Kill them fuckers!","GET DAT FUKKEN DISK","HONK!","EI NATH","Destroy the station!","Admin conspiracies since forever!","Space-time bending hardware!")
	products = list(/obj/item/clothing/under/rank/centcom_green/intern = 10,
					/obj/item/clothing/under/rank/centcom_green/official = 10,
					/obj/item/clothing/under/rank/centcom_green/commander = 10,
					/obj/item/clothing/under/rank/centcom_green/officer = 10,
					/obj/item/clothing/under/rank/centcom_green/officer_skirt = 10,
					/obj/item/clothing/under/rank/centcom_green/commander_skirt = 10,
					/obj/item/clothing/under/rank/centcom_green/military = 10,
					/obj/item/clothing/under/rank/centcom_green/military/eng = 10,
					/obj/item/clothing/head/caphat/centcom_green/cap = 10,
					/obj/item/clothing/head/soft/centcom_green_intern = 10,
					/obj/item/clothing/head/helmet/space/plasmaman/centcomm_green_commander = 5,
					/obj/item/clothing/head/helmet/space/plasmaman/centcomm_green_intern = 5,
					/obj/item/clothing/head/helmet/space/plasmaman/centcomm_green_official = 5,
					/obj/item/clothing/suit/wizrobe/marisa = 5,
					/obj/item/clothing/shoes/sandal/marisa = 5,
					/obj/item/twohanded/staff/broom = 5,
					/obj/item/clothing/head/wizard/black = 5,
					/obj/item/clothing/head/wizard/fluff/dreamy = 5,
					/obj/item/twohanded/staff = 10,
					/obj/item/clothing/head/helmet/space/plasmaman/wizard = 5,
					/obj/item/clothing/under/plasmaman/wizard = 5,
					/obj/item/tank/internals/plasmaman/belt/full = 5,
					/obj/item/clothing/mask/breath = 5,
					/obj/item/tank/internals/emergency_oxygen/double/vox = 5,
					/obj/item/clothing/mask/breath/vox = 5)
	contraband = list(/obj/item/reagent_containers/glass/bottle/wizarditis = 1)
	armor = list(melee = 100, bullet = 100, laser = 100, energy = 100, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 50)
	resistance_flags = FIRE_PROOF
	tiltable = FALSE

