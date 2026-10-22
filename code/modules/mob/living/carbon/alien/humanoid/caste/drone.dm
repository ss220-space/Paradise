/mob/living/carbon/alien/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 220
	health = 220
	icon = 'icons/mob/xeno/drone.dmi'
	icon_state = "drone"
	caste_icon_prefix = "drone"
	time_to_open_doors = 0.2 SECONDS
	ventcrawler_trait = null
	can_evolve = TRUE
	role_text = "Вы — Дрон. Ваша основная задача — помощь Королеве в обустройстве гнезда. Если в улье её всё ещё нет, вам необходимо как можно быстрее в неё эволюционировать."
	var/sterile = FALSE
	base_pixel_x = -16
	pixel_x = -16

/mob/living/carbon/alien/humanoid/drone/get_ru_names()
	return alist(
		NOMINATIVE = "ксеноморф-дрон",
		GENITIVE = "ксеноморфа-дрона",
		DATIVE = "ксеноморфу-дрону",
		ACCUSATIVE = "ксеноморфа-дрона",
		INSTRUMENTAL = "ксеноморфом-дроном",
		PREPOSITIONAL = "ксеноморфе-дроне",
	)

/mob/living/carbon/alien/humanoid/drone/Initialize(mapload)
	. = ..()
	if(name == "alien drone")
		name = "alien drone ([rand(1, 1000)])"
	real_name = name

	AddSpell(new /datum/action/cooldown/spell/pointed/break_vent)
	if(!sterile && !istype(src, /mob/living/carbon/alien/humanoid/drone/resin_drone))
		AddSpell(new /datum/action/cooldown/spell/evolve/drone)

/mob/living/carbon/alien/humanoid/drone/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/drone,
		/obj/item/organ/internal/xenos/acidgland,
		/obj/item/organ/internal/xenos/resinspinner,
	)

/mob/living/carbon/alien/humanoid/drone/no_queen
	sterile = TRUE

/mob/living/carbon/alien/humanoid/drone/resin_drone
	name = "alien resin drone"
	caste = "d"
	maxHealth = 180
	health = 180
	icon = 'icons/mob/xeno/drone.dmi'
	icon_state = "resin_drone"
	caste_icon_prefix = "resin_drone"
	time_to_open_doors = 0.2 SECONDS
	caste_movement_delay = 0.8
	ventcrawler_trait = null
	can_evolve = FALSE
	role_text = "Вы — смоляной дрон. Вы можете строить смоляные стены, которые прочнее обычных. Вы больше не можете эволюционировать в Королеву."

/mob/living/carbon/alien/humanoid/drone/resin_drone/Initialize(mapload)
	. = ..()
	if(name == "alien resin drone")
		name = "alien resin drone ([rand(1, 1000)])"
	real_name = name

/mob/living/carbon/alien/humanoid/drone/resin_drone/get_caste_organs()
	. = ..()
	. += list(
		/obj/item/organ/internal/xenos/plasmavessel/drone/resin_drone,
	)
