/mob/living/simple_animal/hostile/skinner     ////////object_sampo.dmm
	name = "Skinner"
	icon = 'icons/mob/winter_mob.dmi'
	icon_state = "placeholder"
	icon_living = "placeholder"
	icon_dead = "placeholder"
	faction = list("hostile", "undead")
	speak_chance = 0
	turns_per_move = 5
	speed = 0
	maxHealth = 150		//if this seems low for a "boss", it's because you have to fight him multiple times, with him fully healing between stages
	health = 150
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	sentience_type = SENTIENCE_OTHER
	robust_searching = 1
	vision_range = 12
	melee_damage_lower = 3
	melee_damage_upper = 7
	var/next_stage = null
	var/death_message
	/// If TRUE you should spawn it only on special area, see bossfight_area
	var/with_area = TRUE

	var/area/vision_change_area/object_sampo/main_lab/bossfight_area

/mob/living/simple_animal/hostile/skinner/Initialize(mapload)
	. = ..()
	if(with_area)
		bossfight_area = get_area(src)
		bossfight_area.boss = src

/mob/living/simple_animal/hostile/skinner/death(gibbed)
	. = ..(gibbed)
	if(!.)
		return FALSE // Only execute the below if we successfully died
	if(death_message)
		visible_message(death_message)
	if(next_stage)
		spawn(1 SECONDS)
			if(!QDELETED(src))
				new next_stage(get_turf(src))
				qdel(src)
			bossfight_area?.ready_or_not()
	else
		new /obj/effect/particle_effect/smoke/vomiting (get_turf(src))
		new /mob/living/simple_animal/hostile/living_limb_flesh (get_turf(src))
		new /mob/living/simple_animal/hostile/living_limb_flesh (get_turf(src))
		new /obj/item/reagent_containers/food/snacks/monstermeat/rotten/jumping (get_turf(src))
		new /obj/item/reagent_containers/food/snacks/monstermeat/rotten/jumping (get_turf(src))
		new /obj/item/nullrod/armblade (get_turf(src))
		gib(src)
		bossfight_area?.ready_or_not()

/mob/living/simple_animal/hostile/skinner/stage_1		//stage 1: weak melee
	desc = "PERISH OR DIE!"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "skinner"
	icon_living = "skinner"
	icon_dead = "skinner"
	maxHealth = 60
	health = 60
	next_stage = /mob/living/simple_animal/hostile/skinner/stage_2
	death_message = "<span class='danger'>I SMELL YOUR FLESH! PREPARE TO DIE!</span>"
	melee_damage_lower = 10
	melee_damage_upper = 20

/mob/living/simple_animal/hostile/skinner/stage_1/without_area
	with_area = FALSE
	next_stage = /mob/living/simple_animal/hostile/skinner/stage_2/without_area

/mob/living/simple_animal/hostile/skinner/stage_2		//stage 2: strong melee
	desc = "PERISH OR DIE AGAIN!"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "skinner_transform"
	icon_living = "skinner_transform"
	icon_dead = "skinner_transform"
	death_message = "ROOOOAAA RAAA!"
	maxHealth = 200
	health = 200
	melee_damage_upper = 30
	sharp_attack = TRUE
	canmove = FALSE

/mob/living/simple_animal/hostile/skinner/stage_2/without_area
	with_area = FALSE

/mob/living/simple_animal/hostile/skinner/stage_2/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon), UPDATE_ICON_STATE), 1.5 SECONDS)
	addtimer(VARSET_CALLBACK(src, canmove, TRUE), 1 SECONDS)

/mob/living/simple_animal/hostile/skinner/stage_2/update_icon_state()
	icon_state = "skinner_monster"
	icon_living = "skinner_monster"
