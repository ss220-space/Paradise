//SUPPLY PACKS
//NOTE: only secure crate types use the access var (and are lockable)
//NOTE: hidden packs only show up when the computer has been hacked.
//ANOTHER NOTE: Contraband is obtainable through modified supplycomp circuitboards.
//BIG NOTE: Don't add living things to crates, that's bad, it will break the shuttle.
//NEW NOTE: Do NOT set the price of any crates below 7 points. Doing so allows infinite points.

// MARK: Supply Groups
#define SUPPLY_EMERGENCY 1
#define SUPPLY_SECURITY 2
#define SUPPLY_ENGINEER 3
#define SUPPLY_MEDICAL 4
#define SUPPLY_SCIENCE 5
#define SUPPLY_ORGANIC 6
#define SUPPLY_MATERIALS 7
#define SUPPLY_MISC 8
#define SUPPLY_VEND 9

GLOBAL_LIST_INIT(all_supply_groups, list(SUPPLY_EMERGENCY,SUPPLY_SECURITY,SUPPLY_ENGINEER,SUPPLY_MEDICAL,SUPPLY_SCIENCE,SUPPLY_ORGANIC,SUPPLY_MATERIALS,SUPPLY_MISC,SUPPLY_VEND, SUPPLY_CONTRABAND))

/proc/get_supply_group_name(cat)
	switch(cat)
		if(SUPPLY_EMERGENCY)
			return "Чрезвычайные ситуации"
		if(SUPPLY_SECURITY)
			return "Безопасность"
		if(SUPPLY_ENGINEER)
			return "Инженерия"
		if(SUPPLY_MEDICAL)
			return "Медицина"
		if(SUPPLY_SCIENCE)
			return "Наука"
		if(SUPPLY_ORGANIC)
			return "Продовольствие и животноводство"
		if(SUPPLY_MATERIALS)
			return "Материалы"
		if(SUPPLY_MISC)
			return "Прочее"
		if(SUPPLY_VEND)
			return "Торговля"
		if(SUPPLY_CONTRABAND)
			return "Контрабанда"

/datum/supply_packs
	var/name = null
	var/list/contains = list()
	var/manifest = ""
	var/amount = null
	var/cost = null
	var/credits_cost = 0
	var/containertype = /obj/structure/closet/crate
	var/containername = null
	var/container_ru_names = list()
	var/access = null
	var/hidden = FALSE
	var/contraband = FALSE
	var/group = SUPPLY_MISC
	/// Particular beacons that we'll notify the relevant department when we reach
	var/list/announce_beacons = list()
	/// Event/Station Goals/Admin enabled packs
	var/special = FALSE
	var/special_enabled = FALSE

	// The number of times one can order a cargo crate, before it becomes restricted. -1 for infinite
	// var/order_limit = -1	// Unused for now (Crate limit #3056).

	/// Number of times a crate has been ordered in a shift
	var/times_ordered = 0

	/// List of names for being done in TGUI
	var/list/ui_manifest = list()

	var/list/required_tech

/datum/supply_packs/New()
	..()
	manifest += "<ul>"
	for(var/path in contains)
		if(!path)
			continue
		var/atom/movable/dummy = new path(locate(1, 1, 1))
		var/content_name = dummy.declent_ru(NOMINATIVE)
		qdel(dummy)
		manifest += "<li>[content_name]</li>"
		// Add the name to the UI manifest
		ui_manifest += "[content_name]"
	manifest += "</ul>"

/datum/supply_packs/proc/can_approve(mob/user)
	if(SSshuttle.points < cost)
		to_chat(user, span_warning("Недостаточно очков снабжения для заказа."))
		return FALSE
	if(credits_cost && SSshuttle.cargo_money_account.money < credits_cost)
		to_chat(user, span_warning("Недостаточно кредитов для заказа."))
		return FALSE
	if(!length(required_tech))
		return TRUE
	for(var/tech_id in required_tech)
		if(!SSshuttle.techLevels[tech_id] || required_tech[tech_id] > SSshuttle.techLevels[tech_id])
			to_chat(user, span_warning("Недостаточный уровень технологий для заказа."))
			return FALSE
	return TRUE

////// Use the sections to keep things tidy please /Malkevin

//////////////////////////////////////////////////////////////////////////////
// MARK: Emergency
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/emergency	// Section header - use these to set default supply group and crate type for sections
	name = "HEADER"				// Use "HEADER" to denote section headers, this is needed for the supply computers to filter them
	containertype = /obj/structure/closet/crate/internals
	group = SUPPLY_EMERGENCY

/datum/supply_packs/emergency/evac
	name = "Аварийное оборудование"
	contains = list(
		/mob/living/simple_animal/bot/floorbot,
		/mob/living/simple_animal/bot/floorbot,
		/mob/living/simple_animal/bot/medbot,
		/mob/living/simple_animal/bot/medbot,
		/obj/item/tank/internals/air,
		/obj/item/tank/internals/air,
		/obj/item/tank/internals/air,
		/obj/item/tank/internals/air,
		/obj/item/tank/internals/air,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/mask/gas,
		/obj/item/grenade/gas/oxygen,
		/obj/item/grenade/gas/oxygen,
	)
	cost = 40
	containername = "ящик аварийного оборудования"
	container_ru_names = list(
		NOMINATIVE = "ящик аварийного оборудования",
		GENITIVE = "ящика аварийного оборудования",
		DATIVE = "ящику аварийного оборудования",
		ACCUSATIVE = "ящик аварийного оборудования",
		INSTRUMENTAL = "ящиком аварийного оборудования",
		PREPOSITIONAL = "ящике аварийного оборудования",
	)

/datum/supply_packs/emergency/firefighting
	name = "Противопожарное оборудование"
	contains = list(
		/obj/item/clothing/suit/fire/firefighter,
		/obj/item/clothing/suit/fire/firefighter,
		/obj/item/clothing/mask/gas,
		/obj/item/clothing/mask/gas,
		/obj/item/flashlight,
		/obj/item/flashlight,
		/obj/item/tank/internals/oxygen/red,
		/obj/item/tank/internals/oxygen/red,
		/obj/item/extinguisher,
		/obj/item/extinguisher,
		/obj/item/clothing/head/hardhat/red,
		/obj/item/clothing/head/hardhat/red,
	)
	cost = 15
	containertype = /obj/structure/closet/crate
	containername = "ящик противопожарного оборудования"
	container_ru_names = list(
		NOMINATIVE = "ящик противопожарного оборудования",
		GENITIVE = "ящика противопожарного оборудования",
		DATIVE = "ящику противопожарного оборудования",
		ACCUSATIVE = "ящик противопожарного оборудования",
		INSTRUMENTAL = "ящиком противопожарного оборудования",
		PREPOSITIONAL = "ящике противопожарного оборудования",
	)

/datum/supply_packs/emergency/proper
	name = "Кластерная очищающая граната"
	contains = list(
		/obj/item/grenade/clusterbuster/cleaner,
	)
	cost = 75
	containertype = /obj/structure/closet/crate
	containername = "ящик с кластерной очищающей гранатой"
	container_ru_names = list(
		NOMINATIVE = "ящик с кластерной очищающей гранатой",
		GENITIVE = "ящика с кластерной очищающей гранатой",
		DATIVE = "ящику с кластерной очищающей гранатой",
		ACCUSATIVE = "ящик с кластерной очищающей гранатой",
		INSTRUMENTAL = "ящиком с кластерной очищающей гранатой",
		PREPOSITIONAL = "ящике с кластерной очищающей гранатой",
	)

/datum/supply_packs/emergency/clusteroxygen
	name = "Кластерная кислородная граната"
	contains = list(
		/obj/item/grenade/clusterbuster/oxygen,
	)
	cost = 50
	containertype = /obj/structure/closet/crate
	containername = "ящик с кластерной кислородной гранатой"
	container_ru_names = list(
		NOMINATIVE = "ящик с кластерной кислородной гранатой",
		GENITIVE = "ящика с кластерной кислородной гранатой",
		DATIVE = "ящику с кластерной кислородной гранатой",
		ACCUSATIVE = "ящик с кластерной кислородной гранатой",
		INSTRUMENTAL = "ящиком с кластерной кислородной гранатой",
		PREPOSITIONAL = "ящике с кластерной кислородной гранатой",
	)

/datum/supply_packs/emergency/atmostank
	name = "Противопожарный ранец"
	contains = list(
		/obj/item/watertank/atmos,
	)
	cost = 20
	containertype = /obj/structure/closet/crate
	containername = "ящик с противопожарным ранцем"
	container_ru_names = list(
		NOMINATIVE = "ящик с противопожарным ранцем",
		GENITIVE = "ящика с противопожарным ранцем",
		DATIVE = "ящику с противопожарным ранцем",
		ACCUSATIVE = "ящик с противопожарным ранцем",
		INSTRUMENTAL = "ящиком с противопожарным ранцем",
		PREPOSITIONAL = "ящике с противопожарным ранцем",
	)

/datum/supply_packs/emergency/weedcontrol
	name = "Противосорняковое оборудование"
	contains = list(
		/obj/item/scythe,
		/obj/item/clothing/mask/gas,
		/obj/item/grenade/chem_grenade/antiweed,
		/obj/item/grenade/chem_grenade/antiweed,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/hydrosec
	containername = "ящик противосорнякового оборудования"
	container_ru_names = list(
		NOMINATIVE = "ящик противосорнякового оборудования",
		GENITIVE = "ящика противосорнякового оборудования",
		DATIVE = "ящику противосорнякового оборудования",
		ACCUSATIVE = "ящик противосорнякового оборудования",
		INSTRUMENTAL = "ящиком противосорнякового оборудования",
		PREPOSITIONAL = "ящике противосорнякового оборудования",
	)
	access = ACCESS_HYDROPONICS
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_packs/emergency/voxsupport
	name = "Оборудование для жизнеобеспечения воксов"
	contains = list(
		/obj/item/clothing/mask/breath/vox,
		/obj/item/clothing/mask/breath/vox,
		/obj/item/tank/internals/emergency_oxygen/double/vox,
		/obj/item/tank/internals/emergency_oxygen/double/vox,
	)
	cost = 35
	containertype = /obj/structure/closet/crate/medical
	containername = "ящик оборудования для жизнеобеспечения воксов"
	container_ru_names = list(
		NOMINATIVE = "ящик оборудования для жизнеобеспечения воксов",
		GENITIVE = "ящика оборудования для жизнеобеспечения воксов",
		DATIVE = "ящику оборудования для жизнеобеспечения воксов",
		ACCUSATIVE = "ящик оборудования для жизнеобеспечения воксов",
		INSTRUMENTAL = "ящиком оборудования для жизнеобеспечения воксов",
		PREPOSITIONAL = "ящике оборудования для жизнеобеспечения воксов",
	)

/datum/supply_packs/emergency/plasmamansupport
	name = "Оборудование для жизнеобеспечения плазмолюдов"
	contains = list(
		/obj/item/clothing/under/plasmaman,
		/obj/item/clothing/under/plasmaman,
		/obj/item/tank/internals/plasmaman/belt/full,
		/obj/item/tank/internals/plasmaman/belt/full,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/head/helmet/space/plasmaman,
		/obj/item/clothing/head/helmet/space/plasmaman,
		/obj/item/extinguisher_refill,
		/obj/item/extinguisher_refill,
		/obj/item/extinguisher_refill,
		/obj/item/extinguisher_refill,
	)
	cost = 35
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "ящик оборудования для жизнеобспечения плазмолюдов"
	container_ru_names = list(
		NOMINATIVE = "ящик оборудования для жизнеобспечения плазмолюдов",
		GENITIVE = "ящика оборудования для жизнеобспечения плазмолюдов",
		DATIVE = "ящику оборудования для жизнеобспечения плазмолюдов",
		ACCUSATIVE = "ящик оборудования для жизнеобспечения плазмолюдов",
		INSTRUMENTAL = "ящиком оборудования для жизнеобспечения плазмолюдов",
		PREPOSITIONAL = "ящике оборудования для жизнеобспечения плазмолюдов",
	)
	access = ACCESS_CARGO

/datum/supply_packs/emergency/pacmancrate
	name = "Портативный генератор \"Пакман\""
	contains = list(
		/obj/machinery/power/port_gen,
		/obj/item/stack/sheet/mineral/plasma{amount = 20},
	)
	cost = 220
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "ящик c генератором \"Пакман\""
	container_ru_names = list(
		NOMINATIVE = "ящик c генератором \"Пакман\"",
		GENITIVE = "ящика c генератором \"Пакман\"",
		DATIVE = "ящику c генератором \"Пакман\"",
		ACCUSATIVE = "ящик c генератором \"Пакман\"",
		INSTRUMENTAL = "ящиком c генератором \"Пакман\"",
		PREPOSITIONAL = "ящике c генератором \"Пакман\"",
	)
	access = ACCESS_ATMOSPHERICS
	required_tech = list(RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_MATERIALS = 2)

/datum/supply_packs/emergency/spacesuit
	name = "Костюмы для ВКД"
	contains = list(
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
	)
	cost = 80
	containertype = /obj/structure/closet/crate/secure
	containername = "ящик костюмов для ВКД"
	container_ru_names = list(
		NOMINATIVE = "ящик костюмов для ВКД",
		GENITIVE = "ящика костюмов для ВКД",
		DATIVE = "ящику костюмов для ВКД",
		ACCUSATIVE = "ящик костюмов для ВКД",
		INSTRUMENTAL = "ящиком костюмов для ВКД",
		PREPOSITIONAL = "ящике костюмов для ВКД",
	)

/datum/supply_packs/emergency/scrubbercrate
	name = "Очиститель воздуха"
	contains = list(
		/obj/machinery/portable_atmospherics/scrubber,
	)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "ящик с очистителем воздуха"
	container_ru_names = list(
		NOMINATIVE = "ящик с очистителем воздуха",
		GENITIVE = "ящика с очистителем воздуха",
		DATIVE = "ящику с очистителем воздуха",
		ACCUSATIVE = "ящик с очистителем воздуха",
		INSTRUMENTAL = "ящиком с очистителем воздуха",
		PREPOSITIONAL = "ящике с очистителем воздуха",
	)
	access = ACCESS_ATMOSPHERICS

/datum/supply_packs/emergency/pumpcrate
	name = "Воздушный насос"
	contains = list(
		/obj/machinery/portable_atmospherics/pump,
	)
	cost = 25
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "ящик с воздушным насосом"
	container_ru_names = list(
		NOMINATIVE = "ящик с воздушным насосом",
		GENITIVE = "ящика с воздушным насосом",
		DATIVE = "ящику с воздушным насосом",
		ACCUSATIVE = "ящик с воздушным насосом",
		INSTRUMENTAL = "ящиком с воздушным насосом",
		PREPOSITIONAL = "ящике с воздушным насосом",
	)
	access = ACCESS_ATMOSPHERICS

/datum/supply_packs/emergency/biosuitcrate
	name = "Противоэпидемическое снаряжение"
	contains = list(
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/suit/bio_suit,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/head/bio_hood,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
		/obj/item/tank/internals/emergency_oxygen/engi,
		/obj/item/tank/internals/emergency_oxygen/engi,
		/obj/item/tank/internals/emergency_oxygen/engi,
		/obj/item/tank/internals/emergency_oxygen/engi,
		/obj/item/tank/internals/emergency_oxygen/engi,
		/obj/item/tank/internals/emergency_oxygen/engi,
	)
	cost = 120
	containername = "ящик противоэпидемического снаряжения"
	container_ru_names = list(
		NOMINATIVE = "ящик противоэпидемического снаряжения",
		GENITIVE = "ящика противоэпидемического снаряжения",
		DATIVE = "ящику противоэпидемического снаряжения",
		ACCUSATIVE = "ящик противоэпидемического снаряжения",
		INSTRUMENTAL = "ящиком противоэпидемического снаряжения",
		PREPOSITIONAL = "ящике противоэпидемического снаряжения",
	)

/datum/supply_packs/emergency/specialops
	name = "Набор для специальных операций"
	contains = list(
		/obj/item/storage/box/emps,
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/smokebomb,
		/obj/item/grenade/smokebomb,
		/obj/item/pen/sleepy,
		/obj/item/grenade/chem_grenade/incendiary,
	)
	cost = 60
	containertype = /obj/structure/closet/crate
	containername = "ящик c набором для спецопераций"
	container_ru_names = list(
		NOMINATIVE = "ящик c набором для спецопераций",
		GENITIVE = "ящика c набором для спецопераций",
		DATIVE = "ящику c набором для спецопераций",
		ACCUSATIVE = "ящик c набором для спецопераций",
		INSTRUMENTAL = "ящиком c набором для спецопераций",
		PREPOSITIONAL = "ящике c набором для спецопераций",
	)
	hidden = TRUE

/datum/supply_packs/emergency/syndicate
	name = "ОШИБКА_ПУСТАЯ_ЗАПИСЬ"
	contains = list(
		/obj/item/storage/box/random_syndi,
	)
	cost = 0
	credits_cost = 2500
	containertype = /obj/structure/closet/crate/syndicate
	containername = "ящик"
	container_ru_names = list(
		NOMINATIVE = "ящик",
		GENITIVE = "ящика",
		DATIVE = "ящику",
		ACCUSATIVE = "ящик",
		INSTRUMENTAL = "ящиком",
		PREPOSITIONAL = "ящике",
	)
	hidden = TRUE

/datum/supply_packs/emergency/highrisk
	cost = 450
	containertype = /obj/structure/closet/crate/secure/weapon/veihit
	containername = "ящик особо важного снаряжения"
	container_ru_names = list(
		NOMINATIVE = "ящик особо важного снаряжения",
		GENITIVE = "ящика особо важного снаряжения",
		DATIVE = "ящику особо важного снаряжения",
		ACCUSATIVE = "ящик особо важного снаряжения",
		INSTRUMENTAL = "ящиком особо важного снаряжения",
		PREPOSITIONAL = "ящике особо важного снаряжения",
	)
	access = ACCESS_CAPTAIN

/datum/supply_packs/emergency/highrisk/rd_handtp
	name = "Ручной телепорт"
	access = ACCESS_RD
	contains = list(
		/obj/item/hand_tele,
	)
	required_tech = list(RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_BLUESPACE = 8)

/datum/supply_packs/emergency/highrisk/rd_tp_armor
	name = "Реактивная броня"
	access = ACCESS_RD
	contains = list(
		/obj/item/clothing/suit/armor/reactive/teleport,
	)
	required_tech = list(RESEARCH_TREE_COMBAT = 8, RESEARCH_TREE_BLUESPACE = 5)

/datum/supply_packs/emergency/highrisk/reflect_kit
	name = "Противолазерная броня"
	access = ACCESS_ARMORY
	contains = list(
		/obj/item/clothing/suit/armor/reflector,
		/obj/item/clothing/gloves/reflector,
		/obj/item/clothing/shoes/reflector,
		/obj/item/clothing/head/helmet/reflector,
	)
	required_tech = list(RESEARCH_TREE_COMBAT = 8, RESEARCH_TREE_MATERIALS = 7)

/datum/supply_packs/emergency/highrisk/capt_jet
	name = "Люксовый реактивный ранец"
	contains = list(
		/obj/item/tank/jetpack/oxygen/captain,
	)
	required_tech = list(RESEARCH_TREE_TOXINS = 8, RESEARCH_TREE_MATERIALS = 7)

/datum/supply_packs/emergency/highrisk/ce_combatrcd
	name = "Боевое УБС"
	access = ACCESS_CE
	contains = list(
		/obj/item/rcd/combat,
	)
	required_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_ENGINEERING = 8)

/datum/supply_packs/emergency/highrisk/ce_advmagboots
	name = "Продвинутые магбутсы"
	access = ACCESS_CE
	contains = list(
		/obj/item/clothing/shoes/magboots/advance,
	)
	required_tech = list(RESEARCH_TREE_ENGINEERING = 8, RESEARCH_TREE_MAGNETS = 6)

/datum/supply_packs/emergency/highrisk/cmo_defib
	name = "Продвинутый дефибриллятор"
	access = ACCESS_CMO
	contains = list(
		/obj/item/defibrillator/compact/advanced/loaded,
	)
	required_tech = list(RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_POWERSTORAGE = 8)

/datum/supply_packs/emergency/highrisk/cmo_hypospray
	name = "Продвинутый гипоспрей"
	access = ACCESS_CMO
	contains = list(
		/obj/item/reagent_containers/hypospray/CMO/empty,
	)
	required_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_BIOTECH = 8)

/datum/supply_packs/emergency/jetpack
	name = "Реактивные ранцы"
	contains = list(
		/obj/item/tank/jetpack,
		/obj/item/tank/jetpack,
		/obj/item/tank/jetpack,
	)
	cost = 30
	required_tech = list(RESEARCH_TREE_TOXINS = 3)
	containername = "ящик реактивных ранцев"
	container_ru_names = list(
		NOMINATIVE = "ящик реактивных ранцев",
		GENITIVE = "ящика реактивных ранцев",
		DATIVE = "ящику реактивных ранцев",
		ACCUSATIVE = "ящик реактивных ранцев",
		INSTRUMENTAL = "ящиком реактивных ранцев",
		PREPOSITIONAL = "ящике реактивных ранцев",
	)

/datum/supply_packs/emergency/jetpack_upgrade
	name = "Модули реактивного ранца"
	contains = list(
		/obj/item/tank/jetpack/suit,
		/obj/item/tank/jetpack/suit,
		/obj/item/tank/jetpack/suit,
	)
	cost = 80
	required_tech = list(RESEARCH_TREE_TOXINS = 7)
	containername = "ящик модулей реактивного ранца"
	container_ru_names = list(
		NOMINATIVE = "ящик модулей реактивного ранца",
		GENITIVE = "ящика модулей реактивного ранца",
		DATIVE = "ящику модулей реактивного ранца",
		ACCUSATIVE = "ящик модулей реактивного ранца",
		INSTRUMENTAL = "ящиком модулей реактивного ранца",
		PREPOSITIONAL = "ящике модулей реактивного ранца",
	)

/datum/supply_packs/emergency/jetpack_mini
	name = "Реактивные ранцы для мышей" // the fuck?
	contains = list(
		/obj/item/mouse_jetpack,
		/obj/item/mouse_jetpack,
	)
	cost = 30
	required_tech = list(RESEARCH_TREE_TOXINS = 2)
	containername = "ящик реактивных ранцев для мышей"
	container_ru_names = list(
		NOMINATIVE = "ящик реактивных ранцев для мышей",
		GENITIVE = "ящика реактивных ранцев для мышей",
		DATIVE = "ящику реактивных ранцев для мышей",
		ACCUSATIVE = "ящик реактивных ранцев для мышей",
		INSTRUMENTAL = "ящиком реактивных ранцев для мышей",
		PREPOSITIONAL = "ящике реактивных ранцев для мышей",
	)

//////////////////////////////////////////////////////////////////////////////
// MARK: Security
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/security
	name = "HEADER"
	containertype = /obj/structure/closet/crate/secure/gear
	access = ACCESS_SECURITY
	group = SUPPLY_SECURITY
	announce_beacons = list("Security" = list("Head of Security's Desk", "Warden", "Security"))

/datum/supply_packs/security/modsuit
	name = "МЭК службы безопасности"
	contains = list(
		/obj/item/mod/control/pre_equipped/security,
		/obj/item/mod/control/pre_equipped/security,
		/obj/item/clothing/mask/gas/sechailer,
		/obj/item/clothing/mask/gas/sechailer,
	)
	cost = 180
	containername = "ящик МЭК службы безопасности"
	required_tech = list(RESEARCH_TREE_TOXINS = 6, RESEARCH_TREE_COMBAT = 6)
	container_ru_names = list(
		NOMINATIVE = "ящик МЭК службы безопасности",
		GENITIVE = "ящика МЭК службы безопасности",
		DATIVE = "ящику МЭК службы безопасности",
		ACCUSATIVE = "ящик МЭК службы безопасности",
		INSTRUMENTAL = "ящиком МЭК службы безопасности",
		PREPOSITIONAL = "ящике МЭК службы безопасности",
	)
	access = ACCESS_ARMORY

/datum/supply_packs/security/supplies
	name = "Нелетальное снаряжение службы безопасности"
	contains = list(
		/obj/item/storage/box/flashbangs,
		/obj/item/storage/box/teargas,
		/obj/item/storage/box/flashes,
		/obj/item/storage/box/handcuffs,
	)
	cost = 15
	containername = "ящик нелетального снаряжения СБ"
	container_ru_names = list(
		NOMINATIVE = "ящик нелетального снаряжения СБ",
		GENITIVE = "ящика нелетального снаряжения СБ",
		DATIVE = "ящику нелетального снаряжения СБ",
		ACCUSATIVE = "ящик нелетального снаряжения СБ",
		INSTRUMENTAL = "ящиком нелетального снаряжения СБ",
		PREPOSITIONAL = "ящике нелетального снаряжения СБ",
	)

/datum/supply_packs/security/vending/security
	name = "Набор пополнения SecTech"
	cost = 75
	contains = list(
		/obj/item/vending_refill/security,
	)
	containername = "ящик с набором пополнения SecTech"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения SecTech",
		GENITIVE = "ящика с набором пополнения SecTech",
		DATIVE = "ящику с набором пополнения SecTech",
		ACCUSATIVE = "ящик с набором пополнения SecTech",
		INSTRUMENTAL = "ящиком с набором пополнения SecTech",
		PREPOSITIONAL = "ящике с набором пополнения SecTech",
	)

/datum/supply_packs/security/vending/security_mods
	name = "ModTech Supply Crate"
	cost = 20
	contains = list(
		/obj/item/vending_refill/gun_mods,
	)
	containername = "ModTech supply crate"

////// Armor: Basic
/datum/supply_packs/security/justiceinbound
	name = "Набор для исполнения правосудия"
	contains = list(
		/obj/item/clothing/head/helmet/justice,
		/obj/item/clothing/head/helmet/justice,
		/obj/item/clothing/mask/gas/sechailer,
		/obj/item/clothing/mask/gas/sechailer,
	)
	cost = 45 //justice comes at a price. An expensive, noisy price.
	containername = "ящик с набором для исполнения правосудия"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором для исполнения правосудия",
		GENITIVE = "ящика с набором для исполнения правосудия",
		DATIVE = "ящику с набором для исполнения правосудия",
		ACCUSATIVE = "ящик с набором для исполнения правосудия",
		INSTRUMENTAL = "ящиком с набором для исполнения правосудия",
		PREPOSITIONAL = "ящике с набором для исполнения правосудия",
	)

/datum/supply_packs/security/armor
	name = "Стандартная броня службы безопасности"
	contains = list(
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/helmet,
	)
	cost = 20
	containername = "ящик со стандартной бронёй СБ"
	container_ru_names = list(
		NOMINATIVE = "ящик со стандартной бронёй СБ",
		GENITIVE = "ящика со стандартной бронёй СБ",
		DATIVE = "ящику со стандартной бронёй СБ",
		ACCUSATIVE = "ящик со стандартной бронёй СБ",
		INSTRUMENTAL = "ящиком со стандартной бронёй СБ",
		PREPOSITIONAL = "ящике со стандартной бронёй СБ",
	)

////// Weapons: Basic

/datum/supply_packs/security/baton
	name = "Оглушающие дубинки"
	contains = list(
		/obj/item/melee/baton/security/loaded,
		/obj/item/melee/baton/security/loaded,
		/obj/item/melee/baton/security/loaded,
	)
	cost = 20
	containername = "ящик оглушающих дубинок"
	container_ru_names = list(
		NOMINATIVE = "ящик оглушающих дубинок",
		GENITIVE = "ящика оглушающих дубинок",
		DATIVE = "ящику оглушающих дубинок",
		ACCUSATIVE = "ящик оглушающих дубинок",
		INSTRUMENTAL = "ящиком оглушающих дубинок",
		PREPOSITIONAL = "ящике оглушающих дубинок",
	)

/datum/supply_packs/security/laser
	name = "Лазерные карабины"
	contains = list(
		/obj/item/gun/energy/laser,
		/obj/item/gun/energy/laser,
		/obj/item/gun/energy/laser,
	)
	cost = 20
	containername = "ящик лазерных карабинов"
	container_ru_names = list(
		NOMINATIVE = "ящик лазерных карабинов",
		GENITIVE = "ящика лазерных карабинов",
		DATIVE = "ящику лазерных карабинов",
		ACCUSATIVE = "ящик лазерных карабинов",
		INSTRUMENTAL = "ящиком лазерных карабинов",
		PREPOSITIONAL = "ящике лазерных карабинов",
	)

/datum/supply_packs/security/taser
	name = "Нелетальное энергетическое оружие"
	contains = list(
		/obj/item/gun/energy/gun/advtaser,
		/obj/item/gun/energy/gun/advtaser,
		/obj/item/gun/energy/gun/advtaser,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/disabler,
		/obj/item/gun/energy/disabler,
	)
	cost = 25
	containername = "ящик нелетального энергетического оружия"
	container_ru_names = list(
		NOMINATIVE = "ящик нелетального энергетического оружия",
		GENITIVE = "ящика нелетального энергетического оружия",
		DATIVE = "ящику нелетального энергетического оружия",
		ACCUSATIVE = "ящик нелетального энергетического оружия",
		INSTRUMENTAL = "ящиком нелетального энергетического оружия",
		PREPOSITIONAL = "ящике нелетального энергетического оружия",
	)

/datum/supply_packs/security/enforcer
	name = "Блюстители"
	contains = list(
		/obj/item/storage/box/enforcer/security,
		/obj/item/storage/box/enforcer/security,
	)
	cost = 12
	containername = "ящик Блюстителей"
	container_ru_names = list(
		NOMINATIVE = "ящик Блюстителей",
		GENITIVE = "ящика Блюстителей",
		DATIVE = "ящику Блюстителей",
		ACCUSATIVE = "ящик Блюстителей",
		INSTRUMENTAL = "ящиком Блюстителей",
		PREPOSITIONAL = "ящике Блюстителей",
	)

/datum/supply_packs/security/forensics
	name = "Криминалистическое снаряжение"
	contains = list(
		/obj/item/storage/box/evidence,
		/obj/item/camera,
		/obj/item/taperecorder,
		/obj/item/toy/crayon/white,
		/obj/item/clothing/head/det_hat,
		/obj/item/storage/box/swabs,
		/obj/item/storage/box/fingerprints,
		/obj/item/storage/briefcase/crimekit,
	)
	cost = 20
	containername = "ящик криминалистического снаряжения"
	container_ru_names = list(
		NOMINATIVE = "ящик криминалистического снаряжения",
		GENITIVE = "ящика криминалистического снаряжения",
		DATIVE = "ящику криминалистического снаряжения",
		ACCUSATIVE = "ящик криминалистического снаряжения",
		INSTRUMENTAL = "ящиком криминалистического снаряжения",
		PREPOSITIONAL = "ящике криминалистического снаряжения",
	)

/datum/supply_packs/security/telescopic
	name = "Телескопические дубинки"
	contains = list(
		/obj/item/melee/baton/telescopic,
		/obj/item/melee/baton/telescopic,
	)
	cost = 20
	containername = "ящик телескопических дубинок"
	container_ru_names = list(
		NOMINATIVE = "ящик телескопических дубинок",
		GENITIVE = "ящика телескопических дубинок",
		DATIVE = "ящику телескопических дубинок",
		ACCUSATIVE = "ящик телескопических дубинок",
		INSTRUMENTAL = "ящиком телескопических дубинок",
		PREPOSITIONAL = "ящике телескопических дубинок",
	)

///// Armory stuff

/datum/supply_packs/security/armory
	containertype = /obj/structure/closet/crate/secure/weapon
	access = ACCESS_ARMORY
	announce_beacons = list("Security" = list("Warden", "Head of Security's Desk"))

///// Armor: Specialist

/datum/supply_packs/security/armory/riothelmets
	name = "Противоударная броня"
	contains = list(
		/obj/item/storage/backpack/duffel/security/riot_armory,
		/obj/item/storage/backpack/duffel/security/riot_armory,
		/obj/item/storage/backpack/duffel/security/riot_armory,
		/obj/item/shield/riot,
		/obj/item/shield/riot,
		/obj/item/shield/riot,
	)
	cost = 80
	containername = "ящик противоударной брони"
	container_ru_names = list(
		NOMINATIVE = "ящик противоударной брони",
		GENITIVE = "ящика противоударной брони",
		DATIVE = "ящику противоударной брони",
		ACCUSATIVE = "ящик противоударной брони",
		INSTRUMENTAL = "ящиком противоударной брони",
		PREPOSITIONAL = "ящике противоударной брони",
	)

/datum/supply_packs/security/armory/bulletarmor
	name = "Противопульная броня"
	contains = list(
		/obj/item/storage/backpack/duffel/security/bulletproof_armory,
		/obj/item/storage/backpack/duffel/security/bulletproof_armory,
		/obj/item/storage/backpack/duffel/security/bulletproof_armory,
	)
	cost = 40
	containername = "ящик противопульной брони"
	container_ru_names = list(
		NOMINATIVE = "ящик противопульной брони",
		GENITIVE = "ящика противопульной брони",
		DATIVE = "ящику противопульной брони",
		ACCUSATIVE = "ящик противопульной брони",
		INSTRUMENTAL = "ящиком противопульной брони",
		PREPOSITIONAL = "ящике противопульной брони",
	)

/datum/supply_packs/security/armory/webbing
	name = "Тактические разгрузки"
	contains = list(
		/obj/item/storage/belt/security/webbing,
		/obj/item/storage/belt/security/webbing,
		/obj/item/storage/belt/security/webbing,
	)
	cost = 15
	containername = "ящик тактических разгрузок"
	container_ru_names = list(
		NOMINATIVE = "ящик тактических разгрузок",
		GENITIVE = "ящика тактических разгрузок",
		DATIVE = "ящику тактических разгрузок",
		ACCUSATIVE = "ящик тактических разгрузок",
		INSTRUMENTAL = "ящиком тактических разгрузок",
		PREPOSITIONAL = "ящике тактических разгрузок",
	)

/datum/supply_packs/security/armory/combat_webbing
	name = "Боевые разгрузки"
	contains = list(
		/obj/item/clothing/accessory/storage/webbing,
		/obj/item/clothing/accessory/storage/webbing,
		/obj/item/clothing/accessory/storage/webbing,
	)
	cost = 25
	containername = "ящик боевых разгрузок"
	container_ru_names = list(
		NOMINATIVE = "ящик боевых разгрузок",
		GENITIVE = "ящика боевых разгрузок",
		DATIVE = "ящику боевых разгрузок",
		ACCUSATIVE = "ящик боевых разгрузок",
		INSTRUMENTAL = "ящиком боевых разгрузок",
		PREPOSITIONAL = "ящике боевых разгрузок",
	)

/datum/supply_packs/security/armory/vest
	name = "Рагрузочные жилеты"
	contains = list(
		/obj/item/clothing/accessory/storage/black_vest,
		/obj/item/clothing/accessory/storage/black_vest,
		/obj/item/clothing/accessory/storage/brown_vest,
		/obj/item/clothing/accessory/storage/brown_vest,
	)
	cost = 50
	containername = "ящик разгрузочных жилетов"
	container_ru_names = list(
		NOMINATIVE = "ящик разгрузочных жилетов",
		GENITIVE = "ящика разгрузочных жилетов",
		DATIVE = "ящику разгрузочных жилетов",
		ACCUSATIVE = "ящик разгрузочных жилетов",
		INSTRUMENTAL = "ящиком разгрузочных жилетов",
		PREPOSITIONAL = "ящике разгрузочных жилетов",
	)

/datum/supply_packs/security/armory/swat
	name = "Снаряжение SWAT"
	contains = list(
		/obj/item/clothing/head/helmet/swat,
		/obj/item/clothing/head/helmet/swat,
		/obj/item/clothing/suit/space/swat,
		/obj/item/clothing/suit/space/swat,
		/obj/item/kitchen/knife/combat,
		/obj/item/kitchen/knife/combat,
		/obj/item/clothing/mask/gas/sechailer/swat,
		/obj/item/clothing/mask/gas/sechailer/swat,
		/obj/item/storage/belt/military/assault,
		/obj/item/storage/belt/military/assault,
	)
	cost = 80
	containername = "ящик снаряжения SWAT"
	container_ru_names = list(
		NOMINATIVE = "ящик снаряжения SWAT",
		GENITIVE = "ящика снаряжения SWAT",
		DATIVE = "ящику снаряжения SWAT",
		ACCUSATIVE = "ящик снаряжения SWAT",
		INSTRUMENTAL = "ящиком снаряжения SWAT",
		PREPOSITIONAL = "ящике снаряжения SWAT",
	)

/datum/supply_packs/security/armory/laserarmor
	name = "Противолазерные бронежилеты"
	contains = list(
		/obj/item/clothing/suit/armor/laserproof,
		/obj/item/clothing/suit/armor/laserproof,
	)		// Only two vests to keep costs down for balance
	cost = 20
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "ящик противолазерной брони"
	container_ru_names = list(
		NOMINATIVE = "ящик противолазерной брони",
		GENITIVE = "ящика противолазерной брони",
		DATIVE = "ящику противолазерной брони",
		ACCUSATIVE = "ящик противолазерной брони",
		INSTRUMENTAL = "ящиком противолазерной брони",
		PREPOSITIONAL = "ящике противолазерной брони",
	)
	required_tech = list(RESEARCH_TREE_BLUESPACE = 4, RESEARCH_TREE_COMBAT = 4)

/datum/supply_packs/security/armory/sibyl
	name = "Модули \"Sibyl\""
	contains = list(
		/obj/item/gun_module/sibyl,
		/obj/item/gun_module/sibyl,
		/obj/item/gun_module/sibyl,
	)
	cost = 25								//По 6 за один блокиратор
	containername = "ящик модулей \"Sibyl\""
	container_ru_names = list(
		NOMINATIVE = "ящик модулей \"Sibyl\"",
		GENITIVE = "ящика модулей \"Sibyl\"",
		DATIVE = "ящику модулей \"Sibyl\"",
		ACCUSATIVE = "ящик модулей \"Sibyl\"",
		INSTRUMENTAL = "ящиком модулей \"Sibyl\"",
		PREPOSITIONAL = "ящике модулей \"Sibyl\"",
	)

/datum/supply_packs/security/armory/fastpouch
	name = "Подсумки для магазинов"
	contains = list(
		/obj/item/storage/pouch/fast,
		/obj/item/storage/pouch/fast,
	)
	cost = 100
	containername = "ящик подсумков для магазинов"
	container_ru_names = list(
		NOMINATIVE = "ящик подсумков для магазинов",
		GENITIVE = "ящика подсумков для магазинов",
		DATIVE = "ящику подсумков для магазинов",
		ACCUSATIVE = "ящик подсумков для магазинов",
		INSTRUMENTAL = "ящиком подсумков для магазинов",
		PREPOSITIONAL = "ящике подсумков для магазинов",
	)

/////// Weapons: Specialist

/datum/supply_packs/security/armory/ballistic
	name = "Служебные дробовики"
	contains = list(
		/obj/item/gun/projectile/shotgun/riot,
		/obj/item/gun/projectile/shotgun/riot,
		/obj/item/gun/projectile/shotgun/winchester,
		/obj/item/gun/projectile/shotgun/winchester,
		/obj/item/storage/belt/bandolier,
		/obj/item/storage/belt/bandolier,
		/obj/item/storage/belt/bandolier,
	)
	cost = 50
	containername = "ящик служебных дробовиков"
	container_ru_names = list(
		NOMINATIVE = "ящик служебных дробовиков",
		GENITIVE = "ящика служебных дробовиков",
		DATIVE = "ящику служебных дробовиков",
		ACCUSATIVE = "ящик служебных дробовиков",
		INSTRUMENTAL = "ящиком служебных дробовиков",
		PREPOSITIONAL = "ящике служебных дробовиков",
	)

/datum/supply_packs/security/armory/ballisticauto
	name = "Боевые дробовики"
	contains = list(
		/obj/item/gun/projectile/shotgun/automatic/combat,
		/obj/item/gun/projectile/shotgun/automatic/combat,
		/obj/item/gun/projectile/shotgun/automatic/combat,
		/obj/item/storage/belt/bandolier,
		/obj/item/storage/belt/bandolier,
		/obj/item/storage/belt/bandolier,
	)
	cost = 100
	containername = "ящик боевых дробовиков"
	container_ru_names = list(
		NOMINATIVE = "ящик боевых дробовиков",
		GENITIVE = "ящика боевых дробовиков",
		DATIVE = "ящику боевых дробовиков",
		ACCUSATIVE = "ящик боевых дробовиков",
		INSTRUMENTAL = "ящиком боевых дробовиков",
		PREPOSITIONAL = "ящике боевых дробовиков",
	)

/datum/supply_packs/security/armory/buckshotammo
	name = "Снаряды с картечью"
	contains = list(
		/obj/item/ammo_box/speedloader/shotgun/buck,
		/obj/item/ammo_box/shotgun/buck,
		/obj/item/ammo_box/shotgun/buck,
		/obj/item/ammo_box/shotgun/buck,
		/obj/item/ammo_box/shotgun/buck,
		/obj/item/ammo_box/shotgun/buck,
	)
	cost = 45
	containername = "ящик снарядов с картечью"
	container_ru_names = list(
		NOMINATIVE = "ящик снарядов с картечью",
		GENITIVE = "ящика снарядов с картечью",
		DATIVE = "ящику снарядов с картечью",
		ACCUSATIVE = "ящик снарядов с картечью",
		INSTRUMENTAL = "ящиком снарядов с картечью",
		PREPOSITIONAL = "ящике снарядов с картечью",
	)

/datum/supply_packs/security/armory/slugammo
	name = "Ружейные пули"
	contains = list(
		/obj/item/ammo_box/speedloader/shotgun/slug,
		/obj/item/ammo_box/shotgun,
		/obj/item/ammo_box/shotgun,
		/obj/item/ammo_box/shotgun,
		/obj/item/ammo_box/shotgun,
		/obj/item/ammo_box/shotgun,
	)
	cost = 45
	containername = "ящик ружейных пуль"
	container_ru_names = list(
		NOMINATIVE = "ящик ружейных пуль",
		GENITIVE = "ящика ружейных пуль",
		DATIVE = "ящику ружейных пуль",
		ACCUSATIVE = "ящик ружейных пуль",
		INSTRUMENTAL = "ящиком ружейных пуль",
		PREPOSITIONAL = "ящике ружейных пуль",
	)

/datum/supply_packs/security/armory/expenergy
	name = "Энергетические карабины"
	contains = list(
		/obj/item/gun/energy/gun,
		/obj/item/gun/energy/gun,
		/obj/item/gun/energy/gun,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "ящик энергетических карабинов"
	container_ru_names = list(
		NOMINATIVE = "ящик энергетических карабинов",
		GENITIVE = "ящика энергетических карабинов",
		DATIVE = "ящику энергетических карабинов",
		ACCUSATIVE = "ящик энергетических карабинов",
		INSTRUMENTAL = "ящиком энергетических карабинов",
		PREPOSITIONAL = "ящике энергетических карабинов",
	)

/datum/supply_packs/security/armory/epistol	// costs 3/5ths of the normal e-guns for 3/4ths the total ammo, making it cheaper to arm more people, but less convient for any one person
	name = "Энергетические пистолеты"
	contains = list(
		/obj/item/gun/energy/gun/mini,
		/obj/item/gun/energy/gun/mini,
		/obj/item/gun/energy/gun/mini,
	)
	cost = 15
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "ящик энергетических пистолетов"
	container_ru_names = list(
		NOMINATIVE = "ящик энергетических пистолетов",
		GENITIVE = "ящика энергетических пистолетов",
		DATIVE = "ящику энергетических пистолетов",
		ACCUSATIVE = "ящик энергетических пистолетов",
		INSTRUMENTAL = "ящиком энергетических пистолетов",
		PREPOSITIONAL = "ящике энергетических пистолетов",
	)

/datum/supply_packs/security/armory/eweapons
	name = "Зажигательное вооружение"
	contains = list(
		/obj/item/flamethrower/full,
		/obj/item/tank/internals/plasma,
		/obj/item/tank/internals/plasma,
		/obj/item/tank/internals/plasma,
		/obj/item/grenade/chem_grenade/incendiary,
		/obj/item/grenade/chem_grenade/incendiary,
		/obj/item/grenade/chem_grenade/incendiary,
	)
	cost = 30	// its a fecking flamethrower and some plasma, why the shit did this cost so much before!?
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "ящик зажигательного вооружения"
	container_ru_names = list(
		NOMINATIVE = "ящик зажигательного вооружения",
		GENITIVE = "ящика зажигательного вооружения",
		DATIVE = "ящику зажигательного вооружения",
		ACCUSATIVE = "ящик зажигательного вооружения",
		INSTRUMENTAL = "ящиком зажигательного вооружения",
		PREPOSITIONAL = "ящике зажигательного вооружения",
	)
	access = ACCESS_HEADS

/datum/supply_packs/security/armory/wt550
	name = "Пистолет-пулемёты WT-550"
	contains = list(
		/obj/item/gun/projectile/automatic/wt550,
		/obj/item/gun/projectile/automatic/wt550,
	)
	cost = 35
	containername = "ящик WT-550"
	container_ru_names = list(
		NOMINATIVE = "ящик WT-550",
		GENITIVE = "ящика WT-550",
		DATIVE = "ящику WT-550",
		ACCUSATIVE = "ящик WT-550",
		INSTRUMENTAL = "ящиком WT-550",
		PREPOSITIONAL = "ящике WT-550",
	)

/datum/supply_packs/security/armory/ga12
	name = "Дробовики Tkach Ya-Sui GA 12"
	contains = list(
		/obj/item/gun/projectile/revolver/ga12,
		/obj/item/gun/projectile/revolver/ga12,
	)
	cost = 80
	containername = "ящик Tkach Ya-Sui GA 12"
	container_ru_names = list(
		NOMINATIVE = "ящик Tkach Ya-Sui GA 12",
		GENITIVE = "ящика Tkach Ya-Sui GA 12",
		DATIVE = "ящику Tkach Ya-Sui GA 12",
		ACCUSATIVE = "ящик Tkach Ya-Sui GA 12",
		INSTRUMENTAL = "ящиком Tkach Ya-Sui GA 12",
		PREPOSITIONAL = "ящике Tkach Ya-Sui GA 12",
	)
	required_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_MATERIALS = 3)

/datum/supply_packs/security/armory/lr30
	name = "Лазерные карабины LR-30"
	contains = list(
		/obj/item/gun/projectile/automatic/lr30,
		/obj/item/gun/projectile/automatic/lr30,
		/obj/item/gun/projectile/automatic/lr30,
		/obj/item/ammo_box/magazine/lr30mag,
		/obj/item/ammo_box/magazine/lr30mag,
		/obj/item/ammo_box/magazine/lr30mag,
		/obj/item/ammo_box/magazine/lr30mag,
		/obj/item/ammo_box/magazine/lr30mag,
		/obj/item/ammo_box/magazine/lr30mag,
		/obj/item/ammo_box/magazine/lr30mag,
	)
	cost = 65
	containername = "ящик LR-30"
	container_ru_names = list(
		NOMINATIVE = "ящик LR-30",
		GENITIVE = "ящика LR-30",
		DATIVE = "ящику LR-30",
		ACCUSATIVE = "ящик LR-30",
		INSTRUMENTAL = "ящиком LR-30",
		PREPOSITIONAL = "ящике LR-30",
	)

/datum/supply_packs/security/armory/wt550ammo
	name = "Боеприпасы для WT-550"
	contains = list(
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/ammo_box/magazine/wt550m9,
		/obj/item/ammo_box/c46x30mm,
		/obj/item/ammo_box/c46x30mm,
		/obj/item/ammo_box/c46x30mm,
		/obj/item/ammo_box/c46x30mm,
	)
	cost = 100
	containername = "ящик боеприпасов для WT-550"
	container_ru_names = list(
		NOMINATIVE = "ящик боеприпасов для WT-550",
		GENITIVE = "ящика боеприпасов для WT-550",
		DATIVE = "ящику боеприпасов для WT-550",
		ACCUSATIVE = "ящик боеприпасов для WT-550",
		INSTRUMENTAL = "ящиком боеприпасов для WT-550",
		PREPOSITIONAL = "ящике боеприпасов для WT-550",
	)

/datum/supply_packs/security/armory/wt550apammo
	name = "Бронебойные боеприпасы для WT-550"
	contains = list(
		/obj/item/ammo_box/magazine/wt550m9/wtap,
		/obj/item/ammo_box/magazine/wt550m9/wtap,
		/obj/item/ammo_box/magazine/wt550m9/wtap,
		/obj/item/ammo_box/magazine/wt550m9/wtap,
		/obj/item/ammo_box/magazine/wt550m9/wtap,
		/obj/item/ammo_box/magazine/wt550m9/wtap,
		/obj/item/ammo_box/magazine/wt550m9/wtap,
		/obj/item/ammo_box/magazine/wt550m9/wtap,
		/obj/item/ammo_box/ap46x30mm,
		/obj/item/ammo_box/ap46x30mm,
		/obj/item/ammo_box/ap46x30mm,
		/obj/item/ammo_box/ap46x30mm,
	)
	cost = 140
	containername = "ящик бронебойных боеприпасов для WT-550"
	container_ru_names = list(
		NOMINATIVE = "ящик бронебойных боеприпасов для WT-550",
		GENITIVE = "ящика бронебойных боеприпасов для WT-550",
		DATIVE = "ящику бронебойных боеприпасов для WT-550",
		ACCUSATIVE = "ящик бронебойных боеприпасов для WT-550",
		INSTRUMENTAL = "ящиком бронебойных боеприпасов для WT-550",
		PREPOSITIONAL = "ящике бронебойных боеприпасов для WT-550",
	)
	required_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_MATERIALS = 3)

/datum/supply_packs/security/armory/security_voucher
	name = "Оружейные ваучеры"
	contains = list(
		/obj/item/security_voucher,
		/obj/item/security_voucher,
		/obj/item/security_voucher,
		/obj/item/security_voucher,
		/obj/item/security_voucher,
	)
	cost = 100
	containername = "ящик оружейных ваучеров"
	container_ru_names = list(
		NOMINATIVE = "ящик оружейных ваучеров",
		GENITIVE = "ящика оружейных ваучеров",
		DATIVE = "ящику оружейных ваучеров",
		ACCUSATIVE = "ящик оружейных ваучеров",
		INSTRUMENTAL = "ящиком оружейных ваучеров",
		PREPOSITIONAL = "ящике оружейных ваучеров",
	)

/datum/supply_packs/security/armory/m79
	name = "Гранатометы М79"
	contains = list(
		/obj/item/gun/projectile/bombarda/secgl/m79,
		/obj/item/gun/projectile/bombarda/secgl/m79,
	)
	cost = 80
	containername = "ящик с гранатометами М79"
	container_ru_names = list(
		NOMINATIVE = "ящик с гранатометами М79",
		GENITIVE = "ящика с гранатометами М79",
		DATIVE = "ящику с гранатометами М79",
		ACCUSATIVE = "ящик с гранатометами М79",
		INSTRUMENTAL = "ящиком с гранатометами М79",
		PREPOSITIONAL = "ящике с гранатометами М79",
	)
	required_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_MATERIALS = 3)

/datum/supply_packs/security/armory/grenades40mm_nonlethal
	name = "40-мм нелетальные гранаты"
	contains = list(
		/obj/item/ammo_box/secgl/solid,
		/obj/item/ammo_box/secgl/flash,
		/obj/item/ammo_box/secgl/gas,
		/obj/item/ammo_box/secgl/barricade,
		/obj/item/ammo_box/secgl/paint,
	)
	cost = 50
	containername = "ящик с 40-мм нелетальными гранатами"
	container_ru_names = list(
		NOMINATIVE = "ящик с 40-мм нелетальными гранатами",
		GENITIVE = "ящика с 40-мм нелетальными гранатами",
		DATIVE = "ящику с 40-мм нелетальными гранатами",
		ACCUSATIVE = "ящик с 40-мм нелетальными гранатами",
		INSTRUMENTAL = "ящиком с 40-мм нелетальными гранатами",
		PREPOSITIONAL = "ящике с 40-мм нелетальными гранатами",
	)
	required_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_MATERIALS = 3)

/datum/supply_packs/security/armory/SP_91_RC
	name = "Пистолет-пулемёты SP-91-RC"
	contains = list(
		/obj/item/gun/projectile/automatic/sp91rc,
		/obj/item/gun/projectile/automatic/sp91rc,
		/obj/item/gun/projectile/automatic/sp91rc,
	)
	cost = 50
	containername = "ящик SP-91-RC"
	container_ru_names = list(
		NOMINATIVE = "ящик SP-91-RC",
		GENITIVE = "ящика SP-91-RC",
		DATIVE = "ящику SP-91-RC",
		ACCUSATIVE = "ящик SP-91-RC",
		INSTRUMENTAL = "ящиком SP-91-RC",
		PREPOSITIONAL = "ящике SP-91-RC",
	)

/datum/supply_packs/security/armory/sparkle_a12
	name = "Пистолет-пулемёты A9 \"Искра\""
	contains = list(
		/obj/item/gun/projectile/automatic/sparkle_a12,
		/obj/item/gun/projectile/automatic/sparkle_a12,
		/obj/item/gun/projectile/automatic/sparkle_a12,
	)
	cost = 50
	containername = "ящик A9 \"Искра\""
	container_ru_names = list(
		NOMINATIVE = "ящик A9 \"Искра\"",
		GENITIVE = "ящика A9 \"Искра\"",
		DATIVE = "ящику A9 \"Искра\"",
		ACCUSATIVE = "ящик A9 \"Искра\"",
		INSTRUMENTAL = "ящиком A9 \"Искра\"",
		PREPOSITIONAL = "ящике A9 \"Искра\"",
	)

/////// Implants & etc

/datum/supply_packs/security/armory/mindshield
	name = "Имплант \"Щит разума\""
	contains = list(
		/obj/item/storage/lockbox/mindshield,
	)
	cost = 60
	containername = "ящик с имплантом \"Щит разума\""
	container_ru_names = list(
		NOMINATIVE = "ящик с имплантом \"Щит разума\"",
		GENITIVE = "ящика с имплантом \"Щит разума\"",
		DATIVE = "ящику с имплантом \"Щит разума\"",
		ACCUSATIVE = "ящик с имплантом \"Щит разума\"",
		INSTRUMENTAL = "ящиком с имплантом \"Щит разума\"",
		PREPOSITIONAL = "ящике с имплантом \"Щит разума\"",
	)
	required_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_PROGRAMMING = 4)

/datum/supply_packs/security/armory/suppression
	name = "Имплант \"Подавления\""
	contains = list(
		/obj/item/storage/lockbox/suppression/cargo,
	)
	cost = 200
	containername = "ящик с имплантом \"Подавления\""
	container_ru_names = list(
		NOMINATIVE = "ящик с имплантом \"Подавления\"",
		GENITIVE = "ящика с имплантом \"Подавления\"",
		DATIVE = "ящику с имплантом \"Подавления\"",
		ACCUSATIVE = "ящик с имплантом \"Подавления\"",
		INSTRUMENTAL = "ящиком с имплантом \"Подавления\"",
		PREPOSITIONAL = "ящике с имплантом \"Подавления\"",
	)
	required_tech = list(RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_BIOTECH = 7)

/datum/supply_packs/security/armory/trackingimp
	name = "Имплант слежения"
	contains = list(
		/obj/item/storage/box/trackimp,
	)
	cost = 30
	containername = "ящик с имплантом слежения"
	container_ru_names = list(
		NOMINATIVE = "ящик с имплантом слежения",
		GENITIVE = "ящика с имплантом слежения",
		DATIVE = "ящику с имплантом слежения",
		ACCUSATIVE = "ящик с имплантом слежения",
		INSTRUMENTAL = "ящиком с имплантом слежения",
		PREPOSITIONAL = "ящике с имплантом слежения",
	)
	required_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_BIOTECH = 2, RESEARCH_TREE_PROGRAMMING = 2, RESEARCH_TREE_MAGNETS = 2)

/datum/supply_packs/security/armory/chemimp
	name = "Химический имплант"
	contains = list(
		/obj/item/storage/box/chemimp,
	)
	cost = 30
	containername = "ящик с химическим имплантом"
	container_ru_names = list(
		NOMINATIVE = "ящик с химическим имплантом",
		GENITIVE = "ящика с химическим имплантом",
		DATIVE = "ящику с химическим имплантом",
		ACCUSATIVE = "ящик с химическим имплантом",
		INSTRUMENTAL = "ящиком с химическим имплантом",
		PREPOSITIONAL = "ящике с химическим имплантом",
	)
	required_tech = list(RESEARCH_TREE_MATERIALS = 3, RESEARCH_TREE_BIOTECH = 4)

/datum/supply_packs/security/armory/exileimp
	name = "Имплант изгнания"
	contains = list(
		/obj/item/storage/box/exileimp,
	)
	cost = 30
	containername = "ящик с имплантом изгнания"
	container_ru_names = list(
		NOMINATIVE = "ящик с имплантом изгнания",
		GENITIVE = "ящика с имплантом изгнания",
		DATIVE = "ящику с имплантом изгнания",
		ACCUSATIVE = "ящик с имплантом изгнания",
		INSTRUMENTAL = "ящиком с имплантом изгнания",
		PREPOSITIONAL = "ящике с имплантом изгнания",
	)
	required_tech = list(RESEARCH_TREE_MATERIALS = 2, RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_PROGRAMMING = 6)

/datum/supply_packs/security/armory/ion_carbine
	name = "Ионные карабины"
	cost = 120
	contains = list(
		/obj/item/gun/energy/ionrifle/carbine,
		/obj/item/gun/energy/ionrifle/carbine,
		/obj/item/gun/energy/ionrifle/carbine,
	)
	containername = "ящик ионных карабинов"
	container_ru_names = list(
		NOMINATIVE = "ящик ионных карабинов",
		GENITIVE = "ящика ионных карабинов",
		DATIVE = "ящику ионных карабинов",
		ACCUSATIVE = "ящик ионных карабинов",
		INSTRUMENTAL = "ящиком ионных карабинов",
		PREPOSITIONAL = "ящике ионных карабинов",
	)
	required_tech = list(RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_MAGNETS = 4)

/datum/supply_packs/security/armory/tele_shield
	name = "Телескопические щиты"
	cost = 80
	contains = list(
		/obj/item/shield/riot/tele,
		/obj/item/shield/riot/tele,
		/obj/item/shield/riot/tele,
	)
	containername = "ящик телескопических щитов"
	container_ru_names = list(
		NOMINATIVE = "ящик телескопических щитов",
		GENITIVE = "ящика телескопических щитов",
		DATIVE = "ящику телескопических щитов",
		ACCUSATIVE = "ящик телескопических щитов",
		INSTRUMENTAL = "ящиком телескопических щитов",
		PREPOSITIONAL = "ящике телескопических щитов",
	)
	required_tech = list(RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MATERIALS = 3)

/datum/supply_packs/security/armory/shotgun_shells
	name = "Различные боеприпасы 12-го калибра"
	cost = 200
	contains = list(
		/obj/item/ammo_box/shotgun/stunslug,
		/obj/item/ammo_box/shotgun/pulseslug,
		/obj/item/ammo_box/shotgun/dragonsbreath,
		/obj/item/ammo_box/shotgun/ion,
		/obj/item/ammo_box/shotgun/laserslug,
	)
	containername = "ящик боеприпасов 12-го калибра"
	container_ru_names = list(
		NOMINATIVE = "ящик боеприпасов 12-го калибра",
		GENITIVE = "ящика боеприпасов 12-го калибра",
		DATIVE = "ящику боеприпасов 12-го калибра",
		ACCUSATIVE = "ящик боеприпасов 12-го калибра",
		INSTRUMENTAL = "ящиком боеприпасов 12-го калибра",
		PREPOSITIONAL = "ящике боеприпасов 12-го калибра",
	)
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_COMBAT = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_MATERIALS = 4)

/datum/supply_packs/security/securitybarriers
	name = "Охранные барьеры"
	contains = list(
		/obj/item/grenade/barrier,
		/obj/item/grenade/barrier,
		/obj/item/grenade/barrier,
		/obj/item/grenade/barrier,
	)
	cost = 10
	containername = "ящик охранных барьеров"
	container_ru_names = list(
		NOMINATIVE = "ящик охранных барьеров",
		GENITIVE = "ящика охранных барьеров",
		DATIVE = "ящику охранных барьеров",
		ACCUSATIVE = "ящик охранных барьеров",
		INSTRUMENTAL = "ящиком охранных барьеров",
		PREPOSITIONAL = "ящике охранных барьеров",
	)

/datum/supply_packs/security/securityclothes
	name = "Униформа службы безопасности"
	contains = list(
		/obj/item/clothing/under/rank/security/corp,
		/obj/item/clothing/under/rank/security/corp,
		/obj/item/clothing/head/soft/sec/corp,
		/obj/item/clothing/head/soft/sec/corp,
		/obj/item/clothing/under/rank/warden/corp,
		/obj/item/clothing/head/beret/sec/warden,
		/obj/item/clothing/under/rank/head_of_security/corp,
		/obj/item/clothing/head/HoS/beret,
	)
	cost = 30
	containername = "ящик униформы СБ"
	container_ru_names = list(
		NOMINATIVE = "ящик униформы СБ",
		GENITIVE = "ящика униформы СБ",
		DATIVE = "ящику униформы СБ",
		ACCUSATIVE = "ящик униформы СБ",
		INSTRUMENTAL = "ящиком униформы СБ",
		PREPOSITIONAL = "ящике униформы СБ",
	)

/datum/supply_packs/security/officerpack // Starter pack for an officer. Contains everything in a locker but backpack (officer already start with one). Convenient way to equip new officer on highpop.
	name = "Снаряжение офицера СБ"
	contains = list(
		/obj/item/clothing/suit/armor/vest/security,
		/obj/item/radio/headset/headset_sec/alt,
		/obj/item/clothing/head/soft/sec,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/flash,
		/obj/item/grenade/flashbang,
		/obj/item/storage/belt/security/sec,
		/obj/item/holosign_creator/security,
		/obj/item/clothing/mask/gas/sechailer,
		/obj/item/clothing/glasses/hud/security/sunglasses,
		/obj/item/clothing/head/helmet,
		/obj/item/melee/baton/security/loaded,
		/obj/item/clothing/suit/armor/secjacket,
	)
	cost = 40 // Convenience has a price and this pack is genuinely loaded
	containername = "ящик снаряжения офицера СБ"
	container_ru_names = list(
		NOMINATIVE = "ящик снаряжения офицера СБ",
		GENITIVE = "ящика снаряжения офицера СБ",
		DATIVE = "ящику снаряжения офицера СБ",
		ACCUSATIVE = "ящик снаряжения офицера СБ",
		INSTRUMENTAL = "ящиком снаряжения офицера СБ",
		PREPOSITIONAL = "ящике снаряжения офицера СБ",
	)

/datum/supply_packs/security/minigun
	name = "Гатлинг—лазер"
	contains = list(
		/obj/item/gun/energy/gun/minigun,
	)
	cost = 350
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 6, RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_MAGNETS = 6)
	containertype = /obj/structure/closet/crate/secure/weapon/veihit
	containername = "ящик с гатлинг—лазером"
	container_ru_names = list(
		NOMINATIVE = "ящик с гатлинг—лазером",
		GENITIVE = "ящика с гатлинг—лазером",
		DATIVE = "ящику с гатлинг—лазером",
		ACCUSATIVE = "ящик с гатлинг—лазером",
		INSTRUMENTAL = "ящиком с гатлинг—лазером",
		PREPOSITIONAL = "ящике с гатлинг—лазером",
	)

//////////////////////////////////////////////////////////////////////////////
// MARK: Engineering
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/engineering
	name = "HEADER"
	group = SUPPLY_ENGINEER
	announce_beacons = list("Engineering" = list("Engineering", "Chief Engineer's Desk"))
	containertype = /obj/structure/closet/crate/engineering

/datum/supply_packs/engineering/modsuit_eng
	name = "Инженерные МЭК"
	contains = list(
		/obj/item/mod/control/pre_equipped/engineering,
		/obj/item/mod/control/pre_equipped/engineering,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
	)
	cost = 130
	required_tech = list(RESEARCH_TREE_TOXINS = 5, RESEARCH_TREE_ENGINEERING = 4)
	containername = "ящик инженерных МЭК"

	container_ru_names = list(
		NOMINATIVE = "ящик инженерных МЭК",
		GENITIVE = "ящика инженерных МЭК",
		DATIVE = "ящику инженерных МЭК",
		ACCUSATIVE = "ящик инженерных МЭК",
		INSTRUMENTAL = "ящиком инженерных МЭК",
		PREPOSITIONAL = "ящике инженерных МЭК",
	)
	access = ACCESS_ENGINE_EQUIP

/datum/supply_packs/engineering/modsuit_atmos
	name = "Атмосферные МЭК"
	cost = 130
	contains = list(
		/obj/item/mod/control/pre_equipped/atmospheric,
		/obj/item/mod/control/pre_equipped/atmospheric,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
	)
	required_tech = list(RESEARCH_TREE_TOXINS = 6, RESEARCH_TREE_PLASMA = 4)
	containername = "ящик атмосферных МЭК"
	container_ru_names = list(
		NOMINATIVE = "ящик атмосферных МЭК",
		GENITIVE = "ящика атмосферных МЭК",
		DATIVE = "ящику атмосферных МЭК",
		ACCUSATIVE = "ящик атмосферных МЭК",
		INSTRUMENTAL = "ящиком атмосферных МЭК",
		PREPOSITIONAL = "ящике атмосферных МЭК",
	)
	access = ACCESS_ATMOSPHERICS

/datum/supply_packs/engineering/fueltank
	name = "Бак сварочного топлива"
	contains = list(
		/obj/structure/reagent_dispensers/fueltank,
	)
	cost = 8
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с баком сварочного топлива"
	container_ru_names = list(
		NOMINATIVE = "ящик с баком сварочного топлива",
		GENITIVE = "ящика с баком сварочного топлива",
		DATIVE = "ящику с баком сварочного топлива",
		ACCUSATIVE = "ящик с баком сварочного топлива",
		INSTRUMENTAL = "ящиком с баком сварочного топлива",
		PREPOSITIONAL = "ящике с баком сварочного топлива",
	)

/datum/supply_packs/engineering/tools
	name = "Ящики для инструментов"
	contains = list(
		/obj/item/storage/toolbox/electrical,
		/obj/item/storage/toolbox/electrical,
		/obj/item/storage/toolbox/emergency,
		/obj/item/storage/toolbox/emergency,
		/obj/item/storage/toolbox/mechanical,
		/obj/item/storage/toolbox/mechanical,
	)
	cost = 10
	containername = "ящик с набором ящиков для инструментов"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором ящиков для инструментов",
		GENITIVE = "ящика с набором ящиков для инструментов",
		DATIVE = "ящику с набором ящиков для инструментов",
		ACCUSATIVE = "ящик с набором ящиков для инструментов",
		INSTRUMENTAL = "ящиком с набором ящиков для инструментов",
		PREPOSITIONAL = "ящике с набором ящиков для инструментов",
	)

/datum/supply_packs/vending/engivend
	name = "Наборы пополнения инженерных торгоматов"
	cost = 20
	contains = list(
		/obj/item/vending_refill/engivend,
		/obj/item/vending_refill/youtool,
	)
	containername = "ящик наборов пополнения инженерных торгоматов"
	container_ru_names = list(
		NOMINATIVE = "ящик наборов пополнения инженерных торгоматов",
		GENITIVE = "ящика наборов пополнения инженерных торгоматов",
		DATIVE = "ящику наборов пополнения инженерных торгоматов",
		ACCUSATIVE = "ящик наборов пополнения инженерных торгоматов",
		INSTRUMENTAL = "ящиком наборов пополнения инженерных торгоматов",
		PREPOSITIONAL = "ящике наборов пополнения инженерных торгоматов",
	)

/datum/supply_packs/engineering/powergamermitts
	name = "Изоляционные перчатки"
	contains = list(
		/obj/item/clothing/gloves/color/yellow,
		/obj/item/clothing/gloves/color/yellow,
		/obj/item/clothing/gloves/color/yellow,
	)
	cost = 30
	containername = "ящик изоляционных перчаток"
	container_ru_names = list(
		NOMINATIVE = "ящик изоляционных перчаток",
		GENITIVE = "ящика изоляционных перчаток",
		DATIVE = "ящику изоляционных перчаток",
		ACCUSATIVE = "ящик изоляционных перчаток",
		INSTRUMENTAL = "ящиком изоляционных перчаток",
		PREPOSITIONAL = "ящике изоляционных перчаток",
	)
	containertype = /obj/structure/closet/crate/engineering/electrical

/datum/supply_packs/engineering/power
	name = "Батареи АА"
	contains = list(
		/obj/item/stock_parts/cell/high,
		/obj/item/stock_parts/cell/high,
		/obj/item/stock_parts/cell/high,
	)
	cost = 25
	containername = "ящик батарей АА"
	container_ru_names = list(
		NOMINATIVE = "ящик батарей АА",
		GENITIVE = "ящика батарей АА",
		DATIVE = "ящику батарей АА",
		ACCUSATIVE = "ящик батарей АА",
		INSTRUMENTAL = "ящиком батарей АА",
		PREPOSITIONAL = "ящике батарей АА",
	)
	containertype = /obj/structure/closet/crate/engineering/electrical

/datum/supply_packs/engineering/engiequipment
	name = "Инженерное снаряжение"
	contains = list(
		/obj/item/storage/belt/utility,
		/obj/item/storage/belt/utility,
		/obj/item/storage/belt/utility,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/suit/storage/hazardvest,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/head/welding,
		/obj/item/clothing/head/hardhat,
		/obj/item/clothing/head/hardhat,
		/obj/item/clothing/head/hardhat,
	)
	cost = 10
	containername = "ящик инженерного снаряжения"
	container_ru_names = list(
		NOMINATIVE = "ящик инженерного снаряжения",
		GENITIVE = "ящика инженерного снаряжения",
		DATIVE = "ящику инженерного снаряжения",
		ACCUSATIVE = "ящик инженерного снаряжения",
		INSTRUMENTAL = "ящиком инженерного снаряжения",
		PREPOSITIONAL = "ящике инженерного снаряжения",
	)

/datum/supply_packs/engineering/solar
	name = "Набор солнечных панелей"
	contains = list(
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly,
		/obj/item/solar_assembly, // 21 Solar Assemblies. 1 Extra for the controller
		/obj/item/circuitboard/solar_control,
		/obj/item/tracker_electronics,
		/obj/item/paper/solar,
	)
	cost = 15
	containername = "ящик с набором солнечных панелей"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором солнечных панелей",
		GENITIVE = "ящика с набором солнечных панелей",
		DATIVE = "ящику с набором солнечных панелей",
		ACCUSATIVE = "ящик с набором солнечных панелей",
		INSTRUMENTAL = "ящиком с набором солнечных панелей",
		PREPOSITIONAL = "ящике с набором солнечных панелей",
	)
	containertype = /obj/structure/closet/crate/engineering/electrical

/datum/supply_packs/engineering/engine
	name = "Излучатели"
	contains = list(
		/obj/machinery/power/emitter,
		/obj/machinery/power/emitter,
	)
	cost = 30
	containername = "ящик излучателей"
	container_ru_names = list(
		NOMINATIVE = "ящик излучателей",
		GENITIVE = "ящика излучателей",
		DATIVE = "ящику излучателей",
		ACCUSATIVE = "ящик излучателей",
		INSTRUMENTAL = "ящиком излучателей",
		PREPOSITIONAL = "ящике излучателей",
	)
	access = ACCESS_CONSTRUCTION
	containertype = /obj/structure/closet/crate/secure/engineering

/datum/supply_packs/engineering/engine/field_gen
	name = "Генераторы силового поля"
	contains = list(
		/obj/machinery/field/generator,
		/obj/machinery/field/generator,
	)
	cost = 35
	containername = "ящик генераторов силового поля"
	container_ru_names = list(
		NOMINATIVE = "ящик генераторов силового поля",
		GENITIVE = "ящика генераторов силового поля",
		DATIVE = "ящику генераторов силового поля",
		ACCUSATIVE = "ящик генераторов силового поля",
		INSTRUMENTAL = "ящиком генераторов силового поля",
		PREPOSITIONAL = "ящике генераторов силового поля",
	)

/datum/supply_packs/engineering/engine/sing_gen
	name = "Генератор сингулярности"
	contains = list(
		/obj/machinery/the_singularitygen,
	)
	cost = 150
	containername = "ящик с генератором сингулярности"
	container_ru_names = list(
		NOMINATIVE = "ящик с генератором сингулярности",
		GENITIVE = "ящика с генератором сингулярности",
		DATIVE = "ящику с генератором сингулярности",
		ACCUSATIVE = "ящик с генератором сингулярности",
		INSTRUMENTAL = "ящиком с генератором сингулярности",
		PREPOSITIONAL = "ящике с генератором сингулярности",
	)
	access = ACCESS_CE
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 6, RESEARCH_TREE_ENGINEERING = 7)

/datum/supply_packs/engineering/engine/tesla
	name = "Тесла-генератор"
	contains = list(
		/obj/machinery/the_singularitygen/tesla,
	)
	cost = 150
	containername = "ящик с тесла-генератором"
	container_ru_names = list(
		NOMINATIVE = "ящик с тесла-генератором",
		GENITIVE = "ящика с тесла-генератором",
		DATIVE = "ящику с тесла-генератором",
		ACCUSATIVE = "ящик с тесла-генератором",
		INSTRUMENTAL = "ящиком с тесла-генератором",
		PREPOSITIONAL = "ящике с тесла-генератором",
	)
	access = ACCESS_CE
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 7, RESEARCH_TREE_MAGNETS = 5)

/datum/supply_packs/engineering/engine/coil
	name = "Тесла-катушки"
	contains = list(
		/obj/machinery/power/energy_accumulator/tesla_coil,
		/obj/machinery/power/energy_accumulator/tesla_coil,
		/obj/machinery/power/energy_accumulator/tesla_coil,
	)
	cost = 45
	containername = "ящик тесла-катушек"
	container_ru_names = list(
		NOMINATIVE = "ящик тесла-катушек",
		GENITIVE = "ящика тесла-катушек",
		DATIVE = "ящику тесла-катушек",
		ACCUSATIVE = "ящик тесла-катушек",
		INSTRUMENTAL = "ящиком тесла-катушек",
		PREPOSITIONAL = "ящике тесла-катушек",
	)

/datum/supply_packs/engineering/engine/grounding
	name = "Заземлители"
	contains = list(
		/obj/machinery/power/energy_accumulator/grounding_rod,
		/obj/machinery/power/energy_accumulator/grounding_rod,
	)
	cost = 10
	containername = "ящик заземлителей"
	container_ru_names = list(
		NOMINATIVE = "ящик заземлителей",
		GENITIVE = "ящика заземлителей",
		DATIVE = "ящику заземлителей",
		ACCUSATIVE = "ящик заземлителей",
		INSTRUMENTAL = "ящиком заземлителей",
		PREPOSITIONAL = "ящике заземлителей",
	)

/datum/supply_packs/engineering/engine/collector
	name = "Радиационные накопители"
	contains = list(
		/obj/machinery/power/energy_accumulator/rad_collector,
		/obj/machinery/power/energy_accumulator/rad_collector,
		/obj/machinery/power/energy_accumulator/rad_collector,
	)
	cost = 45
	containername = "ящик радиационных накопителей"
	container_ru_names = list(
		NOMINATIVE = "ящик радиационных накопителей",
		GENITIVE = "ящика радиационных накопителей",
		DATIVE = "ящику радиационных накопителей",
		ACCUSATIVE = "ящик радиационных накопителей",
		INSTRUMENTAL = "ящиком радиационных накопителей",
		PREPOSITIONAL = "ящике радиационных накопителей",
	)

/datum/supply_packs/engineering/engine/PA
	name = "Детали ускорителя частиц"
	contains = list(
		/obj/structure/particle_accelerator/fuel_chamber,
		/obj/machinery/particle_accelerator/control_box,
		/obj/structure/particle_accelerator/particle_emitter/center,
		/obj/structure/particle_accelerator/particle_emitter/left,
		/obj/structure/particle_accelerator/particle_emitter/right,
		/obj/structure/particle_accelerator/power_box,
		/obj/structure/particle_accelerator/end_cap,
	)
	cost = 50
	containername = "ящик с деталями ускорителя частиц"
	container_ru_names = list(
		NOMINATIVE = "ящик с деталями ускорителя частиц",
		GENITIVE = "ящика с деталями ускорителя частиц",
		DATIVE = "ящику с деталями ускорителя частиц",
		ACCUSATIVE = "ящик с деталями ускорителя частиц",
		INSTRUMENTAL = "ящиком с деталями ускорителя частиц",
		PREPOSITIONAL = "ящике с деталями ускорителя частиц",
	)
	access = ACCESS_CE
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_MATERIALS = 3)

/datum/supply_packs/engineering/inflatable
	name = "Надувные заграждения"
	contains = list(
		/obj/item/storage/briefcase/inflatable,
		/obj/item/storage/briefcase/inflatable,
		/obj/item/storage/briefcase/inflatable,
	)
	cost = 10
	containername = "ящик надувных заграждений"
	container_ru_names = list(
		NOMINATIVE = "ящик надувных заграждений",
		GENITIVE = "ящика надувных заграждений",
		DATIVE = "ящику надувных заграждений",
		ACCUSATIVE = "ящик надувных заграждений",
		INSTRUMENTAL = "ящиком надувных заграждений",
		PREPOSITIONAL = "ящике надувных заграждений",
	)

/datum/supply_packs/engineering/engine/supermatter_crystal
	name = "Осколок суперматерии"
	contains = list(
		/obj/machinery/atmospherics/supermatter_crystal/shard,
	)
	cost = 150 //So cargo thinks twice before killing themselves with it
	containername = "ящик с осколком суперматерии"
	container_ru_names = list(
		NOMINATIVE = "ящик с осколком суперматерии",
		GENITIVE = "ящика с осколком суперматерии",
		DATIVE = "ящику с осколком суперматерии",
		ACCUSATIVE = "ящик с осколком суперматерии",
		INSTRUMENTAL = "ящиком с осколком суперматерии",
		PREPOSITIONAL = "ящике с осколком суперматерии",
	)
	access = ACCESS_CE
	required_tech = list(RESEARCH_TREE_MATERIALS = 7)

/datum/supply_packs/engineering/engine/teg
	name = "Детали термоэлектрического генератора"
	contains = list(
		/obj/machinery/power/generator,
		/obj/item/pipe/circulator,
		/obj/item/pipe/circulator,
	)
	cost = 225
	containername = "ящик деталей термоэлектрического генератора"
	container_ru_names = list(
		NOMINATIVE = "ящик деталей термоэлектрического генератора",
		GENITIVE = "ящика деталей термоэлектрического генератора",
		DATIVE = "ящику деталей термоэлектрического генератора",
		ACCUSATIVE = "ящик деталей термоэлектрического генератора",
		INSTRUMENTAL = "ящиком деталей термоэлектрического генератора",
		PREPOSITIONAL = "ящике деталей термоэлектрического генератора",
	)
	access = ACCESS_CE
	announce_beacons = list("Engineering" = list("Chief Engineer's Desk", "Atmospherics"))
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 6, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MATERIALS = 2)

/datum/supply_packs/engineering/canister/nitrogen
	name = "Канистра азота"
	contains = list(/obj/machinery/portable_atmospherics/canister/nitrogen)
	cost = 5
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с канистрой азота"
	container_ru_names = list(
		NOMINATIVE = "ящик с канистрой азота",
		GENITIVE = "ящика с канистрой азота",
		DATIVE = "ящику с канистрой азота",
		ACCUSATIVE = "ящик с канистрой азота",
		INSTRUMENTAL = "ящиком с канистрой азота",
		PREPOSITIONAL = "ящике с канистрой азота",
	)

/datum/supply_packs/engineering/canister/oxygen
	name = "Канистра кислорода"
	contains = list(/obj/machinery/portable_atmospherics/canister/oxygen)
	cost = 5
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с канистрой кислорода"
	container_ru_names = list(
		NOMINATIVE = "ящик с канистрой кислорода",
		GENITIVE = "ящика с канистрой кислорода",
		DATIVE = "ящику с канистрой кислорода",
		ACCUSATIVE = "ящик с канистрой кислорода",
		INSTRUMENTAL = "ящиком с канистрой кислорода",
		PREPOSITIONAL = "ящике с канистрой кислорода",
	)

/datum/supply_packs/engineering/canister/air
	name = "Канистра воздуха"
	contains = list(/obj/machinery/portable_atmospherics/canister/air)
	cost = 5
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с канистрой воздуха"
	container_ru_names = list(
		NOMINATIVE = "ящик с канистрой воздуха",
		GENITIVE = "ящика с канистрой воздуха",
		DATIVE = "ящику с канистрой воздуха",
		ACCUSATIVE = "ящик с канистрой воздуха",
		INSTRUMENTAL = "ящиком с канистрой воздуха",
		PREPOSITIONAL = "ящике с канистрой воздуха",
	)

/datum/supply_packs/engineering/canister/sleeping_agent
	name = "Канистра оксида азота"
	contains = list(/obj/machinery/portable_atmospherics/canister/sleeping_agent)
	cost = 25
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с канистрой оксида азота"
	container_ru_names = list(
		NOMINATIVE = "ящик с канистрой оксида азота",
		GENITIVE = "ящика с канистрой оксида азота",
		DATIVE = "ящику с канистрой оксида азота",
		ACCUSATIVE = "ящик с канистрой оксида азота",
		INSTRUMENTAL = "ящиком с канистрой оксида азота",
		PREPOSITIONAL = "ящике с канистрой оксида азота",
	)

/datum/supply_packs/engineering/canister/carbon_dioxide
	name = "Канистра углекислого газа"
	contains = list(/obj/machinery/portable_atmospherics/canister/carbon_dioxide)
	cost = 25
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с канистрой углекислого газа"
	container_ru_names = list(
		NOMINATIVE = "ящик с канистрой углекислого газа",
		GENITIVE = "ящика с канистрой углекислого газа",
		DATIVE = "ящику с канистрой углекислого газа",
		ACCUSATIVE = "ящик с канистрой углекислого газа",
		INSTRUMENTAL = "ящиком с канистрой углекислого газа",
		PREPOSITIONAL = "ящике с канистрой углекислого газа",
	)

/datum/supply_packs/engineering/canister/toxins
	name = "Канистра плазмы"
	contains = list(/obj/machinery/portable_atmospherics/canister/toxins)
	cost = 25
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с канистрой плазмы"
	container_ru_names = list(
		NOMINATIVE = "ящик с канистрой плазмы",
		GENITIVE = "ящика с канистрой плазмы",
		DATIVE = "ящику с канистрой плазмы",
		ACCUSATIVE = "ящик с канистрой плазмы",
		INSTRUMENTAL = "ящиком с канистрой плазмы",
		PREPOSITIONAL = "ящике с канистрой плазмы",
	)

/datum/supply_packs/engineering/miner
	required_tech = list(RESEARCH_TREE_TOXINS = 4)
	cost = 150
	containertype = /obj/structure/closet/crate/large

/datum/supply_packs/engineering/miner/nitrogen
	name = "Майнер N2"
	contains = list(/obj/machinery/atmospherics/miner/nitrogen)
	containername = "ящик с майнером N2"
	container_ru_names = list(
		NOMINATIVE = "ящик с майнером N2",
		GENITIVE = "ящика с майнером N2",
		DATIVE = "ящику с майнером N2",
		ACCUSATIVE = "ящик с майнером N2",
		INSTRUMENTAL = "ящиком с майнером N2",
		PREPOSITIONAL = "ящике с майнером N2",
	)

/datum/supply_packs/engineering/miner/oxygen
	name = "Майнер O2"
	contains = list(/obj/machinery/atmospherics/miner/oxygen)
	containername = "ящик с майнером O2"
	container_ru_names = list(
		NOMINATIVE = "ящик с майнером O2",
		GENITIVE = "ящика с майнером O2",
		DATIVE = "ящику с майнером O2",
		ACCUSATIVE = "ящик с майнером O2",
		INSTRUMENTAL = "ящиком с майнером O2",
		PREPOSITIONAL = "ящике с майнером O2",
	)

/datum/supply_packs/engineering/miner/plasma
	name = "Майнер плазмы"
	contains = list(/obj/machinery/atmospherics/miner/plasma)
	cost = 300
	containername = "ящик с майнером плазмы"
	container_ru_names = list(
		NOMINATIVE = "ящик с майнером плазмы",
		GENITIVE = "ящика с майнером плазмы",
		DATIVE = "ящику с майнером плазмы",
		ACCUSATIVE = "ящик с майнером плазмы",
		INSTRUMENTAL = "ящиком с майнером плазмы",
		PREPOSITIONAL = "ящике с майнером плазмы",
	)

/datum/supply_packs/engineering/miner/agent_b
	name = "Майнер Agent B"
	contains = list(/obj/machinery/atmospherics/miner/agent_b)
	cost = 250
	containername = "ящик с майнером Agent B"
	container_ru_names = list(
		NOMINATIVE = "ящик с майнером Agent B",
		GENITIVE = "ящика с майнером Agent B",
		DATIVE = "ящику с майнером Agent B",
		ACCUSATIVE = "ящик с майнером Agent B",
		INSTRUMENTAL = "ящиком с майнером Agent B",
		PREPOSITIONAL = "ящике с майнером Agent B",
	)

/datum/supply_packs/engineering/miner/hydrogen
	name = "Майнер водяного пара"
	contains = list(/obj/machinery/atmospherics/miner/water_vapor)
	cost = 350
	containername = "ящик с майнером водяного пара"
	container_ru_names = list(
		NOMINATIVE = "ящик с майнером водяного пара",
		GENITIVE = "ящика с майнером водяного пара",
		DATIVE = "ящику с майнером водяного пара",
		ACCUSATIVE = "ящик с майнером водяного пара",
		INSTRUMENTAL = "ящиком с майнером водяного пара",
		PREPOSITIONAL = "ящике с майнером водяного пара",
	)

/datum/supply_packs/engineering/conveyor
	name = "Детали конвейерной ленты"
	contains = list(
		/obj/item/conveyor_construct,
		/obj/item/conveyor_construct,
		/obj/item/conveyor_construct,
		/obj/item/conveyor_construct,
		/obj/item/conveyor_construct,
		/obj/item/conveyor_construct,
		/obj/item/conveyor_switch_construct,
		/obj/item/paper/conveyor,
	)
	cost = 15
	containername = "ящик деталей конвейерной ленты"
	container_ru_names = list(
		NOMINATIVE = "ящик деталей конвейерной ленты",
		GENITIVE = "ящика деталей конвейерной ленты",
		DATIVE = "ящику деталей конвейерной ленты",
		ACCUSATIVE = "ящик деталей конвейерной ленты",
		INSTRUMENTAL = "ящиком деталей конвейерной ленты",
		PREPOSITIONAL = "ящике деталей конвейерной ленты",
	)

/datum/supply_packs/engineering/engine/magboots
	name = "Магбутсы"
	contains = list(
		/obj/item/clothing/shoes/magboots,
		/obj/item/clothing/shoes/magboots,
	)
	cost = 50
	containername = "ящик магбутсов"
	container_ru_names = list(
		NOMINATIVE = "ящик магбутсов",
		GENITIVE = "ящика магбутсов",
		DATIVE = "ящику магбутсов",
		ACCUSATIVE = "ящик магбутсов",
		INSTRUMENTAL = "ящиком магбутсов",
		PREPOSITIONAL = "ящике магбутсов",
	)
	required_tech = list(RESEARCH_TREE_MAGNETS = 4, RESEARCH_TREE_ENGINEERING = 4)

/datum/supply_packs/engineering/permit
	name = "Разрешение на строительство"
	contains = list(
		/obj/item/areaeditor/permit,
	)
	cost = 80
	containertype = /obj/structure/closet/crate/secure/engineering
	containername = "ящик с разрешением на строительство"
	container_ru_names = list(
		NOMINATIVE = "ящик с разрешением на строительство",
		GENITIVE = "ящика с разрешением на строительство",
		DATIVE = "ящику с разрешением на строительство",
		ACCUSATIVE = "ящик с разрешением на строительство",
		INSTRUMENTAL = "ящиком с разрешением на строительство",
		PREPOSITIONAL = "ящике с разрешением на строительство",
	)
	access = ACCESS_CE

/datum/supply_packs/engineering/industrialtols
	name = "Продвинутые инструменты"
	containername = "ящик продвинутых инструментов"
	contains = list(
		/obj/item/weldingtool/hugetank,
		/obj/item/weldingtool/hugetank,
		/obj/item/weldingtool/hugetank,
		/obj/item/wrench/industrial,
		/obj/item/wrench/industrial,
		/obj/item/wrench/industrial,
		/obj/item/crowbar/industrial,
		/obj/item/crowbar/industrial,
		/obj/item/crowbar/industrial,
		/obj/item/wirecutters/industrial,
		/obj/item/wirecutters/industrial,
		/obj/item/wirecutters/industrial,
		/obj/item/screwdriver/industrial,
		/obj/item/screwdriver/industrial,
		/obj/item/screwdriver/industrial,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/engineering/electrical
	containername = "ящик продвинутых инструментов"
	container_ru_names = list(
		NOMINATIVE = "ящик продвинутых инструментов",
		GENITIVE = "ящика продвинутых инструментов",
		DATIVE = "ящику продвинутых инструментов",
		ACCUSATIVE = "ящик продвинутых инструментов",
		INSTRUMENTAL = "ящиком продвинутых инструментов",
		PREPOSITIONAL = "ящике продвинутых инструментов",
	)

/datum/supply_packs/engineering/indumulti
	name = "Продвинутые мультиметры"
	containername = "ящик продвинутых мультиметров"
	contains = list(
		/obj/item/multitool/industrial,
		/obj/item/multitool/industrial,
		/obj/item/multitool/industrial,
	)
	cost = 60
	containertype = /obj/structure/closet/crate/engineering/electrical
	containername = "ящик продвинутых мультиметров"
	container_ru_names = list(
		NOMINATIVE = "ящик продвинутых мультиметров",
		GENITIVE = "ящика продвинутых мультиметров",
		DATIVE = "ящику продвинутых мультиметров",
		ACCUSATIVE = "ящик продвинутых мультиметров",
		INSTRUMENTAL = "ящиком продвинутых мультиметров",
		PREPOSITIONAL = "ящике продвинутых мультиметров",
	)

///////////// Station Goals

/datum/supply_packs/misc/station_goal
	name = "Пустой ящик с задачей смены"
	cost = 10
	special = TRUE
	containername = "пустой ящик с задачей смены"
	container_ru_names = list(
		NOMINATIVE = "пустой ящик с задачей смены",
		GENITIVE = "пустого ящика с задачей смены",
		DATIVE = "пустому ящику с задачей смены",
		ACCUSATIVE = "пустой ящик с задачей смены",
		INSTRUMENTAL = "пустым ящиком с задачей смены",
		PREPOSITIONAL = "пустом ящике с задачей смены",
	)
	containertype = /obj/structure/closet/crate/engineering

/datum/supply_packs/misc/station_goal/bsa
	name = "Детали блюспейс-артиллерии"
	cost = 300
	contains = list(
		/obj/item/circuitboard/machine/bsa/front,
		/obj/item/circuitboard/machine/bsa/middle,
		/obj/item/circuitboard/machine/bsa/back,
		/obj/item/circuitboard/computer/bsa_control,
	)
	containername = "ящик деталей блюспейс-артиллерии"
	container_ru_names = list(
		NOMINATIVE = "ящик деталей блюспейс-артиллерии",
		GENITIVE = "ящика деталей блюспейс-артиллерии",
		DATIVE = "ящику деталей блюспейс-артиллерии",
		ACCUSATIVE = "ящик деталей блюспейс-артиллерии",
		INSTRUMENTAL = "ящиком деталей блюспейс-артиллерии",
		PREPOSITIONAL = "ящике деталей блюспейс-артиллерии",
	)
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 6, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_BLUESPACE = 7)

/datum/supply_packs/misc/station_goal/bluespace_tap
	name = "Детали блюспейс-сборщика"
	cost = 300
	contains = list(
		/obj/item/circuitboard/machine/bluespace_tap,
		/obj/item/paper/bluespace_tap,
	)
	containername = "ящик деталей блюспейс-сборщика"
	container_ru_names = list(
		NOMINATIVE = "ящик деталей блюспейс-сборщика",
		GENITIVE = "ящика деталей блюспейс-сборщика",
		DATIVE = "ящику деталей блюспейс-сборщика",
		ACCUSATIVE = "ящик деталей блюспейс-сборщика",
		INSTRUMENTAL = "ящиком деталей блюспейс-сборщика",
		PREPOSITIONAL = "ящике деталей блюспейс-сборщика",
	)
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 7, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MAGNETS = 6, RESEARCH_TREE_BLUESPACE = 5)

/datum/supply_packs/misc/station_goal/dna_vault
	name = "Детали хранилища ДНК"
	cost = 250
	contains = list(
		/obj/item/circuitboard/machine/dna_vault,
	)
	containername = "ящик деталей хранилища ДНК"
	container_ru_names = list(
		NOMINATIVE = "ящик деталей хранилища ДНК",
		GENITIVE = "ящика деталей хранилища ДНК",
		DATIVE = "ящику деталей хранилища ДНК",
		ACCUSATIVE = "ящик деталей хранилища ДНК",
		INSTRUMENTAL = "ящиком деталей хранилища ДНК",
		PREPOSITIONAL = "ящике деталей хранилища ДНК",
	)
	required_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_BLUESPACE = 3)

/datum/supply_packs/misc/station_goal/dna_probes
	name = "Семплеры ДНК"
	cost = 30
	contains = list(
		/obj/item/dna_probe,
		/obj/item/dna_probe,
		/obj/item/dna_probe,
		/obj/item/dna_probe,
		/obj/item/dna_probe,
	)
	containername = "ящик сэмплеров ДНК"
	container_ru_names = list(
		NOMINATIVE = "ящик сэмплеров ДНК",
		GENITIVE = "ящика сэмплеров ДНК",
		DATIVE = "ящику сэмплеров ДНК",
		ACCUSATIVE = "ящик сэмплеров ДНК",
		INSTRUMENTAL = "ящиком сэмплеров ДНК",
		PREPOSITIONAL = "ящике сэмплеров ДНК",
	)
	required_tech = list(RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_PROGRAMMING = 5)

/datum/supply_packs/misc/station_goal/shield_sat
	name = "Метеоритные щиты"
	cost = 100
	contains = list(
		/obj/machinery/satellite/meteor_shield,
		/obj/machinery/satellite/meteor_shield,
		/obj/machinery/satellite/meteor_shield,
		/obj/machinery/satellite/meteor_shield,
	)
	containername = "ящик метеоритных щитов"
	container_ru_names = list(
		NOMINATIVE = "ящик метеоритных щитов",
		GENITIVE = "ящика метеоритных щитов",
		DATIVE = "ящику метеоритных щитов",
		ACCUSATIVE = "ящик метеоритных щитов",
		INSTRUMENTAL = "ящиком метеоритных щитов",
		PREPOSITIONAL = "ящике метеоритных щитов",
	)
	required_tech = list(RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_PROGRAMMING = 3)

/datum/supply_packs/misc/station_goal/shield_sat_control
	name = "Плата консоли управления метеоритными щитами"
	cost = 60
	contains = list(
		/obj/item/circuitboard/computer/sat_control,
	)
	containername = "ящик с консолью управления метеоритными щитами"
	container_ru_names = list(
		NOMINATIVE = "ящик с консолью управления метеоритными щитами",
		GENITIVE = "ящика с консолью управления метеоритными щитами",
		DATIVE = "ящику с консолью управления метеоритными щитами",
		ACCUSATIVE = "ящик с консолью управления метеоритными щитами",
		INSTRUMENTAL = "ящиком с консолью управления метеоритными щитами",
		PREPOSITIONAL = "ящике с консолью управления метеоритными щитами",
	)
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_PROGRAMMING = 5, RESEARCH_TREE_MAGNETS = 4)

/datum/supply_packs/misc/station_goal/bfl
	name = "Детали ОБЛ"
	cost = 50
	contains = list(
		/obj/item/circuitboard/machine/bfl_emitter,
		/obj/item/circuitboard/machine/bfl_receiver,
	)
	containername = "ящик деталей ОБЛ"
	container_ru_names = list(
		NOMINATIVE = "ящик деталей ОБЛ",
		GENITIVE = "ящика деталей ОБЛ",
		DATIVE = "ящику деталей ОБЛ",
		ACCUSATIVE = "ящик деталей ОБЛ",
		INSTRUMENTAL = "ящиком деталей ОБЛ",
		PREPOSITIONAL = "ящике деталей ОБЛ",
	)
	required_tech = list(RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_BLUESPACE = 6, RESEARCH_TREE_PLASMA = 6)

/datum/supply_packs/misc/station_goal/bfl_lens
	name = "Линза ОБЛ"
	cost = 100
	contains = list(
		/obj/machinery/bfl_lens,
	)
	containername = "ящик с линзой ОБЛ"
	container_ru_names = list(
		NOMINATIVE = "ящик с линзой ОБЛ",
		GENITIVE = "ящика с линзой ОБЛ",
		DATIVE = "ящику с линзой ОБЛ",
		ACCUSATIVE = "ящик с линзой ОБЛ",
		INSTRUMENTAL = "ящиком с линзой ОБЛ",
		PREPOSITIONAL = "ящике с линзой ОБЛ",
	)
	required_tech = list(RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_BLUESPACE = 4)

/datum/supply_packs/misc/station_goal/bfl_goal
	name = "Награда за постройку ОБЛ"
	cost = 3000
	contains = list(
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
		/obj/item/paper/researchnotes,
	)
	containername = "ящик с наградой за постройку ОБЛ"
	container_ru_names = list(
		NOMINATIVE = "ящик с наградой за постройку ОБЛ",
		GENITIVE = "ящика с наградой за постройку ОБЛ",
		DATIVE = "ящику с наградой за постройку ОБЛ",
		ACCUSATIVE = "ящик с наградой за постройку ОБЛ",
		INSTRUMENTAL = "ящиком с наградой за постройку ОБЛ",
		PREPOSITIONAL = "ящике с наградой за постройку ОБЛ",
	)

/datum/supply_packs/misc/station_goal/bluespace_rift
	name = "Набор сканирования блюспейс-разлома"
	cost = 150
	contains = list(
		/obj/item/disk/design_disk/station_goal_machinery/brs_server,
		/obj/item/disk/design_disk/station_goal_machinery/brs_portable_scanner,
		/obj/item/disk/design_disk/station_goal_machinery/brs_stationary_scanner,
	)
	containername = "ящи с набором сканирования БС-разлома"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором сканирования БС-разлома",
		GENITIVE = "ящика с набором сканирования БС-разлома",
		DATIVE = "ящику с набором сканирования БС-разлома",
		ACCUSATIVE = "ящик с набором сканирования БС-разлома",
		INSTRUMENTAL = "ящиком с набором сканирования БС-разлома",
		PREPOSITIONAL = "ящике с набором сканирования БС-разлома",
	)
	containertype = /obj/structure/closet/crate/sci
	required_tech = list(RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_PROGRAMMING = 6, RESEARCH_TREE_BLUESPACE = 7)

///////////// High-Tech Disks

/datum/supply_packs/misc/htdisk
	cost = 1
	special = TRUE
	containername = "ящик с дискетой технологий"
	container_ru_names = list(
		NOMINATIVE = "ящик с дискетой технологий",
		GENITIVE = "ящика с дискетой технологий",
		DATIVE = "ящику с дискетой технологий",
		ACCUSATIVE = "ящик с дискетой технологий",
		INSTRUMENTAL = "ящиком с дискетой технологий",
		PREPOSITIONAL = "ящике с дискетой технологий",
	)
	containertype = /obj/structure/closet/crate/secure/scisec
	access = ACCESS_RESEARCH

/datum/supply_packs/misc/htdisk/materials
	contains = list(/obj/item/disk/tech_disk/loaded/materials)
	name = "Дискета технологий (" + RESEARCH_TREE_MATERIALS_NAME + ")"

/datum/supply_packs/misc/htdisk/engineering
	contains = list(/obj/item/disk/tech_disk/loaded/engineering)
	name = "Дискета технологий (" + RESEARCH_TREE_ENGINEERING_NAME + ")"

/datum/supply_packs/misc/htdisk/plasmatech
	contains = list(/obj/item/disk/tech_disk/loaded/plasmatech)
	name = "Дискета технологий (" + RESEARCH_TREE_PLASMA_NAME + ")"

/datum/supply_packs/misc/htdisk/powerstorage
	contains = list(/obj/item/disk/tech_disk/loaded/powerstorage)
	name = "Дискета технологий (" + RESEARCH_TREE_POWERSTORAGE_NAME + ")"

/datum/supply_packs/misc/htdisk/bluespace
	contains = list(/obj/item/disk/tech_disk/loaded/bluespace)
	name = "Дискета технологий (" + RESEARCH_TREE_BLUESPACE_NAME + ")"

/datum/supply_packs/misc/htdisk/biotech
	contains = list(/obj/item/disk/tech_disk/loaded/biotech)
	name = "Дискета технологий (" + RESEARCH_TREE_BIOTECH_NAME + ")"

/datum/supply_packs/misc/htdisk/combat
	contains = list(/obj/item/disk/tech_disk/loaded/combat)
	name = "Дискета технологий (" + RESEARCH_TREE_COMBAT_NAME + ")"

/datum/supply_packs/misc/htdisk/magnets
	contains = list(/obj/item/disk/tech_disk/loaded/magnets)
	name = "Дискета технологий (" + RESEARCH_TREE_MAGNETS_NAME + ")"

/datum/supply_packs/misc/htdisk/programming
	contains = list(/obj/item/disk/tech_disk/loaded/programming)
	name = "Дискета технологий (" + RESEARCH_TREE_PROGRAMMING_NAME + ")"

/datum/supply_packs/misc/htdisk/toxins
	contains = list(/obj/item/disk/tech_disk/loaded/toxins)
	name = "Дискета технологий (" + RESEARCH_TREE_TOXINS_NAME + ")"

//////////////////////////////////////////////////////////////////////////////
// MARK: Medical
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/medical
	name = "HEADER"
	containertype = /obj/structure/closet/crate/medical
	group = SUPPLY_MEDICAL
	announce_beacons = list("Medbay" = list("Medbay", "Chief Medical Officer's Desk"), "Security" = list("Brig Medbay"))


/datum/supply_packs/medical/modsuit
	name = "Медицинские МЭК"
	contains = list(
		/obj/item/mod/control/pre_equipped/medical,
		/obj/item/mod/control/pre_equipped/medical,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath,
	)
	cost = 130
	containertype = /obj/structure/closet/crate/secure
	required_tech = list(RESEARCH_TREE_TOXINS = 4, RESEARCH_TREE_BIOTECH = 5)
	containername = "ящик медицинских МЭК"
	container_ru_names = list(
		NOMINATIVE = "ящик медицинских МЭК",
		GENITIVE = "ящика медицинских МЭК",
		DATIVE = "ящику медицинских МЭК",
		ACCUSATIVE = "ящик медицинских МЭК",
		INSTRUMENTAL = "ящиком медицинских МЭК",
		PREPOSITIONAL = "ящике медицинских МЭК",
	)
	access = ACCESS_MEDICAL

/datum/supply_packs/medical/supplies
	name = "Медицинское снабжение"
	contains = list(
		/obj/item/reagent_containers/glass/bottle/charcoal,
		/obj/item/reagent_containers/glass/bottle/charcoal,
		/obj/item/reagent_containers/glass/bottle/epinephrine,
		/obj/item/reagent_containers/glass/bottle/epinephrine,
		/obj/item/reagent_containers/glass/bottle/morphine,
		/obj/item/reagent_containers/glass/bottle/morphine,
		/obj/item/reagent_containers/glass/bottle/toxin,
		/obj/item/reagent_containers/glass/bottle/toxin,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/reagent_containers/glass/beaker/large,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/reagent_containers/iv_bag/salglu,
		/obj/item/storage/box/beakers,
		/obj/item/storage/box/syringes,
		/obj/item/storage/box/bodybags,
		/obj/item/storage/box/iv_bags,
		/obj/item/vending_refill/medical,
	)
	cost = 90
	containertype = /obj/structure/closet/crate/secure
	containername = "ящик медицинского снабжения"
	container_ru_names = list(
		NOMINATIVE = "ящик медицинского снабжения",
		GENITIVE = "ящика медицинского снабжения",
		DATIVE = "ящику медицинского снабжения",
		ACCUSATIVE = "ящик медицинского снабжения",
		INSTRUMENTAL = "ящиком медицинского снабжения",
		PREPOSITIONAL = "ящике медицинского снабжения",
	)
	access = ACCESS_MEDICAL

/datum/supply_packs/medical/firstaid
	name = "Аптечки первой помощи"
	contains = list(
		/obj/item/storage/firstaid/regular,
		/obj/item/storage/firstaid/regular,
		/obj/item/storage/firstaid/regular,
		/obj/item/storage/firstaid/regular,
	)
	cost = 15
	containername = "ящик аптечек первой помощи"
	container_ru_names = list(
		NOMINATIVE = "ящик аптечек первой помощи",
		GENITIVE = "ящика аптечек первой помощи",
		DATIVE = "ящику аптечек первой помощи",
		ACCUSATIVE = "ящик аптечек первой помощи",
		INSTRUMENTAL = "ящиком аптечек первой помощи",
		PREPOSITIONAL = "ящике аптечек первой помощи",
	)

/datum/supply_packs/medical/firstaidadv
	name = "Продвинутые аптечки первой помощи"
	contains = list(
		/obj/item/storage/firstaid/adv,
		/obj/item/storage/firstaid/adv,
		/obj/item/storage/firstaid/adv,
		/obj/item/storage/firstaid/adv,
	)
	cost = 60
	containername = "ящик продвинутых аптечек первой помощи"
	container_ru_names = list(
		NOMINATIVE = "ящик продвинутых аптечек первой помощи",
		GENITIVE = "ящика продвинутых аптечек первой помощи",
		DATIVE = "ящику продвинутых аптечек первой помощи",
		ACCUSATIVE = "ящик продвинутых аптечек первой помощи",
		INSTRUMENTAL = "ящиком продвинутых аптечек первой помощи",
		PREPOSITIONAL = "ящике продвинутых аптечек первой помощи",
	)
	access = ACCESS_MEDICAL
	containertype = /obj/structure/closet/crate/secure
	required_tech = list(RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_MATERIALS = 2)

/datum/supply_packs/medical/firstaibrute
	name = "Аптечки первой помощи (Мех.)"
	contains = list(
		/obj/item/storage/firstaid/brute,
		/obj/item/storage/firstaid/brute,
		/obj/item/storage/firstaid/brute,
	)
	cost = 40
	containername = "ящик аптечек первой помощи (Мех.)"
	container_ru_names = list(
		NOMINATIVE = "ящик аптечек первой помощи (Мех.)",
		GENITIVE = "ящика аптечек первой помощи (Мех.)",
		DATIVE = "ящику аптечек первой помощи (Мех.)",
		ACCUSATIVE = "ящик аптечек первой помощи (Мех.)",
		INSTRUMENTAL = "ящиком аптечек первой помощи (Мех.)",
		PREPOSITIONAL = "ящике аптечек первой помощи (Мех.)",
	)
	access = ACCESS_MEDICAL
	containertype = /obj/structure/closet/crate/secure

/datum/supply_packs/medical/firstaidburns
	name = "Аптечки первой помощи (Терм.)"
	contains = list(
		/obj/item/storage/firstaid/fire,
		/obj/item/storage/firstaid/fire,
		/obj/item/storage/firstaid/fire,
	)
	cost = 40
	containername = "ящик аптечек первой помощи (Терм.)"
	container_ru_names = list(
		NOMINATIVE = "ящик аптечек первой помощи (Терм.)",
		GENITIVE = "ящика аптечек первой помощи (Терм.)",
		DATIVE = "ящику аптечек первой помощи (Терм.)",
		ACCUSATIVE = "ящик аптечек первой помощи (Терм.)",
		INSTRUMENTAL = "ящиком аптечек первой помощи (Терм.)",
		PREPOSITIONAL = "ящике аптечек первой помощи (Терм.)",
	)
	access = ACCESS_MEDICAL
	containertype = /obj/structure/closet/crate/secure

/datum/supply_packs/medical/firstaidtoxins
	name = "Аптечки первой помощи (Отравления)"
	contains = list(
		/obj/item/storage/firstaid/toxin,
		/obj/item/storage/firstaid/toxin,
		/obj/item/storage/firstaid/toxin,
	)
	cost = 20
	containername = "ящик аптечек первой помощи (Отравления)"
	container_ru_names = list(
		NOMINATIVE = "ящик аптечек первой помощи (Отравления)",
		GENITIVE = "ящика аптечек первой помощи (Отравления)",
		DATIVE = "ящику аптечек первой помощи (Отравления)",
		ACCUSATIVE = "ящик аптечек первой помощи (Отравления)",
		INSTRUMENTAL = "ящиком аптечек первой помощи (Отравления)",
		PREPOSITIONAL = "ящике аптечек первой помощи (Отравления)",
	)

/datum/supply_packs/medical/firstaidoxygen
	name = "Аптечки первой помощи (Удушье)"
	contains = list(
		/obj/item/storage/firstaid/o2,
		/obj/item/storage/firstaid/o2,
		/obj/item/storage/firstaid/o2,
	)
	cost = 15
	containername = "ящик аптечек первой помощи (Удушье)"
	container_ru_names = list(
		NOMINATIVE = "ящик аптечек первой помощи (Удушье)",
		GENITIVE = "ящика аптечек первой помощи (Удушье)",
		DATIVE = "ящику аптечек первой помощи (Удушье)",
		ACCUSATIVE = "ящик аптечек первой помощи (Удушье)",
		INSTRUMENTAL = "ящиком аптечек первой помощи (Удушье)",
		PREPOSITIONAL = "ящике аптечек первой помощи (Удушье)",
	)

/datum/supply_packs/medical/straightjacket
	name = "Смирительная рубашка"
	contains = list(
		/obj/item/clothing/suit/straight_jacket,
	)
	cost = 40
	containername = "ящик со смирительной рубашкой"
	container_ru_names = list(
		NOMINATIVE = "ящик со смирительной рубашкой",
		GENITIVE = "ящика со смирительной рубашкой",
		DATIVE = "ящику со смирительной рубашкой",
		ACCUSATIVE = "ящик со смирительной рубашкой",
		INSTRUMENTAL = "ящиком со смирительной рубашкой",
		PREPOSITIONAL = "ящике со смирительной рубашкой",
	)

/datum/supply_packs/medical/virus
	name = "Вирусные образцы"
	contains = list(
		/obj/item/reagent_containers/glass/bottle/flu,
		/obj/item/reagent_containers/glass/bottle/cold,
		/obj/item/reagent_containers/glass/bottle/sneezing,
		/obj/item/reagent_containers/glass/bottle/cough,
		/obj/item/reagent_containers/glass/bottle/epiglottis_virion,
		/obj/item/reagent_containers/glass/bottle/liver_enhance_virion,
		/obj/item/reagent_containers/glass/bottle/fake_gbs,
		/obj/item/reagent_containers/glass/bottle/magnitis,
		/obj/item/reagent_containers/glass/bottle/pierrot_throat,
		/obj/item/reagent_containers/glass/bottle/brainrot,
		/obj/item/reagent_containers/glass/bottle/hullucigen_virion,
		/obj/item/reagent_containers/glass/bottle/anxiety,
		/obj/item/reagent_containers/glass/bottle/beesease,
		/obj/item/storage/box/syringes,
		/obj/item/storage/box/beakers,
		/obj/item/reagent_containers/glass/bottle/mutagen,
	)
	cost = 150
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "ящик с вирусными образцами"
	container_ru_names = list(
		NOMINATIVE = "ящик с вирусными образцами",
		GENITIVE = "ящика с вирусными образцами",
		DATIVE = "ящику с вирусными образцами",
		ACCUSATIVE = "ящик с вирусными образцами",
		INSTRUMENTAL = "ящиком с вирусными образцами",
		PREPOSITIONAL = "ящике с вирусными образцами",
	)
	access = ACCESS_CMO
	announce_beacons = list("Medbay" = list("Virology", "Chief Medical Officer's Desk"))
	required_tech = list(RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_COMBAT = 2)

/datum/supply_packs/medical/cloning
	name = "Платы клонировальной машины"
	contains = list(
		/obj/item/circuitboard/clonepod,
		/obj/item/circuitboard/cloning,
	)
	cost = 350
	containertype = /obj/structure/closet/crate/secure
	containername = "ящик с платами клонировальной машины"
	container_ru_names = list(
		NOMINATIVE = "ящик с платами клонировальной машины",
		GENITIVE = "ящика с платами клонировальной машины",
		DATIVE = "ящику с платами клонировальной машины",
		ACCUSATIVE = "ящик с платами клонировальной машины",
		INSTRUMENTAL = "ящиком с платами клонировальной машины",
		PREPOSITIONAL = "ящике с платами клонировальной машины",
	)
	access = ACCESS_CMO
	announce_beacons = list("Medbay" = list("Chief Medical Officer's Desk"))

/datum/supply_packs/medical/vending
	name = "Наборы пополнения медицинских торгоматов"
	cost = 150
	contains = list(
		/obj/item/vending_refill/medical,
		/obj/item/vending_refill/wallmed,
	)
	containername = "ящик наборов пополнения медицинских торгоматов"
	container_ru_names = list(
		NOMINATIVE = "ящик наборов пополнения медицинских торгоматов",
		GENITIVE = "ящика наборов пополнения медицинских торгоматов",
		DATIVE = "ящику наборов пополнения медицинских торгоматов",
		ACCUSATIVE = "ящик наборов пополнения медицинских торгоматов",
		INSTRUMENTAL = "ящиком наборов пополнения медицинских торгоматов",
		PREPOSITIONAL = "ящике наборов пополнения медицинских торгоматов",
	)
	containertype = /obj/structure/closet/crate/secure
	access = ACCESS_MEDICAL
	required_tech = list(RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_PROGRAMMING = 2)

/datum/supply_packs/medical/bloodpacks_syn_oxygenis
	name = "Синтетическая кровь (Кислород)"
	contains = list(
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
	)
	cost = 300
	containertype = /obj/structure/closet/crate/secure/blood/oxygenis
	containername = "ящик синетической крови (Кислород)"
	container_ru_names = list(
		NOMINATIVE = "ящик синетической крови (Кислород)",
		GENITIVE = "ящика синетической крови (Кислород)",
		DATIVE = "ящику синетической крови (Кислород)",
		ACCUSATIVE = "ящик синетической крови (Кислород)",
		INSTRUMENTAL = "ящиком синетической крови (Кислород)",
		PREPOSITIONAL = "ящике синетической крови (Кислород)",
	)
	access = ACCESS_MEDICAL
	required_tech = list(RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_TOXINS = 3)

/datum/supply_packs/medical/bloodpacks_syn_nitrogenis
	name = "Синтетическая кровь (Азот)"
	contains = list(
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
	)
	cost = 300
	containertype = /obj/structure/closet/crate/secure/blood/nitrogenis
	containername = "ящик синтетической крови (Азот)"
	container_ru_names = list(
		NOMINATIVE = "ящик синтетической крови (Азот)",
		GENITIVE = "ящика синтетической крови (Азот)",
		DATIVE = "ящику синтетической крови (Азот)",
		ACCUSATIVE = "ящик синтетической крови (Азот)",
		INSTRUMENTAL = "ящиком синтетической крови (Азот)",
		PREPOSITIONAL = "ящике синтетической крови (Азот)",
	)
	access = ACCESS_MEDICAL
	required_tech = list(RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_TOXINS = 3)

/datum/supply_packs/medical/bloodpacks_human
	name = "Пакеты крови (Человек)"
	contains = list(
		/obj/item/reagent_containers/iv_bag/blood/ABPlus,
		/obj/item/reagent_containers/iv_bag/blood/ABMinus,
		/obj/item/reagent_containers/iv_bag/blood/APlus,
		/obj/item/reagent_containers/iv_bag/blood/AMinus,
		/obj/item/reagent_containers/iv_bag/blood/BPlus,
		/obj/item/reagent_containers/iv_bag/blood/BMinus,
		/obj/item/reagent_containers/iv_bag/blood/OPlus,
		/obj/item/reagent_containers/iv_bag/blood/OMinus,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/secure/blood
	containername = "ящик пакетов крови (Человек)"
	container_ru_names = list(
		NOMINATIVE = "ящик пакетов крови (Человек)",
		GENITIVE = "ящика пакетов крови (Человек)",
		DATIVE = "ящику пакетов крови (Человек)",
		ACCUSATIVE = "ящик пакетов крови (Человек)",
		INSTRUMENTAL = "ящиком пакетов крови (Человек)",
		PREPOSITIONAL = "ящике пакетов крови (Человек)",
	)
	access = ACCESS_MEDICAL
	required_tech = list(RESEARCH_TREE_BIOTECH = 3)

/datum/supply_packs/medical/bloodpacks_xenos
	name = "Пакеты крови (Ксеносы)"
	contains = list(
		/obj/item/reagent_containers/iv_bag/blood/skrell,
		/obj/item/reagent_containers/iv_bag/blood/tajaran,
		/obj/item/reagent_containers/iv_bag/blood/vulpkanin,
		/obj/item/reagent_containers/iv_bag/blood/unathi,
		/obj/item/reagent_containers/iv_bag/blood/kidan,
		/obj/item/reagent_containers/iv_bag/blood/grey,
		/obj/item/reagent_containers/iv_bag/blood/diona,
		/obj/item/reagent_containers/iv_bag/blood/wryn,
		/obj/item/reagent_containers/iv_bag/blood/nian,
	)
	cost = 65
	containertype = /obj/structure/closet/crate/secure/blood/xeno
	containername = "ящик пакетов крови (Ксеносы)"
	container_ru_names = list(
		NOMINATIVE = "ящик пакетов крови (Ксеносы)",
		GENITIVE = "ящика пакетов крови (Ксеносы)",
		DATIVE = "ящику пакетов крови (Ксеносы)",
		ACCUSATIVE = "ящик пакетов крови (Ксеносы)",
		INSTRUMENTAL = "ящиком пакетов крови (Ксеносы)",
		PREPOSITIONAL = "ящике пакетов крови (Ксеносы)",
	)
	required_tech = list(RESEARCH_TREE_BIOTECH = 3)

/datum/supply_packs/medical/bloodpacks_syn_oxygenis_credit
	name = "Synthetic Blood Pack Oxygenis"
	contains = list(
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/oxygenis,
	)
	credits_cost = 6000
	containertype = /obj/structure/closet/crate/secure
	containername = "synthetic blood pack oxygenis crate"
	access = ACCESS_MEDICAL
	required_tech = list(RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_TOXINS = 3)

/datum/supply_packs/medical/bloodpacks_syn_nitrogenis_credit
	name = "Synthetic Blood Pack Nitrogenis"
	contains = list(
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
		/obj/item/reagent_containers/iv_bag/bloodsynthetic/nitrogenis,
	)
	credits_cost = 6000
	containertype = /obj/structure/closet/crate/secure
	containername = "synthetic blood pack nitrogenis crate"
	access = ACCESS_MEDICAL
	required_tech = list(RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_TOXINS = 3)

/datum/supply_packs/medical/bloodpacks_human_credit
	name = "Human Blood Pack"
	contains = list(
		/obj/item/reagent_containers/iv_bag/blood/ABPlus,
		/obj/item/reagent_containers/iv_bag/blood/ABMinus,
		/obj/item/reagent_containers/iv_bag/blood/APlus,
		/obj/item/reagent_containers/iv_bag/blood/AMinus,
		/obj/item/reagent_containers/iv_bag/blood/BPlus,
		/obj/item/reagent_containers/iv_bag/blood/BMinus,
		/obj/item/reagent_containers/iv_bag/blood/OPlus,
		/obj/item/reagent_containers/iv_bag/blood/OMinus,
	)
	credits_cost = 3000
	containertype = /obj/structure/closet/crate/freezer
	containername = "human blood pack crate"
	required_tech = list(RESEARCH_TREE_BIOTECH = 3)

/datum/supply_packs/medical/bloodpacks_xenos_credit
	name = "Xenos Blood Pack"
	contains = list(
		/obj/item/reagent_containers/iv_bag/blood/skrell,
		/obj/item/reagent_containers/iv_bag/blood/tajaran,
		/obj/item/reagent_containers/iv_bag/blood/vulpkanin,
		/obj/item/reagent_containers/iv_bag/blood/unathi,
		/obj/item/reagent_containers/iv_bag/blood/kidan,
		/obj/item/reagent_containers/iv_bag/blood/grey,
		/obj/item/reagent_containers/iv_bag/blood/diona,
		/obj/item/reagent_containers/iv_bag/blood/wryn,
		/obj/item/reagent_containers/iv_bag/blood/nian,
	)
	credits_cost = 3000
	containertype = /obj/structure/closet/crate/freezer
	containername = "xenos blood pack crate"
	required_tech = list(RESEARCH_TREE_BIOTECH = 3)

/datum/supply_packs/medical/iv_drip
	name = "Стойка для капельницы"
	contains = list(
		/obj/machinery/iv_drip,
	)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "ящик со стойкой для капельнцы"
	container_ru_names = list(
		NOMINATIVE = "ящик со стойкой для капельнцы",
		GENITIVE = "ящика со стойкой для капельнцы",
		DATIVE = "ящику со стойкой для капельнцы",
		ACCUSATIVE = "ящик со стойкой для капельнцы",
		INSTRUMENTAL = "ящиком со стойкой для капельнцы",
		PREPOSITIONAL = "ящике со стойкой для капельнцы",
	)
	access = ACCESS_MEDICAL

/datum/supply_packs/medical/surgery
	name = "Хирургическое оборудование"
	contains = list(
		/obj/item/cautery,
		/obj/item/surgicaldrill,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/tank/internals/anesthetic,
		/obj/item/FixOVein,
		/obj/item/hemostat,
		/obj/item/scalpel,
		/obj/item/bonegel,
		/obj/item/retractor,
		/obj/item/bonesetter,
		/obj/item/circular_saw,
	)
	cost = 25
	containertype = /obj/structure/closet/crate/secure
	containername = "ящик с хирургическим оборудованием"
	container_ru_names = list(
		NOMINATIVE = "ящик с хирургическим оборудованием",
		GENITIVE = "ящика с хирургическим оборудованием",
		DATIVE = "ящику с хирургическим оборудованием",
		ACCUSATIVE = "ящик с хирургическим оборудованием",
		INSTRUMENTAL = "ящиком с хирургическим оборудованием",
		PREPOSITIONAL = "ящике с хирургическим оборудованием",
	)
	access = ACCESS_MEDICAL

/datum/supply_packs/medical/incision
	name = "Системы обработки надрезов"
	containername = "ящик с системами обработки надрезов"
	container_ru_names = list(
		NOMINATIVE = "ящик с системами обработки надрезов",
		GENITIVE = "ящика с системами обработки надрезов",
		DATIVE = "ящику с системами обработки надрезов",
		ACCUSATIVE = "ящик с системами обработки надрезов",
		INSTRUMENTAL = "ящиком с системами обработки надрезов",
		PREPOSITIONAL = "ящике с системами обработки надрезов",
	)
	cost = 180
	required_tech = list(RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_MAGNETS = 5, RESEARCH_TREE_PROGRAMMING = 4)
	contains = list(
		/obj/item/scalpel/laser/manager,
		/obj/item/scalpel/laser/manager,
		/obj/item/scalpel/laser/manager,
	)

/datum/supply_packs/medical/menderindustrial
	name = "Продвинутый авто-мендер"
	containername = "ящик продвинутых авто-мендеров"
	container_ru_names = list(
		NOMINATIVE = "ящик продвинутых авто-мендеров",
		GENITIVE = "ящика продвинутых авто-мендеров",
		DATIVE = "ящику продвинутых авто-мендеров",
		ACCUSATIVE = "ящик продвинутых авто-мендеров",
		INSTRUMENTAL = "ящиком продвинутых авто-мендеров",
		PREPOSITIONAL = "ящике продвинутых авто-мендеров",
	)
	cost = 180
	required_tech = list(RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_MAGNETS = 6, RESEARCH_TREE_PROGRAMMING = 6)
	contains = list(
		/obj/item/reagent_containers/applicator/abductor/industrial,
		/obj/item/reagent_containers/applicator/abductor/industrial,
		/obj/item/reagent_containers/applicator/abductor/industrial,
	)

//////////////////////////////////////////////////////////////////////////////
// MARK: Science
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/science
	name = "HEADER"
	group = SUPPLY_SCIENCE
	announce_beacons = list("Research Division" = list("Science", "Research Director's Desk"))
	containertype = /obj/structure/closet/crate/sci

/datum/supply_packs/science/robotics
	name = "Робототехнические детали"
	contains = list(
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/prox_sensor,
		/obj/item/storage/toolbox/electrical,
		/obj/item/storage/box/flashes,
		/obj/item/stock_parts/cell/high,
		/obj/item/stock_parts/cell/high,
	)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "ящик робототехнических деталей"
	container_ru_names = list(
		NOMINATIVE = "ящик робототехнических деталей",
		GENITIVE = "ящика робототехнических деталей",
		DATIVE = "ящику робототехнических деталей",
		ACCUSATIVE = "ящик робототехнических деталей",
		INSTRUMENTAL = "ящиком робототехнических деталей",
		PREPOSITIONAL = "ящике робототехнических деталей",
	)
	access = ACCESS_ROBOTICS
	announce_beacons = list("Research Division" = list("Robotics", "Research Director's Desk"))

/datum/supply_packs/science/robotics/mecha_ripley
	name = "Набор плат (АТМЕ \"Рипли\")"
	contains = list(
		/obj/item/book/manual/ripley_build_and_repair,
		/obj/item/circuitboard/mecha/ripley/main,
		/obj/item/circuitboard/mecha/ripley/peripherals,
	)
	cost = 25
	containername = "ящик с набором плат (АТМЕ \"Рипли\")"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором плат (АТМЕ \"Рипли\")",
		GENITIVE = "ящика с набором плат (АТМЕ \"Рипли\")",
		DATIVE = "ящику с набором плат (АТМЕ \"Рипли\")",
		ACCUSATIVE = "ящик с набором плат (АТМЕ \"Рипли\")",
		INSTRUMENTAL = "ящиком с набором плат (АТМЕ \"Рипли\")",
		PREPOSITIONAL = "ящике с набором плат (АТМЕ \"Рипли\")",
	)

/datum/supply_packs/science/robotics/mecha_odysseus
	name = "Набор плат (Одиссей)"
	contains = list(
		/obj/item/circuitboard/mecha/odysseus/peripherals,
		/obj/item/circuitboard/mecha/odysseus/main,
	)
	cost = 55
	containername = "ящик с набором плат (Одиссей)"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором плат (Одиссей)",
		GENITIVE = "ящика с набором плат (Одиссей)",
		DATIVE = "ящику с набором плат (Одиссей)",
		ACCUSATIVE = "ящик с набором плат (Одиссей)",
		INSTRUMENTAL = "ящиком с набором плат (Одиссей)",
		PREPOSITIONAL = "ящике с набором плат (Одиссей)",
	)

/datum/supply_packs/science/firstaidmachine
	name = "Ремонтные наборы (Синт.)"
	contains = list(
		/obj/item/storage/firstaid/machine,
		/obj/item/storage/firstaid/machine,
		/obj/item/storage/firstaid/machine,
	)
	cost = 20
	containername = "ящик ремонтных наборов (Синт.)"
	container_ru_names = list(
		NOMINATIVE = "ящик ремонтных наборов (Синт.)",
		GENITIVE = "ящика ремонтных наборов (Синт.)",
		DATIVE = "ящику ремонтных наборов (Синт.)",
		ACCUSATIVE = "ящик ремонтных наборов (Синт.)",
		INSTRUMENTAL = "ящиком ремонтных наборов (Синт.)",
		PREPOSITIONAL = "ящике ремонтных наборов (Синт.)",
	)

/datum/supply_packs/science/plasma
	name = "Детали плазменных бомб"
	contains = list(
		/obj/item/tank/internals/plasma,
		/obj/item/tank/internals/plasma,
		/obj/item/tank/internals/plasma,
		/obj/item/assembly/igniter,
		/obj/item/assembly/igniter,
		/obj/item/assembly/igniter,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/prox_sensor,
		/obj/item/assembly/timer,
		/obj/item/assembly/timer,
		/obj/item/assembly/timer,
	)
	cost = 10
	containertype = /obj/structure/closet/crate/secure/plasma
	containername = "ящик деталей плазменных бомб"
	container_ru_names = list(
		NOMINATIVE = "ящик деталей плазменных бомб",
		GENITIVE = "ящика деталей плазменных бомб",
		DATIVE = "ящику деталей плазменных бомб",
		ACCUSATIVE = "ящик деталей плазменных бомб",
		INSTRUMENTAL = "ящиком деталей плазменных бомб",
		PREPOSITIONAL = "ящике деталей плазменных бомб",
	)
	access = ACCESS_TOX_STORAGE

/datum/supply_packs/science/shieldwalls
	name = "Генераторы силового поля"
	contains = list(
		/obj/machinery/shieldwallgen,
		/obj/machinery/shieldwallgen,
		/obj/machinery/shieldwallgen,
		/obj/machinery/shieldwallgen,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "ящик генераторов силового поля"
	container_ru_names = list(
		NOMINATIVE = "ящик генераторов силового поля",
		GENITIVE = "ящика генераторов силового поля",
		DATIVE = "ящику генераторов силового поля",
		ACCUSATIVE = "ящик генераторов силового поля",
		INSTRUMENTAL = "ящиком генераторов силового поля",
		PREPOSITIONAL = "ящике генераторов силового поля",
	)
	access = ACCESS_TELEPORTER
	required_tech = list(RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_POWERSTORAGE = 3)

/datum/supply_packs/science/transfer_valves
	name = "Запорные клапаны"
	contains = list(
		/obj/item/transfer_valve,
		/obj/item/transfer_valve,
	)
	cost = 30
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "ящик запорных клапанов"
	container_ru_names = list(
		NOMINATIVE = "ящик запорных клапанов",
		GENITIVE = "ящика запорных клапанов",
		DATIVE = "ящику запорных клапанов",
		ACCUSATIVE = "ящик запорных клапанов",
		INSTRUMENTAL = "ящиком запорных клапанов",
		PREPOSITIONAL = "ящике запорных клапанов",
	)
	access = ACCESS_RD
	required_tech = list(RESEARCH_TREE_ENGINEERING = 2, RESEARCH_TREE_TOXINS = 3)

/datum/supply_packs/science/prototype
	name = "Прототип машины"
	contains = list(
		/obj/item/machineprototype,
	)
	cost = 80
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "ящик с прототипом машины"
	container_ru_names = list(
		NOMINATIVE = "ящик с прототипом машины",
		GENITIVE = "ящика с прототипом машины",
		DATIVE = "ящику с прототипом машины",
		ACCUSATIVE = "ящик с прототипом машины",
		INSTRUMENTAL = "ящиком с прототипом машины",
		PREPOSITIONAL = "ящике с прототипом машины",
	)
	access = ACCESS_RESEARCH
	required_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MAGNETS = 2)

/datum/supply_packs/science/oil
	name = "Бак масла"
	contains = list(
		/obj/structure/reagent_dispensers/oil,
		/obj/item/reagent_containers/food/drinks/oilcan,
	)
	cost = 10
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с ботаническим ранцем для масла"
	container_ru_names = list(
		NOMINATIVE = "ящик с ботаническим ранцем для масла",
		GENITIVE = "ящика с ботаническим ранцем для масла",
		DATIVE = "ящику с ботаническим ранцем для масла",
		ACCUSATIVE = "ящик с ботаническим ранцем для масла",
		INSTRUMENTAL = "ящиком с ботаническим ранцем для масла",
		PREPOSITIONAL = "ящике с ботаническим ранцем для масла",
	)

/datum/supply_packs/science/dis_borg
	name = "Детали робота"
	contains = list(
		/obj/item/robot_parts/robot_suit,
		/obj/item/robot_parts/chest,
		/obj/item/robot_parts/head,
		/obj/item/robot_parts/l_arm,
		/obj/item/robot_parts/r_arm,
		/obj/item/robot_parts/l_leg,
		/obj/item/robot_parts/r_leg,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "ящик деталей робота"
	container_ru_names = list(
		NOMINATIVE = "ящик деталей робота",
		GENITIVE = "ящика деталей робота",
		DATIVE = "ящику деталей робота",
		ACCUSATIVE = "ящик деталей робота",
		INSTRUMENTAL = "ящиком деталей робота",
		PREPOSITIONAL = "ящике деталей робота",
	)
	access = ACCESS_ROBOTICS

/datum/supply_packs/science/rad_suit
	name = "Радиационные костюмы"
	contains = list(
		/obj/item/clothing/head/radiation,
		/obj/item/clothing/head/radiation,
		/obj/item/clothing/suit/radiation,
		/obj/item/clothing/suit/radiation,
	)
	cost = 35
	containername = "ящик радиационных костюмов"
	container_ru_names = list(
		NOMINATIVE = "ящик радиационных костюмов",
		GENITIVE = "ящика радиационных костюмов",
		DATIVE = "ящику радиационных костюмов",
		ACCUSATIVE = "ящик радиационных костюмов",
		INSTRUMENTAL = "ящиком радиационных костюмов",
		PREPOSITIONAL = "ящике радиационных костюмов",
	)
	required_tech = list(RESEARCH_TREE_BIOTECH = 3, RESEARCH_TREE_MATERIALS = 2)

/datum/supply_packs/science/sohs
	name = "Блюспейс-ранцы"
	contains = list(
		/obj/item/storage/backpack/holding/satchel,
		/obj/item/storage/backpack/holding/satchel,
		/obj/item/storage/backpack/holding/satchel,
	)
	cost = 300
	required_tech = list(RESEARCH_TREE_PLASMA = 6, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_BLUESPACE = 6, RESEARCH_TREE_MATERIALS = 5)
	containername = "ящик блюспейс-ранцев"
	container_ru_names = list(
		NOMINATIVE = "ящик блюспейс-ранцев",
		GENITIVE = "ящика блюспейс-ранцев",
		DATIVE = "ящику блюспейс-ранцев",
		ACCUSATIVE = "ящик блюспейс-ранцев",
		INSTRUMENTAL = "ящиком блюспейс-ранцев",
		PREPOSITIONAL = "ящике блюспейс-ранцев",
	)

/datum/supply_packs/science/soduffelbag
	name = "Блюспейс сумки хранения"
	contains = list(
		/obj/item/storage/backpack/holding/satchel/duffelbag,
		/obj/item/storage/backpack/holding/satchel/duffelbag,
		/obj/item/storage/backpack/holding/satchel/duffelbag,
	)
	cost = 400
	required_tech = list(RESEARCH_TREE_PLASMA = 7, RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_BLUESPACE = 7, RESEARCH_TREE_MATERIALS = 7)
	containername = "ящик блюспейс спортивных сумок"
	container_ru_names = list(
		NOMINATIVE = "ящик блюспейс спортивных сумок",
		GENITIVE = "ящика блюспейс спортивных сумок",
		DATIVE = "ящику блюспейс спортивных сумок",
		ACCUSATIVE = "ящик блюспейс спортивных сумок",
		INSTRUMENTAL = "ящиком блюспейс спортивных сумок",
		PREPOSITIONAL = "ящике блюспейс спортивных сумок",
	)

/datum/supply_packs/science/belt_of_hold
	name = "Блюспейс-пояса"
	containername = "ящик блюспейс-поясов"
	container_ru_names = list(
		NOMINATIVE = "ящик блюспейс-поясов",
		GENITIVE = "ящика блюспейс-поясов",
		DATIVE = "ящику блюспейс-поясов",
		ACCUSATIVE = "ящик блюспейс-поясов",
		INSTRUMENTAL = "ящиком блюспейс-поясов",
		PREPOSITIONAL = "ящике блюспейс-поясов",
	)
	cost = 220
	contains = list(
		/obj/item/storage/belt/bluespace,
		/obj/item/storage/belt/bluespace,
		/obj/item/storage/belt/bluespace,
	)
	required_tech = list(RESEARCH_TREE_PLASMA = 6, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_BLUESPACE = 6, RESEARCH_TREE_MATERIALS = 5)

/datum/supply_packs/science/mining_sohs
	name = "Блюспейс-сумки для руды"
	containername = "ящик блюспейс-сумок для руды"
	container_ru_names = list(
		NOMINATIVE = "ящик блюспейс-сумок для руды",
		GENITIVE = "ящика блюспейс-сумок для руды",
		DATIVE = "ящику блюспейс-сумок для руды",
		ACCUSATIVE = "ящик блюспейс-сумок для руды",
		INSTRUMENTAL = "ящиком блюспейс-сумок для руды",
		PREPOSITIONAL = "ящике блюспейс-сумок для руды",
	)
	cost = 200
	contains = list(
		/obj/item/storage/bag/ore/holding,
		/obj/item/storage/bag/ore/holding,
		/obj/item/storage/bag/ore/holding,
	)
	required_tech = list(RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_BLUESPACE = 4, RESEARCH_TREE_MATERIALS = 3)

/datum/supply_packs/science/cutters
	name = "Продвинутые плазменные резаки"
	containername = "ящик продвинутых плазменных резаков"
	container_ru_names = list(
		NOMINATIVE = "ящик продвинутых плазменных резаков",
		GENITIVE = "ящика продвинутых плазменных резаков",
		DATIVE = "ящику продвинутых плазменных резаков",
		ACCUSATIVE = "ящик продвинутых плазменных резаков",
		INSTRUMENTAL = "ящиком продвинутых плазменных резаков",
		PREPOSITIONAL = "ящике продвинутых плазменных резаков",
	)
	cost = 220
	contains = list(
		/obj/item/gun/energy/plasmacutter/adv,
		/obj/item/gun/energy/plasmacutter/adv,
		/obj/item/gun/energy/plasmacutter/adv,
	)
	required_tech = list(RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_COMBAT = 3, RESEARCH_TREE_PLASMA = 6, RESEARCH_TREE_MATERIALS = 5, RESEARCH_TREE_MAGNETS = 3)

/datum/supply_packs/science/cutters_shotgun
	name = "Плазменные дробовики"
	containername = "ящик плазменных дробовиков"
	container_ru_names = list(
		NOMINATIVE = "ящик плазменных дробовиков",
		GENITIVE = "ящика плазменных дробовиков",
		DATIVE = "ящику плазменных дробовиков",
		ACCUSATIVE = "ящик плазменных дробовиков",
		INSTRUMENTAL = "ящиком плазменных дробовиков",
		PREPOSITIONAL = "ящике плазменных дробовиков",
	)
	cost = 320
	contains = list(
		/obj/item/gun/energy/plasmacutter/shotgun,
		/obj/item/gun/energy/plasmacutter/shotgun,
		/obj/item/gun/energy/plasmacutter/shotgun,
	)
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_PLASMA = 7, RESEARCH_TREE_MATERIALS = 7, RESEARCH_TREE_MAGNETS = 6)

/datum/supply_packs/science/eka
	name = "Экспериментальные кинетические акселераторы"
	containername = "ящик экспериментальных кинетических акселераторов"
	container_ru_names = list(
		NOMINATIVE = "ящик экспериментальных кинетических акселераторов",
		GENITIVE = "ящика экспериментальных кинетических акселераторов",
		DATIVE = "ящику экспериментальных кинетических акселераторов",
		ACCUSATIVE = "ящик экспериментальных кинетических акселераторов",
		INSTRUMENTAL = "ящиком экспериментальных кинетических акселераторов",
		PREPOSITIONAL = "ящике экспериментальных кинетических акселераторов",
	)
	cost = 270
	contains = list(
		/obj/item/gun/energy/kinetic_accelerator/experimental,
		/obj/item/gun/energy/kinetic_accelerator/experimental,
		/obj/item/gun/energy/kinetic_accelerator/experimental,
	)
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 4, RESEARCH_TREE_ENGINEERING = 6, RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_MATERIALS = 4)

/datum/supply_packs/science/fireproof_rods
	name = "Огнеупорные пруты"
	containername = "ящик огнеупорных прутов"
	container_ru_names = list(
		NOMINATIVE = "ящик огнеупорных прутов",
		GENITIVE = "ящика огнеупорных прутов",
		DATIVE = "ящику огнеупорных прутов",
		ACCUSATIVE = "ящик огнеупорных прутов",
		INSTRUMENTAL = "ящиком огнеупорных прутов",
		PREPOSITIONAL = "ящике огнеупорных прутов",
	)
	cost = 150
	contains = list(
		/obj/item/stack/fireproof_rods/twentyfive,
	)
	required_tech = list(RESEARCH_TREE_PLASMA = 4, RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_MATERIALS = 6)

/datum/supply_packs/science/super_cell
	name = "Батареи ААА"
	containername = "ящик батарей ААА"
	container_ru_names = list(
		NOMINATIVE = "ящик батарей ААА",
		GENITIVE = "ящика батарей ААА",
		DATIVE = "ящику батарей ААА",
		ACCUSATIVE = "ящик батарей ААА",
		INSTRUMENTAL = "ящиком батарей ААА",
		PREPOSITIONAL = "ящике батарей ААА",
	)
	cost = 100
	contains = list(
		/obj/item/stock_parts/cell/super/empty,
		/obj/item/stock_parts/cell/super/empty,
		/obj/item/stock_parts/cell/super/empty,
		/obj/item/stock_parts/cell/super,
		/obj/item/stock_parts/cell/super,
		/obj/item/stock_parts/cell/super,
	)
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 3, RESEARCH_TREE_MATERIALS = 3)

/datum/supply_packs/science/bluespace_cell
	name = "Блюспейс-батареи"
	containername = "ящик блюспейс-батарей"
	container_ru_names = list(
		NOMINATIVE = "ящик блюспейс-батарей",
		GENITIVE = "ящика блюспейс-батарей",
		DATIVE = "ящику блюспейс-батарей",
		ACCUSATIVE = "ящик блюспейс-батарей",
		INSTRUMENTAL = "ящиком блюспейс-батарей",
		PREPOSITIONAL = "ящике блюспейс-батарей",
	)
	cost = 200
	contains = list(
		/obj/item/stock_parts/cell/bluespace/empty,
		/obj/item/stock_parts/cell/bluespace/empty,
		/obj/item/stock_parts/cell/bluespace/empty,
		/obj/item/stock_parts/cell/bluespace,
		/obj/item/stock_parts/cell/bluespace,
		/obj/item/stock_parts/cell/bluespace,
	)
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 6, RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_BLUESPACE = 5,)

/datum/supply_packs/science/adv_tools
	name = "Технологичные инструменты"
	containername = "ящик технологичных инструментов"
	container_ru_names = list(
		NOMINATIVE = "ящик технологичных инструментов",
		GENITIVE = "ящика технологичных инструментов",
		DATIVE = "ящику технологичных инструментов",
		ACCUSATIVE = "ящик технологичных инструментов",
		INSTRUMENTAL = "ящиком технологичных инструментов",
		PREPOSITIONAL = "ящике технологичных инструментов",
	)
	cost = 200
	contains = list(
		/obj/item/weldingtool/experimental,
		/obj/item/weldingtool/experimental,
		/obj/item/screwdriver/power,
		/obj/item/screwdriver/power,
		/obj/item/crowbar/power,
		/obj/item/crowbar/power,
		/obj/item/clothing/mask/gas/welding,
		/obj/item/clothing/mask/gas/welding,
	)
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 7, RESEARCH_TREE_ENGINEERING = 4, RESEARCH_TREE_MAGNETS = 6, RESEARCH_TREE_BLUESPACE = 5, RESEARCH_TREE_BIOTECH = 3, RESEARCH_TREE_MATERIALS = 2)

/datum/supply_packs/science/rcd_crate
	name = "Устройства Быстрого Строительства"
	containername = "ящик УБС"
	container_ru_names = list(
		NOMINATIVE = "ящик УБС",
		GENITIVE = "ящика УБС",
		DATIVE = "ящику УБС",
		ACCUSATIVE = "ящик УБС",
		INSTRUMENTAL = "ящиком УБС",
		PREPOSITIONAL = "ящике УБС",
	)
	cost = 200
	contains = list(
		/obj/item/rcd,
		/obj/item/rcd,
		/obj/item/rcd,
	)
	required_tech = list(RESEARCH_TREE_ENGINEERING = 3, RESEARCH_TREE_PROGRAMMING = 2)

/datum/supply_packs/science/bluespace_beakers
	name = "Блюспейс мерные стаканы"
	containername = "ящик блюспейс мерных стаканов"
	container_ru_names = list(
		NOMINATIVE = "ящик блюспейс мерных стаканов",
		GENITIVE = "ящика блюспейс мерных стаканов",
		DATIVE = "ящику блюспейс мерных стаканов",
		ACCUSATIVE = "ящик блюспейс мерных стаканов",
		INSTRUMENTAL = "ящиком блюспейс мерных стаканов",
		PREPOSITIONAL = "ящике блюспейс мерных стаканов",
	)
	cost = 150
	contains = list(
		/obj/item/storage/box/beakers/bluespace,
		/obj/item/storage/box/beakers/bluespace,
	)
	required_tech = list(RESEARCH_TREE_PLASMA = 4, RESEARCH_TREE_BLUESPACE = 6, RESEARCH_TREE_MATERIALS = 5)

/datum/supply_packs/science/deluxe_parts
	name = "Компоненты 4-го поколения"
	containername = "ящик компонентов 4-го поколения"
	container_ru_names = list(
		NOMINATIVE = "ящик компонентов 4-го поколения",
		GENITIVE = "ящика компонентов 4-го поколения",
		DATIVE = "ящику компонентов 4-го поколения",
		ACCUSATIVE = "ящик компонентов 4-го поколения",
		INSTRUMENTAL = "ящиком компонентов 4-го поколения",
		PREPOSITIONAL = "ящике компонентов 4-го поколения",
	)
	cost = 180
	contains = list(
		/obj/item/storage/box/stockparts/deluxe,
		/obj/item/storage/box/stockparts/deluxe,
	)
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 7, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MAGNETS = 6, RESEARCH_TREE_BLUESPACE = 6, RESEARCH_TREE_PROGRAMMING = 6, RESEARCH_TREE_MATERIALS = 7)

/datum/supply_packs/science/cyborg_upgrades
	name = "Улучшения для роботов"
	containername = "ящик улучшений для роботов"
	container_ru_names = list(
		NOMINATIVE = "ящик улучшений для роботов",
		GENITIVE = "ящика улучшений для роботов",
		DATIVE = "ящику улучшений для роботов",
		ACCUSATIVE = "ящик улучшений для роботов",
		INSTRUMENTAL = "ящиком улучшений для роботов",
		PREPOSITIONAL = "ящике улучшений для роботов",
	)
	cost = 250
	contains = list(
		/obj/item/borg/upgrade/vtec,
		/obj/item/borg/upgrade/vtec,
		/obj/item/borg/upgrade/vtec,
		/obj/item/borg/upgrade/thrusters,
		/obj/item/borg/upgrade/thrusters,
		/obj/item/borg/upgrade/thrusters,
	)
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_MAGNETS = 6, RESEARCH_TREE_MATERIALS = 6)

/datum/supply_packs/science/civ_implants
	name = "Гражданские импланты"
	containername = "ящик гражданских имплантов"
	container_ru_names = list(
		NOMINATIVE = "ящик гражданских имплантов",
		GENITIVE = "ящика гражданских имплантов",
		DATIVE = "ящику гражданских имплантов",
		ACCUSATIVE = "ящик гражданских имплантов",
		INSTRUMENTAL = "ящиком гражданских имплантов",
		PREPOSITIONAL = "ящике гражданских имплантов",
	)
	cost = 160
	contains = list(
		/obj/item/organ/internal/cyberimp/eyes/shield,
		/obj/item/organ/internal/cyberimp/eyes/shield,
		/obj/item/organ/internal/cyberimp/mouth/breathing_tube,
		/obj/item/organ/internal/cyberimp/mouth/breathing_tube,
		/obj/item/organ/internal/cyberimp/eyes/meson,
		/obj/item/organ/internal/cyberimp/eyes/meson,
	)
	required_tech = list(RESEARCH_TREE_MATERIALS = 4, RESEARCH_TREE_BIOTECH = 4, RESEARCH_TREE_ENGINEERING = 5, RESEARCH_TREE_PLASMA = 4)

//Nanotrasen tailblade
/datum/supply_packs/science/tailblade
	name = "Хвостовое лазерное лезвие"
	cost = 50
	contains = list(
		/obj/item/disk/design_disk/tailblade/blade_nt,
	)
	containername = "ящик с хвостовым лазерным лезвием"
	container_ru_names = list(
		NOMINATIVE = "ящик с хвостовым лазерным лезвием",
		GENITIVE = "ящика с хвостовым лазерным лезвием",
		DATIVE = "ящику с хвостовым лазерным лезвием",
		ACCUSATIVE = "ящик с хвостовым лазерным лезвием",
		INSTRUMENTAL = "ящиком с хвостовым лазерным лезвием",
		PREPOSITIONAL = "ящике с хвостовым лазерным лезвием",
	)
	containertype = /obj/structure/closet/crate/secure/scisec
	access = ACCESS_RESEARCH
	required_tech = list(RESEARCH_TREE_MATERIALS = 6, RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_BIOTECH = 6, RESEARCH_TREE_POWERSTORAGE = 5)

/datum/supply_packs/science/modcore
	name = "Ящик ядер МЭК"
	contains = list(
		/obj/item/mod/core/standard,
		/obj/item/mod/core/standard,
		/obj/item/mod/core/standard,
		/obj/item/mod/core/standard,
	)
	cost = 50
	access = ACCESS_ROBOTICS
	announce_beacons = list("Research Division" = list("Robotics"))
	containertype = /obj/structure/closet/crate/secure/scisec
	containername = "ящик с ядрами МЭК"
	container_ru_names = list(
		NOMINATIVE = "ящик с ядрами МЭК",
		GENITIVE = "ящика с ядрами МЭК",
		DATIVE = "ящику с ядрами МЭК",
		ACCUSATIVE = "ящик с ядрами МЭК",
		INSTRUMENTAL = "ящиком с ядрами МЭК",
		PREPOSITIONAL = "ящике с ядрами МЭК",
	)

/datum/supply_packs/science/txdisk
	name = "Пустые дискеты технологий"
	containername = "ящик пустых дискет технологий"
	container_ru_names = list(
		NOMINATIVE = "ящик пустых дискет технологий",
		GENITIVE = "ящика пустых дискет технологий",
		DATIVE = "ящику пустых дискет технологий",
		ACCUSATIVE = "ящик пустых дискет технологий",
		INSTRUMENTAL = "ящиком пустых дискет технологий",
		PREPOSITIONAL = "ящике пустых дискет технологий",
	)
	cost = 40
	contains = list(
		/obj/item/storage/box/disks_tech,
		/obj/item/storage/box/disks_tech,
		/obj/item/storage/box/disks_tech,
	)

//////////////////////////////////////////////////////////////////////////////
// MARK: Organic
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/organic
	name = "HEADER"
	group = SUPPLY_ORGANIC
	containertype = /obj/structure/closet/crate/freezer

/datum/supply_packs/organic/food
	name = "Пищевые продукты"
	contains = list(
		/obj/item/reagent_containers/food/condiment/flour,
		/obj/item/reagent_containers/food/condiment/rice,
		/obj/item/reagent_containers/food/condiment/milk,
		/obj/item/reagent_containers/food/condiment/soymilk,
		/obj/item/reagent_containers/food/condiment/saltshaker,
		/obj/item/reagent_containers/food/condiment/peppermill,
		/obj/item/kitchen/rollingpin,
		/obj/item/storage/fancy/egg_box,
		/obj/item/mixing_bowl,
		/obj/item/mixing_bowl,
		/obj/item/reagent_containers/food/condiment/enzyme,
		/obj/item/reagent_containers/food/condiment/sugar,
		/obj/item/reagent_containers/food/snacks/meat/humanoid/monkey,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/banana,
		/obj/item/reagent_containers/food/snacks/grown/banana,
	)
	cost = 10
	containername = "ящик пищевых продуктов"
	container_ru_names = list(
		NOMINATIVE = "ящик пищевых продуктов",
		GENITIVE = "ящика пищевых продуктов",
		DATIVE = "ящику пищевых продуктов",
		ACCUSATIVE = "ящик пищевых продуктов",
		INSTRUMENTAL = "ящиком пищевых продуктов",
		PREPOSITIONAL = "ящике пищевых продуктов",
	)
	announce_beacons = list("Kitchen" = list("Kitchen"))

/datum/supply_packs/organic/pizza
	name = "Пицца"
	contains = list(
		/obj/item/pizzabox/margherita,
		/obj/item/pizzabox/mushroom,
		/obj/item/pizzabox/meat,
		/obj/item/pizzabox/vegetable,
		/obj/item/pizzabox/hawaiian,
	)
	cost = 80
	containername = "ящик пиццы"
	container_ru_names = list(
		NOMINATIVE = "ящик пиццы",
		GENITIVE = "ящика пиццы",
		DATIVE = "ящику пиццы",
		ACCUSATIVE = "ящик пиццы",
		INSTRUMENTAL = "ящиком пиццы",
		PREPOSITIONAL = "ящике пиццы",
	)

/datum/supply_packs/organic/monkey
	name = "Шимпанзе"
	contains = list (/obj/item/storage/box/monkeycubes,
	)
	cost = 30
	containername = "ящик шимпанзе"
	container_ru_names = list(
		NOMINATIVE = "ящик шимпанзе",
		GENITIVE = "ящика шимпанзе",
		DATIVE = "ящику шимпанзе",
		ACCUSATIVE = "ящик шимпанзе",
		INSTRUMENTAL = "ящиком шимпанзе",
		PREPOSITIONAL = "ящике шимпанзе",
	)

/datum/supply_packs/organic/farwa
	name = "Фарвы"
	contains = list (/obj/item/storage/box/monkeycubes/farwacubes,
	)
	cost = 30
	containername = "ящик фарв"
	container_ru_names = list(
		NOMINATIVE = "ящик фарв",
		GENITIVE = "ящика фарв",
		DATIVE = "ящику фарв",
		ACCUSATIVE = "ящик фарв",
		INSTRUMENTAL = "ящиком фарв",
		PREPOSITIONAL = "ящике фарв",
	)

/datum/supply_packs/organic/wolpin
	name = "Вульпины"
	contains = list (/obj/item/storage/box/monkeycubes/wolpincubes,
	)
	cost = 30
	containername = "ящик вульпинов"
	container_ru_names = list(
		NOMINATIVE = "ящик вульпинов",
		GENITIVE = "ящика вульпинов",
		DATIVE = "ящику вульпинов",
		ACCUSATIVE = "ящик вульпинов",
		INSTRUMENTAL = "ящиком вульпинов",
		PREPOSITIONAL = "ящике вульпинов",
	)

/datum/supply_packs/organic/skrell
	name = "Неары"
	contains = list (/obj/item/storage/box/monkeycubes/neaeracubes,
	)
	cost = 30
	containername = "ящик неар"
	container_ru_names = list(
		NOMINATIVE = "ящик неар",
		GENITIVE = "ящика неар",
		DATIVE = "ящику неар",
		ACCUSATIVE = "ящик неар",
		INSTRUMENTAL = "ящиком неар",
		PREPOSITIONAL = "ящике неар",
	)

/datum/supply_packs/organic/stok
	name = "Стоки"
	contains = list (/obj/item/storage/box/monkeycubes/stokcubes,
	)
	cost = 30
	containername = "ящик стоков"
	container_ru_names = list(
		NOMINATIVE = "ящик стоков",
		GENITIVE = "ящика стоков",
		DATIVE = "ящику стоков",
		ACCUSATIVE = "ящик стоков",
		INSTRUMENTAL = "ящиком стоков",
		PREPOSITIONAL = "ящике стоков",
	)

/datum/supply_packs/organic/party
	name = "Набор для вечеринки"
	contains = list(
		/obj/item/storage/box/drinkingglasses,
		/obj/item/reagent_containers/food/drinks/shaker,
		/obj/item/reagent_containers/food/drinks/bottle/patron,
		/obj/item/reagent_containers/food/drinks/bottle/goldschlager,
		/obj/item/reagent_containers/food/drinks/cans/ale,
		/obj/item/reagent_containers/food/drinks/cans/ale,
		/obj/item/reagent_containers/food/drinks/cans/beer,
		/obj/item/reagent_containers/food/drinks/cans/beer,
		/obj/item/reagent_containers/food/drinks/cans/beer,
		/obj/item/reagent_containers/food/drinks/cans/beer,
		/obj/item/grenade/confetti,
		/obj/item/grenade/confetti,
	)
	cost = 20
	containername = "ящик с набором для вечеринки"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором для вечеринки",
		GENITIVE = "ящика с набором для вечеринки",
		DATIVE = "ящику с набором для вечеринки",
		ACCUSATIVE = "ящик с набором для вечеринки",
		INSTRUMENTAL = "ящиком с набором для вечеринки",
		PREPOSITIONAL = "ящике с набором для вечеринки",
	)
	announce_beacons = list("Bar" = list("Bar"))

/datum/supply_packs/organic/bar
	name = "Набор для создания бара"
	contains = list(
		/obj/item/storage/box/drinkingglasses,
		/obj/item/circuitboard/chem_dispenser/soda,
		/obj/item/circuitboard/chem_dispenser/beer,
	)
	cost = 25
	containername = "ящик с набором для создания бара"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором для создания бара",
		GENITIVE = "ящика с набором для создания бара",
		DATIVE = "ящику с набором для создания бара",
		ACCUSATIVE = "ящик с набором для создания бара",
		INSTRUMENTAL = "ящиком с набором для создания бара",
		PREPOSITIONAL = "ящике с набором для создания бара",
	)
	announce_beacons = list("Bar" = list("Bar"))

/datum/supply_packs/organic/coffee_syrups
	name = "Ящик кофейных сиропов"
	contains = list(
		/obj/item/reagent_containers/glass/bottle/syrup_bottle/caramel,
		/obj/item/reagent_containers/glass/bottle/syrup_bottle/caramel,
		/obj/item/reagent_containers/glass/bottle/syrup_bottle/liqueur,
		/obj/item/reagent_containers/glass/bottle/syrup_bottle/liqueur,
	)
	cost = 20
	containername = "ящик кофейных сиропов"
	container_ru_names = list(
		NOMINATIVE = "ящик кофейных сиропов",
		GENITIVE = "ящика кофейных сиропов",
		DATIVE = "ящику кофейных сиропов",
		ACCUSATIVE = "ящик кофейных сиропов",
		INSTRUMENTAL = "ящиком кофейных сиропов",
		PREPOSITIONAL = "ящике кофейных сиропов",
	)

/datum/supply_packs/organic/standard_coffeemachine
	name = "Плата кофемашины \"Моделло 3\""
	contains = list(/obj/item/circuitboard/coffeemaker/standard)
	cost = 35
	containername = "ящик с кофемашиной \"Моделло 3\""
	container_ru_names = list(
		NOMINATIVE = "ящик с кофемашиной \"Моделло 3\"",
		GENITIVE = "ящика с кофемашиной \"Моделло 3\"",
		DATIVE = "ящику с кофемашиной \"Моделло 3\"",
		ACCUSATIVE = "ящик с кофемашиной \"Моделло 3\"",
		INSTRUMENTAL = "ящиком с кофемашиной \"Моделло 3\"",
		PREPOSITIONAL = "ящике с кофемашиной \"Моделло 3\"",
	)

/datum/supply_packs/organic/impressa_coffeemachine
	name = "Плата кофемашины \"Импресса Моделло 5\""
	contains = list(/obj/item/circuitboard/coffeemaker/impressa)
	cost = 60
	containername = "ящик с кофемашиной \"Импресса Моделло 5\""
	container_ru_names = list(
		NOMINATIVE = "ящик с кофемашиной \"Импресса Моделло 5\"",
		GENITIVE = "ящика с кофемашиной \"Импресса Моделло 5\"",
		DATIVE = "ящику с кофемашиной \"Импресса Моделло 5\"",
		ACCUSATIVE = "ящик с кофемашиной \"Импресса Моделло 5\"",
		INSTRUMENTAL = "ящиком с кофемашиной \"Импресса Моделло 5\"",
		PREPOSITIONAL = "ящике с кофемашиной \"Импресса Моделло 5\"",
	)

/datum/supply_packs/organic/coffee_cartridges
	name = "Набор кофейных картриджей"
	contains = list(
		/obj/item/coffee_cartridge,
		/obj/item/coffee_cartridge,
		/obj/item/coffee_cartridge,
	)
	cost = 25
	containername = "ящик кофейных картриджей"
	container_ru_names = list(
		NOMINATIVE = "ящик кофейных картриджей",
		GENITIVE = "ящика кофейных картриджей",
		DATIVE = "ящику кофейных картриджей",
		ACCUSATIVE = "ящик кофейных картриджей",
		INSTRUMENTAL = "ящиком кофейных картриджей",
		PREPOSITIONAL = "ящике кофейных картриджей",
	)

/datum/supply_packs/organic/coffee_cartridges_premium
	name = "Набор премиальных кофейных картриджей"
	contains = list(
		/obj/item/coffee_cartridge/fancy,
		/obj/item/coffee_cartridge/fancy,
		/obj/item/coffee_cartridge/fancy,
	)
	cost = 35
	containername = "ящик премиальных кофейных картриджей"
	container_ru_names = list(
		NOMINATIVE = "ящик премиальных кофейных картриджей",
		GENITIVE = "ящика премиальных кофейных картриджей",
		DATIVE = "ящику премиальных кофейных картриджей",
		ACCUSATIVE = "ящик премиальных кофейных картриджей",
		INSTRUMENTAL = "ящиком премиальных кофейных картриджей",
		PREPOSITIONAL = "ящике премиальных кофейных картриджей",
	)

/datum/supply_packs/organic/coffee_packs
	name = "Набор пакетов кофе"
	contains = list(
		/obj/item/storage/box/coffeepack,
		/obj/item/storage/box/coffeepack,
		/obj/item/storage/box/coffeepack/robusta,
		/obj/item/storage/box/coffeepack/robusta,
	)
	cost = 30
	containername = "ящик пакетов кофе"
	container_ru_names = list(
		NOMINATIVE = "ящик пакетов кофе",
		GENITIVE = "ящика пакетов кофе",
		DATIVE = "ящику пакетов кофе",
		ACCUSATIVE = "ящик пакетов кофе",
		INSTRUMENTAL = "ящиком пакетов кофе",
		PREPOSITIONAL = "ящике пакетов кофе",
	)

//////// livestock
/datum/supply_packs/organic/cow
	name = "Корова"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/cow
	containername = "ящик с коровой"
	container_ru_names = list(
		NOMINATIVE = "ящик с коровой",
		GENITIVE = "ящика с коровой",
		DATIVE = "ящику с коровой",
		ACCUSATIVE = "ящик с коровой",
		INSTRUMENTAL = "ящиком с коровой",
		PREPOSITIONAL = "ящике с коровой",
	)

/datum/supply_packs/organic/pig
	name = "Свинья"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/pig
	containername = "ящик со свиньёй"
	container_ru_names = list(
		NOMINATIVE = "ящик со свиньёй",
		GENITIVE = "ящика со свиньёй",
		DATIVE = "ящику со свиньёй",
		ACCUSATIVE = "ящик со свиньёй",
		INSTRUMENTAL = "ящиком со свиньёй",
		PREPOSITIONAL = "ящике со свиньёй",
	)

/datum/supply_packs/organic/goat
	name = "Козёл"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/goat
	containername = "ящик с козлом"
	container_ru_names = list(
		NOMINATIVE = "ящик с козлом",
		GENITIVE = "ящика с козлом",
		DATIVE = "ящику с козлом",
		ACCUSATIVE = "ящик с козлом",
		INSTRUMENTAL = "ящиком с козлом",
		PREPOSITIONAL = "ящике с козлом",
	)

/datum/supply_packs/organic/chicken
	name = "Курица"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/chick
	containername = "ящик с курицей"
	container_ru_names = list(
		NOMINATIVE = "ящик с курицей",
		GENITIVE = "ящика с курицей",
		DATIVE = "ящику с курицей",
		ACCUSATIVE = "ящик с курицей",
		INSTRUMENTAL = "ящиком с курицей",
		PREPOSITIONAL = "ящике с курицей",
	)

/datum/supply_packs/organic/turkey
	name = "Индейка"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/turkey
	containername = "ящик с индейкой"
	container_ru_names = list(
		NOMINATIVE = "ящик с индейкой",
		GENITIVE = "ящика с индейкой",
		DATIVE = "ящику с индейкой",
		ACCUSATIVE = "ящик с индейкой",
		INSTRUMENTAL = "ящиком с индейкой",
		PREPOSITIONAL = "ящике с индейкой",
	)
/datum/supply_packs/organic/corgi
	name = "Корги"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/corgi
	contains = list(
		/obj/item/clothing/accessory/petcollar,
	)
	containername = "ящик с корги"
	container_ru_names = list(
		NOMINATIVE = "ящик с корги",
		GENITIVE = "ящика с корги",
		DATIVE = "ящику с корги",
		ACCUSATIVE = "ящик с корги",
		INSTRUMENTAL = "ящиком с корги",
		PREPOSITIONAL = "ящике с корги",
	)

/datum/supply_packs/organic/dog_pug
	name = "Мопс"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/dog_pug
	contains = list(
		/obj/item/clothing/accessory/petcollar,
	)
	containername = "ящик с мопсом"
	container_ru_names = list(
		NOMINATIVE = "ящик с мопсом",
		GENITIVE = "ящика с мопсом",
		DATIVE = "ящику с мопсом",
		ACCUSATIVE = "ящик с мопсом",
		INSTRUMENTAL = "ящиком с мопсом",
		PREPOSITIONAL = "ящике с мопсом",
	)

/datum/supply_packs/organic/dog_bullterrier
	name = "Бультерьер"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/dog_bullterrier
	contains = list(
		/obj/item/clothing/accessory/petcollar,
	)
	containername = "ящик с бультерьером"
	container_ru_names = list(
		NOMINATIVE = "ящик с бультерьером",
		GENITIVE = "ящика с бультерьером",
		DATIVE = "ящику с бультерьером",
		ACCUSATIVE = "ящик с бультерьером",
		INSTRUMENTAL = "ящиком с бультерьером",
		PREPOSITIONAL = "ящике с бультерьером",
	)

/datum/supply_packs/organic/dog_tamaskan
	name = "Тамасканская собака"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/dog_tamaskan
	contains = list(
		/obj/item/clothing/accessory/petcollar,
	)
	containername = "ящик с тамасканской собакой"
	container_ru_names = list(
		NOMINATIVE = "ящик с тамасканской собакой",
		GENITIVE = "ящика с тамасканской собакой",
		DATIVE = "ящику с тамасканской собакой",
		ACCUSATIVE = "ящик с тамасканской собакой",
		INSTRUMENTAL = "ящиком с тамасканской собакой",
		PREPOSITIONAL = "ящике с тамасканской собакой",
	)

/datum/supply_packs/organic/dog_german
	name = "Немецкая овчарка"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/dog_german
	contains = list(
		/obj/item/clothing/accessory/petcollar,
	)
	containername = "ящик с немецкой овчаркой"
	container_ru_names = list(
		NOMINATIVE = "ящик с немецкой овчаркой",
		GENITIVE = "ящика с немецкой овчаркой",
		DATIVE = "ящику с немецкой овчаркой",
		ACCUSATIVE = "ящик с немецкой овчаркой",
		INSTRUMENTAL = "ящиком с немецкой овчаркой",
		PREPOSITIONAL = "ящике с немецкой овчаркой",
	)

/datum/supply_packs/organic/dog_brittany
	name = "Бретонский эпаньоль"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/dog_brittany
	contains = list(
		/obj/item/clothing/accessory/petcollar,
	)
	containername = "ящик с бретонским эпаньолем"
	container_ru_names = list(
		NOMINATIVE = "ящик с бретонским эпаньолем",
		GENITIVE = "ящика с бретонским эпаньолем",
		DATIVE = "ящику с бретонским эпаньолем",
		ACCUSATIVE = "ящик с бретонским эпаньолем",
		INSTRUMENTAL = "ящиком с бретонским эпаньолем",
		PREPOSITIONAL = "ящике с бретонским эпаньолем",
	)

/datum/supply_packs/organic/cat
	name = "Кошка"
	cost = 50 //Cats are worth as much as corgis.
	containertype = /obj/structure/closet/crate/critter/cat
	contains = list(
		/obj/item/clothing/accessory/petcollar,
		/obj/item/toy/cattoy,
	)
	containername = "ящик с кошкой"
	container_ru_names = list(
		NOMINATIVE = "ящик с кошкой",
		GENITIVE = "ящика с кошкой",
		DATIVE = "ящику с кошкой",
		ACCUSATIVE = "ящик с кошкой",
		INSTRUMENTAL = "ящиком с кошкой",
		PREPOSITIONAL = "ящике с кошкой",
	)

/datum/supply_packs/organic/cat/white
	name = "Белая кошка"
	containername = "ящик с белой кошкой"
	container_ru_names = list(
		NOMINATIVE = "ящик с белой кошкой",
		GENITIVE = "ящика с белой кошкой",
		DATIVE = "ящику с белой кошкой",
		ACCUSATIVE = "ящик с белой кошкой",
		INSTRUMENTAL = "ящиком с белой кошкой",
		PREPOSITIONAL = "ящике с белой кошкой",
	)
	containertype = /obj/structure/closet/crate/critter/cat_white

/datum/supply_packs/organic/cat/birman
	name = "Бирманская кошка"
	containername = "ящик с бирманской кошкой"
	container_ru_names = list(
		NOMINATIVE = "ящик с бирманской кошкой",
		GENITIVE = "ящика с бирманской кошкой",
		DATIVE = "ящику с бирманской кошкой",
		ACCUSATIVE = "ящик с бирманской кошкой",
		INSTRUMENTAL = "ящиком с бирманской кошкой",
		PREPOSITIONAL = "ящике с бирманской кошкой",
	)
	containertype = /obj/structure/closet/crate/critter/cat_birman

/datum/supply_packs/organic/fox
	name = "Лиса"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/fox
	contains = list(
		/obj/item/clothing/accessory/petcollar,
	)
	containername = "ящик с лисой"
	container_ru_names = list(
		NOMINATIVE = "ящик с лисой",
		GENITIVE = "ящика с лисой",
		DATIVE = "ящику с лисой",
		ACCUSATIVE = "ящик с лисой",
		INSTRUMENTAL = "ящиком с лисой",
		PREPOSITIONAL = "ящике с лисой",
	)

/datum/supply_packs/organic/fennec
	name = "Фенёк"
	cost = 80
	containertype = /obj/structure/closet/crate/critter/fennec
	contains = list(
		/obj/item/clothing/accessory/petcollar,
	)
	containername = "ящик с феньком"
	container_ru_names = list(
		NOMINATIVE = "ящик с феньком",
		GENITIVE = "ящика с феньком",
		DATIVE = "ящику с феньком",
		ACCUSATIVE = "ящик с феньком",
		INSTRUMENTAL = "ящиком с феньком",
		PREPOSITIONAL = "ящике с феньком",
	)
/datum/supply_packs/organic/butterfly
	name = "Бабочка"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/butterfly
	containername = "ящик с бабочкой"
	container_ru_names = list(
		NOMINATIVE = "ящик с бабочкой",
		GENITIVE = "ящика с бабочкой",
		DATIVE = "ящику с бабочкой",
		ACCUSATIVE = "ящик с бабочкой",
		INSTRUMENTAL = "ящиком с бабочкой",
		PREPOSITIONAL = "ящике с бабочкой",
	)

/datum/supply_packs/organic/deer
	name = "Олень"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/deer
	containername = "ящик с оленем"
	container_ru_names = list(
		NOMINATIVE = "ящик с оленем",
		GENITIVE = "ящика с оленем",
		DATIVE = "ящику с оленем",
		ACCUSATIVE = "ящик с оленем",
		INSTRUMENTAL = "ящиком с оленем",
		PREPOSITIONAL = "ящике с оленем",
	)

/datum/supply_packs/organic/sloth
	name = "Ленивец"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/sloth
	contains = list(
		/obj/item/clothing/accessory/petcollar,
	)
	containername = "ящик с ленивцем"
	container_ru_names = list(
		NOMINATIVE = "ящик с ленивцем",
		GENITIVE = "ящика с ленивцем",
		DATIVE = "ящику с ленивцем",
		ACCUSATIVE = "ящик с ленивцем",
		INSTRUMENTAL = "ящиком с ленивцем",
		PREPOSITIONAL = "ящике с ленивцем",
	)

/datum/supply_packs/organic/goose
	name = "Гусь"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/goose
	containername = "ящик с гусём"
	container_ru_names = list(
		NOMINATIVE = "ящик с гусём",
		GENITIVE = "ящика с гусём",
		DATIVE = "ящику с гусём",
		ACCUSATIVE = "ящик с гусём",
		INSTRUMENTAL = "ящиком с гусём",
		PREPOSITIONAL = "ящике с гусём",
	)

/datum/supply_packs/organic/gosling
	name = "Гусёнок"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/gosling
	containername = "ящик с гусёнком"
	container_ru_names = list(
		NOMINATIVE = "ящик с гусёнком",
		GENITIVE = "ящика с гусёнком",
		DATIVE = "ящику с гусёнком",
		ACCUSATIVE = "ящик с гусёнком",
		INSTRUMENTAL = "ящиком с гусёнком",
		PREPOSITIONAL = "ящике с гусёнком",
	)

/datum/supply_packs/organic/wooly_mouse
	name = "Лохматая мышь"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/wooly_mouse
	containername = "ящик с лохматой мышью"
	container_ru_names = list(
		NOMINATIVE = "ящик с лохматой мышью",
		GENITIVE = "ящика с лохматой мышью",
		DATIVE = "ящику с лохматой мышью",
		ACCUSATIVE = "ящик с лохматой мышью",
		INSTRUMENTAL = "ящиком с лохматой мышью",
		PREPOSITIONAL = "ящике с лохматой мышью",
	)

/datum/supply_packs/organic/frog
	name = "Лягушка"
	cost = 90
	containertype = /obj/structure/closet/crate/critter/frog
	containername = "ящик с лягушкой"
	container_ru_names = list(
		NOMINATIVE = "ящик с лягушкой",
		GENITIVE = "ящика с лягушкой",
		DATIVE = "ящику с лягушкой",
		ACCUSATIVE = "ящик с лягушкой",
		INSTRUMENTAL = "ящиком с лягушкой",
		PREPOSITIONAL = "ящике с лягушкой",
	)

/datum/supply_packs/organic/frog/toxic
	name = "Токсичная лягушка"
	cost = 200
	containertype = /obj/structure/closet/crate/critter/frog/toxic
	containername = "ящик с токсичной лягушкой"
	container_ru_names = list(
		NOMINATIVE = "ящик с токсичной лягушкой",
		GENITIVE = "ящика с токсичной лягушкой",
		DATIVE = "ящику с токсичной лягушкой",
		ACCUSATIVE = "ящик с токсичной лягушкой",
		INSTRUMENTAL = "ящиком с токсичной лягушкой",
		PREPOSITIONAL = "ящике с токсичной лягушкой",
	)
	hidden = TRUE

/datum/supply_packs/organic/turtle
	name = "Черепаха"
	cost = 80
	containertype = /obj/structure/closet/crate/critter/turtle
	containername = "ящик с черепахой"
	container_ru_names = list(
		NOMINATIVE = "ящик с черепахой",
		GENITIVE = "ящика с черепахой",
		DATIVE = "ящику с черепахой",
		ACCUSATIVE = "ящик с черепахой",
		INSTRUMENTAL = "ящиком с черепахой",
		PREPOSITIONAL = "ящике с черепахой",
	)

/datum/supply_packs/organic/iguana
	name = "Игуана"
	cost = 150
	containertype = /obj/structure/closet/crate/critter/iguana
	containername = "ящик с игуаной"
	container_ru_names = list(
		NOMINATIVE = "ящик с игуаной",
		GENITIVE = "ящика с игуаной",
		DATIVE = "ящику с игуаной",
		ACCUSATIVE = "ящик с игуаной",
		INSTRUMENTAL = "ящиком с игуаной",
		PREPOSITIONAL = "ящике с игуаной",
	)

/datum/supply_packs/organic/gator
	name = "Аллигатор"
	cost = 300	//most dangerous
	containertype = /obj/structure/closet/crate/critter/gator
	containername = "ящик с аллигатором"
	container_ru_names = list(
		NOMINATIVE = "ящик с аллигатором",
		GENITIVE = "ящика с аллигатором",
		DATIVE = "ящику с аллигатором",
		ACCUSATIVE = "ящик с аллигатором",
		INSTRUMENTAL = "ящиком с аллигатором",
		PREPOSITIONAL = "ящике с аллигатором",
	)

/datum/supply_packs/organic/croco
	name = "Крокодил"
	cost = 250
	containertype = /obj/structure/closet/crate/critter/croco
	containername = "ящик с крокодилом"
	container_ru_names = list(
		NOMINATIVE = "ящик с крокодилом",
		GENITIVE = "ящика с крокодилом",
		DATIVE = "ящику с крокодилом",
		ACCUSATIVE = "ящик с крокодилом",
		INSTRUMENTAL = "ящиком с крокодилом",
		PREPOSITIONAL = "ящике с крокодилом",
	)

/datum/supply_packs/organic/snake
	name = "Змея"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/snake
	containername = "ящик со змеёй"
	container_ru_names = list(
		NOMINATIVE = "ящик со змеёй",
		GENITIVE = "ящика со змеёй",
		DATIVE = "ящику со змеёй",
		ACCUSATIVE = "ящик со змеёй",
		INSTRUMENTAL = "ящиком со змеёй",
		PREPOSITIONAL = "ящике со змеёй",
	)

/datum/supply_packs/organic/slime
	name = "Слайм"
	cost = 50
	containertype = /obj/structure/closet/crate/critter/slime
	containername = "ящик со слаймом"
	container_ru_names = list(
		NOMINATIVE = "ящик со слаймом",
		GENITIVE = "ящика со слаймом",
		DATIVE = "ящику со слаймом",
		ACCUSATIVE = "ящик со слаймом",
		INSTRUMENTAL = "ящиком со слаймом",
		PREPOSITIONAL = "ящике со слаймом",
	)

/datum/supply_packs/organic/barthender_rare
	name = "Набор для опытных барменов"
	containername = "ящик с набором для опытных барменов"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором для опытных барменов",
		GENITIVE = "ящика с набором для опытных барменов",
		DATIVE = "ящику с набором для опытных барменов",
		ACCUSATIVE = "ящик с набором для опытных барменов",
		INSTRUMENTAL = "ящиком с набором для опытных барменов",
		PREPOSITIONAL = "ящике с набором для опытных барменов",
	)
	cost = 60
	contains = list(
		/obj/item/storage/box/bartender_rare_ingredients_kit,
	)

/datum/supply_packs/organic/chef_rare
	name = "Набор для опытных поваров"
	containername = "ящик с набором для опытных поваров"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором для опытных поваров",
		GENITIVE = "ящика с набором для опытных поваров",
		DATIVE = "ящику с набором для опытных поваров",
		ACCUSATIVE = "ящик с набором для опытных поваров",
		INSTRUMENTAL = "ящиком с набором для опытных поваров",
		PREPOSITIONAL = "ящике с набором для опытных поваров",
	)
	cost = 40
	contains = list(
		/obj/item/storage/box/chef_rare_ingredients_kit,
		/obj/item/storage/box/chef_rare_ingredients_kit,
	)

/datum/supply_packs/science/strange_seeds
	name = "Странные семена"
	containername = "ящик со странными семенами"
	container_ru_names = list(
		NOMINATIVE = "ящик со странными семенами",
		GENITIVE = "ящика со странными семенами",
		DATIVE = "ящику со странными семенами",
		ACCUSATIVE = "ящик со странными семенами",
		INSTRUMENTAL = "ящиком со странными семенами",
		PREPOSITIONAL = "ящике со странными семенами",
	)
	cost = 300
	contains = list(
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
	)
	required_tech = list(RESEARCH_TREE_BIOTECH = 6)

/datum/supply_packs/organic/gorilla
	name = "Горилла"
	cost = 100
	containertype = /obj/structure/closet/crate/critter/gorilla
	containername = "ящик с гориллой"
	container_ru_names = list(
		NOMINATIVE = "ящик с гориллой",
		GENITIVE = "ящика с гориллой",
		DATIVE = "ящику с гориллой",
		ACCUSATIVE = "ящик с гориллой",
		INSTRUMENTAL = "ящиком с гориллой",
		PREPOSITIONAL = "ящике с гориллой",
	)

/datum/supply_packs/organic/cargororilla
	name = "Каргорилла"
	cost = 150
	containertype = /obj/structure/closet/crate/critter/cargorilla
	containername = "ящик с каргориллой"
	container_ru_names = list(
		NOMINATIVE = "ящик с каргориллой",
		GENITIVE = "ящика с каргориллой",
		DATIVE = "ящику с каргориллой",
		ACCUSATIVE = "ящик с каргориллой",
		INSTRUMENTAL = "ящиком с каргориллой",
		PREPOSITIONAL = "ящике с каргориллой",
	)

////// hippy gear

/datum/supply_packs/organic/hydroponics // -- Skie
	name = "Ботаническое снабжение"
	contains = list(
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/reagent_containers/spray/plantbgone,
		/obj/item/reagent_containers/glass/bottle/ammonia,
		/obj/item/reagent_containers/glass/bottle/ammonia,
		/obj/item/hatchet,
		/obj/item/cultivator,
		/obj/item/plant_analyzer,
		/obj/item/clothing/gloves/botanic_leather,
		/obj/item/clothing/suit/apron,
	) // Updated with new things
	cost = 15
	containertype = /obj/structure/closet/crate/hydroponics
	containername = "ящик ботанического снабжения"
	container_ru_names = list(
		NOMINATIVE = "ящик ботанического снабжения",
		GENITIVE = "ящика ботанического снабжения",
		DATIVE = "ящику ботанического снабжения",
		ACCUSATIVE = "ящик ботанического снабжения",
		INSTRUMENTAL = "ящиком ботанического снабжения",
		PREPOSITIONAL = "ящике ботанического снабжения",
	)

	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_packs/organic/hydroponics/hydrotank
	name = "Ботанический ранец для воды"
	contains = list(
		/obj/item/watertank,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/secure
	containername = "ящик с ботаническим ранцем для воды"
	container_ru_names = list(
		NOMINATIVE = "ящик с ботаническим ранцем для воды",
		GENITIVE = "ящика с ботаническим ранцем для воды",
		DATIVE = "ящику с ботаническим ранцем для воды",
		ACCUSATIVE = "ящик с ботаническим ранцем для воды",
		INSTRUMENTAL = "ящиком с ботаническим ранцем для воды",
		PREPOSITIONAL = "ящике с ботаническим ранцем для воды",
	)
	access = ACCESS_HYDROPONICS
	announce_beacons = list("Hydroponics" = list("Hydroponics"))

/datum/supply_packs/organic/vending/hydro_refills
	name = "Наборы пополнения ботанических торгоматов"
	cost = 20
	containertype = /obj/structure/closet/crate
	contains = list(
		/obj/item/vending_refill/hydroseeds,
		/obj/item/vending_refill/hydronutrients,
	)
	containername = "ящик с наборами пополнения ботанических торгоматов"
	container_ru_names = list(
		NOMINATIVE = "ящик с наборами пополнения ботанических торгоматов",
		GENITIVE = "ящика с наборами пополнения ботанических торгоматов",
		DATIVE = "ящику с наборами пополнения ботанических торгоматов",
		ACCUSATIVE = "ящик с наборами пополнения ботанических торгоматов",
		INSTRUMENTAL = "ящиком с наборами пополнения ботанических торгоматов",
		PREPOSITIONAL = "ящике с наборами пополнения ботанических торгоматов",
	)

/datum/supply_packs/organic/hydroponics/exoticseeds
	name = "Экзотические семена"
	contains = list(
		/obj/item/seeds/nettle,
		/obj/item/seeds/replicapod,
		/obj/item/seeds/replicapod,
		/obj/item/seeds/replicapod,
		/obj/item/seeds/nymph,
		/obj/item/seeds/nymph,
		/obj/item/seeds/nymph,
		/obj/item/seeds/plump,
		/obj/item/seeds/liberty,
		/obj/item/seeds/amanita,
		/obj/item/seeds/reishi,
		/obj/item/seeds/banana,
		/obj/item/seeds/bamboo,
		/obj/item/seeds/eggplant/eggy,
		/obj/item/seeds/random,
		/obj/item/seeds/random,
	)
	containername = "ящик экзотических семян"
	container_ru_names = list(
		NOMINATIVE = "ящик экзотических семян",
		GENITIVE = "ящика экзотических семян",
		DATIVE = "ящику экзотических семян",
		ACCUSATIVE = "ящик экзотических семян",
		INSTRUMENTAL = "ящиком экзотических семян",
		PREPOSITIONAL = "ящике экзотических семян",
	)

/datum/supply_packs/organic/hydroponics/beekeeping_fullkit
	name = "Оборудование для плеловодства"
	contains = list(
		/obj/structure/beebox/unwrenched,
		/obj/item/honey_frame,
		/obj/item/honey_frame,
		/obj/item/honey_frame,
		/obj/item/queen_bee/bought,
		/obj/item/clothing/head/beekeeper_head,
		/obj/item/clothing/suit/beekeeper_suit,
		/obj/item/melee/flyswatter,
	)
	containername = "ящик с оборудованием для плеловодства"
	container_ru_names = list(
		NOMINATIVE = "ящик с оборудованием для плеловодства",
		GENITIVE = "ящика с оборудованием для плеловодства",
		DATIVE = "ящику с оборудованием для плеловодства",
		ACCUSATIVE = "ящик с оборудованием для плеловодства",
		INSTRUMENTAL = "ящиком с оборудованием для плеловодства",
		PREPOSITIONAL = "ящике с оборудованием для плеловодства",
	)

/datum/supply_packs/organic/hydroponics/beekeeping_suits
	name = "Костюмы пчеловода"
	contains = list(
		/obj/item/clothing/head/beekeeper_head,
		/obj/item/clothing/suit/beekeeper_suit,
		/obj/item/clothing/head/beekeeper_head,
		/obj/item/clothing/suit/beekeeper_suit,
	)
	cost = 10
	containername = "ящик с костюмами плеловода"
	container_ru_names = list(
		NOMINATIVE = "ящик с костюмами плеловода",
		GENITIVE = "ящика с костюмами плеловода",
		DATIVE = "ящику с костюмами плеловода",
		ACCUSATIVE = "ящик с костюмами плеловода",
		INSTRUMENTAL = "ящиком с костюмами плеловода",
		PREPOSITIONAL = "ящике с костюмами плеловода",
	)

//Bottler
/datum/supply_packs/organic/bottler
	name = "Аппарат для разлива"
	contains = list(
		/obj/machinery/bottler,
		/obj/item/wrench,
	)
	cost = 20
	containername = "ящик с аппаратом для разлива"
	container_ru_names = list(
		NOMINATIVE = "ящик с аппаратом для разлива",
		GENITIVE = "ящика с аппаратом для разлива",
		DATIVE = "ящику с аппаратом для разлива",
		ACCUSATIVE = "ящик с аппаратом для разлива",
		INSTRUMENTAL = "ящиком с аппаратом для разлива",
		PREPOSITIONAL = "ящике с аппаратом для разлива",
	)

/datum/supply_packs/organic/botdisk
	name = "Пустые ботанические дискеты"
	containername = "ящик пустых ботанических дискет"
	container_ru_names = list(
		NOMINATIVE = "ящик пустых ботанических дискет",
		GENITIVE = "ящика пустых ботанических дискет",
		DATIVE = "ящику пустых ботанических дискет",
		ACCUSATIVE = "ящик пустых ботанических дискет",
		INSTRUMENTAL = "ящиком пустых ботанических дискет",
		PREPOSITIONAL = "ящике пустых ботанических дискет",
	)
	cost = 20
	contains = list(
		/obj/item/storage/box/disks_plantgene,
		/obj/item/storage/box/disks_plantgene,
		/obj/item/storage/box/disks_plantgene,
	)

//////////////////////////////////////////////////////////////////////////////
// MARK: Materials
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/materials
	name = "HEADER"
	group = SUPPLY_MATERIALS
	announce_beacons = list("Engineering" = list("Engineering", "Chief Engineer's Desk", "Atmospherics"))

/datum/supply_packs/materials/metal50
	name = "50 листов металла"
	contains = list(
		/obj/item/stack/sheet/metal,
	)
	amount = 50
	cost = 20
	containername = "ящик с листами металла"
	container_ru_names = list(
		NOMINATIVE = "ящик с листами металла",
		GENITIVE = "ящика с листами металла",
		DATIVE = "ящику с листами металла",
		ACCUSATIVE = "ящик с листами металла",
		INSTRUMENTAL = "ящиком с листами металла",
		PREPOSITIONAL = "ящике с листами металла",
	)

/datum/supply_packs/materials/plasteel20
	name = "20 листов пластали"
	contains = list(
		/obj/item/stack/sheet/plasteel/lowplasma,
	)
	amount = 20
	cost = 90
	containername = "ящик с листами пластали"
	container_ru_names = list(
		NOMINATIVE = "ящик с листами пластали",
		GENITIVE = "ящика с листами пластали",
		DATIVE = "ящику с листами пластали",
		ACCUSATIVE = "ящик с листами пластали",
		INSTRUMENTAL = "ящиком с листами пластали",
		PREPOSITIONAL = "ящике с листами пластали",
	)

/datum/supply_packs/materials/plasteel50
	name = "50 листов пластали"
	contains = list(
		/obj/item/stack/sheet/plasteel/lowplasma,
	)
	amount = 50
	cost = 210
	containername = "ящик с листами пластали"
	container_ru_names = list(
		NOMINATIVE = "ящик с листами пластали",
		GENITIVE = "ящика с листами пластали",
		DATIVE = "ящику с листами пластали",
		ACCUSATIVE = "ящик с листами пластали",
		INSTRUMENTAL = "ящиком с листами пластали",
		PREPOSITIONAL = "ящике с листами пластали",
	)

/datum/supply_packs/materials/glass50
	name = "50 листов стекла"
	contains = list(
		/obj/item/stack/sheet/glass,
	)
	amount = 50
	cost = 15
	containername = "ящик с листами стекла"
	container_ru_names = list(
		NOMINATIVE = "ящик с листами стекла",
		GENITIVE = "ящика с листами стекла",
		DATIVE = "ящику с листами стекла",
		ACCUSATIVE = "ящик с листами стекла",
		INSTRUMENTAL = "ящиком с листами стекла",
		PREPOSITIONAL = "ящике с листами стекла",
	)

/datum/supply_packs/materials/wood30
	name = "30 деревянных досок"
	contains = list(
		/obj/item/stack/sheet/wood,
	)
	amount = 30
	cost = 15
	containername = "ящик с деревянными досками"
	container_ru_names = list(
		NOMINATIVE = "ящик с деревянными досками",
		GENITIVE = "ящика с деревянными досками",
		DATIVE = "ящику с деревянными досками",
		ACCUSATIVE = "ящик с деревянными досками",
		INSTRUMENTAL = "ящиком с деревянными досками",
		PREPOSITIONAL = "ящике с деревянными досками",
	)

/datum/supply_packs/materials/cardboard50
	name = "50 листов картона"
	contains = list(
		/obj/item/stack/sheet/cardboard,
	)
	amount = 50
	cost = 15
	containername = "ящик с листами картона"
	container_ru_names = list(
		NOMINATIVE = "ящик с листами картона",
		GENITIVE = "ящика с листами картона",
		DATIVE = "ящику с листами картона",
		ACCUSATIVE = "ящик с листами картона",
		INSTRUMENTAL = "ящиком с листами картона",
		PREPOSITIONAL = "ящике с листами картона",
	)

/datum/supply_packs/materials/sandstone30
	name = "30 кирпичей из песчаника"
	contains = list(
		/obj/item/stack/sheet/mineral/sandstone,
	)
	amount = 30
	cost = 20
	containername = "ящик с кирпичами из песчаника"
	container_ru_names = list(
		NOMINATIVE = "ящик с кирпичами из песчаника",
		GENITIVE = "ящика с кирпичами из песчаника",
		DATIVE = "ящику с кирпичами из песчаника",
		ACCUSATIVE = "ящик с кирпичами из песчаника",
		INSTRUMENTAL = "ящиком с кирпичами из песчаника",
		PREPOSITIONAL = "ящике с кирпичами из песчаника",
	)

/datum/supply_packs/materials/plastic30
	name = "30 листами пластика"
	contains = list(
		/obj/item/stack/sheet/plastic,
	)
	amount = 30
	cost = 20
	containername = "ящик с листами пластика"
	container_ru_names = list(
		NOMINATIVE = "ящик с листами пластика",
		GENITIVE = "ящика с листами пластика",
		DATIVE = "ящику с листами пластика",
		ACCUSATIVE = "ящик с листами пластика",
		INSTRUMENTAL = "ящиком с листами пластика",
		PREPOSITIONAL = "ящике с листами пластика",
	)

/datum/supply_packs/materials/carpet50
	name = "Набор ковров"
	contains = list(
		/obj/item/stack/tile/carpet,
		/obj/item/stack/tile/carpet/black,
		/obj/item/stack/tile/carpet/blue,
		/obj/item/stack/tile/carpet/cyan,
		/obj/item/stack/tile/carpet/green,
		/obj/item/stack/tile/carpet/orange,
		/obj/item/stack/tile/carpet/purple,
		/obj/item/stack/tile/carpet/red,
		/obj/item/stack/tile/carpet/royalblack,
		/obj/item/stack/tile/carpet/royalblue,
		/obj/item/stack/tile/arcade_carpet,
	)
	amount = 50
	cost = 60
	containername = "ящик с коврами"
	container_ru_names = list(
		NOMINATIVE = "ящик с коврами",
		GENITIVE = "ящика с коврами",
		DATIVE = "ящику с коврами",
		ACCUSATIVE = "ящик с коврами",
		INSTRUMENTAL = "ящиком с коврами",
		PREPOSITIONAL = "ящике с коврами",
	)

//////////////////////////////////////////////////////////////////////////////
// MARK: Miscellaneous
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/misc
	name = "HEADER"

/datum/supply_packs/misc/mule
	name = "МУЛбот"
	contains = list(
		/mob/living/simple_animal/bot/mulebot,
	)
	cost = 20
	containertype = /obj/structure/closet/crate/large/mule
	containername = "ящик с МУЛботом"
	container_ru_names = list(
		NOMINATIVE = "ящик с МУЛботом",
		GENITIVE = "ящика с МУЛботом",
		DATIVE = "ящику с МУЛботом",
		ACCUSATIVE = "ящик с МУЛботом",
		INSTRUMENTAL = "ящиком с МУЛботом",
		PREPOSITIONAL = "ящике с МУЛботом",
	)

/datum/supply_packs/misc/cargo_mon
	name = "Планшеты для заказов"
	contains = list(
		/obj/item/qm_quest_tablet/cargotech,
		/obj/item/qm_quest_tablet/cargotech,
		/obj/item/qm_quest_tablet/cargotech,
	)
	cost = 30
	containername = "ящик с планшетами для заказов"
	container_ru_names = list(
		NOMINATIVE = "ящик с планшетами для заказов",
		GENITIVE = "ящика с планшетами для заказов",
		DATIVE = "ящику с планшетами для заказов",
		ACCUSATIVE = "ящик с планшетами для заказов",
		INSTRUMENTAL = "ящиком с планшетами для заказов",
		PREPOSITIONAL = "ящике с планшетами для заказов",
	)

/datum/supply_packs/misc/qm_quest_tablet
	name = "Планшет Квартирмейстера"
	contains = list(
		/obj/item/qm_quest_tablet,
	)
	cost = 100
	required_tech = list(RESEARCH_TREE_POWERSTORAGE = 5, RESEARCH_TREE_PROGRAMMING = 5)
	containertype = /obj/structure/closet/crate/vault
	containername = "ящик с планшетом Квартирмейстера"
	container_ru_names = list(
		NOMINATIVE = "ящик с планшетом Квартирмейстера",
		GENITIVE = "ящика с планшетом Квартирмейстера",
		DATIVE = "ящику с планшетом Квартирмейстера",
		ACCUSATIVE = "ящик с планшетом Квартирмейстера",
		INSTRUMENTAL = "ящиком с планшетом Квартирмейстера",
		PREPOSITIONAL = "ящике с планшетом Квартирмейстера",
	)

/datum/supply_packs/misc/watertank
	name = "Бак воды"
	contains = list(
		/obj/structure/reagent_dispensers/watertank,
	)
	cost = 8
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с баком воды"
	container_ru_names = list(
		NOMINATIVE = "ящик с баком воды",
		GENITIVE = "ящика с баком воды",
		DATIVE = "ящику с баком воды",
		ACCUSATIVE = "ящик с баком воды",
		INSTRUMENTAL = "ящиком с баком воды",
		PREPOSITIONAL = "ящике с баком воды",
	)

/datum/supply_packs/misc/holywatertank
	name = "Бак святой воды"
	contains = list(
		/obj/structure/reagent_dispensers/holywatertank,
	)
	cost = 40
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с баком святой воды"
	container_ru_names = list(
		NOMINATIVE = "ящик с баком святой воды",
		GENITIVE = "ящика с баком святой воды",
		DATIVE = "ящику с баком святой воды",
		ACCUSATIVE = "ящик с баком святой воды",
		INSTRUMENTAL = "ящиком с баком святой воды",
		PREPOSITIONAL = "ящике с баком святой воды",
	)

/datum/supply_packs/misc/hightank
	name = "Бак воды повышенной ёмкости"
	contains = list(
		/obj/structure/reagent_dispensers/watertank/high,
	)
	cost = 12
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с баком воды повышенной ёмкости"
	container_ru_names = list(
		NOMINATIVE = "ящик с баком воды повышенной ёмкости",
		GENITIVE = "ящика с баком воды повышенной ёмкости",
		DATIVE = "ящику с баком воды повышенной ёмкости",
		ACCUSATIVE = "ящик с баком воды повышенной ёмкости",
		INSTRUMENTAL = "ящиком с баком воды повышенной ёмкости",
		PREPOSITIONAL = "ящике с баком воды повышенной ёмкости",
	)

/datum/supply_packs/misc/lasertag
	name = "Снаряжение для лазертага"
	contains = list(
		/obj/item/gun/energy/laser/tag/red,
		/obj/item/gun/energy/laser/tag/red,
		/obj/item/gun/energy/laser/tag/red,
		/obj/item/gun/energy/laser/tag/blue,
		/obj/item/gun/energy/laser/tag/blue,
		/obj/item/gun/energy/laser/tag/blue,
		/obj/item/clothing/suit/redtag,
		/obj/item/clothing/suit/redtag,
		/obj/item/clothing/suit/redtag,
		/obj/item/clothing/suit/bluetag,
		/obj/item/clothing/suit/bluetag,
		/obj/item/clothing/suit/bluetag,
		/obj/item/clothing/head/helmet/redtaghelm,
		/obj/item/clothing/head/helmet/bluetaghelm,
	)
	cost = 15
	containername = "ящик со снаряжением для лазертага"
	container_ru_names = list(
		NOMINATIVE = "ящик со снаряжением для лазертага",
		GENITIVE = "ящика со снаряжением для лазертага",
		DATIVE = "ящику со снаряжением для лазертага",
		ACCUSATIVE = "ящик со снаряжением для лазертага",
		INSTRUMENTAL = "ящиком со снаряжением для лазертага",
		PREPOSITIONAL = "ящике со снаряжением для лазертага",
	)

/datum/supply_packs/misc/plasmavendor
	name = "Набор PlasmaMate"
	contains = list(
		/obj/item/vending_refill/plasma,
		/obj/item/circuitboard/vendor/plasmamate,
	)
	cost = 100
	containername = "ящик с набором PlasmaMate"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором PlasmaMate",
		GENITIVE = "ящика с набором PlasmaMate",
		DATIVE = "ящику с набором PlasmaMate",
		ACCUSATIVE = "ящик с набором PlasmaMate",
		INSTRUMENTAL = "ящиком с набором PlasmaMate",
		PREPOSITIONAL = "ящике с набором PlasmaMate",
	)
	required_tech = list(RESEARCH_TREE_TOXINS = 5, RESEARCH_TREE_PLASMA = 6)

/datum/supply_packs/misc/religious_supplies
	name = "Религиозное снабжение"
	contains = list(
		/obj/item/reagent_containers/food/drinks/bottle/holywater,
		/obj/item/reagent_containers/food/drinks/bottle/holywater,
		/obj/item/storage/bible/booze,
		/obj/item/storage/bible/booze,
		/obj/item/clothing/suit/hooded/chaplain_hoodie,
		/obj/item/clothing/suit/hooded/chaplain_hoodie,
		/obj/item/clothing/under/burial,
		/obj/item/clothing/under/burial,
	)
	cost = 40
	containername = "ящик религиозного снабжения"
	container_ru_names = list(
		NOMINATIVE = "ящик религиозного снабжения",
		GENITIVE = "ящика религиозного снабжения",
		DATIVE = "ящику религиозного снабжения",
		ACCUSATIVE = "ящик религиозного снабжения",
		INSTRUMENTAL = "ящиком религиозного снабжения",
		PREPOSITIONAL = "ящике религиозного снабжения",
	)

/datum/supply_packs/misc/minerkit
	name = "Шахтёрское снаряжение"
	cost = 30
	access = ACCESS_QM
	contains = list(
		/obj/item/storage/backpack/duffel/mining_conscript,
	)
	containertype = /obj/structure/closet/crate/secure
	containername = "ящик с шахтёрским снаряжением"
	container_ru_names = list(
		NOMINATIVE = "ящик с шахтёрским снаряжением",
		GENITIVE = "ящика с шахтёрским снаряжением",
		DATIVE = "ящику с шахтёрским снаряжением",
		ACCUSATIVE = "ящик с шахтёрским снаряжением",
		INSTRUMENTAL = "ящиком с шахтёрским снаряжением",
		PREPOSITIONAL = "ящике с шахтёрским снаряжением",
	)

/datum/supply_packs/misc/barber_kit
	name = "Снаряжение барбера"
	contains = list(
		/obj/item/storage/box/barber,
		/obj/item/clothing/under/barber,
		/obj/item/clothing/under/barber/skirt,
		/obj/item/razor,
		/obj/item/storage/box/lip_stick,
	)
	cost = 10
	containername = "ящик со снаряжением барбера"
	container_ru_names = list(
		NOMINATIVE = "ящик со снаряжением барбера",
		GENITIVE = "ящика со снаряжением барбера",
		DATIVE = "ящику со снаряжением барбера",
		ACCUSATIVE = "ящик со снаряжением барбера",
		INSTRUMENTAL = "ящиком со снаряжением барбера",
		PREPOSITIONAL = "ящике со снаряжением барбера",
	)

/datum/supply_packs/misc/patriotic
	name = "Набор патриота НТ"
	cost = 111
	containertype = /obj/structure/closet/crate/trashcart
	contains = list(
		/obj/item/flag/nt,
		/obj/item/flag/nt,
		/obj/item/flag/nt,
		/obj/item/flag/nt,
		/obj/item/flag/nt,
		/obj/item/flag/nt,
		/obj/item/book/manual/security_space_law,
		/obj/item/book/manual/security_space_law,
		/obj/item/book/manual/security_space_law,
		/obj/item/book/manual/security_space_law,
		/obj/item/book/manual/security_space_law,
		/obj/item/book/manual/security_space_law,
		/obj/item/poster/random_official,
		/obj/item/poster/random_official,
		/obj/item/poster/random_official,
		/obj/item/poster/random_official,
		/obj/item/poster/random_official,
		/obj/item/poster/random_official,
	)
	containername = "ящик с набором патриота НТ"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором патриота НТ",
		GENITIVE = "ящика с набором патриота НТ",
		DATIVE = "ящику с набором патриота НТ",
		ACCUSATIVE = "ящик с набором патриота НТ",
		INSTRUMENTAL = "ящиком с набором патриота НТ",
		PREPOSITIONAL = "ящике с набором патриота НТ",
	)

/datum/supply_packs/misc/golden_toilet
	name = "Золотой унитаз"
	cost = 500
	contains = list(
		/obj/structure/toilet/golden_toilet,
	)
	containername = "ящик с золотым унитазом"
	container_ru_names = list(
		NOMINATIVE = "ящик с золотым унитазом",
		GENITIVE = "ящика с золотым унитазом",
		DATIVE = "ящику с золотым унитазом",
		ACCUSATIVE = "ящик с золотым унитазом",
		INSTRUMENTAL = "ящиком с золотым унитазом",
		PREPOSITIONAL = "ящике с золотым унитазом",
	)

///////////// Paper Work

/datum/supply_packs/misc/paper
	name = "Бюрократическое снабжение"
	contains = list(
		/obj/structure/filingcabinet/chestdrawer,
		/obj/item/camera_film,
		/obj/item/hand_labeler,
		/obj/item/hand_labeler_refill,
		/obj/item/hand_labeler_refill,
		/obj/item/stack/tape_roll,
		/obj/item/paper_bin,
		/obj/item/pen,
		/obj/item/pen/blue,
		/obj/item/pen/red,
		/obj/item/stamp/denied,
		/obj/item/stamp/granted,
		/obj/item/folder/blue,
		/obj/item/folder/red,
		/obj/item/folder/yellow,
		/obj/item/clipboard,
		/obj/item/clipboard,
	)
	cost = 15
	containername = "ящик бюрократического снабжения"
	container_ru_names = list(
		NOMINATIVE = "ящик бюрократического снабжения",
		GENITIVE = "ящика бюрократического снабжения",
		DATIVE = "ящику бюрократического снабжения",
		ACCUSATIVE = "ящик бюрократического снабжения",
		INSTRUMENTAL = "ящиком бюрократического снабжения",
		PREPOSITIONAL = "ящике бюрократического снабжения",
	)

/datum/supply_packs/misc/book_crate
	name = "Кодекс Гигас"
	contains = list(
		/obj/item/book/codex_gigas,
	)
	cost = 15
	containername = "ящик с Кодекс Гигас"
	container_ru_names = list(
		NOMINATIVE = "ящик с Кодекс Гигас",
		GENITIVE = "ящика с Кодекс Гигас",
		DATIVE = "ящику с Кодекс Гигас",
		ACCUSATIVE = "ящик с Кодекс Гигас",
		INSTRUMENTAL = "ящиком с Кодекс Гигас",
		PREPOSITIONAL = "ящике с Кодекс Гигас",
	)

/datum/supply_packs/misc/book_crate/New()
	contains += pick(subtypesof(/obj/item/book/manual))
	contains += pick(subtypesof(/obj/item/book/manual))
	contains += pick(subtypesof(/obj/item/book/manual))
	contains += pick(subtypesof(/obj/item/book/manual))
	..()

/datum/supply_packs/misc/tape
	name = "Скотч"
	contains = list(
		/obj/item/stack/tape_roll,
	/obj/item/stack/tape_roll,
	/obj/item/stack/tape_roll,
	)
	cost = 10
	containername = "ящик со скотчем"
	container_ru_names = list(
		NOMINATIVE = "ящик со скотчем",
		GENITIVE = "ящика со скотчем",
		DATIVE = "ящику со скотчем",
		ACCUSATIVE = "ящик со скотчем",
		INSTRUMENTAL = "ящиком со скотчем",
		PREPOSITIONAL = "ящике со скотчем",
	)
	containertype = /obj/structure/closet/crate/tape

/datum/supply_packs/misc/toner
	name = "Тонер-картриджи"
	contains = list(
		/obj/item/toner,
		/obj/item/toner,
		/obj/item/toner,
		/obj/item/toner,
		/obj/item/toner,
		/obj/item/toner,
	)
	cost = 10
	containername = "ящик тонер-картриджей"
	container_ru_names = list(
		NOMINATIVE = "ящик тонер-картриджей",
		GENITIVE = "ящика тонер-картриджей",
		DATIVE = "ящику тонер-картриджей",
		ACCUSATIVE = "ящик тонер-картриджей",
		INSTRUMENTAL = "ящиком тонер-картриджей",
		PREPOSITIONAL = "ящике тонер-картриджей",
	)

/datum/supply_packs/misc/artscrafts
	name = "Художественное снабжение"
	contains = list(
		/obj/item/storage/fancy/crayons,
		/obj/item/camera,
		/obj/item/camera_film,
		/obj/item/camera_film,
		/obj/item/storage/photo_album,
		/obj/item/stack/packageWrap,
		/obj/item/reagent_containers/glass/paint/red,
		/obj/item/reagent_containers/glass/paint/green,
		/obj/item/reagent_containers/glass/paint/blue,
		/obj/item/reagent_containers/glass/paint/yellow,
		/obj/item/reagent_containers/glass/paint/violet,
		/obj/item/reagent_containers/glass/paint/black,
		/obj/item/reagent_containers/glass/paint/white,
		/obj/item/reagent_containers/glass/paint/remover,
		/obj/item/poster/random_official,
		/obj/item/stack/wrapping_paper,
		/obj/item/stack/wrapping_paper,
		/obj/item/stack/wrapping_paper,
	)
	cost = 10
	containername = "ящик художественного снабжения"
	container_ru_names = list(
		NOMINATIVE = "ящик художественного снабжения",
		GENITIVE = "ящика художественного снабжения",
		DATIVE = "ящику художественного снабжения",
		ACCUSATIVE = "ящик художественного снабжения",
		INSTRUMENTAL = "ящиком художественного снабжения",
		PREPOSITIONAL = "ящике художественного снабжения",
	)

/datum/supply_packs/misc/posters
	name = "Корпоративные постеры"
	contains = list(
		/obj/item/poster/random_official,
		/obj/item/poster/random_official,
		/obj/item/poster/random_official,
		/obj/item/poster/random_official,
		/obj/item/poster/random_official,
	)
	cost = 8
	containername = "ящик корпоративных постеров"
	container_ru_names = list(
		NOMINATIVE = "ящик корпоративных постеров",
		GENITIVE = "ящика корпоративных постеров",
		DATIVE = "ящику корпоративных постеров",
		ACCUSATIVE = "ящик корпоративных постеров",
		INSTRUMENTAL = "ящиком корпоративных постеров",
		PREPOSITIONAL = "ящике корпоративных постеров",
	)

///////////// Janitor Supplies

/datum/supply_packs/misc/janitor
	name = "Уборочное снабжение"
	contains = list(
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/mop,
		/obj/item/caution,
		/obj/item/caution,
		/obj/item/caution,
		/obj/item/storage/bag/trash,
		/obj/item/reagent_containers/spray/cleaner,
		/obj/item/reagent_containers/glass/rag,
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/grenade/chem_grenade/cleaner,
	)
	cost = 10
	containername = "ящик уборочного снабжения"
	container_ru_names = list(
		NOMINATIVE = "ящик уборочного снабжения",
		GENITIVE = "ящика уборочного снабжения",
		DATIVE = "ящику уборочного снабжения",
		ACCUSATIVE = "ящик уборочного снабжения",
		INSTRUMENTAL = "ящиком уборочного снабжения",
		PREPOSITIONAL = "ящике уборочного снабжения",
	)
	announce_beacons = list("Janitor" = list("Janitorial"))

/datum/supply_packs/misc/janitor/janicart
	name = "Тележка и галоши уборщика"
	contains = list(
		/obj/structure/janitorialcart,
		/obj/item/clothing/shoes/galoshes,
	)
	containertype = /obj/structure/closet/crate/large
	containername = "ящик с тележкой и галошами уборщика"
	container_ru_names = list(
		NOMINATIVE = "ящик с тележкой и галошами уборщика",
		GENITIVE = "ящика с тележкой и галошами уборщика",
		DATIVE = "ящику с тележкой и галошами уборщика",
		ACCUSATIVE = "ящик с тележкой и галошами уборщика",
		INSTRUMENTAL = "ящиком с тележкой и галошами уборщика",
		PREPOSITIONAL = "ящике с тележкой и галошами уборщика",
	)

/datum/supply_packs/misc/janitor/janitank
	name = "Уборочный ранец для воды"
	contains = list(
		/obj/item/watertank/janitor,
	)
	containertype = /obj/structure/closet/crate/secure
	containername = "ящик с уборочным ранцем для воды"
	container_ru_names = list(
		NOMINATIVE = "ящик с уборочным ранцем для воды",
		GENITIVE = "ящика с уборочным ранцем для воды",
		DATIVE = "ящику с уборочным ранцем для воды",
		ACCUSATIVE = "ящик с уборочным ранцем для воды",
		INSTRUMENTAL = "ящиком с уборочным ранцем для воды",
		PREPOSITIONAL = "ящике с уборочным ранцем для воды",
	)
	access = ACCESS_JANITOR

/datum/supply_packs/misc/janitor/lightbulbs
	name = "Лампочки"
	contains = list(
		/obj/item/storage/box/lights/mixed,
		/obj/item/storage/box/lights/mixed,
		/obj/item/storage/box/lights/mixed,
	)
	containername = "ящик лампочек"
	container_ru_names = list(
		NOMINATIVE = "ящик лампочек",
		GENITIVE = "ящика лампочек",
		DATIVE = "ящику лампочек",
		ACCUSATIVE = "ящик лампочек",
		INSTRUMENTAL = "ящиком лампочек",
		PREPOSITIONAL = "ящике лампочек",
	)

/datum/supply_packs/misc/noslipfloor
	name = "Нескользящие плитки пола"
	contains = list(
		/obj/item/stack/tile/noslip/loaded,
	)
	cost = 20
	containername = "ящик нескользящих плиток пола"
	container_ru_names = list(
		NOMINATIVE = "ящик нескользящих плиток пола",
		GENITIVE = "ящика нескользящих плиток пола",
		DATIVE = "ящику нескользящих плиток пола",
		ACCUSATIVE = "ящик нескользящих плиток пола",
		INSTRUMENTAL = "ящиком нескользящих плиток пола",
		PREPOSITIONAL = "ящике нескользящих плиток пола",
	)

///////////// Costumes

/datum/supply_packs/misc/costume
	name = "Актёрские костюмы"
	contains = list(
		/obj/item/storage/backpack/clown,
		/obj/item/clothing/shoes/clown_shoes,
		/obj/item/clothing/mask/gas/clown_hat,
		/obj/item/clothing/under/rank/clown,
		/obj/item/bikehorn,
		/obj/item/storage/backpack/mime,
		/obj/item/clothing/under/mime,
		/obj/item/clothing/shoes/color/black,
		/obj/item/clothing/gloves/color/white,
		/obj/item/clothing/mask/gas/mime,
		/obj/item/clothing/head/beret,
		/obj/item/clothing/suit/suspenders,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofnothing,
		/obj/item/reagent_containers/food/drinks/bottle/bottleofbanana,
	)
	cost = 10
	containertype = /obj/structure/closet/crate/secure
	containername = "ящик актёрских костюмов"
	container_ru_names = list(
		NOMINATIVE = "ящик актёрских костюмов",
		GENITIVE = "ящика актёрских костюмов",
		DATIVE = "ящику актёрских костюмов",
		ACCUSATIVE = "ящик актёрских костюмов",
		INSTRUMENTAL = "ящиком актёрских костюмов",
		PREPOSITIONAL = "ящике актёрских костюмов",
	)
	access = ACCESS_THEATRE

/datum/supply_packs/misc/wizard
	name = "Костюм мага"
	contains = list(
		/obj/item/twohanded/staff,
		/obj/item/clothing/suit/wizrobe/fake,
		/obj/item/clothing/shoes/sandal,
		/obj/item/clothing/head/wizard/fake,
	)
	cost = 20
	containername = "ящик с костюмом мага"
	container_ru_names = list(
		NOMINATIVE = "ящик с костюмом мага",
		GENITIVE = "ящика с костюмом мага",
		DATIVE = "ящику с костюмом мага",
		ACCUSATIVE = "ящик с костюмом мага",
		INSTRUMENTAL = "ящиком с костюмом мага",
		PREPOSITIONAL = "ящике с костюмом мага",
	)

/datum/supply_packs/misc/mafia
	name = "Снаряжение мафиози"
	contains = list(
		/obj/item/clothing/suit/storage/browntrenchcoat,
		/obj/item/clothing/suit/storage/blacktrenchcoat,
		/obj/item/clothing/head/fedora/whitefedora,
		/obj/item/clothing/head/fedora/brownfedora,
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/under/flappers,
		/obj/item/clothing/under/mafia,
		/obj/item/clothing/under/mafia/vest,
		/obj/item/clothing/under/mafia/white,
		/obj/item/clothing/under/mafia/sue,
		/obj/item/clothing/under/mafia/tan,
		/obj/item/gun/projectile/shotgun/toy/tommygun,
		/obj/item/gun/projectile/shotgun/toy/tommygun,
	)
	cost = 15
	containername = "ящик со снаряжением мафиози"
	container_ru_names = list(
		NOMINATIVE = "ящик со снаряжением мафиози",
		GENITIVE = "ящика со снаряжением мафиози",
		DATIVE = "ящику со снаряжением мафиози",
		ACCUSATIVE = "ящик со снаряжением мафиози",
		INSTRUMENTAL = "ящиком со снаряжением мафиози",
		PREPOSITIONAL = "ящике со снаряжением мафиози",
	)

/datum/supply_packs/misc/sunglasses
	name = "Солнечные очки"
	contains = list(
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/glasses/sunglasses,
		/obj/item/clothing/glasses/sunglasses,
	)
	cost = 30
	containername = "ящик солнечных очков"
	container_ru_names = list(
		NOMINATIVE = "ящик солнечных очков",
		GENITIVE = "ящика солнечных очков",
		DATIVE = "ящику солнечных очков",
		ACCUSATIVE = "ящик солнечных очков",
		INSTRUMENTAL = "ящиком солнечных очков",
		PREPOSITIONAL = "ящике солнечных очков",
	)
/datum/supply_packs/misc/randomised
	var/num_contained = 3 //number of items picked to be contained in a randomised crate
	contains = list(
		/obj/item/clothing/head/collectable/chef,
		/obj/item/clothing/head/collectable/paper,
		/obj/item/clothing/head/collectable/tophat,
		/obj/item/clothing/head/collectable/captain,
		/obj/item/clothing/head/collectable/beret,
		/obj/item/clothing/head/collectable/welding,
		/obj/item/clothing/head/collectable/flatcap,
		/obj/item/clothing/head/collectable/pirate,
		/obj/item/clothing/head/collectable/kitty,
		/obj/item/clothing/head/crown/fancy,
		/obj/item/clothing/head/collectable/rabbitears,
		/obj/item/clothing/head/collectable/wizard,
		/obj/item/clothing/head/collectable/hardhat,
		/obj/item/clothing/head/collectable/HoS,
		/obj/item/clothing/head/collectable/thunderdome,
		/obj/item/clothing/head/collectable/swat,
		/obj/item/clothing/head/collectable/slime,
		/obj/item/clothing/head/collectable/police,
		/obj/item/clothing/head/collectable/slime,
		/obj/item/clothing/head/collectable/xenom,
		/obj/item/clothing/head/collectable/petehat,
	)
	name = "Коллекционные шляпы"
	cost = 200
	containername = "ящик коллекционных шляп"
	container_ru_names = list(
		NOMINATIVE = "ящик коллекционных шляп",
		GENITIVE = "ящика коллекционных шляп",
		DATIVE = "ящику коллекционных шляп",
		ACCUSATIVE = "ящик коллекционных шляп",
		INSTRUMENTAL = "ящиком коллекционных шляп",
		PREPOSITIONAL = "ящике коллекционных шляп",
	)

/datum/supply_packs/misc/randomised/New()
	manifest += "Содержит [num_contained] люб[declension_ru(num_contained, "ой предмет", "ых предмета", "ых предметов")] из списка:"
	..()

/datum/supply_packs/misc/foamforce
	name = "Игрушечные дробовики"
	contains = list(
		/obj/item/gun/projectile/shotgun/toy,
		/obj/item/gun/projectile/shotgun/toy,
		/obj/item/gun/projectile/shotgun/toy,
		/obj/item/gun/projectile/shotgun/toy,
		/obj/item/gun/projectile/shotgun/toy,
		/obj/item/gun/projectile/shotgun/toy,
		/obj/item/gun/projectile/shotgun/toy,
		/obj/item/gun/projectile/shotgun/toy,
	)
	cost = 10
	containername = "ящик игрушечных дробовиков"
	container_ru_names = list(
		NOMINATIVE = "ящик игрушечных дробовиков",
		GENITIVE = "ящика игрушечных дробовиков",
		DATIVE = "ящику игрушечных дробовиков",
		ACCUSATIVE = "ящик игрушечных дробовиков",
		INSTRUMENTAL = "ящиком игрушечных дробовиков",
		PREPOSITIONAL = "ящике игрушечных дробовиков",
	)

/datum/supply_packs/misc/bigband
	name = "Музыкальные инструменты"
	contains = list(
		/obj/item/instrument/violin,
		/obj/item/instrument/guitar,
		/obj/item/instrument/eguitar,
		/obj/item/instrument/glockenspiel,
		/obj/item/instrument/accordion,
		/obj/item/instrument/saxophone,
		/obj/item/instrument/trombone,
		/obj/item/instrument/recorder,
		/obj/item/instrument/harmonica,
		/obj/item/instrument/xylophone,
		/obj/structure/piano/unanchored,
		/obj/structure/musician/drumkit,
	)
	cost = 50
	containername = "ящик музыкальных инструментов"
	container_ru_names = list(
		NOMINATIVE = "ящик музыкальных инструментов",
		GENITIVE = "ящика музыкальных инструментов",
		DATIVE = "ящику музыкальных инструментов",
		ACCUSATIVE = "ящик музыкальных инструментов",
		INSTRUMENTAL = "ящиком музыкальных инструментов",
		PREPOSITIONAL = "ящике музыкальных инструментов",
	)

/datum/supply_packs/misc/formalwear //This is a very classy crate.
	name = "Официальная одежда"
	contains = list(
		/obj/item/clothing/under/blacktango,
		/obj/item/clothing/under/assistantformal,
		/obj/item/clothing/under/assistantformal,
		/obj/item/clothing/under/lawyer/bluesuit,
		/obj/item/clothing/suit/storage/lawyer/bluejacket,
		/obj/item/clothing/under/lawyer/purpsuit,
		/obj/item/clothing/suit/storage/lawyer/purpjacket,
		/obj/item/clothing/under/lawyer/black,
		/obj/item/clothing/suit/storage/lawyer/blackjacket,
		/obj/item/clothing/accessory/waistcoat,
		/obj/item/clothing/accessory/blue,
		/obj/item/clothing/accessory/red,
		/obj/item/clothing/accessory/black,
		/obj/item/clothing/head/bowlerhat,
		/obj/item/clothing/head/fedora,
		/obj/item/clothing/head/flatcap,
		/obj/item/clothing/head/beret,
		/obj/item/clothing/head/that,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/shoes/laceup,
		/obj/item/clothing/under/suit_jacket/charcoal,
		/obj/item/clothing/under/suit_jacket/navy,
		/obj/item/clothing/under/suit_jacket/burgundy,
		/obj/item/clothing/under/suit_jacket/checkered,
		/obj/item/clothing/under/suit_jacket/tan,
		/obj/item/lipstick/random,
	)
	cost = 30 //Lots of very expensive items. You gotta pay up to look good!
	containername = "ящик официальной одежды"
	container_ru_names = list(
		NOMINATIVE = "ящик официальной одежды",
		GENITIVE = "ящика официальной одежды",
		DATIVE = "ящику официальной одежды",
		ACCUSATIVE = "ящик официальной одежды",
		INSTRUMENTAL = "ящиком официальной одежды",
		PREPOSITIONAL = "ящике официальной одежды",
	)

/datum/supply_packs/misc/teamcolors		//For team sports like space polo
	name = "Командные майки"
	// 4 red jerseys, 4 blue jerseys, and 1 beach ball
	contains = list(
		/obj/item/clothing/under/color/red/jersey,
		/obj/item/clothing/under/color/red/jersey,
		/obj/item/clothing/under/color/red/jersey,
		/obj/item/clothing/under/color/red/jersey,
		/obj/item/clothing/under/color/blue/jersey,
		/obj/item/clothing/under/color/blue/jersey,
		/obj/item/clothing/under/color/blue/jersey,
		/obj/item/clothing/under/color/blue/jersey,
		/obj/item/beach_ball,
	)
	cost = 15
	containername = "ящик командных маек"
	container_ru_names = list(
		NOMINATIVE = "ящик командных маек",
		GENITIVE = "ящика командных маек",
		DATIVE = "ящику командных маек",
		ACCUSATIVE = "ящик командных маек",
		INSTRUMENTAL = "ящиком командных маек",
		PREPOSITIONAL = "ящике командных маек",
	)

/datum/supply_packs/misc/polo			//For space polo! Or horsehead Quiditch
	name = "Набор для поло"
	// 6 brooms, 6 horse masks for the brooms, and 1 beach ball
	contains = list(
		/obj/item/twohanded/staff/broom,
		/obj/item/twohanded/staff/broom,
		/obj/item/twohanded/staff/broom,
		/obj/item/twohanded/staff/broom,
		/obj/item/twohanded/staff/broom,
		/obj/item/twohanded/staff/broom,
		/obj/item/clothing/mask/horsehead,
		/obj/item/clothing/mask/horsehead,
		/obj/item/clothing/mask/horsehead,
		/obj/item/clothing/mask/horsehead,
		/obj/item/clothing/mask/horsehead,
		/obj/item/clothing/mask/horsehead,
		/obj/item/beach_ball,
	)
	cost = 20
	containername = "ящик с набором для поло"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором для поло",
		GENITIVE = "ящика с набором для поло",
		DATIVE = "ящику с набором для поло",
		ACCUSATIVE = "ящик с набором для поло",
		INSTRUMENTAL = "ящиком с набором для поло",
		PREPOSITIONAL = "ящике с набором для поло",
	)

/datum/supply_packs/misc/boxing			//For non log spamming cargo brawls!
	name = "Боксёрское снаряжение"
	// 4 boxing gloves
	contains = list(
		/obj/item/clothing/gloves/boxing/blue,
		/obj/item/clothing/gloves/boxing/green,
		/obj/item/clothing/gloves/boxing/yellow,
		/obj/item/clothing/gloves/boxing,
	)
	cost = 15
	containername = "ящик с боксёрским снаряжением"
	container_ru_names = list(
		NOMINATIVE = "ящик с боксёрским снаряжением",
		GENITIVE = "ящика с боксёрским снаряжением",
		DATIVE = "ящику с боксёрским снаряжением",
		ACCUSATIVE = "ящик с боксёрским снаряжением",
		INSTRUMENTAL = "ящиком с боксёрским снаряжением",
		PREPOSITIONAL = "ящике с боксёрским снаряжением",
	)

///////////// Bathroom Fixtures

/datum/supply_packs/misc/toilet
	name = "Оборудование для уборной"
	cost = 10
	contains = list(
		/obj/item/bathroom_parts,
		/obj/item/bathroom_parts/urinal,
	)
	containername = "ящик оборудования для уборной"
	container_ru_names = list(
		NOMINATIVE = "ящик оборудования для уборной",
		GENITIVE = "ящика оборудования для уборной",
		DATIVE = "ящику оборудования для уборной",
		ACCUSATIVE = "ящик оборудования для уборной",
		INSTRUMENTAL = "ящиком оборудования для уборной",
		PREPOSITIONAL = "ящике оборудования для уборной",
	)
/datum/supply_packs/misc/hygiene
	name = "Оборудование для гигиены"
	cost = 10
	contains = list(
		/obj/item/bathroom_parts/sink,
		/obj/item/mounted/shower,
	)
	containername = "ящик оборудования для гигиены"
	container_ru_names = list(
		NOMINATIVE = "ящик оборудования для гигиены",
		GENITIVE = "ящика оборудования для гигиены",
		DATIVE = "ящику оборудования для гигиены",
		ACCUSATIVE = "ящик оборудования для гигиены",
		INSTRUMENTAL = "ящиком оборудования для гигиены",
		PREPOSITIONAL = "ящике оборудования для гигиены",
	)

/datum/supply_packs/misc/snow_machine
	name = "Снегогенератор"
	cost = 20
	contains = list(
		/obj/machinery/snow_machine,
	)
	containername = "ящик со снегогенератором"
	container_ru_names = list(
		NOMINATIVE = "ящик со снегогенератором",
		GENITIVE = "ящика со снегогенератором",
		DATIVE = "ящику со снегогенератором",
		ACCUSATIVE = "ящик со снегогенератором",
		INSTRUMENTAL = "ящиком со снегогенератором",
		PREPOSITIONAL = "ящике со снегогенератором",
	)
	special = TRUE

/datum/supply_packs/misc/crematorium
	name = "Детали крематория"
	cost = 15
	contains = list(
		/obj/item/circuitboard/machine/crematorium,
		/obj/item/toy/plushie/orange_fox,
	)
	containername = "ящик деталей крематория"
	container_ru_names = list(
		NOMINATIVE = "ящик деталей крематория",
		GENITIVE = "ящика деталей крематория",
		DATIVE = "ящику деталей крематория",
		ACCUSATIVE = "ящик деталей крематория",
		INSTRUMENTAL = "ящиком деталей крематория",
		PREPOSITIONAL = "ящике деталей крематория",
	)

/datum/supply_packs/misc/loader
	name = "Грузовой МЭК"
	contains = list(
		/obj/item/mod/control/pre_equipped/loader,
	)
	cost = 75
	containername = "ящик с грузовым МЭК"
	container_ru_names = list(
		NOMINATIVE = "ящик с грузовым МЭК",
		GENITIVE = "ящика с грузовым МЭК",
		DATIVE = "ящику с грузовым МЭК",
		ACCUSATIVE = "ящик с грузовым МЭК",
		INSTRUMENTAL = "ящиком с грузовым МЭК",
		PREPOSITIONAL = "ящике с грузовым МЭК",
	)

/datum/supply_packs/misc/motorcycle
	name = "Мотоцикл"
	contains = list(
		/obj/vehicle/ridden/motorcycle,
	)
	cost = 300
	containertype = /obj/structure/closet/crate/secure/large
	required_tech = list(RESEARCH_TREE_ENGINEERING = 7, RESEARCH_TREE_MATERIALS = 7)
	containername = "ящик с мотоциклом"
	container_ru_names = list(
		NOMINATIVE = "ящик с мотоциклом",
		GENITIVE = "ящика с мотоциклом",
		DATIVE = "ящику с мотоциклом",
		ACCUSATIVE = "ящик с мотоциклом",
		INSTRUMENTAL = "ящиком с мотоциклом",
		PREPOSITIONAL = "ящике с мотоциклом",
	)

//////////////////////////////////////////////////////////////////////////////
// MARK: Vending
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/vending
	name = "HEADER"
	group = SUPPLY_VEND

/datum/supply_packs/vending/autodrobe
	name = "Набор пополнения Autodrobe"
	contains = list(
		/obj/item/vending_refill/autodrobe,
	)
	cost = 15
	containername = "ящик с набором пополнения Autodrobe"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Autodrobe",
		GENITIVE = "ящика с набором пополнения Autodrobe",
		DATIVE = "ящику с набором пополнения Autodrobe",
		ACCUSATIVE = "ящик с набором пополнения Autodrobe",
		INSTRUMENTAL = "ящиком с набором пополнения Autodrobe",
		PREPOSITIONAL = "ящике с набором пополнения Autodrobe",
	)

/datum/supply_packs/vending/clothes
	name = "Набор пополнения ClothesMate"
	contains = list(
		/obj/item/vending_refill/clothing,
	)
	cost = 15
	containername = "ящик с набором пополнения ClothesMate"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения ClothesMate",
		GENITIVE = "ящика с набором пополнения ClothesMate",
		DATIVE = "ящику с набором пополнения ClothesMate",
		ACCUSATIVE = "ящик с набором пополнения ClothesMate",
		INSTRUMENTAL = "ящиком с набором пополнения ClothesMate",
		PREPOSITIONAL = "ящике с набором пополнения ClothesMate",
	)

/datum/supply_packs/vending/clothes/security
	name = "Набор пополнения Security Departament ClothesMate"
	contains = list(
		/obj/item/vending_refill/clothing/security,
	)
	cost = 80
	containername = "ящик с набором пополнения Security Departament ClothesMate"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Security Departament ClothesMate",
		GENITIVE = "ящика с набором пополнения Security Departament ClothesMate",
		DATIVE = "ящику с набором пополнения Security Departament ClothesMate",
		ACCUSATIVE = "ящик с набором пополнения Security Departament ClothesMate",
		INSTRUMENTAL = "ящиком с набором пополнения Security Departament ClothesMate",
		PREPOSITIONAL = "ящике с набором пополнения Security Departament ClothesMate",
	)

/datum/supply_packs/vending/clothes/engineering
	name = "Набор пополнения Engineering Departament ClothesMate"
	contains = list(
		/obj/item/vending_refill/clothing/engineering,
	)
	cost = 50
	containername = "ящик с набором пополнения Engineering Departament ClothesMate"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Engineering Departament ClothesMate",
		GENITIVE = "ящика с набором пополнения Engineering Departament ClothesMate",
		DATIVE = "ящику с набором пополнения Engineering Departament ClothesMate",
		ACCUSATIVE = "ящик с набором пополнения Engineering Departament ClothesMate",
		INSTRUMENTAL = "ящиком с набором пополнения Engineering Departament ClothesMate",
		PREPOSITIONAL = "ящике с набором пополнения Engineering Departament ClothesMate",
	)

/datum/supply_packs/vending/clothes/medical
	name = "Набор пополнения Medical Departament ClothesMate"
	contains = list(
		/obj/item/vending_refill/clothing/medical,
	)
	cost = 50
	containername = "ящик с набором пополнения Medical Departament ClothesMate"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Medical Departament ClothesMate",
		GENITIVE = "ящика с набором пополнения Medical Departament ClothesMate",
		DATIVE = "ящику с набором пополнения Medical Departament ClothesMate",
		ACCUSATIVE = "ящик с набором пополнения Medical Departament ClothesMate",
		INSTRUMENTAL = "ящиком с набором пополнения Medical Departament ClothesMate",
		PREPOSITIONAL = "ящике с набором пополнения Medical Departament ClothesMate",
	)

/datum/supply_packs/vending/clothes/science
	name = "Набор пополнения Science Departament ClothesMate"
	contains = list(
		/obj/item/vending_refill/clothing/science,
	)
	cost = 30
	containername = "ящик с набором пополнения Science Departament ClothesMate"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Science Departament ClothesMate",
		GENITIVE = "ящика с набором пополнения Science Departament ClothesMate",
		DATIVE = "ящику с набором пополнения Science Departament ClothesMate",
		ACCUSATIVE = "ящик с набором пополнения Science Departament ClothesMate",
		INSTRUMENTAL = "ящиком с набором пополнения Science Departament ClothesMate",
		PREPOSITIONAL = "ящике с набором пополнения Science Departament ClothesMate",
	)

/datum/supply_packs/vending/clothes/cargo
	name = "Набор пополнения Cargo Departament ClothesMate"
	contains = list(
		/obj/item/vending_refill/clothing/cargo,
	)
	cost = 30
	containername = "ящик с набором пополнения Cargo Departament ClothesMate"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Cargo Departament ClothesMate",
		GENITIVE = "ящика с набором пополнения Cargo Departament ClothesMate",
		DATIVE = "ящику с набором пополнения Cargo Departament ClothesMate",
		ACCUSATIVE = "ящик с набором пополнения Cargo Departament ClothesMate",
		INSTRUMENTAL = "ящиком с набором пополнения Cargo Departament ClothesMate",
		PREPOSITIONAL = "ящике с набором пополнения Cargo Departament ClothesMate",
	)

/datum/supply_packs/vending/clothes/law
	name = "Набор пополнения Law Departament ClothesMate"
	contains = list(
		/obj/item/vending_refill/clothing/law,
	)
	cost = 30
	containername = "ящик с набором пополнения Law Departament ClothesMate"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Law Departament ClothesMate",
		GENITIVE = "ящика с набором пополнения Law Departament ClothesMate",
		DATIVE = "ящику с набором пополнения Law Departament ClothesMate",
		ACCUSATIVE = "ящик с набором пополнения Law Departament ClothesMate",
		INSTRUMENTAL = "ящиком с набором пополнения Law Departament ClothesMate",
		PREPOSITIONAL = "ящике с набором пополнения Law Departament ClothesMate",
	)

/datum/supply_packs/vending/clothes/service/botanical
	name = "Набор пополнения Service Departament ClothesMate"
	contains = list(
		/obj/item/vending_refill/clothing/service/botanical,
	)
	cost = 30
	containername = "ящик с набором пополнения Service Departament ClothesMate"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Service Departament ClothesMate",
		GENITIVE = "ящика с набором пополнения Service Departament ClothesMate",
		DATIVE = "ящику с набором пополнения Service Departament ClothesMate",
		ACCUSATIVE = "ящик с набором пополнения Service Departament ClothesMate",
		INSTRUMENTAL = "ящиком с набором пополнения Service Departament ClothesMate",
		PREPOSITIONAL = "ящике с набором пополнения Service Departament ClothesMate",
	)

/datum/supply_packs/vending/clothes/service/chaplain
	name = "Набор пополнения Departament Service ClothesMate Chaplain"
	contains = list(
		/obj/item/vending_refill/clothing/service/chaplain,
	)
	cost = 30
	containername = "ящик с набором пополнения Departament Service ClothesMate Chaplain"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Departament Service ClothesMate Chaplain",
		GENITIVE = "ящика с набором пополнения Departament Service ClothesMate Chaplain",
		DATIVE = "ящику с набором пополнения Departament Service ClothesMate Chaplain",
		ACCUSATIVE = "ящик с набором пополнения Departament Service ClothesMate Chaplain",
		INSTRUMENTAL = "ящиком с набором пополнения Departament Service ClothesMate Chaplain",
		PREPOSITIONAL = "ящике с набором пополнения Departament Service ClothesMate Chaplain",
	)

/datum/supply_packs/vending/suit
	name = "Набор пополнения Suitlord"
	contains = list(
		/obj/item/vending_refill/suitdispenser,
	)
	cost = 15
	containername = "ящик с набором пополнения Suitlord"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Suitlord",
		GENITIVE = "ящика с набором пополнения Suitlord",
		DATIVE = "ящику с набором пополнения Suitlord",
		ACCUSATIVE = "ящик с набором пополнения Suitlord",
		INSTRUMENTAL = "ящиком с набором пополнения Suitlord",
		PREPOSITIONAL = "ящике с набором пополнения Suitlord",
	)

/datum/supply_packs/vending/hat
	name = "Набор пополнения Hatlord"
	contains = list(
		/obj/item/vending_refill/hatdispenser,
	)
	cost = 15
	containername = "ящик с набором пополнения Hatlord"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Hatlord",
		GENITIVE = "ящика с набором пополнения Hatlord",
		DATIVE = "ящику с набором пополнения Hatlord",
		ACCUSATIVE = "ящик с набором пополнения Hatlord",
		INSTRUMENTAL = "ящиком с набором пополнения Hatlord",
		PREPOSITIONAL = "ящике с набором пополнения Hatlord",
	)

/datum/supply_packs/vending/shoes
	name = "Набор пополнения Shoelord"
	contains = list(
		/obj/item/vending_refill/shoedispenser,
	)
	cost = 15
	containername = "ящик с набором пополнения Shoelord"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Shoelord",
		GENITIVE = "ящика с набором пополнения Shoelord",
		DATIVE = "ящику с набором пополнения Shoelord",
		ACCUSATIVE = "ящик с набором пополнения Shoelord",
		INSTRUMENTAL = "ящиком с набором пополнения Shoelord",
		PREPOSITIONAL = "ящике с набором пополнения Shoelord",
	)

/datum/supply_packs/vending/pets
	name = "Набор пополнения CritterCare"
	contains = list(
		/obj/item/vending_refill/crittercare,
	)
	cost = 15
	containername = "ящик с набором пополнения CritterCare"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения CritterCare",
		GENITIVE = "ящика с набором пополнения CritterCare",
		DATIVE = "ящику с набором пополнения CritterCare",
		ACCUSATIVE = "ящик с набором пополнения CritterCare",
		INSTRUMENTAL = "ящиком с набором пополнения CritterCare",
		PREPOSITIONAL = "ящике с набором пополнения CritterCare",
	)

/datum/supply_packs/vending/bartending
	name = "Набор пополнения Booze-o-mat и Solar's Best Hot Drinks"
	cost = 20
	contains = list(
		/obj/item/vending_refill/boozeomat,
		/obj/item/vending_refill/coffee,
	)
	containername = "ящик с наборами пополнения Booze-o-mat и Solar's Best Hot Drinks"
	container_ru_names = list(
		NOMINATIVE = "ящик с наборами пополнения Booze-o-mat и Solar's Best Hot Drinks",
		GENITIVE = "ящика с наборами пополнения Booze-o-mat и Solar's Best Hot Drinks",
		DATIVE = "ящику с наборами пополнения Booze-o-mat и Solar's Best Hot Drinks",
		ACCUSATIVE = "ящик с наборами пополнения Booze-o-mat и Solar's Best Hot Drinks",
		INSTRUMENTAL = "ящиком с наборами пополнения Booze-o-mat и Solar's Best Hot Drinks",
		PREPOSITIONAL = "ящике с наборами пополнения Booze-o-mat и Solar's Best Hot Drinks",
	)
	announce_beacons = list("Bar" = list("Bar"))

/datum/supply_packs/vending/cigarette
	name = "Набор пополнения ShadyCigs Deluxe"
	contains = list(
		/obj/item/vending_refill/cigarette,
	)
	cost = 15
	containername = "ящик с набором пополнения ShadyCigs Deluxe"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения ShadyCigs Deluxe",
		GENITIVE = "ящика с набором пополнения ShadyCigs Deluxe",
		DATIVE = "ящику с набором пополнения ShadyCigs Deluxe",
		ACCUSATIVE = "ящик с набором пополнения ShadyCigs Deluxe",
		INSTRUMENTAL = "ящиком с набором пополнения ShadyCigs Deluxe",
		PREPOSITIONAL = "ящике с набором пополнения ShadyCigs Deluxe",
	)

/datum/supply_packs/vending/dinnerware
	name = "Набор пополнения Plasteel Chef's Dinnerware"
	cost = 10
	contains = list(
		/obj/item/vending_refill/dinnerware,
	)
	containername = "ящик с набором пополнения Plasteel Chef's Dinnerware"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Plasteel Chef's Dinnerware",
		GENITIVE = "ящика с набором пополнения Plasteel Chef's Dinnerware",
		DATIVE = "ящику с набором пополнения Plasteel Chef's Dinnerware",
		ACCUSATIVE = "ящик с набором пополнения Plasteel Chef's Dinnerware",
		INSTRUMENTAL = "ящиком с набором пополнения Plasteel Chef's Dinnerware",
		PREPOSITIONAL = "ящике с набором пополнения Plasteel Chef's Dinnerware",
	)

/datum/supply_packs/vending/imported
	name = "Наборы пополнения импортированных торгоматов"
	cost = 40
	contains = list(
		/obj/item/vending_refill/sustenance,
		/obj/item/vending_refill/robotics,
		/obj/item/vending_refill/sovietsoda,
		/obj/item/vending_refill/engineering,
	)
	containername = "ящик наборов пополнения импортированных торгоматов"
	container_ru_names = list(
		NOMINATIVE = "ящик наборов пополнения импортированных торгоматов",
		GENITIVE = "ящика наборов пополнения импортированных торгоматов",
		DATIVE = "ящику наборов пополнения импортированных торгоматов",
		ACCUSATIVE = "ящик наборов пополнения импортированных торгоматов",
		INSTRUMENTAL = "ящиком наборов пополнения импортированных торгоматов",
		PREPOSITIONAL = "ящике наборов пополнения импортированных торгоматов",
	)

/datum/supply_packs/vending/ptech
	name = "Набор пополнения PTech"
	cost = 15
	contains = list(
		/obj/item/vending_refill/cart,
	)
	containername = "ящик с набором пополнения PTech"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения PTech",
		GENITIVE = "ящика с набором пополнения PTech",
		DATIVE = "ящику с набором пополнения PTech",
		ACCUSATIVE = "ящик с набором пополнения PTech",
		INSTRUMENTAL = "ящиком с набором пополнения PTech",
		PREPOSITIONAL = "ящике с набором пополнения PTech",
	)

/datum/supply_packs/vending/snack
	name = "Набор пополнения Getmore Chocolate Corp"
	contains = list(
		/obj/item/vending_refill/snack,
	)
	cost = 15
	containername = "ящик с набором пополнения Getmore Chocolate Corp"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Getmore Chocolate Corp",
		GENITIVE = "ящика с набором пополнения Getmore Chocolate Corp",
		DATIVE = "ящику с набором пополнения Getmore Chocolate Corp",
		ACCUSATIVE = "ящик с набором пополнения Getmore Chocolate Corp",
		INSTRUMENTAL = "ящиком с набором пополнения Getmore Chocolate Corp",
		PREPOSITIONAL = "ящике с набором пополнения Getmore Chocolate Corp",
	)

/datum/supply_packs/vending/cola
	name = "Набор пополнения Robust Softdrinks"
	contains = list(
		/obj/item/vending_refill/cola,
	)
	cost = 15
	containername = "ящик с набором пополнения Robust Softdrinks"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Robust Softdrinks",
		GENITIVE = "ящика с набором пополнения Robust Softdrinks",
		DATIVE = "ящику с набором пополнения Robust Softdrinks",
		ACCUSATIVE = "ящик с набором пополнения Robust Softdrinks",
		INSTRUMENTAL = "ящиком с набором пополнения Robust Softdrinks",
		PREPOSITIONAL = "ящике с набором пополнения Robust Softdrinks",
	)

/datum/supply_packs/vending/vendomat
	name = "Набор пополнения Assistomate"
	cost = 10
	contains = list(
		/obj/item/vending_refill/assist,
	)
	containername = "ящик с набором пополнения Assistomate"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Assistomate",
		GENITIVE = "ящика с набором пополнения Assistomate",
		DATIVE = "ящику с набором пополнения Assistomate",
		ACCUSATIVE = "ящик с набором пополнения Assistomate",
		INSTRUMENTAL = "ящиком с набором пополнения Assistomate",
		PREPOSITIONAL = "ящике с набором пополнения Assistomate",
	)

/datum/supply_packs/vending/chinese
	name = "Набор пополнения Mr. Chang"
	contains = list(
		/obj/item/vending_refill/chinese,
	)
	cost = 15
	containername = "ящик с набором пополнения Mr. Chang"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором пополнения Mr. Chang",
		GENITIVE = "ящика с набором пополнения Mr. Chang",
		DATIVE = "ящику с набором пополнения Mr. Chang",
		ACCUSATIVE = "ящик с набором пополнения Mr. Chang",
		INSTRUMENTAL = "ящиком с набором пополнения Mr. Chang",
		PREPOSITIONAL = "ящике с набором пополнения Mr. Chang",
	)

/datum/supply_packs/vending/protein
	name = "Sport Supply Crate"
	contains = list(
		/obj/item/vending_refill/protein,
	)
	cost = 20
	containername = "protein supply crate"

/datum/supply_packs/vending/customat
	name = "Наборы пополнения Кастоматов"
	contains = list(
		/obj/item/vending_refill/custom,
		/obj/item/vending_refill/custom,
	)
	cost = 30
	containername = "ящик наборов пополнения Кастоматов"
	container_ru_names = list(
		NOMINATIVE = "ящик наборов пополнения Кастоматов",
		GENITIVE = "ящика наборов пополнения Кастоматов",
		DATIVE = "ящику наборов пополнения Кастоматов",
		ACCUSATIVE = "ящик наборов пополнения Кастоматов",
		INSTRUMENTAL = "ящиком наборов пополнения Кастоматов",
		PREPOSITIONAL = "ящике наборов пополнения Кастоматов",
	)

//////////////////////////////////////////////////////////////////////////////
// MARK: CONTRABAND SUPPLY
//////////////////////////////////////////////////////////////////////////////

/datum/supply_packs/contraband
	name = "HEADER"
	group = SUPPLY_CONTRABAND
	contraband = TRUE
	cost = 0

/datum/supply_packs/contraband/mosin
	name = "Винтовки Мосина"
	contains = list(
		/obj/item/gun/projectile/shotgun/boltaction,
		/obj/item/gun/projectile/shotgun/boltaction,
		/obj/item/ammo_box/speedloader/a762,
		/obj/item/ammo_box/speedloader/a762,
		/obj/item/ammo_box/speedloader/a762,
		/obj/item/ammo_box/speedloader/a762,
		/obj/item/ammo_box/speedloader/a762,
		/obj/item/ammo_box/speedloader/a762,
	)
	cost = 80
	containername = "ящик винтовок Мосина"
	container_ru_names = list(
		NOMINATIVE = "ящик винтовок Мосина",
		GENITIVE = "ящика винтовок Мосина",
		DATIVE = "ящику винтовок Мосина",
		ACCUSATIVE = "ящик винтовок Мосина",
		INSTRUMENTAL = "ящиком винтовок Мосина",
		PREPOSITIONAL = "ящике винтовок Мосина",
	)

/datum/supply_packs/contraband/ammobox_mosin
	name = "Патроны 7,62x54 мм"
	contains = list(
		/obj/item/ammo_box/a762x54,
		/obj/item/ammo_box/a762x54,
	)
	credits_cost = 2000
	containername = "ящик патронов 7,62x54 мм"
	container_ru_names = list(
		NOMINATIVE = "ящик патронов 7,62x54 мм",
		GENITIVE = "ящика патронов 7,62x54 мм",
		DATIVE = "ящику патронов 7,62x54 мм",
		ACCUSATIVE = "ящик патронов 7,62x54 мм",
		INSTRUMENTAL = "ящиком патронов 7,62x54 мм",
		PREPOSITIONAL = "ящике патронов 7,62x54 мм",
	)

/datum/supply_packs/contraband/ammobox556
	name = "Патроны 5,56"
	contains = list(
		/obj/item/ammo_box/a556,
		/obj/item/ammo_box/a556,
	)
	credits_cost = 4500
	containername = "ящик патронов 5,56"
	container_ru_names = list(
		NOMINATIVE = "ящик патронов 5,56",
		GENITIVE = "ящика патронов 5,56",
		DATIVE = "ящику патронов 5,56",
		ACCUSATIVE = "ящик патронов 5,56",
		INSTRUMENTAL = "ящиком патронов 5,56",
		PREPOSITIONAL = "ящике патронов 5,56",
	)

/datum/supply_packs/contraband/ammobox45
	name = "Патроны .45"
	contains = list(
		/obj/item/ammo_box/c45/ext,
		/obj/item/ammo_box/c45/ext,
	)
	credits_cost = 3000
	containername = "ящик патронов .45"
	container_ru_names = list(
		NOMINATIVE = "ящик патронов .45",
		GENITIVE = "ящика патронов .45",
		DATIVE = "ящику патронов .45",
		ACCUSATIVE = "ящик патронов .45",
		INSTRUMENTAL = "ящиком патронов .45",
		PREPOSITIONAL = "ящике патронов .45",
	)

/datum/supply_packs/contraband/ammobox45rubber
	name = "Патроны .45 (Резина)"
	contains = list(
		/obj/item/ammo_box/rubber45/ext,
		/obj/item/ammo_box/rubber45/ext,
	)
	credits_cost = 3000
	containername = "ящик патронов .45 (Резина)"
	container_ru_names = list(
		NOMINATIVE = "ящик патронов .45 (Резина)",
		GENITIVE = "ящика патронов .45 (Резина)",
		DATIVE = "ящику патронов .45 (Резина)",
		ACCUSATIVE = "ящик патронов .45 (Резина)",
		INSTRUMENTAL = "ящиком патронов .45 (Резина)",
		PREPOSITIONAL = "ящике патронов .45 (Резина)",
	)

/datum/supply_packs/contraband/ammoboxstechkinAP
	name = "Патроны 10 мм (Бронебойные)"
	contains = list(
		/obj/item/ammo_box/m10mm/ap,
		/obj/item/ammo_box/m10mm/ap,
	)
	credits_cost = 2500
	containername = "ящик патронов 10 мм (Бронебойные)"
	container_ru_names = list(
		NOMINATIVE = "ящик патронов 10 мм (Бронебойные)",
		GENITIVE = "ящика патронов 10 мм (Бронебойные)",
		DATIVE = "ящику патронов 10 мм (Бронебойные)",
		ACCUSATIVE = "ящик патронов 10 мм (Бронебойные)",
		INSTRUMENTAL = "ящиком патронов 10 мм (Бронебойные)",
		PREPOSITIONAL = "ящике патронов 10 мм (Бронебойные)",
	)

/datum/supply_packs/contraband/ammoboxstechkinHP
	name = "Патроны 10 мм (Экспансивные)"
	contains = list(
		/obj/item/ammo_box/m10mm/hp,
		/obj/item/ammo_box/m10mm/hp,
	)
	credits_cost = 2200
	containername = "ящик патронов 10 мм (Экспансивные)"
	container_ru_names = list(
		NOMINATIVE = "ящик патронов 10 мм (Экспансивные)",
		GENITIVE = "ящика патронов 10 мм (Экспансивные)",
		DATIVE = "ящику патронов 10 мм (Экспансивные)",
		ACCUSATIVE = "ящик патронов 10 мм (Экспансивные)",
		INSTRUMENTAL = "ящиком патронов 10 мм (Экспансивные)",
		PREPOSITIONAL = "ящике патронов 10 мм (Экспансивные)",
	)

/datum/supply_packs/contraband/ammoboxstechkinincendiary
	name = "Патроны 10 мм (Зажигательные)"
	contains = list(
		/obj/item/ammo_box/m10mm/fire,
		/obj/item/ammo_box/m10mm/fire,
	)
	credits_cost = 2200
	containername = "ящик патронов 10 мм (Зажигательные)"
	container_ru_names = list(
		NOMINATIVE = "ящик патронов 10 мм (Зажигательные)",
		GENITIVE = "ящика патронов 10 мм (Зажигательные)",
		DATIVE = "ящику патронов 10 мм (Зажигательные)",
		ACCUSATIVE = "ящик патронов 10 мм (Зажигательные)",
		INSTRUMENTAL = "ящиком патронов 10 мм (Зажигательные)",
		PREPOSITIONAL = "ящике патронов 10 мм (Зажигательные)",
	)

/datum/supply_packs/contraband/compact
	name = "Патроны .50L \"Стандартный\""
	contains = list(
		/obj/item/ammo_box/sniper_rounds_compact,
		/obj/item/ammo_box/sniper_rounds_compact,
	)
	credits_cost = 5000
	containername = "ящик патронов .50L \"Стандартный\""
	container_ru_names = list(
		NOMINATIVE = "ящик патронов .50L \"Стандартный\"",
		GENITIVE = "ящика патронов .50L \"Стандартный\"",
		DATIVE = "ящику патронов .50L \"Стандартный\"",
		ACCUSATIVE = "ящик патронов .50L \"Стандартный\"",
		INSTRUMENTAL = "ящиком патронов .50L \"Стандартный\"",
		PREPOSITIONAL = "ящике патронов .50L \"Стандартный\"",
	)

/datum/supply_packs/contraband/penetrator
	name = "Патроны .50 \"Бронебойный\""
	contains = list(
		/obj/item/ammo_box/sniper_rounds_penetrator,
		/obj/item/ammo_box/sniper_rounds_penetrator,
	)
	credits_cost = 9000
	containername = "ящик патронов .50 \"Бронебойный\""
	container_ru_names = list(
		NOMINATIVE = "ящик патронов .50 \"Бронебойный\"",
		GENITIVE = "ящика патронов .50 \"Бронебойный\"",
		DATIVE = "ящику патронов .50 \"Бронебойный\"",
		ACCUSATIVE = "ящик патронов .50 \"Бронебойный\"",
		INSTRUMENTAL = "ящиком патронов .50 \"Бронебойный\"",
		PREPOSITIONAL = "ящике патронов .50 \"Бронебойный\"",
	)

/datum/supply_packs/contraband/ammobox_nagant
	name = "Патргоны 7,62x38 мм"
	contains = list(
		/obj/item/ammo_box/n762x38,
		/obj/item/ammo_box/n762x38,
	)
	credits_cost = 4000
	containername = "ящик патронов 7,62x38 мм"
	container_ru_names = list(
		NOMINATIVE = "ящик патронов 7,62x38 мм",
		GENITIVE = "ящика патронов 7,62x38 мм",
		DATIVE = "ящику патронов 7,62x38 мм",
		ACCUSATIVE = "ящик патронов 7,62x38 мм",
		INSTRUMENTAL = "ящиком патронов 7,62x38 мм",
		PREPOSITIONAL = "ящике патронов 7,62x38 мм",
	)

/datum/supply_packs/contraband/ammobox545
	name = "Патроны 5,45x39 мм"
	contains = list(
		/obj/item/ammo_box/a545x39,
		/obj/item/ammo_box/a545x39,
	)
	credits_cost = 4500
	containername = "ящик патронов 5,45x39 мм"
	container_ru_names = list(
		NOMINATIVE = "ящик патронов 5,45x39 мм",
		GENITIVE = "ящика патронов 5,45x39 мм",
		DATIVE = "ящику патронов 5,45x39 мм",
		ACCUSATIVE = "ящик патронов 5,45x39 мм",
		INSTRUMENTAL = "ящиком патронов 5,45x39 мм",
		PREPOSITIONAL = "ящике патронов 5,45x39 мм",
	)

/datum/supply_packs/contraband/rpg
	name = "Фугасные ракеты"
	contains = list(
		/obj/item/ammo_casing/rocket,
		/obj/item/ammo_casing/rocket,
		/obj/item/ammo_casing/rocket,
	)
	credits_cost = 25000
	containername = "ящик фугасных ракет"
	container_ru_names = list(
		NOMINATIVE = "ящик фугасных ракет",
		GENITIVE = "ящика фугасных ракет",
		DATIVE = "ящику фугасных ракет",
		ACCUSATIVE = "ящик фугасных ракет",
		INSTRUMENTAL = "ящиком фугасных ракет",
		PREPOSITIONAL = "ящике фугасных ракет",
	)

/datum/supply_packs/contraband/grenades
	name = "Гранаты 40 мм"
	contains = list(
		/obj/item/ammo_box/a40mm,
	)
	credits_cost = 20000
	containername = "ящик 40 мм гранат"
	container_ru_names = list(
		NOMINATIVE = "ящик 40 мм гранат",
		GENITIVE = "ящика 40 мм гранат",
		DATIVE = "ящику 40 мм гранат",
		ACCUSATIVE = "ящик 40 мм гранат",
		INSTRUMENTAL = "ящиком 40 мм гранат",
		PREPOSITIONAL = "ящике 40 мм гранат",
	)

/datum/supply_packs/contraband/bombard_grenades
	name = "Самодельные 40 мм гранаты"
	contains = list(
		/obj/item/ammo_casing/a40mm/improvised/exp_shell,
		/obj/item/ammo_casing/a40mm/improvised/flame_shell,
		/obj/item/ammo_casing/a40mm/improvised/smoke_shell,
	)
	credits_cost = 7000
	containername = "ящик самодельных 40 мм гранат"
	container_ru_names = list(
		NOMINATIVE = "ящик самодельных 40 мм гранат",
		GENITIVE = "ящика самодельных 40 мм гранат",
		DATIVE = "ящику самодельных 40 мм гранат",
		ACCUSATIVE = "ящик самодельных 40 мм гранат",
		INSTRUMENTAL = "ящиком самодельных 40 мм гранат",
		PREPOSITIONAL = "ящике самодельных 40 мм гранат",
	)

/datum/supply_packs/contraband/randomised/contraband
	var/num_contained = 5
	contains = list(
		/obj/item/storage/pill_bottle/random_drug_bottle,
		/obj/item/poster/random_contraband,
		/obj/item/storage/fancy/cigarettes/dromedaryco,
		/obj/item/storage/fancy/cigarettes/cigpack_shadyjims,
	)
	name = "Контрабанда"
	cost = 30
	containername = "ящик"	// let's keep it subtle, eh?
	container_ru_names = list(
		NOMINATIVE = "ящик",
		GENITIVE = "ящика",
		DATIVE = "ящику",
		ACCUSATIVE = "ящик",
		INSTRUMENTAL = "ящиком",
		PREPOSITIONAL = "ящике",
	)

/datum/supply_packs/contraband/randomised/contraband/New()
	manifest += "Содержит [num_contained] люб[declension_ru(num_contained, "ой предмет", "ых предмета", "ых предметов")] из списка:"
	..()

/datum/supply_packs/contraband/foamforce/bonus
	name = "Игрушечные пистолеты"
	contains = list(
		/obj/item/gun/projectile/automatic/toy/pistol,
		/obj/item/gun/projectile/automatic/toy/pistol,
		/obj/item/ammo_box/magazine/toy/pistol,
		/obj/item/ammo_box/magazine/toy/pistol,
	)
	cost = 40
	containername = "ящик игрушечных пистолетов"
	container_ru_names = list(
		NOMINATIVE = "ящик игрушечных пистолетов",
		GENITIVE = "ящика игрушечных пистолетов",
		DATIVE = "ящику игрушечных пистолетов",
		ACCUSATIVE = "ящик игрушечных пистолетов",
		INSTRUMENTAL = "ящиком игрушечных пистолетов",
		PREPOSITIONAL = "ящике игрушечных пистолетов",
	)

/datum/supply_packs/contraband/syndie_cutouts
	name = "Адаптивные картонные фигуры"
	contains = list(
		/obj/item/storage/box/syndie_kit/cutouts,
		/obj/item/storage/box/syndie_kit/cutouts,
		/obj/item/storage/box/syndie_kit/cutouts,
	)
	credits_cost = 1000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 2)
	containername = "ящик адаптивных картонных фигур"
	container_ru_names = list(
		NOMINATIVE = "ящик адаптивных картонных фигур",
		GENITIVE = "ящика адаптивных картонных фигур",
		DATIVE = "ящику адаптивных картонных фигур",
		ACCUSATIVE = "ящик адаптивных картонных фигур",
		INSTRUMENTAL = "ящиком адаптивных картонных фигур",
		PREPOSITIONAL = "ящике адаптивных картонных фигур",
	)

/datum/supply_packs/contraband/tape_roll_thick
	name = "Плотная изолента"
	contains = list(
		/obj/item/stack/tape_roll/thick,
		/obj/item/stack/tape_roll/thick,
		/obj/item/stack/tape_roll/thick,
	)
	credits_cost = 2000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 2)
	containername = "ящик плотных изолент"
	container_ru_names = list(
		NOMINATIVE = "ящик плотных изолент",
		GENITIVE = "ящика плотных изолент",
		DATIVE = "ящику плотных изолент",
		ACCUSATIVE = "ящик плотных изолент",
		INSTRUMENTAL = "ящиком плотных изолент",
		PREPOSITIONAL = "ящике плотных изолент",
	)

/datum/supply_packs/contraband/knives_kit
	name = "Метательные ножи"
	contains = list(
		/obj/item/storage/box/syndie_kit/knives_kit,
		/obj/item/storage/box/syndie_kit/knives_kit,
		/obj/item/storage/box/syndie_kit/knives_kit,
	)
	credits_cost = 3000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 2, RESEARCH_TREE_COMBAT = 5)
	containername = "ящик метательных ножей"
	container_ru_names = list(
		NOMINATIVE = "ящик метательных ножей",
		GENITIVE = "ящика метательных ножей",
		DATIVE = "ящику метательных ножей",
		ACCUSATIVE = "ящик метательных ножей",
		INSTRUMENTAL = "ящиком метательных ножей",
		PREPOSITIONAL = "ящике метательных ножей",
	)

/datum/supply_packs/contraband/ecig
	name = "Подозрительные электронные сигареты"
	contains = list(
		/obj/item/ecig/syndi,
		/obj/item/ecig/syndi,
		/obj/item/ecig/syndi,
	)
	credits_cost = 3000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 3, RESEARCH_TREE_BIOTECH = 7)
	containername = "ящик подозрительные электронных сигарет"
	container_ru_names = list(
		NOMINATIVE = "ящик подозрительных электронных сигарет",
		GENITIVE = "ящика подозрительных электронных сигарет",
		DATIVE = "ящику подозрительных электронных сигарет",
		ACCUSATIVE = "ящик подозрительных электронных сигарет",
		INSTRUMENTAL = "ящиком подозрительных электронных сигарет",
		PREPOSITIONAL = "ящике подозрительных электронных сигарет",
	)

/datum/supply_packs/contraband/powerfist
	name = "Реверсивные карты"
	contains = list(
		/obj/item/syndicate_reverse_card,
		/obj/item/syndicate_reverse_card,
	)
	credits_cost = 5000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 3, RESEARCH_TREE_COMBAT = 5, RESEARCH_TREE_POWERSTORAGE = 7, RESEARCH_TREE_ENGINEERING = 5)
	containername = "ящик реверсивных карт"
	container_ru_names = list(
		NOMINATIVE = "ящик реверсивных карт",
		GENITIVE = "ящика реверсивных карт",
		DATIVE = "ящику реверсивных карт",
		ACCUSATIVE = "ящик реверсивных карт",
		INSTRUMENTAL = "ящиком реверсивных карт",
		PREPOSITIONAL = "ящике реверсивных карт",
	)

/datum/supply_packs/contraband/emp
	name = "Набор ЭМИ-гранат"
	contains = list(
		/obj/item/storage/box/syndie_kit/emp,
	)
	credits_cost = 5000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 3, RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_MAGNETS = 5)
	containername = "ящик с набором ЭМИ-гранат"
	container_ru_names = list(
		NOMINATIVE = "ящик с набором ЭМИ-гранат",
		GENITIVE = "ящика с набором ЭМИ-гранат",
		DATIVE = "ящику с набором ЭМИ-гранат",
		ACCUSATIVE = "ящик с набором ЭМИ-гранат",
		INSTRUMENTAL = "ящиком с набором ЭМИ-гранат",
		PREPOSITIONAL = "ящике с набором ЭМИ-гранат",
	)

/datum/supply_packs/contraband/frag
	name = "Пояс боевых осколочных гранат"
	contains = list(
		/obj/item/storage/belt/grenade/frag,
	)
	credits_cost = 7000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 4, RESEARCH_TREE_COMBAT = 6, RESEARCH_TREE_POWERSTORAGE = 7)
	containername = "ящик с поясом боевых осколочных гранат"
	container_ru_names = list(
		NOMINATIVE = "ящик с поясом боевых осколочных гранат",
		GENITIVE = "ящика с поясом боевых осколочных гранат",
		DATIVE = "ящику с поясом боевых осколочных гранат",
		ACCUSATIVE = "ящик с поясом боевых осколочных гранат",
		INSTRUMENTAL = "ящиком с поясом боевых осколочных гранат",
		PREPOSITIONAL = "ящике с поясом боевых осколочных гранат",
	)

/datum/supply_packs/contraband/atmosn2ogrenades
	name = "Усыпляющая кластерная граната"
	contains = list(
		/obj/item/storage/box/syndie_kit/atmosn2ogrenades,
	)
	credits_cost = 7000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 4, RESEARCH_TREE_TOXINS = 7)
	containername = "ящик с усыпляющей кластерной гранатой"
	container_ru_names = list(
		NOMINATIVE = "ящик с усыпляющей кластерной гранатой",
		GENITIVE = "ящика с усыпляющей кластерной гранатой",
		DATIVE = "ящику с усыпляющей кластерной гранатой",
		ACCUSATIVE = "ящик с усыпляющей кластерной гранатой",
		INSTRUMENTAL = "ящиком с усыпляющей кластерной гранатой",
		PREPOSITIONAL = "ящике с усыпляющей кластерной гранатой",
	)

/datum/supply_packs/contraband/thermal
	name = "Тепловизионные очки \"Хамелеон\""
	contains = list(
		/obj/item/clothing/glasses/chameleon/thermal,
	)
	credits_cost = 9000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 5, RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_PROGRAMMING = 7)
	containername = "ящик с тепловизионными очками \"Хамелеон\""
	container_ru_names = list(
		NOMINATIVE = "ящик с тепловизионными очками \"Хамелеон\"",
		GENITIVE = "ящика с тепловизионными очками \"Хамелеон\"",
		DATIVE = "ящику с тепловизионными очками \"Хамелеон\"",
		ACCUSATIVE = "ящик с тепловизионными очками \"Хамелеон\"",
		INSTRUMENTAL = "ящиком с тепловизионными очками \"Хамелеон\"",
		PREPOSITIONAL = "ящике с тепловизионными очками \"Хамелеон\"",
	)

/datum/supply_packs/contraband/autoimplanter
	name = "Автоимплантер"
	contains = list(
		/obj/item/autoimplanter/traitor,
	)
	credits_cost = 10000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 5, RESEARCH_TREE_BIOTECH = 7, RESEARCH_TREE_PROGRAMMING = 7, RESEARCH_TREE_POWERSTORAGE = 7)
	containername = "ящик с автоимплантером"
	container_ru_names = list(
		NOMINATIVE = "ящик с автоимплантером",
		GENITIVE = "ящика с автоимплантером",
		DATIVE = "ящику с автоимплантером",
		ACCUSATIVE = "ящик с автоимплантером",
		INSTRUMENTAL = "ящиком с автоимплантером",
		PREPOSITIONAL = "ящике с автоимплантером",
	)

/datum/supply_packs/contraband/mastiff
	name = "Дробовик \"Мастиф\""
	contains = list(
		/obj/item/gun/projectile/automatic/shotgun/bulldog/mastiff,
		/obj/item/ammo_box/magazine/cheap_m12g,
		/obj/item/ammo_box/magazine/cheap_m12g,
	)
	credits_cost = 20000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 6, RESEARCH_TREE_COMBAT = 7)
	containername = "ящик с дробовиком \"Мастиф\""
	container_ru_names = list(
		NOMINATIVE = "ящик с дробовиком \"Мастиф\"",
		GENITIVE = "ящика с дробовиком \"Мастиф\"",
		DATIVE = "ящику с дробовиком \"Мастиф\"",
		ACCUSATIVE = "ящик с дробовиком \"Мастиф\"",
		INSTRUMENTAL = "ящиком с дробовиком \"Мастиф\"",
		PREPOSITIONAL = "ящике с дробовиком \"Мастиф\"",
	)

/datum/supply_packs/contraband/mini_uzi
	name = "Пистолет пулемет \"Узи\""
	contains = list(
		/obj/item/gun/projectile/automatic/mini_uzi,
		/obj/item/ammo_box/magazine/uzim9mm,
		/obj/item/ammo_box/magazine/uzim9mm,
	)
	credits_cost = 30000
	containertype = /obj/structure/closet/crate/syndicate
	required_tech = list(RESEARCH_TREE_ILLEGAL = 7, RESEARCH_TREE_COMBAT = 7, RESEARCH_TREE_ENGINEERING = 7)
	containername = "ящик с пистолетом пулеметом \"Узи\""
	container_ru_names = list(
		NOMINATIVE = "ящик с пистолетом пулеметом \"Узи\"",
		GENITIVE = "ящика с пистолетом пулеметом \"Узи\"",
		DATIVE = "ящику с пистолетом пулеметом \"Узи\"",
		ACCUSATIVE = "ящик с пистолетом пулеметом \"Узи\"",
		INSTRUMENTAL = "ящиком с пистолетом пулеметом \"Узи\"",
		PREPOSITIONAL = "ящике с пистолетом пулеметом \"Узи\"",
	)

#undef SUPPLY_EMERGENCY
#undef SUPPLY_SECURITY
#undef SUPPLY_ENGINEER
#undef SUPPLY_MEDICAL
#undef SUPPLY_SCIENCE
#undef SUPPLY_ORGANIC
#undef SUPPLY_MATERIALS
#undef SUPPLY_MISC
#undef SUPPLY_VEND
