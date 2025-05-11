/datum/gear/plushie
	sort_category = "Plushie"
	subtype_path = /datum/gear/plushie
	cost = 1

/datum/gear/plushie/rock
	index_name = "a pet rock"
	path = /obj/item/toy/pet_rock

/datum/gear/plushie/redfoxplushie
	index_name = "a red fox plushie"
	path = /obj/item/toy/plushie/red_fox

/datum/gear/plushie/blackcatplushie
	index_name = "a black cat plushie"
	path = /obj/item/toy/plushie/black_cat

/datum/gear/plushie/voxplushie
	index_name = "a vox plushie"
	path = /obj/item/toy/plushie/voxplushie

/datum/gear/plushie/lizardplushie
	index_name = "a lizard plushie"
	path = /obj/item/toy/plushie/lizardplushie

/datum/gear/plushie/deerplushie
	index_name = "a deer plushie"
	path = /obj/item/toy/plushie/deer

/datum/gear/plushie/carpplushie
	index_name = "a carp plushie"
	path = /obj/item/toy/carpplushie

/datum/gear/plushie/nianplushie
	index_name = "Nian plushie"
	path = /obj/item/toy/plushie/nianplushie

/datum/gear/plushie/bubblegumplushie
	index_name = "Bubblegum plushie"
	path = /obj/item/toy/plushie/bubblegumplushie

/datum/gear/plushie/greyplushie
	index_name = "Grey Plushie"
	path = /obj/item/toy/plushie/greyplushie

/datum/gear/plushie/plasmamanplushie
	index_name = "Plasmaman Plushie, select"
	display_name = "Plasmaman Plushie"
	path = /obj/item/toy/plushie/plasmamanplushie

/datum/gear/plushie/plasmamanplushie/New()
	..()
	var/list/plasmamans = list(/obj/item/toy/plushie/plasmamanplushie,
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

/datum/gear/plushie/akulaplushie
	index_name = "Akula Plushie"
	path = /obj/item/toy/plushie/blahaj/twohanded
	cost = 2

/datum/gear/plushie/hampter
	index_name = "Hampter"
	path = /obj/item/toy/plushie/hampter
	cost = 1

/datum/gear/plushie/hampter_assistant
	index_name = "Hampter, Assitant"
	path = /obj/item/toy/plushie/hampter/asisstant
	cost = 1

/datum/gear/plushie/hampter_security
	index_name = "Hampter, Security"
	path = /obj/item/toy/plushie/hampter/security
	cost = 1

/datum/gear/plushie/hampter_medic
	index_name = "Hampter, Doctor"
	path = /obj/item/toy/plushie/hampter/medic
	cost = 1

/datum/gear/plushie/hampter_janitor
	index_name = "Hampter, Janitor"
	path = /obj/item/toy/plushie/hampter/janitor
	cost = 1

/datum/gear/plushie/hampter_captain
	index_name = "Hampter, Captain"
	path = /obj/item/toy/plushie/hampter/captain
	cost = 1

/datum/gear/plushie/hampter_old_captain
	index_name = "Hampter, Old Captain"
	path = /obj/item/toy/plushie/hampter/captain/old
	cost = 1

/datum/gear/plushie/hampter_syndi
	index_name = "Hampter, Syndi"
	path = /obj/item/toy/plushie/hampter/syndi
	cost = 1

/datum/gear/plushie/hampter_death_squad
	index_name = "Hampter, Grandpa"
	path = /obj/item/toy/plushie/hampter/death_squad
	cost = 1

/datum/gear/plushie/hampter_ert_squad
	index_name = "Hampter, ERT"
	path = /obj/item/toy/plushie/hampter/ert_squad
	cost = 1

/datum/gear/plushie/blahaj
	index_name = "Shark Plushie"
	path = /obj/item/toy/plushie/blahaj
	cost = 1


