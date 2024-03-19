/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 205
	health = 205
	devour_time = 2 SECONDS
	icon_state = "alienh_s"
	caste_movement_delay = -1
	var/invisibility_cost = 5
	var/leap_speed = 1.5
	var/leap_without_gravity_speed = 4


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

/mob/living/carbon/alien/humanoid/hunter/proc/toggle_leap(var/message = 1)
	leap_on_click = !leap_on_click
	leap_icon.icon_state = "leap_[leap_on_click ? "on":"off"]"
	update_icons()
	if(message)
		to_chat(src, "<span class='noticealien'>You will now [leap_on_click ? "leap at":"slash at"] enemies!</span>")
	else
		return

/mob/living/carbon/alien/humanoid/hunter/ClickOn(var/atom/A, var/params)
	face_atom(A)
	if(leap_on_click)
		leap_at(A)
	else
		..()

#define MAX_ALIEN_LEAP_DIST 7

/mob/living/carbon/alien/humanoid/hunter/proc/leap_at(var/atom/A)
	if(pounce_cooldown > world.time)
		to_chat(src, span_alertalien("You are too fatigued to pounce right now!"))
		return

	if(leaping) //Leap while you leap, so you can leap while you leap
		return

	if(lying)
		return

	else //Maybe uses plasma in the future, although that wouldn't make any sense...
		leaping = TRUE
		update_icons()
		var/speed = (!has_gravity(src) || !has_gravity(A)) ? leap_without_gravity_speed : leap_speed
		throw_at(A, MAX_ALIEN_LEAP_DIST, speed, spin = 0, diagonals_first = 1, callback = CALLBACK(src, PROC_REF(leap_end)))

/mob/living/carbon/alien/humanoid/hunter/proc/leap_end()
	leaping = FALSE
	update_icons()

/mob/living/carbon/alien/humanoid/hunter/throw_impact(atom/A, datum/thrownthing/throwingdatum)
	if(!leaping)
		return ..()

	pounce_cooldown = world.time + pounce_cooldown_time
	if(A)
		if(isliving(A))
			var/mob/living/L = A
			var/blocked = 0
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.check_shields(src, 0, "the [name]", attack_type = LEAP_ATTACK))
					blocked = 1
			if(!blocked)
				L.visible_message(span_danger("[src] pounces on [L]!"), span_userdanger("[src] pounces on you!"))
				if(ishuman(L))
					var/mob/living/carbon/human/H = L
					H.apply_effect(10 SECONDS, WEAKEN, H.run_armor_check(null, "melee"))
				else
					L.Weaken(10 SECONDS)
				sleep(2)//Runtime prevention (infinite bump() calls on hulks)
				step_towards(src,L)
			else
				Weaken(4 SECONDS, TRUE)

			toggle_leap(0)
		else if(A.density && !A.CanPass(src, get_dir(A, src)))
			visible_message(span_danger("[src] smashes into [A]!"), span_alertalien("[src] smashes into [A]!"))
			Weaken(0.5 SECONDS, TRUE)

		if(leaping)
			leaping = FALSE
			update_icons()
			update_canmove()


/mob/living/carbon/alien/humanoid/float(on)
	if(leaping)
		return
	..()
