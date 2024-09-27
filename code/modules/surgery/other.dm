//Procedures in this file: Inernal wound patching, Implant removal.
//////////////////////////////////////////////////////////////////
//					INTERNAL WOUND PATCHING						//
//////////////////////////////////////////////////////////////////

/datum/surgery/infection
	name = "External Infection Treatment"
	steps = list(/datum/surgery_step/generic/cut_open, /datum/surgery_step/generic/cauterize)
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

/datum/surgery/bleeding
	name = "Internal Bleeding"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_L_ARM,
		BODY_ZONE_PRECISE_L_HAND,
		BODY_ZONE_R_ARM,
		BODY_ZONE_PRECISE_R_HAND,
		BODY_ZONE_R_LEG,
		BODY_ZONE_PRECISE_R_FOOT,
		BODY_ZONE_L_LEG,
		BODY_ZONE_PRECISE_L_FOOT,
		BODY_ZONE_TAIL,
		BODY_ZONE_WING,
	)
	restricted_speciestypes = list(/datum/species/plasmaman)

/datum/surgery/bleeding/special
	name = "Internal Bleeding"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
	)
	restricted_speciestypes = list(/datum/species/wryn, /datum/species/kidan, /datum/species/plasmaman)

/datum/surgery/bleeding/plasmaman
	name = "Plasmaman Internal Bleeding"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ/plasma,
		/datum/surgery_step/generic/cauterize
	)
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
	target_speciestypes = list(/datum/species/plasmaman)
	restricted_speciestypes = null

/datum/surgery/bleeding/insect
	name = "Insectoid Internal Bleeding"
	steps = list(
		/datum/surgery_step/open_encased/saw,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/ib,
		/datum/surgery_step/glue_bone,
		/datum/surgery_step/set_bone,
		/datum/surgery_step/finish_bone,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
		BODY_ZONE_PRECISE_GROIN,
	)
	target_speciestypes = list(/datum/species/wryn, /datum/species/kidan)
	restricted_speciestypes = null

/datum/surgery/debridement
	name = "Debridement"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/proxy/open_organ,
		/datum/surgery_step/fix_dead_tissue,
		/datum/surgery_step/treat_necrosis,
		/datum/surgery_step/generic/cauterize
	)
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
	requires_organic_bodypart = TRUE

/datum/surgery/bleeding/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(affected.has_internal_bleeding())
		return TRUE
	return FALSE


/datum/surgery/debridement/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!affected.is_dead())
		return FALSE
	return TRUE


/datum/surgery_step/fix_vein
	name = "mend internal bleeding"
	begin_sound = 'sound/surgery/fixovein1.ogg'
	end_sound = 'sound/surgery/hemostat1.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_FIXOVEIN = 100,
		/obj/item/stack/cable_coil = 90,
		/obj/item/stack/sheet/sinew = 90
	)
	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 3.2 SECONDS

/datum/surgery_step/fix_vein/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	if(!affected.has_internal_bleeding())
		to_chat(user, span_notice("The veins in [affected] seem to be in perfect shape!"))
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		"[user] starts patching the damaged vein in [target]'s [affected.name] with \the [tool].",
		"You start patching the damaged vein in [target]'s [affected.name] with \the [tool].",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("The pain in your [affected.name] is unbearable!")
	return ..()


/datum/surgery_step/fix_vein/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] has patched the damaged vein in [target]'s [affected.name] with \the [tool]."),
		span_notice("You have patched the damaged vein in [target]'s [affected.name] with \the [tool]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	affected.stop_internal_bleeding()
	if(ishuman(user) && prob(40))
		var/mob/living/carbon/human/U = user
		U.bloody_hands(target, 0)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/fix_vein/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user]'s hand slips, smearing [tool] in the incision in [target]'s [affected.name]!"),
		span_warning("Your hand slips, smearing [tool] in the incision in [target]'s [affected.name]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(5, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/fix_dead_tissue		//Debridement
	name = "remove dead tissue"
	begin_sound = 'sound/surgery/scalpel1.ogg'
	end_sound = 'sound/surgery/scalpel2.ogg'
	fail_sound = 'sound/effects/meatslap.ogg'
	allowed_tools = list(
		TOOL_SCALPEL = 100,
		/obj/item/kitchen/knife = 90,
		/obj/item/shard = 60
	)

	can_infect = TRUE
	blood_level = SURGERY_BLOODSPREAD_HANDS

	time = 1.6 SECONDS

/datum/surgery_step/fix_dead_tissue/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		"[user] starts cutting away necrotic tissue in [target]'s [affected.name] with \the [tool].",
		"You start cutting away necrotic tissue in [target]'s [affected.name] with \the [tool].",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("The pain in [affected.name] is unbearable!")
	return ..()

/datum/surgery_step/fix_dead_tissue/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_notice("[user] has cut away necrotic tissue in [target]'s [affected.name] with \the [tool]."),
		span_notice("You have cut away necrotic tissue in [target]'s [affected.name] with \the [tool]."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	affected.open = ORGAN_ORGANIC_OPEN

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/fix_dead_tissue/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)
	user.visible_message(
		span_warning("[user]'s hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!"),
		span_warning("Your hand slips, slicing an artery inside [target]'s [affected.name] with \the [tool]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.apply_damage(20, def_zone = affected)
	return SURGERY_STEP_RETRY

/datum/surgery_step/treat_necrosis
	name = "treat necrosis"
	allowed_tools = list(
		/obj/item/reagent_containers/dropper = 100,
		/obj/item/reagent_containers/glass/bottle = 90,
		/obj/item/reagent_containers/food/drinks/drinkingglass = 85,
		/obj/item/reagent_containers/food/drinks/bottle = 80,
		/obj/item/reagent_containers/glass/beaker = 75,
		/obj/item/reagent_containers/spray = 60,
		/obj/item/reagent_containers/glass/bucket = 50
	)

	can_infect = FALSE
	blood_level = SURGERY_BLOODSPREAD_NONE

	time = 2.4 SECONDS


/datum/surgery_step/treat_necrosis/tool_check(mob/user, obj/item/tool)
	. = ..()
	if(!.)
		return FALSE
	var/obj/item/reagent_containers/container = tool
	if(!container.reagents.has_reagent("mitocholide"))
		user.visible_message(
			"[user] looks at \the [tool] and ponders.",
			"You are not sure if \the [tool] contains the mitocholide necessary to treat the necrosis.",
			chat_message_type = MESSAGE_TYPE_COMBAT
			)
		return FALSE

/datum/surgery_step/treat_necrosis/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)

	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!(affected.is_dead()))
		to_chat(user, span_warning("The [affected] seems to already be in fine condition!"))
		return SURGERY_BEGINSTEP_SKIP

	user.visible_message(
		"[user] starts applying medication to the affected tissue in [target]'s [affected.name] with \the [tool].",
		"You start applying medication to the affected tissue in [target]'s [affected.name] with \the [tool].",
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	target.custom_pain("Something in your [affected.name] is causing you a lot of pain!")
	return ..()

/datum/surgery_step/treat_necrosis/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	var/obj/item/reagent_containers/container = tool
	var/mitocholide = FALSE

	if(container.reagents.has_reagent("mitocholide"))
		mitocholide = TRUE

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	if(trans > 0)
		container.reagents.reaction(target, REAGENT_INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

		if(mitocholide)
			affected.unnecrotize()

		user.visible_message(
			span_notice("[user] applies [trans] units of the solution to affected tissue in [target]'s [affected.name]"),
			span_notice("You apply [trans] units of the solution to affected tissue in [target]'s [affected.name] with \the [tool]."),
			chat_message_type = MESSAGE_TYPE_COMBAT
		)

	return SURGERY_STEP_CONTINUE

/datum/surgery_step/treat_necrosis/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/organ/external/affected = target.get_organ(target_zone)

	if(!istype(tool, /obj/item/reagent_containers))
		return SURGERY_STEP_INCOMPLETE

	var/obj/item/reagent_containers/container = tool

	var/trans = container.reagents.trans_to(target, container.amount_per_transfer_from_this)
	container.reagents.reaction(target, REAGENT_INGEST)	//technically it's contact, but the reagents are being applied to internal tissue

	user.visible_message(
		span_warning("[user]'s hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!"),
		span_warning("Your hand slips, applying [trans] units of the solution to the wrong place in [target]'s [affected.name] with the [tool]!"),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)

	//no damage or anything, just wastes medicine
	return SURGERY_STEP_RETRY

//////////////////////////////////////////////////////////////////
//					Dethrall Shadowling 						//
//////////////////////////////////////////////////////////////////
/datum/surgery/remove_thrall
	name = "Remove Shadow Tumor"
	steps = list(
		/datum/surgery_step/generic/cut_open,
		/datum/surgery_step/generic/clamp_bleeders,
		/datum/surgery_step/generic/retract_skin,
		/datum/surgery_step/internal/dethrall,
		/datum/surgery_step/generic/cauterize
	)
	possible_locs = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_PRECISE_GROIN,
	)
	requires_organic_bodypart = TRUE

/datum/surgery/remove_thrall/synth
	name = "Debug Shadow Tumor"
	steps = list(
		/datum/surgery_step/robotics/external/unscrew_hatch,
		/datum/surgery_step/robotics/external/open_hatch,
		/datum/surgery_step/internal/dethrall,
		/datum/surgery_step/robotics/external/close_hatch
	)
	requires_organic_bodypart = FALSE
	possible_locs = list(
		BODY_ZONE_HEAD,
		BODY_ZONE_CHEST,
		BODY_ZONE_PRECISE_GROIN,
	)

/datum/surgery/remove_thrall/can_start(mob/user, mob/living/carbon/human/target)
	. = ..()
	if(!.)
		return FALSE
	if(!is_thrall(target))
		return FALSE
	var/obj/item/organ/internal/brain/B = target.get_int_organ(/obj/item/organ/internal/brain)
	var/obj/item/organ/external/affected = target.get_organ(user.zone_selected)
	if(!B)
		// No brain to remove the tumor from
		return FALSE
	if(!LAZYIN(affected.internal_organs, B))
		return FALSE
	return TRUE


/datum/surgery_step/internal/dethrall
	name = "cleanse contamination"
	begin_sound = 'sound/items/lighter/light.ogg'
	allowed_tools = list(/obj/item/flash = 100, /obj/item/flashlight/pen = 80, /obj/item/flashlight = 40)
	blood_level = SURGERY_BLOODSPREAD_NONE
	time = 3 SECONDS

/datum/surgery_step/internal/dethrall/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	var/obj/item/organ/internal/brain = target.get_organ_slot(INTERNAL_ORGAN_BRAIN)
	user.visible_message(
		"[user] reaches into [target]'s head with [tool].",
		span_notice("You begin aligning [tool]'s light to the tumor on [target]'s brain..."),
		chat_message_type = MESSAGE_TYPE_COMBAT
	)
	to_chat(target, span_boldannounceic("A small part of your [brain.parent_organ_zone] pulses with agony as the light impacts it."))
	return ..()

/datum/surgery_step/internal/dethrall/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool,datum/surgery/surgery)
	if(isshadowlinglesser(target)) //Empowered thralls cannot be deconverted
		to_chat(target, span_shadowling("<b><i>NOT LIKE THIS!</i></b>"))
		user.visible_message(span_warning("[target] suddenly slams upward and knocks down [user]!"), \
							 span_userdanger("[target] suddenly bolts up and slams you with tremendous force!"),
							 chat_message_type = MESSAGE_TYPE_COMBAT)
		user.SetSleeping(0)
		user.SetStunned(0)
		user.SetWeakened(0)
		user.SetKnockdown(0)
		user.SetParalysis(0)
		user.set_resting(FALSE, instant = TRUE)
		user.get_up(instant = TRUE)
		if(iscarbon(user))
			var/mob/living/carbon/C = user
			C.Weaken(12 SECONDS)
			C.apply_damage(20, BRUTE, BODY_ZONE_CHEST)
		else if(issilicon(user))
			var/mob/living/silicon/S = user
			S.Weaken(16 SECONDS)
			S.apply_damage(20, BRUTE)
			playsound(S, 'sound/effects/bang.ogg', 50, 1)
		return SURGERY_STEP_INCOMPLETE
	var/obj/item/organ/internal/brain/B = target.get_int_organ(/obj/item/organ/internal/brain)
	var/obj/item/organ/external/E = target.get_organ(check_zone(B.parent_organ_zone))
	user.visible_message("[user] shines light onto the tumor in [target]'s [E]!", span_notice("You cleanse the contamination from [target]'s brain!"), chat_message_type = MESSAGE_TYPE_COMBAT)
	if(target.vision_type) //Turns off their darksight if it's still active.
		to_chat(target, span_boldannounceic("Your eyes are suddenly wrought with immense pain as your darksight is forcibly dismissed!"))
		target.set_vision_override(null)
	SSticker.mode.remove_thrall(target.mind, 0)
	target.visible_message(span_warning("A strange black mass falls from [target]'s [E]!"))
	var/obj/item/organ/thing = new /obj/item/organ/internal/shadowtumor(get_turf(target))
	thing.update_DNA(target.dna)
	user.put_in_hands(thing, ignore_anim = FALSE)
	return SURGERY_STEP_CONTINUE

