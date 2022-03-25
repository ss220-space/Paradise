/datum/disease/critical

/datum/disease/critical/stage_act() //overriden to ensure unique behavior
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
			if(prob(cure_chance))
				return TRUE
	return FALSE

/datum/disease/critical/shock
	name = "Шок"
	form = "Требуется неотложная помощь"
	spread_text = "Пациент в шоке"
	max_stages = 3
	spread_flags = SPECIAL
	cure_text = "Saline-Glucose Solution"
	cures = list("salglu_solution")
	cure_chance = 10
	viable_mobtypes = list(/mob/living/carbon/human)
	stage_prob = 6
	severity = DANGEROUS
	disease_flags = CURABLE
	bypasses_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/critical/shock/stage_act()
	if(..())
		if(affected_mob.health >= 25 && affected_mob.nutrition >= NUTRITION_LEVEL_HYPOGLYCEMIA)
			to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
			cure()
			return
		switch(stage)
			if(1)
				if(prob(1) && prob(10))
					to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shiver", "pale", "moan"))
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>Вы чувствуете слабость!</span>")
			if(2)
				if(prob(1) && prob(10))
					to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shiver", "pale", "moan", "shudder", "tremble"))
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>Вам становится катастрофически плохо!</span>")
				if(prob(5))
					affected_mob.emote("faint", "collapse", "groan")
			if(3)
				if(prob(1) && prob(10))
					to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("shudder", "pale", "tremble", "groan", "bshake"))
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>Вы чувствуете себя ужасно!</span>")
				if(prob(5))
					affected_mob.emote(pick("faint", "collapse", "groan"))
				if(prob(7))
					to_chat(affected_mob, "<span class='danger'>Вы не можете дышать!</span>")
					affected_mob.AdjustLoseBreath(1)
				if(prob(5))
					var/datum/disease/D = new /datum/disease/critical/heart_failure
					affected_mob.ForceContractDisease(D)

/datum/disease/critical/heart_failure
	name = "Сердечная недостаточность"
	form = "Требуется неотложная помощь"
	spread_text = "У пациента сердечная недостаточность"
	max_stages = 3
	spread_flags = SPECIAL
	cure_text = "Atropine, Epinephrine, или Heparin"
	cures = list("atropine", "epinephrine", "heparin")
	cure_chance = 10
	needs_all_cures = FALSE
	viable_mobtypes = list(/mob/living/carbon/human)
	stage_prob = 5
	severity = DANGEROUS
	disease_flags = CURABLE
	required_organs = list(/obj/item/organ/internal/heart)
	bypasses_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/critical/heart_failure/has_cure()
	if(affected_mob.has_status_effect(STATUS_EFFECT_EXERCISED))
		return TRUE

	return ..()

/datum/disease/critical/heart_failure/stage_act()
	if(..())
		switch(stage)
			if(1)
				if(prob(1) && prob(10))
					to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("pale", "shudder"))
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>Ваши руки болят!</span>")
				else if(prob(5))
					to_chat(affected_mob, "<span class='danger'>Ваша грудь болит!</span>")
			if(2)
				if(prob(1) && prob(10))
					to_chat(affected_mob, "<span class='notice'>Вам становится лучше.</span>")
					cure()
					return
				if(prob(8))
					affected_mob.emote(pick("pale", "groan"))
				if(prob(5))
					to_chat(affected_mob, "<span class='danger'>Ваше сердце колотится в груди!</span>")
					affected_mob.AdjustLoseBreath(1)
				if(prob(3))
					to_chat(affected_mob, "<span class='danger'>Ваше сердце остановилось!</span>")
					affected_mob.AdjustLoseBreath(3)
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
	form = "Требуется неотложная помощь"
	max_stages = 3
	spread_flags = SPECIAL
	spread_text = "У пациента низкий уровень сахара в крови."
	cure_text = "Прием пищи, витаминов или питательных веществ"
	viable_mobtypes = list(/mob/living/carbon/human)
	stage_prob = 1
	severity = DANGEROUS
	disease_flags = CURABLE
	bypasses_immunity = TRUE
	virus_heal_resistant = TRUE

/datum/disease/critical/hypoglycemia/has_cure()
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		if(NO_HUNGER in H.dna.species.species_traits)
			return TRUE
		if(ismachineperson(H))
			return TRUE
	return ..()

/datum/disease/critical/hypoglycemia/stage_act()
	if(..())
		if(isLivingSSD(affected_mob)) // We don't want AFK people dying from this.
			return
		if(affected_mob.nutrition > NUTRITION_LEVEL_HYPOGLYCEMIA)
			to_chat(affected_mob, "<span class='notice'>Вам намного лучше!</span>")
			cure()
			return
		switch(stage)
			if(1)
				if(prob(4))
					to_chat(affected_mob, "<span class='warning'>Вам хочется есть!</span>")
				if(prob(2))
					to_chat(affected_mob, "<span class='warning'>У вас болит голова!</span>")
				if(prob(2))
					to_chat(affected_mob, "<span class='warning'>Вы чувствуете себя [pick("беспокойно", "подавлено")]!</span>")
			if(2)
				if(prob(4))
					to_chat(affected_mob, "<span class='warning'>Вы чувствуете, что в вашей жизни всё неправильно!</span>")
				if(prob(5))
					affected_mob.Slowed(rand(4, 16))
					to_chat(affected_mob, "<span class='warning'>Вы чувствуете [pick("усталость", "истощение", "вялость")].</span>")
				if(prob(5))
					affected_mob.Weaken(6)
					affected_mob.Stuttering(10)
					to_chat(affected_mob, "<span class='warning'>Вы чувствуете [pick("онемение", "замешательство", "головокружение", "lightheaded")].</span>")
					affected_mob.emote("collapse")
			if(3)
				if(prob(1))
					var/datum/disease/D = new /datum/disease/critical/shock
					affected_mob.ForceContractDisease(D)
				if(prob(12))
					affected_mob.Weaken(6)
					affected_mob.Stuttering(10)
					to_chat(affected_mob, "<span class='warning'>Вы чувствуете [pick("онемение", "замешательство", "головокружение", "lightheaded")].</span>")
					affected_mob.emote("collapse")
				if(prob(12))
					to_chat(affected_mob, "<span class='warning'>Вы чувствуете [pick("усталость", "истощение", "вялость")].</span>")
					affected_mob.Slowed(rand(4, 16))
