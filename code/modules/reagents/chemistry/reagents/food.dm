/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.

/datum/reagent/consumable
	name = "Еда"
	id = "consumable"
	harmless = TRUE
	taste_description = "обычной еды"
	taste_mult = 4
	var/nutriment_factor = 1 * REAGENTS_METABOLISM
	var/diet_flags = DIET_OMNI | DIET_HERB | DIET_CARN

/datum/reagent/consumable/on_mob_life(mob/living/M)
	if(!(M.mind in SSticker.mode.vampires))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.can_eat(diet_flags))	//Make sure the species has it's dietflag set, otherwise it can't digest any nutrients
				H.adjust_nutrition(nutriment_factor)	// For hunger and fatness
	return ..()

/datum/reagent/consumable/nutriment		// Pure nutriment, universally digestable and thus slightly less effective
	name = "Питательные вещества"
	id = "nutriment"
	description = "Сомнительная смесь различных питательных веществ. Обычно встречаются в обработанных продуктах."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48
	var/brute_heal = 1
	var/burn_heal = 0

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!(M.mind in SSticker.mode.vampires))
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.can_eat(diet_flags))	//Make sure the species has it's dietflag set, otherwise it can't digest any nutrients
				if(prob(50))
					update_flags |= M.adjustBruteLoss(-brute_heal, FALSE)
					update_flags |= M.adjustFireLoss(-burn_heal, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/nutriment/on_new(list/supplied_data)
	// taste data can sometimes be ("salt" = 3, "chips" = 1)
	// and we want it to be in the form ("salt" = 0.75, "chips" = 0.25)
	// which is called "normalizing"
	if(!supplied_data)
		supplied_data = data
	// if data isn't an associative list, this has some WEIRD side effects
	// TODO probably check for assoc list?
	data = counterlist_normalise(supplied_data)

/datum/reagent/consumable/nutriment/on_merge(list/newdata, newvolume)
	if(!islist(newdata) || !newdata.len)
		return
	var/list/taste_amounts = list()
	var/list/other_taste_amounts = newdata.Copy()
	if(data)
		taste_amounts = data.Copy()
	counterlist_scale(taste_amounts, volume)
	counterlist_combine(taste_amounts, other_taste_amounts)
	counterlist_normalise(taste_amounts)
	data = taste_amounts

/datum/reagent/consumable/nutriment/protein			// Meat-based protein, digestable by carnivores and omnivores, worthless to herbivores
	name = "Протеин" // Protein
	id = "protein"
	description = "Различные важные белки и жиры. Обычно содержатся в мясе и крови животных."
	diet_flags = DIET_CARN | DIET_OMNI

/datum/reagent/consumable/nutriment/plantmatter		// Plant-based biomatter, digestable by herbivores and omnivores, worthless to carnivores
	name = "Растительная масса" // Plant-matter
	id = "plantmatter"
	description = "Богатые витаминами волокна и природные сахара. Обычно содержатся в свежих продуктах."
	diet_flags = DIET_HERB | DIET_OMNI

/datum/reagent/consumable/nutriment/vitamin
	name = "Витамины" // Vitamin
	id = "vitamin"
	description = "Самые нужные витамины, минералы и углеводы, необходимые организму в чистом виде."
	reagent_state = SOLID
	color = "#664330" // rgb: 102, 67, 48
	brute_heal = 1
	burn_heal = 1

/datum/reagent/consumable/nutriment/vitamin/on_mob_life(mob/living/M)
	if(M.satiety < 600)
		M.satiety += 30
	return ..()

/datum/reagent/consumable/sugar
	name = "Сахар" // Sugar
	id = "sugar"
	description = "Органическое соединение, известное как «столовый сахар» или «сахароза». Белый кристаллический порошок без запаха, с приятным сладким вкусом."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	nutriment_factor = 5 * REAGENTS_METABOLISM
	overdose_threshold = 200 // Hyperglycaemic shock
	taste_description = "сладости"
	taste_mult = 1.5

/datum/reagent/consumable/sugar/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-5)
	if(current_cycle >= 90)
		M.AdjustJitter(2)
	if(prob(25))
		update_flags |= M.AdjustParalysis(-1, FALSE)
		update_flags |= M.AdjustStunned(-1, FALSE)
		update_flags |= M.AdjustWeakened(-1, FALSE)
	if(prob(4))
		M.reagents.add_reagent("epinephrine", 1.2)
	return ..() | update_flags

/datum/reagent/consumable/sugar/overdose_start(mob/living/M)
	to_chat(M, "<span class='danger'>Вы теряете сознание от гипергликемического шока!</span>")
	M.emote("collapse")
	..()

/datum/reagent/consumable/sugar/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	update_flags |= M.Paralyse(3 * severity, FALSE)
	update_flags |= M.Weaken(4 * severity, FALSE)
	if(prob(8))
		update_flags |= M.adjustToxLoss(severity, FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/soysauce
	name = "Соевый соус" // Soysauce
	id = "soysauce"
	description = "Соленый соус, изготавливаемый из сои."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" // rgb: 121, 35, 0
	taste_description = "сои"

/datum/reagent/consumable/ketchup
	name = "Кетчуп" // Ketchup
	id = "ketchup"
	description = "«Кетчуп», «котсуп» — неважно. Это томатная паста."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "кетчупа"

/datum/reagent/consumable/capsaicin
	name = "Капсаициновое масло" // Capsaicin Oil
	id = "capsaicin"
	description = "Именно это делает чилийские перцы таким острыми."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8
	addiction_chance = 1
	addiction_chance_additional = 10
	addiction_threshold = 2
	minor_addiction = TRUE
	taste_description = "<span class='warning'>ЖЖЕНИЯ</span>"
	taste_mult = 1.5

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 15)
			M.bodytemperature += 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			if(isslime(M))
				M.bodytemperature += rand(5,20)
		if(15 to 25)
			M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(10,20)
		if(25 to 35)
			M.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(15,20)
		if(35 to INFINITY)
			M.bodytemperature += 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature += rand(20,25)
	return ..()

/datum/reagent/consumable/condensedcapsaicin
	name = "Сгущённый капсаицин" // Condensed Capsaicin
	id = "condensedcapsaicin"
	description = "Та самая фигня из перцовых баллончиков."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = "<span class='userdanger'>ЧИСТОГО ПЛАМЕНИ</span>"

/datum/reagent/consumable/condensedcapsaicin/on_mob_life(mob/living/M)
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("шатается","кашляет","отплёвывается")!]</span>")
	return ..()

/datum/reagent/consumable/condensedcapsaicin/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/victim = M
			var/mouth_covered = 0
			var/eyes_covered = 0
			var/obj/item/safe_thing = null
			if( victim.wear_mask )
				if(victim.wear_mask.flags_cover & MASKCOVERSEYES)
					eyes_covered = 1
					safe_thing = victim.wear_mask
				if(victim.wear_mask.flags_cover & MASKCOVERSMOUTH)
					mouth_covered = 1
					safe_thing = victim.wear_mask
			if( victim.head )
				if(victim.head.flags_cover & MASKCOVERSEYES)
					eyes_covered = 1
					safe_thing = victim.head
				if(victim.head.flags_cover & MASKCOVERSMOUTH)
					mouth_covered = 1
					safe_thing = victim.head
			if(victim.glasses)
				eyes_covered = 1
				if( !safe_thing )
					safe_thing = victim.glasses
			if( eyes_covered && mouth_covered )
				to_chat(victim, "<span class='danger'>[safe_thing] защищает вас от перцовой струи!</span>")
				return
			else if( mouth_covered )	// Reduced effects if partially protected
				to_chat(victim, "<span class='danger'>[safe_thing] защищает вас от большей части перцовой струи!</span>")
				if(prob(5))
					victim.emote("scream")
				victim.EyeBlurry(3)
				victim.EyeBlind(1)
				victim.Confused(3)
				victim.damageoverlaytemp = 60
				victim.Weaken(3)
				victim.drop_item()
				return
			else if( eyes_covered ) // Eye cover is better than mouth cover
				to_chat(victim, "<span class='danger'>[safe_thing] защищает ваши глаза от перцовой струи!</span>")
				victim.EyeBlurry(3)
				victim.damageoverlaytemp = 30
				return
			else // Oh dear :D
				if(prob(5))
					victim.emote("scream")
				to_chat(victim, "<span class='danger'>Вам прыснули перцовым баллончиком прямо в глаза!</span>")
				victim.EyeBlurry(5)
				victim.EyeBlind(2)
				victim.Confused(6)
				victim.damageoverlaytemp = 75
				victim.Weaken(5)
				victim.drop_item()

/datum/reagent/consumable/frostoil
	name = "Ледяное масло" // Frost Oil
	id = "frostoil"
	description = "Особое масло, заметно примораживающее кожу. Добывается из ледяных перцев."
	reagent_state = LIQUID
	color = "#8BA6E9" // rgb: 139, 166, 233
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "<font color='lightblue'>холода</span>"

/datum/reagent/consumable/frostoil/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 15)
			M.bodytemperature -= 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
			if(isslime(M))
				M.bodytemperature -= rand(5,20)
		if(15 to 25)
			M.bodytemperature -= 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				M.bodytemperature -= rand(10,20)
		if(25 to 35)
			M.bodytemperature -= 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				M.bodytemperature -= rand(15,20)
		if(35 to INFINITY)
			M.bodytemperature -= 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				M.bodytemperature -= rand(20,25)
	return ..()

/datum/reagent/consumable/frostoil/reaction_turf(turf/T, volume)
	if(volume >= 5)
		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(15, 30))

/datum/reagent/consumable/sodiumchloride
	name = "Соль" // Salt
	id = "sodiumchloride"
	description = "Хлорид натрия, он же поваренная соль."
	reagent_state = SOLID
	color = "#B1B0B0"
	harmless = FALSE
	overdose_threshold = 100
	taste_mult = 2
	taste_description = "соли"

/datum/reagent/consumable/sodiumchloride/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(70))
		update_flags |= M.adjustBrainLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/blackpepper
	name = "Чёрный перед" // Black Pepper
	id = "blackpepper"
	description = "Порошок из молотых зёрен чёрного перца. *А-А-А-ПЧХХИ-И-И!*"
	reagent_state = SOLID
	taste_description = "перца"

/datum/reagent/consumable/cocoa
	name = "Какао-порошок" // Cocoa Powder
	id = "cocoa"
	description = "Жирная горькая паста из какао-бобов."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "горького какао"

/datum/reagent/consumable/vanilla
	name = "Ванильный порошок" // Vanilla Powder
	id = "vanilla"
	description = "Жирная горькая паста из стручков ванили."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#FFFACD"
	taste_description = "горькой ванили"

/datum/reagent/consumable/hot_coco
	name = "Горячий шоколад" // Hot Chocolate
	id = "hot_coco"
	description = "Сделан с любовью. И какао бобами."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16
	taste_description = "шоколада"

/datum/reagent/consumable/hot_coco/on_mob_life(mob/living/M)
	if(M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	return ..()

/datum/reagent/consumable/garlic
	name = "Чесночный сок" // Garlic Juice
	id = "garlic"
	description = "Давленый чеснок. Повара его любят, но пахнуть от него может неприятно."
	color = "#FEFEFE"
	taste_description = "чеснока"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/garlic/on_mob_life(mob/living/carbon/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.mind && H.mind.vampire && !H.mind.vampire.get_ability(/datum/vampire_passive/full)) //incapacitating but not lethal.
			if(prob(min(25, current_cycle)))
				to_chat(H, "<span class='danger'>Вы не можете избавиться от запаха чеснока в носу! Ваши мысли путаются…</span>")
				H.Weaken(1)
				H.Jitter(10)
				H.fakevomit()
		else
			if(H.job == "Chef")
				if(prob(20)) //stays in the system much longer than sprinkles/banana juice, so heals slower to partially compensate
					update_flags |= H.adjustBruteLoss(-1, FALSE)
					update_flags |= H.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/sprinkles
	name = "Посыпка" // Sprinkles
	id = "sprinkles"
	description = "Разноцветные кусочки сахара, обычно встречающиеся на пончиках. Любимы офицерами."
	color = "#FF00FF" // rgb: 255, 0, 255
	taste_description = "хрустящей сладости"

/datum/reagent/consumable/sprinkles/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && (M.job in list("Security Officer", "Security Pod Pilot", "Detective", "Warden", "Head of Security", "Brig Physician", "Internal Affairs Agent", "Magistrate")))
		update_flags |= M.adjustBruteLoss(-1, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/cornoil
	name = "Кукурузное масло" // Corn Oil
	id = "cornoil"
	description = "Масло из различных видов кукурузы."
	reagent_state = LIQUID
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "масла"

/datum/reagent/consumable/cornoil/reaction_turf(turf/simulated/T, volume)
	if(!istype(T))
		return
	if(volume >= 3)
		T.MakeSlippery()
	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air( T.air.total_moles())
		lowertemp.temperature = max(min(lowertemp.temperature-2000, lowertemp.temperature / 2), 0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/consumable/enzyme
	name = "Универсальный фермент" // Universal Enzyme
	id = "enzyme"
	description = "Особый катализатор, значительно ускоряющий некоторые кулинарные процессы."
	reagent_state = LIQUID
	color = "#282314" // rgb: 54, 94, 48
	taste_description = "сладости"

/datum/reagent/consumable/dry_ramen
	name = "Сухого рамэна" // Dry Ramen
	id = "dry_ramen"
	description = "Еда космической эры, с 25 августа 1958 года. Включает сушёную лапшу с овощами и химикаты, закипающие при контакте с водой."
	reagent_state = SOLID
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "сухого рамэна, покрытого тем, что может быть просто вашими слезами"

/datum/reagent/consumable/hot_ramen
	name = "Горячий рамэн" // Hot Ramen
	id = "hot_ramen"
	description = "Заваренная лапша, ароматизаторы, идентичные натуральным. Вы будто бы снова в школе."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "дешёвого рамэна и воспоминаний"

/datum/reagent/consumable/hot_ramen/on_mob_life(mob/living/M)
	if(M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))
	return ..()

/datum/reagent/consumable/hell_ramen
	name = "Адский рамэн" // Hell Ramen
	id = "hell_ramen"
	description = "Заваренная лапша, ароматизаторы, идентичные натуральным. Вы будто бы снова в школе… В АДУ."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "ОСТРОГО рамэна"

/datum/reagent/consumable/hell_ramen/on_mob_life(mob/living/M)
	M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
	return ..()

/datum/reagent/consumable/flour
	name = "Мука" // flour
	id = "flour"
	description = "Ей натираются, притворяясь призраком"
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_description = "муки"

/datum/reagent/consumable/flour/reaction_turf(turf/T, volume)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/flour(T)

/datum/reagent/consumable/rice
	name = "Рис" // Rice
	id = "rice"
	description = "Наслаждайтесь прекрасным отсутствием вкуса."
	reagent_state = SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_description = "риса"

/datum/reagent/consumable/cherryjelly
	name = "Вишнёвое желе" // Cherry Jelly
	id = "cherryjelly"
	description = "Самое лучшее. Намазывать только на продукты с отличной поперечной симметрией."
	reagent_state = LIQUID
	color = "#801E28" // rgb: 128, 30, 40
	taste_description = "вишнёвого желе"

/datum/reagent/consumable/bluecherryjelly
	name = "Желе из синей вишни" // Blue Cherry Jelly
	id = "bluecherryjelly"
	description = "Синий и более вкусный вид вишнёвого желе."
	reagent_state = LIQUID
	color = "#00F0FF"
	taste_description = "блюза"

/datum/reagent/consumable/egg
	name = "Яйцо" // Egg
	id = "egg"
	description = "Жидкая и липкая смесь прозрачной и жёлтой жидкостей."
	reagent_state = LIQUID
	color = "#F0C814"
	taste_description = "яиц"

/datum/reagent/consumable/egg/on_mob_life(mob/living/M)
	if(prob(3))
		M.reagents.add_reagent("cholesterol", rand(1,2))
	return ..()

/datum/reagent/consumable/corn_starch
	name = "Кукурузный крахмал" // Corn Starch
	id = "corn_starch"
	description = "Порошкообразный крахмал, полученный из кукурузных эндоспермов. Используется как загуститель для соусов и пудингов."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "муки"

/datum/reagent/consumable/corn_syrup
	name = "Кукурузный сироп" // Corn Syrup
	id = "corn_syrup"
	description = "Сладкий сироп, получаемый из кукурузного крахмала. Для этого крахмал преобразуют в мальтозу и другие сахара."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "дешёвого сахарозаменителя"

/datum/reagent/consumable/corn_syrup/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 1.2)
	return ..()

/datum/reagent/consumable/vhfcs
	name = "Высокофруктозный кукурузный сироп" // Very-high-fructose corn syrup
	id = "vhfcs"
	description = "Невероятно сладкий сироп. Создаётся из кукурузного сиропа, чьи сахара превращены ферментами во фруктозу."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "диабета"

/datum/reagent/consumable/vhfcs/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 2.4)
	return ..()

/datum/reagent/consumable/honey
	name = "Мёд" // Honey
	id = "honey"
	description = "Сладкое вещество, вырабатываемое пчёлами путём частичного пищеварения. Пчелиная блевотина."
	reagent_state = LIQUID
	color = "#d3a308"
	nutriment_factor = 15 * REAGENTS_METABOLISM
	taste_description = "сладости"

/datum/reagent/consumable/honey/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.reagents.add_reagent("sugar", 3)
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-3, FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/onion
	name = "Концентрированный луковый сок" // Concentrated Onion Juice
	id = "onionjuice"
	description = "Вещество с резким вкусом. Может вызвать частичную слепоту."
	color = "#c0c9a0"
	taste_description = "едкости"

/datum/reagent/consumable/onion/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		if(!M.is_mouth_covered() && !M.is_eyes_covered())
			if(!M.get_organ_slot("eyes"))	//can't blind somebody with no eyes
				to_chat(M, "<span class = 'notice'>Ваши глазницы намокли.</span>")
			else
				if(!M.eye_blurry)
					to_chat(M, "<span class = 'warning'>У вас наворачиваются слёзы!</span>")
				M.EyeBlind(2)
				M.EyeBlurry(5)
	..()

/datum/reagent/consumable/chocolate
	name = "Шоколад" // Chocolate
	id = "chocolate"
	description = "Шоколад — это восхитительный продукт, получаемый из семян какао-дерева теоброма."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM		//same as pure cocoa powder, because it makes no sense that chocolate won't fill you up and make you fat
	color = "#2E2418"
	drink_icon = "chocolateglass"
	drink_name = "Стакан шоколада"
	drink_desc = "Вкуснятина"
	taste_description = "шоколада"

/datum/reagent/consumable/chocolate/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 0.2)
	return ..()

/datum/reagent/consumable/chocolate/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		new /obj/item/reagent_containers/food/snacks/choc_pile(T)

/datum/reagent/consumable/mugwort
	name = "Полынь" // Mugwort
	id = "mugwort"
	description = "Довольно горькая трава. Когда-то считалась обладающей магическими защитными свойствами."
	reagent_state = LIQUID
	color = "#21170E"
	taste_description = "чая"

/datum/reagent/consumable/mugwort/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && M.mind)
		if(M.mind.special_role == SPECIAL_ROLE_WIZARD)
			update_flags |= M.adjustToxLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
			update_flags |= M.adjustOxyLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
			update_flags |= M.adjustBruteLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
			update_flags |= M.adjustFireLoss(-1*REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/porktonium
	name = "Хрютоний" // Porktonium
	id = "porktonium"
	description = "Высокорадиоактивный свиной субпродукт. Впервые обнаруженный в хот-догах."
	reagent_state = LIQUID
	color = "#AB5D5D"
	metabolization_rate = 0.2
	overdose_threshold = 133
	harmless = FALSE
	taste_description = "бекона"

/datum/reagent/consumable/porktonium/overdose_process(mob/living/M, severity)
	if(prob(15))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("radium", 15)
		M.reagents.add_reagent("cyanide", 10)
	return list(0, STATUS_UPDATE_NONE)

/datum/reagent/consumable/chicken_soup
	name = "Куриный суп" // Chicken soup
	id = "chicken_soup"
	description = "Старинное домашнее средство от лёгких болезней."
	reagent_state = LIQUID
	color = "#B4B400"
	metabolization_rate = 0.2
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	taste_description = "бульона"

/datum/reagent/consumable/cheese
	name = "Сыр" // Cheese
	id = "cheese"
	description = "Немного сыра. Вылейте его, чтобы он затвердел."
	reagent_state = SOLID
	color = "#FFFF00"
	taste_description = "сыра"

/datum/reagent/consumable/cheese/on_mob_life(mob/living/M)
	if(prob(3))
		M.reagents.add_reagent("cholesterol", rand(1,2))
	return ..()

/datum/reagent/consumable/cheese/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		new /obj/item/reagent_containers/food/snacks/cheesewedge(T)

/datum/reagent/consumable/fake_cheese
	name = "Сырозаменитель" // Cheese substitute
	id = "fake_cheese"
	description = "Сыроподобное вещество, полученное из настоящего сыра."
	reagent_state = LIQUID
	color = "#B2B139"
	overdose_threshold = 50
	addiction_chance = 2
	addiction_chance_additional = 10
	addiction_threshold = 5
	minor_addiction = TRUE
	harmless = FALSE
	taste_description = "сыра?"

/datum/reagent/consumable/fake_cheese/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(8))
		to_chat(M, "<span class='warning'>У вас урчит в животе. Ваши мысли превращаются в сыр, и вы начинаете потеть.</span>")
		update_flags |= M.adjustToxLoss(rand(1,2), FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/weird_cheese
	name = "Странный сыр" // Weird cheese
	id = "weird_cheese"
	description = "Черт, я даже не знаю, сыр ли это. Что бы это ни было, это ненормально. Если хотите, вылейте его, чтобы он затвердел."
	reagent_state = SOLID
	color = "#50FF00"
	addiction_chance = 1
	addiction_chance_additional = 10
	addiction_threshold = 5
	minor_addiction = TRUE
	taste_description = "сы-ы-ы-ы-ы-ы-ы-ра?…"

/datum/reagent/consumable/weird_cheese/on_mob_life(mob/living/M)
	if(prob(5))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	return ..()

/datum/reagent/consumable/weird_cheese/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		new /obj/item/reagent_containers/food/snacks/weirdcheesewedge(T)

/datum/reagent/consumable/beans
	name = "Жареные бобы" // Refried beans
	id = "beans"
	description = "Блюдо из протертой фасоли, пожаренной на сале."
	reagent_state = LIQUID
	color = "#684435"
	taste_description = "буррито"

/datum/reagent/consumable/bread
	name = "Хлеб" // Bread
	id = "bread"
	description = "Хлеб! Да, хлеб."
	reagent_state = SOLID
	color = "#9C5013"
	taste_description = "хлеба"

/datum/reagent/consumable/soybeanoil
	name = "Космическое соевое масло" // Space-soybean oil
	id = "soybeanoil"
	description = "Масло из внеземных соевых бобов."
	reagent_state = LIQUID
	color = "#B1B0B0"
	taste_description = "масла"

/datum/reagent/consumable/soybeanoil/on_mob_life(mob/living/M)
	if(prob(10))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("porktonium", 5)
	return ..()

/datum/reagent/consumable/hydrogenated_soybeanoil
	name = "Частично гидрогенизированное космическое соевое масло" // Partially hydrogenated space-soybean oil
	id = "hydrogenated_soybeanoil"
	description = "Масло из внеземных соевых бобов. Добавленные дополнительные атомы водорода делают его насыщеннее."
	reagent_state = LIQUID
	color = "#B1B0B0"
	metabolization_rate = 0.2
	overdose_threshold = 75
	harmless = FALSE
	taste_description = "масла"

/datum/reagent/consumable/hydrogenated_soybeanoil/on_mob_life(mob/living/M)
	if(prob(15))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("porktonium", 5)
	if(volume >= 75)
		metabolization_rate = 0.4
	else
		metabolization_rate = 0.2
	return ..()

/datum/reagent/consumable/hydrogenated_soybeanoil/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(33))
		to_chat(M, "<span class='warning'>Вы чувствуете ужасную слабость.</span>")
	if(prob(10))
		to_chat(M, "<span class='warning'>Вы задыхаетесь!</span>")
		update_flags |= M.adjustOxyLoss(5, FALSE)
	if(prob(5))
		to_chat(M, "<span class='warning'>Вы чувствуете резкую боль в груди!</span>")
		update_flags |= M.adjustOxyLoss(25, FALSE)
		update_flags |= M.Stun(5, FALSE)
		update_flags |= M.Paralyse(10, FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/meatslurry
	name = "Мясная суспензия" // Meat Slurry
	id = "meatslurry"
	description = "Паста из сильно переработанного органического материала. Подозрительно схожа с консервированной ветчиной."
	reagent_state = LIQUID
	color = "#EBD7D7"
	taste_description = "мяса?"

/datum/reagent/consumable/meatslurry/on_mob_life(mob/living/M)
	if(prob(4))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	return ..()

/datum/reagent/consumable/meatslurry/reaction_turf(turf/T, volume)
	if(prob(10) && volume >= 5 && !isspaceturf(T))
		new /obj/effect/decal/cleanable/blood/gibs/cleangibs(T)
		playsound(T, 'sound/effects/splat.ogg', 50, 1, -3)

/datum/reagent/consumable/mashedpotatoes
	name = "Картофельное пюре" // Mashed potatoes
	id = "mashedpotatoes"
	description = "Крахмальная съедобная паста из отварного картофеля."
	reagent_state = SOLID
	color = "#D6D9C1"
	taste_description = "картофеля"

/datum/reagent/consumable/gravy
	name = "Подлива" // Gravy
	id = "gravy"
	description = "Пикантный соус, приготовленный из мясной заправки и молока."
	reagent_state = LIQUID
	color = "#B4641B"
	taste_description = "подливы"


///Food Related, but non-nutritious

/datum/reagent/questionmark // food poisoning
	name = "????"
	id = "????"
	description = "Неприятное нераспознаваемое вещество."
	reagent_state = LIQUID
	color = "#63DE63"
	taste_description = "горелой еды"

/datum/reagent/questionmark/reaction_mob(mob/living/carbon/human/H, method = REAGENT_TOUCH, volume)
	if(istype(H) && method == REAGENT_INGEST)
		if(H.dna.species.taste_sensitivity < TASTE_SENSITIVITY_NO_TASTE) // If you can taste it, then you know how awful it is.
			H.Stun(2, FALSE)
			H.Weaken(2, FALSE)
			H.update_canmove()
			to_chat(H, "<span class='danger'>Бе! Съесть это было ужасной идеей!</span>")
		if(NO_HUNGER in H.dna.species.species_traits) //If you don't eat, then you can't get food poisoning
			return
		H.ForceContractDisease(new /datum/disease/food_poisoning(0))

/datum/reagent/msg
	name = "Глутамат натрия" // Monosodium glutamate
	id = "msg"
	description = "Глутамат натрия — это натриевая соль, известная главным образом своим использованием в качестве противоречивого усилителя вкуса."
	reagent_state = LIQUID
	color = "#F5F5F5"
	metabolization_rate = 0.2
	taste_description = "великолепной готовки"
	taste_mult = 4

/datum/reagent/msg/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(5))
		if(prob(10))
			update_flags |= M.adjustToxLoss(rand(2,4), FALSE)
		if(prob(7))
			to_chat(M, "<span class='warning'>Вас одолевает ужасная мигрень.</span>")
			update_flags |= M.Stun(rand(2,5), FALSE)
	return ..() | update_flags

/datum/reagent/cholesterol
	name = "Холестерин" // cholesterol
	id = "cholesterol"
	description = "Чистый холестерин. Вероятно, не очень полезен."
	reagent_state = LIQUID
	color = "#FFFAC8"
	taste_description = "инфаркта"

/datum/reagent/cholesterol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(volume >= 25 && prob(volume*0.15))
		to_chat(M, "<span class='warning'>Вы чувствуете [pick("в груди что-то необычное","дискомфорт в груди","себя отвратительно в районе груди","в груди что-то странное","тепло в груди")]!</span>")
		update_flags |= M.adjustToxLoss(rand(1,2), FALSE)
	else if(volume >= 45 && prob(volume*0.08))
		to_chat(M, "<span class='warning'>У вас [pick("болит","колет","ноет","жжёт")] в груди!</span>")
		update_flags |= M.adjustToxLoss(rand(2,4), FALSE)
		update_flags |= M.Stun(1, FALSE)
	else if(volume >= 150 && prob(volume*0.01))
		to_chat(M, "<span class='warning'>Ваша грудь горит от боли!</span>")
		update_flags |= M.Stun(1, FALSE)
		update_flags |= M.Weaken(1, FALSE)
		M.ForceContractDisease(new /datum/disease/critical/heart_failure(0))
	return ..() | update_flags

/datum/reagent/fungus
	name = "Космический грибок" // Space fungus
	id = "fungus"
	description = "На стенах станции обнаружены соскобы какого-то неизвестного грибка."
	reagent_state = LIQUID
	color = "#C87D28"
	taste_description = "плесени"

/datum/reagent/fungus/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		var/ranchance = rand(1,10)
		if(ranchance == 1)
			to_chat(M, "<span class='warning'>Вы себя очень плохо чувствуете.</span>")
			M.reagents.add_reagent("toxin", rand(1,5))
		else if(ranchance <= 5)
			to_chat(M, "<span class='warning'>На вкус это просто МЕЗРКО.</span>")
			M.ForceContractDisease(new /datum/disease/food_poisoning(0))
		else
			to_chat(M, "<span class='warning'>Фу!</span>")

/datum/reagent/ectoplasm
	name = "Эктоплазма" // Ectoplasm
	id = "ectoplasm"
	description = "Причудливая желеобразная субстанция. Предположительно, получена из призраков."
	reagent_state = LIQUID
	color = "#8EAE7B"
	process_flags = ORGANIC | SYNTHETIC		//Because apparently ghosts in the shell
	taste_description = "призраков"

/datum/reagent/ectoplasm/on_mob_life(mob/living/M)
	var/spooky_message = pick("Вы краем глаза замечаете какое-то движение , но там ничего нет…", "Вы начинаете моргать. Кажется, здесь есть что-то, чего вы не видите…", "Вас начинается трясти.", "Вы чувствуете тревогу.", "Вы вздрагиваете, как от холода…", "Вы чувствуете, как что-то проскальзывает по вашей спине…")
	if(prob(8))
		to_chat(M, "<span class='warning'>[spooky_message]</span>")
	return ..()

/datum/reagent/ectoplasm/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		var/spooky_eat = pick("Ugh, why did you eat that? Your mouth feels haunted. Haunted with bad flavors.", "Ugh, why did you eat that? It has the texture of ham aspic.  From the 1950s.  Left out in the sun.", "Ugh, why did you eat that? It tastes like a ghost fart.", "Ugh, why did you eat that? It tastes like flavor died.")
		to_chat(M, "<span class='warning'>[spooky_eat]</span>")

/datum/reagent/ectoplasm/reaction_turf(turf/T, volume)
	if(volume >= 10 && !isspaceturf(T))
		new /obj/item/reagent_containers/food/snacks/ectoplasm(T)

/datum/reagent/consumable/bread/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		new /obj/item/reagent_containers/food/snacks/breadslice(T)

		///Vomit///

/datum/reagent/vomit
	name = "Блевотина" // Vomit
	id = "vomit"
	description = "Как будто кто-то потерял тут свой обед. А потом собрал его… Фу-у…"
	reagent_state = LIQUID
	color = "#FFFF00"
	taste_description = "рвоты"

/datum/reagent/vomit/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		T.add_vomit_floor()

/datum/reagent/greenvomit
	name = "Зелёная блевотина" // Green vomit
	id = "green_vomit"
	description = "Ох, это не может быть естественным. Гадость."
	reagent_state = LIQUID
	color = "#78FF74"
	taste_description = "рвоты"

/datum/reagent/greenvomit/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		T.add_vomit_floor(FALSE, TRUE)

////Lavaland Flora Reagents////

/datum/reagent/consumable/entpoly
	name = "Энтропийный полипний" // Entropic Polypnium
	id = "entpoly"
	description = "Ихор определённого гриба. На чёрный день."
	color = "#1d043d"
	taste_description = "горьких грибов"

/datum/reagent/consumable/entpoly/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle >= 10)
		update_flags |= M.Paralyse(2, FALSE)
	if(prob(20))
		update_flags |= M.LoseBreath(4, FALSE)
		update_flags |= M.adjustBrainLoss(2 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustToxLoss(3 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustStaminaLoss(10 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.EyeBlurry(5, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/tinlux
	name = "Египетский лишай" // Tinea Luxor
	id = "tinlux"
	description = "Стимулирующий ихор. Вызывает рост люминесцентных грибов на коже."
	color = "#b5a213"
	var/light_activated = FALSE
	taste_description = "покалывающих грибов"

/datum/reagent/consumable/tinlux/on_mob_life(mob/living/M)
	if(!light_activated)
		M.set_light(2)
		light_activated = TRUE
	return ..()

/datum/reagent/consumable/tinlux/on_mob_delete(mob/living/M)
	M.set_light(0)

/datum/reagent/consumable/vitfro
	name = "Стеклопена" // Vitrium Froth
	id = "vitfro"
	description = "Пенящаяся паста, которая заживляет раны на коже."
	color = "#d3a308"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "фруктового гриба"

/datum/reagent/consumable/vitfro/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(80))
		update_flags |= M.adjustBruteLoss(-1 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
		update_flags |= M.adjustFireLoss(-1 * REAGENTS_EFFECT_MULTIPLIER, FALSE)
	return ..() | update_flags
