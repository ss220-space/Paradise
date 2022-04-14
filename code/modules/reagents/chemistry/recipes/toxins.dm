/datum/chemical_reaction/formaldehyde
	name = "Формальдегид" // formaldehyde
	id = "formaldehyde"
	result = "formaldehyde"
	required_reagents = list("ethanol" = 1, "oxygen" = 1, "silver" = 1)
	result_amount = 3
	min_temp = T0C + 150
	mix_message = "Фe, теперь здесь пахнет моргом."

/datum/chemical_reaction/neurotoxin2
	name = "Нейротоксин №2" // neurotoxin2
	id = "neurotoxin2"
	result = "neurotoxin2"
	required_reagents = list("space_drugs" = 1)
	result_amount = 1
	min_temp = T0C + 400
	mix_sound = null
	mix_message = null

/datum/chemical_reaction/cyanide
	name = "Цианид" // Cyanide
	id = "cyanide"
	result = "cyanide"
	required_reagents = list("oil" = 1, "ammonia" = 1, "oxygen" = 1)
	result_amount = 3
	min_temp = T0C + 100
	mix_message = "Смесь источает слабый аромат миндаля."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/cyanide/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>Смесь образует густой пар!</span>")
	for(var/mob/living/carbon/C in range(T, 1))
		if(C.can_breathe_gas())
			C.reagents.add_reagent("cyanide", 7)

/datum/chemical_reaction/itching_powder
	name = "Зудящий порошок" // Itching Powder
	id = "itching_powder"
	result = "itching_powder"
	required_reagents = list("fuel" = 1, "ammonia" = 1, "fungus" = 1)
	result_amount = 3
	mix_message = "Смесь сгущается и высыхает, оставляя после себя абразивный порошок."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/facid
	name = "Фторсерная кислота" // Fluorosulfuric Acid
	id = "facid"
	result = "facid"
	required_reagents = list("sacid" = 1, "fluorine" = 1, "hydrogen" = 1, "potassium" = 1)
	result_amount = 4
	min_temp = T0C + 100
	mix_message = "Смесь становится тёмно-синей и начинает понемногу разъедать контейнер."

/datum/chemical_reaction/initropidril
	name = "Инитропидрил" // Initropidril
	id = "initropidril"
	result = "initropidril"
	required_reagents = list("crank" = 1, "histamine" = 1, "krokodil" = 1, "bath_salts" = 1, "atropine" = 1, "nicotine" = 1, "morphine" = 1)
	result_amount = 4
	mix_message = "От неприятного молочной субстанции исходит приторно-сладкий аромат."

/datum/chemical_reaction/sulfonal
	name = "Сульфонал" // sulfonal
	id = "sulfonal"
	result = "sulfonal"
	required_reagents = list("acetone" = 1, "diethylamine" = 1, "sulfur" = 1)
	result_amount = 3
	mix_message = "Смесь испускает сильный смрад."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/lipolicide
	name = "Липолицид" // lipolicide
	id = "lipolicide"
	result = "lipolicide"
	required_reagents = list("mercury" = 1, "diethylamine" = 1, "ephedrine" = 1)
	result_amount = 3

/datum/chemical_reaction/sarin
	name = "Зарин" // sarin
	id = "sarin"
	result = "sarin"
	required_reagents = list("chlorine" = 1, "fuel" = 1, "oxygen" = 1, "phosphorus" = 1, "fluorine" = 1, "hydrogen" = 1, "acetone" = 1, "atrazine" = 1)
	result_amount = 3
	mix_message = "Смесь образует бесцветную жидкость без запаха."
	min_temp = T0C + 100
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/sarin/on_reaction(datum/reagents/holder)
	var/turf/T = get_turf(holder.my_atom)
	T.visible_message("<span class='warning'>Смесь образует густой пар!</span>")
	for(var/mob/living/carbon/C in range(T, 2))
		if(C.can_breathe_gas())
			C.reagents.add_reagent("sarin", 4)

/datum/chemical_reaction/glyphosate
	name = "Глифосат" // glyphosate
	id = "glyphosate"
	result = "glyphosate"
	required_reagents = list("chlorine" = 1, "phosphorus" = 1, "formaldehyde" = 1, "ammonia" = 1)
	result_amount = 4

/datum/chemical_reaction/atrazine
	name = "Атразин" // atrazine
	id = "atrazine"
	result = "atrazine"
	required_reagents = list("chlorine" = 1, "hydrogen" = 1, "nitrogen" = 1)
	result_amount = 3
	mix_message = "Смесь испускает резкий запах."

/datum/chemical_reaction/pestkiller // To-Do make this more realistic
	name = "Дихлофос" // Pest Killer
	id = "pestkiller"
	result = "pestkiller"
	required_reagents = list("toxin" = 1, "ethanol" = 4)
	result_amount = 5
	mix_message = "Смесь испускает резкий запах."

/datum/chemical_reaction/capulettium
	name = "Капулеттий" // capulettium
	id = "capulettium"
	result = "capulettium"
	required_reagents = list("neurotoxin2" = 1, "chlorine" = 1, "hydrogen" = 1)
	result_amount = 1
	mix_message = "От микстуры исходит запах смерти."

/datum/chemical_reaction/capulettium_plus
	name = "Капулеттий Плюс" // capulettium_plus
	id = "capulettium_plus"
	result = "capulettium_plus"
	required_reagents = list("capulettium" = 1, "ephedrine" = 1, "methamphetamine" = 1)
	result_amount = 3
	mix_message = "Раствор начинает буйно плескаться сам по себе."

/datum/chemical_reaction/teslium
	name = "Теслий" // Teslium
	id = "teslium"
	result = "teslium"
	required_reagents = list("plasma" = 1, "silver" = 1, "blackpowder" = 1)
	result_amount = 3
	mix_message = "<span class='danger'>Смесь сливается в мерцающую жижу и выбрасывает сноп искр.</span>"
	min_temp = T0C + 50
	mix_sound = null

/datum/chemical_reaction/teslium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	do_sparks(6, 1, location)

/datum/chemical_reaction/mutagen
	name = "Нестабильный мутаген" // Unstable mutagen
	id = "mutagen"
	result = "mutagen"
	required_reagents = list("radium" = 1, "plasma" = 1, "chlorine" = 1)
	result_amount = 3
	mix_message = "Вещество становится неоново-зелёным и тревожно пузырится."

/datum/chemical_reaction/stable_mustagen
	name = "Стабильный мутаген" // Stable mutagen
	id = "stable_mutagen"
	result = "stable_mutagen"
	required_reagents = list("mutagen" = 1, "lithium" = 1, "acetone" = 1, "bromine" = 1)
	result_amount = 3
	mix_message = "Вещество становится тускло-зелёным и начинает побулькивать."

/datum/chemical_reaction/stable_mustagen/stable_mustagen2
	id = "stable_mutagen2"
	required_reagents = list("mutadone" = 3, "lithium" = 1)
	result_amount = 4

/datum/chemical_reaction/rotatium
	name = "Ротатий" // Rotatium
	id = "Rotatium"
	result = "rotatium"
	required_reagents = list("lsd" = 1, "teslium" = 1, "methamphetamine" = 1)
	result_amount = 3
	mix_message = "<span class='danger'>Сноп искр, пламя и резкий запах ЛСД. После чего смесь начинает крутиться без остановки.</span>"
