/datum/event/tear/random
	name = "randomensional tear"
	notify_title = "Рандомысленный разрыв"
	notify_image = "regalrat"

	var/obj/effect/tear/random/HE

/datum/event/tear/random/spawn_tear(location)
	HE = new /obj/effect/tear/random(location)

/datum/event/tear/random/announce()
	GLOB.minor_announcement.announce(
		"На борту станции зафиксирована мощный пространственно-временной разрыв. Предполагаемая локация: [impact_area.name].",
		ANNOUNCE_ANOMALY_RU,
		'sound/AI/anomaly.ogg'
	)

/datum/event/tear/random/end()
	if(HE)
		qdel(HE)

/obj/effect/tear/random
	name = "randomensional tear"
	desc = "Мощный пространственно-временной разрыв."
	leader = null
	possible_mobs = list()
	var/static/list/hostile_mobs

/obj/effect/tear/random/get_ru_names()
	return list(
		NOMINATIVE = "рандомысленный разрыв",
		GENITIVE = "рандомысленного разрыва",
		DATIVE = "рандомысленному разрыву",
		ACCUSATIVE = "рандомысленный разрыв",
		INSTRUMENTAL = "рандомысленным разрывом",
		PREPOSITIONAL = "рандомысленном разрыве"
	)

/obj/effect/tear/random/Initialize(mapload)
	if(!hostile_mobs)
		hostile_mobs = list()
		// It works like the create_random_mob proc, but with only aggressive mobs.
		for(var/T in typesof(/mob/living/simple_animal))
			var/mob/living/simple_animal/SA = T
			if(initial(SA.gold_core_spawnable) == HOSTILE_SPAWN)
				hostile_mobs += T

	possible_mobs = hostile_mobs
	leader = pick(hostile_mobs)
	return ..()

