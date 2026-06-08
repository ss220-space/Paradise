//Item for knock/moon heretic sidepath, it can block 5 hits of damage, acts as storage and if the heretic is examined the examiner suffers brain damage and blindness

/obj/item/storage/belt/unfathomable_curio
	name = "непостижимая диковинка"
	desc = "Оно. Оно оглядывается назад. Оно смотрит в прошлое. \
			Оно заглядывает внутрь. Оно видит. Оно прячется. Оно открывается."
	gender = FEMALE
	icon_state = "unfathomable_curio"
	item_state = "unfathomable_curio"
	//content_overlays = FALSE
	//storage_type = /datum/storage/unfathomable_curio
	max_combined_w_class = 21
	storage_slots = 21
	//Vars used for the shield component
	max_w_class = WEIGHT_CLASS_NORMAL
	can_hold = list(
		/obj/item/ammo_box/magazine/strilka310/lionhunter,
		/obj/item/heretic_labyrinth_handbook,
		/obj/item/organ, // Bodyparts are often used in rituals.
		/obj/item/clothing/neck/eldritch_amulet,
		/obj/item/clothing/neck/heretic_focus,
		/obj/item/codex_cicatrix,
		/obj/item/eldritch_potion,
		/obj/item/reagent_containers/food/snacks/grown/poppy, // Used to regain a Living Heart.
		/obj/item/reagent_containers/food/snacks/grown/harebell, // Used to reroll targets
		/obj/item/melee/rune_carver,
		/obj/item/melee/sickly_blade,
		/obj/item/organ, // Organs are also often used in rituals.
		/obj/item/reagent_containers/glass/beaker/eldritch,
		/obj/item/stack/sheet/glass, // Glass is often used by moon heretics
	)
	var/heretic_shield_icon = "unfathomable_shield"
	var/max_charges = 5
	var/recharge_start_delay = 30 SECONDS
	var/charge_increment_delay = 30 SECONDS
	var/charge_recovery = 1


/obj/item/storage/belt/unfathomable_curio/get_ru_names()
	return list(
		NOMINATIVE = "непостижимая диковинка",
		GENITIVE = "непостижимой диковинки",
		DATIVE = "непостижимой диковинке",
		ACCUSATIVE = "непостижимую диковинку",
		INSTRUMENTAL = "непостижимой диковинкой",
		PREPOSITIONAL = "непостижимой диковинке",
	)


/obj/item/storage/belt/unfathomable_curio/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/shielded, max_charges = max_charges, recharge_start_delay = recharge_start_delay, charge_increment_delay = charge_increment_delay, \
	charge_recovery = charge_recovery, shield_icon = heretic_shield_icon, run_hit_callback = CALLBACK(src, PROC_REF(shield_damaged)))


/obj/item/storage/belt/unfathomable_curio/equipped(mob/user, slot, initial)
	. = ..()
	if(!(slot & slot_flags))
		return

	//RegisterSignal(user, COMSIG_ITEM_HIT_REACT, PROC_REF(shield_reaction))

	if(isheretic(user))
		return

	to_chat(user, span_warning("Диковинка обволакивает вас, и вы чувствуете биение чего-то темного внутри неё..."))


/*
/obj/item/storage/belt/unfathomable_curio/dropped(mob/user)
	. = ..()
	UnregisterSignal(user, COMSIG_ITEM_HIT_REACT)
*/
/*
// Here we make sure our curio is only able to block while worn on the belt slot
/obj/item/storage/belt/unfathomable_curio/proc/shield_reaction(datum/source, mob/living/carbon/human/owner, atom/movable/hitby, damage, attack_type)
	SIGNAL_HANDLER

	if(hit_reaction(owner, hitby, "атакует", 0, damage, attack_type) && (owner.belt == src))
		return COMPONENT_BLOCK_SUCCESSFUL

	return NONE
*/

// Our on hit effect
/obj/item/storage/belt/unfathomable_curio/proc/shield_damaged(mob/living/carbon/human/wearer, attack_text, new_current_charges)
	/*var/list/brain_traumas = list(
		/datum/brain_trauma/severe/mute,
		/datum/brain_trauma/severe/flesh_desire,
		/datum/brain_trauma/severe/eldritch_beauty,
		/datum/brain_trauma/severe/paralysis,
		/datum/brain_trauma/severe/monophobia
	)*/
	wearer.visible_message(span_danger("[declent_ru(NOMINATIVE)] обволакивает [wearer.declent_ru(ACCUSATIVE)] блокируя атаку!"))
	if(isheretic(wearer))
		return

	to_chat(wearer, span_warning("Смех раздается в вашем сознании..."))
	wearer.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 40)
	wearer.drop_item_ground(src, TRUE)
	var/trauma_type = rand(1, 5)
	switch(trauma_type)
		if(1)
			wearer.force_gene_block(GLOB.muteblock, TRUE, TRUE)
		if(2)
			wearer.force_gene_block(GLOB.swedeblock, TRUE, TRUE)
		if(3)
			wearer.force_gene_block(GLOB.scrambleblock, TRUE, TRUE)
		if(4)
			wearer.force_gene_block(GLOB.comicblock, TRUE, TRUE)
		if(5)
			wearer.force_gene_block(GLOB.paraplegiablock, TRUE, TRUE)

	//wearer.gain_trauma(pick(brain_traumas) ,TRAUMA_RESILIENCE_ABSOLUTE)


/obj/item/storage/belt/unfathomable_curio/examine(mob/living/carbon/user)
	. = ..()
	if(isheretic(user))
		return

	user.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 10, 160)
	user.EyeBlind(5 SECONDS)
	. += span_notice("Оно. Оно смотрело. ОНО ОБВАЛИВАЕТ МЕНЯ.")

