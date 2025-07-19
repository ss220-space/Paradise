/datum/disease/virus/pierrot_throat
	name = "Горло Пьеро"
	agent = "H0NI<42 Virus"
	desc = "Заболевание мозга, которое было завезено первыми исследователями планеты Клоунов, которое повреждает базальные ганглии, жертвы будут иметь неконтролируемое желание делать ХОНК."
	max_stages = 4
	spread_flags = AIRBORNE
	cures = list("banana")
	cure_prob = 75
	permeability_mod = 0.75
	severity = MEDIUM
	possible_mutations = list(/datum/disease/virus/pierrot_throat/advanced, /datum/disease/virus/wizarditis)

/datum/disease/virus/pierrot_throat/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(10))
				to_chat(affected_mob, span_danger("Вы чувствуете себя немного глупо."))
		if(2)
			if(prob(10))
				to_chat(affected_mob, span_danger("Вы начинаете видеть радуги."))
		if(3)
			if(prob(10))
				to_chat(affected_mob, span_danger("Ваши мысли прерывает громкий <b>ХОНК!</b>"))
		if(4)
			if(prob(5))
				affected_mob.say(pick(list("ХОНК!", "Хонк!", "Хонк.", "Хонк?", "Хонк!!", "Хонк?!", "Хонк...")))


/datum/disease/virus/pierrot_throat/advanced
	name = "Улучшенный \"Горло Пьеро\""
	agent = "H0NI<42.B4n4 Virus"
	desc = "Мутировавший вирус, происходящий от \"Горло Пьеро\". Помимо неконтролируемого желания делать хонк, субъект также отращивает неснимаемую маску клоуна. Хонко-мать одобряет."
	severity = DANGEROUS
	possible_mutations = null

/datum/disease/virus/pierrot_throat/advanced/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(5))
				to_chat(affected_mob, span_danger("Вам хочется пошутить."))
		if(2)
			if(prob(10))
				to_chat(affected_mob, span_danger("Вы не просто начинаете видеть радуги... ВЫ САМИ СТАНОВИТЕСЬ РАДУГОЙ!"))
		if(3)
			if(prob(10))
				to_chat(affected_mob, span_danger("Ваши мысли прерывает громкий <b>ХОНК!</b>"))
				SEND_SOUND(affected_mob, sound('sound/items/airhorn.ogg'))
		if(4)
			if(prob(5))
				affected_mob.say(pick(list("ХОНК!", "Хонк!", "Хонк.", "Хонк?", "Хонк!!", "Хонк?!", "Хонк...")))

			if(!istype(affected_mob.wear_mask, /obj/item/clothing/mask/gas/clown_hat/nodrop))
				affected_mob.drop_item_ground(affected_mob.wear_mask, force = TRUE)
				affected_mob.equip_to_slot(new /obj/item/clothing/mask/gas/clown_hat/nodrop(src), ITEM_SLOT_MASK)
