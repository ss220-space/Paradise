//An ore-devouring but easily scared creature
/mob/living/simple_animal/hostile/asteroid/goldgrub
	name = "goldgrub"
	desc = "Червеобразный обжора, толстеющий от всего съеденного. Особенно любит драгоценные металлы и блестяшки — отсюда и имя."
	ru_names = list(
		NOMINATIVE = "златожор",
		GENITIVE = "златожора",
		DATIVE = "златожору",
		ACCUSATIVE = "златожора",
		INSTRUMENTAL = "златожором",
		PREPOSITIONAL = "златожоре"
	)
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "Goldgrub"
	icon_living = "Goldgrub"
	icon_aggro = "Goldgrub_alert"
	icon_dead = "Goldgrub_dead"
	icon_gib = "syndicate_gib"
	vision_range = 2
	aggro_vision_range = 9
	move_to_delay = 5
	friendly = "безвредно перекатывается в"
	maxHealth = 45
	health = 45
	harm_intent_damage = 5
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "давит"
	attack_sound = 'sound/weapons/punch1.ogg'
	a_intent = INTENT_HELP
	speak_emote = list("визжит")
	throw_message = "медленно погружается, после чего отскакивает из"
	deathmessage = "выплёвывает содержимое желудка перед смертью!"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/monstermeat/goldgrub = 1)
	status_flags = CANPUSH
	search_objects = 1
	wanted_objects = list(/obj/item/stack/ore/diamond, /obj/item/stack/ore/gold, /obj/item/stack/ore/silver,
						  /obj/item/stack/ore/uranium, /obj/item/stack/ore/titanium)
	jewelry_loot = /obj/item/gem/rupee
	var/chase_time = 100
	var/will_burrow = TRUE
	var/max_loot = 15 // The maximum amount of ore that can be stored in this thing's gut

/mob/living/simple_animal/hostile/asteroid/goldgrub/Initialize(mapload)
	. = ..()
	var/i = rand(1,3)
	while(i)
		loot += pick(wanted_objects)
		i--

/mob/living/simple_animal/hostile/asteroid/goldgrub/GiveTarget(new_target)
	add_target(new_target)
	if(!QDELETED(target))
		if(wanted_objects[target.type] && loot.len < max_loot)
			visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] смотрит на [target.declent_ru(ACCUSATIVE)] голодными глазами."))
		else if(iscarbon(target) || issilicon(target))
			Aggro()
			visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] пытается сбежать от [target.declent_ru(ACCUSATIVE)]!"))
			retreat_distance = 10
			minimum_distance = 10
			if(will_burrow)
				addtimer(CALLBACK(src, PROC_REF(Burrow)), chase_time)

/mob/living/simple_animal/hostile/asteroid/goldgrub/AttackingTarget()
	if(wanted_objects[target.type])
		EatOre(target)
		return
	return ..()

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/EatOre(atom/targeted_ore)
	var/obj/item/stack/ore/O = targeted_ore
	if(length(loot) < max_loot)
		var/using = min(max_loot - length(loot), O.amount)
		for(var/i in 1 to using)
			loot += O.type
		O.use(using)
		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] целиком проглотил руду!"))
	else // We are now full! We will consume no more ore ever again.
		search_objects = 0
		visible_message(span_notice("[capitalize(declent_ru(NOMINATIVE))] поклёвывает немного руды и останавливается. Похоже, он наелся."))

/mob/living/simple_animal/hostile/asteroid/goldgrub/proc/Burrow()//You failed the chase to kill the goldgrub in time!
	if(stat == CONSCIOUS)
		visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] зарывается в землю и исчезает из виду!"))
		qdel(src)

/mob/living/simple_animal/hostile/asteroid/goldgrub/bullet_act(obj/projectile/P)
	visible_message(span_danger("[P.name] отскакивает от тучного брюха [declent_ru(GENITIVE)]"), projectile_message = TRUE)


/mob/living/simple_animal/hostile/asteroid/goldgrub/adjustHealth(
	amount = 0,
	updating_health = TRUE,
	blocked = 0,
	damage_type = BRUTE,
	forced = FALSE,
)
	. = ..()
	if(. && amount > 0)
		vision_range = 9

