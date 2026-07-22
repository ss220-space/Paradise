/obj/effect/proc_holder/spell/pointed/projectile/star_blast
	name = "Звёздный Взрыв"
	desc = "Это заклинание запускает в цель неудержимый диск с космической энергией, распространяющий звёздную метку. \
			При повторном применении вы телепортируетесь к диску, а от диска и вас расходятся космические поля, \
			затягивающие в них ближайших язычников."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "star_blast"

	sound = 'sound/magic/cosmic_energy.ogg'
	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 1 SECONDS // Cooldown is tied to teleportation, not firing.

	invocation = "ЗВ'ЗДН'Й ВЗР'В!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	active_msg = "Вы готовы применить Звёздный Взрыв!"
	deactive_msg = "Вы прекращаете концентрировать космическую энергию в своих руках... на время."
	cast_range = 12
	projectile_type = /obj/projectile/magic/star_ball
	/// Weakref to the disk we fired, so re-casting can teleport us to it.
	var/datum/weakref/projectile_weakref
	/// Weakref to our summoner; only relevant if we are a stargazer, prevents us from harming our master.
	var/datum/weakref/summoner


/obj/effect/proc_holder/spell/pointed/projectile/star_blast/ready_projectile(obj/projectile/to_fire, atom/target, mob/user, iteration)
	. = ..()
	projectile_weakref = WEAKREF(to_fire)
	RegisterSignal(to_fire, COMSIG_QDELETING, PROC_REF(on_ball_deleted))
	to_fire.AddElement(cosmic_trail_based_on_passive(user), /obj/effect/forcefield/cosmic_field/fast)


/obj/effect/proc_holder/spell/pointed/projectile/star_blast/Click()
	var/obj/projectile/magic/star_ball/active_ball = projectile_weakref?.resolve()
	if(!active_ball)
		return ..()
	if(!cast_check(TRUE, FALSE, usr))
		return TRUE

	pull_victims()
	do_teleport(action.owner, get_turf(active_ball))
	pull_victims() // Intentional: pull from where we were, AND from where we teleported to.
	QDEL_NULL(active_ball) // on_ball_deleted clears the weakref and the green border.
	cooldown_handler.start_recharge(25 SECONDS)
	action?.UpdateButtonIcon()
	return TRUE


/obj/effect/proc_holder/spell/pointed/projectile/star_blast/after_cast(atom/cast_on)
	. = ..()
	if(projectile_weakref?.resolve())
		set_ball_indicator(TRUE)


/// The disk died (hit range end / we teleported to it) - drop the weakref and the green border.
/obj/effect/proc_holder/spell/pointed/projectile/star_blast/proc/on_ball_deleted(datum/source)
	SIGNAL_HANDLER
	projectile_weakref = null
	set_ball_indicator(FALSE)


/// Toggles the green "teleport available" border on the action button while our disk is alive.
/obj/effect/proc_holder/spell/pointed/projectile/star_blast/proc/set_ball_indicator(active)
	if(!action)
		return
	action.targeting_overlay = active ? "bg_spell_border_active_green" : ACTION_BUTTON_DEFAULT_TARGETING_OVERLAY
	action.targeting_process = active
	action.UpdateButtonIcon()


/obj/effect/temp_visual/circle_wave/star_blast
	color = COLOR_VOID_PURPLE


/// Raises a ring of cosmic fields around us and drags nearby heathens in, star-marking them.
/obj/effect/proc_holder/spell/pointed/projectile/star_blast/proc/pull_victims()
	var/mob/living/caster = action.owner
	if(!caster)
		return
	new /obj/effect/temp_visual/circle_wave/star_blast(get_turf(caster))
	for(var/turf/spawn_turf in range(1, get_turf(caster)))
		if(spawn_turf.density)
			continue
		create_cosmic_field(spawn_turf, caster, /obj/effect/forcefield/cosmic_field/star_blast)
	for(var/mob/living/nearby_mob in view(2, caster))
		if(nearby_mob == caster || nearby_mob == summoner?.resolve())
			continue
		if(!isturf(nearby_mob.loc))
			continue
		if(IS_HERETIC_OR_MONSTER(nearby_mob))
			continue
		for(var/i in 1 to 3)
			nearby_mob.forceMove(get_step_towards(nearby_mob, caster))
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark)


/obj/projectile/magic/star_ball
	name = "star ball"
	gender = MALE
	icon_state = "star_ball"
	speed = 6
	range = 25
	knockdown = 4 SECONDS
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSBLOB | PASSMACHINE | PASSSTRUCTURE | PASSFLAPS | PASSFENCE | PASSDOOR | PASSITEM
	forcedodge = -1
	/// Effect for when the ball hits something.
	var/obj/effect/explosion_effect = /obj/effect/temp_visual/cosmic_explosion
	/// The range at which people will get marked with a star mark.
	var/star_mark_range = 3


/obj/projectile/magic/star_ball/get_ru_names()
	return alist(
		NOMINATIVE = "звёздный диск",
		GENITIVE = "звёздного диска",
		DATIVE = "звёздному диску",
		ACCUSATIVE = "звёздный диск",
		INSTRUMENTAL = "звёздным диском",
		PREPOSITIONAL = "звёздном диске",
	)


/obj/projectile/magic/star_ball/on_hit(atom/target, blocked = 0, pierce_hit)
	. = ..()
	var/mob/living/cast_on = firer
	for(var/mob/living/nearby_mob in range(star_mark_range, target))
		if(cast_on == nearby_mob || cast_on?.buckled == nearby_mob)
			continue
		nearby_mob.apply_status_effect(/datum/status_effect/star_mark, cast_on)


/obj/projectile/magic/star_ball/Destroy()
	playsound(get_turf(src), 'sound/magic/cosmic_energy.ogg', 50, FALSE)
	return ..()
