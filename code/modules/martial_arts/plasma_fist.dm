/datum/martial_art/plasma_fist
	name = "Плазменный Кулак"
	combos = list(/datum/martial_combo/plasma_fist/tornado_sweep, /datum/martial_combo/plasma_fist/plasma_tornado, /datum/martial_combo/plasma_fist/plasma_breath, /datum/martial_combo/plasma_fist/throwback, /datum/martial_combo/plasma_fist/plasma_blink, /datum/martial_combo/plasma_fist/plasma_fist)
	has_explaination_verb = TRUE
	no_guns = TRUE
	no_guns_message = "Клан Плазменного Кулака разачарован попыткой использования дальнобойное орудие."
	deflection_laser_chance = 100 // шанс отразить лазер. Так как для плазменного кулака отключено использование оружия, то баф 100%
	deflection_energy_chance = 50 // шанс отразить энерго-оружие, так как оно приближено к лазерному. Плазменного кулака рекомендуется хармбатонить
	fire_resistance = TRUE

/datum/martial_art/plasma_fist/harm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	add_attack_logs(A, D, "Melee attacked with martial-art [src]", ATKLOG_ALL)
	var/gender_hit = genderize_ru(A.gender,"","а","о","и")
	var/picked_hit_type = pick("ударил[gender_hit] пылающим кулаком", "прожига[pluralize_ru(A.gender,"ет","ют")] пылающим кулаком", "пробил[gender_hit] пылающим кулаком", "пробил[gender_hit] кулаком в солнечное сплетение", "ударил[gender_hit] под ребра", "ударил[gender_hit] под дых", "пробил[gender_hit]", "ударил[gender_hit] в нутро", "размашисто ударил[gender_hit] по ребрам сбоку")
	var/damage_oxy = 5
	var/damage_burn = 13
	if(D.IsWeakened() || D.resting || D.lying)
		damage_burn += 5
		picked_hit_type = "прожига[pluralize_ru(A.gender,"ет","ют")] пылающим кулаком"
	if(picked_hit_type == "ударил[gender_hit] пылающим кулаком" || picked_hit_type == "пробил[gender_hit] пылающим кулаком" || picked_hit_type ==  "прожига[pluralize_ru(A.gender,"ет","ют")] пылающим кулаком")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
		damage_oxy += 5
	else
		playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] вас!</span>")
	D.apply_damage(damage_burn, BURN)
	D.apply_damage(damage_oxy, OXY)
	add_attack_logs(A, D, "Melee attacked with martial-art [src] : [picked_hit_type]", ATKLOG_ALL)
	if(A.resting && !D.stat && !D.IsWeakened())
		D.visible_message("<span class='warning'>[A] выбил[genderize_ru(A.gender,"","а","о","и")] весь воздух из лёгких [D]!", \
							"<span class='userdanger'>[A] выбил[genderize_ru(A.gender,"","а","о","и")] из ваших лёгких весь воздух!</span>")
		playsound(get_turf(D), 'sound/weapons/sear.ogg', 50, 1, -1)
		//сниженный урон, но выжигает воздёх из лёгких
		D.apply_damage(5, BURN)
		D.apply_damage(60, OXY)
		D.LoseBreath(2)
		add_attack_logs(A, D, "Melee attacked with martial-art [src] : burn-oxy", ATKLOG_ALL)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	return TRUE

/datum/martial_art/plasma_fist/disarm_act(var/mob/living/carbon/human/A, var/mob/living/carbon/human/D)
	MARTIAL_ARTS_ACT_CHECK
	var/damage_oxy = 5
	var/obj/item/I = null
	if(prob(50))
		if(!D.stat || !D.IsWeakened())
			I = D.get_active_hand()
			D.visible_message("<span class='warning'>[A] выбива[pluralize_ru(A.gender,"ет","ют")] воздух из лёгких [D]!</span>", \
								"<span class='userdanger'>[A] выбил[genderize_ru(A.gender,"","а","о","и")] вам воздух из лёгких!</span>")
			playsound(get_turf(D), 'sound/weapons/sear.ogg', 50, 1, -1)
			if(I && D.drop_item())
				A.put_in_hands(I)
			damage_oxy += 10
			D.Jitter(2)	//замешательство на 2 секунды
	else
		D.visible_message("<span class='danger'>[A] попытал[genderize_ru(A.gender,"ся","ась","ось","ись")] обезоружить [D]!</span>", "<span class='userdanger'>[A] попытал[genderize_ru(A.gender,"ся","ась","ось","ись")] обезоружить [D]!</span>")
		playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

	//выжигает воздух
	D.apply_damage(damage_oxy, OXY)

	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)

	add_attack_logs(A, D, "Melee attacked with martial-art [src] : Disarmed [I ? " grabbing \the [I]" : ""]", ATKLOG_ALL)
	return TRUE

/datum/martial_art/plasma_fist/explaination_header(user)
	to_chat(user, "<b><i>Вы сжимаете кулаки и чувствуете внутреннее пламя расползающее по вашему телу...</i></b>")
