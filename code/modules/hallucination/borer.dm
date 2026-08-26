/// A borer hallucination - a brain slug crawls out of a vent and briefly paralyzes the target.
/datum/hallucination/borer
	random_hallucination_weight = 1
	hallucination_tier = HALLUCINATION_TIER_UNCOMMON

	/// The vent the fake borer comes out of.
	var/obj/machinery/atmospherics/unary/vent_pump/pump
	/// The fake borer image shown to the hallucinator.
	var/image/fake_borer

/datum/hallucination/borer/start()
	if(hallucinator.stat != CONSCIOUS)
		return FALSE

	for(var/obj/machinery/atmospherics/unary/vent_pump/nearby_pump in orange(7, hallucinator))
		if(nearby_pump.welded)
			continue
		pump = nearby_pump
		break

	if(!pump)
		return FALSE

	fake_borer = image('icons/mob/animal.dmi', pump.loc, "brainslug", MOB_LAYER)
	hallucinator.client?.images |= fake_borer

	to_chat(hallucinator, span_userdanger("Вы чувствуете, как по вам ползёт леденящий ужас, сковывающий конечности и ускоряющий сердцебиение."))
	hallucinator.Stun(8 SECONDS)

	addtimer(CALLBACK(src, PROC_REF(finish)), rand(60, 90))

	return TRUE

/datum/hallucination/borer/proc/finish()
	to_chat(hallucinator, span_changeling("<i>Первичные [rand(1000,9999)] состояния:</i> [pick("Привет.", "Приветик!", "Ты теперь мой раб!", "Не пытайся избавиться от меня…")]"))
	qdel(src)

/datum/hallucination/borer/Destroy()
	if(fake_borer)
		hallucinator.client?.images -= fake_borer
		fake_borer = null
	return ..()
