/// Root of shared behaviour for mobs spawned by blobs, is abstract and should not be spawned
/mob/living/simple_animal/hostile/blob_minion
	name = "Blob Error"
	desc = "Нефункциональное грибковое существо, созданное плохим кодом или небесной ошибкой. Показывайте и смейтесь."
	icon = 'icons/mob/blob.dmi'
	icon_state = "blob_head"
	unique_name = TRUE
	pass_flags = PASSBLOB
	status_flags = NONE // No throwing blobspores into deep space to despawn, or throwing blobbernaughts, which are bigger than you.
	faction = list(ROLE_BLOB)
	bubble_icon = "blob"
	speak_emote = null
	stat_attack = UNCONSCIOUS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	sight = SEE_TURFS|SEE_MOBS|SEE_OBJS
	nightvision = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	can_buckle_to = FALSE
	universal_speak = TRUE // So mobs can understand them when a blob uses Blob Broadcast
	sentience_type = SENTIENCE_OTHER
	gold_core_spawnable = NO_SPAWN
	can_be_on_fire = TRUE
	fire_damage = 3
	tts_seed = "Earth"
	tts_atom_say_effect = SOUND_EFFECT_NONE
	a_intent = INTENT_HARM
	/// Is blob mob linked to factory
	var/factory_linked = FALSE


/mob/living/simple_animal/hostile/blob_minion/ComponentInitialize()
	AddComponent( \
		/datum/component/animal_temperature, \
		minbodytemp = 0, \
		maxbodytemp = INFINITY, \
	)
	AddComponent(/datum/component/blob_minion, on_strain_changed = CALLBACK(src, PROC_REF(on_strain_updated)))

/mob/living/simple_animal/hostile/blob_minion/Initialize(mapload)
	. = ..()
	add_traits(list(TRAIT_BLOB_ALLY, TRAIT_MUTE), INNATE_TRAIT)

/// Called when our blob overmind changes their variant, update some of our mob properties
/mob/living/simple_animal/hostile/blob_minion/proc/on_strain_updated(mob/camera/blob/overmind, datum/blobstrain/new_strain)
	return

/mob/living/simple_animal/hostile/blob_minion/can_z_move(direction, turf/start, turf/destination, z_move_flags, mob/living/rider)
	var/obj/structure/blob/s_blob = locate(/obj/structure/blob) in start
	var/obj/structure/blob/d_blob = locate(/obj/structure/blob) in destination
	var/check = !(z_move_flags & ZMOVE_FALL_CHECKS)
	if(s_blob && d_blob)
		return check
	. = ..()

/mob/living/simple_animal/hostile/blob_minion/move_up()
	var/turf/current_turf = get_turf(src)
	var/turf/above_turf = GET_TURF_ABOVE(current_turf)
	if((locate(/obj/structure/blob) in current_turf) && (locate(/obj/structure/blob) in above_turf))
		if(zMove(UP, above_turf, z_move_flags = ZMOVE_FLIGHT_FLAGS|ZMOVE_FEEDBACK))
			to_chat(src, span_notice("You move upwards."))
			return
	. = ..()

/mob/living/simple_animal/hostile/blob_minion/move_down()
	var/turf/current_turf = get_turf(src)
	var/turf/below_turf = GET_TURF_BELOW(current_turf)
	if((locate(/obj/structure/blob) in current_turf) && (locate(/obj/structure/blob) in below_turf))
		if(zMove(DOWN, below_turf, z_move_flags = ZMOVE_FLIGHT_FLAGS|ZMOVE_FEEDBACK))
			to_chat(src, span_notice("You move down."))
			return
	. = ..()


/mob/living/simple_animal/hostile/blob_minion/regenerate_icons()
	update_icon()

/// Associates this mob with a specific blob factory node
/mob/living/simple_animal/hostile/blob_minion/proc/link_to_factory(obj/structure/blob/special/factory/factory)
	factory_linked = TRUE
	RegisterSignal(factory, COMSIG_QDELETING, PROC_REF(on_factory_destroyed))

/mob/living/simple_animal/hostile/blob_minion/attack_animal(mob/living/simple_animal/M)
	if(ROLE_BLOB in M.faction)
		to_chat(M, span_danger("Вы не можете навредить другому порождению блоба"))
		return
	..()

/// Called when our factory is destroyed
/mob/living/simple_animal/hostile/blob_minion/proc/on_factory_destroyed()
	SIGNAL_HANDLER
	to_chat(src, span_userdanger("Your factory was destroyed! You feel yourself dying!"))


/mob/living/simple_animal/hostile/blob_minion/can_be_blob()
	return FALSE

