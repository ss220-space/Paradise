/*
General Explination:
The research datum is the "folder" where all the research information is stored in a R&D console. It's also a holder for all the
various procs used to manipulate it. It has four variables and seven procs:

Variables:
- possible_tech is a list of all the /datum/tech that can potentially be researched by the player. The RefreshResearch() proc
(explained later) only goes through those when refreshing what you know. Generally, possible_tech contains ALL of the existing tech
but it is possible to add tech to the game that DON'T start in it (example: Xeno tech). Generally speaking, you don't want to mess
with these since they should be the default version of the datums. They're actually stored in a list rather then using typesof to
refer to them since it makes it a bit easier to search through them for specific information.
- know_tech is the companion list to possible_tech. It's the tech you can actually research and improve. Until it's added to this
list, it can't be improved. All the tech in this list are visible to the player.
- possible_designs is functionally identical to possbile_tech except it's for /datum/design.
- known_designs is functionally identical to known_tech except it's for /datum/design

Procs:
- TechHasReqs: Used by other procs (specifically RefreshResearch) to see whether all of a tech's requirements are currently in
known_tech and at a high enough level.
- DesignHasReqs: Same as TechHasReqs but for /datum/design and known_design.
- AddTech2Known: Adds a /datum/tech to known_tech. It checks to see whether it already has that tech (if so, it just replaces it). If
it doesn't have it, it adds it. Note: It does NOT check possible_tech at all. So if you want to add something strange to it (like
a player made tech?) you can.
- AddDesign2Known: Same as AddTech2Known except for /datum/design and known_designs.
- RefreshResearch: This is the workhorse of the R&D system. It updates the /datum/research holder and adds any unlocked tech paths
and designs you have reached the requirements for. It only checks through possible_tech and possible_designs, however, so it won't
accidentally add "secret" tech to it.
- UpdateTech is used as part of the actual researching process. It takes an ID and finds techs with that same ID in known_tech. When
it finds it, it checks to see whether it can improve it at all. If the known_tech's level is less then or equal to
the inputted level, it increases the known tech's level to the inputted level -1 or know tech's level +1 (whichever is higher).

The tech datums are the actual "tech trees" that you improve through researching. Each one has five variables:
- Name:		Pretty obvious. This is often viewable to the players.
- Desc:		Pretty obvious. Also player viewable.
- ID:		This is the unique ID of the tech that is used by the various procs to find and/or maniuplate it.
- Level:	This is the current level of the tech. All techs start at 1 and have a max of 20. Devices and some techs require a certain
level in specific techs before you can produce them.
- Req_tech:	This is a list of the techs required to unlock this tech path. If left blank, it'll automatically be loaded into the
research holder datum.

*/
/***************************************************************
**						Master Types						  **
**	Includes all the helper procs and basic tech processing.  **
***************************************************************/

/datum/research								//Holder for all the existing, archived, and known tech. Individual to console.

									//Datum/tech go here.
	// Possible is a list of direct datum references
	// known is a list of id -> datum mappings

	/// List of all tech in the game that players have access to (barring special events).
	var/list/possible_tech = list()
	/// List of locally known tech.
	var/list/known_tech = list()
	/// List of all designs
	var/list/possible_designs = list()
	/// List of available designs
	var/list/known_designs = list()

/datum/research/New()		//Insert techs into possible_tech here. Known_tech automatically updated.
	// MON DIEU!!!
	// These are semi-global, but not TOTALLY global?
	// Using research disks, you can get techs/designs from one research datum
	// onto another. What consequences this could have, I am presently unsure, but
	// I imagine nothing good.
	for(var/T in subtypesof(/datum/tech))
		possible_tech += new T(src)
	for(var/D in subtypesof(/datum/design))
		possible_designs += new D(src)
	RefreshResearch()

/// Checks to see if tech has all the required pre-reqs.
/// Input: datum/tech; Output: 0/1 (false/true)
/datum/research/proc/TechHasReqs(datum/tech/T)
	if(length(T.req_tech) == 0)
		return TRUE
	for(var/req in T.req_tech)
		var/datum/tech/known = known_tech[req]
		if(!known || known.level < T.req_tech[req])
			return FALSE
	return TRUE

/// Checks to see if design has all the required pre-reqs.
/// Input: datum/design; Output: 0/1 (false/true)
/datum/research/proc/DesignHasReqs(datum/design/D)
	if(!islist(D.req_tech))
		return FALSE
	if(!length(D.req_tech))
		return TRUE
	for(var/req in D.req_tech)
		var/datum/tech/known = known_tech[req]
		if(!known || known.level < D.req_tech[req])
			return FALSE
	return TRUE

/// Adds a tech to known_tech list. Checks to make sure there aren't duplicates and updates existing tech's levels if needed.
/// Input: datum/tech; Output: Null
/datum/research/proc/AddTech2Known(datum/tech/T)
	if(T.id in known_tech)
		var/datum/tech/known = known_tech[T.id]
		if(T.level > known.level)
			known.level = T.level
		return
	var/datum/tech/copy = T.copyTech()
	known_tech[T.id] = copy

/datum/research/proc/CanAddDesign2Known(datum/design/D)
	if(D.id in known_designs)
		return FALSE
	return TRUE

/datum/research/proc/AddDesign2Known(datum/design/D)
	if(!CanAddDesign2Known(D))
		return
	// Global datums make me nervous
	known_designs[D.id] = D

/// Refreshes known_tech and known_designs list.
/// Input/Output: n/a
/datum/research/proc/RefreshResearch()
	for(var/datum/tech/PT in possible_tech)
		if(TechHasReqs(PT))
			AddTech2Known(PT)
	for(var/datum/design/PD in possible_designs)
		if(DesignHasReqs(PD))
			AddDesign2Known(PD)
	for(var/v in known_tech)
		var/datum/tech/T = known_tech[v]
		T.level = clamp(T.level, 0, 20)

/// Refreshes the levels of a given tech.
/// Input: Tech's ID and Level; Output: new level or Null
/datum/research/proc/UpdateTech(ID, level)
	var/datum/tech/KT = known_tech[ID]
	if(KT)
		if(KT.level <= level)
			// Will bump the tech to (value_of_target) automatically -
			// after that it'll bump it up by 1 until it's greater
			// than the source tech
			KT.level = max((KT.level + 1), level)
			SSblackbox.log_research(KT.name, KT.level)
			return KT.level
	return null

/// Checks if the origin level can raise current tech levels
/// Input: Tech's ID and Level; Output: TRUE for yes, FALSE for no
/datum/research/proc/IsTechHigher(ID, level)
	var/datum/tech/KT = known_tech[ID]
	if(KT)
		if(KT.level <= level)
			return TRUE
		else
			return FALSE

/datum/research/proc/FindDesignByID(id)
	return known_designs[id]

///  A common task is for one research datum to copy over its techs and designs
///  and update them on another research datum.
///  Arguments:
///  `other` - The research datum to send designs and techs to
/datum/research/proc/push_data(datum/research/other)
	for(var/v in known_tech)
		var/datum/tech/T = known_tech[v]
		var/datum/tech/copied_tech = T.copyTech()
		other.AddTech2Known(copied_tech)
	for(var/v in known_designs)
		var/datum/design/D = known_designs[v]
		other.AddDesign2Known(D)
	other.RefreshResearch()

//Autolathe files
/datum/research/autolathe

/datum/research/autolathe/DesignHasReqs(datum/design/D)
	return D && (D.build_type & AUTOLATHE) && ("initial" in D.category)

/datum/research/autolathe/CanAddDesign2Known(datum/design/design)
	// Specifically excludes circuit imprinter and mechfab
	if(design.locked || !(design.build_type & (AUTOLATHE|PROTOLATHE|CRAFTLATHE)))
		return FALSE

	for(var/mat in design.materials)
		if(mat != MAT_METAL && mat != MAT_GLASS)
			return FALSE

	return ..()

//Biogenerator files
/datum/research/biogenerator/New()
	for(var/T in (subtypesof(/datum/tech)))
		possible_tech += new T(src)
	for(var/path in subtypesof(/datum/design))
		var/datum/design/D = new path(src)
		possible_designs += D
		if((D.build_type & BIOGENERATOR) && ("initial" in D.category))
			AddDesign2Known(D)

/datum/research/biogenerator/CanAddDesign2Known(datum/design/D)
	if(!(D.build_type & BIOGENERATOR))
		return FALSE
	return ..()

//Smelter files
/datum/research/smelter/New()
	for(var/T in (subtypesof(/datum/tech)))
		possible_tech += new T(src)
	for(var/path in subtypesof(/datum/design))
		var/datum/design/D = new path(src)
		possible_designs += D
		if((D.build_type & SMELTER) && ("initial" in D.category))
			AddDesign2Known(D)

/datum/research/smelter/CanAddDesign2Known(datum/design/D)
	if(!(D.build_type & SMELTER))
		return FALSE
	return ..()

/***************************************************************
**						Technology Datums					  **
**	Includes all the various technoliges and what they make.  **
***************************************************************/

/// Datum of individual technologies.
/datum/tech
	/// Name of the technology.
	var/name = "name"
	/// General description of what it does and what it makes.
	var/desc = "description"
	/// An easily referenced ID. Must be alphanumeric, lower-case, and no symbols.
	var/id = "id"
	/// A simple number scale of the research level. Level 0 = Secret tech.
	var/level = 1
	///  Maximum level this can be at (for job objectives)
	var/max_level = 1
	/// How much CentCom wants to get that tech. Used in supply shuttle tech cost calculation.
	var/rare = 1
	/// List of ids associated values of techs required to research this tech. "id" = #
	var/list/req_tech = list()

// Trunk Technologies (don't require any other techs and you start knowning them).

/datum/tech/materials
	name = RESEARCH_TREE_MATERIALS
	desc = "Исследование и разработка новых материалов с улучшенными характеристиками."
	id = "materials"
	max_level = 8

/datum/tech/engineering
	name = RESEARCH_TREE_ENGINEERING
	desc = "Совершенствование конструкций, узлов и методов сборки промышленного оборудования."
	id = "engineering"
	max_level = 8

/datum/tech/plasmatech
	name = RESEARCH_TREE_PLASMA
	desc = "Изучение свойств и применение вещества под названием \"Плазма\" в различных сферах."
	id = "plasmatech"
	max_level = 8
	rare = 3

/datum/tech/powerstorage
	name = RESEARCH_TREE_POWERSTORAGE
	desc = "Разработка технологий генерации, накопления и распределения электрической энергии."
	id = "powerstorage"
	max_level = 8

/datum/tech/bluespace
	name = RESEARCH_TREE_BLUESPACE
	desc = "Изучение подпространственного слоя реальности, известного как \"Блюспейс\", и его применение в различных сферах."
	id = "bluespace"
	max_level = 8
	rare = 2

/datum/tech/biotech
	name = RESEARCH_TREE_BIOTECH
	desc = "Исследование живых организмов, генной инженерии и органических соединений."
	id = "biotech"
	max_level = 8

/datum/tech/combat
	name = RESEARCH_TREE_COMBAT
	desc = "Разработка наступательных и оборонительных технологий."
	id = "combat"
	max_level = 8

/datum/tech/magnets
	name = RESEARCH_TREE_MAGNETS
	desc = "Исследование электромагнитного спектра и его применение на практике."
	id = "magnets"
	max_level = 8

/datum/tech/programming
	name = RESEARCH_TREE_PROGRAMMING
	desc = "Развитие архитектур искусственного интеллекта, систем хранения информации и вычислительных протоколов."
	id = "programming"
	max_level = 8

/datum/tech/toxins //not meant to be raised by deconstruction, do not give objects toxins as an origin_tech
	name = RESEARCH_TREE_TOXINS
	desc = "Исследование плазменных взрывчатых веществ и реактивных химических соединений."
	id = "toxins"
	max_level = 8
	rare = 2

/datum/tech/syndicate
	name = RESEARCH_TREE_ILLEGAL
	desc = "Изучение систем и устройств, нарушающих регламенты безопасности \"Нанотрейзен\"."
	id = "syndicate"
	level = 0 // Illegal tech level dont need to show in roundstart on console
	max_level = 8 // Used for admin button so need max level like other tech
	rare = 4

/datum/tech/abductor
	name = RESEARCH_TREE_ALIEN
	desc = "Анализ и адаптация технологий, используемых высокоразвитой цивилизацией, известной как \"Абдукторы\"."
	id = "abductor"
	level = 0 // Alien tech level hide roundstart like illegal
	max_level = 8
	rare = 5

/datum/tech/proc/copyTech()
	var/datum/tech/copied = new src.type
	copied.level = src.level
	return copied

/datum/tech/proc/getCost(current_level = null)
	// Calculates tech disk's supply points sell cost
	if(!current_level)
		current_level = initial(level)

	if(current_level >= level)
		return 0

	var/cost = 0
	for(var/i=current_level+1, i<=level, i++)
		if(i == initial(level))
			continue
		cost += i*5*rare

	return cost

/obj/item/disk/tech_disk
	name = "technology disk"
	desc = "Переносной носитель данных, специализированный для хранения научной информации."
	icon_state = "datadisk2"
	materials = list(MAT_METAL=30, MAT_GLASS=10)
	var/datum/tech/stored
	var/default_name = "technology disk"
	var/default_desc = "Переносной носитель данных, специализированный для хранения научной информации."
	var/default_ru_names = list(
		NOMINATIVE = "дискета технологий",
		GENITIVE = "дискеты технологий",
		DATIVE = "дискете технологий",
		ACCUSATIVE = "дискету технологий",
		INSTRUMENTAL = "дискетой технологий",
		PREPOSITIONAL = "дискете технологий"
	)

/obj/item/disk/tech_disk/get_ru_names()
	return list(
		NOMINATIVE = "дискета технологий",
		GENITIVE = "дискеты технологий",
		DATIVE = "дискете технологий",
		ACCUSATIVE = "дискету технологий",
		INSTRUMENTAL = "дискетой технологий",
		PREPOSITIONAL = "дискете технологий"
	)

/obj/item/disk/tech_disk/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-5, 5)
	pixel_y = base_pixel_y + rand(-5, 5)

/obj/item/disk/tech_disk/proc/load_tech(datum/tech/tech_tree)
	name = "[default_name] \[[tech_tree]\]"
	desc = tech_tree.desc + " <b>Уровень: \"[tech_tree.level]\"</b>."
	var/list/names = get_ru_names_cached()
	ru_names = names ? names.Copy() : new /list(6)
	for(var/i = 1; i <= 6; i++)
		ru_names[i] = "[names ? names[i] : initial(name)] \[[tech_tree]\]"
	// NOTE: This is just a reference to the tech on the system it grabbed it from
	// This seems highly fragile
	stored = tech_tree

/obj/item/disk/tech_disk/proc/wipe_tech()
	name = default_name
	desc = default_desc
	ru_names = default_ru_names
	stored = null

/obj/item/disk/tech_disk/loaded
	var/tech_name

/obj/item/disk/tech_disk/loaded/Initialize(mapload)
	. = ..()
	var/datum/tech/our_tech
	for(var/tt in (subtypesof(/datum/tech) - /datum/tech/abductor - /datum/tech/syndicate))
		var/datum/tech/tech = tt
		if(initial(tech.name) == tech_name)
			our_tech = new tech
			our_tech.level = 8
			break

	load_tech(our_tech)

/obj/item/disk/tech_disk/loaded/materials
	tech_name = RESEARCH_TREE_MATERIALS

/obj/item/disk/tech_disk/loaded/engineering
	tech_name = RESEARCH_TREE_ENGINEERING

/obj/item/disk/tech_disk/loaded/plasmatech
	tech_name = RESEARCH_TREE_PLASMA

/obj/item/disk/tech_disk/loaded/powerstorage
	tech_name = RESEARCH_TREE_POWERSTORAGE

/obj/item/disk/tech_disk/loaded/bluespace
	tech_name = RESEARCH_TREE_BLUESPACE

/obj/item/disk/tech_disk/loaded/biotech
	tech_name = RESEARCH_TREE_BIOTECH

/obj/item/disk/tech_disk/loaded/combat
	tech_name = RESEARCH_TREE_COMBAT

/obj/item/disk/tech_disk/loaded/magnets
	tech_name = RESEARCH_TREE_MAGNETS

/obj/item/disk/tech_disk/loaded/programming
	tech_name = RESEARCH_TREE_PROGRAMMING

/obj/item/disk/tech_disk/loaded/toxins
	tech_name = RESEARCH_TREE_TOXINS

/obj/structure/closet/crate/full_tech
	name = "Crate with Tech Disks"

/obj/structure/closet/crate/full_tech/get_ru_names()
	return list(
		NOMINATIVE = "ящик с дискетами технологий",
		GENITIVE = "ящика с дискетами технологий",
		DATIVE = "ящику с дискетами технологий",
		ACCUSATIVE = "ящик с дискетами технологий",
		INSTRUMENTAL = "ящиком с дискетами технологий",
		PREPOSITIONAL = "ящике с дискетами технологий"
	)

/obj/structure/closet/crate/full_tech/populate_contents()
	for(var/path in subtypesof(/obj/item/disk/tech_disk/loaded))
		new path(src)

/obj/item/disk/design_disk
	name = "Component Design Disk"
	desc = "Переносной носитель данных, специализированный для хранения шаблонов печати."
	icon_state = "datadisk2"
	materials = list(MAT_METAL=100, MAT_GLASS=100)
	var/datum/design/blueprint
	// I'm doing this so that disk paths with pre-loaded designs don't get weird names
	// Otherwise, I'd use "initial()"
	var/default_name = "Component Design Disk"
	var/default_desc = "Переносной носитель данных, специализированный для хранения шаблонов печати."
	var/default_ru_names = list(
		NOMINATIVE = "дискета шаблона печати",
		GENITIVE = "дискеты шаблона печати",
		DATIVE = "дискете шаблона печати",
		ACCUSATIVE = "дискету шаблона печати",
		INSTRUMENTAL = "дискетой шаблона печати",
		PREPOSITIONAL = "дискете шаблона печати"
	)

/obj/item/disk/design_disk/get_ru_names()
	return list(
		NOMINATIVE = "дискета шаблона печати",
		GENITIVE = "дискеты шаблона печати",
		DATIVE = "дискете шаблона печати",
		ACCUSATIVE = "дискету шаблона печати",
		INSTRUMENTAL = "дискетой шаблона печати",
		PREPOSITIONAL = "дискете шаблона печати"
	)

/obj/item/disk/design_disk/New()
	..()
	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

/obj/item/disk/design_disk/proc/load_blueprint(datum/design/D)
	var/obj/design_item = new D
	name = "[default_name] \[[design_item]\]"
	desc = D.desc

	var/list/names = get_ru_names_cached()
	ru_names = names ? names.Copy() : new /list(6)
	for(var/i = 1; i <= 6; i++)
		ru_names[i] = "[names ? names[i] : initial(name)] \[[capitalize(design_item.declent_ru(NOMINATIVE))]\]"
	// NOTE: This is just a reference to the design on the system it grabbed it from
	// This seems highly fragile
	blueprint = D
	qdel(design_item)

/obj/item/disk/design_disk/proc/wipe_blueprint()
	name = default_name
	desc = default_desc
	ru_names = default_ru_names
	blueprint = null

/obj/item/disk/design_disk/golem_shell
	name = "golem creation disk"
	icon_state = "datadisk1"

/obj/item/disk/design_disk/golem_shell/get_ru_names()
	return list(
		NOMINATIVE = "дискета для создания голема",
		GENITIVE = "дискеты для создания голема",
		DATIVE = "дискете для создания голема",
		ACCUSATIVE = "дискету для создания голема",
		INSTRUMENTAL = "дискетой для создания голема",
		PREPOSITIONAL = "дискете для создания голема"
	)

/obj/item/disk/design_disk/golem_shell/Initialize(mapload)
	. = ..()
	var/datum/design/golem_shell/G = new
	blueprint = G

/* Station goals design disks */
/** Base */
/obj/item/disk/design_disk/station_goal_machinery
	name = ""
	desc = ""
	icon_state = "datadisk5"
	var/design_type

/obj/item/disk/design_disk/station_goal_machinery/brs_server/get_ru_names()
	return list()

/obj/item/disk/design_disk/station_goal_machinery/Initialize(mapload)
	. = ..()
	if(isnull(design_type))
		return INITIALIZE_HINT_QDEL

	blueprint = new design_type()

/obj/item/disk/design_disk/station_goal_machinery/brs_server
	name = "Bluespace rift scan server design"
	desc = "Экспериментальный проект сервера сканирования блюспейс-разломов."
	design_type = /datum/design/brs_server

/obj/item/disk/design_disk/station_goal_machinery/brs_server/get_ru_names()
	return list(
		NOMINATIVE = "дискета шаблона печати (Сервер сканирования БС-разломов)",
		GENITIVE = "дискеты шаблона печати (Сервер сканирования БС-разломов)",
		DATIVE = "дискете шаблона печати (Сервер сканирования БС-разломов)",
		ACCUSATIVE = "дискету шаблона печати (Сервер сканирования БС-разломов)",
		INSTRUMENTAL = "дискетой шаблона печати (Сервер сканирования БС-разломов)",
		PREPOSITIONAL = "дискете шаблона печати (Сервер сканирования БС-разломов)"
	)

/obj/item/disk/design_disk/station_goal_machinery/brs_portable_scanner
	name = "Bluespace rift portable scanner design"
	desc = "Экспериментальный проект портативного сканера блюспейс-разломов."
	design_type = /datum/design/brs_portable_scanner

/obj/item/disk/design_disk/station_goal_machinery/brs_portable_scanner/get_ru_names()
	return list(
		NOMINATIVE = "дискета шаблона печати (Портативный сканер БС-разломов)",
		GENITIVE = "дискеты шаблона печати (Портативный сканер БС-разломов)",
		DATIVE = "дискете шаблона печати (Портативный сканер БС-разломов)",
		ACCUSATIVE = "дискету шаблона печати (Портативный сканер БС-разломов)",
		INSTRUMENTAL = "дискетой шаблона печати (Портативный сканер БС-разломов)",
		PREPOSITIONAL = "дискете шаблона печати (Портативный сканер БС-разломов)"
	)

/obj/item/disk/design_disk/station_goal_machinery/brs_stationary_scanner
	name = "Bluespace rift stationary scanner design"
	desc = "Экспериментальный проект стационарного сканера блюспейс-разломов."
	design_type = /datum/design/brs_stationary_scanner

/obj/item/disk/design_disk/station_goal_machinery/brs_stationary_scanner/get_ru_names()
	return list(
		NOMINATIVE = "дискета шаблона печати (Стационарный сканер БС-разломов)",
		GENITIVE = "дискеты шаблона печати (Стационарный сканер БС-разломов)",
		DATIVE = "дискете шаблона печати (Стационарный сканер БС-разломов)",
		ACCUSATIVE = "дискету шаблона печати (Стационарный сканер БС-разломов)",
		INSTRUMENTAL = "дискетой шаблона печати (Стационарный сканер БС-разломов)",
		PREPOSITIONAL = "дискете шаблона печати (Стационарный сканер БС-разломов)"
	)


/obj/item/disk/design_disk/tailblade/blade_nt
	name = "Tail laserblade implant design"
	desc = "Переносной носитель данных, специализированный для хранения шаблонов печати. \
			Получен корпорацией \"Нанотрейзен\" по уникальному контракту с \"Кибернетикой М’Саи\"."
	blueprint = new /datum/design/tailblade

/obj/item/disk/design_disk/tailblade/blade_nt/get_ru_names()
	return list(
		NOMINATIVE = "дискета шаблона печати (Имплант хвостового лазера)",
		GENITIVE = "дискеты шаблона печати (Имплант хвостового лазера)",
		DATIVE = "дискете шаблона печати (Имплант хвостового лазера)",
		ACCUSATIVE = "дискету шаблона печати (Имплант хвостового лазера)",
		INSTRUMENTAL = "дискетой шаблона печати (Имплант хвостового лазера)",
		PREPOSITIONAL = "дискете шаблона печати (Имплант хвостового лазера)"
	)
