//goat
/mob/living/simple_animal/hostile/retaliate/goat
	name = "goat"
	desc = "Не отличаются приятным нравом."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("блеет")
	emote_hear = list("блеет")
	emote_see = list("трясёт головой", "бьёт копытом", "грозно зыркает вокруг")
	tts_seed = "Muradin"
	speak_chance = 1
	turns_per_move = 5
	nightvision = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 4)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "пинает"
	faction = list("neutral")
	attack_same = 1
	attacktext = "бодает"
	attack_sound = 'sound/weapons/punch1.ogg'
	death_sound = 'sound/creatures/goat_death.ogg'
	health = 40
	maxHealth = 40
	melee_damage_lower = 1
	melee_damage_upper = 2
	stop_automated_movement_when_pulled = 1
	can_collar = 1
	blood_volume = BLOOD_VOLUME_NORMAL
	var/obj/item/udder/udder = null
	footstep_type = FOOTSTEP_MOB_SHOE
	ru_names = list(NOMINATIVE = "козёл", GENITIVE = "козла", DATIVE = "козлу", ACCUSATIVE = "козла", INSTRUMENTAL = "козлом", PREPOSITIONAL = "козле")

/mob/living/simple_animal/hostile/retaliate/goat/New()
	udder = new()
	. = ..()

/mob/living/simple_animal/hostile/retaliate/goat/Destroy()
	QDEL_NULL(udder)
	return ..()

/mob/living/simple_animal/hostile/retaliate/goat/handle_automated_movement()
	. = ..()
	//chance to go crazy and start wacking stuff
	if(!enemies.len && prob(1))
		Retaliate()

	if(enemies.len && prob(10))
		enemies = list()
		LoseTarget()
		visible_message(span_notice("[capitalize(src.declent_ru(NOMINATIVE))] успокаивается."))

	eat_plants()
	if(!pulledby)
		for(var/direction in shuffle(list(1, 2, 4, 8, 5, 6, 9, 10)))
			var/step = get_step(src, direction)
			if(step)
				if(locate(/obj/structure/spacevine) in step || locate(/obj/structure/glowshroom) in step)
					step_with_glide(step)


/mob/living/simple_animal/hostile/retaliate/goat/Life(seconds, times_fired)
	. = ..()
	if(stat == CONSCIOUS)
		udder.generateMilk()

/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	..()
	visible_message(span_danger("Глаза [src.declent_ru(GENITIVE)] наливаются красным!"))

/mob/living/simple_animal/hostile/retaliate/goat/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	if(!stat)
		eat_plants()


/mob/living/simple_animal/hostile/retaliate/goat/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/reagent_containers/glass))
		add_fingerprint(user)
		if(stat != CONSCIOUS)
			to_chat(user, span_warning("[src] has problems with health."))	// yeah, ITS DEAD
			return ATTACK_CHAIN_PROCEED
		if(udder.milkAnimal(I, user))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	return ..()


/mob/living/simple_animal/hostile/retaliate/goat/proc/eat_plants()
	var/eaten = FALSE
	var/obj/structure/spacevine/SV = locate(/obj/structure/spacevine) in loc
	if(SV)
		SV.eat(src)
		eaten = TRUE

	var/obj/structure/glowshroom/GS = locate(/obj/structure/glowshroom) in loc
	if(GS)
		qdel(GS)
		eaten = TRUE

	if(eaten && prob(10))
		say("Nom")

/mob/living/simple_animal/hostile/retaliate/goat/AttackingTarget()
	. = ..()
	if(. && isdiona(target))
		var/mob/living/carbon/human/H = target
		var/obj/item/organ/external/NB = pick(H.bodyparts)
		H.visible_message(span_warning("[capitalize(src.declent_ru(NOMINATIVE))] отрывает большой кусок от [H]!"), \
				span_userdanger("[capitalize(src.declent_ru(NOMINATIVE))] отрывает от вас большой кусок [NB.declent_ru(GENITIVE)]!"))
		NB.droplimb()

//cow
/mob/living/simple_animal/cow
	name = "cow"
	desc = "Известны своим молоком. Только не опрокидывайте их."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	speak = list("moo?","moo","MOOOOOO")
	speak_emote = list("мычит","протяжно мычит")
	emote_hear = list("ревёт")
	emote_see = list("трясёт головой")
	tts_seed = "Cairne"
	speak_chance = 1
	turns_per_move = 5
	nightvision = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 6)
	food_type = list(/obj/item/reagent_containers/food/snacks/grown/wheat)
	var/list/feedMessages = list("довольно мычит","благодарно мычит", "довольно помахивает хвостом")
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "пинает"
	attacktext = "бодает"
	attack_sound = 'sound/weapons/punch1.ogg'
	death_sound = 'sound/creatures/cow_death.ogg'
	damaged_sound = list('sound/creatures/cow_damaged.ogg')
	talk_sound = list('sound/creatures/cow_talk1.ogg', 'sound/creatures/cow_talk2.ogg')
	health = 50
	maxHealth = 50
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	var/obj/item/udder/udder = null
	gender = FEMALE
	footstep_type = FOOTSTEP_MOB_SHOE
	ru_names = list(NOMINATIVE = "корова", GENITIVE = "коровы", DATIVE = "корове", ACCUSATIVE = "корову", INSTRUMENTAL = "коровой", PREPOSITIONAL = "корове")
	COOLDOWN_DECLARE(feeded_cow)

/mob/living/simple_animal/cow/Initialize()
	udder = new()
	. = ..()

/mob/living/simple_animal/cow/Destroy()
	qdel(udder)
	udder = null
	return ..()


/mob/living/simple_animal/cow/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_type_in_list(I, food_type))
		add_fingerprint(user)
		if(stat != CONSCIOUS)
			user.balloon_alert(user, "[declent_ru(NOMINATIVE)] нездоров[genderize_ru(src, "", "а", "о", "ы")]")
			return ATTACK_CHAIN_PROCEED
		if(COOLDOWN_TIMELEFT(src, feeded_cow) > 40 SECONDS) //starting milk mini-factory
			user.balloon_alert(user, "[declent_ru(NOMINATIVE)] не голод[genderize_ru(src, "ен", "на", "но", "ны")]")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] скармлива[pluralize_ru(user.gender, "ет", "ют")] пшеницу [declent_ru(DATIVE)]! [genderize_ru(src, "Он", "Она", "Оно", "Они")] [pick(feedMessages)]."),
			span_notice("Вы скармливаете пшеницу [declent_ru(DATIVE)]! [genderize_ru(src, "Он", "Она", "Оно", "Они")] [pick(feedMessages)].")
		)
		COOLDOWN_START(src, feeded_cow, 60 SECONDS)
		udder.feeded = TRUE
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/reagent_containers/glass))
		add_fingerprint(user)
		if(stat != CONSCIOUS)
			to_chat(user, span_warning("[src] has problems with health."))
			return ATTACK_CHAIN_PROCEED
		if(udder.milkAnimal(I, user))
			return ATTACK_CHAIN_PROCEED_SUCCESS
		return ATTACK_CHAIN_PROCEED

	return ..()


/mob/living/simple_animal/cow/Life(seconds, times_fired)
	. = ..()
	if(udder.feeded && COOLDOWN_FINISHED(src, feeded_cow))
		udder.feeded = FALSE
	if(stat == CONSCIOUS)
		udder.generateMilk()

/mob/living/simple_animal/cow/attack_hand(mob/living/carbon/M)
	if(!stat && M.a_intent == INTENT_DISARM && icon_state != icon_dead)
		M.visible_message(span_warning("[M] опрокидыва[pluralize_ru(M.gender, "ет", "ют")] [src.declent_ru(ACCUSATIVE)]!"), \
								span_notice("Вы опрокидываете [src.declent_ru(ACCUSATIVE)]."))
		Weaken(60 SECONDS)
		icon_state = icon_dead
		spawn(rand(20,50))
			if(!stat && M)
				icon_state = icon_living
				var/list/responses = list(	" смотрит на вас умоляюще.",
											" смотрит на вас удручённо.",
											" смотрит на вас с покорностью в глазах.",
											", кажется, смирилась со своей участью.")
				to_chat(M, span_notice("[capitalize(src.declent_ru(NOMINATIVE))][pick(responses)]"))
	else
		..()

/mob/living/simple_animal/chick
	name = "\improper chick"
	desc = "Прелесть! Но они такие шумные."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	gender = FEMALE
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("чирикает")
	emote_hear = list("чирикает")
	emote_see = list("клюёт землю","хлопает крылышками")
	tts_seed = "Meepo"
	density = FALSE
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/bird = 1)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "пинает"
	attacktext = "клюёт"
	death_sound = 'sound/creatures/mouse_squeak.ogg'
	health = 3
	maxHealth = 3
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	var/amount_grown = 0
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	can_hide = 1
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW
	holder_type = /obj/item/holder/chick
	ru_names = list(NOMINATIVE = "цыплёнок", GENITIVE = "цыплёнка", DATIVE = "цыплёнку", ACCUSATIVE = "цыплёнка", INSTRUMENTAL = "цыплёнком", PREPOSITIONAL = "цыплёнке")

/mob/living/simple_animal/chick/New()
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

/mob/living/simple_animal/chick/Life(seconds, times_fired)
	. =..()
	if(.)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			var/mob/living/simple_animal/A
			if(prob(5))
				A = new /mob/living/simple_animal/cock(loc)
			else
				A = new /mob/living/simple_animal/chicken(loc)
			if(mind)
				mind.transfer_to(A)
			qdel(src)

#define MAX_CHICKENS 50
GLOBAL_VAR_INIT(chicken_count, 0)

/mob/living/simple_animal/chicken
	name = "\improper chicken"
	desc = "Надеюсь, в этом сезоне яйца будут хорошими."
	gender = FEMALE
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("кудахчет","квохчет")
	emote_hear = list("кудахчет")
	emote_see = list("клюёт землю", "резко встряхивает крыльями")
	tts_seed = "Windranger"
	density = FALSE
	speak_chance = 2
	turns_per_move = 3
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/bird = 2)
	var/egg_type = /obj/item/reagent_containers/food/snacks/egg
	food_type = list(/obj/item/reagent_containers/food/snacks/grown/wheat)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "пинает"
	attacktext = "клюёт"
	death_sound = 'sound/creatures/chicken_death.ogg'
	damaged_sound = list('sound/creatures/chicken_damaged1.ogg', 'sound/creatures/chicken_damaged2.ogg')
	talk_sound = list('sound/creatures/chicken_talk.ogg')
	health = 15
	maxHealth = 15
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	var/eggsleft = 0
	var/eggsFertile = TRUE
	var/body_color
	var/icon_prefix = "chicken"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	can_hide = 1
	can_collar = 1
	var/list/layMessage = EGG_LAYING_MESSAGES
	var/list/validColors = list("brown","black","white")
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW
	holder_type = /obj/item/holder/chicken
	ru_names = list(NOMINATIVE = "курица", GENITIVE = "курицы", DATIVE = "курице", ACCUSATIVE = "курицу", INSTRUMENTAL = "курицей", PREPOSITIONAL = "курице")

/mob/living/simple_animal/chicken/New()
	..()
	if(!body_color)
		body_color = pick(validColors)
	icon_state = "[icon_prefix]_[body_color]"
	icon_living = "[icon_prefix]_[body_color]"
	icon_dead = "[icon_prefix]_[body_color]_dead"
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	GLOB.chicken_count += 1

/mob/living/simple_animal/chicken/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return
	GLOB.chicken_count -= 1


/mob/living/simple_animal/chicken/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(is_type_in_list(I, food_type)) //feedin' dem chickens
		add_fingerprint(user)
		if(stat != CONSCIOUS)
			user.balloon_alert(user, "[declent_ru(NOMINATIVE)] нездоров[genderize_ru(src, "", "а", "о", "ы")]")
			return ATTACK_CHAIN_PROCEED
		if(eggsleft >= 8)
			user.balloon_alert(user, "[declent_ru(NOMINATIVE)] не голод[genderize_ru(src, "ен", "на", "но", "ны")]")
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] скармлива[pluralize_ru(user.gender, "ет", "ют")] пшеницу [declent_ru(DATIVE)]. [genderize_ru(src, "Он", "Она", "Оно", "Они")] радостно [pick(speak_emote)]."),
			span_notice("Вы скармливаете пшеницу [declent_ru(DATIVE)]. [genderize_ru(src, "Он", "Она", "Оно", "Они")] радостно [pick(speak_emote)]."),
		)
		eggsleft += rand(1, 4)
		qdel(I)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/mob/living/simple_animal/chicken/Life(seconds, times_fired)
	. = ..()
	if((. && prob(3) && eggsleft > 0) && egg_type)
		visible_message("[src] [pick(layMessage)]")
		eggsleft--
		var/obj/item/E = new egg_type(get_turf(src))
		E.pixel_x = rand(-6,6)
		E.pixel_y = rand(-6,6)
		if(eggsFertile)
			if(GLOB.chicken_count < MAX_CHICKENS && prob(25))
				START_PROCESSING(SSobj, E)

/obj/item/reagent_containers/food/snacks/egg/var/amount_grown = 0
/obj/item/reagent_containers/food/snacks/egg/process()
	if(isturf(loc))
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			visible_message(span_notice("Яйцо вылупляется с тихим треском."))
			new /mob/living/simple_animal/chick(get_turf(src))
			STOP_PROCESSING(SSobj, src)
			qdel(src)
	else
		STOP_PROCESSING(SSobj, src)

/mob/living/simple_animal/cock
	name = "Петух"
	desc = "Гордый и важный вид."
	gender = MALE
	icon_state = "cock"
	icon_living = "cock"
	icon_dead = "cock_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("кудахчет","квохчет")
	emote_hear = list("кудахчет")
	emote_see = list("клюёт землю", "резко встряхивает крыльями")
	tts_seed = "pantheon"
	density = FALSE
	speak_chance = 2
	turns_per_move = 3
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/bird = 4)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "пинает"
	melee_damage_type = STAMINA
	melee_damage_lower = 2
	melee_damage_upper = 6
	attacktext = "клюёт"
	death_sound = 'sound/creatures/chicken_death.ogg'
	damaged_sound = list('sound/creatures/chicken_damaged1.ogg', 'sound/creatures/chicken_damaged2.ogg')
	talk_sound = list('sound/creatures/chicken_talk.ogg')
	health = 30
	maxHealth = 30
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	can_hide = 1
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW
	holder_type = /obj/item/holder/cock
	ru_names = list(NOMINATIVE = "петух", GENITIVE = "петуха", DATIVE = "петуху", ACCUSATIVE = "петуха", INSTRUMENTAL = "петухом", PREPOSITIONAL = "петухе")

/mob/living/simple_animal/pig
	name = "pig"
	desc = "Хрю-хрю!"
	icon_state = "pig"
	icon_living = "pig"
	icon_dead = "pig_dead"
	speak = list("oink?","oink","OINK")
	speak_emote = list("хрюкает")
	tts_seed = "Anubarak"
//	emote_hear = list("brays")
	emote_see = list("перекатывается по земле")
	speak_chance = 1
	turns_per_move = 5
	nightvision = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/ham = 6)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "пинает"
	attacktext = "лягает"
	death_sound = 'sound/creatures/pig_death.ogg'
	talk_sound = list('sound/creatures/pig_talk1.ogg', 'sound/creatures/pig_talk2.ogg')
	damaged_sound = list()
	health = 50
	maxHealth = 50
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ru_names = list(NOMINATIVE = "свинья", GENITIVE = "свиньи", DATIVE = "свинье", ACCUSATIVE = "свинью", INSTRUMENTAL = "свиньёй", PREPOSITIONAL = "свинье")

/mob/living/simple_animal/turkey
	name = "turkey"
	desc = "Бенджамин Франклин мог бы гордиться."
	icon_state = "turkey"
	icon_living = "turkey"
	icon_dead = "turkey_dead"
	icon_resting = "turkey_rest"
	speak = list("gobble?","gobble","GOBBLE")
	speak_emote = list("кулдычет")
	emote_see = list("важно расхаживает")
	speak_chance = 1
	turns_per_move = 5
	nightvision = 6
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/bird = 4)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "пинает"
	attacktext = "клюёт"
	death_sound = 'sound/creatures/duck_quak1.ogg'
	health = 50
	maxHealth = 50
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_SHOE
	ru_names = list(NOMINATIVE = "индейка", GENITIVE = "индейки", DATIVE = "индейке", ACCUSATIVE = "индейку", INSTRUMENTAL = "индейкой", PREPOSITIONAL = "индейке")

/mob/living/simple_animal/goose
	name = "goose"
	desc = "Прекрасная птица для набива подушек и страха детишек."
	icon_state = "goose"
	icon_living = "goose"
	icon_dead = "goose_dead"
	icon_resting = "goose_rest"
	speak = list("quack?","quack","QUACK")
	speak_emote = list("quacks")
	tts_seed = "pantheon" //Жи есть брат да, я гусь, до тебя доебусь.
//	emote_hear = list("brays")
	emote_see = list("хлопает крыльями")
	speak_chance = 1
	turns_per_move = 5
	nightvision = 6
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/bird = 6)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "пинает"
	melee_damage_type = STAMINA
	melee_damage_lower = 2
	melee_damage_upper = 8
	attacktext = "щипает"
	death_sound = 'sound/creatures/duck_quak1.ogg'
	talk_sound = list('sound/creatures/duck_talk1.ogg', 'sound/creatures/duck_talk2.ogg', 'sound/creatures/duck_talk3.ogg', 'sound/creatures/duck_quak1.ogg', 'sound/creatures/duck_quak2.ogg', 'sound/creatures/duck_quak3.ogg')
	damaged_sound = list('sound/creatures/duck_aggro1.ogg', 'sound/creatures/duck_aggro2.ogg')
	health = 50
	maxHealth = 50
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_CLAW
	ru_names = list(NOMINATIVE = "гусь", GENITIVE = "гуся", DATIVE = "гусю", ACCUSATIVE = "гуся", INSTRUMENTAL = "гусём", PREPOSITIONAL = "гусе")

/mob/living/simple_animal/goose/gosling
	name = "gosling"
	desc = "Симпатичный гусёнок. Скоро он станет грозой всей станции."
	icon_state = "gosling"
	icon_living = "gosling"
	icon_dead = "gosling_dead"
	icon_resting = "gosling_rest"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/bird = 3)
	melee_damage_lower = 0
	melee_damage_upper = 0
	health = 20
	maxHealth = 20
	ru_names = list(NOMINATIVE = "гусёнок", GENITIVE = "гусёнка", DATIVE = "гусёнку", ACCUSATIVE = "гусёнка", INSTRUMENTAL = "гусёнком", PREPOSITIONAL = "гусёнке")

/mob/living/simple_animal/seal
	name = "seal"
	desc = "Красивый белый тюлень."
	icon_state = "seal"
	icon_living = "seal"
	icon_dead = "seal_dead"
	speak = list("Urk?","urk","URK")
	speak_emote = list("urks") //idk how to translate it...
	tts_seed = "Narrator"
	death_sound = 'sound/creatures/seal_death.ogg'
//	emote_hear = list("brays")
	emote_see = list("хлопает ластами")
	speak_chance = 1
	turns_per_move = 5
	nightvision = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 6)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "пинает"
	attacktext = "лягает"
	health = 50
	maxHealth = 50
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	footstep_type = FOOTSTEP_MOB_CLAW
	ru_names = list(NOMINATIVE = "тюлень", GENITIVE = "тюленя", DATIVE = "тюленю", ACCUSATIVE = "тюленя", INSTRUMENTAL = "тюленем", PREPOSITIONAL = "тюлене")

/mob/living/simple_animal/walrus
	name = "walrus"
	desc = "A big brown walrus."
	icon_state = "walrus"
	icon_living = "walrus"
	icon_dead = "walrus_dead"
	speak = list("Urk?","urk","URK")
	speak_emote = list("urks") //idk how to translate it...
	tts_seed = "Tychus"
	death_sound = 'sound/creatures/seal_death.ogg'
//	emote_hear = list("brays")
	emote_see = list("хлопает ластами")
	speak_chance = 1
	turns_per_move = 5
	nightvision = 6
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 6)
	response_help = "гладит"
	response_disarm = "осторожно отодвигает в сторону"
	response_harm = "пинает"
	attacktext = "лягает"
	health = 50
	maxHealth = 50
	can_collar = 1
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	ru_names = list(NOMINATIVE = "морж", GENITIVE = "моржа", DATIVE = "моржу", ACCUSATIVE = "моржа", INSTRUMENTAL = "моржом", PREPOSITIONAL = "морже")

/obj/item/udder
	name = "udder"
	var/feeded = FALSE

/obj/item/udder/New()
	create_reagents(80)
	reagents.add_reagent("milk", 20)
	. = ..()

/obj/item/udder/proc/generateMilk()
	var/probability = 5
	if(feeded)
		probability = 30

	if(prob(probability))
		reagents.add_reagent("milk", rand(5, 10))


/obj/item/udder/proc/milkAnimal(obj/item/reagent_containers/glass/container, mob/user)
	if(!container.reagents)
		user.balloon_alert(user, "неподходящая ёмкость!")
		return FALSE
	if(container.reagents.total_volume >= container.volume)
		user.balloon_alert(user, "ёмкость заполнена!")
		return FALSE
	var/transfered = reagents.trans_to(container, rand(5,10))
	if(!transfered)
		user.balloon_alert(user, "вымя сухое, подождите")
		return FALSE
	user.visible_message(
		span_notice("[user] до[pluralize_ru(user.gender, "ит", "ят")] [declent_ru(ACCUSATIVE)]."),
		span_notice("Вы доите [declent_ru(ACCUSATIVE)]."),
	)
	return TRUE

