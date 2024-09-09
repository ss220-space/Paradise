PROCESSING_SUBSYSTEM_DEF(aggressive_vine)
	name = "aggressive vine"
	flags = SS_NO_INIT | SS_BACKGROUND | SS_KEEP_TIMING
	wait = 5 SECONDS
	ss_id = "aggressive_vine"

/mob/living/simple_animal/hostile/plant/aggressive_vine
	name = "aggressive vine"
	desc = "Выглядит как большая извивающаяся лоза."
	maxHealth = 20
	health = 20
	var/mob/living/grabbed_mob = null
	var/obj/effect/proc_holder/spell/fireball/vine_grapple/grab = null

/mob/living/simple_animal/hostile/plant/aggressive_vine/proc/on_death()
	STOP_PROCESSING(SSaggressive_vine, src)
	REMOVE_TRAIT(grabbed_mob, TRAIT_IMMOBILIZED, name)
	grabbed_mob = null

/mob/living/simple_animal/hostile/plant/aggressive_vine/Initialize()
	. = ..()
	START_PROCESSING(SSaggressive_vine, src)
	RegisterSignal(src, COMSIG_MOB_DEATH, PROC_REF(on_death))
	grab = new /obj/effect/proc_holder/spell/fireball/vine_grapple()

/mob/living/simple_animal/hostile/plant/aggressive_vine/process()
	var/target = find_target(10)
	if (target)
		grab.cast(target, src)

/obj/effect/proc_holder/spell/fireball/vine_grapple
	name = "Vine Grapple"
	desc = "Fire one of your hands, if it hits a person it pulls them in. If you hit a structure you get pulled to the structure."
	action_background_icon_state = "shadow_demon_bg"
	action_icon_state = "shadow_grapple"
	invocation_type = "none"
	invocation = null
	sound = null
	need_active_overlay = TRUE
	human_req = FALSE
	selection_activated_message = span_notice("You raise your hand, full of demonic energy! <b>Left-click to cast at a target!</b>")
	selection_deactivated_message = span_notice("You re-absorb the energy...for now.")
	base_cooldown = 5 SECONDS
	fireball_type = /obj/item/projectile/magic/vine_grab


/obj/effect/proc_holder/spell/fireball/vine_grapple/update_icon_state()
	return

/obj/item/projectile/magic/vine_grab
	name = "shadow hand"
	icon_state = "shadow_hand"
	plane = FLOOR_PLANE
	speed = 1
	var/hit = FALSE


/obj/item/projectile/magic/vine_grab/fire(setAngle)
	if(firer)
		firer.Beam(src, icon_state = "grabber_beam", time = INFINITY, maxdistance = INFINITY, beam_sleep_time = 1, beam_type = /obj/effect/ebeam/floor, beam_layer = BELOW_MOB_LAYER)
	return ..()


/obj/item/projectile/magic/vine_grab/on_hit(atom/target, blocked, hit_zone)
	if(hit)
		return
	hit = TRUE // to prevent double hits from the pull
	. = ..()
	if(isliving(target))
		var/mob/living/l_target = target
		l_target.forceMove(get_turf(firer))
		l_target.Immobilize(3 SECONDS)

		var/mob/living/simple_animal/hostile/plant/aggressive_vine/vine = firer
		vine.grabbed_mob = target
		ADD_TRAIT(target, TRAIT_IMMOBILIZED, vine.name)
