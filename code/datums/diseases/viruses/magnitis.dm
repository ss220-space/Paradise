/datum/disease/virus/magnitis
	name = "Magnitis"
	agent = "Fukkos Miracos"
	desc = "This disease disrupts the magnetic field of your body, making it act as if a powerful magnet. Injections of iron help stabilize the field."
	max_stages = 4
	spread_flags = AIRBORNE
	cures = list("iron")
	permeability_mod = 0.75
	severity = MEDIUM

/datum/disease/virus/magnitis/stage_act()
	..()
	switch(stage)
		if(2)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You feel a slight shock course through your body.</span>")
			if(prob(2))
				for(var/obj/M in orange(2,affected_mob))
					if(!M.anchored && (M.flags & CONDUCT))
						step_towards(M,affected_mob)
				for(var/mob/living/silicon/S in orange(2,affected_mob))
					if(istype(S, /mob/living/silicon/ai)) continue
					step_towards(S,affected_mob)
		if(3)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You feel a strong shock course through your body.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You feel like clowning around.</span>")
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
				to_chat(affected_mob, "<span class='danger'>You feel a powerful shock course through your body.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>You query upon the nature of miracles.</span>")
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
