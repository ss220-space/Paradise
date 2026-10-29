/datum/disease/virus/blood_plague
	name = "Кровавая чума"
	desc = "Этот вирус заражает гуманоидов и пробуждает в них неестественную жажду крови."
	max_stages = 7
	spread_flags = BLOOD|BITES
	cure_text = "Божественная защита"
	cures = list()
	agent = ""
	infectable_mobtypes = list(/mob/living/carbon/human)
	severity = DISEASE_SEVERITY_BIOHAZARD
	can_progress_in_dead = TRUE
	carrier = TRUE
	virus_heal_resistant = TRUE
	stage_prob = 100 // It isn't actually 100%, but is instead based on a timer
	cure_prob = 30
	/// Cooldown until the virus can advance to the next stage
	COOLDOWN_DECLARE(stage_timer)

/datum/disease/virus/blood_plague/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(4))
				to_chat(affected_mob, span_warning("[pick("Кожа на шее чешется.", "Вам кажется, что вы слишком остро чувствуете запахи.")]"))
			else if(prob(5))
				to_chat(affected_mob, span_warning("У вас чешется [pick("спина", "рука", "нога", "локоть", "голова")]."))

		if(2)
			if(prob(2))
				to_chat(affected_mob, span_danger("По задней стенке горла стекает солоноватая слизь."))
			else if(prob(5))
				to_chat(affected_mob, span_warning("[pick("Вы чувствуете жажду.", "Вам хочется чего-нибудь выпить.", "В горле пересохло.")]"))
			if(prob(4))
				to_chat(affected_mob, span_warning("[pick("Дёсны ноют.", "Зубы ломит, будто их что-то распирает изнутри.")]"))

		if(3)
			if(prob(2))
				affected_mob.emote("sneeze")
			else if(prob(2))
				affected_mob.emote("cough")
			else if(prob(5))
				to_chat(affected_mob, span_warning("<i>[pick("Так хочется пить...", "Вы бы отдали всё за глоток...", "Жажда сводит горло...")]</i>"))
			if(prob(5))
				affected_mob.adjustToxLoss(1)
			if(prob(4))
				to_chat(affected_mob, span_danger("[pick("Боль пульсирует в корнях зубов.", "Дёсны кровоточат, а зубы ломит всё сильнее.")]"))

		if(4)
			if(prob(2))
				affected_mob.emote("stare")
			else if(prob(2))
				affected_mob.emote("drool")
			else if(prob(5))
				to_chat(affected_mob, span_danger("Вы чувствуете, как выступает холодный пот."))
			if(prob(25))
				affected_mob.adjustToxLoss(1)
			if(prob(4))
				to_chat(affected_mob, span_danger("[pick("Дёсны горят, зубы ноют не переставая.", "Такое чувство, что каждый зуб сидит в челюсти слишком плотно.", "Боль в зубах отдаёт в челюсть.")]"))

		if(5, 6)
			var/turf/location = get_turf(affected_mob)
			if(location.get_lumcount() >= 0.5)
				if(prob(5))
					to_chat(affected_mob, span_danger("Эти огни кажутся яркими. Жжётся."))
				if(prob(25))
					affected_mob.adjustFireLoss(2)
			if(prob(2))
				affected_mob.emote("drool")
			if(stage == 5 && prob(4))
				to_chat(affected_mob, span_danger("[pick("Дёсны онемели, а боль в зубах стала глухой и постоянной.", "Зубы ломит так, что трудно сжать челюсть.")]"))
			if(stage == 6)
				if(prob(5))
					to_chat(affected_mob, span_danger(span_red("[pick("Клыки заметно удлинились и режут язык.", "Верхние клыки немного вытянулись, дёсны горят.")]")))

				if(!affected_mob.reagents.has_reagent(/datum/reagent/holywater))
					if(prob(10))
						to_chat(affected_mob, span_danger(span_red("Вы чувствуете, как ваша кровь закипает от жажды.")))
					if(prob(10) || affected_mob.stat != DEAD)
						affected_mob.adjustToxLoss(1)
		if(7)
			transform_vampire()
			affected_mob.adjust_nutrition(-0.5)
			return FALSE

/datum/disease/virus/blood_plague/try_increase_stage()
	if(!stage_timer)
		COOLDOWN_START(src, stage_timer, 1 MINUTES) // for the first infection
	if(affected_mob.stat != DEAD || !prob(30)) // when the body is dead, it always has a 30% chance to advance regardless
		if(!COOLDOWN_FINISHED(src, stage_timer))
			return
	COOLDOWN_START(src, stage_timer, 1 MINUTES)
	..()

/datum/disease/virus/blood_plague/has_cure()
	if(affected_mob.can_block_magic(MAGIC_RESISTANCE_HOLY))
		return TRUE
	return ..()

/datum/disease/virus/blood_plague/proc/transform_vampire()
	if(!affected_mob?.mind?.has_antag_datum(/datum/antagonist/vampire))
		affected_mob.mind.add_antag_datum(/datum/antagonist/vampire/virus_vampire)
	return TRUE

/datum/disease/virus/blood_plague/cure(id, need_immunity)
	affected_mob.mind.remove_antag_datum(/datum/antagonist/vampire/virus_vampire)
	return ..()
