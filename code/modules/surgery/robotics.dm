//Procedures in this file: Generic surgery steps for robots
//////////////////////////////////////////////////////////////////
//						COMMON STEPS							//
//////////////////////////////////////////////////////////////////


/datum/surgery_step/proxy/robotics

/datum/surgery/robotics
	requires_organic_bodypart = FALSE

/datum/surgery/robotics/cybernetic_repair
	name = "Ремонт части тела"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/proxy/robotics/repair_limb,
		/datum/surgery_step/robotics/external/close_hatch
	)
	requires_organic_bodypart = FALSE
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)

/datum/surgery/robotics/cybernetic_repair/internal
	name = "Манипуляция с внутренними компонентами"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		// burn/brute are squished into here as well
		/datum/surgery_step/proxy/robotics/manipulate_organs,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list(
		BODY_ZONE_PRECISE_EYES,
		BODY_ZONE_PRECISE_MOUTH,
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
	)

/datum/surgery/robotics/cybernetic_amputation
	name = "Ампутация робо-конечности"
	steps = list(/datum/surgery_step/robotics/external/amputate)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)

/datum/surgery/cybernetic_amputation/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(.)
		var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
		if(affected.cannot_amputate)
			return FALSE

/datum/surgery/robotics/cybernetic_customization
	name = "Изменение внешнего вида части тела"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/robotics/external/customize_appearance,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)

// Intermediate repair surgeries, for fixing up internal maladies mid-surgery.

/datum/surgery/intermediate/robotics
	requires_bodypart = TRUE
	requires_organic_bodypart = FALSE

/datum/surgery/intermediate/robotics/repair
	possible_locs = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_PRECISE_L_HAND, BODY_ZONE_R_ARM, BODY_ZONE_PRECISE_R_HAND, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_L_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_GROIN)

/datum/surgery/intermediate/robotics/repair/burn
	steps = list(/datum/surgery_step/robotics/external/repair/burn)

/datum/surgery/intermediate/robotics/repair/brute
	steps = list(/datum/surgery_step/robotics/external/repair/brute)

// Manipulate organs sub-surgeries

/datum/surgery/intermediate/robotics/manipulate_organs
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
		BODY_ZONE_PRECISE_EYES,
		BODY_ZONE_PRECISE_MOUTH,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_LEG,
		BODY_ZONE_R_LEG,
		BODY_ZONE_TAIL,
	)

/datum/surgery/intermediate/robotics/manipulate_organs/extract
	steps = list(/datum/surgery_step/robotics/manipulate_robotic_organs/extract)

/datum/surgery/intermediate/robotics/manipulate_organs/implant
	steps = list(/datum/surgery_step/robotics/manipulate_robotic_organs/implant)

/datum/surgery/intermediate/robotics/manipulate_organs/mend
	steps = list(/datum/surgery_step/robotics/manipulate_robotic_organs/mend)

/datum/surgery/intermediate/robotics/manipulate_organs/install_mmi
	steps = list(/datum/surgery_step/robotics/manipulate_robotic_organs/install_mmi)
	possible_locs = list(BODY_ZONE_CHEST)

/datum/surgery_step/robotics
	can_infect = 0

/datum/surgery_step/robotics/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	. = ..()
	if(tool && tool.tool_behaviour)
		tool.play_tool_sound(user, 30)

/datum/surgery_step/robotics/external
	name = "внешняя робо-хирургия"

/datum/surgery_step/robotics/external/unscrew_hatch
	name = "развинчивание крышки техпанели"
	allowed_tools = list(
		TOOL_SCREWDRIVER = 100,
		/obj/item/coin = 50,
		/obj/item/kitchen/knife = 50
	)

	time = 1.6 SECONDS

/datum/surgery_step/robotics/external/unscrew_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] развинчивать крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете развинчивать крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/robotics/external/unscrew_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] развинчива[pluralize_ru(user.gender, "ет", "ют")] крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы развинчиваете крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.open = ORGAN_SYNTHETIC_LOOSENED
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/unscrew_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, безуспешно пытаясь развинтить крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]!"),
		span_warning("Вы дёргаете рукой, безуспешно пытаясь развинтить крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_RETRY

/datum/surgery_step/robotics/external/open_hatch
	name = "открытие крышки техпанели"
	allowed_tools = list(
		TOOL_RETRACTOR = 100,
		TOOL_CROWBAR = 100,
		/obj/item/kitchen/utensil = 50
	)

	time = 2.4 SECONDS

/datum/surgery_step/robotics/external/open_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] открывать крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете открывать крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/robotics/external/open_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] открыва[pluralize_ru(user.gender, "ет", "ют")] крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы открываете крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.open = ORGAN_SYNTHETIC_OPEN
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/open_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, безуспешно пытаясь открыть крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]!"),
		span_warning("Вы дёргаете рукой, безуспешно пытаясь открыть крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_RETRY

/datum/surgery_step/robotics/external/close_hatch
	name = "закрытие крышки техпанели"
	allowed_tools = list(
		TOOL_RETRACTOR = 100,
		TOOL_CROWBAR = 100,
		/obj/item/kitchen/utensil = 50
	)

	time = 2.4 SECONDS

/datum/surgery_step/robotics/external/close_hatch/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] отключать и отсоединять [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете отключать и отсоединять [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/robotics/external/close_hatch/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] закрыва[pluralize_ru(user.gender, "ет", "ют")] и закрепля[pluralize_ru(user.gender, "ет", "ют")] крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы закрываете и закрепляете крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	tool.play_tool_sound(target)
	affected.open = ORGAN_CLOSED
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/close_hatch/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, безуспешно пытаясь закрыть и закрепить крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]!"),
		span_warning("Вы дёргаете рукой, безуспешно пытаясь закрыть и закрепить крышку технической панели на [affected.declent_ru(PREPOSITIONAL)] [target], используя [tool.declent_ru(ACCUSATIVE)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_RETRY

/datum/surgery_step/robotics/external/close_hatch/premature
	name = "close hatch prematurely"

/datum/surgery_step/robotics/external/close_hatch/premature/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] отключать и отсоединять [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		// give a little heads up to the surgeon that they're stopping the surgery prematurely in case that wasn't the intention.
		span_notice("Вы прерываете текущую операцию, начиная отключать и отсоединять [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()


/datum/surgery_step/robotics/external/repair
	name = "устранение повреждений"
	time = 3.2 SECONDS

/datum/surgery_step/robotics/external/repair/burn
	name = "замена сгоревших проводов"
	allowed_tools = list(
		/obj/item/stack/cable_coil = 100
	)

/datum/surgery_step/robotics/external/repair/burn/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/obj/item/stack/cable_coil/C = tool
	if(!(affected.burn_dam > 0))
		user.balloon_alert(user, "провода [affected.declent_ru(GENITIVE)] в норме!")
		return SURGERY_BEGINSTEP_SKIP
	if(!istype(C))
		return SURGERY_BEGINSTEP_SKIP
	if(C.get_amount() < 3)
		user.balloon_alert(user, "недостаточно проводов!")
		return SURGERY_BEGINSTEP_SKIP
	C.use(3)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] заменять сгоревшие провода на новые в [affected.declent_ru(PREPOSITIONAL)] [target]."),
		span_notice("Вы начинаете заменять сгоревшие провода на новые в [affected.declent_ru(PREPOSITIONAL)] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()



/datum/surgery_step/robotics/external/repair/burn/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] заменя[pluralize_ru(user.gender, "ет", "ют")] сгоревшие провода на новые в [affected.declent_ru(PREPOSITIONAL)] [target]."),
		span_notice("Вы заменяете сгоревшие провода на новые в [affected.declent_ru(PREPOSITIONAL)] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.heal_damage(0, rand(30, 50), 1, 1)
	if(affected.burn_dam)
		return SURGERY_STEP_RETRY_ALWAYS
	else
		return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/repair/burn/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, вызывая короткое замыкание проводки в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, вызывая короткое замыкание проводки в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(rand(5, 10), BURN, affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/robotics/external/repair/brute
	name = "устранение механических повреждений корпуса"
	allowed_tools = list(
		TOOL_WELDER = 100,
		/obj/item/gun/energy/plasmacutter = 50
	)

/datum/surgery_step/robotics/external/repair/brute/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected.brute_dam > 0 || affected.is_disfigured()))
		user.balloon_alert(user, "повреждения отсутствуют!")
		return SURGERY_BEGINSTEP_SKIP
	if(tool.tool_behaviour == TOOL_WELDER)
		if(!tool.use(1))
			return SURGERY_BEGINSTEP_SKIP
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] ремонтировать повреждённый корпус [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете ремонтировать повреждённый корпус [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()


/datum/surgery_step/robotics/external/repair/brute/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] устраня[pluralize_ru(user.gender, "ет", "ют")] повреждения корпуса [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы устраняете повреждения корпуса [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.heal_damage(rand(30, 50), 0, 1, 1)
	affected.undisfigure()
	if(affected.brute_dam)
		// Keep trying until there's nothing left to patch up.
		return SURGERY_STEP_RETRY_ALWAYS
	else
		return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/repair/brute/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] внутренние компоненты [affected.declent_ru(GENITIVE)] [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] внутренние компоненты [affected.declent_ru(GENITIVE)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(rand(5, 10), BURN, affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/proxy/robotics/manipulate_organs
	name = "манипуляция с внутренними компонентами – прокси"

	branches = list(
		/datum/surgery/intermediate/robotics/manipulate_organs/extract,
		/datum/surgery/intermediate/robotics/manipulate_organs/implant,
		/datum/surgery/intermediate/robotics/manipulate_organs/install_mmi,
		/datum/surgery/intermediate/robotics/manipulate_organs/mend,
		/datum/surgery/intermediate/robotics/repair/brute,
		/datum/surgery/intermediate/robotics/repair/burn
	)


/datum/surgery_step/robotics/manipulate_robotic_organs
	time = 3.2 SECONDS


/datum/surgery_step/robotics/manipulate_robotic_organs/mend
	name = "заживление кибернетических органов"
	allowed_tools = list(
		/obj/item/stack/nanopaste = 100,
		TOOL_BONEGEL = 30,
		TOOL_SCREWDRIVER = 70
	)

/datum/surgery_step/robotics/manipulate_robotic_organs/mend/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/found_damaged_organ = FALSE
	for(var/obj/item/organ/internal/organ as anything in affected.internal_organs)
		if(organ.has_damage() && organ.is_robotic())
			user.visible_message(
				span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] восстаналивать [organ.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
				span_notice("Вы начинаете восстаналивать [organ.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
				chat_message_type = MESSAGE_TYPE_COMBAT
			)
			found_damaged_organ = TRUE

	if(!found_damaged_organ)
		user.balloon_alert(user, "органы в норме!")
		return SURGERY_BEGINSTEP_SKIP

	target.custom_pain("Боль в ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)] просто невыносима!")
	return ..()


/datum/surgery_step/robotics/manipulate_robotic_organs/mend/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(!hasorgans(target))
		return
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	for(var/obj/item/organ/internal/organ as anything in affected.internal_organs)
		if(organ.damage && organ.is_robotic())
			user.visible_message(
				span_notice("[user] восстанавлива[pluralize_ru(user.gender, "ет", "ют")] [organ.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
				span_notice("Вы восстаналиваете [organ.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
				chat_message_type = MESSAGE_TYPE_COMBAT
			)
			organ.damage = 0
			organ.surgeryize()
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/mend/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] компоненты в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		span_warning("Вы дёргаете рукой, повреждая [tool.declent_ru(INSTRUMENTAL)] компоненты в [affected.declent_ru(PREPOSITIONAL)] [target]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	target.apply_damages(brute = 5, tox = 5, def_zone = affected)

	for(var/obj/item/organ/internal/organ as anything in affected.internal_organs)
		organ.internal_receive_damage(rand(3,5))
	return SURGERY_STEP_RETRY


/datum/surgery_step/robotics/manipulate_robotic_organs/implant
	name = "установка кибернетического органа"
	allowed_tools = list(
		/obj/item/organ/internal = 100
	)

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/organ = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!organ.is_robotic())
		user.balloon_alert(user, "орган не кибернетический!")
		return SURGERY_BEGINSTEP_SKIP

	if(target_zone != organ.parent_organ_zone || target.get_organ_slot(organ.slot))
		user.balloon_alert(user, "нет места под орган!")
		return SURGERY_BEGINSTEP_SKIP

	if(organ.damage > (organ.max_damage * 0.75))
		user.balloon_alert(user, "нет места под орган!")
		return SURGERY_BEGINSTEP_SKIP

	if(target.get_int_organ(organ) && !affected)
		user.balloon_alert(user, "этот орган уже имеется!")
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] устанавливать [tool.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
		span_notice("Вы начинаете устанавливать [tool.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	if(affected)
		target.custom_pain("Кто-то копается в ваш[genderize_ru(affected.gender, "ем", "ей", "ем", "их")] [affected.declent_ru(PREPOSITIONAL)]!")
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/internal/I = tool
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!user.can_unEquip(I))
		user.balloon_alert(user, "не получается выпустить!")
		return SURGERY_STEP_INCOMPLETE

	user.drop_from_active_hand()
	I.insert(target)
	user.visible_message(
		span_notice("[user] устанавлива[pluralize_ru(user.gender, "ет", "ют")] [I.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
		span_notice("Вы устанавливаете [I.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/implant/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, прерывая установку [tool.declent_ru(GENITIVE)]!"),
		span_warning("Вы дёргаете рукой, прерывая установку [tool.declent_ru(GENITIVE)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_RETRY


/datum/surgery_step/robotics/manipulate_robotic_organs/extract
	name = "извлечение кибернетического органа"
	allowed_tools = list(TOOL_MULTITOOL = 100)
	var/obj/item/organ/internal/I

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/list/organs = target.get_organs_zone(target_zone)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!(affected && affected.is_robotic()))
		return SURGERY_BEGINSTEP_SKIP
	if(!length(organs))
		user.balloon_alert(user, "нечего извлекать!")
		return SURGERY_BEGINSTEP_SKIP
	else
		for(var/obj/item/organ/internal/O as anything in organs)
			if(O.unremovable)
				continue
			O.on_find(user)
			organs -= O
			organs[O.name] = O

		I = tgui_input_list(user, "Выберите орган для извлечения", "Извлечения органа", organs)
		if(I && user && target && user.Adjacent(target) && user.get_active_hand() == tool)
			I = organs[I]
			if(!I)
				return SURGERY_BEGINSTEP_SKIP
			user.visible_message(
				span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] отсоединять и извлекать [I.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
				span_notice("Вы начинаете отсоединять и извлекать [I.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
				chat_message_type = MESSAGE_TYPE_COMBAT
			)

			target.custom_pain("The pain in your [affected.name] is living hell!")
		else
			return SURGERY_BEGINSTEP_SKIP

	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!I || I.owner != target)
		user.visible_message(
			span_notice("[user] доста[pluralize_ru(user.gender, "ёт", "ют")] [tool.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], ничего не извлекая."),
			span_notice("Вы достаёте [tool.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], ничего не извлекая."),,
			chat_message_type = MESSAGE_TYPE_COMBAT
		)
		return SURGERY_STEP_CONTINUE

	user.visible_message(
		span_notice("[user] отсоединя[pluralize_ru(user.gender, "ет", "ют")] и извлека[pluralize_ru(user.gender, "ет", "ют")] [I.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы отсоединяете и извлекаете [I.declent_ru(ACCUSATIVE)] из [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	add_attack_logs(user, target, "Surgically removed [I.name]. INTENT: [uppertext(user.a_intent)]")
	spread_germs_to_organ(I, user)
	var/obj/item/thing = I.remove(target)
	if(QDELETED(thing))
		return ..()
	if(!istype(thing))
		thing.forceMove(get_turf(target))
	else
		thing.forceMove(get_turf(target))
		user.put_in_hands(thing, ignore_anim = FALSE)
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/extract/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, прерывая извлечение [tool.declent_ru(GENITIVE)]!"),
		span_warning("Вы дёргаете рукой, прерывая извлечение [tool.declent_ru(GENITIVE)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	return SURGERY_STEP_RETRY


/datum/surgery_step/robotics/manipulate_robotic_organs/install_mmi
	name = "установка НКИ"
	allowed_tools = list(/obj/item/mmi = 100)

/datum/surgery_step/robotics/manipulate_robotic_organs/install_mmi/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target_zone != BODY_ZONE_CHEST)
		user.balloon_alert(user, "устанавливается в грудь!")

		return SURGERY_BEGINSTEP_SKIP

	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	var/obj/item/mmi/M = tool

	if(!affected)
		return SURGERY_BEGINSTEP_SKIP

	if(!istype(M))
		return SURGERY_BEGINSTEP_SKIP

	if(!M.brainmob || !M.brainmob.client || !M.brainmob.ckey || M.brainmob.stat >= DEAD)
		user.balloon_alert(user, "мозг неактивен!")
		return SURGERY_BEGINSTEP_SKIP

	if(!affected.is_robotic())
		user.balloon_alert(user, "часть тела не кибернетическая!")
		return SURGERY_BEGINSTEP_SKIP

	if(!target.dna.species)
		user.balloon_alert(user, "неподходящая раса!")
		return SURGERY_BEGINSTEP_SKIP

	if(!target.dna.species.has_organ["brain"])
		user.balloon_alert(user, "неподходящая раса!")
		return SURGERY_BEGINSTEP_SKIP

	if(target.get_int_organ(/obj/item/organ/internal/brain))
		user.balloon_alert(user, "цель уже имеет мозг!")
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] устанавливать [tool.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
		span_notice("Вы начинаете устанавливать [tool.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()


/datum/surgery_step/robotics/manipulate_robotic_organs/install_mmi/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
			span_notice("[user] устанавлива[pluralize_ru(user.gender, "ет", "ют")] [tool.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
			span_notice("Вы устанавливаете [tool.declent_ru(ACCUSATIVE)] в [affected.declent_ru(ACCUSATIVE)] [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	var/obj/item/mmi/M = tool

	user.drop_item_ground(tool)
	M.attempt_become_organ(affected, target)
	return ..()

/datum/surgery_step/robotics/manipulate_robotic_organs/install_mmi/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, прерывая установку [tool.declent_ru(GENITIVE)]!"),
		span_warning("Вы дёргаете рукой, прерывая установку [tool.declent_ru(GENITIVE)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_RETRY

/datum/surgery_step/robotics/external/amputate
	name = "удаление кибернетической конечности"

	allowed_tools = list(
		TOOL_MULTITOOL = 100
	)

	time = 10 SECONDS

/datum/surgery_step/robotics/external/amputate/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] отключать и отсоединять [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете отключать и отсоединять [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	return ..()

/datum/surgery_step/robotics/external/amputate/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] отключа[pluralize_ru(user.gender, "ет", "ют")] и отсоединя[pluralize_ru(user.gender, "ет", "ют")] [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы отключаете и отсоединяете [affected.declent_ru(ACCUSATIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)


	add_attack_logs(user, target, "Surgically removed [affected.name] from. INTENT: [uppertext(user.a_intent)]")//log it

	var/atom/movable/thing = affected.droplimb(1, DROPLIMB_SHARP)
	if(isitem(thing))
		thing.forceMove(get_turf(target))
		user.put_in_hands(thing, ignore_anim = FALSE)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/amputate/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, прерывая отсоединение [affected.declent_ru(GENITIVE)]!"),
		span_warning("Вы дёргаете рукой, прерывая отсоединение [affected.declent_ru(GENITIVE)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_RETRY

/datum/surgery_step/robotics/external/customize_appearance
	name = "кастомизация части тела"
	allowed_tools = list(TOOL_MULTITOOL = 100)
	time = 4.8 SECONDS

/datum/surgery_step/robotics/external/customize_appearance/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] кастомизировать внешний вид [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы начинаете кастомизировать внешний вид [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/robotics/external/customize_appearance/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/chosen_appearance = tgui_input_list(user, "Выберите компанию-производителя для части тела", "Внешний вид части тела", GLOB.selectable_robolimbs)
	if(!chosen_appearance)
		return SURGERY_STEP_INCOMPLETE
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	affected.robotize(company = chosen_appearance, convert_all = FALSE)
	if(istype(affected, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/head = affected
		head.h_style = "Bald" // nearly all the appearance changes for heads are non-monitors; we want to get rid of a floating screen
		target.update_hair()
	target.update_body()
	target.updatehealth()
	target.UpdateDamageIcon()
	user.visible_message(
		span_notice("[user] изменя[pluralize_ru(user.gender, "ет", "ют")] внешний вид [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		span_notice("Вы изменяете внешний вид [affected.declent_ru(GENITIVE)] [target], используя [tool.declent_ru(ACCUSATIVE)]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.open = ORGAN_CLOSED
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/robotics/external/customize_appearance/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] дёрга[pluralize_ru(user.gender, "ет", "ют")] рукой, прерывая кастомизацию [affected.declent_ru(GENITIVE)]!"),
		span_warning("Вы дёргаете рукой, прерывая кастомизацию [affected.declent_ru(GENITIVE)]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_RETRY
