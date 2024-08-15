/**
 * Framework for custom vendor crits.
 */

/datum/vendor_crit
	/// If it'll deal damage or not
	var/harmless = FALSE
	/// If we should be thrown against the mob or not.
	var/fall_towards_mob = TRUE

/**
 * Return whether or not the crit selected is valid.
 */
/datum/vendor_crit/proc/is_valid(obj/machinery/vending/machine, mob/living/carbon/victim)
	return TRUE

/***
 * Perform the tip crit effect on a victim.
 * Arguments:
 * * machine - The machine that was tipped over
 * * user - The unfortunate victim upon whom it was tipped over
 * Returns: The "crit rebate", or the amount of damage to subtract from the original amount of damage dealt, to soften the blow.
 */
/datum/vendor_crit/proc/tip_crit_effect(obj/machinery/vending/machine, mob/living/carbon/victim)
	return 0

/datum/vendor_crit/shatter

/datum/vendor_crit/shatter/tip_crit_effect(obj/machinery/vending/machine, mob/living/carbon/victim)
	victim.bleed(150)
	var/obj/item/organ/external/leg/right = victim.get_organ(BODY_ZONE_R_LEG)
	var/obj/item/organ/external/leg/left = victim.get_organ(BODY_ZONE_L_LEG)
	left.external_receive_damage(50)
	left.fracture()
	right.external_receive_damage(50)
	right.fracture()

	if(left || right)
		victim.visible_message(
			span_danger("[victim]'s legs shatter with a sickening crunch!"),
			span_userdanger("Your legs shatter with a sickening crunch!"),
			span_danger("You hear a sickening crunch!")
		)

	// that's a LOT of damage, let's rebate most of it.
	return machine.squish_damage * (5/6)

/datum/vendor_crit/pin

/datum/vendor_crit/pin/tip_crit_effect(obj/machinery/vending/machine, mob/living/carbon/victim)
	var/turf/our_turf = get_turf(victim)
	if(!our_turf)
		return
	machine.forceMove(our_turf)
	machine.buckle_mob(victim, force=TRUE)
	victim.visible_message(
		span_danger("[victim] gets pinned underneath [machine]!"),
		span_userdanger("You are pinned down by [machine]!")
	)

	return 0

/datum/vendor_crit/embed

/datum/vendor_crit/embed/is_valid(obj/machinery/vending/machine, mob/living/carbon/victim)
	. = ..()
	if(machine.num_shards <= 0)
		return FALSE

/datum/vendor_crit/embed/tip_crit_effect(obj/machinery/vending/machine, mob/living/carbon/victim)
	var/turf/our_turf = get_turf(victim)
	if(!our_turf)
		return
	victim.visible_message(
		span_danger("[machine]'s panel shatters against [victim]!"),
		span_userdanger("[machine] lands on you, its panel shattering!")
	)

	for(var/i in 1 to machine.num_shards)
		var/obj/item/shard/shard = new /obj/item/shard(our_turf)
		// do a little dance to force the embeds, but make sure the glass isn't gigapowered afterwards
		shard.embed_chance = 100
		shard.embedded_pain_chance = 5
		shard.embedded_impact_pain_multiplier = 1
		shard.embedded_ignore_throwspeed_threshold = TRUE
		victim.hitby(shard, skipcatch = TRUE, hitpush = FALSE)
		shard.embed_chance = initial(shard.embed_chance)
		shard.embedded_pain_chance = initial(shard.embedded_pain_chance)
		shard.embedded_impact_pain_multiplier = initial(shard.embedded_pain_multiplier)
		shard.embedded_ignore_throwspeed_threshold = initial(shard.embedded_ignore_throwspeed_threshold)

	playsound(machine, "shatter", 50)

	return machine.squish_damage * (3/4)

/datum/vendor_crit/pop_head

/datum/vendor_crit/pop_head/tip_crit_effect(obj/machinery/vending/machine, mob/living/carbon/victim)
	// pop!
	var/obj/item/organ/external/head/H = victim.get_organ(BODY_ZONE_HEAD)
	var/obj/item/organ/internal/brain/B = victim.get_organ_slot(INTERNAL_ORGAN_BRAIN)
	if(H)
		victim.visible_message(
			span_danger("[H] gets crushed under [machine], and explodes in a shower of gore!"),
			span_userdanger("Oh f-"))
		new /obj/effect/gibspawner/human(get_turf(victim))
		H.drop_organs()
		H.droplimb(TRUE)
		H.disfigure()
		victim.apply_damage(50, BRUTE, BODY_ZONE_HEAD)
	else
		H.visible_message(
			span_danger("[victim]'s head seems to be crushed under [machine]...but wait, they had none in the first place!"))
	if(B in H)
		victim.adjustBrainLoss(80)

	return 0

/datum/vendor_crit/lucky
	harmless = TRUE

/datum/vendor_crit/lucky/tip_crit_effect(obj/machinery/vending/machine, mob/living/carbon/victim)
	victim.visible_message(
		span_danger("[machine] crashes around [victim], but doesn't seem to crush them!"),
		span_userdanger("[machine]  crashes around you, but only around you! You're fine!")
	)

	return 1000
