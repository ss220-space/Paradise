/**
 * Helpers for combat stat examine readouts (weapon_description element, ammo notes, etc.)
 */

/proc/user_meets_weapon_description_skill(mob/user, skill_type)
	if(!skill_type)
		return TRUE
	GET_SKILL_LEVEL(user, skill_type, skill_level)
	return skill_level >= SKILL_LEVEL_BASIC

/proc/format_examine_kinetic_energy(kinetic_force)
	return "[round(kinetic_force)] Дж"

/proc/format_examine_armor_penetration(armour_penetration)
	return "[max(0, round(armour_penetration))] мм RHA"

/proc/damage_class_to_combat_name(damage_class)
	switch(normalize_damage_class(damage_class))
		if(PIERCING)
			return "проникающий"
		if(SLASHING)
			return "режущий"
		if(BLUNT)
			return "дробящий"
	return "дробящий"

/proc/softness_to_bullet_type_name(softness)
	switch(softness)
		if(-INFINITY to 20)
			return "оболочечная"
		if(21 to 50)
			return "полуоболочечная"
		if(51 to 80)
			return "экспансивная"
		else
			return "резиновая"

/proc/build_projectile_combat_examine_stats(obj/projectile/exam_proj, damage_mult = 1, pellet_count = 1)
	var/list/readout = list()
	if(!ispath(exam_proj))
		return readout

	var/effective_damage = initial(exam_proj.damage) * damage_mult * pellet_count
	if(effective_damage > 0)
		var/hits_str = span_warning("[HITS_TO_CRIT(effective_damage)] попадан[declension_ru(HITS_TO_CRIT(effective_damage), "ие", "ия", "ий")]")
		readout += "- Потребуется примерно [hits_str], чтобы нанести <b>[span_red("летальные ранения")]</b> противнику."

	var/kinetic = initial(exam_proj.kinetic_force)
	if(isnull(kinetic))
		kinetic = initial(exam_proj.damage)
	readout += "- Кинетическая энергия: [span_warning(format_examine_kinetic_energy(kinetic))]."
	readout += "- Бронепробитие: [span_warning(format_examine_armor_penetration(initial(exam_proj.armour_penetration)))]."
	readout += "- Тип: [span_warning(softness_to_bullet_type_name(initial(exam_proj.softness)))] пуля."
	return readout
