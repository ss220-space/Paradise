/datum/disease/lycan
	name = "Коргашель"
	form = "Инфекция"
	max_stages = 4
	spread_text = "Контактный"
	spread_flags = CONTACT_GENERAL
	cure_text = "Ethanol"
	cures = list("ethanol")
	agent = "Излишние обжимашки"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "Если не вылечить, то субъект будет откашливать… щенят."
	severity = MEDIUM
	var/barklimit = 0

/datum/disease/lycan/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>Вы чешетесь.</span>")
				affected_mob.emote("cough")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>Вы слышите отдалённый лай.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>Вам хочется отведать мяса.</span>")
				affected_mob.emote("cough")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Ваш живот бурлит!</span>")
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Ваш живот лает?!</span>")
			if(prob(5))
				affected_mob.visible_message("<span class='danger'>[affected_mob] воет!</span>", \
												"<span class='userdanger'>Вы воете!</span>")
				affected_mob.AdjustConfused(rand(6, 8))
			if(prob(3) && barklimit <= 10)
				var/list/puppytype = list(/mob/living/simple_animal/pet/dog/corgi/puppy, /mob/living/simple_animal/pet/dog/pug, /mob/living/simple_animal/pet/dog/fox)
				var/mob/living/puppypicked = pick(puppytype)
				affected_mob.visible_message("<span class='danger'>[affected_mob] выкашливает [initial(puppypicked.name)]!</span>", \
													"<span class='userdanger'>Вы выкашливаете [initial(puppypicked.name)]?!</span>")
				new puppypicked(affected_mob.loc)
				new puppypicked(affected_mob.loc)
				barklimit ++
			if(prob(1))
				var/list/plushtype = list(/obj/item/toy/plushie/orange_fox, /obj/item/toy/plushie/corgi, /obj/item/toy/plushie/robo_corgi, /obj/item/toy/plushie/pink_fox)
				var/obj/item/toy/plushie/coughfox = pick(plushtype)
				new coughfox(affected_mob.loc)
				affected_mob.visible_message("<span class='danger'>[affected_mob] выкашливает [initial(coughfox.name)]!</span>", \
													"<span class='userdanger'>Вы выкашливаете [initial(coughfox.name)]?!</span>")

			affected_mob.emote("cough")
			affected_mob.adjustBruteLoss(5)
	return
