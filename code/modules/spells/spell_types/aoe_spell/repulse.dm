/datum/action/cooldown/spell/aoe/repulse
	name = "Repulse"
	desc = "This spell throws everything around the user away."
	cooldown_time = 40 SECONDS
	cooldown_reduction_per_rank = 6.25 SECONDS
	invocation = "GITTAH WEIGH"
	invocation_type = INVOCATION_SHOUT
	targeting_type = /datum/aoe_targeting/atoms
	sound = 'sound/magic/repulse.ogg'
	var/maxthrow = 5
	var/sparkle_path = /obj/effect/temp_visual/gravpush
	button_icon_state = "repulse"
	aoe_radius = 5
	var/stun_amt = 3 SECONDS
	var/throwtarget
	var/distfromcaster


/datum/action/cooldown/spell/aoe/repulse/cast_on_thing_in_aoe(atom/movable/victim, atom/caster)
	if(victim == caster || victim.anchored || victim.move_resist == INFINITY)
		return

	throwtarget = get_edge_target_turf(caster, get_dir(caster, get_step_away(victim, caster)))
	distfromcaster = get_dist(caster, victim)
	if(distfromcaster == 0)
		if(!isliving(victim))
			return
		var/mob/living/victim_mob = victim
		victim_mob.Weaken(10 SECONDS)
		victim_mob.adjustBruteLoss(5)
		to_chat(victim_mob, span_userdanger("You're slammed into the floor by a mystical force!"))
	else
		new sparkle_path(get_turf(victim), get_dir(caster, victim))
		if(isliving(victim))
			var/mob/living/victim_mob = victim
			victim_mob.Weaken(stun_amt)
			to_chat(victim_mob, span_userdanger("You're thrown back by a mystical force!"))
		spawn(0)
			victim.throw_at(throwtarget, ((clamp((maxthrow - (clamp(distfromcaster - 2, 0, distfromcaster))), 3, maxthrow))), 1)

/datum/action/cooldown/spell/aoe/repulse/spacedragon
	name = "Удар хвостом"
	desc = "Отбрасывайте нападающих ударом хвоста."
	sound = 'sound/magic/tail_swing.ogg'
	cooldown_time = 15 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	sparkle_path = /obj/effect/temp_visual/dir_setting/tailsweep
	button_icon_state = "tailsweep"
	background_icon_state = "bg_alien"

/datum/action/cooldown/spell/aoe/repulse/spacedragon/cast(atom/cast_on)
	. = ..()
	if(iscarbon(cast_on))
		var/mob/living/carbon/C = cast_on
		playsound(C.loc, 'sound/effects/hit_punch.ogg', 80, TRUE, 1)
		C.spin(6, 1)
