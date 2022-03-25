/datum/disease/pierrot_throat
	name = "Горло Пьеро"
	max_stages = 4
	spread_text = "Аэрогенный"
	cure_text = "Банановые продукты, особенно банановый хлеб."
	cures = list("banana")
	cure_chance = 75
	agent = "Вирус Х0Н1<42"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "Если не лечить, субъект, вероятно, сведёт окружающих с ума."
	severity = MEDIUM

/datum/disease/pierrot_throat/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Вы, кажется, слегка поглупели.</span>")
		if(2)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Вы начинаете везде видеть радуги.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Ваши мысли прерываются громким <b>ХОНК!</b></span>")
		if(4)
			if(prob(5))
				affected_mob.say( pick( list("ХОНК!", "Хонк!", "Хонк.", "Хонк?", "Хонк!!", "Хонк?!", "Хонк…") ) )


/datum/disease/pierrot_throat/advanced
	name = "Улучшенное Горло Пьеро"
	spread_text = "Аэрогенный"
	cure_text = "Банановые продукты, особенно банановый хлеб."
	cures = list("banana")
	cure_chance = 75
	agent = "Вирус Х0Н1<42.Б4н4н"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "Если не лечить, субъект, вероятно, сведёт окружающих с ума и свихнётся сам."
	severity = DANGEROUS

/datum/disease/pierrot_throat/advanced/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Кажется, вы отупели.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='danger'>Вам очень хочется пошутить.</span>")
		if(2)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Вы не просто начинаете везде видеть радуги… ВЫ И ЕСТЬ РАДУГИ!</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Ваши мысли прерываются громким <b>ХОНК!</b></span>")
				affected_mob << 'sound/items/airhorn.ogg'
		if(4)
			if(prob(5))
				affected_mob.say( pick( list("ХОНК!", "Хонк!", "Хонк.", "Хонк?", "Хонк!!!", "Хонк?!", "Хонк…") ) )

			if(!istype(affected_mob.wear_mask, /obj/item/clothing/mask/gas/clown_hat/nodrop))
				affected_mob.unEquip(affected_mob.wear_mask, TRUE)
				affected_mob.equip_to_slot(new /obj/item/clothing/mask/gas/clown_hat/nodrop(src), slot_wear_mask)
