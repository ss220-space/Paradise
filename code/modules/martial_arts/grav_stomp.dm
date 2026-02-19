/datum/martial_art/grav_stomp
	name = "Gravitational Boots"
	weight = 4
	var/bonus_damage = 10

/datum/martial_art/grav_stomp/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with [src]")
	var/picked_hit_type = "пинает"
	var/damage_mult = 1
	if(D.body_position == LYING_DOWN)
		damage_mult = 1.5
		picked_hit_type = "топчет"

	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	playsound(get_turf(D), 'sound/effects/hit_kick.ogg', 50, TRUE, -1)
	D.apply_damage(bonus_damage * damage_mult, BRUTE)
	objective_damage(A, D, bonus_damage * damage_mult, BRUTE)
	D.visible_message(span_danger("[A] [picked_hit_type] [D]!"), \
					span_userdanger("[A] [picked_hit_type] вас!"))
	return TRUE
