/datum/disease/magnitis
	name = "Магнитис"
	max_stages = 4
	spread_text = "Аэрогенный"
	cure_text = "Iron"
	cures = list("iron")
	agent = "Фуккос Миракос"
	viable_mobtypes = list(/mob/living/carbon/human)
	disease_flags = CAN_CARRY|CAN_RESIST|CURABLE
	permeability_mod = 0.75
	desc = "Эта болезнь нарушает магнитное поле тела субъекта, заставляя его действовать как мощный магнит. Инъекции железа помогают стабилизировать поле."
	severity = MEDIUM

/datum/disease/magnitis/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>По вашему телу проходят лёгкие колебания.</span>")
			if(prob(2))
				for(var/obj/M in orange(2,affected_mob))
					if(!M.anchored && (M.flags & CONDUCT))
						step_towards(M,affected_mob)
				for(var/mob/living/silicon/S in orange(2,affected_mob))
					if(istype(S, /mob/living/silicon/ai)) continue
					step_towards(S,affected_mob)
		if(3)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>По вашему телу проходят колебания.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Вас немного качает.</span>")
			if(prob(4))
				for(var/obj/M in orange(4,affected_mob))
					if(!M.anchored && (M.flags & CONDUCT))
						var/i
						var/iter = rand(1,2)
						for(i=0,i<iter,i++)
							step_towards(M,affected_mob)
				for(var/mob/living/silicon/S in orange(4,affected_mob))
					if(istype(S, /mob/living/silicon/ai)) continue
					var/i
					var/iter = rand(1,2)
					for(i=0,i<iter,i++)
						step_towards(S,affected_mob)
		if(4)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>По вашему телу проходят мощные колебания.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Вы задаётесь вопросом о природе происходящих странностей.</span>")
			if(prob(8))
				for(var/obj/M in orange(6,affected_mob))
					if(!M.anchored && (M.flags & CONDUCT))
						var/i
						var/iter = rand(1,3)
						for(i=0,i<iter,i++)
							step_towards(M,affected_mob)
				for(var/mob/living/silicon/S in orange(6,affected_mob))
					if(istype(S, /mob/living/silicon/ai)) continue
					var/i
					var/iter = rand(1,3)
					for(i=0,i<iter,i++)
						step_towards(S,affected_mob)
	return
