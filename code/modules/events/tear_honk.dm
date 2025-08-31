/datum/event/tear/honk
	name = "honkmensional tear"
	notify_title = "Хонкомысленный разрыв"
	notify_image = "clowngoblin"

	var/obj/effect/tear/honk/HE

/datum/event/tear/honk/spawn_tear(location)
	HE = new /obj/effect/tear/honk(location)

/datum/event/tear/honk/announce()
	GLOB.minor_announcement.announce(
		"На борту станции зафиксирована Хонканомалия. Предполагаемая локация: [impact_area.name].",
		ANNOUNCE_HONKANOMALY_RU,
		'sound/items/airhorn.ogg'
	)

/datum/event/tear/honk/end()
	if(HE)
		qdel(HE)

/obj/effect/tear/honk
	name = "honkmensional tear"
	desc = "Пространственно-здравомысленный разрыв."
	leader = /mob/living/simple_animal/hostile/retaliate/clown/goblin/cluwne
	possible_mobs = list(
		/mob/living/simple_animal/hostile/retaliate/clown,
		/mob/living/simple_animal/hostile/retaliate/clown/goblin
	)

/obj/effect/tear/honk/get_ru_names()
	return list(
		NOMINATIVE = "хонкомысленный разрыв",
		GENITIVE = "хонкомысленного разрыва",
		DATIVE = "хонкомысленному разрыву",
		ACCUSATIVE = "хонкомысленный разрыв",
		INSTRUMENTAL = "хонкомысленным разрывом",
		PREPOSITIONAL = "хонкомысленном разрыве"
	)
