/// Xeno crawls from nearby vent, jumps at you, and goes back in.
/datum/hallucination/xeno_attack
	random_hallucination_weight = 2
	hallucination_tier = HALLUCINATION_TIER_RARE

/datum/hallucination/xeno_attack/start()
	if(hallucinator.stat != CONSCIOUS)
		return FALSE

	var/turf/xeno_attack_source
	for(var/obj/machinery/atmospherics/unary/vent_pump/nearby_pump in orange(7, hallucinator))
		if(nearby_pump.welded)
			continue
		xeno_attack_source = get_turf(nearby_pump)
		break

	if(!xeno_attack_source)
		return FALSE

	feedback_details += "Vent Coords: ([xeno_attack_source.x], [xeno_attack_source.y], [xeno_attack_source.z])"

	var/obj/effect/client_image_holder/hallucination/xeno/fake_xeno = new(xeno_attack_source, hallucinator, src)
	addtimer(CALLBACK(src, PROC_REF(leap_at_target), fake_xeno, xeno_attack_source), 1 SECONDS)
	return TRUE

/// Leaps from the vent to the hallucinator.
/datum/hallucination/xeno_attack/proc/leap_at_target(obj/effect/client_image_holder/hallucination/xeno/fake_xeno, turf/attack_source)
	if(QDELETED(src))
		return
	if(QDELETED(fake_xeno))
		qdel(src)
		return

	fake_xeno.set_leaping()
	fake_xeno.throw_at(hallucinator, 7, 1, spin = FALSE, diagonals_first = TRUE)

	addtimer(CALLBACK(src, PROC_REF(knock_down_hallucinator), fake_xeno), 0.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(run_back_to_pump), fake_xeno, attack_source), 1 SECONDS)

/// Unconditionally knocks down the hallucinator - dodging the pounce doesn't save you from a hallucination.
/datum/hallucination/xeno_attack/proc/knock_down_hallucinator(obj/effect/client_image_holder/hallucination/xeno/fake_xeno)
	if(QDELETED(src) || QDELETED(hallucinator) || hallucinator.stat == DEAD)
		return

	var/xeno_name = QDELETED(fake_xeno) ? "alien hunter" : fake_xeno.name
	hallucinator.Weaken(10 SECONDS)
	to_chat(hallucinator, span_userdanger("[xeno_name] набросится на тебя!"))

/// Runs from the hallucinator back to the vent - sneaking, semi-transparent.
/datum/hallucination/xeno_attack/proc/run_back_to_pump(obj/effect/client_image_holder/hallucination/xeno/fake_xeno, turf/attack_source)
	if(QDELETED(src))
		return
	if(QDELETED(fake_xeno) || !attack_source)
		qdel(src)
		return

	fake_xeno.set_unleaping()
	fake_xeno.set_sneaking()
	GLOB.move_manager.move_to(fake_xeno, attack_source, 0, rand(1, 2))
	addtimer(CALLBACK(src, PROC_REF(begin_crawling), fake_xeno), 3 SECONDS)

/// Mimics ventcrawling into the vent.
/datum/hallucination/xeno_attack/proc/begin_crawling(obj/effect/client_image_holder/hallucination/xeno/fake_xeno)
	if(QDELETED(src))
		return
	if(QDELETED(fake_xeno))
		qdel(src)
		return

	to_chat(hallucinator, span_notice("[fake_xeno.name] начинает пробираться в вентиляционную систему..."))
	addtimer(CALLBACK(src, PROC_REF(disappear), fake_xeno), 3 SECONDS)

/// Disappears into the vent, ending the hallucination.
/datum/hallucination/xeno_attack/proc/disappear(obj/effect/client_image_holder/hallucination/xeno/fake_xeno)
	if(QDELETED(src))
		return
	if(!QDELETED(fake_xeno))
		GLOB.move_manager.stop_looping(fake_xeno)
		to_chat(hallucinator, span_notice("[fake_xeno.name] забирается в вентиляционную шахту!"))

	qdel(src)

/// The xeno hallucination that goes with the xeno attack hallucination.
/obj/effect/client_image_holder/hallucination/xeno
	image_icon = 'icons/mob/alien.dmi'
	image_state = "alienh_pounce"

/obj/effect/client_image_holder/hallucination/xeno/Initialize(mapload, list/mobs_which_see_us, datum/hallucination/parent)
	. = ..()
	name = "alien hunter ([rand(1, 1000)])"

// The hallucination "throws" us at the hallucinator, so whenever we impact, we reset our leap pose.
// Валит игрока не столкновение, а гарантированный knock_down_hallucinator - уклониться нельзя.
/obj/effect/client_image_holder/hallucination/xeno/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	set_unleaping()

/// Makes the fake xeno semi-transparent, like a real xeno sneaking through the station.
/obj/effect/client_image_holder/hallucination/xeno/proc/set_sneaking()
	var/sneak_alpha = 130
	alpha = sneak_alpha
	if(shown_image)
		animate(shown_image, alpha = sneak_alpha, time = 0.5 SECONDS)

/// Sets our icon to look like we're leaping.
/obj/effect/client_image_holder/hallucination/xeno/proc/set_leaping()
	image_icon = 'icons/mob/alienleap.dmi'
	image_state = "alienh_leap"
	image_pixel_x = -32
	image_pixel_y = -32
	update_appearance(UPDATE_ICON)

/// Resets our icon to our initial state.
/obj/effect/client_image_holder/hallucination/xeno/proc/set_unleaping()
	image_icon = initial(image_icon)
	image_state = initial(image_state)
	image_pixel_x = initial(image_pixel_x)
	image_pixel_y = initial(image_pixel_y)
	update_appearance(UPDATE_ICON)
