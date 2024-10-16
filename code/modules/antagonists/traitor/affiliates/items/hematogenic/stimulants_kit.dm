/datum/reagent/hematogenic
	var/datum/reagent/consumable/ethanol/path

/datum/reagent/hematogenic/New()
	. = ..()
	name = path::name
	color = path::color
	drink_icon = path::drink_icon
	drink_name = path::drink_name
	drink_desc = path::drink_desc
	taste_description = path::taste_description
	reagent_state = path::reagent_state

/datum/reagent/hematogenic/hemat_blue_lagoon
	id = "hemat_blue_lagoon"
	description = "Вещество разработанное Hematogenic Industries, на основе криоксадона из тел Драсков обладающих душой, \
					сильно охлаждающее тело и замедляющее многие биологические процессы, не вредя организму."
	path = /datum/reagent/consumable/ethanol/blue_lagoon

/datum/reagent/hematogenic/hemat_blue_lagoon/on_mob_add(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_IGNORECOLDSLOWDOWN, id)
	ADD_TRAIT(H, TRAIT_IGNORECOLDDAMAGE, id)
	H.physiology.metabolism_mod /= 8
	H.bodytemperature = T0C - 100
	. = ..()

/datum/reagent/hematogenic/hemat_blue_lagoon/on_mob_delete(mob/living/carbon/human/H)
	REMOVE_TRAIT(H, TRAIT_IGNORECOLDSLOWDOWN, id)
	REMOVE_TRAIT(H, TRAIT_IGNORECOLDDAMAGE, id)
	H.physiology.metabolism_mod *= 8
	var/turf/T = get_turf(H)
	var/datum/gas_mixture/environment = T.return_air()
	H.bodytemperature = H.get_temperature(environment)
	. = ..()

/datum/reagent/hematogenic/hemat_blue_lagoon/on_mob_life(mob/living/carbon/human/H)
	H.bodytemperature = T0C - 100
	return ..()


/datum/reagent/hematogenic/hemat_bloody_mary
	id = "hemat_bloody_mary"
	description = "Вещество разработанное Hematogenic Industries, на основе крови воксов обладающих душой, \
					быстро восстанавливающее объем крови и количество кислорода в ней."
	path = /datum/reagent/consumable/ethanol/bloody_mary

/datum/reagent/hematogenic/hemat_bloody_mary/on_mob_life(mob/living/carbon/human/H)
	if(H.blood_volume + 5 < BLOOD_VOLUME_NORMAL)
		H.blood_volume += 5

	H.adjustOxyLoss(-10)
	return ..()


/datum/reagent/hematogenic/hemat_demons_blood
	id = "hemat_demons_blood"
	description = "Вещество разработанное Hematogenic Industries, на основе крови вампиров подкласса \"hemomancer\", \
					быстро лечащае, в зависимости от суммарных повреждений."
	path = /datum/reagent/consumable/ethanol/demonsblood

/datum/reagent/hematogenic/hemat_demons_blood/on_mob_life(mob/living/carbon/human/H)
	var/heal = clamp((100 - H.health) / 25, 1, 4)
	H.heal_overall_damage(heal, heal)
	return ..()


/datum/reagent/hematogenic/hemat_white_russian
	id = "hemat_white_russian"
	description = "Вещество разработанное Hematogenic Industries, на основе крови вампиров подкласса \"gargantua\", \
					временно повышающее скорость бега."
	path = /datum/reagent/consumable/ethanol/white_russian

/datum/reagent/hematogenic/hemat_white_russian/on_mob_add(mob/living/carbon/human/H)
	if(H.dna && (H.dna.species.reagent_tag & PROCESS_ORG))
		H.add_movespeed_modifier(/datum/movespeed_modifier/reagent/hemat_white_russian)
	. = ..()

/datum/reagent/hematogenic/hemat_white_russian/on_mob_delete(mob/living/carbon/human/H)
	H.remove_movespeed_modifier(/datum/movespeed_modifier/reagent/hemat_white_russian)
	. = ..()

/datum/reagent/hematogenic/hemat_white_russian/on_mob_life(mob/living/carbon/human/H)
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
