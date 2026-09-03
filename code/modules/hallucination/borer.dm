/// A borer hallucination - a brain slug crawls out of a vent and briefly paralyzes the target.
/datum/hallucination/borer
	random_hallucination_weight = 1
	hallucination_tier = HALLUCINATION_TIER_UNCOMMON

	/// The vent the fake borer comes out of.
	var/obj/machinery/atmospherics/unary/vent_pump/pump
	/// The fake borer object that walks to the target.
	var/obj/effect/client_image_holder/hallucination/borer/fake_borer_holder
	/// Whether the borer has already ambushed the target this cast.
	var/ambushed = FALSE

/datum/hallucination/borer/start()
	if(!hallucinator.client || hallucinator.stat != CONSCIOUS)
		return FALSE

	for(var/obj/machinery/atmospherics/unary/vent_pump/nearby_pump in orange(7, hallucinator))
		if(nearby_pump.welded)
			continue
		pump = nearby_pump
		break

	if(!pump)
		return FALSE

	RegisterSignal(hallucinator, COMSIG_MOVABLE_MOVED, PROC_REF(on_hallucinator_moved))
	addtimer(CALLBACK(src, PROC_REF(cleanup)), 30 SECONDS)
	return TRUE

/// Signal proc for [COMSIG_MOVABLE_MOVED] - ambush the target when they get close to the vent.
/datum/hallucination/borer/proc/on_hallucinator_moved(mob/source)
	SIGNAL_HANDLER
	if(ambushed || QDELETED(src) || QDELETED(hallucinator) || QDELETED(pump))
		return

	var/dist = get_dist(get_turf(hallucinator), get_turf(pump))
	if(dist > 3)
		return

	ambushed = TRUE
	UnregisterSignal(hallucinator, COMSIG_MOVABLE_MOVED)
	spawn_borer_attack()

/// The actual ambush: knock the target down and send the borer crawling to them.
/datum/hallucination/borer/proc/spawn_borer_attack()
	hallucinator.Weaken(8 SECONDS)
	hallucinator.adjustStaminaLoss(40)
	to_chat(hallucinator, span_userdanger("Что-то вылезает из вентиляции и впивается вам в затылок!"))

	fake_borer_holder = new(get_turf(pump), hallucinator, src)
	GLOB.move_manager.move_to(fake_borer_holder, hallucinator, 0, 2 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(borer_reached)), 2 SECONDS)

/// The borer has reached its target - make it vanish and queue the fake message.
/datum/hallucination/borer/proc/borer_reached()
	if(!QDELETED(fake_borer_holder))
		GLOB.move_manager.stop_looping(fake_borer_holder)
		qdel(fake_borer_holder)

	addtimer(CALLBACK(src, PROC_REF(finish)), rand(5 SECONDS, 10 SECONDS))

/// The fake message from the borer, then end the hallucination.
/datum/hallucination/borer/proc/finish()
	to_chat(hallucinator, span_changeling("<i>Первичные [rand(1000,9999)] состояния:</i> [pick("Привет.", "Приветик!", "Ты теперь мой раб!", "Не пытайся избавиться от меня...", "Ща повеселимся!", "Шо ты, голова?", "Если ты попробуешь жрать сахар — я тебя гибну!")]"))
	qdel(src)

/// Cleanup fallback - the target never got close enough.
/datum/hallucination/borer/proc/cleanup()
	if(!QDELETED(hallucinator))
		UnregisterSignal(hallucinator, COMSIG_MOVABLE_MOVED)
	qdel(src)

/datum/hallucination/borer/Destroy()
	if(!QDELETED(hallucinator))
		UnregisterSignal(hallucinator, COMSIG_MOVABLE_MOVED)
	if(fake_borer_holder)
		GLOB.move_manager.stop_looping(fake_borer_holder)
		QDEL_NULL(fake_borer_holder)
	return ..()

/// A movable borer sprite that crawls from the vent to the hallucinator.
/obj/effect/client_image_holder/hallucination/borer
	name = "мозговой червь"
	image_icon = 'icons/mob/animal.dmi'
	image_state = "brainslug"
