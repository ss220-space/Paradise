/datum/disease/flu
	name = "Грипп"
	max_stages = 3
	spread_text = "Воздушно-капельный"
	cure_text = "Spaceacillin"
	cures = list("spaceacillin")
	cure_chance = 10
	agent = "Вирион гриппа H13N1"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	permeability_mod = 0.75
	desc = "Если не вылечить, то субъект будет чувствовать себя довольно паршиво."
	severity = MEDIUM

/datum/disease/flu/stage_act()
	..()
	switch(stage)
		if(2)
			if(affected_mob.lying && prob(20))
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>У вас ноют мышцы.</span>")
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>У вас болит живот.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1)

		if(3)
			if(affected_mob.lying && prob(15))
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				stage--
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>У вас ноют мышцы.</span>")
				if(prob(20))
					affected_mob.take_organ_damage(1)
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>У вас болит живот.</span>")
				if(prob(20))
					affected_mob.adjustToxLoss(1)
	return
