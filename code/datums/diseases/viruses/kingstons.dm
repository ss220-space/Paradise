/datum/disease/virus/kingstons
	name = "Синдром Кингстона"
	agent = "Ня-вирус"
	desc = "Если не лечить, заражённый превратится в кошку. У кошек это вызывает... ДРУГИЕ... эффекты."
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
					to_chat(affected_mob, span_notice("Вы чувствуете себя хорошо."))
				else
					to_chat(affected_mob, span_notice("Вам хочется поиграть с верёвочкой."))

		if(2)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, span_danger("У вас чешется что-то в горле."))
				else
					to_chat(affected_mob, span_danger("<b>Вам НУЖНО найти мышь!</b>"))

		if(3)
			if(prob(10))
				if(istajaran(affected_mob))
					to_chat(affected_mob, span_danger("Вы чувствуете что-то в горле!"))
					affected_mob.emote("cough")
				else
					if(prob(50))
						affected_mob.say(pick(list("Мяу", "Мяу!", "Ня!~")))
					else
						affected_mob.emote("purrs")

		if(4)
			if(istajaran(affected_mob))
				if(prob(5))
					affected_mob.emote("cough")
					affected_mob.visible_message(span_danger("[affected_mob] откашливает шерстяной комок!"), span_userdanger("Вы откашливаете шерстяной комок!"))
					affected_mob.Stun(10 SECONDS)
			else
				if(prob(30))
					affected_mob.emote("purrs")
				if(prob(5))
					affected_mob.visible_message(span_danger("Форма [affected_mob] искажается, становясь более кошачьей!"), span_userdanger("ВЫ ПРЕВРАЩАЕТЕСЬ В ТАЯРАНА!"))
					var/mob/living/carbon/human/catface = affected_mob
					catface?.set_species(/datum/species/tajaran, retain_damage = TRUE, keep_missing_bodyparts = TRUE)


/datum/disease/virus/kingstons_advanced
	name = "Улучшенный Синдром Кингстона"
	agent = "Бактерии AMB45DR"
	desc = "Если не лечить, заражённый мутирует в другой вид."
	max_stages = 4
	spread_flags = AIRBORNE
	cures = list("plasma")
	cure_prob = 50
	permeability_mod = 0.75
	severity = BIOHAZARD
	var/list/virspecies = list(/datum/species/human, /datum/species/tajaran, /datum/species/unathi, /datum/species/skrell, /datum/species/vulpkanin, /datum/species/diona)
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
					to_chat(H, span_notice("Вы чувствуете себя неловко."))
			if(2, 3)
				if(prob(7) && !istype(H.dna.species, chosentype))
					make_sound(H)
			if(2)
				if(prob(10))
					to_chat(H, span_danger("Вы чешетесь."))
			if(3)
				if(prob(10))
					to_chat(H, span_danger("Ваша кожа начинает шелушиться!"))
			if(4)
				if(!istype(H.dna.species, chosentype))
					if(prob(30))
						make_sound(H)
					if(prob(5))
						var/bodyname_ru = list(SPECIES_HUMAN = "человека", SPECIES_TAJARAN = "таярана", SPECIES_UNATHI = "унатха", SPECIES_SKRELL = "скрелла", SPECIES_VULPKANIN = "вульпканина", SPECIES_DIONA = "диону")
						H.visible_message(span_danger("Кожа [H.declent_ru(ACCUSATIVE)] трескается, и его форма искажается!"), span_userdanger("Ваше тело мутирует в [bodyname_ru[initial(chosentype.name)]]!"))
						H.set_species(chosentype, retain_damage = TRUE, keep_missing_bodyparts = TRUE)
				else
					if(prob(5))
						H.visible_message(span_danger("[H.declent_ru(ACCUSATIVE)] царапает свою кожу!"), span_userdanger("Вы царапаете свою кожу, чтобы избавиться от зуда!"))
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

