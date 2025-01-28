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
	var/fruit_list = english_list(fruits)
	description = "Образец [alcohol_description] вина, приготовленного из [fruit_list]."

	var/flavor = ""
	if(!primary_tastes.len)
		primary_tastes = list("[alcohol_description] алкоголя")
	flavor += english_list(primary_tastes)
	if(secondary_tastes.len)
		flavor += ", с лёгким привкусом "
		flavor += english_list(secondary_tastes)
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
	description = "From such a schnapps it's not a sin to start yodeling."
	color = "#e0e0e0"
	alcohol_perc = 0.4
	dizzy_adj = 2 SECONDS
	drink_icon = "schnapsglass"
	drink_name = "стакан шнапс"
	drink_desc = "From such a schnapps it's not a sin to start yodeling."
	taste_description = "wheat mint"

/datum/reagent/consumable/ethanol/sambuka
	name = "Sambuka"
	id = "sambuka"
	description = "Flying into space, many thought that they had grasped fate."
	color = "#e0e0e0"
	alcohol_perc = 0.45
	dizzy_adj = 2 SECONDS
	drink_icon = "sambukaglass"
	drink_name = "стакан Sambuka"
	drink_desc = "Flying into space, many thought that they had grasped fate."
	taste_description = "twirly fire"

/datum/reagent/consumable/ethanol/bluecuracao
	name = "Blue Curacao"
	id = "bluecuracao"
	description = "The fuse is ready, the blue has already lit up."
	color = "#16c9ff"
	alcohol_perc = 0.35
	drink_icon = "bluecuracaoglass"
	drink_name = "стакан Blue Curacao"
	drink_desc = "The fuse is ready, the blue has already lit up."
	taste_description = "explosive blue"

/datum/reagent/consumable/ethanol/bitter
	name = "Bitter"
	id = "bitter"
	description = "Don't mix up the label sizes, because I won't change anything."
	color = "#d44071"
	alcohol_perc = 0.45
	dizzy_adj = 4 SECONDS
	drink_icon = "bitterglass"
	drink_name = "стакан bitter"
	drink_desc = "Don't mix up the label sizes, because I won't change anything."
	taste_description = "vacuum bitterness"

/datum/reagent/consumable/ethanol/sheridan
	name = "Sheridan's"
	id = "sheridan"
	description = "Refrigerate, pour at an angle of 45, do not mix, enjoy."
	color = "#3a3d2e"
	alcohol_perc = 0.35
	drink_icon = "sheridanglass"
	drink_name = "стакан Sheridan's"
	drink_desc = "Refrigerate, pour at an angle of 45, do not mix, enjoy."
	taste_description = "creamy coffee"

////////////////////////////Cocktails///////////////////////////////
/datum/reagent/consumable/ethanol/black_blood
	name = "Black Blood"
	id = "black_blood"
	description = "Need to drink faster before it starts to curdle."
	color = "#252521"
	alcohol_perc = 0.45
	drink_icon = "black_blood"
	drink_name = "Black Blood"
	drink_desc = "Need to drink faster before it starts to curdle."
	taste_description = "bloody darkness"

/datum/reagent/consumable/ethanol/black_blood/reaction_mob(mob/living/M, method, volume)
	. = ..()
	if(prob(50))
		M.say(pick("Fuu ma'jin!", "Sas'so c'arta forbici!", \
		 "Ta'gh fara'qha fel d'amar det!", "Kla'atu barada nikt'o!", \
		  "Fel'th Dol Ab'orod!", "In'totum Lig'abis!", "Ethra p'ni dedol!", \
		   "Ditans Gut'ura Inpulsa!", "O bidai nabora se'sma!"))

/datum/reagent/consumable/ethanol/light_storm
	name = "Light Storm"
	id = "light_storm"
	description = "Even away from the ocean, you can feel this shaking."
	color = "#4b4b44"
	alcohol_perc = 0.6
	drink_icon = "light_storm"
	drink_name = "Light Storm"
	drink_desc = "Even away from the ocean, you can feel this shaking."
	taste_description = "sea excitement"

/datum/reagent/consumable/ethanol/cream_heaven
	name = "Cream Heaven"
	id = "cream_heaven"
	description = "This is a touch of cream and coffee, a real creation of heaven."
	color = "#4b4b44"
	alcohol_perc = 0.25
	drink_icon = "cream_heaven"
	drink_name = "Cream Heaven"
	drink_desc = "This is a touch of cream and coffee, a real creation of heaven."
	taste_description = "coffee cloud"

/datum/reagent/consumable/ethanol/negroni
	name = "Negroni"
	id = "negroni"
	description = "Bitters are very good for the liver, and gin has a bad effect on you. Here they balance each other."
	color = "#ad3948"
	alcohol_perc = 0.4
	drink_icon = "negroni"
	drink_name = "Negroni"
	drink_desc = "Bitters are very good for the liver, and gin has a bad effect on you. Here they balance each other."
	taste_description = "sweet parade"

/datum/reagent/consumable/ethanol/hirosima
	name = "Hirosima"
	id = "hirosima"
	description = "My hands are up to the elbows in blood... Oh, wait, it's alcohol."
	color = "#598317"
	alcohol_perc = 0.3
	drink_icon = "hirosima"
	drink_name = "Hirosima"
	drink_desc = "My hands are up to the elbows in blood... Oh, wait, it's alcohol."
	taste_description = "alcoholic ashes"

/datum/reagent/consumable/ethanol/nagasaki
	name = "nagasaki"
	id = "nagasaki"
	description = "At first, no one knew what would happen next. The intoxication was terrible. There is no doubt that this is the strongest intoxication that a person has ever seen."
	color = "#18c212"
	alcohol_perc = 0.7
	drink_icon = "nagasaki"
	drink_name = "Nagasaki"
	drink_desc = "At first, no one knew what would happen next. The intoxication was terrible. There is no doubt that this is the strongest intoxication that a person has ever seen."
	taste_description = "radioactive ash"

/datum/reagent/consumable/ethanol/chocolate_sheridan
	name = "Chocolate Sheridan's"
	id = "chocolate_sheridan"
	description = "In situations when you really want to cheer up and drink."
	color = "#332a1a"
	alcohol_perc = 0.3
	drink_icon = "chocolate_sheridan"
	drink_name = "Chocolate Sheridan's"
	drink_desc = "In situations when you really want to cheer up and drink."
	taste_description = "alcoholic mocha"

/datum/reagent/consumable/ethanol/panamian
	name = "Panama"
	id = "panamian"
	description = "It will connect your blood and alcohol like a Katun gateway."
	color = "#3164a7"
	alcohol_perc = 0.6
	drink_icon = "panamian"
	drink_name = "Panama"
	drink_desc = "It will connect your blood and alcohol like a Katun gateway."
	taste_description = "shipping channel"

/datum/reagent/consumable/ethanol/pegu_club
	name = "Pegu Club"
	id = "pegu_club"
	description = "It's like a group of gentlemen colonizing your tongue."
	color = "#a5702b"
	alcohol_perc = 0.5
	drink_icon = "pegu_club"
	drink_name = "Pegu Club"
	drink_desc = "It's like a group of gentlemen colonizing your tongue."
	taste_description = "shipping channel"

/datum/reagent/consumable/ethanol/jagermachine
	name = "Jagermachine"
	id = "jagermachine"
	description = "A true detail hunter."
	color = "#6b0b74"
	alcohol_perc = 0.55
	drink_icon = "jagermachine"
	drink_name = "Jagermachine"
	drink_desc = "A true detail hunter."
	taste_description = "stealing parts"

/datum/reagent/consumable/ethanol/blue_cybesauo
	name = "Blue Cybesauo"
	id = "blue_cybesauo"
	description = "The blue is similar to the blue screen of death."
	color = "#0b7463"
	alcohol_perc = 0.4
	drink_icon = "blue_cybesauo"
	drink_name = "Blue Cybesauo"
	drink_desc = "The blue is similar to the blue screen of death."
	taste_description = "error 0xc000001b"

/datum/reagent/consumable/ethanol/alcomender
	name = "Alcomender"
	id = "alcomender"
	description = "A glass in the form of a mender, a favorite among doctors."
	color = "#6b0059"
	alcohol_perc = 1.4 ////Heal burn
	drink_icon = "alcomender"
	drink_name = "Alcomender"
	drink_desc = "A glass in the form of a mender, a favorite among doctors."
	taste_description = "funny medicine"

/datum/reagent/consumable/ethanol/alcomender/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.adjustFireLoss(-0.7, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/alcomender/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume) // It is alcohol after all, so don't try to pour it on someone who's on fire ... please.
	if(iscarbon(M))
		if(method == REAGENT_TOUCH)
			M.adjustFireLoss(-volume * 0.7, affect_robotic = FALSE)
			to_chat(M, "<span class='notice'>The diluted silver sulfadiazine soothes your burns.</span>")
	return STATUS_UPDATE_NONE

/datum/reagent/consumable/ethanol/amnesia
	name = "Star Amnesia"
	id = "amnesia"
	description = "Is it just a bottle of medical alcohol?"
	color = "#6b0059"
	alcohol_perc = 1.2 ////Ethanol and Hooch
	drink_icon = "amnesia"
	drink_name = "Star Amnesia"
	drink_desc = "Is it just a bottle of medical alcohol?"
	taste_description = "disco amnesia"

/datum/reagent/consumable/ethanol/johnny
	name = "Silverhand"
	id = "johnny"
	description = "Wake the heck up, samurai. We have a station to burn."
	color = "#c41414"
	alcohol_perc = 0.6
	drink_icon = "johnny"
	drink_name = "Silverhand"
	drink_desc = "Wake the heck up, samurai. We have a station to burn."
	taste_description = "superstar fading"

/datum/reagent/consumable/ethanol/cosmospoliten
	name = "Cosmospoliten"
	id = "cosmospoliten"
	description = "Then try to prove that you are straight and not a woman if you got caught with him."
	color = "#b1483a"
	alcohol_perc = 0.5
	drink_icon = "cosmospoliten"
	drink_name = "Cosmospoliten"
	drink_desc = "Then try to prove that you are straight and not a woman if you got caught with him."
	taste_description = "orientation reversal"

/datum/reagent/consumable/ethanol/oldfashion
	name = "Old Fashion"
	id = "oldfashion"
	description = "Rumor has it that this cocktail is the oldest, but however, this is a completely different story."
	color = "#6b4017"
	alcohol_perc = 0.6
	drink_icon = "oldfashion"
	drink_name = "Old Fashion"
	drink_desc = "Rumor has it that this cocktail is the oldest, but however, this is a completely different story."
	taste_description = "old times"

/datum/reagent/consumable/ethanol/french_75
	name = "French 75"
	id = "french_75"
	description = "Charge the liver, aim, fire!"
	color = "#b1953a"
	alcohol_perc = 0.4
	drink_icon = "french_75"
	drink_name = "French 75"
	drink_desc = "Charge the liver, aim, fire!"
	taste_description = "artillery bombing"

/datum/reagent/consumable/ethanol/gydroseridan
	name = "Gydroridan"
	id = "gydroseridan"
	description = "Hydraulic separation of layers will help us in efficiency."
	color = "#3a99b1"
	alcohol_perc = 0.5
	drink_icon = "gydroseridan"
	drink_name = "Gydroridan"
	drink_desc = "Hydraulic separation of layers will help us in efficiency."
	taste_description = "hydraulic power"

/datum/reagent/consumable/ethanol/milk_plus
	name = "Milk +"
	id = "milk_plus"
	description = "When a man cannot choose he ceases to be a man."
	color = "#DFDFDF"
	alcohol_perc = 0.8
	drink_icon = "milk_plus"
	drink_name = "Milk +"
	drink_desc = "When a man cannot choose he ceases to be a man."
	taste_description = "loss of human"

/datum/reagent/consumable/ethanol/teslasingylo
	name = "God Of Power"
	id = "teslasingylo"
	description = "A real horror for the SMES and the APC. Don't overload them."
	color = "#0300ce"
	alcohol_perc = 0.7
	process_flags = SYNTHETIC
	drink_icon = "teslasingylo"
	drink_name = "God Of Power"
	drink_desc = "A real horror for the SMES and the APC. Don't overload them."
	taste_description = "electricity bless"

/datum/reagent/consumable/ethanol/teslasingylo/on_mob_life(mob/living/M)
	. = ..()
	if(ismachineperson(M))
		var/mob/living/carbon/human/machine/machine = M
		if(machine.nutrition > NUTRITION_LEVEL_WELL_FED) //no fat machines, sorry
			return
		machine.adjust_nutrition(15) //much less than charging from APC (50)

/datum/reagent/consumable/ethanol/light
	name = "Light"
	id = "light"
	description = "A favorite among Nian and Dionea, someone say that this is a mini thermonuclear reaction, but only shhh..."
	color = "#fffb00"
	alcohol_perc = 0.2
	drink_icon = "light"
	drink_name = "Light"
	drink_desc = "A favorite among Nian and Dionea, someone say that this is a mini thermonuclear reaction, but only shhh..."
	taste_description = "star warmth"

/datum/reagent/consumable/ethanol/light/on_mob_life(mob/living/M)
	. = ..()
	if(M.lighting_alpha < LIGHTING_PLANE_ALPHA_NV_TRAIT)
		return
	M.lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
	if(volume < 0.4)
		M.lighting_alpha = initial(M.lighting_alpha)

/datum/reagent/consumable/ethanol/bees_knees
	name = "Bee's Knees"
	id = "bees_knees"
	description = "As if the fact is that the bee carries pollen in the area of the knees and ... Nevermind."
	color = "#e8f71f"
	alcohol_perc = 0.5
	drink_icon = "bees_knees"
	drink_name = "Bee's Knees"
	drink_desc = "As if the fact is that the bee carries pollen in the area of the knees and ... Nevermind."
	taste_description = "honey love"

/datum/reagent/consumable/ethanol/aviation
	name = "Aviation"
	id = "aviation"
	description = "It's hard to make cocktails when a zeppelin flies over your house."
	color = "#c48f8f"
	alcohol_perc = 0.5
	drink_icon = "aviation"
	drink_name = "Aviation"
	drink_desc = "It's hard to make cocktails when a zeppelin flies over your house."
	taste_description = "blowing the wind"

/datum/reagent/consumable/ethanol/fizz
	name = "Fizz"
	id = "fizz"
	description = "It's like living with a feral cat."
	color = "#b6b6b6"
	alcohol_perc = 0.3
	drink_icon = "fizz"
	drink_name = "Fizz"
	drink_desc = "It's like living with a feral cat."
	taste_description = "fizzing"

/datum/reagent/consumable/ethanol/brandy_crusta
	name = "Brandy Crusta"
	id = "brandy_crusta"
	description = "The sugar crust may not be sweet at all."
	color = "#754609"
	alcohol_perc = 0.4
	drink_icon = "brandy_crusta"
	drink_name = "Brandy Crusta"
	drink_desc = "The sugar crust may not be sweet at all."
	taste_description = "salty-sweet"

/datum/reagent/consumable/ethanol/aperolspritz
	name = "Aperol Spritz"
	id = "aperolspritz"
	description = "Many consider it a separate alcohol, but it's more like a knight in chess."
	color = "#c43d3d"
	alcohol_perc = 0.5
	drink_icon = "aperolspritz"
	drink_name = "Aperol Spritz"
	drink_desc = "Many consider it a separate alcohol, but it's more like a knight in chess."
	taste_description = "separateness of taste"

/datum/reagent/consumable/ethanol/sidecar
	name = "Sidecar"
	id = "sidecar"
	description = "This cocktail is very popular. It was first introduced by the popular bartender This McGarry from Buck's Club."
	color = "#b15416"
	alcohol_perc = 0.4
	drink_icon = "sidecar"
	drink_name = "Sidecar"
	drink_desc = "This cocktail is very popular. It was first introduced by the popular bartender This McGarry from Buck's Club."
	taste_description = "orange alcoh"

/datum/reagent/consumable/ethanol/daiquiri
	name = "Daiquiri"
	id = "daiquiri"
	description = "Just try, try again for me! With the headshot power of a Daiquiri!"
	color = "#b6b6b6"
	alcohol_perc = 0.4
	drink_icon = "daiquiri"
	drink_name = "Daiquiri"
	drink_desc = "Just try, try again for me! With the headshot power of a Daiquiri!"
	taste_description = "headshot"

/datum/reagent/consumable/ethanol/tuxedo
	name = "Tuxedo"
	id = "tuxedo"
	description = "I can promise you a Colombian tie."
	color = "#888686"
	alcohol_perc = 0.5
	drink_icon = "tuxedo"
	drink_name = "Tuxedo"
	drink_desc = "I can promise you a Colombian tie."
	taste_description = "strictness of style"

/datum/reagent/consumable/ethanol/telegol
	name = "Telegol"
	id = "telegol"
	description = "Many are still puzzling over the question of this cocktail. Anyway, it still exists... Or not."
	color = "#4218a3"
	alcohol_perc = 0.5
	drink_icon = "telegol"
	drink_name = "Telegol"
	drink_desc = "Many are still puzzling over the question of this cocktail. Anyway, it still exists... Or not."
	taste_description = "fourteen dimension"

/datum/reagent/consumable/ethanol/horse_neck
	name = "Horse Neck"
	id = "horse_neck"
	description = "Be careful with your horse's shoes."
	color = "#c45d09"
	alcohol_perc = 0.5
	drink_icon = "horse_neck"
	drink_name = "Horse Neck"
	drink_desc = "Be careful with your horse's shoes."
	taste_description = "horsepower"

/datum/reagent/consumable/ethanol/horse_neck/reaction_mob(mob/living/M, method, volume)
	. = ..()
	if(prob(50))
		M.say(pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!"))

/datum/reagent/consumable/ethanol/cuban_sunset
	name = "Cuban Sunset"
	id = "cuban_sunset"
	description = "A new day, with a new coup."
	color = "#d88948"
	alcohol_perc = 0.6
	drink_icon = "cuban_sunset"
	drink_name = "Cuban Sunset"
	drink_desc = "A new day, with a new coup."
	taste_description = "totalitarianism"

/datum/reagent/consumable/ethanol/sake_bomb
	name = "Sake Bomb"
	id = "sake_bomb"
	description = "Carpet bombing your bamboo liver."
	color = "#e2df2e"
	alcohol_perc = 0.3
	drink_icon = "sake_bomb"
	drink_name = "Sake Bomb"
	drink_desc = "Carpet bombing your bamboo liver."
	taste_description = "beer and sake"

/datum/reagent/consumable/ethanol/blue_havai
	name = "Blue Havai"
	id = "blue_havai"
	description = "The same blue as brown eyes."
	color = "#296129"
	alcohol_perc = 0.2
	drink_icon = "blue_havai"
	drink_name = "Blue Havai"
	drink_desc = "The same blue as brown eyes."
	taste_description = "neon dawn"

/datum/reagent/consumable/ethanol/woo_woo
	name = "Woo Woo"
	id = "woo_woo"
	description = "And which child came up with this name? Yeah, I see, the question is settled."
	color = "#e22e2e"
	alcohol_perc = 0.5
	drink_icon = "woo_woo"
	drink_name = "Woo Woo"
	drink_desc = "And which child came up with this name? Yeah, I see, the question is settled."
	taste_description = "woo woo"

/datum/reagent/consumable/ethanol/mulled_wine
	name = "Mulled Wine"
	id = "mulled_wine"
	description = "Just a hot wine with spices, but so pleasant."
	color = "#fd4b4b"
	alcohol_perc = 0.2
	drink_icon = "mulled_wine"
	drink_name = "Mulled Wine"
	drink_desc = "Just a hot wine with spices, but so pleasant."
	taste_description = "hot wine"

/datum/reagent/consumable/ethanol/white_bear
	name = "White Bear"
	id = "white_bear"
	description = "Two historical enemies, in one circle."
	color = "#d8b465"
	alcohol_perc = 0.5
	drink_icon = "white_bear"
	drink_name = "White Bear"
	drink_desc = "Two historical enemies, in one circle."
	taste_description = "ideological war"

/datum/reagent/consumable/ethanol/vampiro
	name = "Vampiro"
	id = "vampiro"
	description = "Has nothing to do with vampires, except that color."
	color = "#8d0000"
	alcohol_perc = 0.45
	drink_icon = "vampiro"
	drink_name = "Vampiro"
	drink_desc = "Has nothing to do with vampires, except that color."
	taste_description = "exhaustion"

/datum/reagent/consumable/ethanol/vampiro/on_mob_life(mob/living/M)
	. = ..()
	if(volume > 20)
		if(prob(50)) //no spam here :p
			M.visible_message("<span class='warning'>Глаза [M] ослепительно вспыхивают!</span>")

/datum/reagent/consumable/ethanol/queen_mary
	name = "Queen Mary"
	id = "queen_mary"
	description = "Mary was cleaned of blood, and it turned out that she was also red."
	color = "#bd2f2f"
	alcohol_perc = 0.35
	drink_icon = "queen_mary"
	drink_name = "Queen Mary"
	drink_desc = "Mary was cleaned of blood, and it turned out that she was also red."
	taste_description = "cherry beer"

/datum/reagent/consumable/ethanol/inabox
	name = "Box"
	id = "inabox"
	description = "This... Just a box?"
	color = "#5a3e0b"
	alcohol_perc = 0.4
	drink_icon = "inabox"
	drink_name = "Box"
	drink_desc = "This... Just a box?"
	taste_description = "stealth"

/datum/reagent/consumable/ethanol/beer_berry_royal
	name = "Beer Berry Royal"
	id = "beer_berry_royal"
	description = "For some reason, they continue to float up and down."
	color = "#684b16"
	alcohol_perc = 0.25
	drink_icon = "beer_berry_royal"
	drink_name = "Beer Berry Royal"
	drink_desc = "For some reason, they continue to float up and down."
	taste_description = "beer berry"

/datum/reagent/consumable/ethanol/sazerac
	name = "Sazerac"
	id = "sazerac"
	description = "The best pharmacists are bartenders."
	color = "#7c6232"
	alcohol_perc = 0.4
	drink_icon = "sazerac"
	drink_name = "Sazerac"
	drink_desc = "The best pharmacists are bartenders."
	taste_description = "bitter whiskey"

/datum/reagent/consumable/ethanol/monako
	name = "Monako"
	id = "monako"
	description = "You might think there are more fruits on the market."
	color = "#7c6232"
	alcohol_perc = 0.5
	drink_icon = "monako"
	drink_name = "Monako"
	drink_desc = "You might think there are more fruits on the market."
	taste_description = "fruit gin"

/datum/reagent/consumable/ethanol/irishempbomb
	name = "Irish EMP Bomb"
	id = "irishempbomb"
	description = "Mmm, tastes like shut down..."
	color = "#123eb8"
	process_flags = SYNTHETIC
	alcohol_perc = 0.6
	drink_icon = "irishempbomb"
	drink_name = "Irish EMP Bomb"
	drink_desc = "Mmm, tastes like shut down..."
	taste_description = "electromagnetic impulse"

/datum/reagent/consumable/ethanol/irishempbomb/on_mob_life(mob/living/M)
	M.Stun(1, FALSE)
	do_sparks(5, FALSE, M.loc)
	return ..()

/datum/reagent/consumable/ethanol/codelibre
	name = "Code Libre"
	id = "codelibre"
	description = "Por Code libre!"
	color = "#a126b1"
	alcohol_perc = 0.55
	process_flags = SYNTHETIC
	drink_icon = "codelibre"
	drink_name = "Code Libre"
	drink_desc = "Por Code libre!"
	taste_description = "code liberation"

/datum/reagent/consumable/ethanol/codelibre/on_mob_life(mob/living/M)
	. = ..()
	if(prob(10))
		M.say("[get_language_prefix(LANGUAGE_TRINARY)] Viva la Synthetica!")

/datum/reagent/consumable/ethanol/blackicp
	name = "Black ICP"
	id = "blackicp"
	description = "I'm sorry I wasn't responding, can you repeat that?"
	color = "#a126b1"
	alcohol_perc = 0.5
	drink_icon = "blackicp"
	drink_name = "Black ICP"
	drink_desc = "I'm sorry I wasn't responding, can you repeat that?"
	taste_description = "monitor replacing"

/datum/reagent/consumable/ethanol/slime_drink
	name = "Slime Drink"
	id = "slime_drink"
	description = "Don't worry, it's just jelly."
	color = "#dd3e32"
	alcohol_perc = 0.2
	drink_icon = "slime_drink"
	drink_name = "Slime Drink"
	drink_desc = "Don't worry, it's just jelly. And slime been dead for a long time."
	taste_description = "jelly alcohol"

/datum/reagent/consumable/ethanol/innocent_erp
	name = "Innocent ERP"
	id = "innocent_erp"
	description = "Remember that big brother sees everything."
	color = "#746463"
	alcohol_perc = 0.5
	drink_icon = "innocent_erp"
	drink_name = "Innocent ERP"
	drink_desc = "Remember that big brother sees everything."
	taste_description = "loss of flirtatiousness"

/datum/reagent/consumable/ethanol/nasty_slush
	name = "Nasty Slush"
	id = "nasty_slush"
	description = "The name has nothing to do with the drink itself."
	color = "#462c0a"
	alcohol_perc = 0.55
	drink_icon = "nasty_slush"
	drink_name = "Nasty Slush"
	drink_desc = "The name has nothing to do with the drink itself."
	taste_description = "nasty slush"

/datum/reagent/consumable/ethanol/blue_lagoon
	name = "Blue Lagoon"
	id = "blue_lagoon"
	description = "What could be better than relaxing on the beach with a good drink?"
	color = "#1edddd"
	alcohol_perc = 0.5
	drink_icon = "blue_lagoon"
	drink_name = "Blue Lagoon"
	drink_desc = "What could be better than relaxing on the beach with a good drink?"
	taste_description = "beach relaxation"

/datum/reagent/consumable/ethanol/green_fairy
	name = "Green Fairy"
	id = "green_fairy"
	description = "Some kind of abnormal green."
	color = "#54dd1e"
	alcohol_perc = 0.6
	drink_icon = "green_fairy"
	drink_name = "Green Fairy"
	drink_desc = "Some kind of abnormal green."
	taste_description = "faith in fairies"

/datum/reagent/consumable/ethanol/green_fairy/on_mob_life(mob/living/M)
	M.SetDruggy(min(max(0, M.AmountDruggy() + 10 SECONDS), 15 SECONDS))
	return ..()

/datum/reagent/consumable/ethanol/home_lebovsky
	name = "Home Lebowski"
	id = "home_lebovsky"
	description = "Let me explain something to you. Um, I am not Home Lebowski. You're Home Lebowski. I'm The Dude."
	color = "#422b00"
	alcohol_perc = 0.35
	drink_icon = "home_lebovsky"
	drink_name = "Home Lebowski"
	drink_desc = "Let me explain something to you. Um, I am not Home Lebowski. You're Home Lebowski. I'm The Dude."
	taste_description = "dressing gown"

/datum/reagent/consumable/ethanol/top_billing
	name = "Top Billing"
	id = "top_billing"
	description = "In a prominent place, our top billing!"
	color = "#0b573d"
	alcohol_perc = 0.4
	drink_icon = "top_billing"
	drink_name = "Top Billing"
	drink_desc = "In a prominent place, our top billing!"
	taste_description = "advertising space"

/datum/reagent/consumable/ethanol/trans_siberian_express
	name = "Trans-Siberian Express"
	id = "trans_siberian_express"
	description = "From Vladivostok to delirium tremens in a day."
	color = "#e2a600"
	alcohol_perc = 0.5
	drink_icon = "trans_siberian_express"
	drink_name = "Trans-Siberian express"
	drink_desc = "From Vladivostok to delirium tremens in a day."
	taste_description = "terrible infrastructure"

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
	name = "Sun"
	id = "sun"
	description = "Red sun over paradise!"
	color = "#bd1c1c"
	alcohol_perc = 0.4
	drink_icon = "sun"
	drink_name = "Sun"
	drink_desc = "Red sun over paradise!"
	taste_description = "sun heat"

/datum/reagent/consumable/ethanol/tick_tack
	name = "Tick-Tock"
	id = "tick_tack"
	description = "Tick-Tock, Tick-Tock Bzzzzz..."
	color = "#118020"
	alcohol_perc = 0.3
	drink_icon = "tick_tack"
	drink_name = "Tick-Tock"
	drink_desc = "Tick-Tock, Tick-Tock Bzzzzz..."
	taste_description = "clock tick"

/datum/reagent/consumable/ethanol/uragan_shot
	name = "Uragan Shot"
	id = "uragan_shot"
	description = "Is it a uragan? But no, it's urahol."
	color = "#da6631"
	alcohol_perc = 0.35
	drink_icon = "uragan_shot"
	drink_name = "Uragan Shot"
	drink_desc = "Is it a uragan? But no, it's urahol."
	taste_description = "gusts of wind"

/datum/reagent/consumable/ethanol/new_yorker
	name = "New Yorker"
	id = "new_yorker"
	description = "Be careful with the stock exchange, otherwise it will be 'Black Tuesday.'"
	color = "#da3131"
	alcohol_perc = 0.4
	drink_icon = "new_yorker"
	drink_name = "New Yorker"
	drink_desc = "Be careful with the stock exchange, otherwise it will be 'Black Tuesday.'"
	taste_description = "the collapse"

/datum/reagent/consumable/ethanol/blue_moondrin
	name = "Iluk Blue Moon'drin"
	id = "blue_moondrin"
	description = "Rarest tajaran drink in the galaxy! Be careful with your Captain!"
	color = "#0026fc"
	alcohol_perc = 0.7
	addiction_chance = 4
	drink_icon = "blue_moondrin"
	drink_name = "Iluk Blue Moon'drin"
	drink_desc = "Rarest tajaran drink in the galaxy! Be careful with your Captain!"
	taste_description = "the blue set-up"

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
	name = "Redwater Moon'drin"
	id = "red_moondrin"
	description = "Illegal tajaran drink in Adomai, but maybe not here! Dangerous moon'drin based drink with secret ingridient. Be careful with this stuff!"
	color = "#960202"
	alcohol_perc = 0.9
	addiction_chance = 7
	drink_icon = "red_moondrin"
	drink_name = "Redwater Moon'drin"
	drink_desc = "Dangerous moon'drin based tajaran drink with secret ingridient. It seems legal but also wrong..."
	taste_description = "blood red pain in your stomach! But it feels so go-o-o-o-od.."

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
				to_chat(M, "<span class='warning'>You feel strange...</span>")
				M.emote("scream")
				M.playsound_local(src, 'sound/spookoween/ghost_whisper.ogg', 5)
				M.AdjustHallucinate(40 SECONDS)
				update_flags |= M.adjustStaminaLoss(3, FALSE)
			if(prob(5))
				M.playsound_local(src,'sound/hallucinations/look_up1.ogg', 1)
				M.emote("gasp")
				to_chat(M, "<span class='warning'>You can't breathe! But it feels GOOD!</span>")
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
				to_chat(M, "<span class='warning'>You feel pain!</span>")
				M.emote("scream")
				M.playsound_local(src, 'sound/spookoween/ghost_whisper.ogg', 5)
				M.AdjustHallucinate(40 SECONDS)
				update_flags |= M.adjustStaminaLoss(10, FALSE)
			if(prob(5))
				M.playsound_local(src, 'sound/effects/heartbeat.ogg', 2)
				M.playsound_local(src,'sound/hallucinations/growl1.ogg', 1)
				M.emote("gasp")
				to_chat(M, "<span class='warning'>You can't breathe! But it feels GOOD!</span>")
				update_flags |= M.adjustOxyLoss(15, FALSE)
				update_flags |= M.adjustToxLoss(2, FALSE)
				M.Stun(2 SECONDS)
			if(prob(3))
				M.playsound_local(src, 'sound/effects/heartbeat.ogg', 2)
				to_chat(M, "<span class='warning'>You feel like you're being watched!</span>")
				M.playsound_local(src,'sound/hallucinations/growl2.ogg', 1)
				M.emote(pick("drool","scream"))
				M.Jitter(20 SECONDS)
				update_flags |= M.adjustToxLoss(3, FALSE)
				M.Weaken(2 SECONDS)
				M.AdjustConfused(66 SECONDS)
	return ..() | update_flags

/datum/reagent/consumable/ethanol/synthanol/restart
	name = "Restart"
	id = "restart"
	description = "Sometimes you just need to start anew"
	color = "#0026fc"
	reagent_state = LIQUID
	process_flags = SYNTHETIC
	alcohol_perc = 1.5
	drink_icon = "restart"
	drink_name = "стакан Restart"
	drink_desc = "Sometimes you just need to start anew"
	taste_description = "system reset"

/datum/reagent/consumable/ethanol/synthanol/restart/on_mob_life(mob/living/carbon/human/M)
	var/update_flags = STATUS_UPDATE_NONE
	switch(current_cycle)
		if(5 to 13)
			M.Jitter(40 SECONDS)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
			if(prob(5))
				to_chat(M, "<span class='notice'>Rebooting..</span>")
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
