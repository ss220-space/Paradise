// foam and foam precursor

/datum/chemical_reaction/surfactant
	name = "Пенообразователь" // Foam surfactant
	id = "foam surfactant"
	result = "fluorosurfactant"
	required_reagents = list("fluorine" = 2, "carbon" = 2, "sacid" = 1)
	result_amount = 5
	mix_message = "Пенная шапка возникает из-за постоянного шипения смеси."

/datum/chemical_reaction/foam
	name = "Пена" // Foam
	id = "foam"
	result = null
	required_reagents = list("fluorosurfactant" = 1, "water" = 1)
	result_amount = 2

/datum/chemical_reaction/foam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	holder.my_atom.visible_message("<span class='warning'>Смесь пенится!</span>")

	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, 0)
	s.start()
	holder.clear_reagents()


/datum/chemical_reaction/metalfoam
	name = "Металлическая пена" // Metal Foam
	id = "metalfoam"
	result = null
	required_reagents = list("aluminum" = 3, "fluorosurfactant" = 1, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/metalfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	holder.my_atom.visible_message("<span class='warning'>Смесь пенится металлической пеной!</span>")

	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, MFOAM_ALUMINUM)
	s.start()


/datum/chemical_reaction/ironfoam
	name = "Железная пена" // Iron Foam
	id = "ironlfoam"
	result = null
	required_reagents = list("iron" = 3, "fluorosurfactant" = 1, "sacid" = 1)
	result_amount = 5

/datum/chemical_reaction/ironfoam/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)

	holder.my_atom.visible_message("<span class='warning'>Смесь пенится металлической пеной!</span>")

	var/datum/effect_system/foam_spread/s = new()
	s.set_up(created_volume, location, holder, MFOAM_IRON)
	s.start()


	// Synthesizing these three chemicals is pretty complex in real life, but fuck it, it's just a game!
/datum/chemical_reaction/ammonia
	name = "Аммиак" // Ammonia
	id = "ammonia"
	result = "ammonia"
	required_reagents = list("hydrogen" = 3, "nitrogen" = 1)
	result_amount = 3
	mix_message = "Смесь пузырится и едко воняет."

/datum/chemical_reaction/diethylamine
	name = "Диэтиламин" // Diethylamine
	id = "diethylamine"
	result = "diethylamine"
	required_reagents = list ("ammonia" = 1, "ethanol" = 1)
	result_amount = 2
	min_temp = T0C + 100
	mix_message = "От смеси исходит ужасный запах."

/datum/chemical_reaction/space_cleaner
	name = "Космический очиститель" // Space cleaner
	id = "cleaner"
	result = "cleaner"
	required_reagents = list("ammonia" = 1, "water" = 1, "ethanol" = 1)
	result_amount = 3
	mix_message = "Фу, оно сильно воняет. Хотя контейнер теперь просто сверкает чистотой!"

/datum/chemical_reaction/sulfuric_acid
	name = "Серная кислота" // Sulfuric Acid
	id = "sacid"
	result = "sacid"
	required_reagents = list("sulfur" = 1, "oxygen" = 1, "hydrogen" = 1)
	result_amount = 2
	mix_message = "Смесь издаёт резкий кислый запах."

/datum/chemical_reaction/plastic_polymers
	name = "Пластиковый полимер" // plastic polymers
	id = "plastic_polymers"
	result = null
	required_reagents = list("oil" = 5, "sacid" = 2, "ash" = 3)
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/plastic_polymers/on_reaction(datum/reagents/holder, created_volume)
	var/obj/item/stack/sheet/plastic/P = new /obj/item/stack/sheet/plastic
	P.amount = 10
	P.forceMove(get_turf(holder.my_atom))

/datum/chemical_reaction/lube
	name = "Космическая смазка" // Space Lube
	id = "lube"
	result = "lube"
	required_reagents = list("water" = 1, "silicon" = 1, "oxygen" = 1)
	result_amount = 3
	mix_message = "Смесь становится ярко-голубой и очень маслянистой."

/datum/chemical_reaction/holy_water
	name = "Святая вода" // Holy Water
	id = "holywater"
	result = "holywater"
	required_reagents = list("water" = 1, "mercury" = 1, "wine" = 1)
	result_amount = 3
	mix_message = "Вода выглядит как-то очищенной. Или, наоборот, осквернённой."

/datum/chemical_reaction/drying_agent
	name = "Осушающий агент" // Drying agent
	id = "drying_agent"
	result = "drying_agent"
	required_reagents = list("plasma" = 2, "ethanol" = 1, "sodium" = 1)
	result_amount = 3

/datum/chemical_reaction/saltpetre
	name = "Селитра" // saltpetre
	id = "saltpetre"
	result = "saltpetre"
	required_reagents = list("potassium" = 1, "nitrogen" = 1, "oxygen" = 3)
	result_amount = 3
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/acetone
	name = "Ацетон" // acetone
	id = "acetone"
	result = "acetone"
	required_reagents = list("oil" = 1, "fuel" = 1, "oxygen" = 1)
	result_amount = 3
	mix_message = "Смесь начинает пузыриться и вас накрывает запахом растворителя."

/datum/chemical_reaction/carpet
	name = "Ковёр" // carpet
	id = "carpet"
	result = "carpet"
	required_reagents = list("fungus" = 1, "blood" = 1)
	result_amount = 2
	mix_message = "Вещество становится густым и плотным, но мягким."


/datum/chemical_reaction/oil
	name = "Масло" // Oil
	id = "oil"
	result = "oil"
	required_reagents = list("fuel" = 1, "carbon" = 1, "hydrogen" = 1)
	result_amount = 3
	mix_message = "В контейнере образуется блестящее густое чёрное вещество."

/datum/chemical_reaction/phenol
	name = "Фенол" // phenol
	id = "phenol"
	result = "phenol"
	required_reagents = list("water" = 1, "chlorine" = 1, "oil" = 1)
	result_amount = 3
	mix_message = "Смесь пузырится и пахнет лекарствами."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/colorful_reagent
	name = "Цветастый реагент" // colorful_reagent
	id = "colorful_reagent"
	result = "colorful_reagent"
	required_reagents = list("plasma" = 1, "radium" = 1, "space_drugs" = 1, "cryoxadone" = 1, "triple_citrus" = 1, "stabilizing_agent" = 1)
	result_amount = 6
	mix_message = "Вещество вспыхивает разными цветами и пахнет карманным протектором."

/datum/chemical_reaction/corgium
	name = "Коргий" // corgium
	id = "corgium"
	result = null
	required_reagents = list("nutriment" = 1, "colorful_reagent" = 1, "strange_reagent" = 1, "blood" = 1)
	result_amount = 3
	min_temp = T0C + 100

/datum/chemical_reaction/corgium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/pet/dog/corgi(location)
	..()

/datum/chemical_reaction/flaptonium
	name = "Махтоний" // Flaptonium
	id = "flaptonium"
	result = null
	required_reagents = list("egg" = 1, "colorful_reagent" = 1, "chicken_soup" = 1, "strange_reagent" = 1, "blood" = 1)
	result_amount = 5
	min_temp = T0C + 100
	mix_message = "Вещество становится воздушно-голубым и пенится, принимая новую форму."

/datum/chemical_reaction/flaptonium/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /mob/living/simple_animal/parrot(location)
	..()

/datum/chemical_reaction/hair_dye
	name = "Краска для волос" // hair_dye
	id = "hair_dye"
	result = "hair_dye"
	required_reagents = list("colorful_reagent" = 1, "hairgrownium" = 1)
	result_amount = 2

/datum/chemical_reaction/hairgrownium
	name = "Власорост" // hairgrownium
	id = "hairgrownium"
	result = "hairgrownium"
	required_reagents = list("carpet" = 1, "synthflesh" = 1, "ephedrine" = 1)
	result_amount = 3
	mix_message = "Жидкость становится слегка волосатой."

/datum/chemical_reaction/super_hairgrownium
	name = "Супервласорост" // Super Hairgrownium
	id = "super_hairgrownium"
	result = "super_hairgrownium"
	required_reagents = list("iron" = 1, "methamphetamine" = 1, "hairgrownium" = 1)
	result_amount = 3
	mix_message = "Жидкость становится невероятно пушистой и специфически пахнет."

/datum/chemical_reaction/soapification
	name = "Мылофикация" // Soapification
	id = "soapification"
	result = null
	required_reagents = list("liquidgibs" = 10, "lye"  = 10) // requires two scooped gib tiles
	min_temp = T0C + 100
	result_amount = 1


/datum/chemical_reaction/soapification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/soap/homemade(location)

/datum/chemical_reaction/candlefication
	name = "Свечефикация" // Candlefication
	id = "candlefication"
	result = null
	required_reagents = list("liquidgibs" = 5, "oxygen"  = 5) //
	min_temp = T0C + 100
	result_amount = 1

/datum/chemical_reaction/candlefication/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/candle(location)

/datum/chemical_reaction/meatification
	name = "Мясофикация" // Meatification
	id = "meatification"
	result = null
	required_reagents = list("liquidgibs" = 10, "nutriment" = 10, "carbon" = 10)
	result_amount = 1

/datum/chemical_reaction/meatification/on_reaction(datum/reagents/holder, created_volume)
	var/location = get_turf(holder.my_atom)
	new /obj/item/reagent_containers/food/snacks/meat/slab/meatproduct(location)

/datum/chemical_reaction/lye
	name = "Щелочь" // lye
	id = "lye"
	result = "lye"
	required_reagents = list("sodium" = 1, "hydrogen" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/love
	name = "Чистая любовь" // pure love
	id = "love"
	result = "love"
	required_reagents = list("hugs" = 1, "chocolate" = 1)
	result_amount = 2
	mix_message = "Вещество источает привлекательный аромат!"

/datum/chemical_reaction/jestosterone
	name = "Шутостерон" // Jestosterone
	id = "jestosterone"
	result = "jestosterone"
	required_reagents = list("blood" = 1, "sodiumchloride" = 1, "banana" = 1, "lube" = 1, "space_drugs" = 1) //Or one freshly-squeezed clown
	min_temp = T0C + 100
	result_amount = 5
	mix_message = "Вещество быстро меняет цвет, переходя от красного к жёлтому, зелёному, синему, и, наконец, доходит до восхитительной фуксии."

/datum/chemical_reaction/jestosterone/on_reaction(datum/reagents/holder, created_volume)
	playsound(get_turf(holder.my_atom), 'sound/items/bikehorn.ogg', 50, 1)

/datum/chemical_reaction/royal_bee_jelly
	name = "Маточное молочко" // royal bee jelly
	id = "royal_bee_jelly"
	result = "royal_bee_jelly"
	required_reagents = list("mutagen" = 10, "honey" = 40)
	result_amount = 5

/datum/chemical_reaction/glycerol
	name = "Глицерин" // Glycerol
	id = "glycerol"
	result = "glycerol"
	required_reagents = list("cornoil" = 3, "sacid" = 1)
	result_amount = 1

/datum/chemical_reaction/condensedcapsaicin
	name = "Сгущённый капсаицин" // Condensed Capsaicin
	id = "condensedcapsaicin"
	result = "condensedcapsaicin"
	required_reagents = list("capsaicin" = 2)
	required_catalysts = list("plasma" = 5)
	result_amount = 1

/datum/chemical_reaction/sodiumchloride
	name = "Хлорид натрия" // Sodium Chloride
	id = "sodiumchloride"
	result = "sodiumchloride"
	required_reagents = list("sodium" = 1, "chlorine" = 1, "water" = 1)
	result_amount = 3
	mix_message = "Вещество кристаллизуется с короткой вспышкой света."

/datum/chemical_reaction/acetaldehyde
	name = "Ацетальдегид" // Acetaldehyde
	id = "acetaldehyde"
	result = "acetaldehyde"
	required_reagents = list("chromium" = 1, "oxygen" = 1, "copper" = 1, "ethanol" = 1)
	result_amount = 3
	min_temp = T0C + 275
	mix_message = "Это пахнет тяжёлым похмельем."

/datum/chemical_reaction/acetic_acid
	name = "Уксусная кислота" // Acetic Acid
	id = "acetic_acid"
	result = "acetic_acid"
	required_reagents = list("acetaldehyde" = 1, "oxygen" = 1, "nitrogen" = 4)
	result_amount = 3
	mix_message = "Это пахнет уксусом и тяжёлым похмельем."

/datum/chemical_reaction/ice
	name = "Лёд" // Ice
	id = "ice"
	result = "ice"
	required_reagents = list("water" = 1)
	result_amount = 1
	max_temp = T0C
	mix_message = "Замерзая, вода превращается в лёд."
	mix_sound = null

/datum/chemical_reaction/water
	name = "Вода" // Water
	id = "water"
	result = "water"
	required_reagents = list("ice" = 1)
	result_amount = 1
	min_temp = T0C + 29 // In Space.....ice melts at 82F...don't ask
	mix_message = "Лёд тает, образуя воду."
	mix_sound = null

/datum/chemical_reaction/virus_food
	name = "Питательная среда" // Virus Food
	id = "virusfood"
	result = "virusfood"
	required_reagents = list("water" = 1, "milk" = 1, "oxygen" = 1)
	result_amount = 3

/datum/chemical_reaction/virus_food_mutagen
	name = "Мутагенный агар" // mutagenic agar
	id = "mutagenvirusfood"
	result = "mutagenvirusfood"
	required_reagents = list("mutagen" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_diphenhydramine
	name = "Вирусные пайки" // virus rations
	id = "diphenhydraminevirusfood"
	result = "diphenhydraminevirusfood"
	required_reagents = list("diphenhydramine" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_plasma
	name = "Плазма вируса" // virus plasma
	id = "plasmavirusfood"
	result = "plasmavirusfood"
	required_reagents = list("plasma_dust" = 1, "virusfood" = 1)
	result_amount = 1

/datum/chemical_reaction/virus_food_plasma_diphenhydramine
	name = "Ослабленная плазма вируса" // weakened virus plasma
	id = "weakplasmavirusfood"
	result = "weakplasmavirusfood"
	required_reagents = list("diphenhydramine" = 1, "plasmavirusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_mutagen_sugar
	name = "Сахарозный агар" // sucrose agar
	id = "sugarvirusfood"
	result = "sugarvirusfood"
	required_reagents = list("sugar" = 1, "mutagenvirusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/virus_food_mutagen_salineglucose
	name = "Сахарозный агар" // sucrose agar
	id = "salineglucosevirusfood"
	result = "sugarvirusfood"
	required_reagents = list("salglu_solution" = 1, "mutagenvirusfood" = 1)
	result_amount = 2

/datum/chemical_reaction/mix_virus
	name = "Вирусная смесь" // "Mix Virus
	id = "mixvirus"
	required_reagents = list("virusfood" = 1)
	required_catalysts = list("blood" = 1)
	var/level_min = 0
	var/level_max = 2

/datum/chemical_reaction/mix_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Evolve(level_min, level_max)


/datum/chemical_reaction/mix_virus/mix_virus_2
	name = "Вирусная смесь №2" // Mix Virus 2
	id = "mixvirus2"
	required_reagents = list("mutagen" = 1)
	level_min = 2
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_3
	name = "Вирусная смесь №3" // Mix Virus 3
	id = "mixvirus3"
	required_reagents = list("plasma_dust" = 1)
	level_min = 4
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_4
	name = "Вирусная смесь №4" // Mix Virus 4
	id = "mixvirus4"
	required_reagents = list("uranium" = 1)
	level_min = 5
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_5
	name = "Вирусная смесь №5" // Mix Virus 5
	id = "mixvirus5"
	required_reagents = list("mutagenvirusfood" = 1)
	level_min = 3
	level_max = 3

/datum/chemical_reaction/mix_virus/mix_virus_6
	name = "Вирусная смесь №6" // Mix Virus 6
	id = "mixvirus6"
	required_reagents = list("sugarvirusfood" = 1)
	level_min = 4
	level_max = 4

/datum/chemical_reaction/mix_virus/mix_virus_7
	name = "Вирусная смесь №7" // Mix Virus 7
	id = "mixvirus7"
	required_reagents = list("weakplasmavirusfood" = 1)
	level_min = 5
	level_max = 5

/datum/chemical_reaction/mix_virus/mix_virus_8
	name = "Вирусная смесь №8" // Mix Virus 8
	id = "mixvirus8"
	required_reagents = list("plasmavirusfood" = 1)
	level_min = 6
	level_max = 6

/datum/chemical_reaction/mix_virus/mix_virus_9
	name = "Вирусная смесь №9" // Mix Virus 9
	id = "mixvirus9"
	required_reagents = list("diphenhydraminevirusfood" = 1)
	level_min = 1
	level_max = 1

/datum/chemical_reaction/mix_virus/rem_virus
	name = "Devolve Virus"
	id = "remvirus"
	required_reagents = list("diphenhydramine" = 1)
	required_catalysts = list("blood" = 1)

/datum/chemical_reaction/mix_virus/rem_virus/on_reaction(datum/reagents/holder, created_volume)
	var/datum/reagent/blood/B = locate(/datum/reagent/blood) in holder.reagent_list
	if(B && B.data)
		var/datum/disease/advance/D = locate(/datum/disease/advance) in B.data["viruses"]
		if(D)
			D.Devolve()
