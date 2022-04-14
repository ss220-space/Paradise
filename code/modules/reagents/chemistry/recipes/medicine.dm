/datum/chemical_reaction/hydrocodone
	name = "Гидрокон"
	id = "hydrocodone"
	result = "hydrocodone"
	required_reagents = list("morphine" = 1, "sacid" = 1, "water" = 1, "oil" = 1)
	result_amount = 2

/datum/chemical_reaction/mitocholide
	name = "Митоколид" // mitocholide
	id = "mitocholide"
	result = "mitocholide"
	required_reagents = list("synthflesh" = 1, "cryoxadone" = 1, "plasma" = 1)
	result_amount = 3

/datum/chemical_reaction/cryoxadone
	name = "Криоксадон"
	id = "cryoxadone"
	result = "cryoxadone"
	required_reagents = list("cryostylane" = 1, "plasma" = 1, "acetone" = 1, "mutagen" = 1)
	result_amount = 4
	mix_message = "Смесь тихо побулькивает."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/spaceacillin
	name = "Космоцилин"
	id = "spaceacillin"
	result = "spaceacillin"
	required_reagents = list("fungus" = 1, "ethanol" = 1)
	result_amount = 2
	mix_message = "Спирт извлекает антибиотик из грибка."

/datum/chemical_reaction/rezadone
	name = "Резадон" // Rezadone
	id = "rezadone"
	result = "rezadone"
	required_reagents = list("carpotoxin" = 1, "spaceacillin" = 1, "copper" = 1)
	result_amount = 3

/datum/chemical_reaction/sterilizine
	name = "Стерилизин" // Sterilizine
	id = "sterilizine"
	result = "sterilizine"
	required_reagents = list("antihol" = 2, "chlorine" = 1)
	result_amount = 3

/datum/chemical_reaction/charcoal
	name = "Активированный уголь" // Charcoal
	id = "charcoal"
	result = "charcoal"
	required_reagents = list("ash" = 1, "sodiumchloride" = 1)
	result_amount = 2
	mix_message = "Смешивание образует мелкий чёрный порошок."
	min_temp = T0C + 100
	mix_sound = 'sound/goonstation/misc/fuse.ogg'

/datum/chemical_reaction/silver_sulfadiazine
	name = "Сульфадиазин серебра" // Silver Sulfadiazine
	id = "silver_sulfadiazine"
	result = "silver_sulfadiazine"
	required_reagents = list("ammonia" = 1, "silver" = 1, "sulfur" = 1, "oxygen" = 1, "chlorine" = 1)
	result_amount = 5
	mix_message = "Смесь пузырится и от неё идёт сильный приторный запах."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/salglu_solution
	name = "Физраствор с глюкозой" // Saline-Glucose Solution
	id = "salglu_solution"
	result = "salglu_solution"
	required_reagents = list("sodiumchloride" = 1, "water" = 1, "sugar" = 1)
	result_amount = 3

/datum/chemical_reaction/heparin
	name = "Гепарин" // Heparin
	id = "Heparin"
	result = "heparin"
	required_reagents = list("sugar" = 1, "meatslurry" = 1, "phenol" = 1, "sacid" = 1)
	result_amount = 2

/datum/chemical_reaction/synthflesh
	name = "Синтплоть" // Synthflesh
	id = "synthflesh"
	result = "synthflesh"
	required_reagents = list("blood" = 1, "carbon" = 1, "styptic_powder" = 1)
	result_amount = 3
	mix_message = "Смесь слипается в волокнистую кровавую массу."
	mix_sound = 'sound/effects/blobattack.ogg'

/datum/chemical_reaction/styptic_powder
	name = "Кровоостанавливающая пудра" // Styptic Powder
	id = "styptic_powder"
	result = "styptic_powder"
	required_reagents = list("aluminum" = 1, "hydrogen" = 1, "oxygen" = 1, "sacid" = 1)
	result_amount = 4
	mix_message = "Смесь образует белый порошок."

/datum/chemical_reaction/calomel
	name = "Каломель" // Calomel
	id = "calomel"
	result = "calomel"
	required_reagents = list("mercury" = 1, "chlorine" = 1)
	result_amount = 2
	min_temp = T0C + 100
	mix_message = "От раствора поднимаются едкие пары."

/datum/chemical_reaction/potass_iodide
	name = "Йодид калия" // Potassium Iodide
	id = "potass_iodide"
	result = "potass_iodide"
	required_reagents = list("potassium" = 1, "iodine" = 1)
	result_amount = 2
	mix_message = "Раствор медленно оседает, испуская тонкие струйки пара."

/datum/chemical_reaction/pen_acid
	name = "Пентетиновая кислота" // Pentetic Acid
	id = "pen_acid"
	result = "pen_acid"
	required_reagents = list("fuel" = 1, "chlorine" = 1, "ammonia" = 1, "formaldehyde" = 1, "sodium" = 1, "cyanide" = 1)
	result_amount = 6
	mix_message = "Бурлящая смесь успокаивается, испуская занятную дымку."

/datum/chemical_reaction/sal_acid
	name = "Салициловая кислота" // Salicyclic Acid
	id = "sal_acid"
	result = "sal_acid"
	required_reagents = list("sodium" = 1, "phenol" = 1, "carbon" = 1, "oxygen" = 1, "sacid" = 1)
	result_amount = 5
	mix_message = "Смесь образует кристаллы."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/salbutamol
	name = "Сальбутамол" // Salbutamol
	id = "salbutamol"
	result = "salbutamol"
	required_reagents = list("sal_acid" = 1, "lithium" = 1, "aluminum" = 1, "bromine" = 1, "ammonia" = 1)
	result_amount = 5
	mix_message = "Смесь пузырится, образуя шапку голубоватой пены."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/perfluorodecalin
	name = "Перфтордекалин" // Perfluorodecalin
	id = "perfluorodecalin"
	result = "perfluorodecalin"
	required_reagents = list("hydrogen" = 1, "fluorine" = 1, "oil" = 1)
	result_amount = 3
	min_temp = T0C + 100
	mix_message = "Смесь быстро превращается в густую розовую жидкость."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/ephedrine
	name = "Эфедрин" // Ephedrine
	id = "ephedrine"
	result = "ephedrine"
	required_reagents = list("sugar" = 1, "oil" = 1, "hydrogen" = 1, "diethylamine" = 1)
	result_amount = 4
	mix_message = "Смесь шипит и испускает ядовитые пары."

/datum/chemical_reaction/diphenhydramine
	name = "Дифенгидрамин" // Diphenhydramine
	id = "diphenhydramine"
	result = "diphenhydramine"
	required_reagents = list("oil" = 1, "carbon" = 1, "bromine" = 1, "diethylamine" = 1, "ethanol" = 1)
	result_amount = 4
	mix_message = "Смесь мягко шипит."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/oculine
	name = "Окулин" // Oculine
	id = "oculine"
	result = "oculine"
	required_reagents = list("atropine" = 1, "spaceacillin" = 1, "salglu_solution" = 1)
	result_amount = 3
	mix_message = "Смесь оседает, становясь молочно-белой."

/datum/chemical_reaction/atropine
	name = "Атропин" // Atropine
	id = "atropine"
	result = "atropine"
	required_reagents = list("ethanol" = 1, "acetone" = 1, "diethylamine" = 1, "phenol" = 1, "sacid" = 1)
	result_amount = 5
	mix_message = "От смеси исходит ужасный запах, как будто в ней кто-то умер."

/datum/chemical_reaction/epinephrine
	name = "Эпинефрин" // Epinephrine
	id = "epinephrine"
	result = "epinephrine"
	required_reagents = list("phenol" = 1, "acetone" = 1, "diethylamine" = 1, "oxygen" = 1, "chlorine" = 1, "hydrogen" = 1)
	result_amount = 6
	mix_message = "Смесь оседает мельчайшими белыми кристаллами."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/strange_reagent
	name = "Странный реагент" // Strange Reagent
	id = "strange_reagent"
	result = "strange_reagent"
	required_reagents = list("omnizine" = 1, "holywater" = 1, "mutagen" = 1)
	result_amount = 3
	mix_message = "Вещество каким-то образом начинает двигаться само по себе."

/datum/chemical_reaction/life
	name = "Жизнь" // Life
	id = "life"
	result = null
	required_reagents = list("strange_reagent" = 1, "synthflesh" = 1, "blood" = 1)
	result_amount = 1
	min_temp = T0C + 100

// Life (hostile)
/datum/chemical_reaction/life/on_reaction(datum/reagents/holder, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Жизнь (враждебная)") //defaults to HOSTILE_SPAWN

/datum/chemical_reaction/life/friendly
	name = "Жизнь (дружелюбная)" // Life (Friendly)
	id = "life_friendly"
	required_reagents = list("strange_reagent" = 1, "synthflesh" = 1, "sugar" = 1)

/datum/chemical_reaction/life/friendly/on_reaction(datum/reagents/holder, created_volume)
	chemical_mob_spawn(holder, rand(1, round(created_volume, 1)), "Жизнь (дружелюбная)", FRIENDLY_SPAWN)

/datum/chemical_reaction/mannitol
	name = "Маннитол" // Mannitol
	id = "mannitol"
	result = "mannitol"
	required_reagents = list("sugar" = 1, "hydrogen" = 1, "water" = 1)
	result_amount = 3
	mix_message = "Смесь медленно пузырится, испуская слегка сладковатый запах."

/datum/chemical_reaction/mutadone
	name = "Мутадон" // Mutadone
	id = "mutadone"
	result = "mutadone"
	required_reagents = list("mutagen" = 1, "acetone" = 1, "bromine" = 1)
	result_amount = 3
	mix_message = "В результате реакции образуемся неприятная густая жидкость."

/datum/chemical_reaction/antihol
	name = "Антиголь" // antihol
	id = "antihol"
	result = "antihol"
	required_reagents = list("ethanol" = 1, "charcoal" = 1)
	result_amount = 2
	mix_message = "Шипящая свесь источает мятный освежающий запах."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/teporone
	name = "Тепорон" // Teporone
	id = "teporone"
	result = "teporone"
	required_reagents = list("acetone" = 1, "silicon" = 1, "plasma" = 1)
	result_amount = 2
	mix_message = "Смесь приобретает странный лавандовый цвет."
	mix_sound = 'sound/goonstation/misc/drinkfizz.ogg'

/datum/chemical_reaction/haloperidol
	name = "Галоперидол" // Haloperidol
	id = "haloperidol"
	result = "haloperidol"
	required_reagents = list("chlorine" = 1, "fluorine" = 1, "aluminum" = 1, "potass_iodide" = 1, "oil" = 1)
	result_amount = 4
	mix_message = "Химикаты смешиваются в странную розовую жижу."

/datum/chemical_reaction/ether
	name = "Эфир" // Ether
	id = "ether"
	result = "ether"
	required_reagents = list("sacid" = 1, "ethanol" = 1, "oxygen" = 1)
	result_amount = 1
	mix_message = "Смесь издаёт едкий запах, навевающий сонливость…"

/datum/chemical_reaction/degreaser
	name = "Обезжириватель" // Degreaser
	id = "degreaser"
	result = "degreaser"
	required_reagents = list("oil" = 1, "sterilizine" = 1)
	result_amount = 2

/datum/chemical_reaction/liquid_solder
	name = "Жидкий припой" // Liquid Solder
	id = "liquid_solder"
	result = "liquid_solder"
	required_reagents = list("ethanol" = 1, "copper" = 1, "silver" = 1)
	result_amount = 3
	min_temp = T0C + 100
	mix_message = "Металлически поблескивающая смесь мягко булькает."
