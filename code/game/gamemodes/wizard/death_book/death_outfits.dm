/datum/outfit/radial_outfit
	var/icon/icon_outfit = null
	var/icon_state = ""
	var/descr = "Если вы видите это значит что-то пошло не так"

/datum/outfit/radial_outfit/proc/get_image()
	return image(icon = icon_outfit, icon_state = icon_state)

//castom check
/datum/outfit/radial_outfit/proc/can_choise(mob/user)
	return TRUE

/datum/outfit/radial_outfit/death_book
	icon_outfit = 'icons/obj/death_book.dmi'
	calc_used_slots = TRUE
	var/cooldown = 10 MINUTES
	var/time_action = 3 MINUTES
	var/message_to_chat = "Ты не должен это видеть! Кодер ишшуй"
	var/force_unequip_slots = 0

/datum/outfit/radial_outfit/death_book/executioner
	name = "Палач"
	icon_state = "executioner"
	message_to_chat = "Вы читаете главу о кровавой распре, и это пробуждает в вас жажду крови... "
	descr = "Сочетает в себе возможность навязать врагу ближний бой и так же быстро его закончить с помощью костяного вооружения и артефактного крюка."
	
	head = /obj/item/clothing/head/helmet/skull
	mask = /obj/item/clothing/mask/gas/ghostface/true
	suit_store = /obj/item/twohanded/fireaxe/boneaxe/guillotine/sharped
	belt = /obj/item/gun/magic/hook
	suit = /obj/item/clothing/suit/armor/bone
	gloves = /obj/item/clothing/gloves/bracer
	shoes = /obj/item/clothing/shoes/combat
	uniform = /obj/item/clothing/under/color/grey
	back = /obj/item/storage/backpack/cultpack
	backpack_contents = list(/obj/item/kitchen/knife/butcher/sharped = 1)

/datum/outfit/radial_outfit/death_book/bandit
	name = "Бандит"
	icon_state = "bandit"
	message_to_chat = "Вы читаете главу о бандитских похождениях, и заражаетесь духом авантюризма."
	descr = "Предоставляет небольшую защиту, но большой урон: револьвер 357 калибра никогда не подводил."

	head = /obj/item/clothing/head/helmet
	suit = /obj/item/clothing/suit/armor/bulletproof
	mask = /obj/item/clothing/mask/bandana/black
	belt = /obj/item/kitchen/knife/combat
	uniform = /obj/item/clothing/under/syndicate/tacticool
	accessories = list(/obj/item/clothing/accessory/holster)
	gloves = /obj/item/clothing/gloves/color/black
	shoes = /obj/item/clothing/shoes
	backpack_contents = list(/obj/item/ammo_box/speedloader/a357 = 2, /obj/item/gun/projectile/revolver = 1)

/datum/outfit/radial_outfit/death_book/killer
	name = "Убийца"
	icon_state = "hitman"
	message_to_chat = "Вы читаете главу о невероятном охотнике за головами, и жаждите повторить его успех."
	descr = "Позволяет вам замаскироваться среди экипажа, и проводить быстрые и смертельные устранения. Стечкин поможет скрыться с места преступления в случае вашего обнаружения."

	uniform = /obj/item/clothing/under/chameleon
	suit = /obj/item/clothing/suit/chameleon
	gloves = /obj/item/clothing/gloves/chameleon
	shoes = /obj/item/clothing/shoes/chameleon
	glasses = /obj/item/clothing/glasses/chameleon
	head = /obj/item/clothing/head/chameleon
	mask = /obj/item/clothing/mask/chameleon
	back =  /obj/item/storage/backpack/chameleon
	r_ear = /obj/item/radio/headset/chameleon
	neck = /obj/item/clothing/neck/chameleon
	pda =  /obj/item/pda/chameleon

	backpack_contents = list(
		/obj/item/stamp/chameleon = 1,
	 	/obj/item/gun/projectile/automatic/pistol = 1,
	  	/obj/item/ammo_box/magazine/m10mm = 3,
	  	/obj/item/pen/fakesign = 1,
		/obj/item/storage/box/syndie_kit/knives_kit = 1,
		/obj/item/flashlight/emp = 1,
		/obj/item/flash/cameraflash = 1,
		/obj/item/twohanded/garrote = 1,
		/obj/item/card/id/syndicate = 1
	 )
	
/datum/outfit/radial_outfit/death_book/crusher
	name = "Разрушитель"
	icon_state = "crusher"
	message_to_chat = "Вы читаете главу о человеке, что разрушил мир – что навевает вам желание начинать сжигать всё вокруг."
	descr = "Обрушьте всю вашу ярость с этим набором, залив станцию в огне. А в пекле вашу шкурку защитит огнеупорный скафандр."

	uniform = /obj/item/clothing/under/syndicate/tacticool
	suit = /obj/item/clothing/suit/space/syndicate/phantom
	head = /obj/item/clothing/head/helmet/space/syndicate/phantom
	back = /obj/item/storage/backpack/syndicate
	belt = /obj/item/storage/belt/grenade/full
	suit_store = /obj/item/tank/internals/oxygen/red
	mask = /obj/item/clothing/mask/gas/syndicate
	backpack_contents = list(
		/obj/item/tank/internals/plasma = 5,
		/obj/item/pickaxe/drill/jackhammer/phantom = 1,
	  	/obj/item/grenade/clusterbuster/inferno = 1,
		/obj/item/flamethrower/full/tank = 1
		)

/datum/outfit/radial_outfit/death_book/crusher/post_equip(mob/living/carbon/human/H, visualsOnly)
	if(H.dna.species.name == SPECIES_VOX)
		var/obj/item/tank/internals/oxygen/red/prom = H.s_store
		prom.air_contents.oxygen = 0
		prom.air_contents.nitrogen = (6 * ONE_ATMOSPHERE) * prom.volume / (R_IDEAL_GAS_EQUATION * T20C)

/datum/outfit/radial_outfit/death_book/plague_inc
	name = "Вестник чумы"
	icon_state = "plague_inc"
	message_to_chat = "Вы читаете главу о мерзавце, превратившем свой мир в гниющее логово чудовищ – и это задевает ваше эго."
	descr = "Заставьте экипаж почувствовать ужас, порождая страшнейших тварей на их трупах. А для личной безопасности используйте энергоарбалет и различные химикаты."

	force_unequip_slots = ITEM_SLOT_HEAD
	uniform = /obj/item/clothing/under/syndicate/blackops
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie/armoured
	mask = /obj/item/clothing/mask/gas/plaguedoctor/armoured
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	backpack_contents = list(
		/obj/item/powersink/compact = 1,
		/obj/item/pen/sleepy = 1,
		/obj/item/gun/syringe/rapidsyringe/syndicate = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/death_book/eggs_terror = 1,
		/obj/item/reagent_containers/hypospray/autoinjector/death_book/xeno = 1,
		/obj/item/gun/energy/kinetic_accelerator/crossbow = 1
		)

/datum/outfit/radial_outfit/death_book/plague_inc/post_equip(mob/living/carbon/human/H, visualsOnly)
	SEND_SIGNAL(H.wear_suit, COMSIG_EQUIP_HOOD)
	
/datum/outfit/radial_outfit/death_book/plague_inc/can_choise(mob/user)
	if(locate(/datum/objective/hijack) in user.mind.get_all_objectives())
		return TRUE
	return FALSE
