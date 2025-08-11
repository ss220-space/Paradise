/datum/surgery/dental_implant
	name = "Зубное имплантирование"
	steps = list(/datum/surgery_step/generic/drill, /datum/surgery_step/insert_pill)
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)

/datum/surgery/dental_implant/can_start(mob/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!target.check_has_mouth())
		return FALSE

/datum/surgery_step/insert_pill
	name = "вставить таблетку"
	allowed_tools = list(/obj/item/reagent_containers/food/pill = 100)
	time = 1.6 SECONDS

/datum/surgery_step/insert_pill/begin_step(mob/living/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] вставлять [tool.declent_ru(ACCUSATIVE)] в ротовую полость [target]."),
		span_notice("Вы начинаете вставлять [tool.declent_ru(ACCUSATIVE)] в ротовую полость [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return ..()

/datum/surgery_step/insert_pill/end_step(mob/living/user, mob/living/carbon/target, target_zone, var/obj/item/reagent_containers/food/pill/tool, datum/surgery/surgery)
	if(!istype(tool))
		return SURGERY_STEP_INCOMPLETE

	var/dental_implants = 0
	for(var/obj/item/reagent_containers/food/pill in target.contents) // Can't give them more than 4 dental implants.
		dental_implants++
	if(dental_implants >= 4)
		user.visible_message(
			span_notice("[user] доста[pluralize_ru(user.gender, "ёт", "ют")] [tool.declent_ru(ACCUSATIVE)] обратно из ротовой полости [target]."),
			span_notice("Вы достаёте [tool.declent_ru(ACCUSATIVE)] обратно из ротовой полости [target] – некуда вставлять.")
		)
		return SURGERY_STEP_INCOMPLETE

	user.drop_transfer_item_to_loc(tool, target)

	var/datum/action/item_action/hands_free/activate_pill/P = new(tool, tool.icon, tool.icon_state)
	P.name = "Раскусить [tool.declent_ru(ACCUSATIVE)]"
	P.Grant(target)

	user.visible_message(
		span_notice("[user] вставля[pluralize_ru(user.gender, "ет", "ют")] [tool.declent_ru(ACCUSATIVE)] в ротовую полость [target]."),
		span_notice("Вы вставляете [tool.declent_ru(ACCUSATIVE)] в ротовую полость [target]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	return SURGERY_STEP_CONTINUE

/datum/action/item_action/hands_free/activate_pill
	name = "Раскусить таблетку"

/datum/action/item_action/hands_free/activate_pill/Trigger(left_click = TRUE)
	if(!..())
		return
	to_chat(owner, span_warning("Вы сжимаете зубы и раскусываете [target.declent_ru(ACCUSATIVE)]!"))
	add_attack_logs(owner, owner, "Swallowed implanted [target]")
	if(target.reagents.total_volume)
		target.reagents.reaction(owner, REAGENT_INGEST)
		target.reagents.trans_to(owner, target.reagents.total_volume)
	Remove(owner)
	qdel(target)
	return 1
