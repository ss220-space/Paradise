/datum/disease/virus/kingstons
	name = "Kingstons Syndrome"
	agent = "Nya Virus"
	desc = "If left untreated the subject will turn into a feline. In felines it has... OTHER... effects."
	max_stages = 4
	spread_flags = AIRBORNE
	cures = list("milk")
	cure_prob = 50
	permeability_mod = 0.75
	severity = DANGEROUS
	mutation_reagents = list("mutagen", "radium")
	possible_mutations = list(/datum/disease/virus/kingstons_advanced)

/datum/disease/virus/kingstons/stage_act()
	if(!..())
		return FALSE

	switch(stage)
		if(1)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, span_notice("You feel good."))
				else
					to_chat(affected_mob, span_notice("You feel like playing with string."))

		if(2)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, span_danger("Something in your throat itches."))
				else
					to_chat(affected_mob, span_danger("You NEED to find a mouse."))

		if(3)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, span_danger("You feel something in your throat!"))
					affected_mob.emote("cough")
				else
					if(prob(50))
						affected_mob.say(pick(list("Mew", "Meow!", "Nya!~")))
					else
						affected_mob.emote("purrs")

		if(4)
			if(istajaran(affected_mob))
				if(prob(5))
					affected_mob.visible_message(span_danger("[affected_mob] coughs up a hairball!"), \
													span_userdanger("You cough up a hairball!"))
					affected_mob.Stun(10 SECONDS)
			else
				if(prob(30))
					affected_mob.emote("purrs")
				if(prob(5))
					affected_mob.visible_message(span_danger("[affected_mob]'s form contorts into something more feline!"), \
													span_userdanger("YOU TURN INTO A TAJARAN!"))
					var/mob/living/carbon/human/catface = affected_mob
					catface?.set_species(/datum/species/tajaran, retain_damage = TRUE, keep_missing_bodyparts = TRUE)


/datum/disease/virus/kingstons_advanced
	name = "Advanced Kingstons Syndrome"
	agent = "AMB45DR Bacteria"
	desc = "If left untreated the subject will mutate to a different species."
	max_stages = 4
	spread_flags = AIRBORNE
	cures = list("plasma")
	cure_prob = 50
	permeability_mod = 0.75
	severity = BIOHAZARD
	var/list/virspecies = list(/datum/species/human, /datum/species/tajaran, /datum/species/unathi,/datum/species/skrell, /datum/species/vulpkanin, /datum/species/diona)
	var/list/virsuffix = list("pox", "rot", "flu", "cough", "-gitis", "cold", "rash", "itch", "decay")
	var/datum/species/chosentype
	var/chosensuff
	possible_mutations = null

/datum/disease/virus/kingstons_advanced/New()
	..()
	chosentype = pick(virspecies)
	chosensuff = pick(virsuffix)

	name = "[initial(chosentype.name)] [chosensuff]"

/datum/disease/virus/kingstons_advanced/Copy()
	var/datum/disease/virus/kingstons_advanced/KA = ..()
	KA.chosentype = chosentype
	KA.chosensuff = chosensuff
	KA.name = name
	return KA

/datum/disease/virus/kingstons_advanced/stage_act()
	if(!..())
		return FALSE

	if(ishuman(affected_mob))
		var/mob/living/carbon/human/H = affected_mob
		switch(stage)
			if(1)
				if(prob(10))
					to_chat(H, span_notice("You feel awkward."))
			if(2, 3)
				if(prob(7) && !istype(H.dna.species, chosentype))
					make_sound(H)
			if(2)
				if(prob(10))
					to_chat(H, span_danger("You itch."))
			if(3)
				if(prob(10))
					to_chat(H, span_danger("Your skin starts to flake!"))
			if(4)
				if(!istype(H.dna.species, chosentype))
					if(prob(30))
						make_sound(H)
					if(prob(5))
						H.visible_message(span_danger("[H]'s skin splits and form contorts!"), \
														span_userdanger("Your body mutates into a [initial(chosentype.name)]!"))
						H.set_species(chosentype, retain_damage = TRUE, keep_missing_bodyparts = TRUE)
				else
					if(prob(5))
						H.visible_message(span_danger("[H] scratches at thier skin!"), \
														span_userdanger("You scratch your skin to try not to itch!</span>"))
						H.adjustBruteLoss(5)
						affected_mob.Stun(rand(2 SECONDS, 4 SECONDS))


/datum/disease/virus/kingstons_advanced/proc/make_sound(mob/living/carbon/human/H)
	if(!istype(H))
		return

	switch(chosentype)
		if(/datum/species/tajaran)
			H.emote("purr")
		if(/datum/species/unathi)
			H.emote("hiss")
		if(/datum/species/skrell)
			H.emote("warble")
		if(/datum/species/vulpkanin)
			H.emote("howl")
		if(/datum/species/diona)
			H.emote("creak")

