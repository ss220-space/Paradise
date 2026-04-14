/mob/proc/make_interaction()
	return

/mob/living/carbon/human/make_interaction()
	ui_interact(usr)

/mob/living/carbon/human/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "InteractionMenu", "Взаимодействие")
		ui.open()

/mob/living/carbon/human/ui_act(action, list/params)
	if(..())
		return
	var/list/href_list = list("interaction" = action)
	Topic(null, href_list)
	return TRUE

/mob/living/carbon/human/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/carbon/human/human_user = user
	var/mob/living/carbon/human/human_partner = human_user.partner

	if(!human_partner)
		return data

	data["target_name"] = human_partner.name
	data["is_adjacent"] = human_user.Adjacent(human_partner)

	var/obj/item/organ/external/right_hand = human_user.bodyparts_by_name[BODY_ZONE_PRECISE_R_HAND]
	var/obj/item/organ/external/left_hand = human_user.bodyparts_by_name[BODY_ZONE_PRECISE_L_HAND]
	data["has_usable_hands"] = (right_hand?.is_usable() || left_hand?.is_usable())

	var/obj/item/organ/external/target_right_hand = human_partner.bodyparts_by_name[BODY_ZONE_PRECISE_R_HAND]
	var/obj/item/organ/external/target_left_hand = human_partner.bodyparts_by_name[BODY_ZONE_PRECISE_L_HAND]
	data["target_has_usable_hands"] = (target_right_hand?.is_usable() || target_left_hand?.is_usable())

	var/user_mouth_covered = (human_user.head?.flags_cover & HEADCOVERSMOUTH) || (human_user.wear_mask?.flags_cover & MASKCOVERSMOUTH)
	data["can_use_mouth"] = !user_mouth_covered && (human_user.dna?.species?.name != SPECIES_DIONA)

	var/target_mouth_covered = (human_partner.head?.flags_cover & HEADCOVERSMOUTH) || (human_partner.wear_mask?.flags_cover & MASKCOVERSMOUTH)
	data["target_mouth_free"] = !target_mouth_covered

	data["has_wings"] = !!human_partner.get_organ(BODY_ZONE_WING)
	data["has_tail"] = !!human_partner.get_organ(BODY_ZONE_TAIL)
	data["can_pet_target"] = human_partner.can_inject(human_user, target_zone = human_user.zone_selected, silent = TRUE)

	if(human_user.dna?.species)
		data["can_bite"] = human_user.dna.species.can_bite
	else
		data["can_bite"] = FALSE

	return data

/mob/living/carbon/human/verb/interact(mob/living/carbon/human/target_mob as mob)
	set name = "Взаимодействовать"
	set category = VERB_CATEGORY_IC

	if(ishuman(target_mob) && usr != target_mob)
		partner = target_mob
		make_interaction()

/mob/living/carbon/human/mouse_drop_dragged(atom/over_object, mob/user, src_location, over_location, params)
	if(src == usr && ishuman(over_object))
		interact(over_object)
	else
		return ..()
