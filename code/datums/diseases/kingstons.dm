/datum/disease/kingstons
	name = "Синдром Кингстона"
	max_stages = 4
	spread_text = "Воздушно-капельный"
	cure_text = "Milk"
	cures = list("milk")
	cure_chance = 50
	agent = "Ня-вирус"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "Если не вылечить, то субъект превратится в представителя кошачьих. На кошачьих же синдром Кингстона действует… НЕМНОГО ИНАЧЕ…"
	severity = DANGEROUS

/datum/disease/kingstons/stage_act()
	..()
	switch(stage)
		if(1)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, "<span class='notice'>Вы хорошо себя чувствуете.</span>")
				else
					to_chat(affected_mob, "<span class='notice'>Вы были бы не прочь поиграть с верёвочкой.</span>")
		if(2)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, "<span class='danger'>У вас что-то чешется в горле.</span>")
				else
					to_chat(affected_mob, "<span class='danger'>Вам НУЖНО найти мышь.</span>")
		if(3)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, "<span class='danger'>У вас что-то застряло в горле!</span>")
					affected_mob.emote("cough")
				else
					affected_mob.say(pick(list("Мяу", "Мя-я-у!", "Ня!~")))
		if(4)
			if(prob(5))
				if(istajaran(affected_mob))
					affected_mob.visible_message("<span class='danger'>[affected_mob] выкашливает комок шерсти!</span>", \
													"<span class='userdanger'>Вы выкашливаете комок шерсти!</span>")
					affected_mob.Stun(5)
				else
					affected_mob.visible_message("<span class='danger'>Черты [affected_mob] становятся намного более кошачьими!</span>", \
													"<span class='userdanger'>ВЫ ПРЕВРАТИЛИСЬ В ТАЯРАНА!</span>")
					var/mob/living/carbon/human/catface = affected_mob
					catface.set_species(/datum/species/tajaran, retain_damage = TRUE)


/datum/disease/kingstons_advanced //this used to be directly a subtype of kingstons, which sounds nice, but it ment that it would *turn you into a tarjaran always and have normal kingstons stage act* Don't make virusus subtypes unless the base virus does nothing.
	name = "Улучшенный синдром Кингстона"
	max_stages = 4
	spread_text = "Воздушно-капельный"
	cure_text = "Plasma"
	cures = list("plasma")
	cure_chance = 50
	agent = "Бактерия AMB45DR"
	viable_mobtypes = list(/mob/living/carbon/human)
	permeability_mod = 0.75
	desc = "Если не вылечить, то субъект превратится в представителя другого вида"
	severity = BIOHAZARD
	var/list/virspecies = list(/datum/species/human, /datum/species/tajaran, /datum/species/unathi,/datum/species/skrell, /datum/species/vulpkanin, /datum/species/wryn, /datum/species/kidan, /datum/species/drask, /datum/species/diona)
	var/list/virsuffix = list("оспа", "гниль", "волчанка", "потница", "простуда", "чума", "водянка", "сыпь", "чесотка", "корь", "желтуха")
	var/datum/species/chosentype
	var/chosensuff

/datum/disease/kingstons_advanced/New()
	chosentype = pick(virspecies)
	chosensuff = pick(virsuffix)

	name = "[initial(chosentype.name_adjective_female)] [chosensuff]"

/datum/disease/kingstons_advanced/stage_act()
	..()
	if(ishuman(affected_mob))
		var/mob/living/carbon/human/twisted = affected_mob
		switch(stage)
			if(1)
				if(prob(10))
					to_chat(twisted, "<span class='notice'>Вы чувствуете себя странно.</span>")
			if(2)
				if(prob(10))
					to_chat(twisted, "<span class='danger'>Вы чешетесь.</span>")
			if(3)
				if(prob(10))
					to_chat(twisted, "<span class='danger'>У вас начинает слезать кожа!</span>")

			if(4)
				if(prob(5))
					if(!istype(twisted.dna.species, chosentype))
						twisted.visible_message("<span class='danger'>Кожа [twisted] рвётся и вытягивается!</span>", \
														"<span class='userdanger'>Ваше тело мутирует в [initial(chosentype.name)]!</span>")
						twisted.set_species(chosentype, retain_damage = TRUE)
					else
						twisted.visible_message("<span class='danger'>[twisted] расцарапывает свою кожу!</span>", \
														"<span class='userdanger'>Вы царапаете свою кожу, чтобы она перестала так чесаться!</span>")
						twisted.adjustBruteLoss(-5)
						twisted.adjustStaminaLoss(5)
