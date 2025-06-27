/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.

/datum/reagent/consumable
	name = "Съедомная масса"
	id = "consumable"
	harmless = TRUE
	taste_description = "чего-то съедобного"
	taste_mult = 4
	var/nutriment_factor = 1 * REAGENTS_METABOLISM
	var/diet_flags = DIET_OMNI | DIET_HERB | DIET_CARN

/datum/reagent/consumable/on_mob_life(mob/living/M)
	if(!isvampire(M))
		M.adjust_nutrition(nutriment_factor)	// For hunger and fatness
	return ..()

/datum/reagent/consumable/nutriment		// Pure nutriment, universally digestable and thus slightly less effective
	name = "Питательные вещества"
	id = "nutriment"
	description = "Сомнительная смесь чистых питательных веществ, обычно встречающихся в переработанных продуктах питания."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48
	var/brute_heal = 1
	var/burn_heal = 0

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(!isvampire(M))
		update_flags |= M.adjustBruteLoss(-brute_heal, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-burn_heal, FALSE, affect_robotic = FALSE)
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


/datum/reagent/consumable/nutriment/taste_amplification(mob/living/user)
	. = list()
	var/list/nutriment_taste_data = data
	for(var/nutriment_taste in nutriment_taste_data)
		var/ratio = nutriment_taste_data[nutriment_taste]
		var/amount = ratio * taste_mult * volume
		.[nutriment_taste] = amount


/datum/reagent/consumable/nutriment/protein			// Meat-based protein, digestable by carnivores and omnivores, worthless to herbivores
	name = "Белки"
	id = "protein"
	description = "Смесь белков и жиров, которые обычно содержатся в мясе и крови животных."
	diet_flags = DIET_CARN | DIET_OMNI

/datum/reagent/consumable/nutriment/plantmatter		// Plant-based biomatter, digestable by herbivores and omnivores, worthless to carnivores
	name = "Растительная масса"
	id = "plantmatter"
	description = "Богатые витаминами волокна и натуральные сахара, которые обычно содержатся в свежих продуктах."
	diet_flags = DIET_HERB | DIET_OMNI

/datum/reagent/consumable/nutriment/vitamin
	name = "Витамины"
	id = "vitamin"
	description = "Все лучшие витамины, минералы и углеводы, необходимые организму, в чистом виде."
	reagent_state = SOLID
	color = "#664330" // rgb: 102, 67, 48
	brute_heal = 1
	burn_heal = 1

/datum/reagent/consumable/nutriment/vitamin/on_mob_life(mob/living/M)
	if(M.satiety < 600)
		M.satiety += 30
	return ..()

/datum/reagent/consumable/sugar
	name = "Сахар"
	id = "sugar"
	description = "Органическое соединение, широко известное как столовый сахар и иногда называемое сахарозой. Это белый кристаллический порошок без запаха, обладающий приятным сладким вкусом."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	overdose_threshold = 30
	taste_description = "сладости"
	taste_mult = 1.5

/datum/reagent/consumable/sugar/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustDrowsy(-10 SECONDS)
	if(current_cycle >= 90)
		M.AdjustJitter(4 SECONDS)
	if(prob(25))
		M.AdjustParalysis(-2 SECONDS)
		M.AdjustStunned(-2 SECONDS)
		M.AdjustWeakened(-2 SECONDS)
	if(prob(4))
		M.reagents.add_reagent("epinephrine", 1.2)
	return ..() | update_flags

/datum/reagent/consumable/sugar/overdose_start(mob/living/carbon/human/affected)
	to_chat(affected, span_danger("Вы теряете сознание от гипергликемического шока!"))
	affected.overlay_fullscreen("hyperglycemia", /atom/movable/screen/fullscreen/impaired, 1)
	affected.emote("faint")
	if(ishuman(affected))
		affected.physiology.hunger_mod *= 2
	..()

/datum/reagent/consumable/sugar/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	M.AdjustJitter(5 SECONDS)
	if(prob(10))
		to_chat(M, span_danger("У вас болит голова."))
	if(prob(5))
		to_chat(M, span_danger("Вы чувствуете, как силы покидают вас."))
	if(volume >= 60)
		M.AdjustKnockdown(5 SECONDS)
		M.adjustToxLoss(1)
		if(prob(3))
			M.emote("collapse")
		if(prob(3))
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.vomit()
	return ..() | update_flags


/datum/reagent/consumable/sugar/overdose_end(mob/living/carbon/human/affected)
	affected.clear_fullscreen("hyperglycemia")
	if(ishuman(affected))
		affected.physiology.hunger_mod *= 0.5
	..()


/datum/reagent/consumable/soysauce
	name = "Соевый соус"
	id = "soysauce"
	description = "Солёный соус из соевого растения."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" // rgb: 121, 35, 0
	taste_description = "сои"

/datum/reagent/consumable/ketchup
	name = "Кетчуп"
	id = "ketchup"
	description = "Кетчуп, кекчуп, кечап, как будет угодно. Это томатная паста."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" // rgb: 115, 16, 8
	taste_description = "кетчупа"

/datum/reagent/consumable/tomatosauce
	name = "Томатный соус"
	id = "tsauce"
	description = "Отец всех соусов. Помидоры, немного специй и ничего лишнего."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#ee1000"
	taste_description = "томатного соуса"

/datum/reagent/consumable/cheesesauce
	name = "Сырный соус"
	id = "csauce"
	description = "Сыр, сливки и молоко... максимальная концентрация белка!"
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#e6d600"
	taste_description = "сырного соуса"

/datum/reagent/consumable/mushroomsauce
	name = "Грибной соус"
	id = "msauce"
	description = "Сливочный соус с грибами, имеет довольно резкий запах."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#beb58a"
	taste_description = "грибного соуса"

/datum/reagent/consumable/garlicsauce
	name = "Чесночный соус"
	id = "gsauce"
	description = "Крепкий чесночный с резким запахом. Некоторые члены экипажа наверняка будут шипеть на вас из-за этого."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#fffee1"
	taste_description = "чесночного соуса"

/datum/reagent/consumable/diablosauce
	name = "Соус \"Диабло\""
	id = "dsauce"
	description = "Древний жгучий соус, рецепт которого практически не изменился с момента его создания."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#440804"
	taste_description = "острого томатного соуса"

/datum/reagent/consumable/custard
	name = "Заварной крем"
	id = "custard"
	description = "Мягкий и сладкий крем, используемый в кондитерских изделиях."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#fffed1"
	taste_description = "сладкого мягкого крема"

/datum/reagent/consumable/capsaicin
	name = "Капсаициновое масло"
	id = "capsaicin"
	description = "Именно это делает чили острым."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = span_warning("ОСТРОТЫ")
	taste_mult = 1.5

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/M)
	var/is_slime = isslime(M)
	var/adjusted_temp = 0
	switch(current_cycle)
		if(1 to 15)
			adjusted_temp = 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(is_slime)
				adjusted_temp += rand(5,20)
			M.adjust_bodytemperature(adjusted_temp)
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
		if(15 to 25)
			adjusted_temp = 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(is_slime)
				adjusted_temp += rand(10,20)
			M.adjust_bodytemperature(adjusted_temp)
		if(25 to 35)
			adjusted_temp = 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(is_slime)
				adjusted_temp += rand(15,20)
			M.adjust_bodytemperature(adjusted_temp)
		if(35 to INFINITY)
			adjusted_temp = 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(is_slime)
				adjusted_temp += rand(20,25)
			M.adjust_bodytemperature(adjusted_temp)
	return ..()

/datum/reagent/consumable/condensedcapsaicin
	name = "Сгущённое капсаициновое масло"
	id = "condensedcapsaicin"
	description = "Ещё острее."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8
	taste_description = span_userdanger("НЕРЕАЛЬНОЙ ОСТРОТЫ")

/datum/reagent/consumable/condensedcapsaicin/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/victim = M
			var/mouth_covered = FALSE
			var/eyes_covered = FALSE
			var/obj/item/safe_thing = null
			if(victim.wear_mask)
				if(victim.wear_mask.flags_cover & MASKCOVERSEYES)
					eyes_covered = TRUE
					safe_thing = victim.wear_mask
				if(victim.wear_mask.flags_cover & MASKCOVERSMOUTH)
					mouth_covered = TRUE
					safe_thing = victim.wear_mask
				if(isclothing(victim.wear_mask))
					var/obj/item/clothing/cloth = victim.wear_mask
					if(cloth.clothing_flags & BLOCK_CAPSAICIN)
						mouth_covered = TRUE
						eyes_covered = TRUE
						safe_thing = victim.wear_mask
			if(victim.head)
				if(victim.head.flags_cover & MASKCOVERSEYES)
					eyes_covered = TRUE
					safe_thing = victim.head
				if(victim.head.flags_cover & MASKCOVERSMOUTH)
					mouth_covered = TRUE
					safe_thing = victim.head
				if(isclothing(victim.head))
					var/obj/item/clothing/cloth = victim.head
					if(cloth.clothing_flags & BLOCK_CAPSAICIN)
						mouth_covered = TRUE
						eyes_covered = TRUE
						safe_thing = victim.head
			if(victim.glasses)
				eyes_covered = TRUE
				if(!safe_thing)
					safe_thing = victim.glasses
			if( eyes_covered && mouth_covered )
				to_chat(victim, span_danger("[safe_thing] защища[pluralize_ru(safe_thing, "ет", "ют")] ваше лицо от перца!"))
				return
			else if( mouth_covered )	// Reduced effects if partially protected
				to_chat(victim, span_danger("[safe_thing] почти полностью защища[pluralize_ru(safe_thing, "ет", "ют")] ваше лицо от перца!"))
				if(prob(20))
					victim.emote("scream")
				victim.EyeBlurry(6 SECONDS)
				victim.EyeBlind(2 SECONDS)
				victim.Confused(6 SECONDS)
				victim.damageoverlaytemp = 60
				victim.Weaken(6 SECONDS)
				victim.drop_from_active_hand()
				return
			else if( eyes_covered ) // Eye cover is better than mouth cover but not best
				to_chat(victim, span_danger("[safe_thing] частично защища[pluralize_ru(safe_thing, "ет", "ют")] ваше лицо от перца!"))
				if(prob(20))
					victim.emote("scream")
				victim.EyeBlurry(4 SECONDS)
				victim.EyeBlind(2 SECONDS)
				victim.Confused(4 SECONDS)
				victim.damageoverlaytemp = 40
				victim.Weaken(4 SECONDS)
				victim.drop_from_active_hand()
				return
			else // Oh dear :D
				if(prob(20))
					victim.emote("scream")
				to_chat(victim, span_danger("Струя перца летит прямо вам в глаза!"))
				victim.EyeBlurry(10 SECONDS)
				victim.EyeBlind(4 SECONDS)
				victim.Confused(12 SECONDS)
				victim.damageoverlaytemp = 75
				victim.Weaken(10 SECONDS)
				victim.drop_from_active_hand()

/datum/reagent/consumable/frostoil
	name = "Ледяное масло"
	id = "frostoil"
	description = "Масло, сильно охлаждающее тело. Добывается из ледяных перцев."
	reagent_state = LIQUID
	color = "#8BA6E9" // rgb: 139, 166, 233
	process_flags = ORGANIC | SYNTHETIC
	taste_description = "<font color='lightblue'>холода</span>"


/datum/reagent/consumable/frostoil/on_mob_add(mob/living/user)
	. = ..()
	if(isslime(user))
		user.add_movespeed_modifier(/datum/movespeed_modifier/slime_frostoil_mod)


/datum/reagent/consumable/frostoil/on_mob_delete(mob/living/user)
	. = ..()
	user.remove_movespeed_modifier(/datum/movespeed_modifier/slime_frostoil_mod)


/datum/reagent/consumable/frostoil/on_mob_life(mob/living/user)
	var/is_slime = isslime(user)
	var/adjusted_temp = 0
	if(!is_slime)
		user.remove_movespeed_modifier(/datum/movespeed_modifier/slime_frostoil_mod)
	switch(current_cycle)
		if(1 to 15)
			adjusted_temp = 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(is_slime)
				adjusted_temp += rand(5,20)
			user.adjust_bodytemperature(-adjusted_temp)
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
		if(15 to 25)
			adjusted_temp = 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(is_slime)
				adjusted_temp += rand(10,20)
			user.adjust_bodytemperature(-adjusted_temp)
		if(25 to 35)
			adjusted_temp = 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(is_slime)
				adjusted_temp += rand(15,20)
			user.adjust_bodytemperature(-adjusted_temp)
			if(prob(1))
				user.emote("shiver")
		if(35 to INFINITY)
			adjusted_temp = 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(is_slime)
				adjusted_temp += rand(20,25)
			user.adjust_bodytemperature(-adjusted_temp)
			if(prob(1))
				user.emote("shiver")
	return ..()


/datum/reagent/consumable/frostoil/reaction_turf(turf/T, volume)
	if(volume >= 5)
		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(15, 30))

/datum/reagent/consumable/sodiumchloride
	name = "Соль"
	id = "sodiumchloride"
	description = "Хлорид натрия, обычная поваренная соль."
	reagent_state = SOLID
	color = "#B1B0B0"
	harmless = FALSE
	overdose_threshold = 15
	taste_mult = 2
	taste_description = "соли"

/datum/reagent/consumable/sodiumchloride/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(70))
		update_flags |= M.adjustBrainLoss(1, FALSE)
	return ..() | update_flags

/datum/reagent/consumable/blackpepper
	name = "Чёрный перец"
	id = "blackpepper"
	description = "Порошок, измельченный из перца. Только не вдыхайте его полной грудью."
	reagent_state = SOLID
	taste_description = "перца"

/datum/reagent/consumable/cocoa
	name = "Какао-порошок"
	id = "cocoa"
	description = "Жирная, горькая паста из какао-бобов."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "горького какао"

/datum/reagent/consumable/vanilla
	name = "Ванильный порошок"
	id = "vanilla"
	description = "Жирная, горькая паста из стручков ванили."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#FFFACD"
	taste_description = "горькой ванили"

/datum/reagent/consumable/herbs
	name = "Микс трав"
	id = "herbsmix"
	description = "Смесь различных трав."
	reagent_state = SOLID
	color = "#2c5c04"
	taste_description = "сухих трав"

/datum/reagent/consumable/hot_coco
	name = "Горячий шоколад"
	id = "hot_coco"
	description = "Сделано с любовью! И какао-бобами."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16
	taste_description = "горячего шоколада"

/datum/reagent/consumable/hot_coco/on_mob_life(mob/living/M)
	if(M.bodytemperature < BODYTEMP_NORMAL)
		M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT)
	return ..()

/datum/reagent/consumable/garlic
	name = "Чесночный сок"
	id = "garlic"
	description = "Cспелый чеснок. Повара его любят, но от него может неприятно пахнуть."
	color = "#FEFEFE"
	taste_description = "чеснока"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/garlic/on_mob_life(mob/living/carbon/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/datum/antagonist/vampire/vamp = H.mind?.has_antag_datum(/datum/antagonist/vampire)
		if(vamp && vamp.is_garlic_affected && !vamp.get_ability(/datum/vampire_passive/full)) //incapacitating but not lethal.
			if(prob(min(25, current_cycle)))
				to_chat(H, span_danger("Аромат чеснока не выветривается из вашего носа! Вы едва можете думать..."))
				H.Weaken(2 SECONDS)
				H.Jitter(20 SECONDS)
				H.fakevomit()
		else
			if(H.job == JOB_TITLE_CHEF)
				if(prob(20)) //stays in the system much longer than sprinkles/banana juice, so heals slower to partially compensate
					update_flags |= H.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
					update_flags |= H.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/sprinkles
	name = "Посыпка"
	id = "sprinkles"
	description = "Разноцветные кусочки сахара, обычно встречающиеся на пончиках. Копы любят такое."
	color = "#FF00FF" // rgb: 255, 0, 255
	taste_description = "хрустящей сладости"

/datum/reagent/consumable/sprinkles/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && (M.job in list(JOB_TITLE_OFFICER, JOB_TITLE_PILOT, JOB_TITLE_DETECTIVE, JOB_TITLE_WARDEN, JOB_TITLE_HOS, JOB_TITLE_BRIGDOC, JOB_TITLE_LAWYER, JOB_TITLE_JUDGE)))
		update_flags |= M.adjustBruteLoss(-1, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/cornoil
	name = "Кукурузное масло"
	id = "cornoil"
	description = "Масло, получаемое из различных видов кукурузы."
	reagent_state = LIQUID
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "кукурузного масла"

/datum/reagent/consumable/cornoil/reaction_turf(turf/simulated/T, volume)
	if(!istype(T))
		return
	if(volume >= 3)
		T.MakeSlippery(TURF_WET_WATER, 80 SECONDS)
	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air( T.air.total_moles())
		lowertemp.temperature = max(min(lowertemp.temperature-2000, lowertemp.temperature / 2), TCMB)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/consumable/cornoil/oliveoil
	name = "Оливковое масло"
	id = "oliveoil"
	description = "Масло, получаемое из молодых оливок. Очень жирное."
	reagent_state = LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#d3f558"
	taste_description = "горько-сладкого оливкового масла"

/datum/reagent/consumable/enzyme
	name = "Универсальный фермент"
	id = "enzyme"
	description = "Специальный катализатор, благодаря которому некоторые кулинарные химические реакции происходят мгновенно, а не занимают несколько часов или дней."
	reagent_state = LIQUID
	color = "#282314" // rgb: 54, 94, 48
	taste_description = "сладости"

/datum/reagent/consumable/dry_ramen
	name = "Сухой рамен"
	id = "dry_ramen"
	description = "Космическая еда начиная с 25 августа 1958 года. Содержит сушёную лапшу, овощи и химикаты, которые закипают при контакте с водой."
	reagent_state = SOLID
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "дешёвой лапши со специями"

/datum/reagent/consumable/hot_ramen
	name = "Горячий рамен"
	id = "hot_ramen"
	description = "Лапша варёная, ароматизаторы искусственные, а вы как будто бы снова в школе."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "дешёвой лапши и воспоминаний"

/datum/reagent/consumable/hot_ramen/on_mob_life(mob/living/M)
	if(M.bodytemperature < BODYTEMP_NORMAL)
		M.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT)
	return ..()

/datum/reagent/consumable/hell_ramen
	name = "Адский рамен"
	id = "hell_ramen"
	description = "Лапша варёная, ароматизаторы искусственные, а вы как будто бы снова в школе... В АДУ!"
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	taste_description = "острой лапши со специями"

/datum/reagent/consumable/hell_ramen/on_mob_life(mob/living/M)
	M.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT)
	return ..()

/datum/reagent/consumable/flour
	name = "Мука"
	id = "flour"
	description = "Это то, чем вы натираете себя, чтобы притвориться призраком."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_description = "муки"

/datum/reagent/consumable/flour/reaction_turf(turf/T, volume)
	if(!isspaceturf(T))
		new /obj/effect/decal/cleanable/flour(T)

/datum/reagent/consumable/rice
	name = "Рис"
	id = "rice"
	description = "Наслаждайтесь великолепным вкусом ничего."
	reagent_state = SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0
	taste_description = "риса"

/datum/reagent/consumable/buckwheat
	name = "Гречка"
	id = "buckwheat"
	description = "По слухам, советские люди питаются только водкой и... этим?"
	reagent_state = SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#8E633C" // rgb: 142, 99, 60
	taste_description = "сухой гречки"

/datum/reagent/consumable/cherryjelly
	name = "Вишнёвое желе"
	id = "cherryjelly"
	description = "Абсолютно лучший. Наносится только на продукты с отличной боковой симметрией."
	reagent_state = LIQUID
	color = "#801E28" // rgb: 128, 30, 40
	taste_description = "вишнёвого желе"

/datum/reagent/consumable/bluecherryjelly
	name = "Голубичное желе"
	id = "bluecherryjelly"
	description = "Более вкусная версия желе из голубики."
	reagent_state = LIQUID
	color = "#00F0FF"
	taste_description = "голубичного желе"

/datum/reagent/consumable/egg
	name = "Яйцо"
	id = "egg"
	description = "Текучая и вязкая смесь белка и желтка."
	reagent_state = LIQUID
	color = "#F0C814"
	taste_description = "яиц"

/datum/reagent/consumable/egg/on_mob_life(mob/living/M)
	if(prob(3))
		M.reagents.add_reagent("cholesterol", rand(1,2))
	return ..()

/datum/reagent/consumable/corn_starch
	name = "Кукурузный крахмал"
	id = "corn_starch"
	description = "Порошкообразный крахмал кукурузы, получаемый из эндосперма зерен. Используется в качестве загустителя для соусов и пудингов."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "муки"

/datum/reagent/consumable/corn_syrup
	name = "Кукурузный сироп"
	id = "corn_syrup"
	description = "Сладкий сироп, получаемый из кукурузного крахмала преобразованного в мальтозу и другие сахара."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "дешевого сахарозаменителя"

/datum/reagent/consumable/corn_syrup/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 1.2)
	return ..()

/datum/reagent/consumable/vhfcs
	name = "Высокофруктозный кукурузный сироп"
	id = "vhfcs"
	description = "Невероятно сладкая жидкость, созданная из кукурузного сиропа, обработанного ферментами для превращения сахаров во фруктозу."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "диабета"

/datum/reagent/consumable/vhfcs/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 2.4)
	return ..()

/datum/reagent/consumable/honey
	name = "Мёд"
	id = "honey"
	description = "Густое сладкое вещество, вырабатываемое пчелами в результате частичного переваривания. Пчелиная блевотина."
	reagent_state = LIQUID
	color = "#d3a308"
	nutriment_factor = 15 * REAGENTS_METABOLISM
	taste_description = "тягучей сладости"

/datum/reagent/consumable/honey/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	M.reagents.add_reagent("sugar", 3)
	if(prob(20))
		update_flags |= M.adjustBruteLoss(-3, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-1, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/onion
	name = "Концентрированный луковый сок"
	id = "onionjuice"
	description = "Сильное на вкус вещество, способное вызывать частичную слепоту."
	color = "#c0c9a0"
	taste_description = "едкости"

/datum/reagent/consumable/onion/reaction_mob(mob/living/M, method = REAGENT_TOUCH, volume)
	if(method == REAGENT_TOUCH)
		if(!M.is_mouth_covered() && !M.is_eyes_covered())
			if(!M.get_organ_slot(INTERNAL_ORGAN_EYES))	//can't blind somebody with no eyes
				to_chat(M, span_notice("Ваши глазные впадины кажутся влажными."))
			else
				if(!M.AmountEyeBlurry())
					to_chat(M, span_warning("Из ваших глаз брызжут слёзы!"))
				M.EyeBlind(4 SECONDS)
				M.EyeBlurry(10 SECONDS)
	..()

/datum/reagent/consumable/chocolate
	name = "Шоколад"
	id = "chocolate"
	description = "Шоколад - это восхитительный продукт, получаемый из семян дерева \"Theobroma cacao\"."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM		//same as pure cocoa powder, because it makes no sense that chocolate won't fill you up and make you fat
	color = "#2E2418"
	drink_icon = "chocolateglass"
	drink_name = "стакан шоколада"
	drink_desc = "Вкуснятина!"
	taste_description = "шоколада"

/datum/reagent/consumable/chocolate/on_mob_life(mob/living/M)
	M.reagents.add_reagent("sugar", 0.2)
	return ..()

/datum/reagent/consumable/chocolate/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		new /obj/item/reagent_containers/food/snacks/choc_pile(T)

/datum/reagent/consumable/mugwort
	name = "Полынь"
	id = "mugwort"
	description = "Довольно горькая трава, которая, как считается, обладает магическими защитными свойствами."
	reagent_state = LIQUID
	color = "#21170E"
	taste_description = "странного чая"

/datum/reagent/consumable/mugwort/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(ishuman(M) && M.mind)
		if(M.mind.special_role == SPECIAL_ROLE_WIZARD || M.mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)
			update_flags |= M.adjustToxLoss(-0.5, FALSE)
			update_flags |= M.adjustOxyLoss(-0.5, FALSE)
			update_flags |= M.adjustBruteLoss(-0.5, FALSE, affect_robotic = FALSE)
			update_flags |= M.adjustFireLoss(-0.5, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/porktonium
	name = "Порктониум"
	id = "porktonium"
	description = "Высокорадиоактивный побочный продукт свинины, впервые обнаруженный в хот-догах."
	reagent_state = LIQUID
	color = "#AB5D5D"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
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
	name = "Куриный бульон"
	id = "chicken_soup"
	description = "Старинное домашнее средство для лечения лёгких простудных заболеваний."
	reagent_state = LIQUID
	color = "#B4B400"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	nutriment_factor = 2.5 * REAGENTS_METABOLISM
	taste_description = "куриного бульона"

/datum/reagent/consumable/cheese
	name = "Сыр"
	id = "cheese"
	description = "Немного сыра. Вылейте его, чтобы он стал твердым."
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
	name = "Заменитель сыра"
	id = "fake_cheese"
	description = "Сыроподобное вещество, полученное из настоящего сыра."
	reagent_state = LIQUID
	color = "#B2B139"
	overdose_threshold = 50
	harmless = FALSE
	taste_description = "странного сыра"

/datum/reagent/consumable/fake_cheese/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(8))
		to_chat(M, span_warning("Вы чувствуете, как в животе что-то ерзает. Ваши мысли превращаются в сыр, и вы начинаете потеть."))
		update_flags |= M.adjustToxLoss(rand(1,2), FALSE)
	return list(0, update_flags)

/datum/reagent/consumable/weird_cheese
	name = "Странный сыр"
	id = "weird_cheese"
	description = "Чёрт, я даже не знаю, сыр ли это. Что бы это ни было, это ненормально. Если хотите, вылейте его, чтобы он стал твердым."
	reagent_state = SOLID
	color = "#50FF00"
	taste_description = "сыра..?"

/datum/reagent/consumable/weird_cheese/on_mob_life(mob/living/M)
	if(prob(5))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	return ..()

/datum/reagent/consumable/weird_cheese/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		new /obj/item/reagent_containers/food/snacks/weirdcheesewedge(T)

/datum/reagent/consumable/beans
	name = "Жареная фасоль"
	id = "beans"
	description = "Блюдо из фасолевого пюре, приготовленного с добавлением сала."
	reagent_state = LIQUID
	color = "#684435"
	taste_description = "бурритос"

/datum/reagent/consumable/bread
	name = "Хлеб"
	id = "bread"
	description = "Хлеб! Кто его не любит?"
	reagent_state = SOLID
	color = "#9C5013"
	taste_description = "хлеба"

/datum/reagent/consumable/soybeanoil
	name = "Соевое масло"
	id = "soybeanoil"
	description = "Масло, полученное из соевых бобов."
	reagent_state = LIQUID
	color = "#B1B0B0"
	taste_description = "соевого масла"

/datum/reagent/consumable/soybeanoil/on_mob_life(mob/living/M)
	if(prob(10))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("porktonium", 5)
	return ..()

/datum/reagent/consumable/hydrogenated_soybeanoil
	name = "Частично гидрогенизированное соевое масло"
	id = "hydrogenated_soybeanoil"
	description = "Масло, полученное из соевых бобов, в которое добавлены дополнительные атомы водорода для преобразования его в насыщенную форму."
	reagent_state = LIQUID
	color = "#B1B0B0"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 75
	harmless = FALSE
	taste_description = "насыщенного соевого масла"

/datum/reagent/consumable/hydrogenated_soybeanoil/on_mob_life(mob/living/M)
	if(prob(15))
		M.reagents.add_reagent("cholesterol", rand(1,3))
	if(prob(8))
		M.reagents.add_reagent("porktonium", 5)
	if(volume >= 75)
		metabolization_rate = 1 * REAGENTS_METABOLISM
	else
		metabolization_rate = 0.5 * REAGENTS_METABOLISM
	return ..()

/datum/reagent/consumable/hydrogenated_soybeanoil/overdose_process(mob/living/M, severity)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(33))
		to_chat(M, span_warning("Вы чувствуете ужасную слабость."))
	if(prob(10))
		to_chat(M, span_warning("У вас перехватило дыхание!"))
		update_flags |= M.adjustOxyLoss(5, FALSE)
	if(prob(5))
		to_chat(M, span_warning("Вы чувствуете острую боль в груди!"))
		update_flags |= M.adjustOxyLoss(25, FALSE)
		M.Stun(10 SECONDS)
		M.Paralyse(20 SECONDS)
	return list(0, update_flags)

/datum/reagent/consumable/meatslurry
	name = "Мясная жижа"
	id = "meatslurry"
	description = "Паста, состоящая из сильно переработанного органического материала. Напоминает спред из ветчины."
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
	name = "Картофельное пюре"
	id = "mashedpotatoes"
	description = "Паста из вареного картофеля."
	reagent_state = SOLID
	color = "#D6D9C1"
	taste_description = "картофеля"

/datum/reagent/consumable/gravy
	name = "Подливка"
	id = "gravy"
	description = "Пикантный соус, приготовленный из простого мясного рулета и молока."
	reagent_state = LIQUID
	color = "#B4641B"
	taste_description = "подливки"


///Food Related, but non-nutritious

/datum/reagent/questionmark // food poisoning
	name = "Сгоревшая пищевая масса"
	id = "????"
	description = "Отвратительная и ядовитая субстанция."
	reagent_state = LIQUID
	color = "#63DE63"
	taste_description = "сгоревшей еды"

/datum/reagent/questionmark/reaction_mob(mob/living/carbon/human/H, method = REAGENT_TOUCH, volume)
	if(istype(H) && method == REAGENT_INGEST)
		if(H.dna.species.taste_sensitivity < TASTE_SENSITIVITY_NO_TASTE) // If you can taste it, then you know how awful it is.
			H.Weaken(4 SECONDS)
			to_chat(H, span_danger("Ух! Есть <b>ЭТО</b> было плохой идеей!"))
		if(HAS_TRAIT(H, TRAIT_NO_HUNGER)) //If you don't eat, then you can't get food poisoning
			return
		var/datum/disease/food_poisoning/D = new
		D.Contract(H)

/datum/reagent/msg
	name = "Глутамат натрия"
	id = "msg"
	description = "Глутамат натрия - это натриевая соль, известная главным образом благодаря своему использованию в качестве спорного усилителя вкуса."
	reagent_state = LIQUID
	color = "#F5F5F5"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "отличной кухни"
	taste_mult = 4

/datum/reagent/msg/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(istype(M.mind?.martial_art, /datum/martial_art/mr_chang))
		update_flags |= M.adjustBruteLoss(-0.75, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-0.75, affect_robotic = FALSE)
	else
		if(prob(5))
			if(prob(10))
				update_flags |= M.adjustToxLoss(rand(2,4), FALSE)
			if(prob(7))
				to_chat(M, span_warning("Ужасная мигрень одолевает вас!"))
				M.Stun(rand(4 SECONDS, 10 SECONDS))
	return ..() | update_flags

/datum/reagent/cholesterol
	name = "Холестерин"
	id = "cholesterol"
	description = "Чистый холестерин. Достаточно вредная штука."
	reagent_state = LIQUID
	color = "#FFFAC8"
	taste_description = "сердечного приступа"

/datum/reagent/cholesterol/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(volume >= 25 && prob(volume*0.15))
		to_chat(M, span_warning("Вы чувствуете [pick("боль", "дискомфорт", "противное ощущение", "неприятное ощущение", "тепло")] в груди!"))
		update_flags |= M.adjustToxLoss(rand(1,2), FALSE)
	else if(volume >= 45 && prob(volume*0.08))
		to_chat(M, span_warning("Ваша грудь [pick("болит", "трещит", "горит")]!"))
		update_flags |= M.adjustToxLoss(rand(2,4), FALSE)
		M.Stun(2 SECONDS)
	else if(volume >= 150 && prob(volume*0.01))
		to_chat(M, span_warning("Ваша грудь адски горит!"))
		M.Weaken(2 SECONDS)
		var/datum/disease/critical/heart_failure/D = new
		D.Contract(M)
	return ..() | update_flags

/datum/reagent/fungus
	name = "Космический грибок"
	id = "fungus"
	description = "Соскобы неизвестного грибка, растущего на стенах станции."
	reagent_state = LIQUID
	color = "#C87D28"
	taste_description = "плесени"

/datum/reagent/fungus/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		var/ranchance = rand(1,10)
		if(ranchance == 1)
			to_chat(M, span_warning("Вы чувствуете себя очень плохо."))
			M.reagents.add_reagent("toxin", rand(1,5))
		else if(ranchance <= 5)
			to_chat(M, span_warning("Это было невероятно отвратительно!"))
			var/datum/disease/food_poisoning/D = new
			D.Contract(M)
		else
			to_chat(M, "Чёрт, да какого хера!")

/datum/reagent/ectoplasm
	name = "Эктоплазма"
	id = "ectoplasm"
	description = "Причудливая студенистая субстанция, якобы получаемая из призраков."
	reagent_state = LIQUID
	color = "#8EAE7B"
	process_flags = ORGANIC | SYNTHETIC		//Because apparently ghosts in the shell
	taste_description = "страшилок"

/datum/reagent/ectoplasm/on_mob_life(mob/living/M)
	var/spooky_message = pick("Краем глаза вы замечаете, что что-то движется, но ничего не происходит...", "Глаза дёргаются, вам кажется, что здесь кто-то находится, но вы ничего не видите...", "У вас мурашки по коже.", "Вы чувствуете беспокойство.", "Вы вздрагиваете, словно от холода...", "Вы чувствуете, как что-то скользит по вашей спине...")
	if(prob(8))
		to_chat(M, span_warning("[spooky_message]"))
	return ..()

/datum/reagent/ectoplasm/reaction_mob(mob/living/M, method=REAGENT_TOUCH, volume)
	if(method == REAGENT_INGEST)
		var/spooky_eat = pick("Зачем вы это съели? Во рту словно призраки. Призраки с плохим вкусом.", "Зачем вы это съели? У него текстура ветчинного аспика. Из 1950-х. Оставленная на солнце.", "Зачем вы это съели? На вкус как пердёж призрака.", "Зачем вы это съели? На вкус как будто что-то мёртвое.")
		to_chat(M, span_warning("[spooky_eat]"))

/datum/reagent/ectoplasm/reaction_turf(turf/T, volume)
	if(volume >= 10 && !isspaceturf(T))
		new /obj/item/reagent_containers/food/snacks/ectoplasm(T)

/datum/reagent/consumable/bread/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		new /obj/item/reagent_containers/food/snacks/breadslice(T)

		///Vomit///

/datum/reagent/vomit
	name = "Блевотина"
	id = "vomit"
	description = "Похоже, кто-то потерял свой обед. А потом собрал его. Фу."
	reagent_state = LIQUID
	color = "#FFFF00"
	taste_description = "рвоты"

/datum/reagent/vomit/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		T.add_vomit_floor()

/datum/reagent/greenvomit
	name = "Зелёная блевотина"
	id = "green_vomit"
	description = "Вау, это не может быть естественным. Это ужасно."
	reagent_state = LIQUID
	color = "#78FF74"
	taste_description = "рвоты"

/datum/reagent/greenvomit/reaction_turf(turf/T, volume)
	if(volume >= 5 && !isspaceturf(T))
		T.add_vomit_floor(FALSE, TRUE)

////Lavaland Flora Reagents////

/datum/reagent/consumable/entpoly
	name = "Экстракт Энтропийного Полипния"
	id = "entpoly"
	description = "Токсичное вещество, добываемое из некоторых видов грибов."
	color = "#1d043d"
	taste_description = "горьких грибов"

/datum/reagent/consumable/entpoly/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(current_cycle >= 10)
		M.Paralyse(4 SECONDS)
	if(prob(20))
		M.LoseBreath(8 SECONDS)
		update_flags |= M.adjustBrainLoss(1, FALSE)
		update_flags |= M.adjustToxLoss(1.5, FALSE)
		update_flags |= M.adjustStaminaLoss(5, FALSE)
		M.EyeBlurry(10 SECONDS)
	return ..() | update_flags

/datum/reagent/consumable/tinlux
	name = "Светящийся грибок"
	id = "tinlux"
	description = "Стимулирующий ихор, который вызывает рост люминесцентных грибков на коже."
	color = "#b5a213"
	var/light_activated = FALSE
	taste_description = "покалывающих язык грибов"
	//Lazy list of mobs affected by the luminosity of this reagent.
	var/list/mobs_affected

/datum/reagent/consumable/tinlux/on_mob_add(mob/living/L)
	. = ..()
	add_reagent_light(L)

/datum/reagent/consumable/tinlux/on_mob_delete(mob/living/M)
	. = ..()
	remove_reagent_light(M)

/datum/reagent/consumable/tinlux/proc/on_living_holder_deletion(mob/living/source)
	SIGNAL_HANDLER
	remove_reagent_light(source)

/datum/reagent/consumable/tinlux/proc/add_reagent_light(mob/living/living_holder)
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj = living_holder.mob_light(2)
	LAZYSET(mobs_affected, living_holder, mob_light_obj)
	RegisterSignal(living_holder, COMSIG_QDELETING, PROC_REF(on_living_holder_deletion))

/datum/reagent/consumable/tinlux/proc/remove_reagent_light(mob/living/living_holder)
	UnregisterSignal(living_holder, COMSIG_QDELETING)
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj = LAZYACCESS(mobs_affected, living_holder)
	LAZYREMOVE(mobs_affected, living_holder)
	if(mob_light_obj)
		qdel(mob_light_obj)

/datum/reagent/consumable/vitfro
	name = "Стекловидная пена"
	id = "vitfro"
	description = "Пенистая паста, заживляющая раны на коже."
	color = "#d3a308"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "фруктовых грибов"

/datum/reagent/consumable/vitfro/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(prob(80))
		update_flags |= M.adjustBruteLoss(-0.5, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-0.5, FALSE, affect_robotic = FALSE)
	return ..() | update_flags

/datum/reagent/consumable/animal_feed
	name = "Еда для животных"
	id = "afeed"
	description = "Пища, которой кормят домашних животных."
	color = "#ac3308"
	nutriment_factor = 2 * REAGENTS_METABOLISM
	taste_description = "пищи для животных"

/datum/reagent/consumable/animal_feed/on_mob_life(mob/living/M)
	var/update_flags = STATUS_UPDATE_NONE
	if(isvulpkanin(M) || istajaran(M))
		update_flags |= M.adjustBruteLoss(-0.25, FALSE, affect_robotic = FALSE)
		update_flags |= M.adjustFireLoss(-0.25, FALSE, affect_robotic = FALSE)
		M.AdjustDisgust(-5 SECONDS)
		if(prob(2))
			to_chat(M, span_notice("Вы чувствуете восхитительный вкус закуски!"))
	else
		M.AdjustDisgust(5 SECONDS)
		if(prob(2))
			to_chat(M, span_warning("Ух! Какой ужасный вкус!"))
	return ..() | update_flags
