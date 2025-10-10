/datum/martial_combo/cqc/kick
	name = "Пинок"
	steps = list(MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Ты отбрасываешь оппонента назад, если на пути будет стена, то дополнительно собьёшь его с ног."

/datum/martial_combo/cqc/kick/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/MA)
	if(target == user)
		return MARTIAL_COMBO_DONE_BASIC_HIT
	target.visible_message(
		span_warning("[capitalize(user.declent_ru(NOMINATIVE))] пина[pluralize_ru(user.gender, "ет", "ют")] [target.declent_ru(ACCUSATIVE)]!"), \
		span_userdanger("[capitalize(user.declent_ru(NOMINATIVE))] пина[pluralize_ru(user.gender, "ет", "ют")] тебя!")
	)
	playsound(get_turf(user), 'sound/weapons/cqchit1.ogg', 50, TRUE, -1)
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(bump_impact))
	target.throw_at(throw_target, 1, 14, user, callback = CALLBACK(src, PROC_REF(unregister_bump_impact), target))
	target.apply_damage(10, BRUTE)
	objective_damage(user, target, 10, BRUTE)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Kick", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE

/datum/martial_combo/cqc/kick/proc/bump_impact(mob/living/target, atom/hit_atom, throwingdatum)
	if(target && !iscarbon(hit_atom) && hit_atom.density)
		target.Knockdown(2 SECONDS)
		target.take_organ_damage(10)

/datum/martial_combo/cqc/kick/proc/unregister_bump_impact(mob/living/target)
	UnregisterSignal(target, COMSIG_MOVABLE_IMPACT)
