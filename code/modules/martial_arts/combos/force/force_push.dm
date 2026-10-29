/datum/martial_combo/force/force_push
	name = "Толчок силы"
	steps = list(MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_DISARM, MARTIAL_COMBO_STEP_HARM)
	explaination_text = "Сильно откидывает жертву."

/datum/martial_combo/force/force_push/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	playsound(user, 'sound/magic/force_choke.ogg', 50, TRUE)
	RegisterSignal(target, COMSIG_MOVABLE_IMPACT, PROC_REF(bump_impact))
	var/atom/throw_target = get_edge_target_turf(target, user.dir)
	target.throw_at(throw_target, 7, 14, user, callback = CALLBACK(src, PROC_REF(unregister_bump_impact), target))
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Force push", ATKLOG_ALL)
	. = MARTIAL_COMBO_DONE

/datum/martial_combo/force/force_push/proc/bump_impact(mob/living/target, atom/hit_atom, throwingdatum)
	if(!target || !hit_atom || throwingdatum)
		return

	if(target && !iscarbon(hit_atom) && hit_atom.density)
		target.Knockdown(2 SECONDS)

/datum/martial_combo/force/force_push/proc/unregister_bump_impact(mob/living/target)
	UnregisterSignal(target, COMSIG_MOVABLE_IMPACT)
