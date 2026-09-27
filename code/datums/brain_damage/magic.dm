#define LUMIPHOBIA_LIGHT_THRESHOLD 0.2
#define STALKER_SPAWN_RANGE 12

/datum/brain_trauma/magic
	abstract_type = /datum/brain_trauma/magic
	resilience = TRAUMA_RESILIENCE_LOBOTOMY

/datum/brain_trauma/magic/lumiphobia
	name = "Lumiphobia"
	desc = "У пациента необъяснимая болезненная реакция на свет."
	scan_desc = "светочувствительность"
	gain_text = span_warning_alt("Вас неудержимо тянет в темноту.")
	lose_text = span_notice_alt("Свет больше не тревожит вас.")
	COOLDOWN_DECLARE(burn_warning_cooldown)

/datum/brain_trauma/magic/lumiphobia/on_life()
	var/turf/location = owner.loc
	if(!isturf(location) || location.get_lumcount() <= LUMIPHOBIA_LIGHT_THRESHOLD)
		return

	if(COOLDOWN_FINISHED(src, burn_warning_cooldown))
		to_chat(owner, span_warning("<b>Свет обжигает вас!</b>"))
		COOLDOWN_START(src, burn_warning_cooldown, 10 SECONDS)
	owner.take_overall_damage(burn = 3)

/datum/brain_trauma/magic/poltergeist
	name = "Poltergeist"
	desc = "Пациента преследует злобная невидимая сущность."
	scan_desc = "паранормальная активность"
	gain_text = span_warning_alt("Вы чувствуете рядом чьё-то полное ненависти присутствие.")
	lose_text = span_notice_alt("Полное ненависти присутствие рассеивается.")

/datum/brain_trauma/magic/poltergeist/on_life()
	if(!prob(4))
		return

	var/most_violent = -1
	var/obj/item/thrown_item
	for(var/obj/item/candidate in view(5, get_turf(owner)))
		if(candidate.anchored || candidate.throwforce <= most_violent)
			continue
		most_violent = candidate.throwforce
		thrown_item = candidate

	thrown_item?.throw_at(owner, 8, 2)

/datum/brain_trauma/magic/antimagic
	name = "Athaumasia"
	desc = "Пациент полностью инертен к магическим силам."
	scan_desc = "тауматургическая пустота"
	gain_text = span_notice_alt("Вы осознаёте, что магии не может существовать.")
	lose_text = span_notice_alt("Вы осознаёте, что магия, возможно, всё-таки существует.")

/datum/brain_trauma/magic/antimagic/on_gain()
	ADD_TRAIT(owner, TRAIT_ANTIMAGIC, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/magic/antimagic/on_lose(silent)
	REMOVE_TRAIT(owner, TRAIT_ANTIMAGIC, TRAUMA_TRAIT)
	return ..()

/datum/brain_trauma/magic/stalker
	name = "Stalking Phantom"
	desc = "Пациента преследует призрак, которого видит только он сам."
	scan_desc = "экстрасенсорная паранойя"
	gain_text = span_warning_alt("Вам кажется, что кто-то хочет вас убить...")
	lose_text = span_notice_alt("Вы больше не чувствуете чужого взгляда за спиной.")
	var/stalker_type = /obj/effect/client_image_holder/stalker_phantom
	var/obj/effect/client_image_holder/stalker_phantom/stalker
	var/heartbeat_playing = FALSE

/datum/brain_trauma/magic/stalker/Destroy()
	QDEL_NULL(stalker)
	return ..()

/datum/brain_trauma/magic/stalker/on_gain()
	create_stalker()
	return ..()

/datum/brain_trauma/magic/stalker/on_lose(silent)
	stop_heartbeat()
	QDEL_NULL(stalker)
	return ..()

/datum/brain_trauma/magic/stalker/proc/create_stalker()
	QDEL_NULL(stalker)
	var/turf/spawn_turf = locate(owner.x + pick(-STALKER_SPAWN_RANGE, STALKER_SPAWN_RANGE), owner.y + pick(-STALKER_SPAWN_RANGE, STALKER_SPAWN_RANGE), owner.z)
	if(!spawn_turf)
		return
	stalker = new stalker_type(spawn_turf, owner)

/datum/brain_trauma/magic/stalker/on_life()
	if(owner.stat != CONSCIOUS)
		return

	if(QDELETED(stalker) || !stalker.loc || stalker.z != owner.z)
		create_stalker()
		return

	if(get_dist(owner, stalker) <= 1)
		playsound(owner, 'sound/misc/demon_attack1.ogg', 50)
		owner.visible_message(
			span_warning("[DECLENT_RU_CAP(owner, ACCUSATIVE)] разрывают невидимые когти!"),
			span_userdanger("Призрачные когти рвут ваше тело!"),
		)
		owner.take_overall_damage(brute = rand(20, 45))
	else if(prob(60))
		stalker.forceMove(get_step_towards(stalker, owner))

	if(get_dist(owner, stalker) <= 8)
		start_heartbeat()
	else
		stop_heartbeat()

/datum/brain_trauma/magic/stalker/proc/start_heartbeat()
	if(heartbeat_playing)
		return
	heartbeat_playing = TRUE
	SEND_SOUND(owner, sound('sound/effects/heartbeat.ogg', repeat = TRUE, channel = CHANNEL_HEARTBEAT, volume = 40))

/datum/brain_trauma/magic/stalker/proc/stop_heartbeat()
	if(!heartbeat_playing)
		return
	heartbeat_playing = FALSE
	owner.stop_sound_channel(CHANNEL_HEARTBEAT)

/obj/effect/client_image_holder/stalker_phantom
	name = "???"
	desc = "Оно подбирается всё ближе..."
	image_icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	image_state = "curseblob"

/datum/brain_trauma/magic/stalker/cosmic
	stalker_type = /obj/effect/client_image_holder/stalker_phantom/cosmic
	random_gain = FALSE
	known_trauma = FALSE

/obj/effect/client_image_holder/stalker_phantom/cosmic
	image_icon = 'icons/mob/96x96eldritch_mobs.dmi'
	image_state = "star_gazer"
	image_pixel_x = -32
	image_pixel_y = -32

#undef LUMIPHOBIA_LIGHT_THRESHOLD
#undef STALKER_SPAWN_RANGE
