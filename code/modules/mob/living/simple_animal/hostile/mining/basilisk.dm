//A beast that fire freezing blasts.
/mob/living/simple_animal/hostile/asteroid/basilisk
	name = "basilisk"
	desc = "Территориальный зверь, покрытый толстой энергопоглощающей бронёй. Его взгляд заставляет жертв замерзать изнутри."
	ru_names = list(
		NOMINATIVE = "базилиск",
		GENITIVE = "базилиска",
		DATIVE = "базилиску",
		ACCUSATIVE = "базилиска",
		INSTRUMENTAL = "базилиском",
		PREPOSITIONAL = "базилиске"
	)
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Basilisk"
	icon_living = "Basilisk"
	icon_aggro = "Basilisk_alert"
	icon_dead = "Basilisk_dead"
	icon_gib = "syndicate_gib"
	move_to_delay = 20
	projectiletype = /obj/projectile/temp/basilisk
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	ranged_message = "смотрит"
	ranged_cooldown_time = 30
	throw_message = "отскакивает от"
	vision_range = 2
	speed = 3
	maxHealth = 200
	health = 200
	harm_intent_damage = 5
	obj_damage = 60
	melee_damage_lower = 12
	melee_damage_upper = 12
	attacktext = "вгрызается в"
	a_intent = INTENT_HARM
	speak_emote = list("стрекочет")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	vision_range = 2
	aggro_vision_range = 9
	turns_per_move = 5
	gold_core_spawnable = HOSTILE_SPAWN
	loot = list(/obj/item/stack/ore/diamond{layer = ABOVE_MOB_LAYER},
				/obj/item/stack/ore/diamond{layer = ABOVE_MOB_LAYER})
	tts_seed = "Antimage"

/obj/projectile/temp/basilisk
	name = "freezing blast"
	icon_state = "ice_2"
	damage = 0
	damage_type = BURN
	nodamage = TRUE
	flag = "energy"
	temperature = 50

/mob/living/simple_animal/hostile/asteroid/basilisk/GiveTarget(new_target)
	if(..()) //we have a target
		if(isliving(target) && !target.Adjacent(targets_from) && ranged_cooldown <= world.time)//No more being shot at point blank or spammed with RNG beams
			OpenFire(target)

/mob/living/simple_animal/hostile/asteroid/basilisk/ex_act(severity)
	switch(severity)
		if(1)
			gib()
		if(2)
			adjustBruteLoss(140)
		if(3)
			adjustBruteLoss(110)

//Watcher
/mob/living/simple_animal/hostile/asteroid/basilisk/watcher
	name = "watcher"
	desc = "Левитирующее создание, похожее на глаз, парящее на крылоподобных мышечных структурах. Из тела торчит острый кристаллический шип."
	ru_names = list(
		NOMINATIVE = "наблюдатель",
		GENITIVE = "наблюдателя",
		DATIVE = "наблюдателю",
		ACCUSATIVE = "наблюдателя",
		INSTRUMENTAL = "наблюдателем",
		PREPOSITIONAL = "наблюдателе"
	)
	icon = 'icons/mob/lavaland/watcher.dmi'
	icon_state = "watcher"
	icon_living = "watcher"
	icon_aggro = "watcher"
	icon_dead = "watcher_dead"
	pixel_x = -10
	throw_message = "отскакивает от"
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "пронзает"
	a_intent = INTENT_HARM
	speak_emote = list("телепатически вопит")
	attack_sound = 'sound/weapons/bladeslice.ogg'
	stat_attack = UNCONSCIOUS
	robust_searching = 1
	projectiletype = /obj/projectile/watcher
	crusher_loot = /obj/item/crusher_trophy/watcher_wing
	loot = list()
	butcher_results = list(/obj/item/stack/ore/diamond = 2, /obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 1)


/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/simple_flying)


/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing
	name = "magmawing watcher"
	desc = "Когда наблюдатели растут у самой лавы, они адаптируются к жаре и начинают использовать её как оружие."
	ru_names = list(
		NOMINATIVE = "магмовый наблюдатель",
		GENITIVE = "магмового наблюдателя",
		DATIVE = "магмовому наблюдателю",
		ACCUSATIVE = "магмового наблюдателя",
		INSTRUMENTAL = "магмовым наблюдателем",
		PREPOSITIONAL = "магмовом наблюдателе"
	)
	icon_state = "watcher_magmawing"
	icon_living = "watcher_magmawing"
	icon_aggro = "watcher_magmawing"
	icon_dead = "watcher_magmawing_dead"
	maxHealth = 215 //Compensate for the lack of slowdown on projectiles with a bit of extra health
	health = 215
	light_range = 3
	light_power = 2.5
	light_color = LIGHT_COLOR_LAVA
	projectiletype = /obj/projectile/temp/basilisk/magmawing
	jewelry_loot = /obj/item/gem/magma
	crusher_loot = /obj/item/crusher_trophy/blaster_tubes/magma_wing
	crusher_drop_mod = 60

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing
	name = "icewing watcher"
	desc = "В редких случаях наблюдатели выживают вдали от источников тепла. Без тепла они становятся хрупкими, но обретают мощные ледяные атаки."
	ru_names = list(
		NOMINATIVE = "ледяной наблюдатель",
		GENITIVE = "ледяного наблюдателя",
		DATIVE = "ледяному наблюдателю",
		ACCUSATIVE = "ледяного наблюдателя",
		INSTRUMENTAL = "ледяным наблюдателем",
		PREPOSITIONAL = "ледяном наблюдателе"
	)
	icon_state = "watcher_icewing"
	icon_living = "watcher_icewing"
	icon_aggro = "watcher_icewing"
	icon_dead = "watcher_icewing_dead"
	maxHealth = 170
	health = 170
	projectiletype = /obj/projectile/temp/basilisk/icewing
	butcher_results = list(/obj/item/stack/ore/diamond = 5, /obj/item/stack/sheet/bone = 1) //No sinew; the wings are too fragile to be usable
	jewelry_loot = /obj/item/gem/fdiamond
	crusher_loot = /obj/item/crusher_trophy/watcher_wing/ice_wing
	crusher_drop_mod = 60

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/random/Initialize(mapload)
	. = ..()
	if(prob(40)) //60 for classic, 20/20 for magma and ice
		if(prob(50))
			new /mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing(loc)
		else
			new /mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing(loc)
		return INITIALIZE_HINT_QDEL

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/tendril
	fromtendril = TRUE

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/icewing/tendril
	fromtendril = TRUE

/mob/living/simple_animal/hostile/asteroid/basilisk/watcher/magmawing/tendril
	fromtendril = TRUE

/obj/projectile/watcher
	name = "stunning blast"
	ru_names = list(
		NOMINATIVE = "оглушающий выброс",
		GENITIVE = "оглушающего выброса",
		DATIVE = "оглушающему выбросу",
		ACCUSATIVE = "оглушающий выброс",
		INSTRUMENTAL = "оглушающим выбросом",
		PREPOSITIONAL = "оглушающем выбросе"
	)
	icon_state = "temp_0"
	damage = 10 //make it hurt, as it no more freezing
	damage_type = BURN
	nodamage = FALSE
	speed = 0.8

/obj/projectile/watcher/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if(istype(L) && !isrobot(L))
			L.AdjustWeakened(1 SECONDS)
			L.Slowed(3 SECONDS)
			L.Confused(3 SECONDS)


/obj/projectile/temp/basilisk/magmawing
	name = "scorching blast"
	ru_names = list(
		NOMINATIVE = "опаляющий выброс",
		GENITIVE = "опаляющего выброса",
		DATIVE = "опаляющему выбросу",
		ACCUSATIVE = "опаляющий выброс",
		INSTRUMENTAL = "опаляющим выбросом",
		PREPOSITIONAL = "опаляющем выбросе"
	)
	icon_state = "lava"
	damage = 5
	damage_type = BURN
	nodamage = FALSE
	temperature = 700 //Heats you up!
	speed = 0.6

/obj/projectile/temp/basilisk/magmawing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if(istype(L))
			L.adjust_fire_stacks(3)
			L.IgniteMob()
			if(L.getFireLoss() > 50)
				explosion(L.loc, 0, 0, 0, 0, flame_range = 3)
				L.AdjustWeakened(1 SECONDS)

/obj/projectile/temp/basilisk/icewing
	damage = 5
	damage_type = BURN
	nodamage = FALSE
	speed = 0.6

/obj/projectile/temp/basilisk/icewing/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(.)
		var/mob/living/L = target
		if(istype(L))
			L.apply_status_effect(/datum/status_effect/freon/watcher)
