/datum/reagent/hemat_blue_lagoon
	name = "Blue Lagoon"
	id = "hemat_blue_lagoon"
	description = "Вещество разработанное Hematogenic Industries, на основе криоксадона из тел Драсков обладающих душой, \
					сильно охлаждающее тело и замедляющее многие биологические процессы, не вредя организму."
	color = "#1edddd"
	drink_icon = "blue_lagoon"
	drink_name = "Blue Lagoon"
	drink_desc = "Что может быть лучше, чем расслабиться на пляже с хорошим напитком?"
	taste_description = "beach relaxation"
	reagent_state = LIQUID

/datum/reagent/hemat_blue_lagoon/on_mob_add(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_IGNORECOLDSLOWDOWN, CHEM_TRAIT(src))
	ADD_TRAIT(H, TRAIT_IGNORECOLDDAMAGE, CHEM_TRAIT(src))
	H.physiology.metabolism_mod /= 8
	H.bodytemperature = T0C - 100
	. = ..()

/datum/reagent/hemat_blue_lagoon/on_mob_delete(mob/living/carbon/human/H)
	REMOVE_TRAIT(H, TRAIT_IGNORECOLDSLOWDOWN, CHEM_TRAIT(src))
	REMOVE_TRAIT(H, TRAIT_IGNORECOLDDAMAGE, CHEM_TRAIT(src))
	H.physiology.metabolism_mod *= 8
	var/turf/T = get_turf(H)
	var/datum/gas_mixture/environment = T.return_air()
	H.bodytemperature = H.get_temperature(environment)
	. = ..()

/datum/reagent/hemat_blue_lagoon/on_mob_life(mob/living/carbon/human/H)
	H.bodytemperature = T0C - 100
	return ..()


/datum/reagent/hemat_bloody_mary
	name = "Bloody Mary"
	id = "hemat_bloody_mary"
	description = "Вещество разработанное Hematogenic Industries, на основе крови воксов обладающих душой, \
					быстро восстанавливающее объем крови и количество кислорода в ней."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	drink_icon = "bloodymaryglass"
	drink_name = "Bloody Mary"
	drink_desc = "Томатный сок, смешанный с водкой и небольшим количеством лайма. На вкус как жидкое убийство."
	taste_description = "tomatoes with booze"

/datum/reagent/hemat_bloody_mary/on_mob_life(mob/living/carbon/human/H)
	if (H.blood_volume + 5 < BLOOD_VOLUME_NORMAL)
		H.blood_volume += 5

	H.adjustOxyLoss(-10)
	return ..()


/datum/reagent/hemat_demons_blood
	name = "Demons Blood"
	id = "hemat_demons_blood"
	description = "Вещество разработанное Hematogenic Industries, на основе крови вампиров подкласса \"hemomancer\", \
					быстро лечащае, в зависимости от суммарных повреждений."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	drink_icon = "demonsblood"
	drink_name = "Demons Blood"
	drink_desc = "Just looking at this thing makes the hair at the back of your neck stand up."
	taste_description = span_warning("evil")

/datum/reagent/hemat_demons_blood/on_mob_life(mob/living/carbon/human/H)
	var/heal = clamp((100 - H.health) / 25, 1, 4)
	H.heal_overall_damage(heal, heal)
	return ..()


/datum/reagent/hemat_white_russian
	name = "White Russian"
	id = "hemat_white_russian"
	description = "Вещество разработанное Hematogenic Industries, на основе крови вампиров подкласса \"gargantua\", \
					временно повышающее скорость бега."
	reagent_state = LIQUID
	color = "#A68340" // rgb: 166, 131, 64
	drink_icon = "whiterussianglass"
	drink_name = "White Russian"
	drink_desc = "A very nice looking drink. But that's just, like, your opinion, man."
	taste_description = "very creamy alcohol"

/datum/reagent/hemat_white_russian/on_mob_add(mob/living/carbon/human/H)
	if(H.dna && (H.dna.species.reagent_tag & PROCESS_ORG))
		H.add_movespeed_modifier(/datum/movespeed_modifier/reagent/hemat_white_russian)
	. = ..()

/datum/reagent/hemat_white_russian/on_mob_delete(mob/living/carbon/human/H)
	H.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/hemat_white_russian)
	. = ..()

/datum/reagent/hemat_white_russian/on_mob_life(mob/living/carbon/human/H)
	if(!(H.dna && (H.dna.species.reagent_tag & PROCESS_ORG)))
		H.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/hemat_white_russian)
	return ..()


/obj/item/reagent_containers/hypospray/autoinjector/hemat
	volume = 15
	amount_per_transfer_from_this = 15

/obj/item/reagent_containers/hypospray/autoinjector/hemat/blue_lagoon
	name = "Blue Lagoon autoinjector"
	desc = "Вещество разработанное Hematogenic Industries, на основе криоксадона из тел Драсков обладающих душой, \
			сильно охлаждающее тело и замедляющее многие биологические процессы, не вредя организму."
	list_reagents = list("hemat_blue_lagoon" = 15)

/obj/item/reagent_containers/hypospray/autoinjector/hemat/bloody_mary
	name = "Bloody Mary autoinjector"
	desc = "Вещество разработанное Hematogenic Industries, на основе крови воксов обладающих душой, быстро восстанавливающее \
			объем крови и количество кислорода в ней."
	list_reagents = list("hemat_bloody_mary" = 15)


/obj/item/reagent_containers/hypospray/autoinjector/hemat/demons_blood
	name = "Demons Blood autoinjector"
	desc = "Вещество разработанное Hematogenic Industries, на основе крови вампиров подкласса \"hemomancer\", быстро \
			лечащае, в зависимости от суммарных повреждений."
	list_reagents = list("hemat_demons_blood" = 15)

/obj/item/reagent_containers/hypospray/autoinjector/hemat/white_russian
	name = "White Russian autoinjector"
	desc = "Вещество разработанное Hematogenic Industries, на основе крови вампиров подкласса \"gargantua\", временно \
			повышающее скорость бега."
	list_reagents = list("hemat_white_russian" = 15)

/obj/item/storage/box/syndie_kit/stimulants
	name = "Boxed set of stimulants"

/obj/item/storage/box/syndie_kit/stimulants/populate_contents()
	new /obj/item/reagent_containers/hypospray/autoinjector/hemat/blue_lagoon(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/hemat/bloody_mary(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/hemat/demons_blood(src)
	new /obj/item/reagent_containers/hypospray/autoinjector/hemat/white_russian(src)
