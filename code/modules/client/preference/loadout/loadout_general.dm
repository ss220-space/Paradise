/datum/gear/dice
	index_name = "a d20"
	path = /obj/item/dice/d20

/datum/gear/uplift
	index_name = "a pack of Uplifts"
	path = /obj/item/storage/fancy/cigarettes/cigpack_uplift

/datum/gear/robust
	index_name = "a pack of Robusts"
	path = /obj/item/storage/fancy/cigarettes/cigpack_robust

/datum/gear/carp
	index_name = "a pack of Carps"
	path = /obj/item/storage/fancy/cigarettes/cigpack_carp

/datum/gear/midori
	index_name = "a pack of Midoris"
	path = /obj/item/storage/fancy/cigarettes/cigpack_midori

/datum/gear/smokingpipe
	index_name = "smoking pipe"
	path = /obj/item/clothing/mask/cigarette/pipe
	cost = 2

/datum/gear/robustpipe
	index_name = "robust smoking pipe"
	path = /obj/item/clothing/mask/cigarette/pipe/oldpipe
	cost = 2

/datum/gear/lighter
	index_name = "a cheap lighter"
	path = /obj/item/lighter

/datum/gear/earrings
	index_name = "earrings, select"
	display_name = "earrings"
	path = /obj/item/clothing/ears/earrings

/datum/gear/earrings/New()
	..()
	var/list/earrings = list("silver" = /obj/item/clothing/ears/earrings/silver,
								 "gold" = /obj/item/clothing/ears/earrings
								 )
	gear_tweaks += new /datum/gear_tweak/path(earrings, src)

/datum/gear/matches
	index_name = "a box of matches"
	path = /obj/item/storage/box/matches

/datum/gear/candlebox
	index_name = "a box candles"
	description = "For setting the mood or for occult rituals."
	path = /obj/item/storage/fancy/candle_box/full

/datum/gear/camera
	index_name = "a camera"
	path = /obj/item/camera

/datum/gear/sechud
	index_name = "a classic security HUD"
	path = /obj/item/clothing/glasses/hud/security
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_OFFICER, JOB_TITLE_PILOT, JOB_TITLE_JUDGE)

/datum/gear/read_only_sechud
	index_name = "a classic security HUD (read-only)"
	path = /obj/item/clothing/glasses/hud/security/read_only
	allowed_roles = list(JOB_TITLE_LAWYER)

/datum/gear/cryaonbox
	index_name = "a box of crayons"
	path = /obj/item/storage/fancy/crayons

/datum/gear/cane
	index_name = "a walking cane"
	path = /obj/item/cane

/datum/gear/cards
	index_name = "a deck of standard cards"
	path = /obj/item/deck/cards

/datum/gear/doublecards
	index_name = "a double deck of standard cards"
	path = /obj/item/deck/cards/doublecards

/datum/gear/tarot
	index_name = "a deck of tarot cards"
	path = /obj/item/deck/tarot

/datum/gear/headphones
	index_name = "a pair of headphones"
	path = /obj/item/clothing/ears/headphones

/datum/gear/fannypack
	index_name = "a fannypack"
	path = /obj/item/storage/belt/fannypack

/datum/gear/wallet
	index_name = "a wallet(leather)"
	path = /obj/item/storage/wallet

/datum/gear/wallet/color
	index_name = "a wallet, select"
	display_name = "a wallet"
	path = /obj/item/storage/wallet/color/blue

/datum/gear/wallet/color/New()
	..()
	var/list/wallets = list("blue" = /obj/item/storage/wallet/color/blue,
							"red" = /obj/item/storage/wallet/color/red,
							"yellow" = /obj/item/storage/wallet/color/yellow,
							"green" = /obj/item/storage/wallet/color/green,
							"pink" = /obj/item/storage/wallet/color/pink,
							"black" = /obj/item/storage/wallet/color/black,
							)
	gear_tweaks += new /datum/gear_tweak/path(wallets, src)

/datum/gear/bandana
	index_name = "bandana, select"
	display_name = "bandana"
	path = /obj/item/clothing/mask/bandana/black

/datum/gear/bandana/New()
	..()
	var/list/bands = list("black" = /obj/item/clothing/mask/bandana/black,
							"red" = /obj/item/clothing/mask/bandana/red,
							"gold" = /obj/item/clothing/mask/bandana/gold,
							"green" = /obj/item/clothing/mask/bandana/green,
							"skull" = /obj/item/clothing/mask/bandana/skull,
							"purple" = /obj/item/clothing/mask/bandana/purple,
							"orange" = /obj/item/clothing/mask/bandana/orange,
							"blue" = /obj/item/clothing/mask/bandana/blue,
							)
	gear_tweaks += new /datum/gear_tweak/path(bands, src)

/datum/gear/piano_synth
	index_name ="synthesizer"
	path = /obj/item/instrument/piano_synth
	cost = 2

/datum/gear/tts
	index_name ="TTS device"
	path = /obj/item/ttsdevice

/datum/gear/lipstick
	index_name = "lipstick, select"
	display_name = "lipstick"
	path = /obj/item/lipstick

/datum/gear/lipstick/New()
	..()
	var/list/lips = list(/obj/item/lipstick,
						 /obj/item/lipstick/black,
						 /obj/item/lipstick/jade,
						 /obj/item/lipstick/purple,
						 /obj/item/lipstick/blue,
						 /obj/item/lipstick/lime,)
	gear_tweaks += new /datum/gear_tweak/path(lips, src, TRUE)


//////////////////////
//		Mugs		//
//////////////////////

/datum/gear/mug
	index_name = "random coffee mug"
	description = "A randomly colored coffee mug. You'll need to supply your own beverage though."
	path = /obj/item/reagent_containers/food/drinks/mug

/datum/gear/novelty_mug
	index_name = "novelty coffee mug"
	description = "A random novelty coffee mug. You'll need to supply your own beverage though."
	path = /obj/item/reagent_containers/food/drinks/mug/novelty
	cost = 2

/datum/gear/mug/flask
	index_name = "flask"
	description = "A flask for drink transportation. You'll need to supply your own beverage though."
	path = /obj/item/reagent_containers/food/drinks/flask/barflask

/datum/gear/mug/department
	subtype_path = /datum/gear/mug/department
	subtype_cost_overlap = FALSE

/datum/gear/mug/department/eng
	index_name = "engineer coffee mug"
	description = "An engineer's coffee mug, emblazoned in the colors of the Engineering department."
	allowed_roles = list(JOB_TITLE_CHIEF, JOB_TITLE_ENGINEER, JOB_TITLE_ENGINEER_TRAINEE, JOB_TITLE_MECHANIC, JOB_TITLE_ATMOSTECH)
	path = /obj/item/reagent_containers/food/drinks/mug/eng

/datum/gear/mug/department/med
	index_name = "doctor coffee mug"
	description = "A doctor's coffee mug, emblazoned in the colors of the Medical department."
	allowed_roles = list(JOB_TITLE_CMO, JOB_TITLE_DOCTOR, JOB_TITLE_MINING_MEDIC, JOB_TITLE_INTERN, JOB_TITLE_CHEMIST, JOB_TITLE_PSYCHIATRIST, JOB_TITLE_PARAMEDIC, JOB_TITLE_VIROLOGIST, JOB_TITLE_CORONER)
	path = /obj/item/reagent_containers/food/drinks/mug/med

/datum/gear/mug/department/sci
	index_name = "scientist coffee mug"
	description = "A scientist's coffee mug, emblazoned in the colors of the Science department."
	allowed_roles = list(JOB_TITLE_RD, JOB_TITLE_SCIENTIST, JOB_TITLE_SCIENTIST_STUDENT, JOB_TITLE_ROBOTICIST)
	path = /obj/item/reagent_containers/food/drinks/mug/sci

/datum/gear/mug/department/sec
	index_name = "officer coffee mug"
	description = "An officer's coffee mug, emblazoned in the colors of the Security department."
	allowed_roles = list(JOB_TITLE_HOS, JOB_TITLE_WARDEN, JOB_TITLE_DETECTIVE, JOB_TITLE_OFFICER, JOB_TITLE_BRIGDOC, JOB_TITLE_PILOT, JOB_TITLE_LAWYER)
	path = /obj/item/reagent_containers/food/drinks/mug/sec

/datum/gear/mug/department/serv
	index_name = "crewmember coffee mug"
	description = "A crewmember's coffee mug, emblazoned in the colors of the Service department."
	path = /obj/item/reagent_containers/food/drinks/mug/serv
