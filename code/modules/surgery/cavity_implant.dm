/datum/surgery/cavity_implant
	name = "Cavity Implant/Removal"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // just do IB here since we're sawing the bone anyway
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/open_encased/close,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	restricted_speciestypes = list(/datum/species/kidan, /datum/species/wryn, /datum/species/plasmaman)


/datum/surgery/cavity_implant/soft
	name = "Cavity Implant/Removal"
	desc = "Implant an object into a cavity not protected by bone."
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // just do IB here since we're sawing the bone anyway
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/generic/cauterize
	)

	possible_locs = list(BODY_ZONE_PRECISE_GROIN)

/datum/surgery/cavity_implant/insect
	name = "Insectoid Cavity Implant/Removal"
	steps = list(
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/proxy/ib,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/open_encased/close,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	target_speciestypes = list(/datum/species/kidan, /datum/species/wryn)
	restricted_speciestypes = null
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
	)

/datum/surgery/cavity_implant/plasmaman
	name = "Plasmaman Cavity Implant/Removal"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // just do IB here since we're sawing the bone anyway
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/open_encased/retract,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/open_encased/close,
		/datum/surgery_step/glue_bone/plasma,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	target_speciestypes = list(/datum/species/plasmaman)
	restricted_speciestypes = null

/datum/surgery/cavity_implant/plasmaman/soft
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,  // just do IB here since we're sawing the bone anyway
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/cavity/make_space,
		/datum/surgery_step/proxy/cavity_manipulation,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(BODY_ZONE_PRECISE_GROIN)

/datum/surgery/cavity_implant/synth
	name = "Robotic Cavity Implant/Removal"
	requires_organic_bodypart = FALSE
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/proxy/cavity_manipulation/robotic,
		/datum/surgery_step/cavity/close_space,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
	)

/datum/surgery/cavity_implant/synth
	name = "Robotic Cavity Implant/Removal"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/proxy/cavity_manipulation/robotic,
		/datum/surgery_step/robotics/external/close_hatch
	)
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN)
	requires_organic_bodypart = FALSE

/datum/surgery_step/proxy/cavity_manipulation
	name = "Cavity Manipulation (proxy)"
	branches = list(
		/datum/surgery/intermediate/open_cavity/implant,
		/datum/surgery/intermediate/open_cavity/extract,
		/datum/surgery/intermediate/bleeding
	)

	insert_self_after = TRUE

/datum/surgery_step/proxy/cavity_manipulation/robotic
	name = "Robotic Cavity Manipulation (proxy)"
	branches = list(
		/datum/surgery/intermediate/open_cavity/implant/robotic,
		/datum/surgery/intermediate/open_cavity/extract/robotic
	)

/datum/surgery/intermediate/open_cavity
	possible_locs = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_PRECISE_GROIN)

/datum/surgery/intermediate/open_cavity/implant
	name = "implant object"
	steps = list(
		/datum/surgery_step/cavity/place_item
	)

/datum/surgery/intermediate/open_cavity/extract
	name = "extract object"
	steps = list(
		/datum/surgery_step/cavity/remove_item
	)

/datum/surgery/intermediate/open_cavity/implant/robotic
	requires_organic_bodypart = FALSE

/datum/surgery/intermediate/open_cavity/extract/robotic
	requires_organic_bodypart = FALSE

/datum/surgery_step/cavity/proc/get_max_wclass(obj/item/organ/external/affected)
	switch(affected.limb_zone)
		if(BODY_ZONE_HEAD)
			return WEIGHT_CLASS_TINY
		if(BODY_ZONE_CHEST)
			return WEIGHT_CLASS_NORMAL
		if(BODY_ZONE_PRECISE_GROIN)
			return WEIGHT_CLASS_SMALL
	return 0

/datum/surgery_step/cavity/proc/get_cavity(obj/item/organ/external/affected)
	switch(affected.limb_zone)
		if(BODY_ZONE_HEAD)
			return "cranial"
		if(BODY_ZONE_CHEST)
			return "thoracic"
		if(BODY_ZONE_PRECISE_GROIN)
			return "abdominal"
	return ""

/datum/surgery_step/cavity/proc/get_item_inside(obj/item/organ/external/affected)
	var/obj/item/extracting
	for(var/obj/item/I in affected.contents)
		if(!istype(I, /obj/item/organ))
			extracting = I
			break

	if(!extracting && affected.hidden)
		extracting = affected.hidden

	return extracting

/datum/surgery_step/cavity/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user]'s hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!"),
		span_warning("Your hand slips, scraping around inside [target]'s [affected.name] with \the [tool]!")
	)
	target.apply_damage(20, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/cavity/make_space
	name = "make cavity space"
	begin_sound = 'sound/surgery/surgicaldrill.ogg'
	allowed_tools = list(
		TOOL_DRILL = 100,
		/obj/item/screwdriver/power = 90,
		/obj/item/pen = 90,
		/obj/item/stack/rods = 60
	)

	time = 5.4 SECONDS

/datum/surgery_step/cavity/make_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].",
		"You start making some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]."
	)
	target.custom_pain("The pain in your chest is living hell!")
	return ..()

/datum/surgery_step/cavity/make_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice(" [user] makes some space inside [target]'s [get_cavity(affected)] cavity with \the [tool]."),
		span_notice(" You make some space inside [target]'s [get_cavity(affected)] cavity with \the [tool].")
	)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/cavity/close_space
	name = "close cavity space"
	begin_sound = 'sound/surgery/cautery2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		/obj/item/scalpel/laser = 100,
		TOOL_CAUTERY = 100,
		/obj/item/clothing/mask/cigarette = 90,
		/obj/item/lighter = 60,
		TOOL_WELDER = 30
	)

	time = 2.4 SECONDS

/datum/surgery_step/cavity/close_space/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts mending [target]'s [get_cavity(affected)] cavity wall with \the [tool].",
		"You start mending [target]'s [get_cavity(affected)] cavity wall with \the [tool]."
	)
	target.custom_pain("The pain in your chest is living hell!")
	return ..()

/datum/surgery_step/cavity/close_space/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice(" [user] mends [target]'s [get_cavity(affected)] cavity walls with \the [tool]."),
		span_notice(" You mend [target]'s [get_cavity(affected)] cavity walls with \the [tool].")
	)

	return SURGERY_STEP_CONTINUE


/datum/surgery_step/cavity/remove_item
	name = "extract object"
	begin_sound = 'sound/surgery/organ2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	accept_hand = TRUE

/datum/surgery_step/cavity/remove_item/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	// Check even if there isn't anything inside
	user.visible_message(
		"[user] checks for items in [target]'s [target_zone].",
		span_notice("You check for items in [target]'s [target_zone]...")
	)
	return ..()

/datum/surgery_step/cavity/remove_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/extracting
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	for(var/obj/item/I in affected.contents)
		if(!istype(I, /obj/item/organ))
			extracting = I
			break

	if(!extracting && affected.hidden)
		extracting = affected.hidden

	if(!extracting)
		to_chat(user, span_warning("You don't find anything in [target]'s [target_zone]."))
		return SURGERY_STEP_CONTINUE
	user.visible_message(
		span_notice("[user] pulls [extracting] out of [target]'s [target_zone]!"),
		span_notice("You pull [extracting] out of [target]'s [target_zone].")
	)
	user.put_in_hands(extracting, ignore_anim = FALSE)
	affected.hidden = null
	return SURGERY_STEP_CONTINUE

/datum/surgery_step/cavity/remove_item/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user] grabs onto something else by mistake, damaging it!."),
		span_warning("You grab onto something else inside [target]'s [get_cavity(affected)] cavity by mistake, damaging it!")
	)
	target.apply_damage(rand(3,7), def_zone = affected)

	return SURGERY_STEP_INCOMPLETE

/datum/surgery_step/cavity/place_item
	name = "implant object"
	begin_sound = 'sound/surgery/organ1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	accept_any_item = TRUE

	time = 3.2 SECONDS


/datum/surgery_step/cavity/place_item/tool_check(mob/user, obj/item/tool)
	if(istype(tool, /obj/item/disk/nuclear))
		to_chat(user, span_warning("Central command would kill you if you implanted the disk into someone."))
		return FALSE

	var/obj/item/disk/nuclear/datdisk = locate() in tool
	if(datdisk)
		to_chat(user, span_warning("Central Command would kill you if you implanted the disk into someone. Especially if in a [tool]."))
		return FALSE

	if(istype(tool, /obj/item/organ))
		to_chat(user, span_warning("This isn't the type of surgery for organ transplants!"))
		return FALSE

	if(!user.can_unEquip(tool))
		to_chat(user, span_warning("[tool] is stuck to your hand!"))
		return FALSE

	if(istype(tool, /obj/item/cautery))
		// Pass it to the next step
		return FALSE

	return TRUE


/datum/surgery_step/cavity/place_item/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/can_fit = !affected.hidden && tool.w_class <= get_max_wclass(affected)
	if(!can_fit)
		to_chat(user, span_warning("\The [tool] won't fit in \the [affected]!"))
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		"[user] starts putting \the [tool] inside [target]'s [get_cavity(affected)] cavity.",
		"You start putting \the [tool] inside [target]'s [get_cavity(affected)] cavity."
	)
	target.custom_pain("The pain in your [target_zone] is living hell!")
	return ..()

/datum/surgery_step/cavity/place_item/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/chest/affected = target.get_organ(target_zone)
	if(get_item_inside(affected))
		to_chat(user, span_notice("There seems to be something in there already!"))
		return SURGERY_STEP_CONTINUE

	user.visible_message(
		span_notice("[user] puts \the [tool] inside [target]'s [get_cavity(affected)] cavity."),
		span_notice("You put \the [tool] inside [target]'s [get_cavity(affected)] cavity.")
	)
	if((tool.w_class > get_max_wclass(affected) / 2 && prob(50) && !affected.is_robotic()))
		user.visible_message(
			span_warning("[user] tears some blood vessels trying to fit the object in the cavity!"),
			span_danger("You tear some blood vessels trying to fit the object into the cavity!"),
			span_warning("You hear some gentle tearing."))
		affected.internal_bleeding()
	user.drop_transfer_item_to_loc(tool, target)
	affected.hidden = tool
	return SURGERY_STEP_CONTINUE
