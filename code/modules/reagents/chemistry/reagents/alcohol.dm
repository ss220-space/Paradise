//ALCOHOL WOO
/datum/reagent/consumable/ethanol
	name = "Этанол" // Ethanol //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "Всем известный спирт, с множеством применений."
	reagent_state = LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" // rgb: 64, 64, 48
	var/dizzy_adj = 3
	var/alcohol_perc = 1 //percentage of ethanol in a beverage 0.0 - 1.0
	taste_description = "жидкого огня"

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/M)
	M.AdjustDrunk(alcohol_perc)
	M.AdjustDizzy(dizzy_adj)
	return ..()

/datum/reagent/consumable/ethanol/reaction_obj(obj/O, volume)
	if(istype(O,/obj/item/paper))
		if(istype(O,/obj/item/paper/contract/infernal))
			O.visible_message("<span class='warning'>Реагент воспламеняется при контакте с [O].</span>")
		else
			var/obj/item/paper/paperaffected = O
			paperaffected.clearpaper()
			paperaffected.visible_message("<span class='notice'>Реагент растворяет чернила с бумаги.</span>")
	if(istype(O,/obj/item/book))
		if(volume >= 5)
			var/obj/item/book/affectedbook = O
			affectedbook.dat = null
			affectedbook.visible_message("<span class='notice'>Реагент растворяет все чернила в книги.</span>")
		else
			O.visible_message("<span class='warning'>Реагента не хватило…</span>")

/datum/reagent/consumable/ethanol/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(method == REAGENT_TOUCH)
		M.adjust_fire_stacks(volume / 15)


/datum/reagent/consumable/ethanol/beer
	name = "Пиво" // Beer
	id = "beer"
	description = "Алкогольный напиток, приготовленный из солодового зерна, хмеля, дрожжей и воды."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon ="beerglass"
	drink_name = "Кружка пива"
	drink_desc = "Леденящая пинта пива"
	taste_description = "пива"

/datum/reagent/consumable/ethanol/cider
	name = "Сидр" // Cider
	id = "cider"
	description = "Алкогольный напиток, приготовленный из яблок."
	color = "#174116"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "rewriter"
	drink_name = "Сидр"
	drink_desc = "Освежающий стакан традиционного сидра"
	taste_description = "сидра"

/datum/reagent/consumable/ethanol/whiskey
	name = "Виски" // Whiskey
	id = "whiskey"
	description = "Превосходный, хорошо выдержанный односолодовый виски. Офигенно."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	alcohol_perc = 0.4
	drink_icon = "whiskeyglass"
	drink_name = "Стакан виски"
	drink_desc = "Стакан шелковисто-дымчатого виски. Очень стильный напиток."
	taste_description = "виски"

/datum/reagent/consumable/ethanol/specialwhiskey
	name = "Виски особой выдержки"
	id = "specialwhiskey"
	description = "Как только вы решили что обычный виски станции весьма неплох… Это шелковистое янтарное чудо появилось и всё испортило."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	taste_description = "стиля"

/datum/reagent/consumable/ethanol/gin
	name = "Джин" // Gin
	id = "gin"
	description = "Это джин. В космосе. На здоровье, сэр."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 3
	alcohol_perc = 0.5
	drink_icon = "ginvodkaglass"
	drink_name = "Стакан джина"
	drink_desc = "Стакан кристально чистого гриффитского джина."
	taste_description = "джина"

/datum/reagent/consumable/ethanol/absinthe
	name = "Абсент" // Absinthe
	id = "absinthe"
	description = "Остерегайтесь, чтобы Зелёная фея не пришла за вами!"
	color = "#33EE00" // rgb: lots, ??, ??
	overdose_threshold = 30
	dizzy_adj = 5
	alcohol_perc = 0.7
	drink_icon = "absinthebottle"
	drink_name = "Стакан абсента"
	drink_desc = "Зелёная фея уже идёт за вами!"
	taste_description = "жуткой боли"

//copy paste from LSD... shoot me
/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/M)
	M.AdjustHallucinate(5)
	return ..()

/datum/reagent/consumable/ethanol/absinthe/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/ethanol/hooch
	name = "Самогон" // Hooch
	id = "hooch"
	description = "Кто-то либо плохо приготовил коктейль, либо пытался сварить алкоголь. Вы правда собираете это пить?"
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 7
	alcohol_perc = 1
	drink_icon = "glass_brown2"
	drink_name = "Самогон"
	drink_desc = "Теперь вы точно достигли самого дна… Ваша печень уже собрала вещи и съехала."
	taste_description = "гарантированного увольнения"

/datum/reagent/consumable/ethanol/hooch/on_mob_life(mob/living/carbon/M)
	if(M.mind && M.mind.assigned_role == "Assistant")
		M.heal_organ_damage(1, 1)
		. = 1
	return ..() || .

/datum/reagent/consumable/ethanol/rum
	name = "Ром" // Rum
	id = "rum"
	description = "Popular with the sailors. Not very popular with everyone else."
	description = "Популярен у моряков. Не особенно популярен у всех остальных."
	color = "#664300" // rgb: 102, 67, 0
	overdose_threshold = 30
	alcohol_perc = 0.4
	dizzy_adj = 5
	drink_icon = "rumglass"
	drink_name = "Стакан рома"
	drink_desc = "Теперь вы начнёте молиться о пиратском костюме, так ведь?"
	taste_description = "рома"

/datum/reagent/consumable/ethanol/rum/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/ethanol/mojito
	name = "Мохито" // Mojito
	id = "mojito"
	description = "Если он достаточно хорош для Космокубы, то и для вас он достаточно хорош."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "mojito"
	drink_name = "Стакан мохито"
	drink_desc = "Свежий, с Космокубы."
	taste_description = "мохито"

/datum/reagent/consumable/ethanol/vodka
	name = "Водка" // Vodka
	id = "vodka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "ginvodkaglass"
	drink_name = "Стакан водки"
	drink_desc = "Стакан с водкой. Сука, блядь."
	taste_description = "водки"

/datum/reagent/consumable/ethanol/vodka/on_mob_life(mob/living/M)
	..()
	if(prob(50))
		M.radiation = max(0, M.radiation-1)

/datum/reagent/consumable/ethanol/sake
	name = "Саке" // Sake
	id = "sake"
	description = "Любимый напиток аниме."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "sake"
	drink_name = "Стакан саке"
	drink_desc = "Стакан саке."
	taste_description = "саке"

/datum/reagent/consumable/ethanol/tequila
	name = "Текилла" // Tequila
	id = "tequila"
	description = "Крепкий спирт мексиканского производства, с мягким вкусом. Хочешь выпить, хомбре?"
	color = "#A8B0B7" // rgb: 168, 176, 183
	alcohol_perc = 0.4
	drink_icon = "tequilaglass"
	drink_name = "Стакан текиллы"
	drink_desc = "Теперь всё, чего не хватает, так это странных цветных оттенков!"
	taste_description = "текиллы"

/datum/reagent/consumable/ethanol/vermouth
	name = "Вермут" // Vermouth
	id = "vermouth"
	description = "Вы вдруг чувствуете тягу к мартини…"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "vermouthglass"
	drink_name = "Стакан вермута"
	drink_desc = "Вы задаетесь вопросом, почему вы вообще это пьёте."
	taste_description = "вермута"

/datum/reagent/consumable/ethanol/wine
	name = "Вино" // Wine
	id = "wine"
	description = "Алкогольный напиток премиум-класса, приготовленный из дистиллированного виноградного сока."
	color = "#7E4043" // rgb: 126, 64, 67
	dizzy_adj = 2
	alcohol_perc = 0.2
	drink_icon = "wineglass"
	drink_name = "Стакан вина"
	drink_desc = "Очень стильно выглядящий напиток."
	taste_description = "вина"

/datum/reagent/consumable/ethanol/cognac
	name = "Коньяк" // Cognac
	id = "cognac"
	description = "Крепкий сладкий алкогольный напиток, приготовленный после многочисленных дистилляций и многолетней выдержки. Клёвый как измена."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	alcohol_perc = 0.4
	drink_icon = "cognacglass"
	drink_name = "Стакан коньяка"
	drink_desc = "Мерде, чувствуешь себя французским аристократом, просто держа его в руках."
	taste_description = "коньяка"

/datum/reagent/consumable/ethanol/suicider //otherwise known as "I want to get so smashed my liver gives out and I die from alcohol poisoning".
	name = "Суицидник" // Suicider
	id = "suicider"
	description = "Невероятно крепкий и мощный сорт сидра."
	color = "#CF3811"
	dizzy_adj = 20
	alcohol_perc = 1 //because that's a thing it's supposed to do, I guess
	drink_icon = "suicider"
	drink_name = "Суицидник"
	drink_desc = "Теперь вы точно достигли самого дна… Ваша печень уже собрала вещи и съехала."
	taste_description = "приближающейся смерти"

/datum/reagent/consumable/ethanol/ale
	name = "Эль" // Ale
	id = "ale"
	description = "Тёмный алкогольный напиток, приготовленный из ячменного солода и дрожжей."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.1
	drink_icon = "aleglass"
	drink_name = "Стакан эля"
	drink_desc = "Освежающая пинта восхитительного эля"
	taste_description = "эля"

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Локо тринадцать" // Thirteen Loko
	id = "thirteenloko"
	description = "Крепкая смесь кофеина и алкоголя."
	reagent_state = LIQUID
	color = "#102000" // rgb: 16, 32, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.3
	heart_rate_increase = 1
	drink_icon = "thirteen_loko_glass"
	drink_name = "Стакан «Локо тринадцать»"
	drink_desc = "Это стакан «Локо тринадцать». Выглядит очень качественным. Напиток, не стакан."
	taste_description = "вечеринки"

/datum/reagent/consumable/ethanol/thirteenloko/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-7)
	update_flags |= M.AdjustSleeping(-2, FALSE)
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(5)
	return ..() | update_flags


/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////

/datum/reagent/consumable/ethanol/bilk
	name = "Пивлоко" // Bilk
	id = "bilk"
	description = "Выглядит как смесь пива и молока. Отвратительно."
	reagent_state = LIQUID
	color = "#895C4C" // rgb: 137, 92, 76
	nutriment_factor = 2 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "glass_brown"
	drink_name = "Стакан пивлока"
	drink_desc = "Настой из молока и пива. Для алкоголиков, которые боятся остеопороза."
	taste_description = "пивлока"

/datum/reagent/consumable/ethanol/atomicbomb
	name = "Атомная бомба" // Atomic Bomb
	id = "atomicbomb"
	description = "Распространение ядерного оружия ещё никогда не было таким вкусным."
	reagent_state = LIQUID
	color = "#666300" // rgb: 102, 99, 0
	alcohol_perc = 0.2
	drink_icon = "atomicbombglass"
	drink_name = "Атомная бомба"
	drink_desc = "НаноТрейзен не несёт ответственности за ваши действия после употребления."
	taste_description = "долгого, болезненного горения"

/datum/reagent/consumable/ethanol/threemileisland
	name = "Шорт айленд айс ти" // THree Mile Island Iced Tea
	id = "threemileisland"
	description = "Сделан для женщин, крепок как мужчина."
	reagent_state = LIQUID
	color = "#666340" // rgb: 102, 99, 64
	alcohol_perc = 0.2
	drink_icon = "threemileislandglass"
	drink_name = "Шорт айленд айс ти"
	drink_desc = "Стакан этого напитка обязательно предотвратит расплавление."
	taste_description = "надвигающегося жара"

/datum/reagent/consumable/ethanol/goldschlager
	name = "Гольдшлагер" // Goldschlager
	id = "goldschlager"
	description = "Стопроцентный шнапс с корицей, приготовленный для пьяных старшеклассниц на весенних каникулах."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "ginvodkaglass"
	drink_name = "Стакан гольдшлагера"
	drink_desc = "Стопроцентное доказательство того, что школьницы выпьют всё, что содержит золото."
	taste_description = "глубокой пряной теплоты"

/datum/reagent/consumable/ethanol/patron
	name = "Патрон" // Patron
	id = "patron"
	description = "Текила с серебром, любимица пьяных женщин в клубах на клубной сцене."
	reagent_state = LIQUID
	color = "#585840" // rgb: 88, 88, 64
	alcohol_perc = 0.4
	drink_icon = "patronglass"
	drink_name = "Стакан патрона"
	drink_desc = "Патрон пьют в баре вместе с пьяными дамами"
	taste_description = "подарка"

/datum/reagent/consumable/ethanol/gintonic
	name = "Джин-тоник" // Gin and Tonic
	id = "gintonic"
	description = "Мягкий классический коктейль на все времена."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "gintonicglass"
	drink_name = "Джин-тоник"
	drink_desc = "Мягкий, но всё же отличный коктейль. Пейте его как истинный англичанин."
	taste_description = "горького лекарства"

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Свободная Куба" // Cuba Libre
	id = "cubalibre"
	description = "Ром смешанный с колой. Вива ля революсьён."
	reagent_state = LIQUID
	color = "#3E1B00" // rgb: 62, 27, 0
	alcohol_perc = 0.2
	drink_icon = "cubalibreglass"
	drink_name = "Свободная Куба"
	drink_desc = "Классическая смесь рома с колой."
	taste_description = "освобождения"

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Виски с колой" // Whiskey Cola
	id = "whiskeycola"
	description = "Виски, смешанное с колой. Удивительно освежающий."
	reagent_state = LIQUID
	color = "#3E1B00" // rgb: 62, 27, 0
	alcohol_perc = 0.3
	drink_icon = "whiskeycolaglass"
	drink_name = "Виски с колой"
	drink_desc = "Невинная на вид смесь колы и виски. Вкусно."
	taste_description = "виски с колой"

/datum/reagent/consumable/ethanol/martini
	name = "Классический мартини" // Classic Martini
	id = "martini"
	description = "Вермут с джином. Не точно как у агента 007, но всё равно вкусно."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "martiniglass"
	drink_name = "Классический мартини"
	drink_desc = "Чёрт, бармен даже взболтал, но не смешивал."
	taste_description = "стиля"

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Мартини с водкой" // Vodka Martini
	id = "vodkamartini"
	description = "Водка с джином. Не точно как у агента 007, но всё равно вкусно."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "martiniglass"
	drink_name = "Мартини с водкой"
	drink_desc = "Издевательство над классическим мартини. Всё равно потрясающий."
	taste_description = "стиля и картошки"

/datum/reagent/consumable/ethanol/white_russian
	name = "Белый русский" // White Russian
	id = "whiterussian"
	description = "Это всего лишь твоё мнение, чел…"
	reagent_state = LIQUID
	color = "#A68340" // rgb: 166, 131, 64
	alcohol_perc = 0.3
	drink_icon = "whiterussianglass"
	drink_name = "Белый русский"
	drink_desc = "Этот напиток отлично выглядит. Но это всего лишь твоё мнение, чел."
	taste_description = "очень сливочного алкоголя"

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Отвёртка" // Screwdriver
	id = "screwdrivercocktail"
	description = "Водка, смешанная со старым добрым апельсиновым соком. Результат удивительно вкусный."
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.3
	drink_icon = "screwdriverglass"
	drink_name = "Отвёртка"
	drink_desc = "Простая, но превосходная смесь водки и апельсинового сока. То, что нужно уставшему инженеру."
	taste_description = "грязного секрета"

/datum/reagent/consumable/ethanol/booger
	name = "Козявка" // Booger
	id = "booger"
	description = "Фу…"
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.2
	drink_icon = "booger"
	drink_name = "Козявка"
	drink_desc = "Фу…"
	taste_description = "фруктовой кашицы"

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Кровавая Мэри" // Bloody Mary
	id = "bloodymary"
	description = "Странная, но приятная смесь из водки, помидоров и сока лайма. Или, по крайней мере, вам КАЖЕТСЯ, что красное в ней — томатный сок."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "bloodymaryglass"
	drink_name = "Кровавая Мэри"
	drink_desc = "Томатный сок, смешанный с водкой и небольшим количеством лайма. На вкус как жидкое убийство."
	taste_description = "жидкого убийства"

/datum/reagent/consumable/ethanol/gargle_blaster
	name = "Пангалактический грызлодёр" // Pan-Galactic Gargle Blaster
	id = "gargleblaster"
	description = "Ого, эта штука выглядит взрывоопасно!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.7 //ouch
	drink_icon = "gargleblasterglass"
	drink_name = "Пангалактический грызлодёр"
	drink_desc = "Это… это значит что Артур и Форд на станции? Во дела."
	taste_description = "числа сорок два"

/datum/reagent/consumable/ethanol/flaming_homer
	name = "Горючий Мо" // Flaming Moe
	id = "flamingmoe"
	description = "Похоже, что это смесь различного алкоголя с рецептурными лекарствами. Слегка поджаренная…"
	reagent_state = LIQUID
	color = "#58447f" //rgb: 88, 66, 127
	alcohol_perc = 0.5
	drink_icon = "flamingmoeglass"
	drink_name = "Горючий Мо"
	drink_desc = "Счастье всего в шаге от Горючего Мо!"
	taste_description = "карамелизованной выпивки и сладко-солёных лекарств"

/datum/reagent/consumable/ethanol/brave_bull
	name = "Храбрый бык" // Brave Bull
	id = "bravebull"
	description = "Текила в аппетитной смеси с кофейным ликером. Пейте."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "bravebullglass"
	drink_name = "Храбрый бык"
	drink_desc = "Текила в аппетитной смеси с кофейным ликером. Пейте."
	taste_description = "сладкого алкоголя"

/datum/reagent/consumable/ethanol/tequila_sunrise
	name = "Текилла «Восход»" // Tequila Sunrise
	id = "tequilasunrise"
	description = "Текилла с апельсиновым соком. Прямо как отвёртка, только по-мексикански~"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "tequilasunriseglass"
	drink_name = "Текилла «Восход»"
	drink_desc = "О да, теперь у вас началась ностальгия по восходам на Терре…"
	taste_description = "fruity alcohol"

/datum/reagent/consumable/ethanol/toxins_special
	name = "Особые токсины" // Toxins Special
	id = "toxinsspecial"
	description = "Эта штука ГОРИТ! ВЫЗЫВАЙТЕ СРАНЫЙ ШАТТЛ!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "toxinsspecialglass"
	drink_name = "Особые токсины"
	drink_desc = "Вау, эта штука ГОРИТ"
	taste_description = "ОГНЯ"

/datum/reagent/consumable/ethanol/toxins_special/on_mob_life(mob/living/M)
	if(M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Удар бипски" // Beepsky Smash
	id = "beepskysmash"
	description = "Откажитесь это выпить и почувствуйте ЗАКОН."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "beepskysmashglass"
	drink_name = "Удар бипски"
	drink_desc = "Тяжелый, горячий, сильный. Прямо как железный кулак ЗАКОНА."
	taste_description = "ЗАКОНА"

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_life(mob/living/M)
	var/update_flag = STATUS_UPDATE_NONE
	update_flag |= M.Stun(1, FALSE)
	return ..() | update_flag

/datum/reagent/consumable/ethanol/irish_cream
	name = "Ирландские сливки" // Irish Cream
	id = "irishcream"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "irishcreamglass"
	drink_name = "Ирландские сливки"
	drink_desc = "Сливки, смешанные с виски. Чего ещё можно ожидать от ирландцев?"
	taste_description = "сливочного алкоголя"

/datum/reagent/consumable/ethanol/manly_dorf
	name = "Бравый карлик" // The Manly Dorf
	id = "manlydorf"
	description = "Пиво и эль, соединённые в восхитительном миксе. Только для настоящих мужиков."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "manlydorfglass"
	drink_name = "Бравый карлик"
	drink_desc = "Мужественная смесь из эля и пива. Только для настоящих мужиков."
	taste_description = "мужиковости"

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Лонг айленд айс ти" // Long Island Iced Tea
	id = "longislandicedtea"
	description = "Целый винный шкаф, собранный во вкусный микс. Предназначен только для женщин среднего возраста, страдающих алкоголизмом."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "longislandicedteaglass"
	drink_name = "Лонг айленд айс ти"
	description = "Целый винный шкаф, собранный во вкусный микс. Предназначен только для женщин среднего возраста, страдающих алкоголизмом."
	taste_description = "фруктового алкоголя"

/datum/reagent/consumable/ethanol/moonshine
	name = "Сивуха" // Moonshine
	id = "moonshine"
	drink_desc = "Теперь вы точно достигли самого дна… Ваша печень уже собрала вещи и съехала."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.8 //yeeehaw
	drink_icon = "glass_clear"
	drink_name = "Сивуха"
	drink_desc = "Теперь вы точно достигли самого дна… Ваша печень уже собрала вещи и съехала."
	taste_description = "prohibition"

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	id = "b52"
	description = "Кофе, ирландские сливки и коньяк. Вас разбомбит."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "b52glass"
	drink_name = "B-52"
	drink_desc = "Калуа, ирландские сливки и коньяк. Вас разбомбит."
	taste_description = "разрушения"

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Ирландский кофе" // Irish Coffee
	id = "irishcoffee"
	description = "Кофе с алкоголем. Веселее, чем пить мимозу по утрам."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "irishcoffeeglass"
	drink_name = "Ирландский кофе"
	drink_desc = "Кофе с алкоголем. Веселее, чем пить мимозу по утрам."
	taste_description = "кофе и выпивки"

/datum/reagent/consumable/ethanol/margarita
	name = "Маргарита" // Margarita
	id = "margarita"
	description = "В старомодном стакане с солью по краю. Арриба~!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "margaritaglass"
	drink_name = "Маргарита"
	drink_desc = "В старомодном стакане с солью по краю. Арриба~!"
	taste_description = "ромашек"

/datum/reagent/consumable/ethanol/black_russian
	name = "Чёрный русский" // Black Russian
	id = "blackrussian"
	description = "Для непереносящих лактозу. Такой же стильный, как и белый русский."
	reagent_state = LIQUID
	color = "#360000" // rgb: 54, 0, 0
	alcohol_perc = 0.4
	drink_icon = "blackrussianglass"
	drink_name = "Чёрный русский"
	drink_desc = "Для непереносящих лактозу. Такой же стильный, как и белый русский."
	taste_description = "сладкого алкоголя"

/datum/reagent/consumable/ethanol/manhattan
	name = "Манхэттен" // Manhattan
	id = "manhattan"
	description = "Любимый напиток детектива под прикрытием. Он никогда не переваривал джин…"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "manhattanglass"
	drink_name = "Манхэттен"
	drink_desc = "Любимый напиток детектива под прикрытием. Он никогда не переваривал джин…"
	taste_description = "шумного города"

/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Манхэттенский проект" // Manhattan Project
	id = "manhattan_proj"
	description = "Лучший напиток для учёного, который обдумывает, как взорвать станцию."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "proj_manhattanglass"
	drink_name = "Манхэттенский проект"
	drink_desc = "Лучший напиток для учёного, который обдумывает, как взорвать станцию."
	taste_description = "апокалипсиса"

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Виски с содовой" // Whiskey Soda
	id = "whiskeysoda"
	description = "Абсолютное освежение."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "whiskeysodaglass2"
	drink_name = "Виски с содовой"
	drink_desc = "Абсолютное освежение."
	taste_description = "посредственности"

/datum/reagent/consumable/ethanol/antifreeze
	name = "Антифриз" // Anti-freeze
	id = "antifreeze"
	description = "Абсолютное освежение."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "antifreeze"
	drink_name = "Антифриз"
	drink_desc = "Абсолютное освежение."
	taste_description = "плохих жизненных выборов"

/datum/reagent/consumable/ethanol/antifreeze/on_mob_life(mob/living/M)
	if(M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

// Непереводимая игра слов с названием вина «Barefoot» и отсылкой к американской пословице о месте женщины «Barefoot and pregnant»
// Поменял на отсылку к Мойдодыру. Так хотя бы смысл отсылки к вину «Barefoot» останется и будет связь с русскоязычной поговоркой, хоть и совсем иной.
/datum/reagent/consumable/ethanol/barefoot
	name = "Босоногий"
	id = "barefoot"
	description = "Босоногий и хромой"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "b&p"
	drink_name = "Босоногий"
	drink_desc = "Босоногий и хромой"
	taste_description = "хромоты"

/datum/reagent/consumable/ethanol/snowwhite
	name = "Белоснежка" // Snow White
	id = "snowwhite"
	description = "Холодная свежесть"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "snowwhite"
	drink_name = "Белоснежка"
	drink_desc = "Холодная свежесть."
	taste_description = "отравленного яблока"

/datum/reagent/consumable/ethanol/demonsblood
	name = "Демонова кровь" // Demons Blood
	id = "demonsblood"
	description = "АХХХ!!!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 10
	alcohol_perc = 0.4
	drink_icon = "demonsblood"
	drink_name = "Демонова кровь"
	drink_desc = "Одного взгляда на эту штуку достаточно чтобы у вас волосы на затылке встали дыбом."
	taste_description = "<span class='warning'>зла</span>"

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Водка с тоником" // Vodka and Tonic
	id = "vodkatonic"
	description = "Для случаев, когда джин с тоником — недостаточно по-русски."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	alcohol_perc = 0.3
	drink_icon = "vodkatonicglass"
	drink_name = "Водка с тоником"
	drink_desc = "Для случаев, когда джин с тоником — недостаточно по-русски."
	taste_description = "горького лекарства"

/datum/reagent/consumable/ethanol/ginfizz
	name = "Джин Физз" // Gin Fizz
	id = "ginfizz"
	description = "Освежающе лимонный, восхитительно сухой."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 4
	alcohol_perc = 0.4
	drink_icon = "ginfizzglass"
	drink_name = "Джин Физз"
	drink_desc = "Освежающе лимонный, восхитительно сухой."
	taste_description = "шипучего алкоголя"

/datum/reagent/consumable/ethanol/bahama_mama
	name = "Багама мама" // Bahama mama
	id = "bahama_mama"
	description = "Тропический коктейль."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "bahama_mama"
	drink_name = "Багама мама"
	drink_desc = "Тропический коктейль."
	taste_description = "ХОНКА"

/datum/reagent/consumable/ethanol/singulo
	name = "Сингуло" // Singulo
	id = "singulo"
	description = "Напиток блюспейса!"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	dizzy_adj = 15
	alcohol_perc = 0.7
	drink_icon = "singulo"
	drink_name = "Сингуло"
	drink_desc = "Напиток блюспейса."
	taste_description = "бесконечности"

/datum/reagent/consumable/ethanol/sbiten
	name = "Сбитень" // Sbiten
	id = "sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	description = "Пряная водка! Может быть островато для малышей!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "sbitenglass"
	drink_name = "Сбитень"
	drink_desc = "A spicy mix of Vodka and Spice. Very hot."
	drink_desc = "Пряный микс водки и пряности. Обжигающе."
	taste_description = "комфортного тепла"

/datum/reagent/consumable/ethanol/sbiten/on_mob_life(mob/living/M)
	if(M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/devilskiss
	name = "Поцелуй дьявола" // Devils Kiss
	id = "devilskiss"
	description = "Жуткий момент!"
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.3
	drink_icon = "devilskiss"
	drink_name = "Поцелуй дьявола"
	drink_desc = "Жуткий момент!"
	taste_description = "непослушания"

/datum/reagent/consumable/ethanol/red_mead
	name = "Красный мёд" // Red Mead
	id = "red_mead"
	description = "Напиток настоящего викинга! Хоть у него и странный красный цвет."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "red_meadglass"
	drink_name = "Красный мёд"
	drink_desc = "Настоящий напиток викингов, хотя цвет у него странный."
	taste_description = "крови"

/datum/reagent/consumable/ethanol/mead
	name = "Мёд" // Mead
	id = "mead"
	description = "Напиток викингов, хоть и дешёвый."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "meadglass"
	drink_name = "Мёд"
	drink_desc = "Напиток викингов, хоть и дешёвый."
	taste_description = "мёда"

/datum/reagent/consumable/ethanol/iced_beer
	name = "Ледяное пиво" // Iced Beer
	id = "iced_beer"
	description = "Пиво, холодное настолько, что замораживает воздух вокруг."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "iced_beerglass"
	drink_name = "Ледяное пиво"
	drink_desc = "Пиво, холодное настолько, что замораживает воздух вокруг."
	taste_description = "холодного пива"

/datum/reagent/consumable/ethanol/iced_beer/on_mob_life(mob/living/M)
	if(M.bodytemperature > 270)
		M.bodytemperature = max(270, M.bodytemperature - (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	return ..()

/datum/reagent/consumable/ethanol/grog
	name = "Грог" // Grog
	id = "grog"
	description = "Разбавленный ром. НаноТрейзен одобряет!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "grogglass"
	drink_name = "Грог"
	drink_desc = "Прекрасный и крепкий напиток для Космоса."
	taste_description = "сильно разбавленного рома"

/datum/reagent/consumable/ethanol/aloe
	name = "Алоэ" // Aloe
	id = "aloe"
	description = "Очень-очень-очень хорошее."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "aloe"
	drink_name = "Алоэ"
	drink_desc = "Очень-очень-очень хорошее."
	taste_description = "здоровой кожи"

/datum/reagent/consumable/ethanol/andalusia
	name = "Андалусия" // Andalusia
	id = "andalusia"
	description = "Прекрасный напиток со странным названием."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "andalusia"
	drink_name = "Андалусия"
	drink_desc = "Прекрасный напиток со странным названием."
	taste_description = "сладкого алкоголя"

/datum/reagent/consumable/ethanol/alliescocktail
	name = "Коктейль «Союзнический»" // Allies cocktail
	id = "alliescocktail"
	description = "Напиток, сделанный из ваших союзников."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "alliescocktail"
	drink_name = "Коктейль «Союзнический»"
	drink_desc = "Напиток, сделанный из ваших союзников."
	taste_description = "победы"

/datum/reagent/consumable/ethanol/acid_spit
	name = "Кислотный плевок" // Acid Spit
	id = "acidspit"
	description = "Напиток производства НаноТрейзен. Готовится из живых чужих."
	reagent_state = LIQUID
	color = "#365000" // rgb: 54, 80, 0
	alcohol_perc = 0.3
	drink_icon = "acidspitglass"
	drink_name = "Кислотный плевок"
	drink_desc = "Напиток производства НаноТрейзен. Готовится из живых чужих."
	taste_description = "БОЛИ"

/datum/reagent/consumable/ethanol/amasec
	name = "Амасек" // Amasec
	id = "amasec"
	description = "Официальный напиток Империума."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "amasecglass"
	drink_name = "Амасек"
	drink_desc = "Всегда уместен перед БИТВОЙ!!!"
	taste_description = "оглушающей дубинки"

/datum/reagent/consumable/ethanol/neurotoxin
	name = "Нейро-токсин" // Neuro-toxin
	id = "neurotoxin"
	description = "Сильный нейротоксин, вводящий субъекта в неотличимое от смерти состояние."
	reagent_state = LIQUID
	color = "#2E2E61" // rgb: 46, 46, 97
	dizzy_adj = 6
	alcohol_perc = 0.7
	heart_rate_decrease = 1
	drink_icon = "neurotoxinglass"
	drink_name = "Нейротоксин"
	drink_desc = "Напиток, который гарантированно вышибет вам мозги."
	taste_description = "повреждений мозгааыаЫЫЫАААыыаа"

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle >= 13)
		update_flags |= M.Weaken(3, FALSE)
	if(current_cycle >= 55)
		update_flags |= M.Druggy(55, FALSE)
	if(current_cycle >= 200)
		update_flags |= M.adjustToxLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/hippies_delight
	name = "Радость хиппи" // Hippie's Delight
	id = "hippiesdelight"
	description = "Да до тебя просто не дошло, чувааак."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	drink_icon = "hippiesdelightglass"
	drink_name = "Радость хиппи"
	drink_desc = "Напиток, которым люди наслаждались в 1960-х."
	taste_description = "цветов"

/datum/reagent/consumable/ethanol/hippies_delight/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.Druggy(50, FALSE)
	switch(current_cycle)
		if(1 to 5)
			M.Stuttering(1)
			M.Dizzy(10)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Stuttering(1)
			M.Jitter(20)
			M.Dizzy(20)
			update_flags |= M.Druggy(45, FALSE)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			M.Stuttering(1)
			M.Jitter(40)
			M.Dizzy(40)
			update_flags |= M.Druggy(60, FALSE)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	return ..() | update_flags

/datum/reagent/consumable/ethanol/changelingsting
	name = "Жало генокрада" // Changeling Sting
	id = "changelingsting"
	description = "Жалящий напиток."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.7
	dizzy_adj = 5
	drink_icon = "changelingsting"
	drink_name = "Жало генокрада"
	drink_desc = "Жалящий напиток."
	taste_description = "лёгкого укола"

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Ирландская автомобильная бомба" // Irish Car Bomb
	id = "irishcarbomb"
	description = "М-м-м, на вкус как шоколадный пирог…"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.3
	dizzy_adj = 5
	drink_icon = "irishcarbomb"
	drink_name = "Ирландская автомобильная бомба"
	drink_desc = "Ирландская автомобильная бомба."
	taste_description = "проблем"

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Бомба Синдиката" // Syndicate Bomb
	id = "syndicatebomb"
	description = "Бомба Синдиката"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "syndicatebomb"
	drink_name = "Бомба Синдиката"
	drink_desc = "Бомба Синдиката."
	taste_description = "предложения работы"

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Сюрприз Эрики" // Erika Surprise
	id = "erikasurprise"
	description = "Сюрприз в том, что он зелёный!"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "erikasurprise"
	name = "Сюрприз Эрики"
	drink_desc = "Сюрприз в том, что он зелёный!"
	taste_description = "разочарования"

/datum/reagent/consumable/ethanol/driestmartini
	name = "Сухой Мартини" // Driest Martini
	id = "driestmartini"
	description = "Только для опытных. Кажется, в стакане плавает песок."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.5
	dizzy_adj = 10
	drink_icon = "driestmartiniglass"
	drink_name = "Сухой Мартини"
	drink_desc = "Только для опытных. Кажется, в стакане плавает песок."
	taste_description = "пыли и пепла"

/datum/reagent/consumable/ethanol/driestmartini/on_mob_life(mob/living/M)
	if(current_cycle >= 55 && current_cycle < 115)
		M.AdjustStuttering(10)
	return ..()

/datum/reagent/consumable/ethanol/kahlua
	name = "Калуа" // Kahlua
	id = "kahlua"
	description = "Широко известный мексиканский ликер со вкусом кофе. Выпускается с 1936 года!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "kahluaglass"
	drink_name = "Стакан кофейного ликёра"
	drink_desc = "DAMN, THIS THING LOOKS ROBUST"
	taste_description = "кофе с алкоголем"

/datum/reagent/consumable/ethanol/kahlua/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDizzy(-5)
	M.AdjustDrowsy(-3)
	update_flags |= (M.AdjustSleeping(-2) ? STATUS_UPDATE_STAT : STATUS_UPDATE_NONE)
	M.Jitter(5)
	return ..() | update_flags

/datum/reagent/ginsonic
	name = "Джин-соник"
	id = "ginsonic"
	description = "НУЖНО НАПИТЬСЯ БЫСТРО, А ЛИКЁР СЛИШКОМ МЕДЛЕННЫЙ"
	reagent_state = LIQUID
	color = "#1111CF"
	drink_icon = "ginsonic"
	drink_name = "Джин-Соник"
	drink_desc = "Чрезвычайно крепкий напиток. Точно не для настоящих англичанин."
	taste_description = "SPEED"

/datum/reagent/ginsonic/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-5)
	if(prob(25))
		update_flags |= M.AdjustParalysis(-1, FALSE)
		update_flags |= M.AdjustStunned(-1, FALSE)
		update_flags |= M.AdjustWeakened(-1, FALSE)
	if(prob(8))
		M.reagents.add_reagent("methamphetamine",1.2)
		var/sonic_message = pick("Ускоряемся!", "Покатили, чиля!", "Я жажду скорости!", "Давай заправимся.", "Пора подзарядиться.", "Носиться — клёво!")
		if(prob(50))
			M.say("[sonic_message]")
		else
			to_chat(M, "<span class='notice'>[sonic_message]</span>")
	return ..() | update_flags

/datum/reagent/consumable/ethanol/applejack
	name = "Яблочная водка" // Applejack
	id = "applejack"
	description = "Высококонцентрированный алкогольный напиток, приготовленный путем многократного замораживания сидра и удаления льда."
	color = "#997A00"
	alcohol_perc = 0.4
	drink_icon = "cognacglass"
	drink_name = "Стакан яблочной водки"
	drink_desc = "Когда сидр недостаточно крепок, и градус нужно поднимать."
	taste_description = "крепкого сидра"

/datum/reagent/consumable/ethanol/jackrose
	name = "Джек Роуз" // Jack Rose
	id = "jackrose"
	description = "Классический коктейль. Вышел из моды, но не утратил вкуса."
	color = "#664300"
	alcohol_perc = 0.4
	drink_icon = "patronglass"
	drink_name = "Джек Роуз"
	drink_desc = "Когда вы его пьёте, то будто оказываетесь в баре роскошного отеля 1920-х годов."
	taste_description = "стиля"

/datum/reagent/consumable/ethanol/drunkenblumpkin
	name = "Пьяный синяк" // Drunken Blumpkin
	id = "drunkenblumpkin"
	description = "Странный микс виски и синячьего сока."
	color = "#1EA0FF" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "drunkenblumpkin"
	drink_name = "Пьяный синяк"
	drink_desc = "Питьё для пьяниц"
	taste_description = "странности"

/datum/reagent/consumable/ethanol/eggnog
	name = "Гоголь-моголь" // Eggnog
	id = "eggnog"
	description = "Для того, чтобы насладиться самым прекрасным временем года."
	color = "#fcfdc6" // rgb: 252, 253, 198
	nutriment_factor = 2 * REAGENTS_METABOLISM
	alcohol_perc = 0.1
	drink_icon = "glass_yellow"
	drink_name = "Гоголь-моголь"
	drink_desc = "Для того, чтобы насладиться самым прекрасным временем года."
	taste_description = "новогоднего праздника"

/datum/reagent/consumable/ethanol/dragons_breath //inaccessible to players, but here for admin shennanigans
	name = "Дыханье дракона" // Dragon's Breath
	id = "dragonsbreath"
	description = "Иметь это при себе, вероятно, нарушает Женевскую конвенцию."
	reagent_state = LIQUID
	color = "#DC0000"
	alcohol_perc = 1
	can_synth = FALSE
	taste_description = "<span class='userdanger'>ЕБУЧАЯ ОГНЕННАЯ СМЕРТЬ БОЖЕ ЧТО ЗА ПИЗДЕЦ</span>"

/datum/reagent/consumable/ethanol/dragons_breath/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST && prob(20))
		if(M.on_fire)
			M.adjust_fire_stacks(6)

/datum/reagent/consumable/ethanol/dragons_breath/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(M.reagents.has_reagent("milk"))
		to_chat(M, "<span class='notice'>Молоко гасит пламя. Уф.</span>")
		M.reagents.del_reagent("milk")
		M.reagents.del_reagent("dragonsbreath")
		return
	if(prob(8))
		to_chat(M, "<span class='userdanger'>О боже! О ДАА!!</span>")
	if(prob(50))
		to_chat(M, "<span class='danger'>У вас жутко жжёт горло!</span>")
		M.emote(pick("scream","cry","choke","gasp"))
		update_flags |= M.Stun(1, FALSE)
	if(prob(8))
		to_chat(M, "<span class='danger'>Почему!? ПОЧЕМУ!?</span>")
	if(prob(8))
		to_chat(M, "<span class='danger'>АРРРГХ!</span>")
	if(prob(2 * volume))
		to_chat(M, "<span class='userdanger'>О БОЖЕ ПОЖАЛУЙСТА НЕ НАДО!!!</b></span>")
		if(M.on_fire)
			M.adjust_fire_stacks(20)
		if(prob(50))
			to_chat(M, "<span class='userdanger'>ОГОНЬ!!!!</span>")
			M.visible_message("<span class='danger'>[M] исчезает в пламени!</span>")
			M.dust()
			return
	return ..() | update_flags

// ROBOT ALCOHOL PAST THIS POINT
// WOOO!

/datum/reagent/consumable/ethanol/synthanol
	name = "Синтанол" // Synthanol
	id = "synthanol"
	description = "Текучая жидкость с проводящими свойствами. Её действие на синтетиков аналогично действию спирта на органиков."
	reagent_state = LIQUID
	color = "#1BB1FF"
	process_flags = ORGANIC | SYNTHETIC
	alcohol_perc = 0.5
	drink_icon = "synthanolglass"
	drink_name = "Стакан синтанола"
	drink_desc = "Эквивалент алкоголя для синтетических членов экипажа. Они бы считали его ужасным, если бы имели вкусовые рецепторы."
	taste_description = "моторного масла"

/datum/reagent/consumable/ethanol/synthanol/on_mob_life(mob/living/M)
	metabolization_rate = REAGENTS_METABOLISM
	if(!(M.dna.species.reagent_tag & PROCESS_SYN))
		metabolization_rate += 3.6 //gets removed from organics very fast
		if(prob(25))
			metabolization_rate += 15
			M.fakevomit()
	return ..()

/datum/reagent/consumable/ethanol/synthanol/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(M.dna.species.reagent_tag & PROCESS_SYN)
		return
	if(method == REAGENT_INGEST)
		to_chat(M, pick("<span class='danger'>Это было ужасно!</span>", "<span class='danger'>Фу-у!</span>"))

/datum/reagent/consumable/ethanol/synthanol/robottears
	name = "Слёзы робота" // Robot Tears
	id = "robottears"
	description = "Маслянистая субстанция, которую КПБ технически могли бы посчитать «напитком»."
	reagent_state = LIQUID
	color = "#363636"
	alcohol_perc = 0.25
	drink_icon = "robottearsglass"
	drink_name = "Стакан слёз робота"
	drink_desc = "При производстве этого напитка ни один робот не пострадал."
	taste_description = "экзистенциальной тревоги"

/datum/reagent/consumable/ethanol/synthanol/trinary
	name = "Троичность" // Trinary
	id = "trinary"
	description = "Фруктовый напиток, предназначенный только для синтетиков, как бы это не работало."
	reagent_state = LIQUID
	color = "#adb21f"
	alcohol_perc = 0.2
	drink_icon = "trinaryglass"
	drink_name = "Стакан троичности"
	drink_desc = "Цветастый напиток для синтетических членов экипажа. Не похоже, что он хотя бы немного вкусный."
	taste_description = "шипения модема"

/datum/reagent/consumable/ethanol/synthanol/servo
	name = "Серво" // Servo
	id = "servo"
	description = "Напиток, содержащий немного органических ингредиентов, но предназначенный только для синтетиков."
	reagent_state = LIQUID
	color = "#5b3210"
	alcohol_perc = 0.25
	drink_icon = "servoglass"
	drink_name = "Стакан серво"
	drink_desc = "Напиток для КПБ на основе шоколада. Вряд ли кто-то пробовал этот рецепт."
	taste_description = "моторного масла и какао"

/datum/reagent/consumable/ethanol/synthanol/uplink
	name = "Аплинк" // Uplink
	id = "uplink"
	description = "Крепкий микс алкоголя и синтанола. Действует только на синтетиков."
	reagent_state = LIQUID
	color = "#e7ae04"
	alcohol_perc = 0.15
	drink_icon = "uplinkglass"
	drink_name = "Стакан аплинка"
	drink_desc = "Изысканный микс лучших ликёров с синтанолом. Только для синтетиков."
	taste_description = "интерфейса на Visual Basic"

/datum/reagent/consumable/ethanol/synthanol/synthnsoda
	name = "Синт с содовой" // Synth 'n Soda
	id = "synthnsoda"
	description = "Классический напиток с поправкой на вкусы роботов."
	reagent_state = LIQUID
	color = "#7204e7"
	alcohol_perc = 0.25
	drink_icon = "synthnsodaglass"
	drink_name = "Стакан синта с содовой"
	drink_desc = "Классический напиток, переделанный под вкусы роботов. Не стоит это пить, если вы сделаны из углерода."
	taste_description = "газированного моторного масла"

/datum/reagent/consumable/ethanol/synthanol/synthignon
	name = "Синтиньон" // Synthignon
	id = "synthignon"
	description = "Кое-кто перемешал вино с алкоголем для роботов. Надеюсь, ты гордишься собой."
	reagent_state = LIQUID
	color = "#d004e7"
	alcohol_perc = 0.25
	drink_icon = "synthignonglass"
	drink_name = "Стакан синтиньона"
	drink_desc = "Кое-кто смешал хорошее вино c робо-выпивкой. Романтично, но отвратительно."
	taste_description = "модного моторного масла"

/datum/reagent/consumable/ethanol/fruit_wine
	name = "Фруктовое вино" // Fruit Wine
	id = "fruit_wine"
	description = "Вино из спелых плодов."
	color = "#FFFFFF"
	alcohol_perc = 0.35
	taste_description = "плохого кодинга"
	can_synth = FALSE
	var/list/names = list("нуль-фруктов" = 1) //Names of the fruits used. Associative list where name is key, value is the percentage of that fruit.
	var/list/tastes = list("плохого кодинга" = 1) //List of tastes. See above.

/datum/reagent/consumable/ethanol/fruit_wine/on_new(list/data)
	names = data["names"]
	tastes = data["tastes"]
	alcohol_perc = data["alcohol_perc"]
	color = data["color"]
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/on_merge(list/data, amount)
	var/diff = (amount/volume)
	if(diff < 1)
		color = BlendRGB(color, data["color"], diff/2) //The percentage difference over two, so that they take average if equal.
	else
		color = BlendRGB(color, data["color"], (1/diff)/2) //Adjust so it's always blending properly.
	var/oldvolume = volume-amount

	var/list/cachednames = data["names"]
	for(var/name in names | cachednames)
		names[name] = ((names[name] * oldvolume) + (cachednames[name] * amount)) / volume

	var/list/cachedtastes = data["tastes"]
	for(var/taste in tastes | cachedtastes)
		tastes[taste] = ((tastes[taste] * oldvolume) + (cachedtastes[taste] * amount)) / volume

	alcohol_perc *= oldvolume
	var/newzepwr = data["alcohol_perc"] * amount
	alcohol_perc += newzepwr
	alcohol_perc /= volume //Blending alcohol percentage to volume.
	generate_data_info(data)

/datum/reagent/consumable/ethanol/fruit_wine/proc/generate_data_info(list/data)
	var/minimum_percent = 0.15 //Percentages measured between 0 and 1.
	var/list/primary_tastes = list()
	var/list/secondary_tastes = list()
	drink_name = "[name] в стакане"
	drink_desc = description
	for(var/taste in tastes)
		switch(tastes[taste])
			if(minimum_percent*2 to INFINITY)
				primary_tastes += taste
			if(minimum_percent to minimum_percent*2)
				secondary_tastes += taste

	var/minimum_name_percent = 0.35
	name = ""
	var/list/names_in_order = sortTim(names, /proc/cmp_numeric_dsc, TRUE)
	var/named = FALSE
	for(var/fruit_name in names)
		if(names[fruit_name] >= minimum_name_percent)
			name += "[fruit_name] "
			named = TRUE
	if(named)
		name += "вино"
	else
		name = "вино из смеси [names_in_order[1]]"

	var/alcohol_description
	switch(alcohol_perc)
		if(1.2 to INFINITY)
			alcohol_description = "смертельное крепкое"
		if(0.9 to 1.2)
			alcohol_description = "довольно крепкое"
		if(0.7 to 0.9)
			alcohol_description = "крепкое"
		if(0.4 to 0.7)
			alcohol_description = "густое"
		if(0.2 to 0.4)
			alcohol_description = "умеренное"
		if(0 to 0.2)
			alcohol_description = "сладкое"
		else
			alcohol_description = "водянистое" //How the hell did you get negative boozepwr?

	var/list/fruits = list()
	if(names_in_order.len <= 3)
		fruits = names_in_order
	else
		for(var/i in 1 to 3)
			fruits += names_in_order[i]
		fruits += "других растений"
	var/fruit_list = english_list(fruits)
	description = "Это [alcohol_description] вино, сваренное из [fruit_list]."

	var/flavor = ""
	if(!primary_tastes.len)
		primary_tastes = list("[alcohol_description] алкоголь")
	flavor += english_list(primary_tastes)
	if(secondary_tastes.len)
		flavor += ", с ноткой "
		flavor += english_list(secondary_tastes)
	taste_description = flavor
	if(holder.my_atom)
		holder.my_atom.on_reagent_change()

/datum/reagent/consumable/ethanol/bacchus_blessing //An EXTREMELY powerful drink. Smashed in seconds, dead in minutes.
	name = "Благословение Бахуса" // Bacchus' Blessing
	id = "bacchus_blessing"
	description = "Нераспознаваемая смесь. Неизмеримо высокое содержание алкоголя"
	color = rgb(51, 19, 3) //Sickly brown
	dizzy_adj = 21
	alcohol_perc = 3 //I warned you
	drink_icon = "bacchusblessing"
	drink_name = "Благословение Бахуса"
	drink_desc = "Вы и не думали, что жидкость может быть настолько отвратительной. Вы уверены…?"
	taste_description = "стены кирпичей"

/datum/reagent/consumable/ethanol/fernet
	name = "Фернет" // Fernet
	id = "fernet"
	description = "Невероятно горький травяной ликер, используемый в качестве дижестива."
	color = "#1B2E24" // rgb: 27, 46, 36
	alcohol_perc = 0.5
	drink_icon = "fernetpuro"
	drink_name = "стакан чистого фернета"
	drink_desc = "Почему ты пьёшь это пюре?"
	taste_description = "глубокой горечи"
	var/remove_nutrition = 2

/datum/reagent/consumable/ethanol/fernet/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!M.nutrition)
		switch(rand(1, 3))
			if(1)
				to_chat(M, "<span class='warning'>Вы проголодались…</span>")
			if(2)
				update_flags |= M.adjustToxLoss(1, FALSE)
				to_chat(M, "<span class='warning'>Ваш желудок болезненно урчит!</span>")
			else
				pass()
	else
		if(prob(60))
			M.adjust_nutrition(-remove_nutrition)
			M.overeatduration = 0
	return ..() | update_flags

/datum/reagent/consumable/ethanol/fernet/fernet_cola
	name = "Фернет-кола" // Fernet Cola
	id = "fernet_cola"
	description = "Очень популярный горько-сладкий дижестив, идеально подходящий после обильной еды. Традиционно подаётся в обрезанной бутылке из-под колы."
	color = "#390600" // rgb: 57, 6, 0
	alcohol_perc = 0.2
	drink_icon = "fernetcola"
	drink_name = "стакан «Фернет-колы»"
	drink_desc = "Обрезанная бутылка из-под колы, наполненная «Фернет-колой». Изнутри раздаётся лёгкая музыка куартето."
	taste_description = "дешёвого рая"
	remove_nutrition = 1
