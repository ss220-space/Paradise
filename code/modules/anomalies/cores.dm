// Embedded signaller used in anomalies.
/obj/item/assembly/signaler/core
	name = "anomaly core"
	desc = "Нейтрализованное ядро ​​аномалии. Вероятно, оно пригодится для исследований."
	gender = NEUTER
	icon_state = "core_bluespace_t2"
	item_state = "electronic"
	resistance_flags = FIRE_PROOF
	receiving = TRUE
	/// The type of anomaly that leaves nuclei of this type.
	var/anomaly_type = /obj/effect/old_anomaly
	/// The strength of the anomaly at the moment of stabilization. Used to scale some effects of items using anomaly cores.
	var/charge = 50
	/// The level of the anomaly from which the core was collected.
	var/tier = 0
	/// Moment whet this core was created. Used to prevent the core from instantly disintegrating when charging.
	var/born_moment = 0
	COOLDOWN_DECLARE(anomaly_toch_cooldown)

/obj/item/assembly/signaler/core/get_ru_names()
	return list(
		NOMINATIVE = "ядро аномалии", \
		GENITIVE = "ядра аномалии", \
		DATIVE = "ядру аномалии", \
		ACCUSATIVE = "ядро аномалии", \
		INSTRUMENTAL = "ядром аномалии", \
		PREPOSITIONAL = "ядре аномалии"
	)

/obj/item/assembly/signaler/core/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] засовыва[pluralize_ru(user.gender,"ет","ют")] [declent_ru(ACCUSATIVE)] себе в рот. Похоже [genderize_ru(user.gender, "он", "она", "оно", "они")] пыта[pluralize_ru(user.gender,"ет","ют")]ся убить себя!"))
	return OXYLOSS | BRUTELOSS

/obj/item/assembly/signaler/core/examine(mob/user)
	. = ..()
	. += span_notice("Текущий заряд: [charge].")
	. += span_notice("Текущая сила: [get_strength()].")

/obj/item/assembly/signaler/core/New(spawnloc, charge)
	. = ..()
	if(!charge)
		charge = iscoreempty(src) ? 0 : rand(51, 60)

	src.charge = charge
	born_moment = world.time

// Used in old anomalies.
/obj/item/assembly/signaler/core/receive_signal(datum/signal/signal)
	if(!..())
		return

	for(var/obj/effect/old_anomaly/anomaly in get_turf(src))
		anomaly.anomalyNeutralize()

/obj/item/assembly/signaler/core/attack_self()
	return

/*
100 of tier 1 == 50 of tier 2 == 25 of tier 3
100 of tier 3 == 200 of tier 2 == 400 of tier 1
*/
/obj/item/assembly/signaler/core/proc/get_strength()
	return round(charge * (1 << (tier - 1)) * (tier != 4 ? 1 : 1.5))

// ============================ Tier 1 ===================================
/obj/item/assembly/signaler/core/tier1
	name = "пустое ядро малой аномалии"
	desc = "Не похоже, что силы аномалии на момент стабилизации хватило, чтобы придать этому ядру какие-то свойства. \
			Вероятно, его можно как-то зарядить."
	icon_state = "core_empty_t1"
	anomaly_type = null
	origin_tech = "materials=3"
	tier = 1

/obj/item/assembly/signaler/core/tier1/get_ru_names()
	return list(
		NOMINATIVE = "пустое ядро малой аномалии", \
		GENITIVE = "пустого ядра малой аномалии", \
		DATIVE = "пустому ядру малой аномалии", \
		ACCUSATIVE = "пустое ядро малой аномалии", \
		INSTRUMENTAL = "пустым ядром малой аномалии", \
		PREPOSITIONAL = "пустом ядре малой аномалии"
	)


/obj/item/assembly/signaler/core/atmospheric/tier1
	name = "ядро малой атмосферной аномалии"
	desc = "Стабилизированное ядро ​малой атмосферной аномалии. На ощупь прохладное. Вероятно, оно пригодится для исследований."
	icon_state = "core_atmos_t1"
	anomaly_type = /obj/effect/anomaly/atmospheric/tier1
	origin_tech = "plasmatech=5"
	tier = 1

/obj/item/assembly/signaler/core/atmospheric/tier1/get_ru_names()
	return list(
		NOMINATIVE = "ядро малой атмосферной аномалии", \
		GENITIVE = "ядра малой атмосферной аномалии", \
		DATIVE = "ядру малой атмосферной аномалии", \
		ACCUSATIVE = "ядро малой атмосферной аномалии", \
		INSTRUMENTAL = "ядром малой атмосферной аномалии", \
		PREPOSITIONAL = "ядре малой атмосферной аномалии"
	)

/obj/item/assembly/signaler/core/gravitational/tier1
	name = "ядро малой гравитационной аномалии"
	desc = "Нейтрализованное ядро малой ​​гравитационной аномалии. Слегка легче, чем выглядит. Вероятно, оно пригодится для исследований."
	icon_state = "core_grav_t1"
	anomaly_type = /obj/effect/anomaly/gravitational/tier1
	origin_tech = "magnets=5"
	tier = 1

/obj/item/assembly/signaler/core/gravitational/tier1/get_ru_names()
	return list(
		NOMINATIVE = "ядро малой гравитационной аномалии", \
		GENITIVE = "ядра малой гравитационной аномалии", \
		DATIVE = "ядру малой гравитационной аномалии", \
		ACCUSATIVE = "ядро малой гравитационной аномалии", \
		INSTRUMENTAL = "ядром малой гравитационной аномалии", \
		PREPOSITIONAL = "ядре малой гравитационной аномалии"
	)

/obj/item/assembly/signaler/core/energetic/tier1
	name = "ядро малой ​​энергетической аномалии"
	desc = "Стабилизированное ядро малой ​​энергетической аномалии. Прикосновение к нему вызывает лёгкое покалывание. Вероятно, оно пригодится для исследований."
	icon_state = "core_energ_t1"
	anomaly_type = /obj/effect/anomaly/energetic/tier1
	origin_tech = "powerstorage=5"
	tier = 1

/obj/item/assembly/signaler/core/energetic/tier1/get_ru_names()
	return list(
		NOMINATIVE = "ядро малой ​​энергетической аномалии", \
		GENITIVE = "ядра малой ​​энергетической аномалии", \
		DATIVE = "ядру малой ​​энергетической аномалии", \
		ACCUSATIVE = "ядро малой ​​энергетической аномалии", \
		INSTRUMENTAL = "ядром малой ​​энергетической аномалии", \
		PREPOSITIONAL = "ядре малой ​​энергетической аномалии"
	)

/obj/item/assembly/signaler/core/bluespace/tier1
	name = "ядро малой ​​блюспейс аномалии"
	desc = "Стабилизированное ядро ​малой ​блюспейс аномалии. Оно изредка, на долю секунды, исчезает из виду. Вероятно, оно пригодится для исследований."
	icon_state = "core_bluespace_t1"
	anomaly_type = /obj/effect/anomaly/bluespace/tier1
	origin_tech = "bluespace=5"
	tier = 1

/obj/item/assembly/signaler/core/bluespace/tier1/get_ru_names()
	return list(
		NOMINATIVE = "ядро малой ​​блюспейс аномалии", \
		GENITIVE = "ядра малой ​​блюспейс аномалии", \
		DATIVE = "ядру малой ​​блюспейс аномалии", \
		ACCUSATIVE = "ядро малой ​​блюспейс аномалии", \
		INSTRUMENTAL = "ядром малой ​​блюспейс аномалии", \
		PREPOSITIONAL = "ядре малой ​​блюспейс аномалии"
	)

/obj/item/assembly/signaler/core/vortex/tier1
	name = "ядро малой вихревой аномалии"
	desc = "Стабилизированное ядро малой ​​вихревой аномалии. Оно изредка подёргивается. Вероятно, оно пригодится для исследований."
	icon_state = "core_vortex_t1"
	anomaly_type = /obj/effect/anomaly/vortex/tier1
	origin_tech = "engineering=5"
	tier = 1

/obj/item/assembly/signaler/core/vortex/tier1/get_ru_names()
	return list(
		NOMINATIVE = "ядро малой вихревой аномалии", \
		GENITIVE = "ядра малой вихревой аномалии", \
		DATIVE = "ядру малой вихревой аномалии", \
		ACCUSATIVE = "ядро малой вихревой аномалии", \
		INSTRUMENTAL = "ядром малой вихревой аномалии", \
		PREPOSITIONAL = "ядре малой вихревой аномалии"
	)


// ============================ Tier 2 ===================================
/obj/item/assembly/signaler/core/tier2
	name = "пустое ядро аномалии"
	desc = "Не похоже, что силы аномалии на момент стабилизации хватило, чтобы придать ядру какие-то свойства. \
			Вероятно, его можно как-то зарядить."
	icon_state = "core_empty_t2"
	anomaly_type = null
	origin_tech = "materials=5" // not clonable by experimentor
	tier = 2

/obj/item/assembly/signaler/core/tier2/get_ru_names()
	return list(
		NOMINATIVE = "пустое ядро аномалии", \
		GENITIVE = "пустого ядра аномалии", \
		DATIVE = "пустому ядру аномалии", \
		ACCUSATIVE = "пустое ядро аномалии", \
		INSTRUMENTAL = "пустым ядром аномалии", \
		PREPOSITIONAL = "пустом ядре аномалии"
	)

/obj/item/assembly/signaler/core/atmospheric/tier2
	name = "pyroclastic anomaly core"
	desc = "Стабилизированное ядро ​атмосферной аномалии. На ощупь теплое. Вероятно, оно пригодится для исследований."
	icon_state = "core_atmos_t2"
	anomaly_type = /obj/effect/anomaly/atmospheric/tier2
	origin_tech = "plasmatech=7"
	tier = 2

/obj/item/assembly/signaler/core/gravitational/tier2
	name = "gravitational anomaly core"
	desc = "Стабилизированное ядро ​​гравитационной аномалии. Гораздо тяжелее, чем кажется. Вероятно, оно пригодится для исследований."
	icon_state = "core_grav_t2"
	anomaly_type = /obj/effect/anomaly/gravitational/tier2
	origin_tech = "magnets=7"
	tier = 2

/obj/item/assembly/signaler/core/gravitational/tier2/get_ru_names()
	return list(
		NOMINATIVE = "ядро гравитационной аномалии", \
		GENITIVE = "ядра гравитационной аномалии", \
		DATIVE = "ядру гравитационной аномалии", \
		ACCUSATIVE = "ядро гравитационной аномалии", \
		INSTRUMENTAL = "ядром гравитационной аномалии", \
		PREPOSITIONAL = "ядре гравитационной аномалии"
	)

/obj/item/assembly/signaler/core/energetic/tier2
	name = "flux anomaly core"
	desc = "Стабилизированное ядро ​​энергетической аномалии. Прикосновение к нему вызывает лёгкое покалывание. Вероятно, оно пригодится для исследований."
	icon_state = "core_energ_t2"
	anomaly_type = /obj/effect/anomaly/energetic/tier2
	origin_tech = "powerstorage=7"
	tier = 2

/obj/item/assembly/signaler/core/energetic/tier2/get_ru_names()
	return list(
		NOMINATIVE = "ядро ​​энергетической аномалии", \
		GENITIVE = "ядра ​​энергетической аномалии", \
		DATIVE = "ядру ​​энергетической аномалии", \
		ACCUSATIVE = "ядро ​​энергетической аномалии", \
		INSTRUMENTAL = "ядром ​​энергетической аномалии", \
		PREPOSITIONAL = "ядре ​​энергетической аномалии"
	)

/obj/item/assembly/signaler/core/bluespace/tier2
	name = "bluespace anomaly core"
	desc = "Стабилизированное ядро ​​блюспейс аномалии. Оно то появляется, то исчезает из виду. Вероятно, оно пригодится для исследований."
	icon_state = "core_bluespace_t2"
	anomaly_type = /obj/effect/anomaly/bluespace/tier2
	origin_tech = "bluespace=7"
	tier = 2

/obj/item/assembly/signaler/core/bluespace/tier2/get_ru_names()
	return list(
		NOMINATIVE = "ядро ​​блюспейс аномалии", \
		GENITIVE = "ядра ​​блюспейс аномалии", \
		DATIVE = "ядру ​​блюспейс аномалии", \
		ACCUSATIVE = "ядро ​​блюспейс аномалии", \
		INSTRUMENTAL = "ядром ​​блюспейс аномалии", \
		PREPOSITIONAL = "ядре ​​блюспейс аномалии"
	)

/obj/item/assembly/signaler/core/vortex/tier2
	name = "vortex anomaly core"
	desc = "Стабилизированное ядро ​​вихревой аномалии. Оно слегка трясётся, как будто на него воздействует некая невидимая сила. Вероятно, оно пригодится для исследований."
	icon_state = "core_vortex_t2"
	anomaly_type = /obj/effect/anomaly/vortex/tier2
	origin_tech = "engineering=7"
	tier = 2

/obj/item/assembly/signaler/core/vortex/tier2/get_ru_names()
	return list(
		NOMINATIVE = "ядро ​​вихревой аномалии", \
		GENITIVE = "ядра ​​вихревой аномалии", \
		DATIVE = "ядру ​​вихревой аномалии", \
		ACCUSATIVE = "ядро ​​вихревой аномалии", \
		INSTRUMENTAL = "ядром ​​вихревой аномалии", \
		PREPOSITIONAL = "ядре ​​вихревой аномалии"
	)


// ============================ Tier 3 ===================================
/obj/item/assembly/signaler/core/tier3
	name = "пустое ядро большой аномалии"
	desc = "Не похоже, что силы аномалии на момент стабилизации хватило, чтобы придать ядру какие-то свойства. \
			Вероятно, его можно как-то зарядить."
	icon_state = "core_empty_t3"
	anomaly_type = null
	origin_tech = "materials=7" // Sorry, not clonable by experimentor
	tier = 3

/obj/item/assembly/signaler/core/tier3/get_ru_names()
	return list(
		NOMINATIVE = "пустое ядро большой аномалии", \
		GENITIVE = "пустого ядра большой аномалии", \
		DATIVE = "пустому ядру большой аномалии", \
		ACCUSATIVE = "пустое ядро большой аномалии", \
		INSTRUMENTAL = "пустым ядром большой аномалии", \
		PREPOSITIONAL = "пустом ядре большой аномалии"
	)

/obj/item/assembly/signaler/core/atmospheric/tier3
	name = "ядро большой атмосферной аномалии"
	desc = "Стабилизированное ядро большой атмосферной аномалии. От одного его вида вас бросает то в жар, то в холод, причём буквально."
	icon_state = "core_atmos_t3"
	anomaly_type = /obj/effect/anomaly/atmospheric/tier3
	origin_tech = "plasmatech=8"
	tier = 3

/obj/item/assembly/signaler/core/atmospheric/tier3/get_ru_names()
	return list(
		NOMINATIVE = "ядро большой атмосферной аномалии", \
		GENITIVE = "ядра большой атмосферной аномалии", \
		DATIVE = "ядру большой атмосферной аномалии", \
		ACCUSATIVE = "ядро большой атмосферной аномалии", \
		INSTRUMENTAL = "ядром большой атмосферной аномалии", \
		PREPOSITIONAL = "ядре большой атмосферной аномалии"
	)

/obj/item/assembly/signaler/core/atmospheric/tier3/suicide_act(mob/living/user)
	..()
	user.adjust_fire_stacks(30)
	user.IgniteMob()
	return FIRELOSS

/obj/item/assembly/signaler/core/atmospheric/tier3/forceMove(atom/destination)
	if(!ishuman(destination))
		STOP_PROCESSING(SSobj, src)
		return ..()

	START_PROCESSING(SSobj, src)
	if(!prob(1))
		return ..()

	var/mob/living/carbon/human/H = destination
	H.adjust_fire_stacks(charge/10)
	H.IgniteMob()
	return ..()

/obj/item/assembly/signaler/core/atmospheric/tier3/process()
	var/mob/living/carbon/human/H = loc
	if(!istype(H))
		return

	if(prob(90))
		return

	if(H.bodytemperature < T0C - 50)
		visible_message("[capitalize(declent_ru(NOMINATIVE))] реагирует на контакт с холодным объектом, испуская языки пламени!")
		H.adjust_fire_stacks(round(get_strength() / 30 + 0.5))
		H.IgniteMob()
		return

	if(H.bodytemperature <= T0C + 100)
		return

	visible_message("[capitalize(declent_ru(NOMINATIVE))] реагирует на контакт с горячим объектом, значительно охлаждая окружающую среду!")
	H.apply_status_effect(/datum/status_effect/freon)
	H.ExtinguishMob()
	H.adjust_bodytemperature(-get_strength())


/obj/item/assembly/signaler/core/gravitational/tier3
	name = "ядро большой гравитационной аномалии"
	desc = "Нейтрализованное ядро большой ​​гравитационной аномалии. Вы чувствуете сильное несоответствие веса многих окружающих предметов с их внешним видом."
	icon_state = "core_grav_t3"
	anomaly_type = /obj/effect/anomaly/gravitational/tier3
	origin_tech = "magnets=8"
	var/atom/old_owner = null
	tier = 3

/obj/item/assembly/signaler/core/gravitational/tier3/get_ru_names()
	return list(
		NOMINATIVE = "ядро большой гравитационной аномалии", \
		GENITIVE = "ядра большой гравитационной аномалии", \
		DATIVE = "ядру большой гравитационной аномалии", \
		ACCUSATIVE = "ядро большой гравитационной аномалии", \
		INSTRUMENTAL = "ядром большой гравитационной аномалии", \
		PREPOSITIONAL = "ядре большой гравитационной аномалии"
	)

/obj/item/assembly/signaler/core/gravitational/tier3/suicide_act(mob/user)
	..()
	user.visible_message(span_suicide("[user] взрыва[pluralize_ru(user.gender,"ет","ют")]ся из-за возникшего гравитационного колодца!"), \
						span_suicide("Вы взрываетесь из-за возникшего гравитационного колодца!"),
						span_suicide("Вы слышите громкий хлопок!"))
	user.gib()
	return OBLITERATION

/obj/item/assembly/signaler/core/gravitational/tier3/Initialize(mapload)
	. = ..()
	old_owner = get_external_loc()
	update_gravity(TRUE)

// Mobs will be in reversed gravity. Items will be without gravity.
/obj/item/assembly/signaler/core/gravitational/tier3/proc/update_gravity(restart = FALSE)
	if(restart)
		addtimer(CALLBACK(src, PROC_REF(update_gravity), TRUE), 5 SECONDS)

	var/atom/new_owner = get_external_loc()
	if(old_owner == new_owner && old_owner.get_gravity() == -1)
		return

	old_owner.remove_gravity_source("core_grav")
	if(ismob(new_owner))
		new_owner.add_gravity("core_grav", -(new_owner.get_gravity() + 2))

	if(isitem(new_owner))
		new_owner.add_gravity("core_grav", -(new_owner.get_gravity() + 1))

	old_owner = new_owner

/obj/item/assembly/signaler/core/gravitational/tier3/forceMove(atom/destination)
	. = ..()
	update_gravity()

/obj/item/assembly/signaler/core/energetic/tier3
	name = "ядро большой ​​энергетической аномалии"
	desc = "Стабилизированное ядро большой ​​энергетической аномалии. Вокруг ядра периодически возникают электрические разряды. Окружающая электроника напряженно гудит."
	icon_state = "core_energ_t3"
	anomaly_type = /obj/effect/anomaly/energetic/tier3
	origin_tech = "powerstorage=8"
	tier = 3

/obj/item/assembly/signaler/core/energetic/tier3/get_ru_names()
	return list(
		NOMINATIVE = "ядро большой ​​энергетической аномалии", \
		GENITIVE = "ядра большой ​​энергетической аномалии", \
		DATIVE = "ядру большой ​​энергетической аномалии", \
		ACCUSATIVE = "ядро большой ​​энергетической аномалии", \
		INSTRUMENTAL = "ядром большой ​​энергетической аномалии", \
		PREPOSITIONAL = "ядре большой ​​энергетической аномалии"
	)

/obj/item/assembly/signaler/core/energetic/tier3/Bump(atom/bumped_atom)
	. = ..()
	try_shock(bumped_atom)

/obj/item/assembly/signaler/core/energetic/tier3/suicide_act(mob/living/user)
	..()
	user.electrocute_act(600, "[declent_ru(GENITIVE)]")
	return FIRELOSS

/obj/item/assembly/signaler/core/energetic/tier3/proc/try_shock(atom/target)
	if(!iscarbon(target))
		return FALSE

	visible_message(span_warning("[declent_ru(NOMINATIVE)] внезапно испустил[genderize_ru(gender, "", "а", "о", "и")] электрический разряд!"))
	var/mob/living/carbon/human/H = target
	if(H.electrocute_act(charge, "[declent_ru(GENITIVE)]"))
		do_sparks(max(1, charge / 20), FALSE, src)
		return TRUE

	return FALSE

/obj/item/assembly/signaler/core/energetic/tier3/forceMove(atom/destination)
	if(!try_shock(destination))
		return ..()
	else
		return FALSE

/obj/item/assembly/signaler/core/bluespace/tier3
	name = "ядро большой ​​блюспейс аномалии"
	desc = "Стабилизированное ядро ​большой ​блюспейс аномалии. Пространство вокруг него постоянно искревляется."
	icon_state = "core_bluespace_t3"
	anomaly_type = /obj/effect/anomaly/bluespace/tier3
	origin_tech = "bluespace=8"
	tier = 3

/obj/item/assembly/signaler/core/bluespace/tier3/get_ru_names()
	return list(
		NOMINATIVE = "ядро большой ​​блюспейс аномалии", \
		GENITIVE = "ядра большой ​​блюспейс аномалии", \
		DATIVE = "ядру большой ​​блюспейс аномалии", \
		ACCUSATIVE = "ядро большой ​​блюспейс аномалии", \
		INSTRUMENTAL = "ядром большой ​​блюспейс аномалии", \
		PREPOSITIONAL = "ядре большой ​​блюспейс аномалии"
	)

/obj/item/assembly/signaler/core/bluespace/tier3/suicide_act(mob/user)
	..()
	user.gib()
	for(var/obj/item/organ/internal/O in range(2))
		if(!isturf(O.loc))
			continue

		do_teleport(O, O, 2, asoundin = 'sound/effects/phasein.ogg')

	return OBLITERATION

/obj/item/assembly/signaler/core/bluespace/tier3/Bump(atom/bumped_atom)
	. = ..()
	try_teleport()

/obj/item/assembly/signaler/core/bluespace/tier3/proc/try_teleport()
	if(prob(80) || !ismob(loc))
		return FALSE

	visible_message(span_warning("[declent_ru(NOMINATIVE)] внезапно телепортируется!"))
	return do_teleport(src, src, 2, asoundin = 'sound/effects/phasein.ogg')

/obj/item/assembly/signaler/core/bluespace/tier3/forceMove(atom/destination)
	if(!try_teleport())
		return ..()
	else
		return FALSE


/obj/item/assembly/signaler/core/vortex/tier3
	name = "ядро большой вихревой аномалии"
	desc = "Стабилизированное ядро большой ​​вихревой аномалии. Предметы вокруг ядра опасно подрагивают."
	icon_state = "core_vortex_t3"
	anomaly_type = /obj/effect/anomaly/vortex/tier3
	origin_tech = "engineering=8"
	tier = 3

/obj/item/assembly/signaler/core/vortex/tier3/get_ru_names()
	return list(
		NOMINATIVE = "ядро большой вихревой аномалии",
		GENITIVE = "ядра большой вихревой аномалии",
		DATIVE = "ядру большой вихревой аномалии",
		ACCUSATIVE = "ядро большой вихревой аномалии",
		INSTRUMENTAL = "ядром большой вихревой аномалии",
		PREPOSITIONAL = "ядре большой вихревой аномалии"
	)


// ============================ Tier4 (admin spawn only) ===================================
/obj/item/assembly/signaler/core/tier3/tier4
	name = "пустое ядро колоссальной аномалии"
	desc = "Не похоже что силы аномалии на момент стабилизации хватило, чтобы придать ядру какие-то свойства. \
			Вероятно, его можно как-то зарядить. У вас стойкое чувство, что его не должно здесь находиться."
	icon_state = "core_empty_t3"
	anomaly_type = null
	origin_tech = "materials=10" // Sorry, not clonable by experimentor
	tier = 4

/obj/item/assembly/signaler/core/tier3/tier4/get_ru_names()
	return list(
		NOMINATIVE = "пустое ядро колоссальной аномалии", \
		GENITIVE = "пустого ядра колоссальной аномалии", \
		DATIVE = "пустому ядру колоссальной аномалии", \
		ACCUSATIVE = "пустое ядро колоссальной аномалии", \
		INSTRUMENTAL = "пустым ядром колоссальной аномалии", \
		PREPOSITIONAL = "пустом ядре колоссальной аномалии"
	)

/obj/item/assembly/signaler/core/atmospheric/tier3/tier4
	name = "ядро колоссальной атмосферной аномалии"
	desc = "Стабилизированное ядро колоссальной атмосферной аномалии. У вас стойкое чувство, что его не должно здесь находиться."
	icon_state = "core_atmos_t3"
	anomaly_type = /obj/effect/anomaly/atmospheric/tier4
	origin_tech = "plasmatech=11"
	tier = 4

/obj/item/assembly/signaler/core/atmospheric/tier3/tier4/get_ru_names()
	return list(
		NOMINATIVE = "ядро колоссальной атмосферной аномалии", \
		GENITIVE = "ядра колоссальной атмосферной аномалии", \
		DATIVE = "ядру колоссальной атмосферной аномалии", \
		ACCUSATIVE = "ядро колоссальной атмосферной аномалии", \
		INSTRUMENTAL = "ядром колоссальной атмосферной аномалии", \
		PREPOSITIONAL = "ядре колоссальной атмосферной аномалии"
	)

/obj/item/assembly/signaler/core/gravitational/tier3/tier4
	name = "ядро колоссальной гравитационной аномалии"
	desc = "Нейтрализованное ядро колоссальной ​​гравитационной аномалии. У вас стойкое чувство, что его не должно здесь находиться."
	icon_state = "core_grav_t3"
	anomaly_type = /obj/effect/anomaly/gravitational/tier4
	origin_tech = "magnets=11"
	tier = 4

/obj/item/assembly/signaler/core/gravitational/tier3/tier4/get_ru_names()
	return list(
		NOMINATIVE = "ядро колоссальной гравитационной аномалии", \
		GENITIVE = "ядра колоссальной гравитационной аномалии", \
		DATIVE = "ядру колоссальной гравитационной аномалии", \
		ACCUSATIVE = "ядро колоссальной гравитационной аномалии", \
		INSTRUMENTAL = "ядром колоссальной гравитационной аномалии", \
		PREPOSITIONAL = "ядре колоссальной гравитационной аномалии"
	)

/obj/item/assembly/signaler/core/energetic/tier3/tier4
	name = "ядро колоссальной ​​энергетической аномалии"
	desc = "Стабилизированное ядро колоссальной ​​энергетической аномалии. У вас стойкое чувство, что его не должно здесь находиться."
	icon_state = "core_energ_t3"
	anomaly_type = /obj/effect/anomaly/energetic/tier4
	origin_tech = "powerstorage=11"
	tier = 4

/obj/item/assembly/signaler/core/energetic/tier3/tier4/get_ru_names()
	return list(
		NOMINATIVE = "ядро колоссальной ​​энергетической аномалии", \
		GENITIVE = "ядра колоссальной ​​энергетической аномалии", \
		DATIVE = "ядру колоссальной ​​энергетической аномалии", \
		ACCUSATIVE = "ядро колоссальной ​​энергетической аномалии", \
		INSTRUMENTAL = "ядром колоссальной ​​энергетической аномалии", \
		PREPOSITIONAL = "ядре колоссальной ​​энергетической аномалии"
	)

/obj/item/assembly/signaler/core/bluespace/tier3/tier4
	name = "ядро колоссальной ​​блюспейс аномалии"
	desc = "Стабилизированное ядро ​большой ​блюспейс аномалии. У вас стойкое чувство, что его не должно здесь находиться."
	icon_state = "core_bluespace_t3"
	anomaly_type = /obj/effect/anomaly/bluespace/tier4
	origin_tech = "bluespace=11"
	tier = 4

/obj/item/assembly/signaler/core/bluespace/tier3/tier4/get_ru_names()
	return list(
		NOMINATIVE = "ядро колоссальной ​​блюспейс аномалии", \
		GENITIVE = "ядра колоссальной ​​блюспейс аномалии", \
		DATIVE = "ядру колоссальной ​​блюспейс аномалии", \
		ACCUSATIVE = "ядро колоссальной ​​блюспейс аномалии", \
		INSTRUMENTAL = "ядром колоссальной ​​блюспейс аномалии", \
		PREPOSITIONAL = "ядре колоссальной ​​блюспейс аномалии"
	)

/obj/item/assembly/signaler/core/vortex/tier3/tier4
	name = "ядро колоссальной вихревой аномалии"
	desc = "Стабилизированное ядро колоссальной ​​вихревой аномалии. У вас стойкое чувство, что его не должно здесь находиться."
	icon_state = "core_vortex_t3"
	anomaly_type = /obj/effect/anomaly/vortex/tier4
	origin_tech = "engineering=11"
	tier = 4

/obj/item/assembly/signaler/core/vortex/tier3/tier4/get_ru_names()
	return list(
		NOMINATIVE = "ядро колоссальной вихревой аномалии", \
		GENITIVE = "ядра колоссальной вихревой аномалии", \
		DATIVE = "ядру колоссальной вихревой аномалии", \
		ACCUSATIVE = "ядро колоссальной вихревой аномалии", \
		INSTRUMENTAL = "ядром колоссальной вихревой аномалии", \
		PREPOSITIONAL = "ядре колоссальной вихревой аномалии"
	)
