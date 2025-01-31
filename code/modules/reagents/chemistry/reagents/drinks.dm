/datum/reagent/consumable/drink/orangejuice
	name = "Апельсиновый сок"
	id = "orangejuice"
	description = "И вкусно, и богато витамином С - что ещё нужно?"
	color = "#E78108" // rgb: 231, 129, 8
	drink_icon = "glass_orange"
	drink_name = "стакан апельсинового сока"
	drink_desc = "Витамины! Круто!"
	taste_description = "апельсиного сока"

/datum/reagent/consumable/drink/orangejuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(30))
		update_flags |= M.adjustOxyLoss(-0.5, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/tomatojuice
	name = "Томатный сок"
	id = "tomatojuice"
	description = "Почему томатный, а не помидорный сок?"
	color = "#731008" // rgb: 115, 16, 8
	drink_icon = "glass_red"
	drink_name = "стакан томатного сока"
	drink_desc = "Это точно томатный сок?"
	taste_description = "томатного сока"

/datum/reagent/consumable/drink/pineapplejuice
	name = "Ананасовый сок"
	id = "pineapplejuice"
	description = "Ананасы, выжатые до жидкого состояния. Сладко и приторно."
	color = "#e5b437"
	drink_icon = "glass_orange"
	drink_name = "стакан ананасового сока"
	drink_desc = "Яркий напиток, сладкий и приторный."
	taste_description = "ананасового сока"

/datum/reagent/consumable/drink/tomatojuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/limejuice
	name = "Лаймовый сок"
	id = "limejuice"
	description = "Кисло-сладкий сок лайма."
	color = "#365E30" // rgb: 54, 94, 48
	drink_icon = "glass_green"
	drink_name = "стакан лаймового сока"
	drink_desc = "Стакан кисло-сладкого сока лайма."
	taste_description = "лаймового сока"

/datum/reagent/consumable/drink/limejuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/carrotjuice
	name = "Морковный сок"
	id = "carrotjuice"
	description = "Это как морковь, только без хруста. Полезно для глаз!"
	color = "#973800" // rgb: 151, 56, 0
	drink_icon = "carrotjuice"
	drink_name = "стакан морковного сока"
	drink_desc = "Это как морковь, только без хруста. Полезно для глаз!"
	taste_description = "морковного сока"

/datum/reagent/consumable/drink/carrotjuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustEyeBlurry(-2 SECONDS)
	M.AdjustEyeBlind(-2 SECONDS)
	switch(current_cycle)
		if(1 to 20)
			//nothing
		if(21 to INFINITY)
			if(prob(current_cycle-10))
				update_flags |= M.CureNearsighted(FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/doctor_delight
	name = "Радость Доктора"
	id = "doctorsdelight"
	description = "Полезная смесь соков, которая поможет вам восстановиться перед следующей зарубой на тулбоксах."
	reagent_state = LIQUID
	color = "#FF8CFF" // rgb: 255, 140, 255
	drink_icon = "doctorsdelightglass"
	drink_name = "стакан Радости Доктора"
	drink_desc = "Полезная смесь соков, которая поможет вам восстановиться перед следующей зарубой на тулбоксах."
	taste_description = "здорового питания"

/datum/reagent/consumable/drink/doctor_delight/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/triple_citrus
	name = "Тройной Цитрус"
	id = "triple_citrus"
	description = "Освежающий микс из сока различных цитрусовых. Замечательно."
	reagent_state = LIQUID
	color = "#23A046"
	drink_icon = "triplecitrus"
	drink_name = "стакан Тройного Цитруса"
	drink_desc = "Освежающий микс из сока различных цитрусовых. Замечательно."
	taste_description = "сока цитрусовых"

/datum/reagent/consumable/drink/triple_citrus/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		M.adjustToxLoss(-rand(1,2))

/datum/reagent/consumable/drink/berryjuice
	name = "Ягодный сок"
	id = "berryjuice"
	description = "Вкусная смесь из нескольких видов ягод."
	color = "#863333" // rgb: 134, 51, 51
	drink_icon = "berryjuice"
	drink_name = "стакан ягодного сока"
	drink_desc = "Вкусная смесь из нескольких видов ягод."
	taste_description = "ягодного сока"

/datum/reagent/consumable/drink/poisonberryjuice
	name = "Сок из ядовитых ягод"
	id = "poisonberryjuice"
	description = "Вкусная смесь из нескольких видов ядовитых и опасных ягод."
	color = "#863353" // rgb: 134, 51, 83
	drink_icon = "poisonberryjuice"
	drink_name = "стакан ягодного сока"
	drink_desc = "Вкусная смесь из нескольких видов ягод."
	taste_description = "ягодного сока"

/datum/reagent/consumable/drink/poisonberryjuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/applejuice
	name = "Яблочный сок"
	id = "applejuice"
	description = "Сладкой сок, полученный из выжатых яблок. Подходит для всех возрастов."
	color = "#ECFF56" // rgb: 236, 255, 86
	taste_description = "яблочного сока"

/datum/reagent/consumable/drink/watermelonjuice
	name = "Арбузный сок"
	id = "watermelonjuice"
	description = "Вкусный сок из арбуза."
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "арбузного сока"

/datum/reagent/consumable/drink/lemonjuice
	name = "Лимонный сок"
	id = "lemonjuice"
	description = "Этот сок ОЧЕНЬ кислый."
	color = "#863333" // rgb: 175, 175, 0
	drink_icon = "lemonglass"
	drink_name = "стакан лимонного сока"
	drink_desc = "От одного только взгляда на это сводит скулы."
	taste_description = "лимонного сока"

/datum/reagent/consumable/drink/grapejuice
	name = "Виноградный сок"
	id = "grapejuice"
	description = "Не запачкайте рубашку."
	color = "#993399" // rgb: 153, 51, 153
	taste_description = "виноградного сока"

/datum/reagent/consumable/drink/banana
	name = "Банановый сок"
	id = "banana"
	description = "Сырая сущность банана."
	color = "#863333" // rgb: 175, 175, 0
	drink_icon = "banana"
	drink_name = "стакан бананового сока"
	drink_desc = "Сырая сущность банана. Хонк!"
	taste_description = "бананового сока"

/datum/reagent/consumable/drink/banana/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(HAS_TRAIT(M, TRAIT_COMIC) || is_monkeybasic(M))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/nothing
	name = "Ничего"
	id = "nothing"
	description = "Абсолютно ничего."
	drink_icon = "nothing"
	drink_name = "стакан ничего"
	drink_desc = "Абсолютно ничего."
	taste_description = "ничего"

/datum/reagent/consumable/drink/nothing/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && M.mind && M.mind.miming)
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/potato_juice
	name = "Картофельный сок"
	id = "potato"
	description = "Сок картофеля. Ух."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	drink_icon = "glass_brown"
	drink_name = "стакан картофельного сока"
	drink_desc = "Кто вообще такое пьёт? Ух..."
	taste_description = "рвоты или ещё чего похуже"

/datum/reagent/consumable/drink/milk
	name = "Молоко"
	id = "milk"
	description = "Непрозрачная белая жидкость, вырабатываемая молочными железами млекопитающих."
	color = "#DFDFDF" // rgb: 223, 223, 223
	drink_icon = "glass_white"
	drink_name = "стакан молока"
	drink_desc = "Белая и питательная вкуснятина!"
	taste_description = "молока"

/datum/reagent/consumable/drink/milk/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 2)
	return ..() | update_flags

/datum/reagent/consumable/drink/milk/soymilk
	name = "Соевое молоко"
	id = "soymilk"
	description = "Непрозрачная белая жидкость, изготовленная из соевых бобов."
	color = "#DFDFC7" // rgb: 223, 223, 199
	drink_name = "стакан соевого молока"
	drink_desc = "Белая и питательная соевая вкуснятина!"
	taste_description = "фальшивого молока"

/datum/reagent/consumable/drink/milk/cream
	name = "Сливки"
	id = "cream"
	description = "Жирная, но всё ещё жидкая часть молока. Почему бы вам не смешать это с виски, а?"
	color = "#DFD7AF" // rgb: 223, 215, 175
	drink_name = "стакан сливок"
	drink_desc = "Ууу..."
	taste_description = "сливок"

/datum/reagent/consumable/drink/milk/chocolate_milk
	name = "Шоколадное молоко"
	id ="chocolate_milk"
	description = "Молоко с шоколадом. Прямо как в детстве."
	color = "#85432C"
	drink_name = "стакан шоколадного молока"
	taste_description = "шоколадного сока"

/datum/reagent/consumable/drink/hot_coco
	name = "Горячий шоколад"
	id = "hot_coco"
	description = "Сделано с любовью! И какао-бобами."
	color = "#403010" // rgb: 64, 48, 16
	adj_temp_hot = 5
	drink_icon = "hot_coco"
	drink_name = "стакан горячего шоколада"
	drink_desc = "Вкусный и тёплый."
	taste_description = "горячего шоколада"

/datum/reagent/consumable/drink/coffee
	name = "Кофе"
	id = "coffee"
	description = "Кофе - это напиток, приготовленный из обжаренных семян кофейного растения, которые обычно называют какао-бобами."
	color = "#482000" // rgb: 72, 32, 0
	nutriment_factor = 0
	adj_dizzy = -10 SECONDS
	adj_drowsy = -6 SECONDS
	adj_sleepy = -4 SECONDS
	adj_temp_hot = 25
	overdose_threshold = 45
	addiction_chance = 1 // It's true.
	addiction_threshold = 200
	minor_addiction = TRUE
	addict_supertype = /datum/reagent/consumable/drink/coffee
	heart_rate_increase = 1
	drink_icon = "glass_brown"
	drink_name = "стакан кофе"
	drink_desc = "Отличный способ взбодриться с утра или посадить свою сердечно-сосудистую систему. Зависит от частоты употребления."
	taste_description = "кофе"

/datum/reagent/consumable/drink/coffee/New()
	addict_supertype = /datum/reagent/consumable/drink/coffee

/datum/reagent/consumable/drink/coffee/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustStaminaLoss(-1, FALSE)
	if(holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 5)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/overdose_process(mob/living/M, severity)
	if(volume > 45)
		M.Jitter(10 SECONDS)
	return list(0, STATUS_UPDATE_NONE)

/datum/reagent/consumable/drink/coffee/icecoffee
	name = "Кофе со льдом"
	id = "icecoffee"
	description = "Кофе со льдом, освежающе-бодрящий."
	color = "#102838" // rgb: 16, 40, 56
	adj_temp_hot = 0
	adj_temp_cool = 5
	drink_icon = "icedcoffeeglass"
	drink_name = "стакан кофе со льдом"
	drink_desc = "Кофе со льдом, освежающе-бодрящий."
	taste_description = "освежающе-холодного кофе"

/datum/reagent/consumable/drink/coffee/soy_latte
	name = "Соевый латте"
	id = "soy_latte"
	description = "Вкусный и бодрящий напиток. Самое то для чтения всех этих ваших левацких книжек."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp_hot = 5
	drink_icon = "soy_latte"
	drink_name = "стакан соевого латте"
	drink_desc = "Вкусный и бодрящий напиток. Самое то для чтения всех этих ваших левацких книжек."
	taste_description = "фальшивого молочного кофе"

/datum/reagent/consumable/drink/coffee/soy_latte/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.SetSleeping(0)
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/cafe_latte
	name = "Латте"
	id = "cafe_latte"
	description = "Вкусный и бодрящий напиток. Самое то для чтения книг."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp_hot = 5
	drink_icon = "cafe_latte"
	drink_name = "стакан латте"
	drink_desc = "Вкусный и бодрящий напиток. Самое то для чтения книг."
	taste_description = "молочного кофе"

/datum/reagent/consumable/drink/coffee/cafe_latte/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.SetSleeping(0)
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/cafe_latte/cafe_mocha
	name = "Моккачино"
	id = "cafe_mocha"
	description = "Идеальное сочетание кофе, молока и шоколада."
	color = "#673629"
	drink_name = "стакан моккачино"
	drink_desc = "Идеальное сочетание кофе, молока и шоколада."
	taste_description = "шоколадного кофе"

/datum/reagent/consumable/drink/tea
	name = "Чай"
	id = "tea"
	description = "Вкусный чёрный чай. Содержит полезные антиоксиданты!"
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	adj_dizzy = -4 SECONDS
	adj_drowsy = -2 SECONDS
	adj_sleepy = -6 SECONDS
	adj_temp_hot = 20
	addiction_chance = 1
	addiction_chance_additional = 10
	addiction_threshold = 300
	minor_addiction = TRUE
	addict_supertype = /datum/reagent/consumable/drink/tea
	drink_icon = "glass_brown"
	drink_name = "стакан чая"
	drink_desc = "Стакан горячего чая. Может стоило всё таки налить в кружку с ручкой?"
	taste_description = "горячего чая"

/datum/reagent/consumable/drink/tea/New()
	addict_supertype = /datum/reagent/consumable/drink/tea

/datum/reagent/consumable/drink/tea/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/tea/icetea
	name = "Чай со льдом"
	id = "icetea"
	description = "Освежает и бодрит. Самое то в жаркий денёк."
	color = "#104038" // rgb: 16, 64, 56
	adj_temp_hot = 0
	adj_temp_cool = 5
	drink_icon = "icetea"
	drink_name = "стакан чая со льдом"
	drink_desc = "Освежает и бодрит. Самое то в жаркий денёк."
	taste_description = "холодного чая"

/datum/reagent/consumable/drink/bananahonk
	name = "Банана-Хонк"
	id = "bananahonk"
	description = "Напиток из клоунского рая."
	color = "#664300" // rgb: 102, 67, 0
	drink_icon = "bananahonkglass"
	drink_name = "Банана-Хонк"
	drink_desc = "Напиток из клоунского рая."
	taste_description = "бананов и веселья"

/datum/reagent/consumable/drink/bananahonk/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(HAS_TRAIT(src, TRAIT_COMIC) || is_monkeybasic(M))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/silencer
	name = "Глушитель"
	id = "silencer"
	description = "Напиток из мимского рая."
	color = "#664300" // rgb: 102, 67, 0
	drink_icon = "silencerglass"
	drink_name = "стакан Глушителя"
	drink_desc = "Напиток из мимского рая."
	taste_description = "тишины"

/datum/reagent/consumable/drink/silencer/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && (M.job in list(JOB_TITLE_MIME)))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/chocolatepudding
	name = "Шоколадный пудинг"
	id = "chocolatepudding"
	description = "Отличный десерт для любителей шоколада."
	color = "#800000"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "chocolatepudding"
	drink_name = "шоколадный пудинг"
	drink_desc = "Отличный десерт для любителей шоколада."
	taste_description = "шоколадной массы"

/datum/reagent/consumable/drink/vanillapudding
	name = "Ванильный пудинг"
	id = "vanillapudding"
	description = "Отличный десерт для любителей ванили."
	color = "#FAFAD2"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "vanillapudding"
	drink_name = "ванильный пудинг"
	drink_desc = "Отличный десерт для любителей ванили."
	taste_description = "ванильной массы"

/datum/reagent/consumable/drink/cherryshake
	name = "Ягодный шейк"
	id = "cherryshake"
	description = "Молочный коктейль со вкусом вишни."
	color = "#FFB6C1"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "cherryshake"
	drink_name = "ягодный шейк"
	drink_desc = "Молочный коктейль со вкусом вишни."
	taste_description = "ягодного милк-шейка"

/datum/reagent/consumable/drink/bluecherryshake
	name = "Голубой ягодный шейк"
	id = "bluecherryshake"
	description = "Экзотичный ягодный молочный коктейль."
	color = "#00F1FF"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "bluecherryshake"
	drink_name = "голубой ягодный шейк"
	drink_desc = "Экзотичный ягодный молочный коктейль."
	taste_description = "голубики"

/datum/reagent/consumable/drink/pumpkin_latte
	name = "Тыквенный латте"
	id = "pumpkin_latte"
	description = "Смесь тыквенного сока и кофе. Скорее всего, по неадекватно завышенной цене."
	color = "#F4A460"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	drink_icon = "pumpkin_latte"
	drink_name = "кружка тыквенного латте"
	drink_desc = "Смесь тыквенного сока и кофе. Скорее всего, по неадекватно завышенной цене."
	taste_description = "дорогущего кофе для леваков"

/datum/reagent/consumable/drink/gibbfloats
	name = "Всплывший Гибб"
	id = "gibbfloats"
	description = "Мороженое, смешанное с Доктором Гиббом."
	color = "#B22222"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	drink_icon= "gibbfloats"
	drink_name = "кружка Всплывшего Гибба"
	drink_desc = "Мороженое, смешанное с Доктором Гиббом."
	taste_description = "революции"

/datum/reagent/consumable/drink/pumpkinjuice
	name = "Pumpkin Juice"
	id = "pumpkinjuice"
	description = "Выжат из настоящей тыквы."
	color = "#FFA500"
	taste_description = "осени"

/datum/reagent/consumable/drink/blumpkinjuice
	name = "Нетыквенный сок"
	id = "blumpkinjuice"
	description = "Не выжат из настоящей тыквы."
	color = "#00BFFF"
	taste_description = "едкой рвоты"

/datum/reagent/consumable/drink/grape_soda
	name = "Виноградная газировка"
	id = "grapesoda"
	description = "Любим детьми и трезвенниками."
	color = "#E6CDFF"
	taste_description = "виноградной газировки"

/datum/reagent/consumable/drink/coco/icecoco
	name = "Холодный какао"
	id = "icecoco"
	description = "Горячее какао со льдом, освежающий и прохладный."
	color = "#102838" // rgb: 16, 40, 56
	adj_temp_hot = 0
	adj_temp_cool = 5
	drink_icon = "icedcoffeeglass"
	drink_name = "стакан холодного какао"
	drink_desc = "Горячее какао со льдом, освежающий и прохладный."
	taste_description = "освежающе-холодного какао"

/datum/reagent/consumable/drink/non_alcoholic_beer
	name = "Безалкогольное пиво"
	id = "noalco_beer"
	description = "Что может быть ещё более бессмысленным?"
	drink_icon = "alcohol_free_beer"
	drink_name = "Безалкогольное пиво"
	drink_desc = "Что может быть ещё более бессмысленным?"
	color = "#572c13"
	taste_description = "пива"

/datum/reagent/consumable/drink/laughsyrup
	name = "Смехо-сироп"
	description = "Сок, выжатый из смеющихся бобов. Шипучий и меняет вкус в зависимости от того, с чем его употребляют!"
	id = "laughsyrup"
	color = "#803280"
	nutriment_factor = 5 * REAGENTS_METABOLISM
	taste_mult = 2
	taste_description = "шипучей сладости"

/datum/reagent/consumable/drink/laughsyrup/on_mob_life(mob/living/M)
	if(prob(5))
		M.emote(pick("laugh", "giggle", "smile"))
	else if(prob(2))
		M.say(pick(list("Ха-ха!", "Хе-хе")))
