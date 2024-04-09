/datum/component/caltrop
	var/min_damage
	var/max_damage
	var/probability
	var/flags

	COOLDOWN_DECLARE(message_cooldown)
	var/list/protected_species = list()

/datum/component/caltrop/Initialize(min_damage = 0, max_damage = 0, probability = 100, flags = NONE, protected_species = list())
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	src.min_damage = min_damage
	src.max_damage = max(min_damage, max_damage)
	src.probability = probability
	src.flags = flags
	src.protected_species = protected_species

	RegisterSignal(parent, list(COMSIG_MOVABLE_CROSSED), PROC_REF(Crossed))

/datum/component/caltrop/proc/Crossed(datum/source, atom/movable/AM)
	var/atom/A = parent
	if(!A.has_gravity(A.loc))
		return

	if(!ishuman(AM))
		return

	if(!prob(probability))
		return

	var/mob/living/carbon/human/victim_human = AM
	if(victim_human.dna.species.name in protected_species)
		return

	if(!(flags & CALTROP_BYPASS_WALKERS) && victim_human.m_intent == MOVE_INTENT_WALK)
		return

	if(victim_human.buckled || (victim_human.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return
	special_caltdrop(victim_human)

/datum/component/caltrop/proc/special_caltdrop(mob/living/carbon/human/human)
	var/picked_def_zone = pick(BODY_ZONE_PRECISE_R_FOOT, BODY_ZONE_PRECISE_L_FOOT)
	var/obj/item/organ/external/O = human.get_organ(picked_def_zone)
	if(!istype(O))
		return
	if(!(flags & CALTROP_BYPASS_ROBOTIC_FOOTS) && (O.is_robotic()))
		return

	var/feetCover = (human.wear_suit && (human.wear_suit.body_parts_covered & FEET)) || (human.w_uniform && (human.w_uniform.body_parts_covered & FEET))

	if(!(flags & CALTROP_BYPASS_SHOES) && (human.shoes || feetCover))
		return
	if(PIERCEIMMUNE in human.dna.species.species_traits)
		return
	var/damage = rand(min_damage, max_damage)

	human.apply_damage(damage, BRUTE, picked_def_zone)

	if(COOLDOWN_FINISHED(src, message_cooldown)) //cooldown to avoid message spam.
		if(!human.incapacitated(ignore_restraints = TRUE))
			human.visible_message("<span class='danger'>[human] steps on [parent].</span>", "<span class='userdanger'>You step on [parent]!</span>")
		else
			human.visible_message("<span class='danger'>[human] slides on [parent]!</span>", "<span class='userdanger'>You slide on [parent]!</span>")

		COOLDOWN_START(src, message_cooldown, 1 SECONDS)
	human.Weaken(6 SECONDS)

/datum/component/caltrop/virus
	var/datum/disease/virus/virus_type = null

/datum/component/caltrop/virus/Initialize(min_damage = 0, max_damage = 0, probability = 100, flags = NONE, protected_species = list(), datum/disease/virus/virus_type)
	if(!ispath(virus_type, /datum/disease/virus))
		return COMPONENT_INCOMPATIBLE
	. = ..()
	src.virus_type = virus_type

/datum/component/caltrop/virus/special_caltdrop(mob/living/carbon/human/human)
	var/datum/disease/virus/virus = new virus_type()
	virus.Contract(human, CONTACT|AIRBORNE, need_protection_check = TRUE)
