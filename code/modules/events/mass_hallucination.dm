/datum/event/mass_hallucination/setup()
	announceWhen = rand(0, 20)

/datum/event/mass_hallucination/start()
	for(var/mob/living/carbon/human/human as anything in GLOB.human_list)
		if(human.stat == DEAD)
			continue
		var/turf/turf = get_turf(human)
		if(!is_station_level(turf?.z))
			continue
		// Leave radiation-immune species/rad armored players completely unaffected
		if(HAS_TRAIT(human, TRAIT_RADIMMUNE) || HAS_TRAIT(human, TRAIT_NO_RADIATION_EFFECTS))
			continue
		human.AdjustHallucinate(rand(100 SECONDS, 200 SECONDS))
		human.last_hallucinator_log = "Mass hallucination event"

/datum/event/mass_hallucination/announce()
	if(prob(40))
		GLOB.minor_announcement.announce(
			message = "Станция [station_name()] проходит через радиационное поле низкой интенсивности. Возможно появление галлюцинаций, но не более."
		)
