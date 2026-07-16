/datum/outfit/deathmatch_loadout //remember that fun > balance
	name = ""
	shoes = /obj/item/clothing/shoes/color/black // im not doing this on all of them
	/// Name shown in the UI
	var/display_name = ""
	/// Description shown in the UI
	var/desc = ":KILL:"
	/// If defined, using this outfit sets the targets species to it
	var/datum/species/species_override
	/// This outfit will grant these spells if applied
	var/list/spells_to_add = list()
	/// This outfit will grant these mutations if applied
	var/list/mutations_to_add = list()


/datum/outfit/deathmatch_loadout/naked
	name = "Deathmatch: Naked"
	display_name = "Без одежды"
	desc = "Голые космонавтики жаждут устроить кровавую баню."
	shoes = null

/datum/outfit/deathmatch_loadout/assistant
	name = "Deathmatch: Assistant"
	display_name = "Ассистент"
	desc = "Классический ассистент — серый комбинезон и туллбокс в руках."

	l_hand = /obj/item/storage/toolbox/mechanical
	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/storage/backpack
	belt = /obj/item/flashlight

	backpack_contents = list(
		/obj/item/storage/box/survival = 1,
	)

/datum/outfit/deathmatch_loadout/assistant/weaponless
	name = "Deathmatch: Assistant (Weaponless)"
	display_name = "Ассистент (без оружия)"
	desc = "Что есть ассистент без своего туллбокса? Правильно, ничто."
	l_hand = null

/datum/outfit/deathmatch_loadout/operative
	name = "Deathmatch: Operative"
	display_name = "Оперативник (без оружия)"
	desc = "Оперативник синдиката без оружия."

	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/syndicate

/datum/outfit/deathmatch_loadout/operative/ranged
	name = "Deathmatch: Ranged Operative"
	display_name = "Оперативник (Дальний бой)"
	desc = "Оперативник синдиката с ножом и пистолетом."

	l_hand = /obj/item/gun/projectile/automatic/pistol
	l_pocket = /obj/item/kitchen/knife/combat
	backpack_contents = list(/obj/item/ammo_box/magazine/m10mm = 5)

/datum/outfit/deathmatch_loadout/operative/melee
	name = "Deathmatch: Melee Operative"
	display_name = "Оперативник (Ближний бой)"
	desc = "Оперативник синдиката с несколькими ножами."

	suit = /obj/item/clothing/suit/armor/vest
	head = /obj/item/clothing/head/helmet
	backpack_contents = list(/obj/item/kitchen/knife/combat/throwing = 6)
	l_hand = /obj/item/kitchen/knife/combat
	l_pocket = /obj/item/kitchen/knife/combat/throwing

/datum/outfit/deathmatch_loadout/securing_sec
	name = "Deathmatch: Security Officer"
	display_name = "Офицер СБ"
	desc = "Офицер службы безопасности НТ."

	uniform = /datum/outfit/job/officer::uniform
	suit = /datum/outfit/job/officer::suit
	suit_store = /datum/outfit/job/officer::suit_store
	belt = /datum/outfit/job/officer::belt
	gloves = /datum/outfit/job/officer::gloves
	head = /datum/outfit/job/officer::head
	shoes = /datum/outfit/job/officer::shoes
	l_pocket = /obj/item/flashlight/seclite
	l_hand = /obj/item/gun/energy/disabler
	r_pocket = /obj/item/kitchen/knife/combat/survival
	back = /datum/outfit/job/officer::backpack

/datum/outfit/deathmatch_loadout/assistant/instagib
	name = "DM: Instagib"
	display_name = "Инстагиб-пушка"
	desc = "Ассистент с инстагиб пушкой"

	l_hand = /obj/item/gun/energy/laser/instakill

/datum/outfit/deathmatch_loadout/operative/sniper
	name = "Deathmatch: Sniper"
	display_name = "Снайпер"
	desc = "Снайперская винтовка и несколько магазинов к ней."
	backpack_contents = list(
		/obj/item/ammo_box/magazine/sniper_rounds = 3,
	)
	glasses = /obj/item/clothing/glasses/thermal
	uniform = /obj/item/clothing/under/syndicate/sniper

	l_pocket = /obj/item/kitchen/knife/combat
	l_hand = /obj/item/gun/projectile/automatic/sniper_rifle/syndicate


/datum/outfit/deathmatch_loadout/head_of_security
	name = "Deathmatch: Head of Security"
	display_name = "ГСБ"
	desc = "Офицер с уникой. Что же может пойти не так?"

	head = /datum/outfit/job/hos::head
	uniform = /obj/item/clothing/under/rank/head_of_security/alt
	shoes = /datum/outfit/job/hos::shoes
	glasses = /datum/outfit/job/hos::glasses
	suit = /obj/item/clothing/suit/armor/hos
	gloves = /datum/outfit/job/hos::gloves
	r_hand = /obj/item/gun/projectile/revolver/mateba
	l_hand = /obj/item/shield/riot/tele
	l_pocket = /obj/item/ammo_box/speedloader/a357
	r_pocket = /obj/item/ammo_box/speedloader/a357

/datum/outfit/deathmatch_loadout/captain
	name = "Deathmatch: Captain"
	display_name = "Капитан"
	desc = "Обнажите вашу рапиру и покажите отродью, на что вы способны."

	head = /obj/item/clothing/head/caphat/parade
	uniform = /obj/item/clothing/under/rank/captain
	suit = /obj/item/clothing/suit/armor/vest/capcarapace
	suit_store = /obj/item/gun/energy/laser
	shoes = /obj/item/clothing/shoes/laceup
	neck = /obj/item/bedsheet/captain
	glasses = /obj/item/clothing/glasses/sunglasses
	gloves = /obj/item/clothing/gloves/color/captain
	belt = /obj/item/storage/belt/rapier
	l_hand = /obj/item/gun/energy/laser/captain
	l_pocket = /obj/item/melee/baton/telescopic

/datum/outfit/deathmatch_loadout/nukie
	name = "Deathmatch: Nuclear Operative"
	display_name = "Ядерный оперативник"
	desc = "Снаряжение, выдаваемое ядерному оперативнику. Ваша задача проста."

	uniform = /obj/item/clothing/under/syndicate
	back = /obj/item/mod/control/pre_equipped/nuclear
	r_hand = /obj/item/gun/projectile/automatic/shotgun/bulldog
	belt = /obj/item/gun/projectile/automatic/pistol
	l_pocket = /obj/item/grenade/syndieminibomb

	backpack_contents = list(
		/obj/item/ammo_box/m10mm = 2,
		/obj/item/ammo_box/magazine/m12g/slug = 5,
	)


/datum/outfit/deathmatch_loadout/tider
	name = "Deathmatch: Tider"
	display_name = "Грейтайд"
	desc = "Глава среди ассистентов"

	back = /obj/item/melee/baton/security/cattleprod
	r_hand = /obj/item/twohanded/fireaxe
	uniform = /obj/item/clothing/under/color/grey
	mask = /obj/item/clothing/mask/gas
	gloves = /obj/item/clothing/gloves/color/yellow/fake
	r_pocket = /obj/item/stock_parts/cell/high
	belt = /obj/item/storage/belt/utility/full

// TODO:
// ALL BATTLERS
// ALL SPECIES
// ALL WIZARDS
// ALL CULTISTS
