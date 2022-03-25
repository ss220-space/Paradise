/datum/reagent/spider_eggs
	name = "Паучьи яйца"
	id = "spidereggs"
	description = "Мелкая пыль, содержащая паучьи яйца. Мерзость."
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
		M.ForceContractDisease(new /datum/disease/transformation/robot(0))
	return ..()


/datum/reagent/xenomicrobes
	name = "Ксеномикробы"
	id = "xenomicrobes"
	description = "Микробы с абсолютно чуждой клеточной структурой."
	color = "#535E66" // rgb: 83, 94, 102
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/xenomicrobes/on_mob_life(mob/living/carbon/M)
	if(volume > 1.5)
		M.ContractDisease(new /datum/disease/transformation/xeno(0))
	return ..()

/datum/reagent/fungalspores
	name = "Космическая грибковая туберкулезная бацилла"
	id = "fungalspores"
	description = "Активные грибные споры."
	color = "#92D17D" // rgb: 146, 209, 125
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/fungalspores/on_mob_life(mob/living/carbon/M)
	if(volume > 2.5)
		M.ForceContractDisease(new /datum/disease/tuberculosis(0))
	return ..()

/datum/reagent/jagged_crystals
	name = "Зубчатые кристаллы"
	id = "jagged_crystals"
	description = "Быстрый химический распад превратил эти кристаллы в искривлённые шипы."
	reagent_state = SOLID
	color = "#FA0000" // rgb: 250, 0, 0
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/jagged_crystals/on_mob_life(mob/living/carbon/M)
	M.ForceContractDisease(new /datum/disease/berserker(0))
	return ..()

/datum/reagent/salmonella
	name = "Сальмонелла"
	id = "salmonella"
	description = "Противная бактерия, обитающая в испорченной еде."
	reagent_state = LIQUID
	color = "#1E4600"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/salmonella/on_mob_life(mob/living/carbon/M)
	M.ForceContractDisease(new /datum/disease/food_poisoning(0))
	return ..()

/datum/reagent/gibbis
	name = "Ошмётки"
	id = "gibbis"
	description = "Жидкие ошмётки."
	reagent_state = LIQUID
	color = "#FF0000"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/gibbis/on_mob_life(mob/living/carbon/M)
	if(volume > 2.5)
		M.ForceContractDisease(new /datum/disease/gbs/curable(0))
	return ..()

/datum/reagent/prions
	name = "Прионы"
	id = "prions"
	description = "Болезнетворный агент, не имеющий генетического материала, чья природа не является ни бактериальной, ни вирусной, ни грибковой."
	reagent_state = LIQUID
	color = "#FFFFFF"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/prions/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		M.ForceContractDisease(new /datum/disease/kuru(0))
	return ..()

/datum/reagent/grave_dust
	name = "Могильная пыль"
	id = "grave_dust"
	description = "Заплесневелая старая пыль, взятая из могилы."
	reagent_state = LIQUID
	color = "#465046"
	can_synth = FALSE
	taste_mult = 0

/datum/reagent/grave_dust/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		M.ForceContractDisease(new /datum/disease/vampire(0))
	return ..()

/datum/reagent/bacon_grease
	name = "Чистый жир бекона"
	id = "bacon_grease"
	description = "Подключите меня к капельнице с этой вкуснятиной!"
	reagent_state = LIQUID
	color = "#F7E6B1"
	can_synth = FALSE
	taste_description = "bacon"

/datum/reagent/bacon_grease/on_mob_life(mob/living/carbon/M)
	if(volume > 4.5)
		M.ForceContractDisease(new /datum/disease/critical/heart_failure(0))
	return ..()

/datum/reagent/heartworms
	name = "Космические сердечные черви"
	id = "heartworms"
	description = "Вот чёрт! Эти штуки не полезны для вашего сердца! Наоборот, они сами его жрут!"
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
	name = "Концентрированный инитропидрил"
	id = "concentrated_initro"
	description = "Гарантированная остановка сердца!"
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
	description = "Смесь воды, молока и кислорода. Вирусные клетки могут использовать эту среду для размножения."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19
	taste_description = "watery milk"

/datum/reagent/mutagen/mutagenvirusfood
	name = "Мутагенный агар"
	id = "mutagenvirusfood"
	description = "mutates blood"
	color = "#A3C00F" // rgb: 163,192,15

/datum/reagent/mutagen/mutagenvirusfood/sugar
	name = "Сахарозный агар"
	id = "sugarvirusfood"
	color = "#41B0C0" // rgb: 65,176,192
	taste_mult = 1.5

/datum/reagent/medicine/diphenhydramine/diphenhydraminevirusfood
	name = "Вирусные пайки"
	id = "diphenhydraminevirusfood"
	description = "mutates blood"
	color = "#D18AA5" // rgb: 209,138,165

/datum/reagent/plasma_dust/plasmavirusfood
	name = "Плазма вируса"
	id = "plasmavirusfood"
	description = "mutates blood"
	color = "#A69DA9" // rgb: 166,157,169

/datum/reagent/plasma_dust/plasmavirusfood/weak
	name = "Ослабленная плазма вируса"
	id = "weakplasmavirusfood"
	color = "#CEC3C6" // rgb: 206,195,198
