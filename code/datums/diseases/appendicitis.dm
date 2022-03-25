/datum/disease/appendicitis
	form = "Состояние"
	name = "Аппендицит"
	max_stages = 3
	cure_text = "Хирургия"
	agent = "Раздутый аппендикс"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 1
	desc = "Если не вылечить, то субъект будет слабеть и может начать постоянно блевать."
	severity = DANGEROUS
	disease_flags = CAN_CARRY|CAN_RESIST
	spread_flags = NON_CONTAGIOUS
	visibility_flags = HIDDEN_PANDEMIC
	required_organs = list(/obj/item/organ/internal/appendix)
	bypasses_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/appendicitis/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(5))
				affected_mob.emote("cough")
		if(2)
			var/obj/item/organ/internal/appendix/A = affected_mob.get_int_organ(/obj/item/organ/internal/appendix)
			if(A)
				A.inflamed = 1
				A.update_icon()
			if(prob(3))
				to_chat(affected_mob, "<span class='warning'>Вы ощущаете колющую боль в животе!</span>")
				affected_mob.Stun(rand(2,3))
				affected_mob.adjustToxLoss(1)
		if(3)
			if(prob(1))
				affected_mob.vomit(95)
