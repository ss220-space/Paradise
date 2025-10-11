/**
 * # Stack item heal element
 *
 * This element allows the carbon mob to get healed, or heal themselves, using specific stack items.
 * Doesn't handle subtypes of stack items, that don't have the same merge_type as passed type.
 * Also shows that we can heal using some material on self examine.
 * Healing is identical to gauze/ointment.
 */
/datum/element/material_heal
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY|ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// What materials do we heal from
	var/list/material_list
	/// How much of the material does it take to heal
	var/material_amount
	/// How much do we heal from said material
	var/heal_amount
	/// How long does it take to heal ourselves
	var/heal_delay

	/// Cached string for on_self_examine proc
	var/cached_materials_str

/datum/element/material_heal/Attach(mob/living/carbon/target, list/material_list, material_amount, heal_amount, heal_delay)
	. = ..()

	if(!istype(target))
		return ELEMENT_INCOMPATIBLE

	if(!list_check(material_list))
		return ELEMENT_INCOMPATIBLE
	if(!vars_check(material_amount, heal_amount, heal_delay))
		return ELEMENT_INCOMPATIBLE

	src.material_list = material_list
	src.material_amount = material_amount
	src.heal_amount = heal_amount
	src.heal_delay = heal_delay

	RegisterSignal(target, COMSIG_PARENT_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_self_examine))

/// Proc used to check the list for correct types
/datum/element/material_heal/proc/list_check(list/material_list)
	if(!LAZYLEN(material_list))
		return FALSE

	. = TRUE
	for(var/entry_path in material_list)
		if(!ispath(entry_path, /obj/item/stack))
			return FALSE

		// merge_type variable is often set to self type AFTER init
		var/obj/item/stack/type_item = new entry_path
		var/is_valid_merge_type = type_item.merge_type == entry_path
		qdel(type_item)

		if(!is_valid_merge_type)
			stack_trace("Invalid stack type passed in material_list: [entry_path]. Stack type must be equal to its merge_type variable.")
			return FALSE

/datum/element/material_heal/proc/vars_check(material_amount, heal_amount, heal_delay)
	if(!isnum(material_amount) || !isnum(heal_amount) || !isnum(heal_delay))
		return FALSE
	if(material_amount <= 0 || heal_amount <= 0 || heal_delay < 0)
		return FALSE
	return TRUE

/datum/element/material_heal/Detach(mob/living/carbon/target)
	. = ..()

	UnregisterSignal(target, list(COMSIG_PARENT_ATTACKBY, COMSIG_PARENT_EXAMINE))

/// Main signal proc. Signal is called in atom/proc/attackby()
/datum/element/material_heal/proc/on_attackby(mob/living/carbon/source, obj/item/stack/item, mob/living/user, params)
	SIGNAL_HANDLER

	if(!pre_heal_checks(source, item, user, params))
		return

	. = COMPONENT_CANCEL_ATTACK_CHAIN
	var/obj/item/organ/external/bodypart = source.get_organ(check_zone(user.zone_selected))
	if(!heal_checks(source, item, bodypart, user, params))
		return .

	user.changeNext_move(CLICK_CD_MELEE)

	// This is separated into two (healing ourselves and not) because of proc/endlag in proc/do_after,
	// which can't be used in procs with SHOULD_NOT_SLEEP(TRUE)
	if(source != user)
		stack_heal(source, user, bodypart, item)
		source.UpdateDamageIcon()
		return .

	if(LAZYACCESS(user.do_afters, src)) // Check if we are trying to heal ourselves while already trying
		return .

	INVOKE_ASYNC(src, PROC_REF(self_stack_heal), item, bodypart, user, params)

/**
 * # Proc to check heal requirements.
 *
 * Contains checks, that tell us, whether we
 * should or shouldn't cancel the attack chain.
 */
/datum/element/material_heal/proc/pre_heal_checks(mob/living/carbon/source, obj/item/stack/item, mob/living/user, params)
	. = FALSE
	if(user.a_intent != INTENT_HELP)
		return .
	if(!check_for_valid_type(item))
		return .

	return TRUE


/**
 * # Proc to check heal requirements.
 *
 * Contains checks, that tell us, whether our
 * new attack was successful or not.
 */
/datum/element/material_heal/proc/heal_checks(mob/living/carbon/source, obj/item/stack/item, obj/item/organ/external/bodypart, mob/living/user, params)
	. = FALSE
	if(!bodypart)
		user.balloon_alert(user, "нет такой конечности!")
		return .
	if(bodypart.is_robotic())
		user.balloon_alert(user, "конечность роботическая!")
		return .
	if(bodypart.open != ORGAN_CLOSED)
		user.balloon_alert(user, "конечность вскрыта!")
		return .

	if(!item.get_amount() || item.amount < material_amount) // Stack amount is spent later
		user.balloon_alert(user, "недостаточно материала!")
		return .

	return TRUE

/**
 * # Proc used to check if our item merge_type variable type exists in material_list
 * Why? Because I want this element to check for strict types, BUT
 * we have types like ../metal/fifty which is a separate type,
 * which would fail a strict type check for ../metal.
 * Checking for merge_type fixes that.
 */
/datum/element/material_heal/proc/check_for_valid_type(obj/item/stack/item)
	. = TRUE
	if(!istype(item))
		return FALSE
	if(!(item.merge_type in material_list)) // Material list always exists when this proc is called
		return FALSE

/**
 * # The material_heal element heal proc
 *
 * Basically a copy of gauze/ointment mechanics, but heals both brute and burn damages.
 */
/datum/element/material_heal/proc/stack_heal(mob/living/carbon/target, mob/living/user, obj/item/organ/external/bodypart, obj/item/stack/item)
	if(!item.use(material_amount)) // Rare to happen, but can happen. Example: Start healing ourselves, heal somebody else using all material.
		return

	user.balloon_alert(user, "вылечено!")
	heal_message(target, user, bodypart, item)

	var/bodypart_damage_was = bodypart.brute_dam + bodypart.burn_dam
	bodypart.heal_damage(heal_amount, heal_amount, updating_health = FALSE)

	var/actual_healing = bodypart_damage_was - (bodypart.brute_dam + bodypart.burn_dam)
	var/remaining_heal = max(0, heal_amount * 2 - actual_healing)

	var/should_update_health = actual_healing > 0

	if(remaining_heal > 0 && stack_children_heal(target, user, bodypart, item, remaining_heal))
		should_update_health = TRUE

	if(should_update_health)
		target.updatehealth("[item.name] heal")

	target.UpdateDamageIcon()

/**
 * # Subproc of stack_heal proc
 *
 * Heals bodypart's children using remaining medication.
 * Returns TRUE if any bodypart was successfully healed.
 */
/datum/element/material_heal/proc/stack_children_heal(mob/living/carbon/target, mob/living/user, obj/item/organ/external/bodypart, obj/item/item, remaining_heal)
	var/remheal = remaining_heal
	var/nremheal = remheal

	var/list/achildlist
	if(LAZYLEN(bodypart.children))
		achildlist = bodypart.children.Copy()
	var/parenthealed = FALSE

	while(remheal > 0) // Don't bother if there's not enough leftover heal
		var/obj/item/organ/external/bodypart_child
		if(LAZYLEN(achildlist))
			bodypart_child = pick_n_take(achildlist) // Pick a random children and then remove it from the list
		else if(bodypart.parent && !parenthealed) // If there's a parent and no healing attempt was made on it
			bodypart_child = bodypart.parent
			parenthealed = TRUE
		else
			break // If the organ have no child left and no parent / parent healed, break
		if(bodypart_child.is_robotic() || bodypart_child.open) // Ignore robotic or open limb
			continue
		else if(!bodypart_child.brute_dam && !bodypart_child.burn_dam) // Ignore undamaged limb
			continue
		nremheal = max(0, remheal - (bodypart_child.brute_dam + bodypart_child.burn_dam)) // Deduct the healed damage from the remain
		var/damage_was = bodypart_child.brute_dam + bodypart_child.burn_dam
		bodypart_child.heal_damage(remheal, remheal, updating_health = FALSE)
		if(bodypart.brute_dam + bodypart.burn_dam != damage_was)
			. = TRUE
		remheal = nremheal
		heal_message(target, user, bodypart_child, item)

/// Async proc used for delaying healing ourselves (because of endlag proc in do_after)
/datum/element/material_heal/proc/self_stack_heal(obj/item/stack/item, obj/item/organ/external/bodypart, mob/living/user, params)
	user.balloon_alert(user, "лечение...")
	user.visible_message(
		span_notice("[user] начина[pluralize_ru(user.gender, "ет", "ют")] лечить свои раны на [genderize_ru(user.gender, "его", "её", "его", "их")] [bodypart.declent_ru(PREPOSITIONAL)], используя [item.declent_ru(ACCUSATIVE)]."),
		ignored_mobs = user
	)

	if(!do_after(user, heal_delay, user, DA_IGNORE_USER_LOC_CHANGE, interaction_key = src, max_interact_count = 1))
		return

	stack_heal(user, user, bodypart, item)
	user.UpdateDamageIcon()

/**
 * Shows healing message for golem repair
 *
 * Varies depending on if we are healing ourselves, or someone else
 */
/datum/element/material_heal/proc/heal_message(mob/living/carbon/target, mob/living/user, obj/item/organ/external/bodypart, obj/item/item)
	if(user == target)
		user.visible_message(span_green("[user] залечива[pluralize_ru(user.gender, "ет", "ют")] раны на [genderize_ru(target.gender, "его", "её", "его", "их")] [bodypart.declent_ru(PREPOSITIONAL)], используя [item.declent_ru(ACCUSATIVE)]."), \
							ignored_mobs = user)
	else
		user.visible_message(span_green("[user] залечива[pluralize_ru(user.gender, "ет", "ют")] раны [target] на [genderize_ru(target.gender, "его", "её", "его", "их")] [bodypart.declent_ru(PREPOSITIONAL)], используя [item.declent_ru(ACCUSATIVE)]."), \
							ignored_mobs = user)

/// Signal proc. Shows on self examine that we can get healed by certain materials
/datum/element/material_heal/proc/on_self_examine(mob/living/carbon/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	if(source != user)
		return

	if(!cached_materials_str)
		for(var/material_type in material_list)
			var/obj/material = new material_type
			cached_materials_str += material.declent_ru(ACCUSATIVE)
			cached_materials_str += ", "
			qdel(material)
		cached_materials_str = copytext(cached_materials_str, 1, -2) // Remove last ", "
		cached_materials_str = capitalize(cached_materials_str) // Capitalize the first letter

	examine_text += span_notice("Присмотревшись, вы понимаете, что раны можно залечить, приложив следующие материалы: [cached_materials_str].")
