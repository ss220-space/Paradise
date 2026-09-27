/datum/lazy_template/virtual_domain/pipedream
	name = "Фабрика мусоропроводов"
	cost = BITRUNNER_COST_LOW
	desc = "Заброшенная и кем-то обжитая фабрика по производству труб мусоропровода."
	difficulty = BITRUNNER_DIFFICULTY_LOW
	completion_loot = list(/obj/item/stack/cable_coil = 1)
	help_text = "Ещё недавно здесь кипела работа. Смена ушла в спешке, и с тех пор производство буквально в мусорке. Что-то разнесло это место — вот только что?"
	is_modular = TRUE
	key = LAZY_TEMPLATE_KEY_BITRUNNING_PIPEDREAM
	map_name = "pipedream"
	mob_modules = list(
		/datum/modular_mob_segment/hivebots,
		/datum/modular_mob_segment/hivebots_strong,
	)
	reward_points = BITRUNNER_REWARD_LOW

/datum/outfit/factory
	name = "Factory Worker"
	uniform = /obj/item/clothing/under/rank/cargotech
	suit = /obj/item/clothing/suit/storage/hazardvest
	gloves = /obj/item/clothing/gloves/color/black
	head = /obj/item/clothing/head/soft/yellow
	shoes = /obj/item/clothing/shoes/workboots
	l_pocket = /obj/item/flashlight/seclite

/datum/outfit/factory/guard
	name = "Factory Guard"
	uniform = /obj/item/clothing/under/rank/security
	suit = /obj/item/clothing/suit/armor/vest/security
	head = /obj/item/clothing/head/soft/sec
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/restraints/handcuffs
	r_pocket = /obj/item/flash

/datum/outfit/factory/qm
	name = "Factory Quartermaster"
	uniform = /obj/item/clothing/under/rank/cargo
	suit = null
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/melee/baton/telescopic
	r_pocket = /obj/item/stamp/qm

/obj/effect/mob_spawn/human/corpse/factory
	name = "Factory Worker"
	mob_name = "Factory Worker"
	id_job = "Factory Worker"
	id_access_list = list(ACCESS_MAILSORTING, ACCESS_CARGO)
	outfit = /datum/outfit/factory

/obj/effect/mob_spawn/human/corpse/factory/guard
	name = "Factory Guard"
	mob_name = "Factory Guard"
	id_job = "Factory Guard"
	outfit = /datum/outfit/factory/guard

/obj/effect/mob_spawn/human/corpse/factory/qm
	name = "Factory Quartermaster"
	mob_name = "Factory Quartermaster"
	id_job = "Factory Quartermaster"
	id_access_list = list(ACCESS_MAILSORTING, ACCESS_CARGO, ACCESS_QM)
	outfit = /datum/outfit/factory/qm
