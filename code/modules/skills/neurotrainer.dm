/obj/item/neurotrainer
	name = "skill neurotrainer"
	desc = "Сыворотка с дозой механитов, запрограммированных на обучение конкретному навыку. \
		Сыворотка вводится через глазное яблоко. После того, как механиты попадают в мозг пациента, \
		они быстро улучшают способности в определённой области. При необходимости преобразуя себя в нервную ткань."
	icon = 'icons/obj/implants.dmi'
	icon_state = "neurotrainer_1"
	item_state = "syringe_0"
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	origin_tech = "materials=2;biotech=3"
	materials = list(MAT_METAL = 600, MAT_GLASS = 200)
	/// Skill path
	var/list/skill_types = null
	/// Name of train skill
	var/manual_title = "Неизвестно"
	/// Skill points amount
	var/skill_points = 1
	var/used = FALSE

/obj/item/neurotrainer/Initialize(mapload)
	. = ..()
	update_icon(UPDATE_ICON_STATE)

/obj/item/neurotrainer/get_ru_names()
	return alist(
		NOMINATIVE = "нейротренер навыка \"[manual_title]\"",
		GENITIVE = "нейротренера навыка \"[manual_title]\"",
		DATIVE = "нейротренеру навыка \"[manual_title]\"",
		ACCUSATIVE = "нейротренер навыка \"[manual_title]\"",
		INSTRUMENTAL = "нейротренером навыка \"[manual_title]\"",
		PREPOSITIONAL = "нейротренере навыка \"[manual_title]\"",
	)

/obj/item/neurotrainer/update_icon_state()
	icon_state = "neurotrainer_[skill_types ? "1" : "0"]"

/obj/item/neurotrainer/attack(mob/living/carbon/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ATTACK_CHAIN_PROCEED

	if(!iscarbon(target))
		return .

	if(!user || !skill_types)
		return .

	if(target != user)
		target.visible_message(span_warning("[user] пыта[PLUR_ET_YUT(user)]ся использовать нейротренер в [target]."))
		if(!do_after(user, 5 SECONDS * toolspeed, target, category = DA_CAT_TOOL) || QDELETED(user) || QDELETED(target) || QDELETED(src) || !skill_types)
			return .

	addtimer(CALLBACK(src, PROC_REF(apply_neurtrainer), user, target), 1)
	. |= ATTACK_CHAIN_SUCCESS

/obj/item/neurotrainer/proc/apply_neurtrainer(mob/living/user, mob/living/carbon/target)
	. = FALSE
	if(!target.mind)
		return

	if(used)
		return

	if(skill_types && islist(skill_types))
		var/choices = list()
		for(var/datum/skill/skill_type as anything in skill_types)
			choices[skill_type::name] = skill_type
		var/choice = tgui_input_list(usr, "Выберите навык для прокачки: ", "Прокачка навыка", choices)
		if(!skill_types || !choice)
			return
		skill_types = choices[choice]

	if(used)
		return

	var/current_skill_level = target.mind.skills[skill_types]
	if(!current_skill_level)
		current_skill_level = SKILL_LEVEL_NONE
	var/applyed_bonus_points = skill_points
	if(current_skill_level + applyed_bonus_points > SKILL_LEVEL_LEGEND)
		applyed_bonus_points = SKILL_LEVEL_LEGEND - current_skill_level
	if(applyed_bonus_points > 0)
		target.mind.active_neurotrainer_bonuses[skill_types] += applyed_bonus_points
		target.mind.refresh_skills()
		. = TRUE
		used = TRUE

	if(!.)
		return

	skill_types = null
	update_icon(UPDATE_ICON_STATE)

	if(user == target)
		to_chat(user, span_notice("Вы использовали нейротренер."))
	else
		target.visible_message(
			span_warning("[user] использовал[GEND_A_O_I(user)] нейротренер в [target]."),
			span_notice("[user] использовал[GEND_A_O_I(user)] нейротренер на вас."),
		)

// MARK: Random
/obj/item/neurotrainer/all_without_combat
	manual_title = "Небоевые"

/obj/item/neurotrainer/all_without_combat/Initialize(mapload)
	var/static/combat_skills = list(
		/datum/skill/combat/accuracy,
		/datum/skill/combat/guns,
		/datum/skill/combat/melee,
		/datum/skill/combat/fists,
	)
	skill_types = GLOB.skill_types - combat_skills
	. = ..()

/obj/item/neurotrainer/random/Initialize(mapload)
	. = ..()
	var/newtype = pick(GLOB.skill_neurotrainers)
	new newtype(loc)
	return INITIALIZE_HINT_QDEL

// MARK: General
/obj/item/neurotrainer/general
	manual_title = "Общие"
	skill_types = list(
		/datum/skill/general/carrying,
		/datum/skill/general/mech_drive,
		/datum/skill/general/mod_use,
		/datum/skill/general/cooking,
	)

/obj/item/neurotrainer/general/carrying
	manual_title = "Переноска"
	skill_types = /datum/skill/general/carrying

/obj/item/neurotrainer/general/mech_drive
	manual_title = "Пилотирование"
	skill_types = /datum/skill/general/mech_drive

/obj/item/neurotrainer/general/mod_use
	manual_title = "Внекорабельная деятельность"
	skill_types = /datum/skill/general/mod_use

/obj/item/neurotrainer/general/cooking
	manual_title = "Кулинария"
	skill_types = /datum/skill/general/cooking

// MARK: Service
/obj/item/neurotrainer/service
	manual_title = "Сервис"
	skill_types = list(
		/datum/skill/service/drink_mixing,
		/datum/skill/service/botany,
		/datum/skill/service/cleaning,
		/datum/skill/service/mining,
	)

/obj/item/neurotrainer/service/drink_mixing
	manual_title = "Напитки"
	skill_types = /datum/skill/service/drink_mixing

/obj/item/neurotrainer/service/botany
	manual_title = "Ботаника"
	skill_types = /datum/skill/service/botany

/obj/item/neurotrainer/service/cleaning
	manual_title = "Клининг"
	skill_types = /datum/skill/service/cleaning

/obj/item/neurotrainer/service/mining
	manual_title = "Горное дело"
	skill_types = /datum/skill/service/mining

// MARK: Combat
/obj/item/neurotrainer/combat
	manual_title = "Боевые"
	skill_types = list(
		/datum/skill/combat/accuracy,
		/datum/skill/combat/guns,
		/datum/skill/combat/melee,
		/datum/skill/combat/fists,
		/datum/skill/combat/bows,
	)

/obj/item/neurotrainer/combat/accuracy
	manual_title = "Точный выстрел"
	skill_types = /datum/skill/combat/accuracy

/obj/item/neurotrainer/combat/guns
	manual_title = "Стрелковое оружие"
	skill_types = /datum/skill/combat/guns

/obj/item/neurotrainer/combat/melee
	manual_title = "Оружие ближнего боя"
	skill_types = /datum/skill/combat/melee

/obj/item/neurotrainer/combat/fists
	manual_title = "Рукопашный бой"
	skill_types = /datum/skill/combat/fists

/obj/item/neurotrainer/combat/bows
	manual_title = "Стрельба из лука"
	skill_types = /datum/skill/combat/bows

// MARK: Engineering
/obj/item/neurotrainer/engineering
	manual_title = "Инженерные"
	skill_types = list(
		/datum/skill/engineering/building,
		/datum/skill/engineering/construction,
		/datum/skill/engineering/electrician,
		/datum/skill/engineering/atmos,
	)

/obj/item/neurotrainer/engineering/building
	manual_title = "Строительство"
	skill_types = /datum/skill/engineering/building

/obj/item/neurotrainer/engineering/construction
	manual_title = "Конструирование"
	skill_types = /datum/skill/engineering/construction

/obj/item/neurotrainer/engineering/electrician
	manual_title = "Электроника"
	skill_types = /datum/skill/engineering/electrician

/obj/item/neurotrainer/engineering/atmos
	manual_title = "Атмосферика"
	skill_types = /datum/skill/engineering/atmos

// MARK: Medical
/obj/item/neurotrainer/medical
	manual_title = "Медицинские"
	skill_types = list(
		/datum/skill/medical/surgery,
		/datum/skill/medical/heal,
		/datum/skill/medical/chemistry,
		/datum/skill/medical/genetic,
		/datum/skill/medical/virusology,
	)

/obj/item/neurotrainer/medical/surgery
	manual_title = "Хирургия"
	skill_types = /datum/skill/medical/surgery

/obj/item/neurotrainer/medical/heal
	manual_title = "Лечение"
	skill_types = /datum/skill/medical/heal

/obj/item/neurotrainer/medical/chemistry
	manual_title = "Химия"
	skill_types = /datum/skill/medical/chemistry

/obj/item/neurotrainer/medical/genetic
	manual_title = "Генетика"
	skill_types = /datum/skill/medical/genetic

/obj/item/neurotrainer/medical/virusology
	manual_title = "Вирусология"
	skill_types = /datum/skill/medical/virusology

// MARK: Research
/obj/item/neurotrainer/research
	manual_title = "Научные"
	skill_types = list(
		/datum/skill/research/research,
		/datum/skill/research/protolathe,
		/datum/skill/research/robotics,
		/datum/skill/research/xenobiology,
	)

/obj/item/neurotrainer/research/research
	manual_title = "Исследование"
	skill_types = /datum/skill/research/research

/obj/item/neurotrainer/research/protolathe
	manual_title = "Протолат"
	desc = "Руководство по работе с протолатом."
	skill_types = /datum/skill/research/protolathe

/obj/item/neurotrainer/research/mech_construct
	manual_title = "Конструирование мехов"
	skill_types = /datum/skill/research/robotics

/obj/item/neurotrainer/research/xenobiology
	manual_title = "Ксенобиология"
	skill_types = /datum/skill/research/xenobiology
