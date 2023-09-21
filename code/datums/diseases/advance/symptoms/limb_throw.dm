/*
//////////////////////////////////////

Limb Rejection

//////////////////////////////////////
*/

/datum/symptom/limb_throw

	name = "Limb Rejection"
	id = "limb_throw"
	stealth = -4
	resistance = -5
	stage_speed = 3
	transmittable = -3
	level = 5
	severity = 4
	var/spell_learned = FALSE

/datum/symptom/limb_throw/Activate(datum/disease/advance/A)
	if(!spell_learned && A.stage >= 4)
		A.affected_mob.mind?.AddSpell(new /obj/effect/proc_holder/spell/limb_throw)
		spell_learned = TRUE
	return

/datum/symptom/limb_throw/End(datum/disease/advance/A)
	A.affected_mob.mind?.RemoveSpell(/obj/effect/proc_holder/spell/limb_throw)
	spell_learned = FALSE
	return

/obj/effect/proc_holder/spell/limb_throw
	name = "Limb Rejection"
	desc = "Throws the selected limb as a projectile"

	base_cooldown = 0 SECONDS
	clothes_req = FALSE
	need_active_overlay = TRUE
	invocation = ""

	selection_activated_message		= "<span class='notice'>Your prepare to throw a limb!! <B>Left-click to cast at a target!</B></span>"
	selection_deactivated_message	= "<span class='notice'>You decided not to throw a limb...for now.</span>"

	action_icon_state = "limb_throw"
	action_background_icon_state = "bg_changeling"

/obj/effect/proc_holder/spell/limb_throw/create_new_targeting()
	var/datum/spell_targeting/clicked_atom/T = new()
	T.range = 7
	return T

/obj/effect/proc_holder/spell/limb_throw/cast(list/targets, mob/living/user = usr)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir)
	if(!isturf(U) || !isturf(T))
		return FALSE

	var/mob/living/carbon/human/H = user
	if(!istype(H))
		return FALSE

	var/obj/item/organ/external/limb = H.bodyparts_by_name[H.zone_selected]
	if(!istype(limb))
		to_chat(H, "<span class = 'alert'>You don't have the selected body part!</span>")
		return FALSE

	if(limb.vital)
		to_chat(H, "<span class = 'alert'>You still need [limb]!</span>")
		return FALSE

	for(var/obj/item/organ/internal/organ in limb.internal_organs)
		if(organ.vital)
			to_chat(H, "<span class = 'alert'>You still need [organ]!</span>")
			return FALSE

	var/obj/item/projectile/limb/limb_projectile = new(user.loc, limb)
	limb_projectile.current = get_turf(user)
	limb_projectile.preparePixelProjectile(target, get_turf(target), user)
	limb_projectile.fire()
	playsound(get_turf(usr), 'sound/effects/splat.ogg', 50, 1)

	limb.droplimb()
	qdel(limb)
	H.emote("scream")

	user.newtonian_move(get_dir(U, T))

	return TRUE
