/// Hallucinations that create a danger nearby, which is associated with a real danger.
/datum/hallucination/hazard
	abstract_hallucination_parent = /datum/hallucination/hazard
	random_hallucination_weight = 5
	hallucination_tier = HALLUCINATION_TIER_UNCOMMON

	/// The type of effect we create
	var/hazard_type = /obj/effect/client_image_holder/hallucination/danger

/datum/hallucination/hazard/start()
	if(hallucinator.stat != CONSCIOUS)
		return FALSE

	var/list/possible_points = list()
	for(var/turf/simulated/floor/floor_in_view in view(hallucinator))
		possible_points += floor_in_view

	if(!length(possible_points))
		return FALSE

	new hazard_type(pick(possible_points), hallucinator, src)
	QDEL_IN(src, rand(20 SECONDS, 45 SECONDS))
	return TRUE

/datum/hallucination/hazard/lava
	hazard_type = /obj/effect/client_image_holder/hallucination/danger/lava

/datum/hallucination/hazard/chasm
	hazard_type = /obj/effect/client_image_holder/hallucination/danger/chasm


/// These hallucination effects cause side effects when the hallucinator walks into them.
/obj/effect/client_image_holder/hallucination/danger
	image_layer = AREA_LAYER
	image_plane = FLOOR_PLANE

/obj/effect/client_image_holder/hallucination/danger/Initialize(mapload, list/mobs_which_see_us, datum/hallucination/parent)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(atom_touched_holder),
		COMSIG_ATOM_EXITED = PROC_REF(atom_touched_holder),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/client_image_holder/hallucination/danger/proc/atom_touched_holder(datum/source, atom/movable/entered)
	SIGNAL_HANDLER

	if(!(entered in who_sees_us))
		return

	on_hallucinator_entered(entered)

/// Applies effects whenever the hallucinator enters the turf with our hallucination present.
/obj/effect/client_image_holder/hallucination/danger/proc/on_hallucinator_entered(mob/living/afflicted)
	return

/obj/effect/client_image_holder/hallucination/danger/lava
	name = "лава"
	image_icon = 'icons/turf/floors/lava.dmi'

/obj/effect/client_image_holder/hallucination/danger/lava/generate_image()
	var/turf/danger_turf = get_turf(src)
	image_state = "lava-[danger_turf.smoothing_junction || 0]"
	return ..()

/obj/effect/client_image_holder/hallucination/danger/lava/on_hallucinator_entered(mob/living/afflicted)
	afflicted.adjustStaminaLoss(20)
	afflicted.cause_hallucination(/datum/hallucination/fire, "fake lava hallucination")

/obj/effect/client_image_holder/hallucination/danger/chasm
	name = "разлом"
	image_icon = 'icons/turf/floors/Chasms.dmi'

/obj/effect/client_image_holder/hallucination/danger/chasm/generate_image()
	var/turf/danger_turf = get_turf(src)
	image_state = "smooth"
	return ..()

/obj/effect/client_image_holder/hallucination/danger/chasm/on_hallucinator_entered(mob/living/afflicted)
	if(QDELETED(src) || QDELETED(afflicted))
		return

	to_chat(afflicted, span_userdanger("Вы падаете в разлом!"))
	afflicted.visible_message(span_warning("[afflicted] внезапно падает на землю!"), ignored_mobs = afflicted)

	var/image/falling_image = image(afflicted.icon, afflicted, afflicted.icon_state, ABOVE_MOB_LAYER)
	falling_image.appearance_flags = RESET_COLOR
	falling_image.pixel_x = afflicted.pixel_x
	falling_image.pixel_y = afflicted.pixel_y
	afflicted.client?.images |= falling_image

	animate(falling_image, transform = matrix() - matrix(), alpha = 0, pixel_y = afflicted.pixel_y - 24, time = 1 SECONDS, easing = LINEAR_EASING)

	addtimer(CALLBACK(src, PROC_REF(clear_falling_overlay), afflicted, falling_image), 1.2 SECONDS)

	afflicted.setStaminaLoss(afflicted.get_max_stamina())

	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), afflicted, span_notice("...Он на удивление мелкий.")), 1.5 SECONDS)
	QDEL_IN(src, 3 SECONDS)

/obj/effect/client_image_holder/hallucination/danger/chasm/proc/clear_falling_overlay(mob/living/afflicted, image/falling_image)
	if(QDELETED(afflicted))
		return
	afflicted.client?.images -= falling_image

