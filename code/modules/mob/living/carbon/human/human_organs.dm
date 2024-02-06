/mob/living/carbon/human
	/// All external organs in src.
	var/list/bodyparts = list()
	/// Map organ zones to external organs.
	var/list/bodyparts_by_name = list()


/mob/living/carbon/human/proc/update_eyes()
	var/obj/item/organ/internal/eyes/eyes = get_int_organ(/obj/item/organ/internal/eyes)
	if(eyes)
		eyes.update_colour()
		update_body()


// Takes care of organ related updates, such as broken and missing limbs
/mob/living/carbon/human/handle_organs()
	..()
	//processing internal organs is pretty cheap, do that first.
	for(var/obj/item/organ/internal/organ as anything in internal_organs)
		organ.process()

	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		bodypart.process()

		if(!lying && world.time - l_move_time < 15)	//Moving around with fractured ribs won't do you any good
			if(bodypart.is_traumatized() && prob(15))
				if(LAZYLEN(bodypart.internal_organs))
					var/obj/item/organ/internal/organ = pick(bodypart.internal_organs)
					organ.receive_damage(rand(3,5))
				custom_pain("Вы чувствуете как в вашей [bodypart.declent_ru(PREPOSITIONAL)] двигаются сломанные кости!")

	handle_grasp()
	handle_stance()


/mob/living/carbon/human/proc/handle_stance()
	// Don't need to process any of this if they aren't standing anyways
	// unless their stance is damaged, and we want to check if they should stay down
	if(!stance_damage && (lying || resting) && (life_tick % 4) == 0)
		return

	stance_damage = 0

	// Buckled to a bed/chair. Stance damage is forced to 0 since they're sitting on something solid
	// Not standing, so no need to care about stance
	if(istype(buckled, /obj/structure/chair) || !isturf(loc))
		return

	for(var/limb_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_PRECISE_L_FOOT, BODY_ZONE_PRECISE_R_FOOT))
		var/obj/item/organ/external/bodypart = bodyparts_by_name[limb_zone]
		if(!bodypart || bodypart.is_dead() || bodypart.is_malfunctioning())
			stance_damage += 2 // let it fail even if just foot&leg. Also malfunctioning happens sporadically so it should impact more when it procs
		else if(bodypart.is_traumatized() || !bodypart.is_usable())
			stance_damage += 1

	// Canes and crutches help you stand (if the latter is ever added)
	// One cane mitigates a broken leg+foot, or a missing foot.
	// Two canes are needed for a lost leg. If you are missing both legs, canes aren't gonna help you.
	if(l_hand && l_hand.is_crutch())
		stance_damage -= 2
	if(r_hand && r_hand.is_crutch())
		stance_damage -= 2

	if(stance_damage < 0)
		stance_damage = 0

	// standing is poor
	if(stance_damage >= 8)
		if(!(lying || resting))
			if(has_pain())
				emote("scream")
			emote("collapses", ignore_cooldowns = TRUE)


/mob/living/carbon/human/proc/handle_grasp()

	if(!l_hand && !r_hand)
		return

	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(!bodypart.can_grasp || bodypart.is_splinted())
			continue

		if(bodypart.is_traumatized())
			if(bodypart.limb_zone == BODY_ZONE_L_ARM || bodypart.limb_zone == BODY_ZONE_PRECISE_L_HAND)
				if(!l_hand)
					continue
				if(!drop_item_ground(l_hand))
					continue
			else
				if(!r_hand)
					continue
				if(!drop_item_ground(r_hand))
					continue

			var/emote_scream = pick("крич[pluralize_ru(gender,"ит","ат")] от боли и ", "изда[pluralize_ru(gender,"ёт","ют")] резкий крик и ", "вскрикива[pluralize_ru(gender,"ет","ют")] и ")
			custom_emote(EMOTE_VISIBLE, "[(has_pain()) ? emote_scream :  "" ]броса[pluralize_ru(gender,"ет","ют")] предмет, который держал[genderize_ru(gender,"","а","о","и")] в [bodypart.declent_ru(PREPOSITIONAL)]!")

		else if(bodypart.is_malfunctioning())

			if(bodypart.limb_zone == BODY_ZONE_L_ARM || bodypart.limb_zone == BODY_ZONE_PRECISE_L_HAND)
				if(!l_hand)
					continue
				if(!drop_item_ground(l_hand))
					continue
			else
				if(!r_hand)
					continue
				if(!drop_item_ground(r_hand))
					continue

			custom_emote(EMOTE_VISIBLE, "броса[pluralize_ru(gender,"ет","ют")] предмет, который держал[genderize_ru(gender,"","а","о","и")] держали, [genderize_ru(gender,"его","её","его","их")] [bodypart.declent_ru(NOMINATIVE)] выход[pluralize_ru(bodypart.gender,"ит","ят")] из строя!")

			do_sparks(5, FALSE, src)


/mob/living/carbon/human/handle_germs()
	..()
	if(gloves && germ_level > gloves.germ_level && prob(10))
		gloves.germ_level += 1


/mob/living/carbon/human/proc/becomeSlim()
	to_chat(src, span_notice("[pluralize_ru(src.gender,"Ты","Вы")] снова чувствуе[pluralize_ru(src.gender,"шь","те")] себя в форме!"))
	mutations.Remove(FAT)


/mob/living/carbon/human/proc/becomeFat()
	to_chat(src, span_alert("[pluralize_ru(src.gender,"Ты","Вы")] вдруг чувствуе[pluralize_ru(src.gender,"шь","те")] себя пухлым!"))
	mutations.Add(FAT)


/**
 * Handles chem traces
 */
/mob/living/carbon/human/proc/handle_trace_chems()
	//New are added for reagents to random organs.
	for(var/datum/reagent/reagent in reagents.reagent_list)
		var/obj/item/organ/external/bodypart = safepick(bodyparts)
		if(bodypart)
			LAZYSET(bodypart.trace_chemicals, reagent.name, 100)


/**
 * Sync internal and exteranl organs with DNA unique enzymes.
 *
 * Arguments:
 * * assimilate - If `TRUE`, organs that have a different UE will still have their DNA overriden by that of the host. Otherwise, this restricts itself to organs that share the UE of the host.
 * * old_ue - Set this to a UE string, and this proc will overwrite the dna of organs that have that UE, instead of the host's present UE.
 */
/mob/living/carbon/human/proc/sync_organ_dna(assimilate = TRUE, old_ue = null)
	var/ue_to_compare = (old_ue) ? old_ue : dna.unique_enzymes
	var/list/all_bits = internal_organs|bodyparts
	for(var/obj/item/organ/organ as anything in all_bits)
		if(assimilate || organ.dna?.unique_enzymes == ue_to_compare)
			organ.update_DNA(dna)


/mob/living/carbon/human/has_organic_damage()
	var/total_dmg = 0
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(bodypart.is_robotic())
			total_dmg += bodypart.brute_dam
			total_dmg += bodypart.burn_dam
	return (health < (100 - total_dmg))


/mob/living/carbon/human/proc/count_infected_organs()
	. = 0
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		for(var/obj/item/organ/internal/organ as anything in bodypart.internal_organs)
			if(organ.germ_level >= INFECTION_LEVEL_ONE)
				.++
		if(bodypart.germ_level >= INFECTION_LEVEL_ONE)
			.++


/**
 * Returns a list with all fractured bodyparts.
 */
/mob/living/carbon/human/proc/check_fractures()
	var/list/fractured_bodyparts = list()
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(bodypart.has_fracture())
			fractured_bodyparts += bodypart
	return fractured_bodyparts


/**
 * Returns a list with all bodyparts affected by internal bleeding.
 */
/mob/living/carbon/human/proc/check_internal_bleedings()
	var/list/bleeding_bodyparts = list()
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(bodypart.has_internal_bleeding())
			bleeding_bodyparts += bodypart
	return bleeding_bodyparts


/mob/living/carbon/human/proc/update_splints()
	for(var/obj/item/organ/external/bodypart as anything in splinted_limbs)
		if(step_count >= bodypart.splinted_count + SPLINT_LIFE)
			bodypart.remove_splint(splint_break = TRUE)	// oh no, we actually need surgery now!


/mob/living/carbon/human/proc/embed_item_inside(obj/item/thing, embedded_zone, silent = FALSE)
	if(isliving(thing.loc))
		var/mob/living/holder = thing.loc
		holder.drop_item_ground(thing)

	if(embedded_zone && !get_organ(embedded_zone))
		embedded_zone = BODY_ZONE_CHEST

	var/obj/item/organ/external/bodypart = embedded_zone ? embedded_zone : safepick(bodyparts)
	if(!bodypart)
		return FALSE

	bodypart.add_embedded_object(thing)
	thing.add_mob_blood(src)	// it embedded itself in you, of course it's bloody!
	bodypart.receive_damage(thing.w_class * thing.embedded_impact_pain_multiplier, silent = silent)
	if(!silent)
		visible_message(
			span_danger("[thing] embeds itself in [src]'s [bodypart.name]!"),
			span_userdanger("[thing] embeds itself in your [bodypart.name]!"),
		)
	return TRUE


/mob/living/carbon/human/proc/remove_embedded_object(obj/item/thing, atom/drop_loc, clear_alert = TRUE)
	var/obj/item/organ/external/bodypart = thing.loc
	if(!istype(bodypart))
		return FALSE
	return bodypart.remove_embedded_object(thing, drop_loc, clear_alert)


/mob/living/carbon/human/proc/remove_all_embedded_objects(atom/drop_loc)
	var/counter = 0
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		counter += bodypart.remove_all_embedded_objects(drop_loc, clear_alert = FALSE)
	clear_alert("embeddedobject")
	return counter


/mob/living/carbon/human/proc/has_embedded_objects()
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(LAZYLEN(bodypart.embedded_objects))
			return TRUE
	return FALSE


/mob/living/carbon/human/proc/check_limbs_with_embedded_objects()
	var/list/bodyparts_with_embedded = list()
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		if(LAZYLEN(bodypart.embedded_objects))
			bodyparts_with_embedded += bodypart
	return bodyparts_with_embedded


/mob/living/carbon/human/proc/check_embedded_objects()
	var/list/embedded_items = list()
	for(var/obj/item/organ/external/bodypart as anything in bodyparts)
		for(var/obj/item/thing as anything in bodypart.embedded_objects)
			embedded_items += thing
	return embedded_items

