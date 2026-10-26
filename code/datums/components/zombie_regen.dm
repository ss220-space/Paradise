/datum/component/zombie_regen/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	START_PROCESSING(SSprocessing, src)

/datum/component/zombie_regen/Destroy(force, silent)
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/component/zombie_regen/process()
	if(!ishuman(parent))
		return
	var/mob/living/carbon/human/zomboid = parent
	if(zomboid.suiciding)
		return
	var/turf/current_turf = get_turf(zomboid)
	var/healing_factor = max(1, 6 * (1 - current_turf.get_lumcount()))
	if(HAS_TRAIT(zomboid, TRAIT_PLAGUE_ZOMBIE))
		healing_factor *= 1.6 // plague zombies have more health, and should heal faster
	if(zomboid.reagents.has_reagent(/datum/reagent/zombie_cure/third))
		healing_factor /= 3
	var/datum/antagonist/zombie/datum = zomboid?.mind?.has_antag_datum(/datum/antagonist/zombie)
	if(datum?.class)
		healing_factor *= datum.class.healing_factor_mod
	if(zomboid.stat == DEAD)
		healing_factor *= 3

	zomboid.heal_overall_damage(healing_factor, healing_factor)
	zomboid.adjustBrainLoss(-healing_factor)
	var/list/limbs = zomboid.get_damaged_organs(TRUE, TRUE)
	var/robotlimbbrute = 0
	var/robotlimbburn = 0
	for(var/obj/item/organ/external/limb in limbs)
		if(limb.is_robotic())
			robotlimbbrute += limb.brute_dam
			robotlimbburn += limb.burn_dam

	if(zomboid.stat == DEAD && (zomboid.getBruteLoss() - robotlimbbrute) <= 5 && (zomboid.getFireLoss() - robotlimbburn) <= 5 && (zomboid.timeofdeath + 15 SECONDS <= world.time))
		var/datum/reagent/the_cure = zomboid.reagents.has_reagent(/datum/reagent/zombie_cure/fourth)
		if(the_cure) // dead bodies dont process chemicals, so we gotta do it manually.
			zomboid.reagents.remove_reagent(/datum/reagent/zombie_cure/fourth, the_cure.metabolization_rate * zomboid.metabolism_efficiency)
			return
		zombie_rejuv()
		to_chat(zomboid, span_zombielarge("Мы... Восстаём..."))
		zomboid.notify_ghost_cloning("Your zombie body has risen again, re-enter your corpse to continue the feast!", source = zomboid)

	// If no client, but they were a player thats not SSD (debrained, revived but hasn't returned to body, etc)
	if(zomboid.stat != CONSCIOUS || HAS_TRAIT(zomboid, TRAIT_HANDS_BLOCKED))
		return

	if(zomboid.client || isLivingSSD(zomboid))
		return

	if(HAS_TRAIT(zomboid, TRAIT_PLAGUE_ZOMBIE)) // dont want plague zombie NPCs
		return

	if(!zomboid.client) // make sure they were player inhabited and not admin ghosted
		mindless_hunger()

/datum/component/zombie_regen/proc/zombie_rejuv()
	var/mob/living/carbon/human/zomboid = parent

	var/obj/item/organ/internal/heart = zomboid.get_organ_slot(INTERNAL_ORGAN_HEART)
	var/heart_type = zomboid.dna?.species?.has_organ[INTERNAL_ORGAN_HEART]
	if(!heart && heart_type)
		var/obj/item/organ/internal/new_heart = new heart_type()
		new_heart.insert(zomboid)

	var/obj/item/organ/internal/lungs = zomboid.get_organ_slot(INTERNAL_ORGAN_LUNGS)
	var/lung_type = zomboid.dna?.species?.has_organ[INTERNAL_ORGAN_LUNGS]
	if(!lungs && lung_type)
		var/obj/item/organ/internal/new_lungs = new lung_type()
		new_lungs.insert(zomboid)

	zomboid.rejuvenate(FALSE)

	for(var/datum/disease/critical/crit in zomboid.diseases) // cure all crit conditions
		crit.cure()

/datum/component/zombie_regen/proc/mindless_hunger()
	var/mob/living/carbon/human/zomboid = parent
	var/list/targets = list()
	for(var/mob/living/carbon/human/target in view(6, zomboid))
		if(target.stat == CONSCIOUS && !HAS_TRAIT(target, TRAIT_I_WANT_BRAINS))
			targets |= target
			if(zomboid.Adjacent(target))
				break // we're just gonna hit em

	var/target
	if(length(targets))
		target = pick(targets)

	if(zomboid.Adjacent(target) && safe_active_hand(zomboid))
		if(!zomboid.get_active_hand())
			var/datum/antagonist/zombie/datum = zomboid.mind.has_antag_datum(/datum/antagonist/zombie)
			var/obj/item/zombie_claw/claws = new()
			if(datum?.class)
				claws.damage_mod = datum?.class.damage_mod
				claws.force *= datum?.class.damage_mod
			zomboid.put_in_hands(claws)
		zomboid.a_intent = INTENT_HARM
		zomboid.ClickOn(target)
		return

	if(!target && prob(90)) // a small chance to wander
		return

	var/targetted_direction = pick(GLOB.cardinal)
	if(target)
		targetted_direction = get_dir(zomboid, target)

	step(zomboid, targetted_direction)

/datum/component/zombie_regen/proc/safe_active_hand(mob/living/carbon/human/zomboid)
	if(zomboid.get_organ(zomboid.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND))
		return TRUE
	zomboid.swap_hand()
	if(zomboid.get_organ(zomboid.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND))
		return TRUE
	return FALSE
