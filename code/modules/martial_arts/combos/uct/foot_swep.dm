/**
 * Foot Sweep: grab, harm, disarm
 * Drops the target on the floor for 3 seconds, dealing 25 stamina damage.
 * Requires Level 4 Unarmed Combat skill.
 */
/datum/martial_combo/uct/foot_swep
	name = "Подсечка"
	steps = list(MARTIAL_COMBO_STEP_GRAB, MARTIAL_COMBO_STEP_HARM, MARTIAL_COMBO_STEP_DISARM)
	explaination_text = "Подсечка, роняет жертву на пол."

/datum/martial_combo/uct/foot_swep/perform_combo(mob/living/carbon/human/user, mob/living/target, datum/martial_art/martial_art)
	target.visible_message(span_warning("[user] проводит подсечу [target]!"), \
						span_userdanger("[user] ставит вам подсечку!"))

	playsound(get_turf(user), 'sound/weapons/whip.ogg', 40, TRUE, -1)
	target.apply_damage(25, STAMINA)
	target.Knockdown(3 SECONDS)
	add_attack_logs(user, target, "Melee attacked with martial-art [src] : Подсечка", ATKLOG_ALL)
	return MARTIAL_COMBO_DONE
