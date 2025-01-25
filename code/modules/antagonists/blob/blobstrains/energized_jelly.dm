//does tons of oxygen damage and a little stamina, immune to tesla bolts, weak to EMP
/datum/blobstrain/reagent/energized_jelly
	name = "Энергетическое желе"
	description = "наносит урон выносливости и средний урон гипоксией, а также лишает цели возможности дышать."
	effectdesc = "также проводит электричество, но получает урон от ЭМИ. Вызывает электрические разряды в теле после удара."
	analyzerdescdamage = "Наносит высокий урон выносливости, средний урон гипоксией и не дает цели дышать."
	analyzerdesceffect = "Невосприимчив к электричеству и легко его проводит, но слаб к ЭМИ. Вызывает электрические разряды в теле после удара."
	color = "#EFD65A"
	complementary_color = "#00E5B1"
	reagent = /datum/reagent/blob/energized_jelly

/datum/blobstrain/reagent/energized_jelly/damage_reaction(obj/structure/blob/B, damage, damage_type, damage_flag)
	if((damage_flag == MELEE || damage_flag == BULLET || damage_flag == LASER) && B.get_integrity() - damage <= 0 && prob(30))
		do_sparks(rand(2, 4), FALSE, B)
	return ..()

/datum/blobstrain/reagent/energized_jelly/tesla_reaction(obj/structure/blob/B, power)
	return FALSE

/datum/blobstrain/reagent/energized_jelly/emp_reaction(obj/structure/blob/B, severity)
	var/damage = rand(30, 50) - severity * rand(10, 15)
	B.take_damage(damage, BURN, ENERGY)

/datum/reagent/blob/energized_jelly
	name = "Энергетическое желе"
	id = "blob_energized_jelly"
	taste_description = "желатин"
	color = "#EFD65A"


/datum/reagent/blob/energized_jelly/reaction_mob(mob/living/exposed_mob, methods=REAGENT_TOUCH, reac_volume, show_message, touch_protection, mob/camera/blob/overmind)
	. = ..()
	reac_volume = return_mob_expose_reac_volume(exposed_mob, methods, reac_volume, show_message, touch_protection, overmind)
	exposed_mob.LoseBreath(round(0.2*reac_volume))
	exposed_mob.adjustStaminaLoss(reac_volume * 1.2)
	exposed_mob.apply_damage(0.6*reac_volume, OXY)
	if(exposed_mob.reagents)
		if(exposed_mob.reagents.has_reagent("teslium") && prob(0.6 * reac_volume))
			exposed_mob.electrocute_act((0.5 * reac_volume), "разряда блоба", flags = SHOCK_NOGLOVES)
			exposed_mob.reagents.del_reagent("teslium")
			return //don't add more teslium after you shock it out of someone.
		exposed_mob.reagents.add_reagent("teslium", 0.125 * reac_volume)  // a little goes a long way
	
