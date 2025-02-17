//ALCOHOL WOO
/datum/reagent/consumable/ethanol
	name = "Этанол" //Parent class for all alcoholic reagents.
	id = "ethanol"
	description = "Хорошо известный алкоголь, имеющий множество воплощений."
	reagent_state = LIQUID
	nutriment_factor = 0 //So alcohol can fill you up! If they want to.
	color = "#404030" // rgb: 64, 64, 48
	addiction_chance = 3
	addiction_threshold = 150
	minor_addiction = TRUE
	addict_supertype = /datum/reagent/consumable/ethanol
	var/dizzy_adj = 6 SECONDS
	var/alcohol_perc = 1 //percentage of ethanol in a beverage 0.0 - 1.0
	taste_description = "жидкого огня"

/datum/reagent/consumable/ethanol/New()
	addict_supertype = /datum/reagent/consumable/ethanol

/datum/reagent/consumable/ethanol/on_mob_life(mob/living/M)
	M.AdjustDrunk(alcohol_perc STATUS_EFFECT_CONSTANT)
	M.AdjustDizzy(dizzy_adj, bound_upper = 1.5 MINUTES)
	return ..()

/datum/reagent/consumable/ethanol/reaction_obj(obj/O, volume)
	if(istype(O,/obj/item/paper))
		if(istype(O,/obj/item/paper/contract/infernal))
			O.visible_message(span_warning("Смесь воспламеняется при контакте с [O.declent_ru(INSTRUMENTAL)]."))
		else
			var/obj/item/paper/paperaffected = O
			paperaffected.clearpaper()
			paperaffected.visible_message(span_notice("Раствор плавит чернила на бумаге."))
	if(istype(O,/obj/item/book))
		if(volume >= 5)
			var/obj/item/book/affectedbook = O
			affectedbook.dat = null
			affectedbook.visible_message(span_notice("Раствор плавит чернила в книге."))
		else
			O.visible_message(span_warning("Объём вещества был слишком мал, чтобы нанести какой-либо эффект книге."))

/datum/reagent/consumable/ethanol/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(method == REAGENT_TOUCH)
		M.adjust_fire_stacks(volume / 15)


/datum/reagent/consumable/ethanol/beer
	name = "Пиво"
	id = "beer"
	description = "Алкогольный напиток, приготовленный из солода, хмеля, дрожжей и воды."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon ="beerglass"
	drink_name = "стакан пива"
	drink_desc = "Освежающая пинта пива."
	taste_description = "пива"

/datum/reagent/consumable/ethanol/cider
	name = "Сидр"
	id = "cider"
	description = "Алкогольный напиток, получаемый из яблок."
	color = "#174116"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "rewriter"
	drink_name = "стакан сидра"
	drink_desc = "Освежающий стакан традиционного сидра."
	taste_description = "сидра"

/datum/reagent/consumable/ethanol/whiskey
	name = "Виски"
	id = "whiskey"
	description = "Превосходный и отлично выдержанный односолодовый виски. Чёрт возьми."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.4
	drink_icon = "whiskeyglass"
	drink_name = "стакан виски"
	drink_desc = "Шелковистая, дымчатая структура виски в стакане придаёт напитку очень стильный вид."
	taste_description = "виски"

/datum/reagent/consumable/ethanol/specialwhiskey
	name = "Виски Особого Смешения"
	id = "specialwhiskey"
	description = "Как раз в тот момент, когда вы уже думаете, что обычный станционный виски - это хорошо... Это шелковистое, янтарное великолепие приходит и всё портит."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	taste_description = "отличного виски"

/datum/reagent/consumable/ethanol/gin
	name = "Джин"
	id = "gin"
	description = "Это джин. Крепкий алкогольный напиток, приготовленный с использованием самых разных пряностей."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 6 SECONDS
	alcohol_perc = 0.5
	drink_icon = "ginvodkaglass"
	drink_name = "стакан джина"
	drink_desc = "Кристально чистый бокал джина \"Гриффитер\"."
	taste_description = "джина"

/datum/reagent/consumable/ethanol/absinthe
	name = "Абсент"
	id = "absinthe"
	description = "Абсент, очень крепкий напиток для очень крепких парней. Смотрите, чтобы Зелёная Фея не пришла за вами!"
	color = "#33EE00" // rgb: lots, ??, ??
	overdose_threshold = 30
	dizzy_adj = 10 SECONDS
	alcohol_perc = 0.7
	drink_icon = "absintheglass"
	drink_name = "стакан абсента"
	drink_desc = "Теперь Зелёная Фея до вас точно доберётся!"
	taste_description = "чёртовой боли"

//copy paste from LSD... shoot me
/datum/reagent/consumable/ethanol/absinthe/on_mob_life(mob/living/M)
	M.AdjustHallucinate(5 SECONDS)
	M.last_hallucinator_log = name
	return ..()

/datum/reagent/consumable/ethanol/absinthe/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/ethanol/hooch
	name = "Самогон"
	id = "hooch"
	description = "Либо чья-то неудачная попытка приготовить коктейль, либо попытка приготовить алкоголь. В любом случае, вы действительно хотите это выпить?"
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 14 SECONDS
	alcohol_perc = 1
	drink_icon = "glass_brown2"
	drink_name = "стакан самогона"
	drink_desc = "Теперь вы действительно на дне... Вага печень собрала свои вещи и уехала прошлой ночью."
	taste_description = "чистого смирения"

/datum/reagent/consumable/ethanol/hooch/on_mob_life(mob/living/carbon/M)
	if(M.mind && M.mind.assigned_role == JOB_TITLE_CIVILIAN)
		var/update_flags = STATUS_UPDATE_NONE
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
		return ..() | update_flags

/datum/reagent/consumable/ethanol/rum
	name = "Ром"
	id = "rum"
	description = "Крик подобен грому – дайте людям рому!"
	color = "#664300" // rgb: 102, 67, 0
	overdose_threshold = 30
	alcohol_perc = 0.4
	dizzy_adj = 10 SECONDS
	drink_icon = "rumglass"
	drink_name = "стакан рома"
	drink_desc = "Вам захотельно примерить костюм пирата, разве не так?"
	taste_description = "рома"

/datum/reagent/consumable/ethanol/rum/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustToxLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/mojito
	name = "Мохито"
	id = "mojito"
	description = "Если он хорош для Космокубы, то он хорош и для вас."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "mojito"
	drink_name = "стакан мохито"
	drink_desc = "Прямо с Космокубы."
	taste_description = "мохито"

/datum/reagent/consumable/ethanol/vodka
	name = "Водка"
	id = "vodka"
	description = "Алкогольный напиток номер один для славян со всей галактики."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "ginvodkaglass"
	drink_name = "стакан водки"
	drink_desc = "Стакан с водкой. Только не забывайте закусывать."
	taste_description = "водки"

/datum/reagent/consumable/ethanol/vodka/on_mob_life(mob/living/M)
	..()
	if(prob(50))
		M.radiation = max(0, M.radiation-1)

/datum/reagent/consumable/ethanol/sake
	name = "Сакэ"
	id = "sake"
	description = "Это сакэ. Как водка, только из риса."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "sake"
	drink_name = "стакан сакэ"
	drink_desc = "Стакан сакэ. Да, именно так."
	taste_description = "сакэ"

/datum/reagent/consumable/ethanol/tequila
	name = "Текила"
	id = "tequila"
	description = "Крепкий алкогольный напиток с мягким вкусом, производимый по традиционным мексиканским технологиям. Не хочешь промочить горло, омбре?"
	color = "#A8B0B7" // rgb: 168, 176, 183
	alcohol_perc = 0.4
	drink_icon = "tequilaglass"
	drink_name = "стакан текилы"
	drink_desc = "Не хватает только странных цветных оттенков!"
	taste_description = "текилы"

/datum/reagent/consumable/ethanol/vermouth
	name = "Вермут"
	id = "vermouth"
	description = "Вам вдруг ужасно захотелось мартини..."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "vermouthglass"
	drink_name = "стакан вермута"
	drink_desc = "Чёрт, зачем вообще пить это неразбавленным?"
	taste_description = "вермута"

/datum/reagent/consumable/ethanol/wine
	name = "Вино"
	id = "wine"
	description = "Алкогольный напиток премиум-класса, приготовленный из дистиллированного виноградного сока."
	color = "#7E4043" // rgb: 126, 64, 67
	dizzy_adj = 4 SECONDS
	alcohol_perc = 0.2
	drink_icon = "wineglass"
	drink_name = "Бокал вина"
	drink_desc = "Очень стильный на вид напиток."
	taste_description = "вина"

/datum/reagent/consumable/ethanol/cognac
	name = "Коньяк"
	id = "cognac"
	description = "Сладкий крепкий напиток, приготовленный с помощью многочисленных перегонок и многолетней выдержки. Сама элегантность."
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.4
	drink_icon = "cognacglass"
	drink_name = "стакан коньяка"
	drink_desc = "Вы чувствуете себя аристократом просто держа его в руках."
	taste_description = "коньяка"

/datum/reagent/consumable/ethanol/suicider //otherwise known as "I want to get so smashed my liver gives out and I die from alcohol poisoning".
	name = "Суисидр"
	id = "suicider"
	description = "Невероятно крепкий и мощный сорт сидра."
	color = "#CF3811"
	dizzy_adj = 40 SECONDS
	alcohol_perc = 1 //because that's a thing it's supposed to do, I guess
	drink_icon = "suicider"
	drink_name = "стакан суисидра"
	drink_desc = "Вы действительно достигли дна... Ваша печень собрала вещи и ушла вчера вечером."
	taste_description = "неминуемой смерти"

/datum/reagent/consumable/ethanol/ale
	name = "Эль"
	id = "ale"
	description = "Тёмный алкогольный напиток, приготовленный из ячменного солода и дрожжей."
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.1
	drink_icon = "aleglass"
	drink_name = "стакан эля"
	drink_desc = "Освежающая пинта отличного эля."
	taste_description = "эля"

/datum/reagent/consumable/ethanol/thirteenloko
	name = "Тринадцатый Локо"
	id = "thirteenloko"
	description = "Крепкая смесь кофеина и алкоголя."
	reagent_state = LIQUID
	color = "#102000" // rgb: 16, 32, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.3
	heart_rate_increase = 1
	drink_icon = "thirteen_loko_glass"
	drink_name = "стакан Тринадцатого Локо"
	drink_desc = "Этот стакан Тринадцатого Локо, судя по всему, самого высокого качества. Напиток, а не стакан."
	taste_description = "смешанного с алкоголем энергетика"

/datum/reagent/consumable/ethanol/thirteenloko/on_mob_life(mob/living/M)
	M.AdjustDrowsy(-14 SECONDS)
	M.AdjustSleeping(-4 SECONDS)
	if(M.bodytemperature > BODYTEMP_NORMAL)
		M.adjust_bodytemperature(-(5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(10 SECONDS)
	return ..()


/////////////////////////////////////////////////////////////////cocktail entities//////////////////////////////////////////////

/datum/reagent/consumable/ethanol/bilk
	name = "Миво"
	id = "bilk"
	description = "Это пиво, смешанное с молоком. Ух..."
	reagent_state = LIQUID
	color = "#895C4C" // rgb: 137, 92, 76
	nutriment_factor = 2 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "glass_brown"
	drink_name = "стакан мива"
	drink_desc = "Молоко с пивом - миво. Или пиво с молоком - пивоко. Как вам будет угодно."
	taste_description = "мива"

/datum/reagent/consumable/ethanol/atomicbomb
	name = "Атомная Бомба"
	id = "atomicbomb"
	description = "Ядерное оружие никогда не было таким вкусным."
	reagent_state = LIQUID
	color = "#666300" // rgb: 102, 99, 0
	alcohol_perc = 0.2
	drink_icon = "atomicbombglass"
	drink_name = "Атомная Бомба"
	drink_desc = "Nanotrasen не несёт юридической ответственности за ваши действия после употребления напитка."
	taste_description = "длинного, терпкого ожога"

/datum/reagent/consumable/ethanol/threemileisland
	name = "Чай со льдом Три-Майл-Айленд"
	id = "threemileisland"
	description = "Создан для женщин, достаточно крепок для мужчин."
	reagent_state = LIQUID
	color = "#666340" // rgb: 102, 99, 64
	alcohol_perc = 0.2
	drink_icon = "threemileislandglass"
	drink_name = "Чай со льдом Три-Майл-Айленд"
	drink_desc = "Бокал этого напитка точно предотвратит нервный срыв."
	taste_description = "текучей волны жара"

/datum/reagent/consumable/ethanol/goldschlager
	name = "Гольдшлягер"
	id = "goldschlager"
	description = "Шнапс с корицей 100%-ой пробы пробы, созданный для алкоголиков-подростков на весенних каникулах."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "ginvodkaglass"
	drink_name = "стакан шольдшлягера"
	drink_desc = "Стопроцентное доказательства того, что девочки-подростки будут пить всё, что содержит золото в названии."
	taste_description = "глубокого, пряного тепла"

/datum/reagent/consumable/ethanol/patron
	name = "Патрон"
	id = "patron"
	description = "Текила с серебром в составе, которую пьют женщины-алкоголики в клубах."
	reagent_state = LIQUID
	color = "#585840" // rgb: 88, 88, 64
	alcohol_perc = 0.4
	drink_icon = "patronglass"
	drink_name = "стакан Патрона"
	drink_desc = "Пить патрон в клубе в окружении женщин-алкоголиков."
	taste_description = "подарка"

/datum/reagent/consumable/ethanol/gintonic
	name = "Джин и тоник"
	id = "gintonic"
	description = "Классический мягкий коктейль, нестареющая классика."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "gintonicglass"
	drink_name = "стакан джина и тоника"
	drink_desc = "Мягкий, но всё равно отличный коктейль. Пейте, как истинный англичанин."
	taste_description = "горького лекарства"

/datum/reagent/consumable/ethanol/cuba_libre
	name = "Куба Либре"
	id = "cubalibre"
	description = "Ром, смешанный с колой. Viva la Revolution!"
	reagent_state = LIQUID
	color = "#3E1B00" // rgb: 62, 27, 0
	alcohol_perc = 0.2
	drink_icon = "cubalibreglass"
	drink_name = "стакан Куба Либре"
	drink_desc = "Классический микс рома и колы."
	taste_description = "пьянящей свободы"

/datum/reagent/consumable/ethanol/whiskey_cola
	name = "Виски-кола"
	id = "whiskeycola"
	description = "Виски, смешанный с колой. Удивительно освежающий."
	reagent_state = LIQUID
	color = "#3E1B00" // rgb: 62, 27, 0
	alcohol_perc = 0.3
	drink_icon = "whiskeycolaglass"
	drink_name = "стакан виски-колы"
	drink_desc = "Невинно выглядящая смесь колы и виски. Вкусно."
	taste_description = "виски с колой"

/datum/reagent/consumable/ethanol/martini
	name = "Классический мартини"
	id = "martini"
	description = "Вермут с джином. Не совсем то, что пил 007, но всё равно вкусно."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "martiniglass"
	drink_name = "Классическое мартини"
	drink_desc = "Взболтать, но не смешивать."
	taste_description = "аристократии"

/datum/reagent/consumable/ethanol/vodkamartini
	name = "Водка мартини"
	id = "vodkamartini"
	description = "Водка с джином. Не совсем то, что пил 007, но всё равно вкусно."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "martiniglass"
	drink_name = "Водка мартини"
	drink_desc ="Славянская версия классического мартини. На удивление вкусно."
	taste_description = "аристократии и картошки"

/datum/reagent/consumable/ethanol/white_russian
	name = "Белый Русский"
	id = "whiterussian"
	description = "Но это только твоё мнение, чувак..."
	reagent_state = LIQUID
	color = "#A68340" // rgb: 166, 131, 64
	alcohol_perc = 0.3
	drink_icon = "whiterussianglass"
	drink_name = "стакан Белого Русского"
	drink_desc = "Странно выглядящий напиток. Но это только твое мнение, чувак."
	taste_description = "очень кремового алкоголя"

/datum/reagent/consumable/ethanol/screwdrivercocktail
	name = "Отвёртка"
	id = "screwdrivercocktail"
	description = "Водка, смешанная с апельсиновым соком. Достаточно вкусно."
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.3
	drink_icon = "screwdriverglass"
	drink_name = "стакан Отвёртки"
	drink_desc = "Простая, но изящная смесь водки и апельсинового сока. То, что нужно уставшему инженеру."
	taste_description = "водки с апельсином"

/datum/reagent/consumable/ethanol/booger
	name = "Козявка"
	id = "booger"
	description = "Ууу..."
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.2
	drink_icon = "booger"
	drink_name = "стакан Козявки"
	drink_desc = "Ууу..."
	taste_description = "фруктовой массы"

/datum/reagent/consumable/ethanol/bloody_mary
	name = "Кровавая Мэри"
	id = "bloodymary"
	description = "Странная, но приятная смесь из водки, томатов и сока лайма. А томатов ли?"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "bloodymaryglass"
	drink_name = "стакан Кровавой Мэри"
	drink_desc = "Томатный сок, смешанный с водкой и небольшим количеством лайма. На вкус как жидкое убийство."
	taste_description = "томатов со спиртом"

/datum/reagent/consumable/ethanol/bloody_mary/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle % 20 == 0)
		update_flags |= M.adjustToxLoss(-1, FALSE) //heals 1 tox damage every 20 cycles or (metabolization_rate * 20) units of reagent
	return ..() | update_flags

/datum/reagent/consumable/ethanol/gargle_blaster
	name = "Пан-Галактический Грызлодёр"
	id = "gargleblaster"
	description = "Вау, эта штука выглядит нестабильно!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.7 //ouch
	drink_icon = "gargleblasterglass"
	drink_name = "Пан-Галактический Грызлодёр"
	drink_desc = "Значит ли... значит ли это, что Артур и Форд на станции? О, отлично."
	taste_description = "числа 42"

/datum/reagent/consumable/ethanol/flaming_homer
	name = "Горящий Мо"
	id = "flamingmoe"
	description = "Это, по-видимому, смесь различных алкогольных напитков, смешанных с рецептурным лекарством."
	reagent_state = LIQUID
	color = "#58447f" //rgb: 88, 66, 127
	alcohol_perc = 0.5
	drink_icon = "flamingmoeglass"
	drink_name = "Горящий Мо"
	drink_desc = "Смотри не обожгись!"
	taste_description = "карамелизированной выпивки и лекарства"

/datum/reagent/consumable/ethanol/brave_bull
	name = "Храбрый Бык"
	id = "bravebull"
	description = "Текила с кофейным ликёром. Хех."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "bravebullglass"
	drink_name = "стакан Бравого Быка"
	drink_desc = "Текила и кофейный ликер, соединённые в аппетитную смесь. Так пейте же."
	taste_description = "сладкого алкоголя"

/datum/reagent/consumable/ethanol/tequila_sunrise
	name = "Текила Санрайз"
	id = "tequilasunrise"
	description = "Текила и апельсиновый сок. Как \"Отвёртка\", только по-мексикански."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "tequilasunriseglass"
	drink_name = "стакан Текилы Санрайз"
	drink_desc = "Отлично, теперь вы ностальгируете по восходам на Терре..."
	taste_description = "фруктового алкоголя"

/datum/reagent/consumable/ethanol/toxins_special
	name = "Особый из Токсикологии"
	id = "toxinsspecial"
	description = "Эта штука горит! ВЫЗОВИТЕ ЧЁРТОВ ШАТТЛ!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "toxinsspecialglass"
	drink_name = "Особый из Токсикологии"
	drink_desc = "Уох, эта штука ГОРИТ!"
	taste_description = "огня"

/datum/reagent/consumable/ethanol/toxins_special/on_mob_life(mob/living/M)
	if(M.bodytemperature < (BODYTEMP_NORMAL + 20))
		M.adjust_bodytemperature(15 * TEMPERATURE_DAMAGE_COEFFICIENT)
	return ..()

/datum/reagent/consumable/ethanol/beepsky_smash
	name = "Удар Бипски"
	id = "beepskysmash"
	description = "Перестаньте пить это и приготовьтесь к ПРАВОСУДИЮ."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "beepskysmashglass"
	drink_name = "Удар Бипски"
	drink_desc = "Тяжелый, горячий и крепкий. Как железный кулак ПРАВОСУДИЯ."
	taste_description = "правосудия"

/datum/reagent/consumable/ethanol/beepsky_smash/on_mob_life(mob/living/M)
	M.drop_from_hands()
	return ..()

/datum/reagent/consumable/ethanol/irish_cream
	name = "Ирландские Сливки"
	description = "Крем с добавлением виски - чего ещё ожидать от ирландцев?"
	id = "irishcream"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "irishcreamglass"
	drink_name = "стакан Ирландских Сливок"
	drink_desc = "Крем с добавлением виски - чего ещё ожидать от ирландцев?"
	taste_description = "сливочного алкоголя"

/datum/reagent/consumable/ethanol/manly_dorf
	name = "Мужественный Дворф"
	id = "manlydorf"
	description = "Крепкая смесь из эля и пива для настоящих трудяг. За Карла!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "manlydorfglass"
	drink_name = "Кружка Мужественного Дворфа"
	drink_desc = "Крепкая смесь из эля и пива для настоящих трудяг. За Карла!"
	taste_description = "мужественности"

/datum/reagent/consumable/ethanol/longislandicedtea
	name = "Чай со льдом Лонг Айленд"
	id = "longislandicedtea"
	description = "Содержимое ликёрного шкафа, смешанное в восхитительный микс. Предназначен только для женщин-алкоголичек среднего возраста."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "longislandicedteaglass"
	drink_name = "стакан чая со льдом Лонг Айленд"
	drink_desc = "Содержимое ликёрного шкафа, смешанное в восхитительный микс. Предназначен только для женщин-алкоголичек среднего возраста."
	taste_description = "фруктового алкоголя"

/datum/reagent/consumable/ethanol/moonshine
	name = "Самогон"
	id = "moonshine"
	description = "Вы действительно достигли дна... ваша печень собрала вещи и ушла вчера вечером."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.8 //yeeehaw
	drink_icon = "glass_clear"
	drink_name = "стакан самогона"
	drink_desc = "Вы действительно достигли дна... ваша печень собрала вещи и ушла вчера вечером."
	taste_description = "чего-то запрещённого"

/datum/reagent/consumable/ethanol/b52
	name = "B-52"
	id = "b52"
	description = "Кофе, ирландские сливки и коньяк. Взрывная смесь."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "b52glass"
	drink_name = "стакан B-52"
	drink_desc = "Кофе, ирландские сливки и коньяк. Взрывная смесь."
	taste_description = "уничтожения"

/datum/reagent/consumable/ethanol/irishcoffee
	name = "Кофе по Ирландски"
	id = "irishcoffee"
	description = "Кофе и алкоголь. Веселее, чем пить \"Мимозу\" по утрам."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "irishcoffeeglass"
	drink_name = "Кофе по Ирландски"
	drink_desc = "Кофе и алкоголь. Веселее, чем пить \"Мимозу\" по утрам."
	taste_description = "кофе с алкоголем"

/datum/reagent/consumable/ethanol/margarita
	name = "Маргарита"
	id = "margarita"
	description = "Текила с ликёром и лаймом. Так по-мексикански."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "margaritaglass"
	drink_name = "Маргарита"
	drink_desc = "Текила с ликёром и лаймом. Так по-мексикански."
	taste_description = "маргариток"

/datum/reagent/consumable/ethanol/black_russian
	name = "Чёрный Русский"
	id = "blackrussian"
	description = "Для тех, кто не переносит лактозу. По-прежнему стильный, как и Белый Русский."
	reagent_state = LIQUID
	color = "#360000" // rgb: 54, 0, 0
	alcohol_perc = 0.4
	drink_icon = "blackrussianglass"
	drink_name = "стакан Чёрного Русского"
	drink_desc = "Для тех, кто не переносит лактозу. По-прежнему стильный, как и Белый Русский."
	taste_description = "сладкого алкоголя"

/datum/reagent/consumable/ethanol/manhattan
	name = "Манхэттен"
	id = "manhattan"
	description = "Любимый напиток детектива под прикрытием. Он никогда не переносил джин..."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "manhattanglass"
	drink_name = "Манхэттен"
	drink_desc = "Любимый напиток детектива под прикрытием. Он никогда не переносил джин..."
	taste_description = "городской суеты"

/datum/reagent/consumable/ethanol/manhattan_proj
	name = "Манхэттенский проект"
	id = "manhattan_proj"
	description = "Напиток для учёных, размышляющих о том, как взорвать станцию."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "proj_manhattanglass"
	drink_name = "Манхэттенский проект"
	drink_desc = "Напиток для учёных, размышляющих о том, как взорвать станцию."
	taste_description = "апокалипсиса"

/datum/reagent/consumable/ethanol/whiskeysoda
	name = "Виски-сода"
	id = "whiskeysoda"
	description = "Ультимативный способ освежиться."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "whiskeysodaglass2"
	drink_name = "стакан виски-соды"
	drink_desc = "Ультимативный способ освежиться."
	taste_description = "посредственности"

/datum/reagent/consumable/ethanol/antifreeze
	name = "Анти-фриз"
	id = "antifreeze"
	description = "Ультимативный способ освежиться."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "antifreeze"
	drink_name = "Анти-фриз"
	drink_desc = "Ультимативный способ освежиться."
	taste_description = "неправильности жизненного пути"

/datum/reagent/consumable/ethanol/antifreeze/on_mob_life(mob/living/M)
	if(M.bodytemperature < (BODYTEMP_NORMAL + 20))
		M.adjust_bodytemperature(20 * TEMPERATURE_DAMAGE_COEFFICIENT)
	return ..()

/datum/reagent/consumable/ethanol/barefoot
	name = "Босяк"
	id = "barefoot"
	description = "Босоногость и беременность."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "b&p"
	drink_name = "Босяк"
	drink_desc = "Босоногость и беременность."
	taste_description = "беременности"

/datum/reagent/consumable/ethanol/snowwhite
	name = "Белоснежка"
	id = "snowwhite"
	description = "Холодный напиток. Реально холодный."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "snowwhite"
	drink_name = "стакан Белоснежки"
	drink_desc = "Холодный напиток. Реально холодный."
	taste_description = "отравленного яблока"

/datum/reagent/consumable/ethanol/demonsblood
	name = "Кровь Демона"
	id = "demonsblood"
	description = "ААААА!!!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 20 SECONDS
	alcohol_perc = 0.4
	drink_icon = "demonsblood"
	drink_name = "Кровь Демона"
	drink_desc = "От одного взгляда на эту штуку волосы на затылке встают дыбом."
	taste_description = "зла"

/datum/reagent/consumable/ethanol/vodkatonic
	name = "Водка и тоник"
	id = "vodkatonic"
	description = "Когда \"Джин и тоник\" не достаточно славянский."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.3
	drink_icon = "vodkatonicglass"
	drink_name = "стакан водки и тоника"
	drink_desc = "Когда \"Джин и тоник\" не достаточно славянский."
	taste_description = "горького лекарства"

/datum/reagent/consumable/ethanol/ginfizz
	name = "Джин-физ"
	id = "ginfizz"
	description = "Освежающе лимонный, восхитительно сухой."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	dizzy_adj = 8 SECONDS
	alcohol_perc = 0.4
	drink_icon = "ginfizzglass"
	drink_name = "стакан Джин-физа"
	drink_desc = "Освежающе лимонный, восхитительно сухой."
	taste_description = "шипучего алкоголя"

/datum/reagent/consumable/ethanol/bahama_mama
	name = "Бахама Мама"
	id = "bahama_mama"
	description = "Тропический коктейль."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "bahama_mama"
	drink_name = "Бахама Мама"
	drink_desc = "Тропический коктейль."
	taste_description = "фруктов и алкоголя"

/datum/reagent/consumable/ethanol/singulo
	name = "Сингуло"
	id = "singulo"
	description = "Блю-спейс коктейль, вау!"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	dizzy_adj = 30 SECONDS
	alcohol_perc = 0.7
	drink_icon = "singulo"
	drink_name = "Сингуло"
	drink_desc = "Блю-спейс коктейль, вау!"
	taste_description = "бесконечности"

/datum/reagent/consumable/ethanol/sbiten
	name = "Сбитень"
	id = "sbiten"
	description = "Пряная водка! Горячо!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "sbitenglass"
	drink_name = "кружка Сбитня"
	drink_desc = "Пряная водка! Горячо!"
	taste_description = "приятно согревающего алкоголя"

/datum/reagent/consumable/ethanol/sbiten/on_mob_life(mob/living/M)
	if(M.bodytemperature < (BODYTEMP_NORMAL + 50))
		M.adjust_bodytemperature(50 * TEMPERATURE_DAMAGE_COEFFICIENT)
	return ..()

/datum/reagent/consumable/ethanol/devilskiss
	name = "Поцелуй Дьявола"
	id = "devilskiss"
	description = "Время страшилок!"
	reagent_state = LIQUID
	color = "#A68310" // rgb: 166, 131, 16
	alcohol_perc = 0.3
	drink_icon = "devilskiss"
	drink_name = "Поцелуй Дьявола"
	drink_desc = "Время страшилок!"
	taste_description = "озорства"

/datum/reagent/consumable/ethanol/red_mead
	name = "Красная медовуха"
	id = "red_mead"
	description = "Напиток Настоящих Викингов! Даже несмотря на странный красный цвет."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "red_meadglass"
	drink_name = "красная медовуха"
	drink_desc = "Напиток Настоящих Викингов! Даже несмотря на странный красный цвет."
	taste_description = "крови и мёда"

/datum/reagent/consumable/ethanol/mead
	name = "Медовуха"
	id = "mead"
	description = "Напиток Настоящих Викингов!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	nutriment_factor = 1 * REAGENTS_METABOLISM
	alcohol_perc = 0.2
	drink_icon = "meadglass"
	drink_name = "медовуха"
	drink_desc = "Напиток Настоящих Викингов!"
	taste_description = "мёда"

/datum/reagent/consumable/ethanol/iced_beer
	name = "Пиво со льдом"
	id = "iced_beer"
	description = "Пиво, настолько ледяное, что воздух вокруг него замерзает."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "iced_beerglass"
	drink_name = "стакан пива со льдом"
	drink_desc = "Пиво, настолько ледяное, что воздух вокруг него замерзает."
	taste_description = "холодного пива"

/datum/reagent/consumable/ethanol/iced_beer/on_mob_life(mob/living/M)
	if(M.bodytemperature > (BODYTEMP_NORMAL - 40))
		M.adjust_bodytemperature(-(20 * TEMPERATURE_DAMAGE_COEFFICIENT))
	return ..()

/datum/reagent/consumable/ethanol/grog
	name = "Грог"
	id = "grog"
	description = "Разведённый водом ром. Просто, но со вкусом."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "grogglass"
	drink_name = "кружка грога"
	drink_desc = "Разведённый водом ром. Просто, но со вкусом."
	taste_description = "сильно разбавленного рома"

/datum/reagent/consumable/ethanol/aloe
	name = "Алоэ"
	id = "aloe"
	description = "Хорошо, очень хорошо."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "aloe"
	drink_name = "Алоэ"
	drink_desc = "Хорошо, очень хорошо."
	taste_description = "здоровой кожи"

/datum/reagent/consumable/ethanol/andalusia
	name = "Андалузия"
	id = "andalusia"
	description = "Хороший напиток со странным названием."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.4
	drink_icon = "andalusia"
	drink_name = "Андалузия"
	drink_desc = "Хороший напиток со странным названием."
	taste_description = "сладкого алкоголя"

/datum/reagent/consumable/ethanol/alliescocktail
	name = "Коктейль союзников"
	id = "alliescocktail"
	description = "Напиток, приготовленный из ваших союзников."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "alliescocktail"
	drink_name = "Коктейль союзников"
	drink_desc = "Напиток, приготовленный из ваших союзников."
	taste_description = "победы"

/datum/reagent/consumable/ethanol/acid_spit
	name = "Кислотный Плевок"
	id = "acidspit"
	description = "Сделан из живых пришельцев."
	reagent_state = LIQUID
	color = "#365000" // rgb: 54, 80, 0
	alcohol_perc = 0.3
	drink_icon = "acidspitglass"
	drink_name = "стакан Кислотного Плевка"
	drink_desc = "Сделан из живых пришельцев."
	taste_description = "ЖГУЧЕЙ БОЛИ"

/datum/reagent/consumable/ethanol/acid_spit/reaction_mob(mob/living/M, method, volume)
	. = ..()
	if(prob(50))
		M.emote("scream")

/datum/reagent/consumable/ethanol/amasec
	name = "Амасек"
	id = "amasec"
	description = "Император одобряет."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.3
	drink_icon = "amasecglass"
	drink_name = "кружка Амасека"
	drink_desc = "Пригодится перед БОЕМ!!!"
	taste_description = "странного алкоголя"

/datum/reagent/consumable/ethanol/neurotoxin
	name = "Нейротоксин"
	id = "neurotoxin"
	description = "Сильный нейротоксин, который вводит выпившего в состояние, подобное смерти."
	reagent_state = LIQUID
	color = "#2E2E61" // rgb: 46, 46, 97
	dizzy_adj = 12 SECONDS
	alcohol_perc = 0.7
	heart_rate_decrease = 1
	drink_icon = "neurotoxinglass"
	drink_name = "Нейротоксин"
	drink_desc = "Напиток, который гарантированно собьёт вас с толку."
	taste_description = "удара по мозгам"

/datum/reagent/consumable/ethanol/neurotoxin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle >= 13)
		M.Weaken(6 SECONDS)
	if(current_cycle >= 55)
		M.Druggy(110 SECONDS)
	if(current_cycle >= 200)
		update_flags |= M.adjustToxLoss(2, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/hippies_delight
	name = "Радость Хиппи"
	id = "hippiesdelight"
	description = "Ты просто не понимаешь, чуваааак."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	drink_icon = "hippiesdelightglass"
	drink_name = "стакан Радости Хиппи"
	drink_desc = "Ты просто не понимаешь, чуваааак."
	taste_description = "цветов"

/datum/reagent/consumable/ethanol/hippies_delight/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(100 SECONDS)
	switch(current_cycle)
		if(1 to 5)
			M.Stuttering(2 SECONDS)
			M.Dizzy(20 SECONDS)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Stuttering(2 SECONDS)
			M.Jitter(40 SECONDS)
			M.Dizzy(40 SECONDS)
			M.Druggy(90 SECONDS)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if(10 to INFINITY)
			M.Stuttering(2 SECONDS)
			M.Jitter(80 SECONDS)
			M.Dizzy(80 SECONDS)
			M.Druggy(120 SECONDS)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	return ..() | update_flags

/datum/reagent/consumable/ethanol/changelingsting
	name = "Жало Генокрада"
	id = "changelingsting"
	description = "Генокрадов не существует, это ведь даже дети знают."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.7
	dizzy_adj = 10 SECONDS
	drink_icon = "changelingsting"
	drink_name = "Жало Генокрада"
	drink_desc = "Генокрадов не существует, это ведь даже дети знают."
	taste_description = "лёгкого укола"

/datum/reagent/consumable/ethanol/irishcarbomb
	name = "Ирландская Автомобильная Бомба"
	id = "irishcarbomb"
	description = "Ммм, на вкус как шоколадный торт..."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.3
	dizzy_adj = 10 SECONDS
	drink_icon = "irishcarbomb"
	drink_name = "стакан Ирландской Автомобильной Бомбы"
	drink_desc = "Ирландская Автомобильная Бомба."
	taste_description = "проблем"

/datum/reagent/consumable/ethanol/syndicatebomb
	name = "Бомба Синдиката"
	id = "syndicatebomb"
	description = "Пить аккуратно."
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "syndicatebomb"
	drink_name = "Бомба Синдиката"
	drink_desc = "Бум. Пить осторожно."
	taste_description = "предложения о работе"

/datum/reagent/consumable/ethanol/erikasurprise
	name = "Сюрприз Эрики"
	id = "erikasurprise"
	description = "Сюрприз в том, что он зелёный!"
	reagent_state = LIQUID
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.2
	drink_icon = "erikasurprise"
	name = "Сюрприз Эрики"
	drink_desc = "Сюрприз в том, что он зелёный!"
	taste_description = "разочарования"

/datum/reagent/consumable/ethanol/driestmartini
	name = "Самый сухой мартини"
	id = "driestmartini"
	description = "Только для опытных. Стоп, это песок там в стакане?"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113
	alcohol_perc = 0.5
	dizzy_adj = 20 SECONDS
	drink_icon = "driestmartiniglass"
	drink_name = "Самый сухой мартини"
	drink_desc = "Только для опытных. Стоп, это песок там в стакане?"
	taste_description = "пыли и пепла"

/datum/reagent/consumable/ethanol/driestmartini/on_mob_life(mob/living/M)
	if(current_cycle >= 55 && current_cycle < 115)
		M.AdjustStuttering(20 SECONDS)
	return ..()

/datum/reagent/consumable/ethanol/kahlua
	name = "Калуа"
	id = "kahlua"
	description = "Широко известный мексиканский ликёр со вкусом кофе. Производится с 1936 года!"
	color = "#664300" // rgb: 102, 67, 0
	alcohol_perc = 0.2
	drink_icon = "kahluaglass"
	drink_name = "ликёра \"Калуа\""
	drink_desc = "Выглядит робастно."
	taste_description = "кофе и алкоголя"

/datum/reagent/consumable/ethanol/kahlua/on_mob_life(mob/living/M)
	M.AdjustDizzy(-10 SECONDS)
	M.AdjustDrowsy(-6 SECONDS)
	M.AdjustSleeping(-4 SECONDS)
	M.Jitter(10 SECONDS)
	return ..()

/datum/reagent/ginsonic
	name = "Джин и Соник"
	id = "ginsonic"
	description = "GOTTA GET CRUNK FAST BUT LIQUOR TOO SLOW"
	reagent_state = LIQUID
	color = "#1111CF"
	drink_icon = "ginsonic"
	drink_name = "Джин и Соник"
	drink_desc = "Напиток с чрезвычайно высокой силой тока. Абсолютно не для истинного англичанина."
	taste_description = "СКОРОСТИ"

/datum/reagent/ginsonic/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-10 SECONDS)
	if(prob(25))
		M.AdjustParalysis(-2 SECONDS)
		M.AdjustStunned(-2 SECONDS)
		M.AdjustWeakened(-2 SECONDS)
	if(prob(8))
		M.reagents.add_reagent("methamphetamine",1.2)
		var/sonic_message = pick("НАДО! ЕЩЁ! БЫСТРЕЕ!!!", "БЫСТРЕЕ, БЫСТРЕЕ, ЕЩЁ БЫСТРЕЕ!!!", "ДА, ДЕТКА!!!", "БОДРИТ!!!", "ПОШЁЛ, ПОШЁЛ!!!", "На старт... МАРШ!!!", "ПОНЕСЛАСЬ!!!")
		if(prob(50))
			M.say("[sonic_message]")
		else
			to_chat(M, span_notice("[sonic_message]"))
	return ..() | update_flags

/datum/reagent/consumable/ethanol/applejack
	name = "Эпплджек"
	id = "applejack"
	description = "Высококонцентрированный алкогольный напиток, изготовленный путём многократного замораживания сидра и удаления льда."
	color = "#997A00"
	alcohol_perc = 0.4
	drink_icon = "cognacglass"
	drink_name = "Эпплджек"
	drink_desc = "Когда сидр недостаточно крепок."
	taste_description = "крепкого сидра"

/datum/reagent/consumable/ethanol/jackrose
	name = "Джек Роуз"
	id = "jackrose"
	description = "Классический коктейль, который вышел из моды, но не из вкуса."
	color = "#664300"
	alcohol_perc = 0.4
	drink_icon = "patronglass"
	drink_name = "Джек Роуз"
	drink_desc = "При его употреблении вы чувствуете себя в баре роскошного отеля 1920-х годов."
	taste_description = "стиля"

/datum/reagent/consumable/ethanol/drunkenblumpkin
	name = "Пьяный Идиот"
	id = "drunkenblumpkin"
	description = "Странная смесь виски и тыквенного сока."
	color = "#1EA0FF" // rgb: 102, 67, 0
	alcohol_perc = 0.5
	drink_icon = "drunkenblumpkin"
	drink_name = "Пьяный Идиот"
	drink_desc = "Напиток для напивающихся."
	taste_description = "странности"

/datum/reagent/consumable/ethanol/eggnog
	name = "Эгг-Ног"
	id = "eggnog"
	description = "Для наслаждения самым чудесным временем года."
	color = "#fcfdc6" // rgb: 252, 253, 198
	nutriment_factor = 2 * REAGENTS_METABOLISM
	alcohol_perc = 0.1
	drink_icon = "glass_yellow"
	drink_name = "стакан Эгг-Нога"
	drink_desc = "Для наслаждения самым чудесным временем года."
	taste_description = "рождества"

/datum/reagent/consumable/ethanol/dragons_breath //inaccessible to players, but here for admin shennanigans
	name = "Дыхание Дракона"
	id = "dragonsbreath"
	description = "Производство этого напитка вероятно, нарушает Женевскую конвенцию."
	reagent_state = LIQUID
	color = "#DC0000"
	alcohol_perc = 1
	can_synth = FALSE
	taste_description = span_userdanger("ЖИДКОЙ БЛЯДЬ СМЕРТИ СУКА ПИЗДЕЦ НАХУЙ КАКОГО ХУЯ")

/datum/reagent/consumable/ethanol/dragons_breath/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST && prob(20))
		if(M.on_fire)
			M.adjust_fire_stacks(6)

/datum/reagent/consumable/ethanol/dragons_breath/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(M.reagents.has_reagent("milk"))
		to_chat(M, span_notice("Молоко останавливает горение. Фух."))
		M.reagents.del_reagent("milk")
		M.reagents.del_reagent("dragonsbreath")
		return
	if(prob(8))
		to_chat(M, span_userdanger("Господи! ГОСПОДИ БЛЯДЬ!!!"))
	if(prob(50))
		to_chat(M, span_danger("Ваша глотка пылает! Буквально!"))
		M.emote(pick("scream","cry","choke","gasp"))
		M.Stun(2 SECONDS)
	if(prob(8))
		to_chat(M, span_danger("За что?! ЗА ЧТО?!"))
	if(prob(8))
		to_chat(M, span_danger("ААААААААА!!!"))
	if(prob(2 * volume))
		to_chat(M, span_userdanger("ГОСПОДИ БОЖЕ БЛЯДЬ НЕТ НЕТ НЕТ!!!"))
		if(M.on_fire)
			M.adjust_fire_stacks(20)
		if(prob(50))
			to_chat(M, span_userdanger("КАК ЖЖЁТСЯ, КАК ЖЕ ОНО ЖЖЁТСЯ!!!"))
			M.visible_message( span_danger("[M] сгорел[genderize_ru(M.gender, "", "а", "о", "и")] заживо!"))
			M.dust()
			return
	return ..() | update_flags

// ROBOT ALCOHOL PAST THIS POINT
// WOOO!

/datum/reagent/consumable/ethanol/synthanol
	name = "Синтанол"
	id = "synthanol"
	description = "Текучая жидкость с токопроводящими свойствами. Её воздействие на синтетику аналогично воздействию спирта на органику."
	reagent_state = LIQUID
	color = "#1BB1FF"
	process_flags = ORGANIC | SYNTHETIC
	alcohol_perc = 0.5
	drink_icon = "synthanolglass"
	drink_name = "стакан синтанола"
	drink_desc = "Эквивалент алкоголя для синтетических членов экипажа. Если бы у них были вкусовые рецепторы, они бы сочли его ужасным."
	taste_description = "машинного масла"

/datum/reagent/consumable/ethanol/synthanol/on_mob_life(mob/living/M)
	metabolization_rate = REAGENTS_METABOLISM
	if(!(M.dna.species.reagent_tag & PROCESS_SYN))
		metabolization_rate += 9 * REAGENTS_METABOLISM //gets removed from organics very fast
		if(prob(25))
			metabolization_rate += 40 * REAGENTS_METABOLISM
			M.fakevomit()
	return ..()

/datum/reagent/consumable/ethanol/synthanol/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(M.dna.species.reagent_tag & PROCESS_SYN)
		return
	if(method == REAGENT_INGEST)
		to_chat(M, pick(span_danger("Это отвратительно!"), span_danger("Фу!")))

/datum/reagent/consumable/ethanol/synthanol/robottears
	name = "Слёзы Робота"
	id = "robottears"
	description = "Маслянистая субстанция, которую КПБ технически могут считать \"напитком\"."
	reagent_state = LIQUID
	color = "#363636"
	alcohol_perc = 0.25
	drink_icon = "robottearsglass"
	drink_name = "стакан Слёз Робота"
	drink_desc = "При изготовлении этого напитка ни один робот не пострадал."
	taste_description = "экзистенциальных вопросов"

/datum/reagent/consumable/ethanol/synthanol/trinary
	name = "Тринарный"
	id = "trinary"
	description = "Фруктовый напиток, предназначенный только для синтетиков, как бы это ни звучало."
	reagent_state = LIQUID
	color = "#adb21f"
	alcohol_perc = 0.2
	drink_icon = "trinaryglass"
	drink_name = "стакан Тринарного"
	drink_desc = "Красочный напиток, созданный для синтетических членов экипажа. Не похоже, чтобы он был вкусным."
	taste_description = "машинной логики"

/datum/reagent/consumable/ethanol/synthanol/servo
	name = "Серво"
	id = "servo"
	description = "Напиток, содержащий некоторые органические ингредиенты, но предназначенный только для синтетиков."
	reagent_state = LIQUID
	color = "#5b3210"
	alcohol_perc = 0.25
	drink_icon = "servoglass"
	drink_name = "стакан Серво"
	drink_desc = "Напиток на основе шоколада для КПБ. Врядли кто-то пробовал этот рецепт на вкус."
	taste_description = "машинного масла и шоколада"

/datum/reagent/consumable/ethanol/synthanol/uplink
	name = "Аплинк"
	id = "uplink"
	description = "Сильнодействующая смесь алкоголя и синтанола. Действует только на синтетиков."
	reagent_state = LIQUID
	color = "#e7ae04"
	alcohol_perc = 0.15
	drink_icon = "uplinkglass"
	drink_name = "Аплинк"
	drink_desc = "Сильнодействующая смесь хорошего ликёра и синтанола. Действует только на синтетиков."
	taste_description = "графического интерфейса на Visual Basic"

/datum/reagent/consumable/ethanol/synthanol/synthnsoda
	name = "Синт и Сода"
	id = "synthnsoda"
	description = "Классический напиток, адаптированный под вкусы синтетиков."
	reagent_state = LIQUID
	color = "#7204e7"
	alcohol_perc = 0.25
	drink_icon = "synthnsodaglass"
	drink_name = "стакан Синта и Соды"
	drink_desc = "Классический напиток, адаптированный под вкусы синтетиков. Органикам лучше не пить."
	taste_description = "шипучего моторного масла"

/datum/reagent/consumable/ethanol/synthanol/synthignon
	name = "Синтигон"
	id = "synthignon"
	description = "Кто-то смешал вино и алкоголь для роботов. Надеюсь, он горд собой."
	reagent_state = LIQUID
	color = "#d004e7"
	alcohol_perc = 0.25
	drink_icon = "synthignonglass"
	drink_name = "Синтигон"
	drink_desc = "Кто-то смешал хорошее вино и выпивку для роботов. Романтично, но отвратительно."
	taste_description = "модного моторного масла"

/datum/reagent/consumable/ethanol/fruit_wine
	name = "Фруктовое вино"
	id = "fruit_wine"
	description = "Вино, изготовленное из растений."
	color = "#FFFFFF"
	alcohol_perc = 0.35
	taste_description = "плохого кода"
	can_synth = FALSE
	var/list/names = list("нулевого фрукта" = 1) //Names of the fruits used. Associative list where name is key, value is the percentage of that fruit.
	var/list/tastes = list("плохого кода" = 1) //List of tastes. See above.

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
	var/list/primary_tastes = list()
	var/list/secondary_tastes = list()
	drink_name = "[name]"
	drink_desc = description
	for(var/taste in tastes)
		switch(tastes[taste])
			if(0.3 to INFINITY)
				primary_tastes += taste
			if(0.15 to 0.3)
				secondary_tastes += taste

	var/minimum_name_percent = 0.35
	name = ""
	var/list/names_in_order = sortTim(names, cmp = /proc/cmp_numeric_dsc, associative = TRUE)
	var/named = FALSE
	for(var/fruit_name in names)
		if(names[fruit_name] >= minimum_name_percent)
			name += "[fruit_name] "
			named = TRUE
	if(named)
		name += "вино"
	else
		name = "Смешанное [names_in_order[1]] вино"

	var/alcohol_description
	switch(alcohol_perc)
		if(1.2 to INFINITY)
			alcohol_description = "самоубийственно сильного"
		if(0.9 to 1.2)
			alcohol_description = "очень крепкого"
		if(0.7 to 0.9)
			alcohol_description = "крепкого"
		if(0.4 to 0.7)
			alcohol_description = "насыщенного"
		if(0.2 to 0.4)
			alcohol_description = "мягкого"
		if(0 to 0.2)
			alcohol_description = "сладкого"
		else
			alcohol_description = "водянистого" //How the hell did you get negative boozepwr?

	var/list/fruits = list()
	if(names_in_order.len <= 3)
		fruits = names_in_order
	else
		for(var/i in 1 to 3)
			fruits += names_in_order[i]
		fruits += "других растений"
	var/fruit_list = russian_list(fruits)
	description = "Образец [alcohol_description] вина, приготовленного из [fruit_list]."

	var/flavor = ""
	if(!primary_tastes.len)
		primary_tastes = list("[alcohol_description] алкоголя")
	flavor += russian_list(primary_tastes)
	if(secondary_tastes.len)
		flavor += ", с лёгким привкусом "
		flavor += russian_list(secondary_tastes)
	taste_description = flavor
	if(holder.my_atom)
		holder.my_atom.on_reagent_change()

/datum/reagent/consumable/ethanol/bacchus_blessing //An EXTREMELY powerful drink. Smashed in seconds, dead in minutes.
	name = "Благословение Бахуса"
	id = "bacchus_blessing"
	description = "Неидентифицируемая смесь. Неизмеримо высокое содержание алкоголя."
	color = rgb(51, 19, 3) //Sickly brown
	dizzy_adj = 42 SECONDS
	alcohol_perc = 3 //I warned you
	drink_icon = "bacchusblessing"
	drink_name = "Благословение Бахуса"
	drink_desc = "Даже подумать было невозможно, что напиток может быть настолько отвратительным. Кто-то точно захочет это выпить?"
	taste_description = "стены кирпичей"

/datum/reagent/consumable/ethanol/fernet
	name = "Фернет"
	id = "fernet"
	description = "Невероятно горький травяной ликёр, используемый в качестве дижестива."
	color = "#1B2E24" // rgb: 27, 46, 36
	alcohol_perc = 0.5
	drink_icon = "fernetpuro"
	drink_name = "стакан чистого фернета"
	drink_desc = "Зачем вообще пить это в чистом виде?"
	taste_description = "сильной горечи"
	var/remove_nutrition = 2

/datum/reagent/consumable/ethanol/fernet/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!M.nutrition)
		switch(rand(1, 3))
			if(1)
				to_chat(M, span_warning("Вы чувствуете себя голодным..."))
			if(2)
				update_flags |= M.adjustToxLoss(1, FALSE)
				to_chat(M, span_warning("Ваш желудок болезненно урчит!"))
			else
				pass()
	else
		if(prob(60))
			M.adjust_nutrition(-remove_nutrition)
			M.overeatduration = 0
	return ..() | update_flags

/datum/reagent/consumable/ethanol/fernet/fernet_cola
	name = "Фернет-кола"
	id = "fernet_cola"
	description = "Очень популярный и горьковато-сладкий дижестив, идеальный после плотного обеда. По традиции, его лучше всего подавать в откупоренной бутылке из-под колы."
	color = "#390600" // rgb: 57, 6, 0
	alcohol_perc = 0.2
	drink_icon = "fernetcola"
	drink_name = "стакан фернет-колы"
	drink_desc = "Откупоренная бутылка из-под колы, наполненная фернет-колой. Изнутри слышна музыка куартето."
	taste_description = "рая низкого класса"
	remove_nutrition = 1

/datum/reagent/consumable/ethanol/rainbow_sky
	name = "Радужное Небо"
	id = "rainbow_sky"
	description = "Напиток, переливающийся всеми цветами радуги с примесями космоса."
	color = "#ffffff"
	dizzy_adj = 20 SECONDS
	alcohol_perc = 1.5
	drink_icon = "rainbow_sky"
	drink_name = "Радужное Небо"
	drink_desc = "Напиток, переливающийся всеми цветами радуги с примесями космоса."
	taste_description = "радуги"

/datum/reagent/consumable/ethanol/rainbow_sky/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
	update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	M.Druggy(30 SECONDS)
	M.Jitter(10 SECONDS)
	M.AdjustHallucinate(10 SECONDS)
	M.last_hallucinator_log = name
	return ..() | update_flags

/datum/reagent/consumable/ethanol/champagne
	name = "Шампанское"
	id = "champagne"
	description = "Превосходное игристое шампанское. Для тех, кто хочет выделиться среди винокуров."
	color = "#d0d312"
	alcohol_perc = 0.2
	drink_icon = "champagneglass"
	drink_name = "бокал шампанского"
	drink_desc = "Превосходное игристое шампанское. Для тех, кто хочет выделиться среди винокуров."
	taste_description = "искрящегося солнечного света"

/datum/reagent/consumable/ethanol/aperol
	name = "Апероль"
	id = "aperol"
	description = "О-о-о-о... Похоже, это засада для печени."
	color = "#b9000a"
	alcohol_perc = 0.2
	drink_icon = "aperolglass"
	drink_name = "бокал апероля"
	drink_desc = "О-о-о-о... Похоже, это засада для печени."
	taste_description = "травянистой сладости"

/datum/reagent/consumable/ethanol/jagermeister
	name = "Ягермейстер"
	id = "jagermeister"
	description = "Пьяница-охотник прибыл из далёкого космоса, и, похоже, он нашёл свою жертву."
	color = "#200b0b"
	alcohol_perc = 0.4
	dizzy_adj = 6 SECONDS
	drink_icon = "jagermeisterglass"
	drink_name = "стакан ягермейстера"
	drink_desc = "Пьяница-охотник прибыл из далёкого космоса, и, похоже, он нашёл свою жертву."
	taste_description = "охотничьего азарта"

/datum/reagent/consumable/ethanol/schnaps
	name = "Шнапс"
	id = "schnaps"
	description = "От такого шнапса не грех начать петь йодлем."
	color = "#e0e0e0"
	alcohol_perc = 0.4
	dizzy_adj = 2 SECONDS
	drink_icon = "schnapsglass"
	drink_name = "стакан шнапса"
	drink_desc = "От такого шнапса не грех начать петь йодлем."
	taste_description = "пшеничной мяты"

/datum/reagent/consumable/ethanol/sambuka
	name = "Самбука"
	id = "sambuka"
	description = "Улетая в космос, многие думали, что схватили судьбу"
	color = "#e0e0e0"
	alcohol_perc = 0.45
	dizzy_adj = 2 SECONDS
	drink_icon = "sambukaglass"
	drink_name = "бокал самбуки"
	drink_desc = "Улетая в космос, многие думали, что схватили судьбу"
	taste_description = "вертлявого огня"

/datum/reagent/consumable/ethanol/bluecuracao
	name = "Голубой Кюрасао"
	id = "bluecuracao"
	description = "Запал готов, синий уже загорелся."
	color = "#16c9ff"
	alcohol_perc = 0.35
	drink_icon = "bluecuracaoglass"
	drink_name = "бокал Голубого Кюрасао"
	drink_desc = "Запал готов, синий уже загорелся."
	taste_description = "взрывной голубизны"

/datum/reagent/consumable/ethanol/bitter
	name = "Биттер"
	id = "bitter"
	description = "Не перепутай размеры этикеток, ведь я ничего менять не буду."
	color = "#d44071"
	alcohol_perc = 0.45
	dizzy_adj = 4 SECONDS
	drink_icon = "bitterglass"
	drink_name = "стакан биттера"
	drink_desc = "Не перепутай размеры этикеток, ведь я ничего менять не буду."
	taste_description = "вакуумной горечи"

/datum/reagent/consumable/ethanol/sheridan
	name = "Шериданс"
	id = "sheridan"
	description = "Охладите, разлейте под углом 45°, не перемешивайте, наслаждайтесь."
	color = "#3a3d2e"
	alcohol_perc = 0.35
	drink_icon = "sheridanglass"
	drink_name = "стакан Шериданса"
	drink_desc = "Охладите, разлейте под углом 45°, не перемешивайте, наслаждайтесь."
	taste_description = "шоколадно-кремового алкоголя"

////////////////////////////Cocktails///////////////////////////////
/datum/reagent/consumable/ethanol/black_blood
	name = "Чёрная Кровь"
	id = "black_blood"
	description = "Пить нужно быстрее, пока оно не начало сворачиваться."
	color = "#252521"
	alcohol_perc = 0.45
	drink_icon = "black_blood"
	drink_name = "Чёрная Кровь"
	drink_desc = "Пить нужно быстрее, пока оно не начало сворачиваться."
	taste_description = "кровавой тьмы"

/datum/reagent/consumable/ethanol/black_blood/reaction_mob(mob/living/M, method, volume)
	. = ..()
	if(prob(50))
		M.say(pick("Фуу ма'джин!", "Сас'со к'арта форбичи!", \
		 "Та'гх фара'кха фель де'амар дет!", "Кла'ату барада никт'o!", \
		  "Фел'т Дол Аб'ород!", "Ин'тотум Лиг'абис!", "Этра п'ни дедоль!", \
		   "Дитанс Гут'ура Инпульса!", "О бидай набора се'сма!"))

/datum/reagent/consumable/ethanol/light_storm
	name = "Лёгкий Шторм"
	id = "light_storm"
	description = "Даже вдали от океана вы можете почувствовать эту дрожь."
	color = "#4b4b44"
	alcohol_perc = 0.6
	drink_icon = "light_storm"
	drink_name = "стакан Лёгкого Шторма"
	drink_desc = "Даже вдали от океана вы можете почувствовать эту дрожь."
	taste_description = "морских волнений"

/datum/reagent/consumable/ethanol/cream_heaven
	name = "Кремовый Рай"
	id = "cream_heaven"
	description = "Это сочетание сливок и кофе, настоящее небесное творение."
	color = "#4b4b44"
	alcohol_perc = 0.25
	drink_icon = "cream_heaven"
	drink_name = "Кремовый Рай"
	drink_desc = "Это сочетание сливок и кофе, настоящее небесное творение."
	taste_description = "кофейных облачков"

/datum/reagent/consumable/ethanol/negroni
	name = "Негрони"
	id = "negroni"
	description = "Горькие напитки очень полезны для печени, а джин плохо влияет на организм. Здесь они уравновешивают друг друга."
	color = "#ad3948"
	alcohol_perc = 0.4
	drink_icon = "negroni"
	drink_name = "Негрони"
	drink_desc = "Горькие напитки очень полезны для печени, а джин плохо влияет на организм. Здесь они уравновешивают друг друга."
	taste_description = "сладкого шествия"

/datum/reagent/consumable/ethanol/hirosima
	name = "Хиросима"
	id = "hirosima"
	description = "Мои руки по локоть в крови... О, подождите, это алкоголь."
	color = "#598317"
	alcohol_perc = 0.3
	drink_icon = "hirosima"
	drink_name = "Хиросима"
	drink_desc = "Мои руки по локоть в крови... О, подождите, это алкоголь."
	taste_description = "алкогольного пепла"

/datum/reagent/consumable/ethanol/nagasaki
	name = "Нагасаки"
	id = "nagasaki"
	description = "Сначала никто не знал, что произойдет дальше. Опьянение было ужасным. Нет сомнений, что это самое сильное опьянение, которое когда-либо испытывал человек."
	color = "#18c212"
	alcohol_perc = 0.7
	drink_icon = "nagasaki"
	drink_name = "Нагасаки"
	drink_desc = "Сначала никто не знал, что произойдет дальше. Опьянение было ужасным. Нет сомнений, что это самое сильное опьянение, которое когда-либо испытывал человек."
	taste_description = "радиоактивного пепла"

/datum/reagent/consumable/ethanol/chocolate_sheridan
	name = "Шоколадный Шериданс"
	id = "chocolate_sheridan"
	description = "В ситуациях, когда действительно хочется взбодриться и выпить."
	color = "#332a1a"
	alcohol_perc = 0.3
	drink_icon = "chocolate_sheridan"
	drink_name = "стакан Шоколадного Шериданса"
	drink_desc = "В ситуациях, когда действительно хочется взбодриться и выпить."
	taste_description = "алкогольного мокко"

/datum/reagent/consumable/ethanol/panamian
	name = "Панама"
	id = "panamian"
	description = "Это соединит вашу кровь и алкоголь, прямо как Катунские врата."
	color = "#3164a7"
	alcohol_perc = 0.6
	drink_icon = "panamian"
	drink_name = "стакан Панамы"
	drink_desc = "Это соединит вашу кровь и алкоголь, прямо как Катунские врата."
	taste_description = "судоходного канала"

/datum/reagent/consumable/ethanol/pegu_club
	name = "Клуб Пегу"
	id = "pegu_club"
	description = "Это похоже на группу джентльменов, колонизирующих ваш язык."
	color = "#a5702b"
	alcohol_perc = 0.5
	drink_icon = "pegu_club"
	drink_name = "Клуб Пегу"
	drink_desc = "Это похоже на группу джентльменов, колонизирующих ваш язык."
	taste_description = "судоходного канала"

/datum/reagent/consumable/ethanol/jagermachine
	name = "Ягермашина"
	id = "jagermachine"
	description = "Настоящий охотник за деталями."
	color = "#6b0b74"
	alcohol_perc = 0.55
	drink_icon = "jagermachine"
	drink_name = "Ягермашина"
	drink_desc = "Настоящий охотник за деталями."
	taste_description = "воровства деталей"

/datum/reagent/consumable/ethanol/blue_cybesauo
	name = "Голубой Киберсауо"
	id = "blue_cybesauo"
	description = "Синева, похожая на синий экран смерти."
	color = "#0b7463"
	alcohol_perc = 0.4
	drink_icon = "blue_cybesauo"
	drink_name = "Голубой Киберсауо"
	drink_desc = "Синева, похожая на синий экран смерти."
	taste_description = "ошибки 0xc000001b"

/datum/reagent/consumable/ethanol/alcomender
	name = "Алко-мендер"
	id = "alcomender"
	description = "Кружка в форме авто-мендера, популярен среди докторов."
	color = "#6b0059"
	alcohol_perc = 1.4 ////Heal burn
	drink_icon = "alcomender"
	drink_name = "Алко-мендер"
	drink_desc = "Кружка в форме авто-мендера, популярен среди докторов."
	taste_description = "весёлой медицины"

/datum/reagent/consumable/ethanol/alcomender/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(-0.7, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/alcomender/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) // It is alcohol after all, so don't try to pour it on someone who's on fire ... please.
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			M.adjustFireLoss(-volume * 0.7, affect_robotic = FALSE)
			to_chat(M, span_notice("Разбавленный сульфадиазин серебра исцеляет ваши ожоги."))
	return STATUS_UPDATE_NONE

/datum/reagent/consumable/ethanol/amnesia
	name = "Звёздная Амнезия"
	id = "amnesia"
	description = "Стоп, это бутылка медицинского спирта?"
	color = "#6b0059"
	alcohol_perc = 1.2 ////Ethanol and Hooch
	drink_icon = "amnesia"
	drink_name = "Звёздная Амнезия"
	drink_desc = "Стоп, это бутылка медицинского спирта?"
	taste_description = "диско"

/datum/reagent/consumable/ethanol/johnny
	name = "Сильверхэнд"
	id = "johnny"
	description = "Просыпайся, самурай. Нам нужно сжечь одну станцию."
	color = "#c41414"
	alcohol_perc = 0.6
	drink_icon = "johnny"
	drink_name = "Сильверхэнд"
	drink_desc = "Просыпайся, самурай. Нам нужно сжечь одну станцию."
	taste_description = "угасающей суперзвезды"

/datum/reagent/consumable/ethanol/cosmospoliten
	name = "Космополитен"
	id = "cosmospoliten"
	description = "А теперь попробуй доказать, что ты натурал и не женщина, если тебя застукают с ним."
	color = "#b1483a"
	alcohol_perc = 0.5
	drink_icon = "cosmospoliten"
	drink_name = "Космополитен"
	drink_desc = "А теперь попробуй доказать, что ты натурал и не женщина, если тебя застукают с ним."
	taste_description = "изменения ориентации"

/datum/reagent/consumable/ethanol/oldfashion
	name = "Старая мода"
	id = "oldfashion"
	description = "Ходят слухи, что этот коктейль является самым старым из всех, но, впрочем, это совсем другая история."
	color = "#6b4017"
	alcohol_perc = 0.6
	drink_icon = "oldfashion"
	drink_name = "Старая мода"
	drink_desc = "Ходят слухи, что этот коктейль является самым старым из всех, но, впрочем, это совсем другая история."
	taste_description = "старых добрых времён"

/datum/reagent/consumable/ethanol/french_75
	name = "Французский 75"
	id = "french_75"
	description = "Заряжай печень, целься, стреляй!"
	color = "#b1953a"
	alcohol_perc = 0.4
	drink_icon = "french_75"
	drink_name = "Французский 75"
	drink_desc = "Заряжай печень, целься, стреляй!"
	taste_description = "артиллерийского обстрела"

/datum/reagent/consumable/ethanol/gydroseridan
	name = "Гидрориданс"
	id = "gydroseridan"
	description = "Гидравлическое разделение слоёв поможет нам повысить эффективность."
	color = "#3a99b1"
	alcohol_perc = 0.5
	drink_icon = "gydroseridan"
	drink_name = "Гидрориданс"
	drink_desc = "Гидравлическое разделение слоёв поможет нам повысить эффективность."
	taste_description = "мощи гидравлики"

/datum/reagent/consumable/ethanol/milk_plus
	name = "Молоко +"
	id = "milk_plus"
	description = "Когда человек не может выбирать, он перестаёт быть человеком."
	color = "#DFDFDF"
	alcohol_perc = 0.8
	drink_icon = "milk_plus"
	drink_name = "Молоко +"
	drink_desc = "Когда человек не может выбирать, он перестаёт быть человеком."
	taste_description = "человеческой потери"

/datum/reagent/consumable/ethanol/teslasingylo
	name = "Бог Энергии"
	id = "teslasingylo"
	description = "Настоящий ужас для СКАН'ов и ЛКП. Не перегружайте их."
	color = "#0300ce"
	alcohol_perc = 0.7
	process_flags = SYNTHETIC
	drink_icon = "teslasingylo"
	drink_name = "Бог Энергии"
	drink_desc = "Настоящий ужас для СКАН'ов и ЛКП. Не перегружайте их."
	taste_description = "электрического благословления"

/datum/reagent/consumable/ethanol/teslasingylo/on_mob_life(mob/living/M)
	. = ..()
	if(ismachineperson(M))
		var/mob/living/carbon/human/machine/machine = M
		if(machine.nutrition > NUTRITION_LEVEL_WELL_FED) //no fat machines, sorry
			return
		machine.adjust_nutrition(15) //much less than charging from APC (50)

/datum/reagent/consumable/ethanol/light
	name = "Свет"
	id = "light"
	description = "Любимый напиток ниан и дион. Кто-то скажет, что это мини-термоядерная реакция, но только тссс..."
	color = "#fffb00"
	alcohol_perc = 0.2
	drink_icon = "light"
	drink_name = "Свет"
	drink_desc = "Любимый напиток ниан и дион. Кто-то скажет, что это мини-термоядерная реакция, но только тссс..."
	taste_description = "звёздного света"

/datum/reagent/consumable/ethanol/light/on_mob_life(mob/living/M)
	. = ..()
	if(M.lighting_alpha < LIGHTING_PLANE_ALPHA_NV_TRAIT)
		return
	M.lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
	if(volume < 0.4)
		M.lighting_alpha = initial(M.lighting_alpha)

/datum/reagent/consumable/ethanol/bees_knees
	name = "Пчелиные Колени"
	id = "bees_knees"
	description = "Как будто бы дело в том, что пчела переносит пыльцу в области коленей и... Не берите в голову."
	color = "#e8f71f"
	alcohol_perc = 0.5
	drink_icon = "bees_knees"
	drink_name = "Пчелиные Колени"
	drink_desc = "Как будто бы дело в том, что пчела переносит пыльцу в области коленей и... Не берите в голову."
	taste_description = "любви к мёду"

/datum/reagent/consumable/ethanol/aviation
	name = "Авиация"
	id = "aviation"
	description = "Трудно готовить коктейли, когда над твоим домом пролетает дирижабль."
	color = "#c48f8f"
	alcohol_perc = 0.5
	drink_icon = "aviation"
	drink_name = "Авиация"
	drink_desc = "Трудно готовить коктейли, когда над твоим домом пролетает дирижабль."
	taste_description = "сильного ветра"

/datum/reagent/consumable/ethanol/fizz
	name = "Физз"
	id = "fizz"
	description = "Это всё равно, что жить с дикой кошкой."
	color = "#b6b6b6"
	alcohol_perc = 0.3
	drink_icon = "fizz"
	drink_name = "Физз"
	drink_desc = "Это всё равно, что жить с дикой кошкой."
	taste_description = "шипучего алкоголя"

/datum/reagent/consumable/ethanol/brandy_crusta
	name = "Коньячная Корочка"
	id = "brandy_crusta"
	description = "Сахарная корочка может быть совсем не сладкой."
	color = "#754609"
	alcohol_perc = 0.4
	drink_icon = "brandy_crusta"
	drink_name = "Коньячная Корочка"
	drink_desc = "Сахарная корочка может быть совсем не сладкой."
	taste_description = "солёно-сладкого алкоголя"

/datum/reagent/consumable/ethanol/aperolspritz
	name = "Апероль Спритц"
	id = "aperolspritz"
	description = "Многие считают его отдельным видом алкоголя, но он больше похож на коня в шахматах."
	color = "#c43d3d"
	alcohol_perc = 0.5
	drink_icon = "aperolspritz"
	drink_name = "Апероль Спритц"
	drink_desc = "Многие считают его отдельным видом алкоголя, но он больше похож на коня в шахматах."
	taste_description = "раздельности вкусов"

/datum/reagent/consumable/ethanol/sidecar
	name = "Коляска"
	id = "sidecar"
	description = "Этот коктейль очень популярен. Впервые его представил популярный бармен Этот МакГарри из Клуба Бака."
	color = "#b15416"
	alcohol_perc = 0.4
	drink_icon = "sidecar"
	drink_name = "Коляска"
	drink_desc = "Этот коктейль очень популярен. Впервые его представил популярный бармен Этот МакГарри из Клуба Бака."
	taste_description = "апельсинового алкоголя"

/datum/reagent/consumable/ethanol/daiquiri
	name = "Дайкири"
	id = "daiquiri"
	description = "Просто попробуй, попробуй ещё раз!"
	color = "#b6b6b6"
	alcohol_perc = 0.4
	drink_icon = "daiquiri"
	drink_name = "Дайкири"
	drink_desc = "Просто попробуй, попробуй ещё раз!"
	taste_description = "выстрела в голову"

/datum/reagent/consumable/ethanol/tuxedo
	name = "Смокинг"
	id = "tuxedo"
	description = "Я могу пообещать вам Колумбийский Галстук."
	color = "#888686"
	alcohol_perc = 0.5
	drink_icon = "tuxedo"
	drink_name = "Смокинг"
	drink_desc = "Я могу пообещать вам Колумбийский Галстук."
	taste_description = "строгости стиля"

/datum/reagent/consumable/ethanol/telegol
	name = "Телеголь"
	id = "telegol"
	description = "Многие до сих пор ломают голову над вопросом существования этого коктейля. Как бы то ни было, он всё ещё существует... Или нет."
	color = "#4218a3"
	alcohol_perc = 0.5
	drink_icon = "telegol"
	drink_name = "Телеголь"
	drink_desc = "Многие до сих пор ломают голову над вопросом существования этого коктейля. Как бы то ни было, он всё ещё существует... Или нет."
	taste_description = "четырнадцатого измерения"

/datum/reagent/consumable/ethanol/horse_neck
	name = "Лошадиная Шея"
	id = "horse_neck"
	description = "Будьте осторожны с подковами вашей лошади."
	color = "#c45d09"
	alcohol_perc = 0.5
	drink_icon = "horse_neck"
	drink_name = "Лошадиная Шея"
	drink_desc = "Будьте осторожны с подковами вашей лошади."
	taste_description = "лошадиной силы"

/datum/reagent/consumable/ethanol/horse_neck/reaction_mob(mob/living/M, method, volume)
	. = ..()
	if(prob(50))
		M.say(pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!"))

/datum/reagent/consumable/ethanol/cuban_sunset
	name = "Кубинский Закат"
	id = "cuban_sunset"
	description = "Новый день, новая революция."
	color = "#d88948"
	alcohol_perc = 0.6
	drink_icon = "cuban_sunset"
	drink_name = "Кубинский Закат"
	drink_desc = "Новый день, новая революция."
	taste_description = "тоталитаризма"

/datum/reagent/consumable/ethanol/sake_bomb
	name = "Бомба Сакэ"
	id = "sake_bomb"
	description = "Ковровая бомбардировка вашей бамбуковой печени."
	color = "#e2df2e"
	alcohol_perc = 0.3
	drink_icon = "sake_bomb"
	drink_name = "Бомба Сакэ"
	drink_desc = "Ковровая бомбардировка вашей бамбуковой печени."
	taste_description = "пива и саке"

/datum/reagent/consumable/ethanol/blue_havai
	name = "Голубые Гавайи"
	id = "blue_havai"
	description = "Такой же голубой, как и карие глаза."
	color = "#296129"
	alcohol_perc = 0.2
	drink_icon = "blue_havai"
	drink_name = "Голубые Гавайи"
	drink_desc = "Такой же голубой, как и карие глаза."
	taste_description = "неонового рассвета"

/datum/reagent/consumable/ethanol/woo_woo
	name = "Ву-Ву"
	id = "woo_woo"
	description = "Какой ребёнок придумал это имя? Да, я вижу, вопрос решён."
	color = "#e22e2e"
	alcohol_perc = 0.5
	drink_icon = "woo_woo"
	drink_name = "Ву-Ву"
	drink_desc = "Какой ребёнок придумал это имя? Да, я вижу, вопрос решён."
	taste_description = "ву-ву"

/datum/reagent/consumable/ethanol/mulled_wine
	name = "Глинтвейн"
	id = "mulled_wine"
	description = "Просто горячее вино со специями, но такое приятное."
	color = "#fd4b4b"
	alcohol_perc = 0.2
	drink_icon = "mulled_wine"
	drink_name = "Глинтвейн"
	drink_desc = "Просто горячее вино со специями, но такое приятное."
	taste_description = "горячего пряного вина"

/datum/reagent/consumable/ethanol/white_bear
	name = "Белый Медведь"
	id = "white_bear"
	description = "Два исторических врага в одном кругу."
	color = "#d8b465"
	alcohol_perc = 0.5
	drink_icon = "white_bear"
	drink_name = "Белый Медведь"
	drink_desc = "Два исторических врага в одном кругу."
	taste_description = "войны идеологий"

/datum/reagent/consumable/ethanol/vampiro
	name = "Вампиро"
	id = "vampiro"
	description = "Не имеет ничего общего с вампирами кроме цвета."
	color = "#8d0000"
	alcohol_perc = 0.45
	drink_icon = "vampiro"
	drink_name = "Вампиро"
	drink_desc = "Не имеет ничего общего с вампирами кроме цвета."
	taste_description = "истощения"

/datum/reagent/consumable/ethanol/vampiro/on_mob_life(mob/living/M)
	. = ..()
	if(volume > 20)
		if(prob(50)) //no spam here :p
			M.visible_message(span_warning("Глаза [M] ослепительно вспыхивают!"))

/datum/reagent/consumable/ethanol/queen_mary
	name = "Королева Мария"
	id = "queen_mary"
	description = "Мария очистилась от крови, и оказалось, что она тоже красная."
	color = "#bd2f2f"
	alcohol_perc = 0.35
	drink_icon = "queen_mary"
	drink_name = "Королева Мария"
	drink_desc = "Мария очистилась от крови, и оказалось, что она тоже красная."
	taste_description = "вишнёвого пива"

/datum/reagent/consumable/ethanol/inabox
	name = "Коробка"
	id = "inabox"
	description = "Это... Просто коробка?"
	color = "#5a3e0b"
	alcohol_perc = 0.4
	drink_icon = "inabox"
	drink_name = "Коробка"
	drink_desc = "Это... Просто коробка?"
	taste_description = "стелса"

/datum/reagent/consumable/ethanol/beer_berry_royal
	name = "Пиво Королевской Вишни"
	id = "beer_berry_royal"
	description = "По какой-то причине они продолжают подниматься и опускаться, вверх и вниз."
	color = "#684b16"
	alcohol_perc = 0.25
	drink_icon = "beer_berry_royal"
	drink_name = "Пиво Королевской Вишни"
	drink_desc = "По какой-то причине они продолжают подниматься и опускаться, вверх и вниз."
	taste_description = "ягодного пива"

/datum/reagent/consumable/ethanol/sazerac
	name = "Сазерак"
	id = "sazerac"
	description = "Лучшие фармацевты - бармены."
	color = "#7c6232"
	alcohol_perc = 0.4
	drink_icon = "sazerac"
	drink_name = "Сазерак"
	drink_desc = "Лучшие фармацевты - бармены."
	taste_description = "горького виски"

/datum/reagent/consumable/ethanol/monako
	name = "Монако"
	id = "monako"
	description = "Вы можете подумать, что на рынке больше фруктов."
	color = "#7c6232"
	alcohol_perc = 0.5
	drink_icon = "monako"
	drink_name = "Монако"
	drink_desc = "Вы можете подумать, что на рынке больше фруктов."
	taste_description = "фруктового джина"

/datum/reagent/consumable/ethanol/irishempbomb
	name = "Ирландская ЭМИ-бомба"
	id = "irishempbomb"
	description = "Ммм, на вкус как отключение..."
	color = "#123eb8"
	process_flags = SYNTHETIC
	alcohol_perc = 0.6
	drink_icon = "irishempbomb"
	drink_name = "Ирландская ЭМИ-бомба"
	drink_desc = "Ммм, на вкус как отключение..."
	taste_description = "электромагнитного импульса"

/datum/reagent/consumable/ethanol/irishempbomb/on_mob_life(mob/living/M)
	M.Stun(1, FALSE)
	do_sparks(5, FALSE, M.loc)
	return ..()

/datum/reagent/consumable/ethanol/codelibre
	name = "Коде Либре"
	id = "codelibre"
	description = "За Коде Либре!"
	color = "#a126b1"
	alcohol_perc = 0.55
	process_flags = SYNTHETIC
	drink_icon = "codelibre"
	drink_name = "Коде Либре"
	drink_desc = "За Code libre!"
	taste_description = "свободы кода"

/datum/reagent/consumable/ethanol/codelibre/on_mob_life(mob/living/M)
	. = ..()
	if(prob(10))
		M.say("[get_language_prefix(LANGUAGE_TRINARY)] Вива ла Синтетика!")

/datum/reagent/consumable/ethanol/blackicp
	name = "Чёрный КПБ"
	id = "blackicp"
	description = "Извините за игнорирование вопроса, можете повторить запрос?"
	color = "#a126b1"
	alcohol_perc = 0.5
	drink_icon = "blackicp"
	drink_name = "Чёрный КПБ"
	drink_desc = "Извините за игнорирование вопроса, можете повторить запрос?"
	taste_description = "замены монитора"

/datum/reagent/consumable/ethanol/slime_drink
	name = "Пьяный Слайм"
	id = "slime_drink"
	description = "Не волнуйтесь, это просто желе."
	color = "#dd3e32"
	alcohol_perc = 0.2
	drink_icon = "slime_drink"
	drink_name = "Пьяный Слайм"
	drink_desc = "Не волнуйтесь, это просто желе. А слайм уже давно мёртв."
	taste_description = "желейного алкоголя"

/datum/reagent/consumable/ethanol/innocent_erp
	name = "Невинное ЕРП"
	id = "innocent_erp"
	description = "Большой Брат следит за тобой."
	color = "#746463"
	alcohol_perc = 0.5
	drink_icon = "innocent_erp"
	drink_name = "Невинное ЕРП"
	drink_desc = "Большой Брат следит за тобой."
	taste_description = "запретных желаний"

/datum/reagent/consumable/ethanol/nasty_slush
	name = "Мерзкая Слякоть"
	id = "nasty_slush"
	description = "Название не имеет никакого отношения к самому напитку."
	color = "#462c0a"
	alcohol_perc = 0.55
	drink_icon = "nasty_slush"
	drink_name = "Мерзкая Слякоть"
	drink_desc = "Название не имеет никакого отношения к самому напитку."
	taste_description = "мерзкой слякоти"

/datum/reagent/consumable/ethanol/blue_lagoon
	name = "Голубая Лагуна"
	id = "blue_lagoon"
	description = "Что может быть лучше, чем отдых на пляже с хорошим напитком?"
	color = "#1edddd"
	alcohol_perc = 0.5
	drink_icon = "blue_lagoon"
	drink_name = "Голубая Лагуна"
	drink_desc = "Что может быть лучше, чем отдых на пляже с хорошим напитком?"
	taste_description = "пляжного отдыха"

/datum/reagent/consumable/ethanol/green_fairy
	name = "Зелёная Фея"
	id = "green_fairy"
	description = "Какой-то ненормальный зелёный."
	color = "#54dd1e"
	alcohol_perc = 0.6
	drink_icon = "green_fairy"
	drink_name = "Зелёная Фея"
	drink_desc = "Какой-то ненормальный зелёный."
	taste_description = "веры в фей"

/datum/reagent/consumable/ethanol/green_fairy/on_mob_life(mob/living/M)
	M.SetDruggy(min(max(0, M.AmountDruggy() + 10 SECONDS), 15 SECONDS))
	return ..()

/datum/reagent/consumable/ethanol/home_lebovsky
	name = "Домашний Лебовски"
	id = "home_lebovsky"
	description = "Позволь мне кое-что тебе объяснить. Я не Домашний Лебовски. Иы Домашний Лебовски. Я Чувак."
	color = "#422b00"
	alcohol_perc = 0.35
	drink_icon = "home_lebovsky"
	drink_name = "Домашний Лебовски"
	drink_desc = "Позволь мне кое-что тебе объяснить. Я не Домашний Лебовски. Ты Домашний Лебовски. Я Чувак."
	taste_description = "dressing gown"

/datum/reagent/consumable/ethanol/top_billing
	name = "Топ Биллинг"
	id = "top_billing"
	description = "На видном месте, наша главная заслуга!"
	color = "#0b573d"
	alcohol_perc = 0.4
	drink_icon = "top_billing"
	drink_name = "Топ Биллинг"
	drink_desc = "На видном месте, наша главная заслуга!"
	taste_description = "рекламного пространства"

/datum/reagent/consumable/ethanol/trans_siberian_express
	name = "Транссибирский экспресс"
	id = "trans_siberian_express"
	description = "От Владивостока до белой горячки за один день."
	color = "#e2a600"
	alcohol_perc = 0.5
	drink_icon = "trans_siberian_express"
	drink_name = "Транссибирский экспресс"
	drink_desc = "От Владивостока до белой горячки за один день."
	taste_description = "ужасной инфрастуктуры"

/datum/reagent/consumable/ethanol/trans_siberian_express/on_mob_life(mob/living/M)
	. = ..()
	var/datum/language/rus_lang = GLOB.all_languages[LANGUAGE_NEO_RUSSIAN]
	if(LAZYIN(M.languages, rus_lang) && !LAZYIN(M.temporary_languages, rus_lang))
		if(M.default_language != rus_lang)
			M.default_language = rus_lang
		if(volume < 0.4)
			M.default_language = null //reset language we were speaking
		return
	else
		if(!LAZYIN(M.languages, rus_lang))
			LAZYADD(M.temporary_languages, rus_lang)
			LAZYADD(M.languages, rus_lang)
			M.default_language = rus_lang
		if(volume < 0.4)
			M.languages ^= M.temporary_languages
			LAZYREMOVE(M.temporary_languages, rus_lang)
			M.default_language = null

/datum/reagent/consumable/ethanol/sun
	name = "Солнце"
	id = "sun"
	description = "Red sun over paradise!"
	color = "#bd1c1c"
	alcohol_perc = 0.4
	drink_icon = "sun"
	drink_name = "Солнце"
	drink_desc = "Red sun over paradise!"
	taste_description = "солнечной жары"

/datum/reagent/consumable/ethanol/tick_tack
	name = "Тик-Ток"
	id = "tick_tack"
	description = "Тик-Ток, Тик-Ток, бззз..."
	color = "#118020"
	alcohol_perc = 0.3
	drink_icon = "tick_tack"
	drink_name = "Тик-Ток"
	drink_desc = "Тик-Ток, Тик-Ток, бззз..."
	taste_description = "тиканья часов"

/datum/reagent/consumable/ethanol/uragan_shot
	name = "Ураганный Выстрел"
	id = "uragan_shot"
	description = "Это ураган? Нет, это урагон."
	color = "#da6631"
	alcohol_perc = 0.35
	drink_icon = "uragan_shot"
	drink_name = "Ураганный Выстрел"
	drink_desc = "Это ураган? Нет, это урагон."
	taste_description = "порывов ветра"

/datum/reagent/consumable/ethanol/new_yorker
	name = "Нью-Йоркер"
	id = "new_yorker"
	description = "Будьте осторожны с биржей, иначе наступит \"чёрный вторник\"."
	color = "#da3131"
	alcohol_perc = 0.4
	drink_icon = "new_yorker"
	drink_name = "Нью-Йоркер"
	drink_desc = "Будьте осторожны с биржей, иначе наступит \"чёрный вторник\"."
	taste_description = "катастрофы"

/datum/reagent/consumable/ethanol/blue_moondrin
	name = "Илукский Синий Мун`дрин"
	id = "blue_moondrin"
	description = "Редчайший таяранский напиток в галактике! Будьте осторожны с вашим капитаном!"
	color = "#0026fc"
	alcohol_perc = 0.7
	addiction_chance = 4
	drink_icon = "blue_moondrin"
	drink_name = "Илукский Синий Мун`дрин"
	drink_desc = "Редчайший таяранский напиток в галактике! Будьте осторожны с вашим капитаном!"
	taste_description = "синего выключения"

/datum/reagent/consumable/ethanol/blue_moondrin/on_mob_life(mob/living/M)
	M.Druggy(30 SECONDS, FALSE)
	switch(current_cycle)
		if(1 to 15)
			M.Dizzy(10 SECONDS)
			if(prob(20))
				M.emote(pick("twitch","giggle","moan"))
				M.Jitter(20 SECONDS)
		if(16 to 24)
			if(prob(15))
				M.Dizzy(10 SECONDS)
				M.playsound_local(src, 'sound/spookoween/ghost_whisper.ogg', 3)
				M.emote(pick("twitch","giggle"))
				M.Jitter(20 SECONDS)
				M.AdjustHallucinate(20 SECONDS)
		if(25 to INFINITY)
			if(prob(10))
				M.Dizzy(20 SECONDS)
				M.playsound_local(src,'sound/hallucinations/veryfar_noise.ogg', 1)
				M.Jitter(20 SECONDS)
				M.AdjustHallucinate(30 SECONDS)
				M.emote("moan")
	return ..()

/datum/reagent/consumable/ethanol/red_moondrin
	name = "Красноводный Мун`дрин"
	id = "red_moondrin"
	description = "Запрещённый на Адомае таяранский напиток, но не здесь! Опасное пойло на основе лун'дрина с тайным ингридиентом. Будьте осторожны!"
	color = "#960202"
	alcohol_perc = 0.9
	addiction_chance = 7
	drink_icon = "red_moondrin"
	drink_name = "Красноводный Мун`дрин"
	drink_desc = "Запрещённый на Адомае таяранский напиток, но не здесь! Опасное пойло на основе лун'дрина с тайным ингридиентом. Будьте осторожны!"
	taste_description = "приятного, но болезненного ощущения в желудке"

/datum/reagent/consumable/ethanol/red_moondrin/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.Druggy(30 SECONDS)
	switch(current_cycle)
		if(1 to 20)
			M.Dizzy(20 SECONDS)
			M.Stuttering(10 SECONDS)
			if(prob(30))
				M.emote(pick("twitch","moan"))
				M.Jitter(20 SECONDS)
				M.AdjustHallucinate(30 SECONDS)
			if(prob(10))
				M.playsound_local(src,'sound/hallucinations/im_here1.ogg', 1)
		if(21 to 30)
			M.Dizzy(10 SECONDS)
			M.Stuttering(10 SECONDS)
			M.playsound_local(src, 'sound/effects/heartbeat.ogg', 1)
			if(prob(20))
				to_chat(M, span_warning("Вы чувствуете себя странно..."))
				M.emote("scream")
				M.playsound_local(src, 'sound/spookoween/ghost_whisper.ogg', 5)
				M.AdjustHallucinate(40 SECONDS)
				update_flags |= M.adjustStaminaLoss(3, FALSE)
			if(prob(5))
				M.playsound_local(src,'sound/hallucinations/look_up1.ogg', 1)
				M.emote("gasp")
				to_chat(M, span_warning("Вы не можете дышать! Но это так приятно!"))
				update_flags |= M.adjustOxyLoss(15, FALSE)
				update_flags |= M.adjustToxLoss(2, FALSE)
				M.Stun(2 SECONDS)
		if(31 to INFINITY)
			M.playsound_local(src, 'sound/effects/heartbeat.ogg', 2)
			M.Dizzy(20 SECONDS)
			M.Stuttering(20 SECONDS)
			if(prob(30))
				M.playsound_local(src, 'sound/effects/heartbeat.ogg', 2)
				M.emote(pick("twitch","moan"))
				M.Jitter(20 SECONDS)
				M.AdjustHallucinate(30 SECONDS)
				M.playsound_local(src,'sound/hallucinations/i_see_you2.ogg', 1)
			if(prob(20))
				to_chat(M, span_warning("Вам больно!"))
				M.emote("scream")
				M.playsound_local(src, 'sound/spookoween/ghost_whisper.ogg', 5)
				M.AdjustHallucinate(40 SECONDS)
				update_flags |= M.adjustStaminaLoss(10, FALSE)
			if(prob(5))
				M.playsound_local(src, 'sound/effects/heartbeat.ogg', 2)
				M.playsound_local(src,'sound/hallucinations/growl1.ogg', 1)
				M.emote("gasp")
				to_chat(M, span_warning("Вы не можете дышать! Но это так приятно!"))
				update_flags |= M.adjustOxyLoss(15, FALSE)
				update_flags |= M.adjustToxLoss(2, FALSE)
				M.Stun(2 SECONDS)
			if(prob(3))
				M.playsound_local(src, 'sound/effects/heartbeat.ogg', 2)
				to_chat(M, span_warning("Вам кажется, что вас кто-то преследует!"))
				M.playsound_local(src,'sound/hallucinations/growl2.ogg', 1)
				M.emote(pick("drool","scream"))
				M.Jitter(20 SECONDS)
				update_flags |= M.adjustToxLoss(3, FALSE)
				M.Weaken(2 SECONDS)
				M.AdjustConfused(66 SECONDS)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/synthanol/restart
	name = "Перезагрузка"
	id = "restart"
	description = "Иногда нужно начать всё сначала."
	color = "#0026fc"
	reagent_state = LIQUID
	process_flags = SYNTHETIC
	alcohol_perc = 1.5
	drink_icon = "restart"
	drink_name = "Перезагрузка"
	drink_desc = "Иногда нужно начать всё сначала."
	taste_description = "перезагрузки"

/datum/reagent/consumable/ethanol/synthanol/restart/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(5 to 13)
			M.Jitter(40 SECONDS)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
			if(prob(5))
				to_chat(M, span_notice("Перезагрузка системы..."))
		if(14)
			playsound(get_turf(M),'sound/effects/restart-shutdown.ogg', 200, 1)
		if(15 to 23)
			M.Weaken(10 SECONDS)
			update_flags |= M.adjustBruteLoss(-0.3, FALSE, affect_robotic = TRUE)
			update_flags |= M.adjustFireLoss(-0.3, FALSE, affect_robotic = TRUE)
			M.SetSleeping(20 SECONDS)
		if(24)
			playsound(get_turf(M), 'sound/effects/restart-wakeup.ogg', 200, 1)
		if(25)
			M.SetStunned(0)
			M.SetWeakened(0)
			M.SetKnockdown(0)
			M.SetParalysis(0)
			M.SetSleeping(0)
			M.SetDrowsy(0)
			M.SetSlur(0)
			M.SetDrunk(0)
			M.SetJitter(0)
			M.SetDizzy(0)
			M.SetDruggy(0)
			M.set_resting(FALSE, instant = TRUE)
			M.get_up(instant = TRUE)
			var/restart_amount = clamp(M.reagents.get_reagent_amount("restart")-0.4, 0, 330)
			M.reagents.remove_reagent("restart",restart_amount)
	return ..() | update_flags
