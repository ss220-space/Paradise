/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 205
	health = 205
	devour_time = 2 SECONDS
	icon_state = "alienh_s"
	caste_movement_delay = -1
	var/invisibility_cost = 5


/mob/living/carbon/alien/humanoid/hunter/New()
	if(name == "alien hunter")
		name = text("alien hunter ([rand(1, 1000)])")
	real_name = name
	..()


/mob/living/carbon/alien/humanoid/hunter/get_caste_organs()
	. = ..()
	. += /obj/item/organ/internal/xenos/plasmavessel/hunter


/mob/living/carbon/alien/humanoid/hunter/handle_environment()
	if(m_intent == MOVE_INTENT_RUN || resting)
		..()
	else
		adjust_alien_plasma(-invisibility_cost)


//Hunter verbs

/mob/living/carbon/alien/humanoid/hunter/proc/toggle_leap(message = TRUE)
	leap_on_click = !leap_on_click
	leap_icon.icon_state = "leap_[leap_on_click ? "on":"off"]"
	update_icons()
	if(message)
		to_chat(src, span_noticealien("You will now [leap_on_click ? "leap at":"slash at"] enemies!"))


/mob/living/carbon/alien/humanoid/hunter/ClickOn(atom/A, params)
	face_atom(A)
	if(leap_on_click)
		leap_at(A)
	else
		..()


#define MAX_ALIEN_LEAP_DIST 7
#define LEAP_SPEED_DEFAULT 1.5
#define LEAP_SPEED_NO_GRAVITY 4

/mob/living/carbon/alien/humanoid/hunter/proc/leap_at(atom/target)
	if(body_position == LYING_DOWN || HAS_TRAIT(src, TRAIT_IMMOBILIZED) || leaping)
		return

	if(pounce_cooldown > world.time)
		to_chat(src, span_alertalien("You are too fatigued to pounce right now!"))
		return

	leaping = TRUE
	//Because the leaping sprite is bigger than the normal one
	body_position_pixel_x_offset = -32
	body_position_pixel_y_offset = -32
	update_icons()
	ADD_TRAIT(src, TRAIT_MOVE_FLOATING, LEAPING_TRAIT) //Throwing itself doesn't protect mobs against lava (because gulag).
	var/updated_speed = (!has_gravity() || !target.has_gravity()) ? LEAP_SPEED_NO_GRAVITY : LEAP_SPEED_DEFAULT
	throw_at(target, MAX_ALIEN_LEAP_DIST, updated_speed, src, FALSE, TRUE, callback = CALLBACK(src, PROC_REF(leap_end)))

#undef MAX_ALIEN_LEAP_DIST
#undef LEAP_SPEED_DEFAULT
#undef LEAP_SPEED_NO_GRAVITY


/mob/living/carbon/alien/humanoid/hunter/proc/leap_end()
	leaping = FALSE
	body_position_pixel_x_offset = 0
	body_position_pixel_y_offset = 0
	update_icons()
	REMOVE_TRAIT(src, TRAIT_MOVE_FLOATING, LEAPING_TRAIT)


/mob/living/carbon/alien/humanoid/hunter/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!leaping)
		return ..()

	pounce_cooldown = world.time + pounce_cooldown_time
	if(!hit_atom)
		return

	if(isliving(hit_atom))
		var/mob/living/L = hit_atom
		var/blocked = FALSE
		var/human_target = ishuman(L)
		if(human_target)
			var/mob/living/carbon/human/H = hit_atom
			if(H.check_shields(src, 0, "the [name]", attack_type = LEAP_ATTACK))
				blocked = TRUE
		if(!blocked)
			L.visible_message(span_danger("[src] pounces on [L]!"), span_userdanger("[src] pounces on you!"))
			if(human_target)
				L.apply_effect(10 SECONDS, WEAKEN, L.run_armor_check(null, MELEE))
			else
				L.Weaken(10 SECONDS)
			sleep(0.2 SECONDS)//Runtime prevention (infinite bump() calls on hulks)
			step_towards(src, L)
		else
			Weaken(4 SECONDS, TRUE)

		toggle_leap(FALSE)

	else if(hit_atom.density && !hit_atom.CanPass(src, get_dir(hit_atom, src)))
		visible_message(span_danger("[src] smashes into [hit_atom]!"), span_alertalien("[src] smashes into [hit_atom]!"))
		Weaken(0.5 SECONDS, TRUE)

