/obj/effect/proc_holder/spell/alien_spell/neurotoxin
	name = "Neurotoxin spit"
	desc = "This ability allows you to fire some neurotoxin. Knocks down anyone you hit, applies a small amount of stamina damage as well."
	base_cooldown = 1 SECONDS
	plasma_cost = 50
	selection_activated_message		= span_noticealien("<B>Your prepare some neurotoxin!</B>")
	selection_deactivated_message	= span_noticealien("<B>You swallow your prepared neurotoxin.</B>")
	var/neurotoxin_type = /obj/item/projectile/bullet/neurotoxin
	action_icon_state = "alien_neurotoxin_0"
	sound = 'sound/creatures/terrorspiders/spit2.ogg'

/obj/effect/proc_holder/spell/alien_spell/neurotoxin/sentinel
	base_cooldown = 0.5 SECONDS

/obj/effect/proc_holder/spell/alien_spell/neurotoxin/create_new_targeting()
	return new /datum/spell_targeting/clicked_atom


/obj/effect/proc_holder/spell/alien_spell/neurotoxin/update_icon_state()
	if(!action)
		return
	action.button_icon_state = "alien_neurotoxin_[active]"
	action.UpdateButtonIcon()

//sets charge_check = FALSE so that you can cancel spell while it's charging
/obj/effect/proc_holder/spell/alien_spell/neurotoxin/can_cast(mob/user, charge_check = FALSE, show_message)
	. = ..()

/obj/effect/proc_holder/spell/alien_spell/neurotoxin/cast(list/targets, mob/living/carbon/user)
	var/target = targets[1]
	var/turf/T = user.loc
	var/turf/U = get_step(user, user.dir) // A little aimbot is fine
	if(!istype(U) || !istype(T))
		return FALSE

	var/obj/item/projectile/bullet/neurotoxin/neurotoxin = new neurotoxin_type(user.loc)
	neurotoxin.current = get_turf(user)
	neurotoxin.original = target
	neurotoxin.firer = user
	neurotoxin.preparePixelProjectile(target, get_turf(target), user, targeting.click_params)
	neurotoxin.fire()
	user.newtonian_move(get_dir(U, T))

	return TRUE

//sets charge_check = FALSE so that you can cancel spell while it's charging
/obj/effect/proc_holder/spell/alien_spell/neurotoxin/Click()
	if(cast_check(FALSE, FALSE, usr))
		choose_targets(usr)
	return TRUE

//removes line (user.changeNext_click(CLICK_CD_CLICK_ABILITY)) in parent proc to quick toggle spell
/obj/effect/proc_holder/spell/alien_spell/neurotoxin/InterceptClickOn(mob/user, params, atom/target)
	if(user.ranged_ability != src)
		to_chat(user, span_warning("<b>[user.ranged_ability.name]</b> has been disabled."))
		user.ranged_ability.remove_ranged_ability(user)
	else
		targeting.InterceptClickOn(user, params, target, src)

/obj/effect/proc_holder/spell/alien_spell/neurotoxin/after_cast(list/targets, mob/user)
	. = ..()
	if(should_remove_click_intercept(user))
		remove_ranged_ability(user)

/obj/effect/proc_holder/spell/alien_spell/neurotoxin/should_remove_click_intercept(mob/living/carbon/user)
	if(user.get_plasma() < plasma_cost)
		return TRUE
	return FALSE

