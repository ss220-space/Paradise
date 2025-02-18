/datum/reagent/spider_eggs
	name = "Паучьи яйца"
	id = "spidereggs"
	description = "Мелкая пыль, содержащая паучьи яйца. О боже."
	reagent_state = SOLID
	color = "#FFFFFF"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/spider_eggs/on_mob_life(mob/living/M)
	if(volume > 2.5)
		if(iscarbon(M))
			if(!M.get_int_organ(/obj/item/organ/internal/body_egg))
				new/obj/item/organ/internal/body_egg/spider_eggs(M) //Yes, even Xenos can fall victim to the plague that is spider infestation.
	return ..()


/datum/reagent/nanomachines
	name = "Наномашины"
	id = "nanomachines"
	description = "Микроскопические строительные роботы."
	color = "#535E66" // rgb: 83, 94, 102
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/nanomachines/on_mob_life(mob/living/carbon/M)
	if(volume > 1.5)
		var/datum/disease/virus/transformation/robot/D = new
		D.Contract(M)
	return ..()


/datum/reagent/xenomicrobes
	name = "Ксеномикробы"
	id = "xenomicrobes"
	description = "Микробы с совершенно чужеродной клеточной структурой."
	color = "#535E66" // rgb: 83, 94, 102
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/xenomicrobes/on_mob_life(mob/living/carbon/M)
	if(volume > 1.5)
		var/datum/disease/virus/transformation/xeno/D = new
		D.Contract(M)
	return ..()

/datum/reagent/fungalspores
	name = "Микробы Космического Туберкулёза"
	id = "fungalspores"
	description = "Активные споры грибов."
	color = "#92D17D" // rgb: 146, 209, 125
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/fungalspores/on_mob_life(mob/living/carbon/M)
	if(volume > 2.5)
		var/datum/disease/virus/tuberculosis/D = new
		D.Contract(M)
	return ..()

/datum/reagent/jagged_crystals
	name = "Зазубренные кристаллы"
	id = "jagged_crystals"
	description = "В результате быстрого химического разложения эти кристаллы превратились в витые шипы."
	reagent_state = SOLID
	color = "#FA0000" // rgb: 250, 0, 0
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/jagged_crystals/on_mob_life(mob/living/carbon/M)
	var/datum/disease/berserker/D = new
	D.Contract(M)
	return ..()

/datum/reagent/salmonella
	name = "Сальмонелла"
	id = "salmonella"
	description = "Отвратительная бактерия, встречающаяся в испорченных продуктах."
	reagent_state = LIQUID
	color = "#1E4600"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/salmonella/on_mob_life(mob/living/carbon/M)
	var/datum/disease/food_poisoning/D = new
	D.Contract(M)
	return ..()

/datum/reagent/gibbis
	name = "Гиббис"
	id = "gibbis"
	description = "Гиббис в жидкой форме."
	reagent_state = LIQUID
	color = "#FF0000"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/gibbis/on_mob_life(mob/living/carbon/M)
	if(volume > 2.5)
		var/datum/disease/virus/gbs/non_con/D = new
		D.Contract(M)
	return ..()

/datum/reagent/prions
	name = "Прионы"
	id = "prions"
	description = "Возбудитель болезни, который не является ни бактериальным, ни грибковым, ни вирусным агентом и не содержит генетического материала."
	reagent_state = LIQUID
	color = "#FFFFFF"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/prions/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		var/datum/disease/kuru/D = new
		D.Contract(M)
	return ..()

/datum/reagent/grave_dust
	name = "Могильная пыль"
	id = "grave_dust"
	description = "Заплесневелая пыль, взятая кладбища."
	reagent_state = LIQUID
	color = "#465046"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/grave_dust/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		var/datum/disease/vampire/D = new
		D.Contract(M)
	return ..()

/datum/reagent/bacon_grease
	name = "Чистый сальный жир"
	id = "bacon_grease"
	description = "Принесите мне капельницу этого сладкого, сладкого жира!"
	reagent_state = LIQUID
	color = "#F7E6B1"
	can_synth = FALSE
	taste_description = "бекона"

/datum/reagent/bacon_grease/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		var/datum/disease/critical/heart_failure/D = new
		D.Contract(M)
	return ..()

/datum/reagent/heartworms
	name = "Сердечные черви"
	id = "heartworms"
	description = "Какая гадость! Эти черви будут не против полакомиться твоим сердечком!"
	reagent_state = SOLID
	color = "#925D6C"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/heartworms/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			var/obj/item/organ/internal/heart/ate_heart = H.get_int_organ(/obj/item/organ/internal/heart)
			if(ate_heart)
				ate_heart.remove(H)
				qdel(ate_heart)
	return ..()

/datum/reagent/concentrated_initro
	name = "Сгущённый инитропидрил"
	id = "concentrated_initro"
	description = "Остановка сердца в жидкой форме!"
	reagent_state = LIQUID
	color = "#AB1CCF"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/concentrated_initro/on_mob_life(mob/living/M)
	if(volume >= 5)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.undergoing_cardiac_arrest())
				H.set_heartattack(TRUE) // rip in pepperoni
	return ..()

//virus foods

/datum/reagent/consumable/virus_food
	name = "Питательная среда"
	id = "virusfood"
	description = "Смесь воды, молока и кислорода. Вирусные клетки могут использовать эту смесь для размножения."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19
	taste_description = "водянистого молока"

/datum/reagent/mutagen/mutagenvirusfood
	name = "Мутагенный агар"
	id = "mutagenvirusfood"
	description = "Вещество, способствующее ускоренной мутации вирусных форм жизни."
	color = "#A3C00F" // rgb: 163,192,15

/datum/reagent/mutagen/mutagenvirusfood/sugar
	name = "Сахарный агар"
	id = "sugarvirusfood"
	color = "#41B0C0" // rgb: 65,176,192
	taste_mult = 1.5

/datum/reagent/medicine/diphenhydramine/diphenhydraminevirusfood
	name = "Вирусный пайки"
	id = "diphenhydraminevirusfood"
	description = "Вещество, способствующее ускоренной мутации вирусных форм жизни."
	color = "#D18AA5" // rgb: 209,138,165

/datum/reagent/plasma_dust/plasmavirusfood
	name = "Вирусная плазма"
	id = "plasmavirusfood"
	description = "Вещество, способствующее ускоренной мутации вирусных форм жизни."
	color = "#A69DA9" // rgb: 166,157,169

/datum/reagent/plasma_dust/plasmavirusfood/weak
	name = "Ослабленная вирусная плазма"
	id = "weakplasmavirusfood"
	color = "#CEC3C6" // rgb: 206,195,198
