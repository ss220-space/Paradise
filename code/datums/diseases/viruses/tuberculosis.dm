/datum/disease/virus/tuberculosis
	form = "Болезнь"
	name = "Грибковый туберкулез"
	agent = "Космическая грибковая туберкулезная бацилла"
	desc = "Редкий высокозаразный вирус. Существует лишь несколько образцов, которые, по слухам, тщательно выращиваются и культивируются специалистами по биологическому оружию. Вызывает лихорадку, кровавую рвоту, повреждение лёгких, потерю веса и усталость."
	spread_flags = AIRBORNE
	cures = list("spaceacillin", "salbutamol")
	cure_prob = 5
	required_organs = list(/obj/item/organ/internal/lungs)
	severity = DANGEROUS
	ignore_immunity = TRUE

/datum/disease/virus/tuberculosis/stage_act()
	if(!..())
		return FALSE

	var/mob/living/carbon/human/H = affected_mob
	switch(stage)
		if(2, 3)
			if(prob(2))
				H.emote("cough")
				to_chat(H, span_danger("Ваша грудь болит."))
			if(prob(2))
				to_chat(H, span_danger("Ваш желудок яростно урчит!"))
			if(prob(5))
				to_chat(H, span_danger("Вы чувствуете, как выступает холодный пот."))
		if(4)
			if(prob(2))
				to_chat(H, span_userdanger("Всё вокруг вас начинает вращаться, и вы теряете ориентацию."))
				H.Dizzy(10 SECONDS)
			if(prob(2))
				to_chat(H, span_danger("Вы чувствуете острую боль в нижней части груди!"))
				H.adjustOxyLoss(5)
				H.emote("gasp")
			if(prob(10))
				to_chat(H, span_danger("Вы чувствуете, как воздух болезненно выходит из ваших лёгких."))
				H.adjustOxyLoss(25)
				H.emote("gasp")
		if(5)
			if(prob(2))
				to_chat(H, span_userdanger("[pick("Вы чувствуете, как ваше сердце замедляется...", "Вы расслабляетесь и замедляете сердцебиение.")]"))
				H.adjustStaminaLoss(70)
			if(prob(10))
				H.adjustStaminaLoss(H.get_max_stamina())
				H.visible_message(span_warning("[H.declent_ru(NOMINATIVE)] падает в обморок!"), span_userdanger("Вы сдаётесь и чувствуете покой..."))
				H.AdjustSleeping(10 SECONDS)
			if(prob(2))
				to_chat(H, span_userdanger("Вы чувствуете, как ваш разум расслабляется, а мысли уплывают!"))
				H.AdjustConfused(16 SECONDS, bound_lower = 0, bound_upper = 200 SECONDS)
			if(prob(10))
				H.vomit(20)
			if(prob(3))
				to_chat(H, span_warning("<i>[pick("Ваш желудок тихо урчит...", "Ваш желудок сводит судорогой, мышцы становятся вялыми и безжизненными.", "Вы бы съели мелок")]</i>"))
				H.overeatduration = max(H.overeatduration - 100, 0)
				H.adjust_nutrition(-100)
			if(prob(15))
				to_chat(H, span_danger("[pick("Вам невыносимо жарко...", "Вам хочется расстегнуть комбинезон", "Вам хочется снять часть одежды...")]"))
				H.adjust_bodytemperature(40)
	return
