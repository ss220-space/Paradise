//Gutlunches, passive mods that devour blood and gibs
/mob/living/simple_animal/hostile/asteroid/gutlunch
	name = "gutlunch"
	desc = "Падальщик, питающийся сырым мясом. Часто встречается рядом с пеплоходцами. Производит густое питательное молоко."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "gutlunch"
	icon_living = "gutlunch"
	icon_dead = "gutlunch"
	speak_emote = list("воркует", "трепещет")
	emote_hear = list("издает трель")
	emote_see = list("принюхивается", "рыгает")
	weather_immunities = list(TRAIT_LAVA_IMMUNE, TRAIT_ASHSTORM_IMMUNE)
	faction = list("mining", "ashwalker")
	density = FALSE
	speak_chance = 1
	turns_per_move = 8
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	move_to_delay = 15
	response_help  = "гладит"
	response_disarm = "аккуратно отодвигает"
	response_harm   = "шлёпает"
	friendly = "щиплет"
	a_intent = INTENT_HELP
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	stat_attack = UNCONSCIOUS
	gender = NEUTER
	stop_automated_movement = FALSE
	stop_automated_movement_when_pulled = TRUE
	stat_exclusive = TRUE
	robust_searching = TRUE
	search_objects = 3 //Ancient simplemob AI shitcode. This makes them ignore all other mobs.
	del_on_death = TRUE
	loot = list(/obj/effect/decal/cleanable/blood/gibs)
	deathmessage = "превращается в месиво."

	animal_species = /mob/living/simple_animal/hostile/asteroid/gutlunch
	childtype = list(/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch = 100)

	wanted_objects = list(/obj/effect/decal/cleanable/blood/gibs, /obj/item/organ/internal)
	var/obj/item/udder/gutlunch/udder = null

/mob/living/simple_animal/hostile/asteroid/gutlunch/get_ru_names()
	return list(
		NOMINATIVE = "кишкожор",
		GENITIVE = "кишкожора",
		DATIVE = "кишкожору",
		ACCUSATIVE = "кишкожора",
		INSTRUMENTAL = "кишкожором",
		PREPOSITIONAL = "кишкожоре"
	)

/mob/living/simple_animal/hostile/asteroid/gutlunch/Initialize(mapload)
	udder = new()
	. = ..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/examine(mob/user)
	. = ..()
	if(udder)
		. += span_notice("В его [udder.declent_ru(PREPOSITIONAL)] содержится [udder.reagents.total_volume] единиц[declension_ru(udder.reagents.total_volume, "а", "ы", "")] молока.")

/mob/living/simple_animal/hostile/asteroid/gutlunch/Destroy()
	QDEL_NULL(udder)
	return ..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/regenerate_icons()
	..()
	if(udder.reagents.total_volume == udder.reagents.maximum_volume)
		add_overlay("gl_full")


/mob/living/simple_animal/hostile/asteroid/gutlunch/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/reagent_containers/glass))
		add_fingerprint(user)
		if(stat != CONSCIOUS)
			to_chat(user, span_warning("[capitalize(declent_ru(NOMINATIVE))] выглядит нездоровым."))
			return ATTACK_CHAIN_PROCEED
		if(udder.milkAnimal(I, user))
			regenerate_icons()
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	return ..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/ListTargetsLazy(check_z)//override to include wanted_objects as valid targets
	. = ..()
	for(var/atom/movable/movable as anything in view(vision_range, loc))
		if(wanted_objects[movable.type])
			if(isturf(movable.loc))
				. += movable

/mob/living/simple_animal/hostile/asteroid/gutlunch/CanAttack(atom/the_target) // Gutlunch-specific version of CanAttack to handle stupid stat_exclusive = true crap so we don't have to do it for literally every single simple_animal/hostile except the two that spawn in lavaland
	if(isturf(the_target) || !the_target || the_target.type == /atom/movable/lighting_object) // bail out on invalids
		return FALSE

	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(isliving(the_target))
		var/mob/living/L = the_target

		if(faction_check_mob(L) && !attack_same)
			return FALSE
		if(L.stat > stat_attack || L.stat != stat_attack && stat_exclusive)
			return FALSE

		return TRUE

	if(isobj(the_target) && is_type_in_typecache(the_target, wanted_objects))
		return TRUE

	return FALSE

/mob/living/simple_animal/hostile/asteroid/gutlunch/AttackingTarget()
	if(is_type_in_typecache(target,wanted_objects)) //we eats
		udder.generateMilk()
		regenerate_icons()
		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] с хлюпаньем поглощает [target.declent_ru(ACCUSATIVE)]."))
		qdel(target)
		return
	return ..()

/obj/item/udder/gutlunch
	name = "nutrient sac"

/obj/item/udder/gutlunch/get_ru_names()
	return list(
		NOMINATIVE = "питательный мешок",
		GENITIVE = "питательного мешка",
		DATIVE = "питательному мешку",
		ACCUSATIVE = "питательный мешок",
		INSTRUMENTAL = "питательным мешком",
		PREPOSITIONAL = "питательном мешке"
	)

/obj/item/udder/gutlunch/Initialize(mapload)
	. = ..()
	reagents = new(50)
	reagents.my_atom = src

/obj/item/udder/gutlunch/generateMilk()
	reagents.add_reagent("bugmilk", rand(2, 5))

//Male gutlunch. They're smaller and more colorful!
/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck
	name = "gubbuck"
	gender = MALE

/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck/get_ru_names()
	return list(
		NOMINATIVE = "жирохрюн",
		GENITIVE = "жирохрюна",
		DATIVE = "жирохрюну",
		ACCUSATIVE = "жирохрюна",
		INSTRUMENTAL = "жирохрюном",
		PREPOSITIONAL = "жирохрюне"
	)

/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck/Initialize(mapload)
	. = ..()
	add_atom_colour(pick("#E39FBB", "#D97D64", "#CF8C4A"), FIXED_COLOUR_PRIORITY)
	update_transform(0.85)

//Lady gutlunch. They make the babby.
/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen
	name = "guthen"
	gender = FEMALE

/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen/get_ru_names()
	return list(
		NOMINATIVE = "квохтун",
		GENITIVE = "квохтуна",
		DATIVE = "квохтуну",
		ACCUSATIVE = "квохтуна",
		INSTRUMENTAL = "квохтуном",
		PREPOSITIONAL = "квохтуне"
	)

/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen/Life()
	..()
	if(udder.reagents.total_volume == udder.reagents.maximum_volume) //Only breed when we're full.
		make_babies()

/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen/make_babies()
	. = ..()
	if(.)
		udder.reagents.clear_reagents()
		regenerate_icons()

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch
	name = "grublunch"
	wanted_objects = list() //They don't eat.
	gold_core_spawnable = NO_SPAWN
	var/growth = 0

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/get_ru_names()	
	return list(
		NOMINATIVE = "червожор",
		GENITIVE = "червожора",
		DATIVE = "червожору",
		ACCUSATIVE = "червожора",
		INSTRUMENTAL = "червожором",
		PREPOSITIONAL = "червожоре"
	)

//Baby gutlunch
/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/Initialize(mapload)
	. = ..()
	add_atom_colour("#9E9E9E", FIXED_COLOUR_PRIORITY) //Somewhat hidden
	update_transform(0.45)

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/Life()
	..()
	growth++
	if(growth > 50) //originally used a timer for this but was more problem that it's worth.
		growUp()

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/proc/growUp()
	var/mob/living/L
	if(prob(45))
		L = new /mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck(loc)
	else
		L = new /mob/living/simple_animal/hostile/asteroid/gutlunch/guthen(loc)
	mind?.transfer_to(L)
	L.faction = faction.Copy()
	L.setDir(dir)
	visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] вырастает в [L.declent_ru(ACCUSATIVE)]."))
	qdel(src)
