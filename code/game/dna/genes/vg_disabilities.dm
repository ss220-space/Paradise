
/datum/dna/gene/disability/speech/loud
	name = "Loud"
	desc = "Заставляет речевой центр мозга субъекта выкрикивать каждое предложение."
	activation_message = list("ВАМ ХОЧЕТСЯ КРИЧАТЬ!")
	deactivation_message = list("Вам хочется побыть в тишине...")


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
	desc = "Вызывает отключение мозжечка время от времени."
	activation_message = list("У вас очень сильно кружится голова...")
	deactivation_message = list("Вы вновь обретаете равновесие.")
	instability = -GENE_INSTABILITY_MINOR


/datum/dna/gene/disability/dizzy/New()
	..()
	block = GLOB.dizzyblock


/datum/dna/gene/disability/dizzy/OnMobLife(mob/living/mutant)
	mutant.Dizzy(600 SECONDS)


/datum/dna/gene/disability/dizzy/deactivate(mob/living/mutant, flags)
	. = ..()
	mutant.SetDizzy(0)
