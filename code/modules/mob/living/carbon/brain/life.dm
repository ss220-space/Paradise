/mob/living/carbon/brain/handle_mutations_and_radiation()
	if(radiation)
		if(radiation > 100)
			if(!container)
				to_chat(src, span_danger("You feel weak."))
			else
				to_chat(src, span_danger("STATUS: CRITICAL AMOUNTS OF RADIATION DETECTED."))

		switch(radiation)

			if(50 to 75)
				if(prob(5))
					if(!container)
						to_chat(src, span_danger("You feel weak."))
					else
						to_chat(src, span_danger("STATUS: DANGEROUS AMOUNTS OF RADIATION DETECTED."))
		..()

/mob/living/carbon/brain/proc/handle_temperature_damage(body_part, exposed_temperature, exposed_intensity)
	if(HAS_TRAIT(src, TRAIT_GODMODE))
		return

	if(exposed_temperature > bodytemperature)
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		adjustFireLoss(20*discomfort)

	else
		var/discomfort = min( abs(exposed_temperature - bodytemperature)*(exposed_intensity)/2000000, 1.0)
		adjustFireLoss(5*discomfort)

/mob/living/carbon/brain/Life()
	. = ..()
	if(.)
		if(!container && (world.time - timeofhostdeath) > CONFIG_GET(number/revival_brain_life))
			death()

/mob/living/carbon/brain/breathe()
	return
