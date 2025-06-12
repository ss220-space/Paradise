/datum/disease/critical
	visibility_flags = HIDDEN_PANDEMIC
	can_immunity = FALSE
	ignore_immunity = TRUE
	virus_heal_resistant = TRUE
	severity = DANGEROUS

/datum/disease/critical/stage_act() //overriden to ensure unique behavior
	if(affected_mob?.stat == DEAD)
		return FALSE

	stage = min(stage, max_stages)

	if(prob(stage_prob))
		stage = min(stage + 1, max_stages)

	if(has_cure())
		cure()
		return FALSE
	return TRUE

/datum/disease/critical/has_cure()
	for(var/C_id in cures)
		if(affected_mob.reagents.has_reagent(C_id))
			if(prob(cure_prob))
				return TRUE
	return FALSE

/datum/disease/critical/shock
	name = "Шок"
	form = "Критическое состояние"
	additional_info = "Пациент находится в состоянии шока"
	max_stages = 3
	stage_prob = 6
	cures = list("salglu_solution")
	cure_prob = 10

/datum/disease/critical/shock/stage_act()
	if(..())
		if(affected_mob.health >= 25 && affected_mob.nutrition >= NUTRITION_LEVEL_HYPOGLYCEMIA)
			to_chat(affected_mob, span_notice("Вы чувствуете себя лучше."))
			cure()
			return
		switch(stage)
			if(1)
				if(prob(1) && prob(10))
					to_chat(affected_mob, span_notice("Вы чувствуете себя лучше."))
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shiver", "pale", "moan"))
				if(prob(5))
					to_chat(affected_mob, span_danger("Вы чувствуете слабость!"))
			if(2)
				if(prob(1) && prob(10))
					to_chat(affected_mob, span_notice("Вы чувствуете себя лучше."))
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shiver", "pale", "moan", "shudder", "tremble"))
				if(prob(5))
					to_chat(affected_mob, span_danger("Вы чувствуете себя ужасно!"))
				if(prob(5))
					affected_mob.emote("faint", "collapse", "groan")
			if(3)
				if(prob(1) && prob(10))
					to_chat(affected_mob, span_notice("Вы чувствуете себя лучше."))
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shudder", "pale", "tremble", "groan", "bshake"))
				if(prob(5))
					to_chat(affected_mob, span_danger("Вы чувствуете себя отвратительно!"))
				if(prob(5))
					affected_mob.emote(pick("faint", "collapse", "groan"))
				if(prob(7))
					to_chat(affected_mob, span_danger("Вы задыхаетесь!"))
					affected_mob.AdjustLoseBreath(2 SECONDS)
				if(prob(5))
					var/datum/disease/D = new /datum/disease/critical/heart_failure
					D.Contract(affected_mob)

/datum/disease/critical/heart_failure
	name = "Сердечная недостаточность"
	form = "Критическое состояние"
	additional_info = "У пациента сердечный приступ"
	max_stages = 3
	stage_prob = 5
	cures = list("atropine", "epinephrine", "heparin")
	cure_prob = 10
	needs_all_cures = FALSE
	required_organs = list(/obj/item/organ/internal/heart)

/datum/disease/critical/heart_failure/has_cure()
	if(affected_mob.has_status_effect(STATUS_EFFECT_EXERCISED))
		return TRUE

	return ..()

/datum/disease/critical/heart_failure/stage_act()
	if(..())
		switch(stage)
			if(1)
				if(prob(1) && prob(10))
					to_chat(affected_mob, span_notice("Вы чувствуете себя лучше."))
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("pale", "shudder"))
				if(prob(5))
					to_chat(affected_mob, span_danger("Ваша рука болит!"))
				else if(prob(5))
					to_chat(affected_mob, span_danger("Ваша грудь болит!"))
			if(2)
				if(prob(1) && prob(10))
					to_chat(affected_mob, span_notice("Вы чувствуете себя лучше."))
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("pale", "groan"))
				if(prob(5))
					to_chat(affected_mob, span_danger("Ваше сердце готово вырваться из груди!"))
					affected_mob.AdjustLoseBreath(2 SECONDS)
				if(prob(3))
					to_chat(affected_mob, span_danger("Ваше сердце перестаёт биться!"))
					affected_mob.AdjustLoseBreath(6 SECONDS)
				if(prob(5))
					affected_mob.emote(pick("faint", "collapse", "groan"))
			if(3)
				affected_mob.adjustOxyLoss(1)
				if(prob(8))
					affected_mob.emote(pick("twitch", "gasp"))
				if(prob(5) && ishuman(affected_mob))
					var/mob/living/carbon/human/H = affected_mob
					H.set_heartattack(TRUE)

/datum/disease/critical/hypoglycemia
	name = "Гипогликемия"
	form = "Критическое состояние"
	additional_info = "У пациента низкий уровень сахара в крови"
	max_stages = 3
	stage_prob = 1
	cure_text = "Приём пищи или введение витаминов и питательных веществ"


/datum/disease/critical/hypoglycemia/has_cure()
	if(HAS_TRAIT(affected_mob, TRAIT_NO_HUNGER) && !isvampire(affected_mob))
		return TRUE
	if(ismachineperson(affected_mob))
		return TRUE
	return ..()


/datum/disease/critical/hypoglycemia/stage_act()
	if(..())
		if(isLivingSSD(affected_mob)) // We don't want AFK people dying from this.
			return
		if(affected_mob.nutrition > NUTRITION_LEVEL_HYPOGLYCEMIA)
			to_chat(affected_mob, span_notice("Вы чувствуете себя намного лучше!"))
			cure()
			return
		switch(stage)
			if(1)
				if(prob(4))
					to_chat(affected_mob, span_warning("Вы чувствуете голод!"))
				if(prob(2))
					to_chat(affected_mob, span_warning("У вас болит голова!"))
				if(prob(2))
					to_chat(affected_mob, span_warning("Вы чувствуете себя [pick("тревожно", "подавленно")]!"))
			if(2)
				if(prob(4))
					to_chat(affected_mob, span_warning("Вам кажется, что всё в вашей жизни идёт не так, как надо!"))
				if(prob(5))
					affected_mob.Slowed(rand(8 SECONDS, 32 SECONDS))
					to_chat(affected_mob, span_warning("Вы чувствуете [pick("усталость", "истощение", "вялость")]."))
				if(prob(5))
					affected_mob.Weaken(12 SECONDS)
					affected_mob.Stuttering(20 SECONDS)
					to_chat(affected_mob, span_warning("Вы чувствуете [pick("онемение", "растерянность", "головокружение", "холодный пот", "дрожь в руках", "слабость в коленях", "пульсацию в висках")]."))
					affected_mob.emote("collapse")
			if(3)
				if(prob(1))
					var/datum/disease/D = new /datum/disease/critical/shock
					D.Contract(affected_mob)
				if(prob(12))
					affected_mob.Weaken(12 SECONDS)
					affected_mob.Stuttering(20 SECONDS)
					to_chat(affected_mob, span_warning("Вы чувствуете [pick("онемение", "растерянность", "головокружение", "холодный пот", "дрожь в руках", "слабость в коленях", "пульсацию в висках")]."))
					affected_mob.emote("collapse")
				if(prob(12))
					to_chat(affected_mob, span_warning("Вы чувствуете [pick("усталость", "истощение", "вялость")]."))
					affected_mob.Slowed(rand(8 SECONDS, 32 SECONDS))
