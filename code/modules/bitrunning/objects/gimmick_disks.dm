/obj/item/disk/bitrunning/gimmick
	abstract_type = /obj/item/disk/bitrunning/gimmick
	desc = "Диск с исходным кодом. Подгружает в домен готовый набор снаряжения."

/obj/item/disk/bitrunning/gimmick/load_onto_avatar(mob/living/carbon/human/pilot, mob/living/carbon/human/avatar, domain_flags)
	if(isnull(selected_path))
		return BITRUNNER_GEAR_LOAD_FAILED

	var/datum/bitrunning_gimmick/loadout = new selected_path
	. = loadout.grant_loadout(avatar, domain_flags)
	qdel(loadout)

/obj/item/disk/bitrunning/gimmick/sports
	name = "bitrunning gimmick: sports"
	selectable = list(
		"Боксёр" = /datum/bitrunning_gimmick/boxer,
		"Лучник" = /datum/bitrunning_gimmick/archer,
		"Рыбак" = /datum/bitrunning_gimmick/fisher,
		"Геймер" = /datum/bitrunning_gimmick/gamer,
	)

/obj/item/disk/bitrunning/gimmick/dungeon
	name = "bitrunning gimmick: dungeon crawling"
	selectable = list(
		"Алхимик" = /datum/bitrunning_gimmick/alchemist,
		"Разбойник" = /datum/bitrunning_gimmick/rogue,
		"Целитель" = /datum/bitrunning_gimmick/healer,
		"Волшебник" = /datum/bitrunning_gimmick/wizard,
	)

/datum/bitrunning_gimmick
	var/name = "Gimmick Loadout"
	var/list/granted_items
	var/list/granted_spells
	var/container_type = /obj/item/storage/briefcase

/datum/bitrunning_gimmick/proc/grant_loadout(mob/living/carbon/human/avatar, domain_flags)
	. = NONE
	. |= grant_items(avatar, domain_flags)
	. |= grant_spells(avatar, domain_flags)

/datum/bitrunning_gimmick/proc/grant_items(mob/living/carbon/human/avatar, domain_flags)
	if(!length(granted_items))
		return NONE

	if(domain_flags & DOMAIN_FORBIDS_ITEMS)
		return BITRUNNER_GEAR_LOAD_BLOCKED

	var/obj/item/storage/container = new container_type(avatar.loc)
	for(var/item_type in granted_items)
		new item_type(container)

	avatar.put_in_hands(container)
	return NONE

/datum/bitrunning_gimmick/proc/grant_spells(mob/living/carbon/human/avatar, domain_flags)
	if(!length(granted_spells))
		return NONE

	if(domain_flags & DOMAIN_FORBIDS_ABILITIES)
		return BITRUNNER_GEAR_LOAD_BLOCKED

	for(var/spell_type in granted_spells)
		if(locate(spell_type) in avatar.mob_spell_list)
			continue

		avatar.AddSpell(new spell_type)

	return NONE

/datum/bitrunning_gimmick/boxer
	name = "Boxer"
	granted_items = list(
		/obj/item/clothing/gloves/boxing,
		/obj/item/clothing/under/shorts/red,
		/obj/item/clothing/shoes/laceup,
		/obj/item/reagent_containers/cup/soda_cans/energy,
	)

/datum/bitrunning_gimmick/gamer
	name = "Gamer"
	granted_items = list(
		/obj/item/clothing/under/suit_jacket/really_black,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/gloves/color/black,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/toy/eight_ball,
		/obj/item/reagent_containers/cup/soda_cans/energy/grey,
	)

/datum/bitrunning_gimmick/archer
	name = "Archer"
	granted_items = list(
		/obj/item/clothing/shoes/sandal,
		/obj/item/storage/backpack/quiver/weaver/full,
		/obj/item/gun/projectile/bow,
	)

/datum/bitrunning_gimmick/fisher
	name = "Fisher"
	granted_items = list(
		/obj/item/clothing/under/overalls,
		/obj/item/clothing/suit/jacket/miljacket,
		/obj/item/clothing/head/soft/black,
		/obj/item/clothing/shoes/jackboots,
		/obj/item/twohanded/fishing_rod,
		/obj/item/storage/bag/medpouch/fishing,
		/obj/item/reagent_containers/food/snacks/bait/goldgrub_larva,
	)

/datum/bitrunning_gimmick/alchemist
	name = "Alchemist"
	granted_items = list(
		/obj/item/clothing/suit/bio_suit/plaguedoctorsuit,
		/obj/item/clothing/mask/gas/plaguedoctor,
		/obj/item/clothing/head/bio_hood,
		/obj/item/storage/box/alchemist,
		/obj/item/storage/box/alchemist/unstable,
	)

/datum/bitrunning_gimmick/rogue
	name = "Rogue"
	granted_items = list(
		/obj/item/clothing/under/color/black,
		/obj/item/clothing/mask/bandana,
		/obj/item/clothing/glasses/eyepatch,
		/obj/item/storage/belt/fannypack,
		/obj/item/kitchen/knife/combat/survival,
	)

/datum/bitrunning_gimmick/healer
	name = "Healer"
	granted_items = list(
		/obj/item/clothing/suit/storage/labcoat,
		/obj/item/rod_of_asclepius,
		/obj/item/storage/firstaid/surgery,
		/obj/item/reagent_containers/dropper,
	)

/datum/bitrunning_gimmick/wizard
	name = "Wizard"
	granted_items = list(
		/obj/item/clothing/head/wizard/fake,
		/obj/item/clothing/suit/wizrobe/fake,
		/obj/item/clothing/shoes/sandal/marisa,
		/obj/item/twohanded/staff,
		/obj/item/storage/box/matches,
	)
	granted_spells = list(
		/datum/action/cooldown/spell/smoke/digital,
	)

/datum/action/cooldown/spell/smoke/digital
	name = "Digi-Smoke"

GLOBAL_LIST_INIT(alchemist_reagents, list(
	"aluminum",
	"bromine",
	"carbon",
	"chlorine",
	"coffee",
	"copper",
	"ethanol",
	"fluorine",
	"fuel",
	"hydrogen",
	"iodine",
	"iron",
	"lithium",
	"mercury",
	"nitrogen",
	"nutriment",
	"oxygen",
	"phosphorus",
	"potassium",
	"radium",
	"sacid",
	"silicon",
	"sodium",
	"sugar",
	"sulfur",
	"water",
))

/obj/item/reagent_containers/cup/bottle/alchemist
	name = "unlabeled bottle"
	desc = "Небольшая бутылочка. Вы уже не помните, что в неё налили."
	var/unstable = FALSE

/obj/item/reagent_containers/cup/bottle/alchemist/get_ru_names()
	return alist(
		NOMINATIVE = "бутылочка без этикетки",
		GENITIVE = "бутылочки без этикетки",
		DATIVE = "бутылочке без этикетки",
		ACCUSATIVE = "бутылочку без этикетки",
		INSTRUMENTAL = "бутылочкой без этикетки",
		PREPOSITIONAL = "бутылочке без этикетки",
	)

/obj/item/reagent_containers/cup/bottle/alchemist/Initialize(mapload)
	. = ..()
	reagents.add_reagent(unstable ? get_random_reagent_id() : pick(GLOB.alchemist_reagents), volume)

/obj/item/reagent_containers/cup/bottle/alchemist/unstable
	name = "skull-labeled bottle"
	desc = "Небольшая бутылочка с черепом на этикетке. Что бы в ней ни было, оно вам не понравится."
	unstable = TRUE

/obj/item/reagent_containers/cup/bottle/alchemist/unstable/get_ru_names()
	return alist(
		NOMINATIVE = "бутылочка с черепом",
		GENITIVE = "бутылочки с черепом",
		DATIVE = "бутылочке с черепом",
		ACCUSATIVE = "бутылочку с черепом",
		INSTRUMENTAL = "бутылочкой с черепом",
		PREPOSITIONAL = "бутылочке с черепом",
	)

/obj/item/storage/box/alchemist
	name = "box of unlabeled bottles"
	desc = "Коробка с бутылочками без этикеток. Алхимия — это про смелость."
	icon_state = "box_pillpacks"
	var/bottle_type = /obj/item/reagent_containers/cup/bottle/alchemist

/obj/item/storage/box/alchemist/get_ru_names()
	return alist(
		NOMINATIVE = "коробка бутылочек",
		GENITIVE = "коробки бутылочек",
		DATIVE = "коробке бутылочек",
		ACCUSATIVE = "коробку бутылочек",
		INSTRUMENTAL = "коробкой бутылочек",
		PREPOSITIONAL = "коробке бутылочек",
	)

/obj/item/storage/box/alchemist/populate_contents()
	for(var/bottle in 1 to 7)
		new bottle_type(src)

/obj/item/storage/box/alchemist/unstable
	name = "box of skull-labeled bottles"
	desc = "Коробка с бутылочками, помеченными черепами. Кто-то очень старался предупредить."
	bottle_type = /obj/item/reagent_containers/cup/bottle/alchemist/unstable
