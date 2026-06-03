/datum/action/changeling/biodegrade
	name = "Биоразложение"
	desc = "Растворяет сдерживающие наше передвижение предметы. Можно использовать в низшей форме. Требует 30 химикатов."
	helptext = "Позволяет освободится от наручников, стяжек, смирительной рубашки, бол, коконов, шкафов. Очень заметно. Можно использовать в низшей форме."
	button_icon_state = "biodegrade"
	power_type = CHANGELING_PURCHASABLE_POWER
	dna_cost = 1
	chemical_cost = 30

/datum/action/changeling/biodegrade/sting_action(mob/living/carbon/human/user)
	var/used = FALSE // only one form of shackles removed per use

	if(!HAS_TRAIT(user, TRAIT_RESTRAINED) && !iscloset(user.loc) && !istype(user.loc, /obj/structure/spider/cocoon) && !user.pulledby)
		user.balloon_alert(user, "мы уже свободны")
		return FALSE

	if(user.handcuffed)
		var/obj/item/restraints/handcuffs/handcuffs = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
		if(!istype(handcuffs))
			return FALSE

		user.balloon_alert_to_viewers("[user] блюёт кислотой", "мы блюём кислотой!")

		addtimer(CALLBACK(src, PROC_REF(dissolve_restraint), user, handcuffs), 3 SECONDS)
		used = TRUE

	if(user.legcuffed && !used)
		var/obj/item/restraints/legcuffs/legcuffs = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
		if(!istype(legcuffs))
			return FALSE

		user.balloon_alert_to_viewers("[user] блюёт кислотой", "мы блюём кислотой!")

		addtimer(CALLBACK(src, PROC_REF(dissolve_restraint), user, legcuffs), 3 SECONDS)
		used = TRUE

	if(user.wear_suit?.breakout_time && !used)
		var/obj/item/clothing/suit/res_suit = user.get_item_by_slot(ITEM_SLOT_CLOTH_OUTER)
		if(!istype(res_suit))
			return FALSE

		user.balloon_alert_to_viewers("[user] блюёт кислотой", "мы блюём кислотой!")

		addtimer(CALLBACK(src, PROC_REF(dissolve_restraint), user, res_suit), 3 SECONDS)
		used = TRUE

	// mech supress escape
	if(HAS_TRAIT_FROM(user, TRAIT_IMMOBILIZED, MECH_SUPRESSED_TRAIT))
		user.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_FLOORED), MECH_SUPRESSED_TRAIT)
		used = TRUE

	// mech cage container escape
	if(istype(user.loc, /obj/item/mecha_parts/mecha_equipment/cage))
		var/obj/item/mecha_parts/mecha_equipment/cage/container = user.loc
		user.balloon_alert_to_viewers("[user] блюёт кислотой", "мы блюём кислотой!")
		user.forceMove(get_turf(container))
		container.prisoner = null

	if(iscloset(user.loc) && !used)
		var/obj/structure/closet/closet = user.loc
		if(!istype(closet))
			return FALSE

		user.balloon_alert_to_viewers("[user] блюёт кислотой", "мы блюём кислотой!")

		addtimer(CALLBACK(src, PROC_REF(open_closet), user, closet), 7 SECONDS)
		used = TRUE

	if(istype(user.loc, /obj/structure/spider/cocoon) && !used)
		var/obj/structure/spider/cocoon/cocoon = user.loc
		if(!istype(cocoon))
			return FALSE

		user.balloon_alert_to_viewers("[user] блюёт кислотой", "мы блюём кислотой!")

		addtimer(CALLBACK(src, PROC_REF(dissolve_cocoon), user, cocoon), 2.5 SECONDS) //Very short because it's just webs
		used = TRUE

	if(!used && user.pulledby)
		var/mob/living/grab_owner = user.pulledby
		user.balloon_alert_to_viewers("[user] блюёт кислотой", "мы блюём кислотой!")
		grab_owner.apply_damage(20, BURN, BODY_ZONE_CHEST, grab_owner.run_armor_check(BODY_ZONE_CHEST, MELEE))
		playsound(user.loc, 'sound/weapons/sear.ogg', 50, TRUE)
		grab_owner.stop_pulling()
		user.client?.move_delay = world.time	// to skip move delay we probably got from resisting the grab
		used = TRUE

	if(used)
		SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))

	return TRUE

/datum/action/changeling/biodegrade/proc/dissolve_restraint(mob/living/carbon/human/user, obj/restraints)
	if(QDELETED(user) || QDELETED(restraints))
		return

	if(user.handcuffed == restraints || user.legcuffed == restraints || user.wear_suit == restraints)
		user.visible_message(span_warning("[restraints] dissolves into a puddle of sizzling goop."))
		user.temporarily_remove_item_from_inventory(restraints, force = TRUE)
		qdel(restraints)

/datum/action/changeling/biodegrade/proc/open_closet(mob/living/carbon/human/user, obj/structure/closet/closet)
	if(QDELETED(user) || QDELETED(closet))
		return

	if(user.loc == closet)
		closet.welded = FALSE
		closet.locked = FALSE
		closet.broken = TRUE
		closet.open()
		user.balloon_alert_to_viewers("дверь растворенна!", "мы растворили дверь!")

/datum/action/changeling/biodegrade/proc/dissolve_cocoon(mob/living/carbon/human/user, obj/structure/spider/cocoon/cocoon)
	if(QDELETED(user) || QDELETED(cocoon))
		return

	if(user.loc == cocoon)
		qdel(cocoon) //The cocoon's destroy will move the changeling outside of it without interference
		to_chat(user, span_warning("We dissolve the cocoon!"))

