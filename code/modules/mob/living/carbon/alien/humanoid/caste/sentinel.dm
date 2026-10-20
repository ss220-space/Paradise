/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 350
	health = 350
	attack_damage = 25
	time_to_open_doors = 0.2 SECONDS
	icon = 'icons/mob/xeno/warrior.dmi'
	icon_state = "sentinel"
	caste_icon_prefix = "sentinel"
	ventcrawler_trait = null
	caste_movement_delay = 0.7
	role_text = "Вы — Часовой. Ваша основная задача — защита гнезда от непрошенных гостей."
	can_evolve = TRUE
	base_pixel_x = -16
	pixel_x = -16

/mob/living/carbon/alien/humanoid/sentinel/Initialize(mapload)
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name
	. = ..()
	AddSpell(new /datum/action/cooldown/spell/pointed/break_vent)
	AddSpell(new /datum/action/cooldown/spell/evolve/praetorian)

/mob/living/carbon/alien/humanoid/sentinel/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/sentinel,
		/obj/item/organ/internal/xenos/acidgland/sentinel,
		/obj/item/organ/internal/xenos/neurotoxin/sentinel
	)


/mob/living/carbon/alien/humanoid/praetorian
	name = "alien praetorian"
	icon = 'icons/mob/xeno/warrior.dmi'
	icon_state = "praetorian"
	caste_icon_prefix = "praetorian"
	caste = "s"
	pixel_x = -16
	maxHealth = 550
	health = 550
	status_flags = CANPARALYSE
	large = TRUE
	caste_movement_delay = 1.5
	ventcrawler_trait = null
	attack_damage = 30
	disarm_stamina_damage = 34
	armour_penetration = 30
	obj_damage = 80
	time_to_open_doors = 0.2 SECONDS
	environment_smash = ENVIRONMENT_SMASH_WALLS
	role_text = "Вы — Преторианец. Вы являетесь более сильной и неповоротливой версией Часового. Ваша основная задача — защита гнезда от непрошенных гостей."

/mob/living/carbon/alien/humanoid/praetorian/Initialize(mapload)
	. = ..()
	if(name == "alien praetorian")
		name = text("alien praetorian ([rand(1, 1000)])")
	real_name = name
	AddSpell(new /datum/action/cooldown/spell/pointed/break_vent)
	praetorian_count++

/mob/living/carbon/alien/humanoid/praetorian/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(.)
		praetorian_count--

/mob/living/carbon/alien/humanoid/praetorian/is_strong()
	return TRUE

/mob/living/carbon/alien/humanoid/praetorian/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/praetorian,
		/obj/item/organ/internal/xenos/acidgland/praetorian,
		/obj/item/organ/internal/xenos/neurotoxin
	)



