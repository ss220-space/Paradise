/obj/item/book/skill_manual
	w_class = WEIGHT_CLASS_SMALL
	desc = "Неизвестное руководство."
	/// title for localization
	var/manual_title = "Неизвестно"
	/// skill for bonus
	var/skill_type
	/// how many points increase skill
	var/bonus_size = 1
	/// cap of skill level for bonus
	var/max_skill_level = SKILL_LEVEL_EXPERT
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
	if(!user.mind)
		return
	if(skill_type in user.mind.active_skill_bonuses)
		return
	var/current_skill_level = user.mind.skills[skill_type]
	if(!current_skill_level)
		current_skill_level = SKILL_LEVEL_NONE
	applyed_bonus_points = bonus_size
	if(current_skill_level + applyed_bonus_points > max_skill_level)
		applyed_bonus_points = max_skill_level - current_skill_level
	if(applyed_bonus_points <= 0)
		return
	user.mind.skills[skill_type] = current_skill_level + applyed_bonus_points
	user.mind.active_skill_bonuses += skill_type

/obj/item/book/skill_manual/proc/try_remove_skill_bonus(mob/user)
	if(applyed_bonus_points <= 0)
		return
	if(user.mind)
		user.mind.skills[skill_type] = user.mind.skills[skill_type] - applyed_bonus_points
		user.mind.active_skill_bonuses -= skill_type
	applyed_bonus_points = 0


// MARK: General
/obj/item/book/skill_manual/general
	icon_state = "cooked_book"
	item_state = "cooked_book"

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

/obj/item/book/skill_manual/general/lockpick
	manual_title = "Взлом"
	desc = "Руководство по взлому."
	skill_type = /datum/skill/general/lockpick

/obj/item/book/skill_manual/general/cooking
	manual_title = "Кулинария"
	desc = "Руководство по кулинарии."
	skill_type = /datum/skill/general/cooking

// MARK: Service
/obj/item/book/skill_manual/service
	icon_state = "bookHydroponicsPodPeople"
	item_state = "bookHydroponicsPodPeople"

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

// MARK: Combat
/obj/item/book/skill_manual/combat
	icon_state = "bookSpaceLaw"
	item_state = "bookSpaceLaw"

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

/obj/item/book/skill_manual/combat/fists
	manual_title = "Рукопашный бой"
	desc = "Руководство по рукопашному бою."
	skill_type = /datum/skill/combat/fists

// MARK: Engineering
/obj/item/book/skill_manual/engineering
	icon_state = "bookEngineering"
	item_state = "bookEng"

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
	desc = "Руководство по химии с таблицец Менделеева внутри."
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
	skill_type = /datum/skill/research/mech_construct

/obj/item/book/skill_manual/research/xenobiology
	manual_title = "Ксенобиология"
	desc = "Энциклопедия с различными экзотическими животными с детальным описанием."
	skill_type = /datum/skill/research/xenobiology
