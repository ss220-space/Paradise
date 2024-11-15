// Embedded signaller used in anomalies.
/obj/item/assembly/signaler/anomaly
	name = "anomaly core"
	desc = "The neutralized core of an anomaly. It'd probably be valuable for research."
	icon_state = "anomaly_core"
	item_state = "electronic"
	resistance_flags = FIRE_PROOF
	receiving = TRUE
	/// The type of anomaly that leaves nuclei of this type.
	var/anomaly_type = /obj/effect/old_anomaly
	/// The strength of the anomaly at the moment of stabilization. Used to scale some effects of items using anomaly cores.
	var/strenght = 50
	/// The level of the anomaly from which the core was collected.
	var/tier = 0

/obj/item/assembly/signaler/anomaly/tier2/New(spawnloc, strenght = rand(40, 60))
	. = ..()
	src.strenght = strenght

/obj/item/assembly/signaler/anomaly/tier2/receive_signal(datum/signal/signal)
	if(..())
		for(var/obj/effect/old_anomaly/A in get_turf(src))
			A.anomalyNeutralize()

/obj/item/assembly/signaler/anomaly/attack_self()
	return

/*
100 of tier 1 == 50 of tier 2 == 25 of tier 3
100 of tier 3 == 200 of tier 2 == 400 of tier 1
*/
/obj/item/assembly/signaler/anomaly/proc/get_strenght()
	return strenght * (1 << (tier - 1))

// ============================ Tier 1 ===================================
/obj/item/assembly/signaler/anomaly/tier1
	name = "пустое ядро малой аномалии"
	ru_names = list(NOMINATIVE = "пустое ядро малой аномалии", \
					GENITIVE = "пустого ядра малой аномалии", \
					DATIVE = "пустому ядру малой аномалии", \
					ACCUSATIVE = "пустое ядро малой аномалии", \
					INSTRUMENTAL = "пустым ядром малой аномалии", \
					PREPOSITIONAL = "пустом ядре малой аномалии")
	desc = "Вероятно, его можно как-то зарядить."
	icon_state = "pyro_core"
	anomaly_type = null
	origin_tech = "materials=3" // clonable by experimentor
	tier = 1

/obj/item/assembly/signaler/anomaly/tier1/pyro
	name = "ядро малой атмосферной аномалии"
	ru_names = list(NOMINATIVE = "ядро малой атмосферной аномалии", \
					GENITIVE = "ядра малой атмосферной аномалии", \
					DATIVE = "ядру малой атмосферной аномалии", \
					ACCUSATIVE = "ядро малой атмосферной аномалии", \
					INSTRUMENTAL = "ядром малой атмосферной аномалии", \
					PREPOSITIONAL = "ядре малой атмосферной аномалии")
	desc = "Стабилизированное ядро ​малой атмосферной аномалии. На ощупь прохладное. Вероятно, оно пригодится для исследований."
	icon_state = "pyro_core"
	anomaly_type = /obj/effect/anomaly/pyro/tier1
	origin_tech = "plasmatech=5"

/obj/item/assembly/signaler/anomaly/tier1/grav
	name = "ядро малой гравитационной аномалии"
	ru_names = list(NOMINATIVE = "ядро малой гравитационной аномалии", \
					GENITIVE = "ядра малой гравитационной аномалии", \
					DATIVE = "ядру малой гравитационной аномалии", \
					ACCUSATIVE = "ядро малой гравитационной аномалии", \
					INSTRUMENTAL = "ядром малой гравитационной аномалии", \
					PREPOSITIONAL = "ядре малой гравитационной аномалии")
	desc = "Нейтрализованное ядро малой ​​гравитационной аномалии. Слегка легче, чем выглядит. Вероятно, оно пригодится для исследований."
	icon_state = "grav_core"
	anomaly_type = /obj/effect/anomaly/grav/tier1
	origin_tech = "magnets=5"

/obj/item/assembly/signaler/anomaly/tier1/flux
	name = "ядро малой ​​энергетической аномалии"
	ru_names = list(NOMINATIVE = "ядро малой ​​энергетической аномалии", \
					GENITIVE = "ядра малой ​​энергетической аномалии", \
					DATIVE = "ядру малой ​​энергетической аномалии", \
					ACCUSATIVE = "ядро малой ​​энергетической аномалии", \
					INSTRUMENTAL = "ядром малой ​​энергетической аномалии", \
					PREPOSITIONAL = "ядре малой ​​энергетической аномалии")
	desc = "Стабилизированное ядро малой ​​энергетической аномалии. Прикосновение к нему вызывает легкое покалывание. Вероятно, оно пригодится для исследований."
	icon_state = "flux_core"
	anomaly_type = /obj/effect/anomaly/flux/tier1
	origin_tech = "powerstorage=5"

/obj/item/assembly/signaler/anomaly/tier1/bluespace
	name = "ядро малой ​​блюспейс аномалии"
	ru_names = list(NOMINATIVE = "ядро малой ​​блюспейс аномалии", \
					GENITIVE = "ядра малой ​​блюспейс аномалии", \
					DATIVE = "ядру малой ​​блюспейс аномалии", \
					ACCUSATIVE = "ядро малой ​​блюспейс аномалии", \
					INSTRUMENTAL = "ядром малой ​​блюспейс аномалии", \
					PREPOSITIONAL = "ядре малой ​​блюспейс аномалии")
	desc = "Стабилизированное ядро ​малой ​блюспейс аномалии. Оно изредка, на долю секунды, исчезает из виду. Вероятно, оно пригодится для исследований."
	icon_state = "anomaly_core"
	anomaly_type = /obj/effect/anomaly/bluespace/tier1
	origin_tech = "bluespace=5"

/obj/item/assembly/signaler/anomaly/tier1/vortex
	name = "ядро малой вихревой аномалии"
	ru_names = list(NOMINATIVE = "ядро малой вихревой аномалии", \
					GENITIVE = "ядра малой вихревой аномалии", \
					DATIVE = "ядру малой вихревой аномалии", \
					ACCUSATIVE = "ядро малой вихревой аномалии", \
					INSTRUMENTAL = "ядром малой вихревой аномалии", \
					PREPOSITIONAL = "ядре малой вихревой аномалии")
	desc = "Стабилизированное ядро малой ​​вихревой аномалии. Оно изредка подергивается. Вероятно, оно пригодится для исследований."
	icon_state = "vortex_core"
	anomaly_type = /obj/effect/anomaly/vortex/tier1
	origin_tech = "engineering=5"


// ============================ Tier 2 ===================================
/obj/item/assembly/signaler/anomaly/tier2
	name = "пустое ядро аномалии"
	ru_names = list(NOMINATIVE = "пустое ядро аномалии", \
					GENITIVE = "пустого ядра аномалии", \
					DATIVE = "пустому ядру аномалии", \
					ACCUSATIVE = "пустое ядро аномалии", \
					INSTRUMENTAL = "пустым ядром аномалии", \
					PREPOSITIONAL = "пустом ядре аномалии")
	desc = "Вероятно, его можно как-то зарядить."
	icon_state = "pyro_core"
	anomaly_type = null
	origin_tech = "materials=5" // not clonable by experimentor
	tier = 2

/obj/item/assembly/signaler/anomaly/tier2/pyro
	name = "\improper pyroclastic anomaly core"
	desc = "Стабилизированное ядро ​атмосферной аномалии. На ощупь теплое. Вероятно, оно пригодится для исследований."
	icon_state = "pyro_core"
	anomaly_type = /obj/effect/anomaly/pyro/tier2
	origin_tech = "plasmatech=7"

/obj/item/assembly/signaler/anomaly/tier2/grav
	name = "\improper gravitational anomaly core"
	desc = "Стабилизированное ядро ​​гравитационной аномалии. Гораздо тяжелее, чем выглядит. Вероятно, оно пригодится для исследований."
	icon_state = "grav_core"
	anomaly_type = /obj/effect/anomaly/grav/tier2
	origin_tech = "magnets=7"

/obj/item/assembly/signaler/anomaly/tier2/flux
	name = "\improper flux anomaly core"
	desc = "Стабилизированное ядро ​​энергетической аномалии. Прикосновение к нему вызывает легкое покалывание. Вероятно, оно пригодится для исследований."
	icon_state = "flux_core"
	anomaly_type = /obj/effect/anomaly/flux/tier2
	origin_tech = "powerstorage=7"

/obj/item/assembly/signaler/anomaly/tier2/bluespace
	name = "\improper bluespace anomaly core"
	desc = "Стабилизированное ядро ​​блюспейс аномалии. Оно то появляется, то исчезает из виду. Вероятно, оно пригодится для исследований."
	icon_state = "anomaly_core"
	anomaly_type = /obj/effect/anomaly/bluespace/tier2
	origin_tech = "bluespace=7"

/obj/item/assembly/signaler/anomaly/tier2/vortex
	name = "\improper vortex anomaly core"
	desc = "Стабилизированное ядро ​​вихревой аномалии. Оно слегка трясется, как будто на него действует какая-то невидимая сила. Вероятно, оно пригодится для исследований."
	icon_state = "vortex_core"
	anomaly_type = /obj/effect/anomaly/vortex/tier2
	origin_tech = "engineering=7"


// ============================ Tier 3 ===================================
/obj/item/assembly/signaler/anomaly/tier3
	name = "пустое ядро большой аномалии"
	ru_names = list(NOMINATIVE = "пустое ядро большой аномалии", \
					GENITIVE = "пустого ядра большой аномалии", \
					DATIVE = "пустому ядру большой аномалии", \
					ACCUSATIVE = "пустое ядро большой аномалии", \
					INSTRUMENTAL = "пустым ядром большой аномалии", \
					PREPOSITIONAL = "пустом ядре большой аномалии")
	desc = "Вероятно, его можно как-то зарядить."
	icon_state = "pyro_core"
	anomaly_type = null
	origin_tech = "materials=7" // Sorry, not clonable by experimentor
	tier = 3

/obj/item/assembly/signaler/anomaly/tier3/pyro
	name = "ядро большой атмосферной аномалии"
	ru_names = list(NOMINATIVE = "ядро большой атмосферной аномалии", \
					GENITIVE = "ядра большой атмосферной аномалии", \
					DATIVE = "ядру большой атмосферной аномалии", \
					ACCUSATIVE = "ядро большой атмосферной аномалии", \
					INSTRUMENTAL = "ядром большой атмосферной аномалии", \
					PREPOSITIONAL = "ядре большой атмосферной аномалии")
	desc = "Стабилизированное ядро большой атмосферной аномалии. От одного его вида вас бросает то в жар, то в холод, причем буквально."
	icon_state = "pyro_core"
	anomaly_type = /obj/effect/anomaly/pyro/tier3
	origin_tech = "plasmatech=8"

/obj/item/assembly/signaler/anomaly/tier3/grav
	name = "ядро большой гравитационной аномалии"
	ru_names = list(NOMINATIVE = "ядро большой гравитационной аномалии", \
					GENITIVE = "ядра большой гравитационной аномалии", \
					DATIVE = "ядру большой гравитационной аномалии", \
					ACCUSATIVE = "ядро большой гравитационной аномалии", \
					INSTRUMENTAL = "ядром большой гравитационной аномалии", \
					PREPOSITIONAL = "ядре большой гравитационной аномалии")
	desc = "Нейтрализованное ядро большой ​​гравитационной аномалии. Вы чувствуете сильное несоответствие веса многих окружающих предметов с их внешним видом."
	icon_state = "grav_core"
	anomaly_type = /obj/effect/anomaly/grav/tier3
	origin_tech = "magnets=8"

/obj/item/assembly/signaler/anomaly/tier3/flux
	name = "ядро большой ​​энергетической аномалии"
	ru_names = list(NOMINATIVE = "ядро большой ​​энергетической аномалии", \
					GENITIVE = "ядра большой ​​энергетической аномалии", \
					DATIVE = "ядру большой ​​энергетической аномалии", \
					ACCUSATIVE = "ядро большой ​​энергетической аномалии", \
					INSTRUMENTAL = "ядром большой ​​энергетической аномалии", \
					PREPOSITIONAL = "ядре большой ​​энергетической аномалии")
	desc = "Стабилизированное ядро большой ​​энергетической аномалии. Вокруг ядра периодически возникают электрические разряды. Окружающая электроника напряженно гудит."
	icon_state = "flux_core"
	anomaly_type = /obj/effect/anomaly/flux/tier3
	origin_tech = "powerstorage=8"

/obj/item/assembly/signaler/anomaly/tier3/bluespace
	name = "ядро большой ​​блюспейс аномалии"
	ru_names = list(NOMINATIVE = "ядро большой ​​блюспейс аномалии", \
					GENITIVE = "ядра большой ​​блюспейс аномалии", \
					DATIVE = "ядру большой ​​блюспейс аномалии", \
					ACCUSATIVE = "ядро большой ​​блюспейс аномалии", \
					INSTRUMENTAL = "ядром большой ​​блюспейс аномалии", \
					PREPOSITIONAL = "ядре большой ​​блюспейс аномалии")
	desc = "Стабилизированное ядро ​большой ​блюспейс аномалии. Пространство вокруг него постоянно искревляется."
	icon_state = "anomaly_core"
	anomaly_type = /obj/effect/anomaly/bluespace/tier3
	origin_tech = "bluespace=8"

/obj/item/assembly/signaler/anomaly/tier3/vortex
	name = "ядро большой вихревой аномалии"
	ru_names = list(NOMINATIVE = "ядро большой вихревой аномалии", \
					GENITIVE = "ядра большой вихревой аномалии", \
					DATIVE = "ядру большой вихревой аномалии", \
					ACCUSATIVE = "ядро большой вихревой аномалии", \
					INSTRUMENTAL = "ядром большой вихревой аномалии", \
					PREPOSITIONAL = "ядре большой вихревой аномалии")
	desc = "Стабилизированное ядро большой ​​вихревой аномалии. Предметы вокруг ядра опасно подрагивают."
	icon_state = "vortex_core"
	anomaly_type = /obj/effect/anomaly/vortex/tier3
	origin_tech = "engineering=8"
