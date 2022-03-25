/datum/disease/tuberculosis
	form = "Болезнь"
	name = "Грибной туберкулёз"
	max_stages = 5
	spread_text = "Воздушно-капельный"
	cure_text = "Spaceacillin & salbutamol"
	cures = list("spaceacillin", "salbutamol")
	agent = "Космическая грибковая туберкулезная бацилла"
	viable_mobtypes = list(/mob/living/carbon/human)
	cure_chance = 5//like hell are you getting out of hell
	desc = "Редкий высококонтагиозный вирулентный вирус. Существует несколько штаммов, которые, по слухам, были тщательно выращены и культивированы нелегальными специалистами по биологическому оружию. Вызывает лихорадку, кровавую рвоту, повреждение лёгких, истощение и слабость."
	required_organs = list(/obj/item/organ/internal/lungs)
	severity = DANGEROUS
	bypasses_immunity = TRUE //Fungal and bacterial in nature; also infects the lungs

/datum/disease/tuberculosis/stage_act() //it begins
	..()
	switch(stage)
		if(2)
			if(prob(2))
				affected_mob.emote("cough")
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете боль в груди.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Ваш желудок громко урчит!</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Вас пробивает холодный пот.</span>")
		if(4)
			if(prob(2))
				to_chat(affected_mob, "<span class='userdanger'>У вас в глазах всё двоится</span>")
				affected_mob.Dizzy(5)
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Вы ощущаете острую боль в нижней части груди!</span>")
				affected_mob.adjustOxyLoss(5)
				affected_mob.emote("gasp")
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете боль, выдыхая воздух из лёгких.</span>")
				affected_mob.adjustOxyLoss(25)
				affected_mob.emote("gasp")
		if(5)
			if(prob(2))
				to_chat(affected_mob, "<span class='userdanger'>[pick("Ваше сердце начинает биться реже…", "Вы расслабляетесь и сердцебиение замедляется.")]</span>")
				affected_mob.adjustStaminaLoss(70)
			if(prob(10))
				affected_mob.adjustStaminaLoss(100)
				affected_mob.visible_message("<span class='warning'>[affected_mob] падает в обморок!</span>", "<span class='userdanger'>Вы прекращаете бороться и чувствуете умиротворение…</span>")
				affected_mob.AdjustSleeping(5)
			if(prob(2))
				to_chat(affected_mob, "<span class='userdanger'>Ваш разум блуждает, а мысли путаются…</span>")
				affected_mob.AdjustConfused(8, bound_lower = 0, bound_upper = 100)
			if(prob(10))
				affected_mob.vomit(20)
			if(prob(3))
				to_chat(affected_mob, "<span class='warning'><i>[pick("Ваш желудок негромко урчит…", "Ваш желудок сжался и обмяк, а мышцы мертвы и безжизненны.", "Вам хочется съесть парочку мелков.")]</i></span>")
				affected_mob.overeatduration = max(affected_mob.overeatduration - 100, 0)
				affected_mob.adjust_nutrition(-100)
			if(prob(15))
				to_chat(affected_mob, "<span class='danger'>[pick("Вв чувствуете неприятный жар…", "Вам хочется расстегнуть комбинезон.", "Вам хочется снять одежду…")]</span>")
				affected_mob.bodytemperature += 40
	return
