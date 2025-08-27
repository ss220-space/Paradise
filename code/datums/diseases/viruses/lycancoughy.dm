/datum/disease/virus/lycan
	name = "Коргашель"
	form = "Инфекция"
	agent = "Избыток обнимашек"
	desc = "Если не лечить, заражённый начнёт отрыгивать... щенков."
	max_stages = 4
	spread_flags = CONTACT
	cures = list("ethanol")
	severity = DANGEROUS
	var/barklimit = 0

/datum/disease/virus/lycan/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(2)
			if(prob(5))
				to_chat(affected_mob, span_notice("Вы чешетесь."))
				affected_mob.emote("cough")
		if(3)
			if(prob(10))
				to_chat(affected_mob, span_notice("Вы слышите слабый лай."))
			if(prob(5))
				to_chat(affected_mob, span_notice("Вам хочется мяса."))
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, span_danger("Ваш желудок урчит!"))
		if(4)
			if(prob(10))
				to_chat(affected_mob, span_danger("<b>Ваш желудок лает?!</b>"))
			if(prob(5))
				affected_mob.visible_message(span_danger("[affected_mob] во[pluralize_ru(affected_mob.gender,"ет","ют")]!"), span_userdanger("Вы воете!"))
				affected_mob.AdjustConfused(rand(12 SECONDS, 16 SECONDS))
			if(prob(3) && barklimit <= 10)
				var/list/puppytype = list(
					/mob/living/simple_animal/pet/dog/corgi/puppy,
					/mob/living/simple_animal/pet/dog/pug,
					/mob/living/simple_animal/pet/dog/fox)

				var/mob/living/puppypicked = pick(puppytype)
				affected_mob.visible_message(span_danger("[affected_mob] отрыгива[pluralize_ru(affected_mob.gender,"ет","ют")] [initial(puppypicked.name)]!"), span_userdanger("Вы отрыгиваете [initial(puppypicked.name)]?!"))
				new puppypicked(affected_mob.loc)
				new puppypicked(affected_mob.loc)
				barklimit ++
			if(prob(1))
				var/list/plushtype = list(/obj/item/toy/plushie/orange_fox, /obj/item/toy/plushie/corgi, /obj/item/toy/plushie/robo_corgi, /obj/item/toy/plushie/pink_fox)
				var/obj/item/toy/plushie/coughfox = pick(plushtype)
				new coughfox(affected_mob.loc)
				affected_mob.visible_message(span_danger("[affected_mob] отрыгива[pluralize_ru(affected_mob.gender,"ет","ют")] [coughfox.declent_ru(ACCUSATIVE)]!"), span_userdanger("Вы отрыгиваете [coughfox.declent_ru(ACCUSATIVE)]?!"))
			if(prob(50))
				affected_mob.emote("cough")
			affected_mob.adjustBruteLoss(5)
	return
