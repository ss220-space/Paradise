
/datum/dna/gene/disability/speech/loud
	name = "Loud"
	desc = "Заставляет речевой центр мозга субъекта выкрикивать каждое предложение."
	activation_message = "ВАМ ХОЧЕТСЯ КРИЧАТЬ!"
	deactivation_message = "Вам хочется помолчать.."
	mutation = LOUD

/datum/dna/gene/disability/speech/loud/New()
	..()
	block = GLOB.loudblock



/datum/dna/gene/disability/speech/loud/OnSay(mob/M, message)
	message = replacetext(message,".","!")
	message = replacetext(message,"?","?!")
	message = replacetext(message,"!","!!")
	return uppertext(message)

/datum/dna/gene/disability/dizzy
	name = "Dizzy"
	desc = "Вызывает отключение мозжечка в некоторых местах."
	activation_message = "У вас сильно кружится голова..."
	deactivation_message = "Вы восстанавливаете равновесие."
	instability = -GENE_INSTABILITY_MINOR
	mutation = DIZZY

/datum/dna/gene/disability/dizzy/New()
	..()
	block = GLOB.dizzyblock


/datum/dna/gene/disability/dizzy/OnMobLife(mob/living/carbon/human/M)
	if(!istype(M))
		return
	if(DIZZY in M.mutations)
		M.Dizzy(600 SECONDS)


/datum/dna/gene/disability/dizzy/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.SetDizzy(0)
