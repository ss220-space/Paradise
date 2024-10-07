/datum/disease/appendicitis
	form = "Condition"
	name = "Appendicitis"
	agent = "Shitty Appendix"
	desc = "If left untreated the subject will become very weak, and may vomit often."
	cure_text = "Surgery"
	stage_prob = 2
	severity = DANGEROUS
	curable = FALSE
	can_immunity = FALSE
	visibility_flags = HIDDEN_PANDEMIC
	required_organs = list(/obj/item/organ/internal/appendix)
	ignore_immunity = TRUE
	virus_heal_resistant = TRUE
	var/ruptured = FALSE

/datum/disease/appendicitis/stage_act()
	if(!..())
		return FALSE

	var/mob/living/carbon/human/H = affected_mob
	if(!istype(H))
		return

	var/obj/item/organ/internal/appendix/A = H.get_int_organ(/obj/item/organ/internal/appendix)
	if(!istype(A))
		cure()
		return

	if(!A.inflamed)
		A.inflamed = TRUE
		A.update_icon()

	if(!ruptured && (A.germ_level >= INFECTION_LEVEL_THREE || A.is_dead()))
		rupture(H, A)

	var/germs_mod = H.dna.species.germs_growth_mod * H.physiology.germs_growth_mod
	switch(stage)
		if(2)
			if(A.germ_level < INFECTION_LEVEL_ONE)
				A.germ_level = INFECTION_LEVEL_ONE
			A.germ_level += rand(1, 4) * germs_mod

			if(prob(2))
				H.vomit()

			if(prob(5))
				A.internal_receive_damage(1, silent = prob(65))

		if(3)
			if(A.germ_level < INFECTION_LEVEL_ONE)
				A.germ_level = INFECTION_LEVEL_ONE
			A.germ_level += rand(2, 6) * germs_mod

			if(prob(10))
				A.internal_receive_damage(1, silent = prob(45))

			if(prob(3))
				H.vomit()

			if(prob(10))
				H.emote("moan")

			if(prob(5))
				to_chat(H, span_warning("You feel a stabbing pain in your abdomen!"))
				H.Stun(rand(2 SECONDS, 4 SECONDS))
				H.Slowed(10 SECONDS, 5)
				H.adjustToxLoss(1)

		if(4)

			if(A.germ_level < INFECTION_LEVEL_TWO)
				A.germ_level = INFECTION_LEVEL_TWO
			A.germ_level += rand(4, 10) * germs_mod

			if(prob(10))
				A.internal_receive_damage(2)

			if(prob(3))
				H.vomit()

			if(prob(15))
				H.emote(pick("moan", "cry"))

			if(prob(7))
				to_chat(H, span_danger("You feel a stabbing pain in your abdomen!"))
				H.Stun(rand(2 SECONDS, 4 SECONDS))
				H.Slowed(15 SECONDS, 5)
				H.adjustToxLoss(3)

		if(5)
			if(A.germ_level < INFECTION_LEVEL_TWO)
				A.germ_level = INFECTION_LEVEL_TWO
			A.germ_level += rand(6, 12) * germs_mod

			H.adjustToxLoss(0.5)
			if(H.IsSlowed())
				H.AdjustSlowedDuration(30 SECONDS, bound_upper = 40 SECONDS)
			else
				H.Slowed(30 SECONDS, 5)

			H.damageoverlaytemp = 30

			if(prob(20))
				A.internal_receive_damage(3)

			if(prob(5))
				H.vomit()

			if(prob(10))
				H.emote(pick("moan", "cry"))

			if(prob(8))
				to_chat(H, span_danger("You feel a stabbing pain in your abdomen!"))
				H.Stun(rand(2 SECONDS, 4 SECONDS))
				H.Jitter(10 SECONDS)


/datum/disease/appendicitis/proc/rupture(mob/living/carbon/human/H, obj/item/organ/internal/appendix/A)
	ruptured = TRUE
	A.necrotize()
	stage = 5

	var/obj/item/organ/external/parent = H.get_organ(check_zone(A.parent_organ_zone))
	if(istype(parent))
		H.apply_damage(25, def_zone = parent, used_weapon = "appendix rupture")
		if(parent.germ_level < INFECTION_LEVEL_TWO)
			parent.germ_level = INFECTION_LEVEL_TWO
		for(var/obj/item/organ/internal/organ as anything in parent.internal_organs)
			if(organ.germ_level < INFECTION_LEVEL_TWO)
				organ.germ_level = INFECTION_LEVEL_TWO
			organ.internal_receive_damage(10)

	to_chat(H, span_userdanger("You feel a hellish pain in your abdomen, as if something is torn!"))
	H.Stun(20 SECONDS)
	H.emote("scream")
	addtimer(CALLBACK(src, PROC_REF(fall), H, A), 10 SECONDS)

/datum/disease/appendicitis/proc/fall(mob/living/carbon/human/H, obj/item/organ/internal/appendix/A)
	to_chat(H, span_danger("You feel weakening..."))
	H.Weaken(10 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(exhausted), H, A), 10 SECONDS)

/datum/disease/appendicitis/proc/exhausted(mob/living/carbon/human/H, obj/item/organ/internal/appendix/A)
	to_chat(H, span_danger("You feel weakening... Need to sleep"))
	H.SetSleeping(40 SECONDS)
	H.Slowed(200 SECONDS, 10)




