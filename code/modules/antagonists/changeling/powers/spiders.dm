/datum/action/changeling/spiders
	name = "Распространение заражения"
	desc = "Наш сосуд делится, создавая паукообразных, которые вырастут в смертоносных зверей. Требуется 30 химикатов."
	helptext = "Пауки бездумные существа и могут атаковать своих создателей, когда вырастут. Можно использовать в низшей форме."
	button_icon_state = "spread_infestation"
	dna_cost = 1
	chemical_cost = 30
	power_type = CHANGELING_PURCHASABLE_POWER

/datum/action/changeling/spiders/sting_action(mob/user)
	for(var/i in 1 to 3)
		var/obj/structure/spider/spiderling/spider = new(user.loc)
		spider.grow_as = /mob/living/simple_animal/hostile/poison/giant_spider/hunter
		spider.amount_grown = 100 //insta grown up

	SSblackbox.record_feedback("nested tally", "changeling_powers", 1, list("[name]"))
	return TRUE
