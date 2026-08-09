#define MANUAL_READ_PAGES_AMOUNT 36
#define MANUAL_PAGE_READ_DURATION 5 SECONDS

/obj/item/book/skill_manual
	w_class = WEIGHT_CLASS_SMALL
	desc = "Неизвестное руководство."
	has_drm = TRUE
	read_by_examine = FALSE
	/// title for localization
	var/manual_title = "Неизвестно"
	/// Count of pages for read
	var/pages_amount = MANUAL_READ_PAGES_AMOUNT
	/// skill for bonus
	var/skill_type
	/// how many points increase skill
	var/bonus_size = 1
	/// cap of skill level for bonus
	var/max_skill_level = SKILL_LEVEL_PROFESSIONAL
	/// flag for hold using state
	var/applyed_bonus_points = FALSE

/obj/item/book/skill_manual/get_ru_names()
	return alist(
		NOMINATIVE = "руководство \"[manual_title]\"",
		GENITIVE = "руководства \"[manual_title]\"",
		DATIVE = "руководству \"[manual_title]\"",
		ACCUSATIVE = "руководство \"[manual_title]\"",
		INSTRUMENTAL = "руководством \"[manual_title]\"",
		PREPOSITIONAL = "руководстве \"[manual_title]\"",
	)

/obj/item/book/skill_manual/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip_check))
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(on_drop_check))

/obj/item/book/skill_manual/Destroy(force)
	UnregisterSignal(src, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(src, COMSIG_ITEM_DROPPED)
	. = ..()

/obj/item/book/skill_manual/proc/on_equip_check(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	if(slot & (ITEM_SLOT_HANDS|ITEM_SLOT_POCKETS))
		try_apply_skill_bonus(user)
		return
	try_remove_skill_bonus(user)

/obj/item/book/skill_manual/proc/on_drop_check(datum/source, mob/user)
	SIGNAL_HANDLER
	try_remove_skill_bonus(user)

/obj/item/book/skill_manual/proc/try_apply_skill_bonus(mob/user)
	if(applyed_bonus_points > 0)
		return
	var/datum/mind/user_mind = user.mind
	if(!user_mind)
		return
	if(skill_type in (user_mind.active_skill_bonuses | user_mind.manual_skill_bonuses))
		return
	var/current_skill_level = user_mind.skills[skill_type]
	if(!current_skill_level)
		current_skill_level = SKILL_LEVEL_NONE
	applyed_bonus_points = bonus_size
	if(current_skill_level + applyed_bonus_points > max_skill_level)
		applyed_bonus_points = max_skill_level - current_skill_level
	if(applyed_bonus_points <= 0)
		return
	user_mind.active_skill_bonuses[skill_type] = applyed_bonus_points
	user_mind.refresh_skills()

/obj/item/book/skill_manual/proc/try_remove_skill_bonus(mob/user)
	if(applyed_bonus_points <= 0)
		return
	if(user.mind)
		user.mind.active_skill_bonuses -= skill_type
		user.mind.refresh_skills()
	applyed_bonus_points = 0

/obj/item/book/skill_manual/attack_self(mob/user)
	if(carved)
		return ..()

	var/datum/mind/user_mind = user.mind

	if(!user_mind || !user.is_literate())
		to_chat(user, span_notice("Вы не можете читать [declent_ru(NOMINATIVE)]!"))
		return

	if(type in user_mind.read_manuals)
		var/pages = user_mind.read_manuals[type]
		if(pages >= pages_amount)
			to_chat(user, span_notice("Вы уже прочитали [declent_ru(NOMINATIVE)]!"))
			return

	to_chat(user, span_notice("Вы начинаете читать [declent_ru(NOMINATIVE)]..."))

	while(do_after(user, 5 SECONDS, src, max_interact_count = 1))
		if(!(type in user_mind.read_manuals))
			user_mind.read_manuals[type] = 0
		user_mind.read_manuals[type] += 1
		if(user_mind.read_manuals[type] >= pages_amount)
			// remove temo variable from manual, but bonus hold in active_skill_bonuses (prevent dupe bonuses)
			user_mind.active_skill_bonuses -= skill_type
			user_mind.manual_skill_bonuses[skill_type] = applyed_bonus_points
			applyed_bonus_points = 0
			user_mind.refresh_skills()
			to_chat(user, span_notice("Вы полностью прочитали [declent_ru(NOMINATIVE)] и запомнили все что в нем было!"))
			balloon_alert(user, "чтение завершено!")
			return

	balloon_alert(user, "чтение прервано!")

/obj/item/book/skill_manual/examine(mob/user)
	. = ..()
	var/complete_pages = 0
	if(type in user.mind.read_manuals)
		complete_pages = user.mind.read_manuals[type]
	if(complete_pages >= pages_amount)
		. += span_notice("Вы уже полностью прочитали и запомнили данное руководство.")
		return
	. += span_notice("Прочитано [complete_pages] страниц из [pages_amount].")

/obj/item/book/skill_manual/random/Initialize(mapload)
	. = ..()
	var/newtype = pick(GLOB.skill_manual_types)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL

// MARK: General
/obj/item/book/skill_manual/general
	icon_state = "cooked_book"
	item_state = "cooked_book"

/obj/item/book/skill_manual/general/random/Initialize(mapload)
	. = ..()
	var/static/banned_books = list(/obj/item/book/skill_manual/general/random)
	var/newtype = pick(subtypesof(/obj/item/book/skill_manual/general) - banned_books)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/book/skill_manual/general/carrying
	manual_title = "Переноска"
	desc = "Руководство по эффективной переноске предметов."
	skill_type = /datum/skill/general/carrying

/obj/item/book/skill_manual/general/mech_drive
	manual_title = "Пилотирование"
	desc = "Руководство по пилотированию мехов и подов."
	skill_type = /datum/skill/general/mech_drive

/obj/item/book/skill_manual/general/mod_use
	manual_title = "Внекорабельная деятельность"
	desc = "Руководство для использования модульными экзокостюмами."
	skill_type = /datum/skill/general/mod_use


/obj/item/book/skill_manual/general/cooking
	manual_title = "Кулинария"
	desc = "Руководство по кулинарии."
	skill_type = /datum/skill/general/cooking

// MARK: Service
/obj/item/book/skill_manual/service
	icon_state = "bookHydroponicsPodPeople"
	item_state = "bookHydroponicsPodPeople"

/obj/item/book/skill_manual/service/random/Initialize(mapload)
	. = ..()
	var/static/banned_books = list(/obj/item/book/skill_manual/service/random)
	var/newtype = pick(subtypesof(/obj/item/book/skill_manual/service) - banned_books)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/book/skill_manual/service/drink_mixing
	manual_title = "Напитки"
	desc = "Руководство по напиткам."
	skill_type = /datum/skill/service/drink_mixing

/obj/item/book/skill_manual/service/botany
	manual_title = "Ботаника"
	desc = "Руководство по выращиванию растений."
	skill_type = /datum/skill/service/botany

/obj/item/book/skill_manual/service/cleaning
	manual_title = "Клининг"
	desc = "Руководство по эффективной уборке помещений."
	skill_type = /datum/skill/service/cleaning

/obj/item/book/skill_manual/service/mining
	manual_title = "Горное дело"
	desc = "Руководство по эффективной добыче полезных ископаемых."
	skill_type = /datum/skill/service/mining

// MARK: Combat
/obj/item/book/skill_manual/combat
	icon_state = "bookSpaceLaw"
	item_state = "bookSpaceLaw"

/obj/item/book/skill_manual/combat/random/Initialize(mapload)
	. = ..()
	var/static/banned_books = list(/obj/item/book/skill_manual/combat/random)
	var/newtype = pick(subtypesof(/obj/item/book/skill_manual/combat) - banned_books)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/book/skill_manual/combat/accuracy
	manual_title = "Точный выстрел"
	desc = "Наставление по стрелковому делу."
	skill_type = /datum/skill/combat/accuracy

/obj/item/book/skill_manual/combat/guns
	manual_title = "Стрелковое оружие"
	desc = "Руководство по обращению с различным стрелковым оружием."
	skill_type = /datum/skill/combat/guns

/obj/item/book/skill_manual/combat/melee
	manual_title = "Оружие ближнего боя"
	desc = "Руководство по обращению с различным оружием ближнего боя."
	skill_type = /datum/skill/combat/melee

/obj/item/book/skill_manual/combat/bows
	manual_title = "Стрельба из лука"
	desc = "Руководство по стрельбе из лука и обращению с ним."
	skill_type = /datum/skill/combat/bows

/obj/item/book/skill_manual/combat/fists
	manual_title = "Рукопашный бой"
	desc = "Руководство по рукопашному бою."
	skill_type = /datum/skill/combat/fists

// MARK: Engineering
/obj/item/book/skill_manual/engineering
	icon_state = "bookEngineering"
	item_state = "bookEng"

/obj/item/book/skill_manual/engineering/random/Initialize(mapload)
	. = ..()
	var/static/banned_books = list(/obj/item/book/skill_manual/engineering/random)
	var/newtype = pick(subtypesof(/obj/item/book/skill_manual/engineering) - banned_books)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/book/skill_manual/engineering/building
	manual_title = "Строительство"
	desc = "Руководство по строительству."
	skill_type = /datum/skill/engineering/building

/obj/item/book/skill_manual/engineering/construction
	manual_title = "Конструирование"
	desc = "Руководство по конструированию различных механизмов."
	skill_type = /datum/skill/engineering/construction

/obj/item/book/skill_manual/engineering/electrician
	manual_title = "Электроника"
	desc = "Руководство по электрике."
	skill_type = /datum/skill/engineering/electrician

/obj/item/book/skill_manual/engineering/atmos
	manual_title = "Атмосферика"
	desc = "Руководство по работе с атмосферной техникой."
	skill_type = /datum/skill/engineering/atmos

// MARK: Medical
/obj/item/book/skill_manual/medical
	icon_state = "bookCloning"
	item_state = "bookCloning"

/obj/item/book/skill_manual/medical/random/Initialize(mapload)
	. = ..()
	var/static/banned_books = list(/obj/item/book/skill_manual/medical/random)
	var/newtype = pick(subtypesof(/obj/item/book/skill_manual/medical) - banned_books)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/book/skill_manual/medical/surgery
	manual_title = "Хирургия"
	desc = "Руководство по хирургии и анатомии."
	skill_type = /datum/skill/medical/surgery

/obj/item/book/skill_manual/medical/heal
	manual_title = "Лечение"
	desc = "Руководство по лечении различными препаратами и средствами."
	skill_type = /datum/skill/medical/heal

/obj/item/book/skill_manual/medical/chemistry
	manual_title = "Химия"
	desc = "Руководство по химии с таблицей Менделеева внутри."
	skill_type = /datum/skill/medical/chemistry

/obj/item/book/skill_manual/medical/genetic
	manual_title = "Генетика"
	desc = "Руководство по генетике."
	skill_type = /datum/skill/medical/genetic

/obj/item/book/skill_manual/medical/virusology
	manual_title = "Вирусология"
	desc = "Руководство по работе с аппаратурой вирусологии."
	skill_type = /datum/skill/medical/virusology

// MARK: Research
/obj/item/book/skill_manual/research
	icon_state = "rdbook"
	item_state = "rdbook"

/obj/item/book/skill_manual/research/random/Initialize(mapload)
	. = ..()
	var/static/banned_books = list(/obj/item/book/skill_manual/research/random)
	var/newtype = pick(subtypesof(/obj/item/book/skill_manual/research) - banned_books)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/book/skill_manual/research/research
	manual_title = "Исследование"
	desc = "Руководство по работе с деконструктором."
	skill_type = /datum/skill/research/research

/obj/item/book/skill_manual/research/protolathe
	manual_title = "Протолат"
	desc = "Руководство по работе с протолатом."
	skill_type = /datum/skill/research/protolathe

/obj/item/book/skill_manual/research/mech_construct
	manual_title = "Конструирование мехов"
	desc = "Руководство по конструированию различных видов мехов и подов."
	skill_type = /datum/skill/research/robotics

/obj/item/book/skill_manual/research/xenobiology
	manual_title = "Ксенобиология"
	desc = "Энциклопедия с различными экзотическими животными с детальным описанием."
	skill_type = /datum/skill/research/xenobiology


#undef MANUAL_READ_PAGES_AMOUNT
#undef MANUAL_PAGE_READ_DURATION
