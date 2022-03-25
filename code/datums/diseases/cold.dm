/datum/disease/cold
	name = "Простуда"
	max_stages = 3
	spread_flags = AIRBORNE
	cure_text = "Отдых + Spaceacillin"
	cures = list("spaceacillin")
	agent = "Риновирус XY"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	permeability_mod = 0.5
	desc = "Если не вылечить, субъект заболеет гриппом."
	severity = MINOR

/datum/disease/cold/stage_act()
	..()
	switch(stage)
		if(2)
/*
			if(affected_mob.sleeping && prob(40))  //removed until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				cure()
				return
*/
			if(affected_mob.lying && prob(40))  //changed FROM prob(10) until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				cure()
				return
			if(prob(1) && prob(5))
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>У вас першит в горле.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете, как по задней стенке горла стекает мокрота.</span>")
		if(3)
/*
			if(affected_mob.sleeping && prob(25))  //removed until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				cure()
				return
*/
			if(affected_mob.lying && prob(25))  //changed FROM prob(5) until sleeping is fixed
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				cure()
				return
			if(prob(1) && prob(1))
				to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
				cure()
				return
			if(prob(1))
				affected_mob.emote("sneeze")
			if(prob(1))
				affected_mob.emote("cough")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>У вас першит в горле.</span>")
			if(prob(1))
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете, как по задней стенке горла стекает мокрота.</span>")
			if(prob(1) && prob(50))
				if(!affected_mob.resistances.Find(/datum/disease/flu))
					var/datum/disease/Flu = new /datum/disease/flu(0)
					affected_mob.ContractDisease(Flu)
					cure()
