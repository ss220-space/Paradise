/datum/gear/plushie
	sort_category = "Игрушки"
	subtype_path = /datum/gear/plushie

/datum/gear/plushie/balloon
	index_name = "a balloon"
	path = /obj/item/toy/balloon

/datum/gear/plushie/rock
	index_name = "a pet rock"
	path = /obj/item/toy/pet_rock

/datum/gear/plushie/foxes
	index_name = "Fox plushie, select"
	display_name = "Плюшевая лиса"
	path = /obj/item/toy/plushie/fox

/datum/gear/plushie/foxes/New()
	..()
	var/list/foxes = list(
		/obj/item/toy/plushie/fox,
		/obj/item/toy/plushie/fox/black,
		/obj/item/toy/plushie/fox/marble,
		/obj/item/toy/plushie/fox/blue,
		/obj/item/toy/plushie/fox/coffee,
		/obj/item/toy/plushie/fox/pink,
		/obj/item/toy/plushie/fox/purple,
		/obj/item/toy/plushie/fox/crimson,
		/obj/item/toy/plushie/fox/orange,
	)
	gear_tweaks += new /datum/gear_tweak/path(foxes, src, TRUE)

/datum/gear/plushie/cats
	index_name = "a black cat plushie"
	display_name = "Плюшевый кот"
	path = /obj/item/toy/plushie/cat

/datum/gear/plushie/cats/New()
	..()
	var/list/cats = list(
		/obj/item/toy/plushie/cat,
		/obj/item/toy/plushie/cat/grey,
		/obj/item/toy/plushie/cat/white,
		/obj/item/toy/plushie/cat/orange,
		/obj/item/toy/plushie/cat/siamese,
		/obj/item/toy/plushie/cat/tabby,
		/obj/item/toy/plushie/cat/tuxedo,
	)
	gear_tweaks += new /datum/gear_tweak/path(cats, src, TRUE)

/datum/gear/plushie/voxplushie
	index_name = "a vox plushie"
	path = /obj/item/toy/plushie/voxplushie

/datum/gear/plushie/lizardplushie
	index_name = "a lizard plushie"
	path = /obj/item/toy/plushie/lizard_plushie

/datum/gear/plushie/snakeplushie
	index_name = "a snake plushie"
	path = /obj/item/toy/plushie/snakeplushie

/datum/gear/plushie/deerplushie
	index_name = "a deer plushie"
	path = /obj/item/toy/plushie/deer

/datum/gear/plushie/slimeplushie
	index_name = "a slime plushie"
	path = /obj/item/toy/plushie/slimeplushie

/datum/gear/plushie/fennecplushie
	index_name = "a fennec plushie"
	path = /obj/item/toy/plushie/fennecplushie

/datum/gear/plushie/carps
	index_name = "Carp plushie, select"
	display_name = "Плюшевый карп"
	path = /obj/item/toy/plushie/carp

/datum/gear/plushie/carps/New()
	..()
	var/list/carps = list(
		/obj/item/toy/plushie/carp,
		/obj/item/toy/plushie/carp/ice,
		/obj/item/toy/plushie/carp/silent,
		/obj/item/toy/plushie/carp/electric,
		/obj/item/toy/plushie/carp/gold,
		/obj/item/toy/plushie/carp/toxin,
		/obj/item/toy/plushie/carp/dragon,
		/obj/item/toy/plushie/carp/pink,
		/obj/item/toy/plushie/carp/candy,
		/obj/item/toy/plushie/carp/nebula,
		/obj/item/toy/plushie/carp/void,
	)
	gear_tweaks += new /datum/gear_tweak/path(carps, src, TRUE)

/datum/gear/plushie/nianplushie
	index_name = "Nian plushie"
	path = /obj/item/toy/plushie/nianplushie

/datum/gear/plushie/beeplushie
	index_name = "Bee plushie"
	path = /obj/item/toy/plushie/nianplushie/beeplushie

/datum/gear/plushie/bubblegumplushie
	index_name = "Bubblegum plushie"
	path = /obj/item/toy/plushie/bubblegumplushie

/datum/gear/plushie/greyplushie
	index_name = "Grey Plushie"
	path = /obj/item/toy/plushie/greyplushie

/datum/gear/plushie/ipcplushie
	index_name = "IPC Plushie"
	path = /obj/item/toy/plushie/ipcplushie

/datum/gear/plushie/plasmamanplushie
	index_name = "Plasmaman Plushie, select"
	display_name = "Плюшевый плазмолюд"
	path = /obj/item/toy/plushie/plasmamanplushie

/datum/gear/plushie/plasmamanplushie/New()
	..()
	var/list/plasmamans = list(
		/obj/item/toy/plushie/plasmamanplushie,
		/obj/item/toy/plushie/plasmamanplushie/standart/sindie,
		/obj/item/toy/plushie/plasmamanplushie/standart/doctor,
		/obj/item/toy/plushie/plasmamanplushie/standart/brigmed,
		/obj/item/toy/plushie/plasmamanplushie/standart/chemist,
		/obj/item/toy/plushie/plasmamanplushie/standart/scientist,
		/obj/item/toy/plushie/plasmamanplushie/standart/engineer,
		/obj/item/toy/plushie/plasmamanplushie/standart/atmostech,
		/obj/item/toy/plushie/plasmamanplushie/standart/officer,
		/obj/item/toy/plushie/plasmamanplushie/standart/captain,
		/obj/item/toy/plushie/plasmamanplushie/standart/ntr,
		/obj/item/toy/plushie/plasmamanplushie/standart/miner,
	)
	gear_tweaks += new /datum/gear_tweak/path(plasmamans, src, TRUE)

/datum/gear/plushie/shardplushie
	index_name = "Shard Plushie"
	path = /obj/item/toy/plushie/shardplushie

/datum/gear/plushie/sharkplushie
	index_name = "Shark Plushie"
	path = /obj/item/toy/plushie/blahaj

/datum/gear/plushie/akulaplushie
	index_name = "Akula Plushie"
	path = /obj/item/toy/plushie/blahaj/twohanded
	cost = 2

/datum/gear/plushie/hampter
	index_name = "Hampter"
	path = /obj/item/toy/plushie/hampter

/datum/gear/plushie/hampter/New()
	..()
	var/list/hampters = list(
		/obj/item/toy/plushie/hampter,
		/obj/item/toy/plushie/hampter/asisstant,
		/obj/item/toy/plushie/hampter/security,
		/obj/item/toy/plushie/hampter/medic,
		/obj/item/toy/plushie/hampter/janitor,
	)
	gear_tweaks += new /datum/gear_tweak/path(hampters, src, TRUE)
