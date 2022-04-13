/datum/reagent/consumable/drink/orangejuice
	name = "Апельсиновый сок" // Orange juice
	id = "orangejuice"
	description = "Вкусный И богатый витамином Ц, что вам ещё надо?"
	color = "#E78108" // rgb: 231, 129, 8
	drink_icon = "glass_orange"
	drink_name = "Стакан апельсинового сока"
	drink_desc = "Витамины! Ура!"
	taste_description = "апельсинового сока"

/datum/reagent/consumable/drink/orangejuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(30))
		update_flags |= M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/tomatojuice
	name = "Томатный сок" // Tomato Juice
	id = "tomatojuice"
	description = "Сок из помидоров. Какая трата больших сочных помидоров, а?"
	color = "#731008" // rgb: 115, 16, 8
	drink_icon = "glass_red"
	drink_name = "Стакан томатного сока"
	drink_desc = "Вы уверены что это томатный сок?"
	taste_description = "томатного сока"

/datum/reagent/consumable/drink/pineapplejuice
	name = "Ананасовый сок" // Pineapple Juice
	id = "pineapplejuice"
	description = "Сок из ананасов. Сладкий и вкусный."
	color = "#e5b437"
	drink_icon = "glass_orange"
	drink_name = "Стакан ананасового сока"
	drink_desc = "Яркий, сладкий и вкусный напиток."
	taste_description = "ананасового сока"

/datum/reagent/consumable/drink/tomatojuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/limejuice
	name = "Лаймовый сок" // Lime Juice
	id = "limejuice"
	description = "Кисло-сладкий сока лаймов."
	color = "#365E30" // rgb: 54, 94, 48
	drink_icon = "glass_green"
	drink_name = "Стакан лаймового сока"
	drink_desc = "Стакан кисло-сладкого лаймового сока."
	taste_description = "лаймового сока"

/datum/reagent/consumable/drink/limejuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/carrotjuice
	name = "Морковный сок" // Carrot juice
	id = "carrotjuice"
	description = "Прямо как морковка, но не хрустит."
	color = "#973800" // rgb: 151, 56, 0
	drink_icon = "carrotjuice"
	drink_name = "Стакан морковного сока"
	drink_desc = "Прямо как морковка, но не хрустит."
	taste_description = "морковного сока"

/datum/reagent/consumable/drink/carrotjuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.AdjustEyeBlurry(-1, FALSE)
	update_flags |= M.AdjustEyeBlind(-1, FALSE)
	switch(current_cycle)
		if(1 to 20)
			//nothing
		if(21 to INFINITY)
			if(prob(current_cycle-10))
				update_flags |= M.CureNearsighted(FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/doctor_delight
	name = "Восторг врача" // The Doctor's Delight
	id = "doctorsdelight"
	description = "Один глоток в день и медботы больше не побеспокоят. Возможно, это и к лучшему."
	reagent_state = LIQUID
	color = "#FF8CFF" // rgb: 255, 140, 255
	drink_icon = "doctorsdelightglass"
	drink_name = "Восторг врача"
	drink_desc = "Здоровая смесь соков, которая гарантированно сохранит ваше здоровье до следующего отулбоксивания."
	taste_description = "здоровой диеты"

/datum/reagent/consumable/drink/doctor_delight/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/triple_citrus
	name = "Тройной цитрус" // Triple Citrus
	id = "triple_citrus"
	description = "Освежающий микс апельсинового, лимонного и лаймового соков."
	reagent_state = LIQUID
	color = "#23A046"
	drink_icon = "triplecitrus"
	drink_name = "Стакан сока трёх цитрусов"
	drink_desc = "Цветастый и настолько же здоровый, насколько вкусный."
	taste_description = "цитрусового сока"

/datum/reagent/consumable/drink/triple_citrus/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		M.adjustToxLoss(-rand(1,2))

/datum/reagent/consumable/drink/berryjuice
	name = "Ягодный сок" // Berry Juice
	id = "berryjuice"
	description = "Вкусная смесь нескольких разных видов ягод."
	color = "#863333" // rgb: 134, 51, 51
	drink_icon = "berryjuice"
	drink_name = "Стакан ягодного сока"
	drink_desc = "Ягодный сок. Или это джем? Хотя какая разница?"
	taste_description = "ягодного сока"

/datum/reagent/consumable/drink/poisonberryjuice
	name = "Ядовитый ягодный сок" // Poison Berry Juice
	id = "poisonberryjuice"
	description = "Вкусный сок, приготовленный из различных видов крайне смертоносных и токсичных ягод."
	color = "#863353" // rgb: 134, 51, 83
	drink_icon = "poisonberryjuice"
	drink_name = "Стакан ядовитого ягодного сока"
	drink_desc = "Стакан смертоносного сока."
	taste_description = "ягодного сока"

/datum/reagent/consumable/drink/poisonberryjuice/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/applejuice
	name = "Яблочный сок" // Apple Juice
	id = "applejuice"
	description = "Сладкий яблочный сок. Для любого возраста."
	color = "#ECFF56" // rgb: 236, 255, 86
	taste_description = "яблочного сока"

/datum/reagent/consumable/drink/watermelonjuice
	name = "Арбузный сок" // Watermelon Juice
	id = "watermelonjuice"
	description = "Delicious juice made from watermelon."
	description = "Вкусный сок арбуза"
	color = "#863333" // rgb: 134, 51, 51
	taste_description = "арбузного сока"

/datum/reagent/consumable/drink/lemonjuice
	name = "Лимонный сок" // Lemon Juice
	id = "lemonjuice"
	description = "Этот сок ОЧЕНЬ кислый."
	color = "#863333" // rgb: 175, 175, 0
	drink_icon = "lemonglass"
	drink_name = "Стакан лимонного сока"
	drink_desc = "Кислятина…"
	taste_description = "лимонного сока"

/datum/reagent/consumable/drink/grapejuice
	name = "Виноградный сок" // Grape Juice
	id = "grapejuice"
	description = "This juice is known to stain shirts."
	description = "Этот сок — известный пачкатель рубашек."
	color = "#993399" // rgb: 153, 51, 153
	taste_description = "виноградного сока"

/datum/reagent/consumable/drink/banana
	name = "Банановый сок" // Banana Juice
	id = "banana"
	description = "Чистая банановая эссенция."
	color = "#863333" // rgb: 175, 175, 0
	drink_icon = "banana"
	drink_name = "Стакан бананового сока"
	drink_desc = "Чистая банановая эссенция. ХОНК!"
	taste_description = "бананового сока"

/datum/reagent/consumable/drink/banana/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if((ishuman(M) && (COMIC in M.mutations)) || issmall(M))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/nothing
	name = "Ничего" // Nothing
	id = "nothing"
	description = "Абсолютно ничего."
	drink_icon = "nothing"
	drink_name = "Ничего"
	drink_desc = "Абсолютно ничего."
	taste_description = "ничего?"

/datum/reagent/consumable/drink/nothing/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && M.mind && M.mind.miming)
		update_flags |= M.adjustBruteLoss(-1, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/potato_juice
	name = "Картофельный сок" // Potato Juice
	id = "potato"
	description = "Сок картофеля. Буэ."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	drink_icon = "glass_brown"
	drink_name = "Стакан картофельного сока"
	drink_desc = "Кто, мать вашу, попросил это сделать? Отвратительно!"
	taste_description = "блевотины, определённо"

/datum/reagent/consumable/drink/milk
	name = "Молоко" // Milk
	id = "milk"
	description = "Прозрачная белая жидкость, получаемая из молочных желёз млекопитающих."
	color = "#DFDFDF" // rgb: 223, 223, 223
	drink_icon = "glass_white"
	drink_name = "Стакан молока"
	drink_desc = "Белое питательное совершенство!"
	taste_description = "молока"

/datum/reagent/consumable/drink/milk/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 2)
	return ..() | update_flags

/datum/reagent/consumable/drink/milk/soymilk
	name = "Соевое молоко" // Soy Milk
	id = "soymilk"
	description = "Прозрачная белая жидкость, получаемая из соевых бобов."
	color = "#DFDFC7" // rgb: 223, 223, 199
	drink_name = "Стакан соевого молока"
	drink_desc = "Белое питательное соевое совершенство!"
	taste_description = "поддельного молока"

/datum/reagent/consumable/drink/milk/cream
	name = "Сливки" // Cream
	id = "cream"
	description = "Жирная, но всё ещё жидкая часть молока. Почему бы не смешать их со скотчем, а?"
	color = "#DFD7AF" // rgb: 223, 215, 175
	drink_name = "Стакан сливок"
	drink_desc = "Эм-м-м…"
	taste_description = "сливок"

/datum/reagent/consumable/drink/milk/chocolate_milk
	name = "Шоколадное молоко" // Chocolate milk
	id ="chocolate_milk"
	description = "Молоко со вкусом шоколада, со вкусом возвращения в детство."
	color = "#85432C"
	taste_description = "шоколадного молока"

/datum/reagent/consumable/drink/hot_coco
	name = "Горячий шоколад" // Hot Chocolate
	id = "hot_coco"
	description = "Сделан с любовью. И какао бобами."
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16
	adj_temp_hot = 5
	drink_icon = "hot_coco"
	drink_name = "Стакан горячего шоколада"
	drink_desc = "Вкусный и уютный"
	taste_description = "шоколада"

/datum/reagent/consumable/drink/coffee
	name = "Кофе" // Coffee
	id = "coffee"
	description = "Кофе — напиток, который варится из обжаренных семян кофейного растения, обычно называемых кофейными зёрнами."
	color = "#482000" // rgb: 72, 32, 0
	nutriment_factor = 0
	adj_dizzy = -5
	adj_drowsy = -3
	adj_sleepy = -2
	adj_temp_hot = 25
	overdose_threshold = 45
	addiction_chance = 2 // It's true.
	addiction_chance_additional = 20
	addiction_threshold = 10
	minor_addiction = TRUE
	heart_rate_increase = 1
	drink_icon = "glass_brown"
	drink_name = "Стакан кофе"
	drink_desc = "Не роняйте его, а то повсюду разлетится обжигающая жидкость и осколки стекла."
	taste_description = "кофе"

/datum/reagent/consumable/drink/coffee/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 5)
	if(prob(50))
		update_flags |= M.AdjustParalysis(-1, FALSE)
		update_flags |= M.AdjustStunned(-1, FALSE)
		update_flags |= M.AdjustWeakened(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/overdose_process(mob/living/M, severity)
	if(volume > 45)
		M.Jitter(5)
	return list(0, STATUS_UPDATE_NONE)

/datum/reagent/consumable/drink/coffee/icecoffee
	name = "Кофе со льдом" // Iced Coffee
	id = "icecoffee"
	description = "Кофе и лёд, бодрит и освежает."
	color = "#102838" // rgb: 16, 40, 56
	adj_temp_hot = 0
	adj_temp_cool = 5
	drink_icon = "icedcoffeeglass"
	drink_name = "Кофе со льдом"
	drink_desc = "Напиток, который взбодрит и освежит!"
	taste_description = "освежающе холодного кофе"

/datum/reagent/consumable/drink/coffee/soy_latte
	name = "Соевый латте" // Soy Latte
	id = "soy_latte"
	description = "Приятный и вкусный. Отлично подходит к хипстерским книжкам."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp_hot = 5
	drink_icon = "soy_latte"
	drink_name = "Соевый латте"
	drink_desc = "Напиток, который приятно освежит во время чтения."
	taste_description = "кофе с поддельным молоком"

/datum/reagent/consumable/drink/coffee/soy_latte/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.SetSleeping(0, FALSE)
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/cafe_latte
	name = "Кофе латте" // Cafe Latte
	id = "cafe_latte"
	description = "Славный, вкусный и крепкий. Отличный напиток во время чтения."
	color = "#664300" // rgb: 102, 67, 0
	adj_sleepy = 0
	adj_temp_hot = 5
	drink_icon = "cafe_latte"
	drink_name = "Кофе латте"
	drink_desc = "Славный, вкусный, крепкий и бодрящий. Отличный напиток во время чтения."
	taste_description = "молочного кофе"

/datum/reagent/consumable/drink/coffee/cafe_latte/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.SetSleeping(0, FALSE)
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/coffee/cafe_latte/cafe_mocha
	name = "Моккачино" // Cafe Mocha
	id = "cafe_mocha"
	description = "Превосходная смесь кофе, молока и шоколада."
	color = "#673629"
	drink_name = "Моккачино"
	drink_desc = "Превосходная смесь кофе, молока и шоколада."
	taste_description = "шоколадного кофе"

/datum/reagent/consumable/drink/tea
	name = "Чай" // Tea
	id = "tea"
	description = "Вкусный чёрный чай с антиоксидантами. Очень полезный!"
	color = "#101000" // rgb: 16, 16, 0
	nutriment_factor = 0
	adj_dizzy = -2
	adj_drowsy = -1
	adj_sleepy = -3
	adj_temp_hot = 20
	addiction_chance = 1
	addiction_chance_additional = 1
	addiction_threshold = 10
	minor_addiction = TRUE
	drink_icon = "glass_brown"
	drink_name = "Стакан чая"
	drink_desc = "Стакан горячего чая. Может быть, умнее было бы пить его из кружки с ручкой?"
	taste_description = "чая"

/datum/reagent/consumable/drink/tea/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(20))
		update_flags |= M.adjustToxLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/tea/icetea
	name = "Чай со льдом" // Iced Tea
	id = "icetea"
	description = "Не имеет никакого отношения к какому-либо артисту или рэперу."
	color = "#104038" // rgb: 16, 64, 56
	adj_temp_hot = 0
	adj_temp_cool = 5
	drink_icon = "icetea"
	drink_name = "Чай со льдом"
	drink_desc = "Не имеет никакого отношения к какому-либо артисту или рэперу."
	taste_description = "холодного чая"

/datum/reagent/consumable/drink/bananahonk
	name = "Банановый хонк" // Banana Honk
	id = "bananahonk"
	description = "Напиток из клоунского рая."
	color = "#664300" // rgb: 102, 67, 0
	drink_icon = "bananahonkglass"
	drink_name = "Банановый хонк"
	drink_desc = "Напиток из бананового рая."
	taste_description = "ХОНКА"

/datum/reagent/consumable/drink/bananahonk/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if((ishuman(M) && (COMIC in M.mutations)) || issmall(M))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/silencer
	name = "Глушитель" // Silencer
	id = "silencer"
	description = "Напиток из мимского рая."
	color = "#664300" // rgb: 102, 67, 0
	drink_icon = "silencerglass"
	drink_name = "Глушитель"
	drink_desc = "Напиток из мимского рая."
	taste_description = "м-м-м"

/datum/reagent/consumable/drink/silencer/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && (M.job in list("Mime")))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/drink/chocolatepudding
	name = "Шоколадный пудинг" // Chocolate Pudding
	id = "chocolatepudding"
	description = "Отличный десерт для любителей шоколада."
	color = "#800000"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "chocolatepudding"
	drink_name = "Шоколадный пудинг"
	drink_desc = "Вкуснятина."
	taste_description = "шоколада"

/datum/reagent/consumable/drink/vanillapudding
	name = "Ванильный пудинг" // Vanilla Pudding
	id = "vanillapudding"
	description = "Отличный десерт для любителей ванили."
	color = "#FAFAD2"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "vanillapudding"
	drink_name = "Ванильный пудинг"
	drink_desc = "Вкуснятина."
	taste_description = "ванили"

/datum/reagent/consumable/drink/cherryshake
	name = "Вишнёвый коктейль" // Cherry Shake
	id = "cherryshake"
	description = "Молочный коктейль со вкусом вишни."
	color = "#FFB6C1"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "cherryshake"
	drink_name = "Вишнёвый коктейль"
	drink_desc = "Молочный коктейль со вкусом вишни."
	taste_description = "вишнёвого молочного коктейля"

/datum/reagent/consumable/drink/bluecherryshake
	name = "Коктейль «Синяя вишня»" // Blue Cherry Shake
	id = "bluecherryshake"
	description = "Экзотический молочный коктейль."
	color = "#00F1FF"
	nutriment_factor = 4 * REAGENTS_METABOLISM
	drink_icon = "bluecherryshake"
	drink_name = "Коктейль «Синяя вишня»"
	drink_desc = "Экзотический синий молочный коктейль."
	taste_description = "блюз"

/datum/reagent/consumable/drink/pumpkin_latte
	name = "Тыквенный латте" // Pumpkin Latte
	id = "pumpkin_latte"
	description = "Смесь тыквенного сока c кофе."
	color = "#F4A460"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	drink_icon = "pumpkin_latte"
	drink_name = "Тыквенный латте"
	drink_desc = "Смесь тыквенного сока c кофе."
	taste_description = "переоценённых хипстерских специй"

/datum/reagent/consumable/drink/gibbfloats
	name = "Д-р Гибб с поплавком" // Gibb Floats
	id = "gibbfloats"
	description = "Ледяные сливки поверх стакана Д-ра Гибба."
	color = "#B22222"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	drink_icon= "gibbfloats"
	drink_name = "Д-р Гибб с поплавком"
	drink_desc = "Д-р Гибб с ледяными сливками сверху."
	taste_description = "революции"

/datum/reagent/consumable/drink/pumpkinjuice
	name = "Тыквенный сок" // Pumpkin Juice
	id = "pumpkinjuice"
	description = "Сок настоящей тыквы."
	color = "#FFA500"
	taste_description = "осени"

/datum/reagent/consumable/drink/blumpkinjuice
	name = "Синячный сок" // Blumpkin Juice
	id = "blumpkinjuice"
	description = "Сок настоящего синяка."
	color = "#00BFFF"
	taste_description = "едкой рвоты"

/datum/reagent/consumable/drink/grape_soda
	name = "Виноградный сок с содовой" // Grape soda
	id = "grapesoda"
	description = "Любим детьми и трезвенниками."
	color = "#E6CDFF"
	taste_description = "виноградной газировки"

/datum/reagent/consumable/drink/coco/icecoco
	name = "Какао со льдом" // Iced Cocoa
	id = "icecoco"
	description = "Горячий какао со льдом. Бодрящий и прохладный."
	color = "#102838" // rgb: 16, 40, 56
	adj_temp_hot = 0
	adj_temp_cool = 5
	drink_icon = "icedcoffeeglass"
	drink_name = "Какао со льдом"
	drink_desc = "Сладкий напиток, который взбодрит и освежит!"
	taste_description = "бодряще холодного какао"
