#define SNIFF 1
#define SHAKE 2
#define SCRATCH 3
#define WASHUP 4

/mob/living/simple_animal/mouse
	name = "mouse"
	real_name = "mouse"
	desc = "It's a small, disease-ridden rodent."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	icon_resting = "mouse_gray_sleep"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks","squeaks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
	var/squeak_sound = 'sound/creatures/mouse_squeak.ogg'
	talk_sound = list('sound/creatures/rat_talk.ogg')
	damaged_sound = list('sound/creatures/rat_wound.ogg')
	death_sound = 'sound/creatures/rat_death.ogg'
	tts_seed = "Gyro"
	speak_chance = 1
	turns_per_move = 5
	nightvision = 6
	maxHealth = 5
	health = 5
	blood_volume = BLOOD_VOLUME_SURVIVE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/mouse = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	density = FALSE
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	mob_size = MOB_SIZE_TINY
	layer = MOB_LAYER
	atmos_requirements = list("min_oxy" = 16, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = FALSE
	can_hide = TRUE
	pass_door_while_hidden = TRUE
	holder_type = /obj/item/holder/mouse
	can_collar = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	var/chew_probability = 1
	var/obj/item/mouse_jetpack/jetpack
	var/static/list/animated_mouses = list(
			/mob/living/simple_animal/mouse,
			/mob/living/simple_animal/mouse/brown,
			/mob/living/simple_animal/mouse/white,
			/mob/living/simple_animal/mouse/blobinfected)

/mob/living/simple_animal/mouse/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/squeak, list(squeak_sound), 100, extrarange = SHORT_RANGE_SOUND_EXTRARANGE, dead_check = TRUE) //as quiet as a mouse or whatever
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/mob/living/simple_animal/mouse/add_strippable_element()
	AddElement(/datum/element/strippable, GLOB.strippable_mouse_items)

/mob/living/simple_animal/mouse/death(gibbed)
	if(jetpack)
		remove_from_back(null)
	. = ..()


/mob/living/simple_animal/mouse/handle_automated_action()
	if(prob(chew_probability) && isturf(loc))
		var/turf/simulated/floor/F = get_turf(src)
		if(istype(F) && !F.intact && !F.transparent_floor)
			var/obj/structure/cable/C = locate() in F
			if(C && prob(15))
				if(C.avail())
					visible_message(span_warning("[src] chews through [C]. It's toast!"))
					playsound(src, 'sound/effects/sparks2.ogg', 100, TRUE)
					toast() // mmmm toasty.
				else
					visible_message(span_warning("[src] chews through [C]."))
				investigate_log("was chewed through by a mouse at [COORD(F)]", INVESTIGATE_WIRES)
				C.deconstruct()

/mob/living/simple_animal/mouse/handle_automated_speech()
	..()
	if(prob(speak_chance) && !incapacitated())
		playsound(src, squeak_sound, 100, TRUE)

/mob/living/simple_animal/mouse/handle_automated_movement()
	. = ..()
	if(resting)
		if(prob(1))
			set_resting(FALSE, instant = TRUE)
			if(is_available_for_anim())
				do_idle_animation(pick(SNIFF, SCRATCH, SHAKE, WASHUP))
		else if(prob(5))
			custom_emote(EMOTE_AUDIBLE, "соп%(ит,ят)%.")
	else if(prob(0.5))
		set_resting(TRUE, instant = TRUE)

/mob/living/simple_animal/mouse/proc/do_idle_animation(anim)
	ADD_TRAIT(src, TRAIT_IMMOBILIZED, "mouse_animation_trait_[anim]")
	flick("[initial(icon_state)]_idle[anim]",src)
	addtimer(CALLBACK(src, PROC_REF(animation_end), anim), 2 SECONDS)

/mob/living/simple_animal/mouse/proc/animation_end(anim)
	REMOVE_TRAIT(src, TRAIT_IMMOBILIZED, "mouse_animation_trait_[anim]")

/mob/living/simple_animal/mouse/proc/is_available_for_anim()
	. = FALSE
	if(is_type_in_list(src, animated_mouses, FALSE))
		return TRUE


/mob/living/simple_animal/mouse/New()
	..()
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)

	if(is_available_for_anim())
		add_verb(src, /mob/living/simple_animal/mouse/proc/sniff)
		add_verb(src, /mob/living/simple_animal/mouse/proc/shake)
		add_verb(src, /mob/living/simple_animal/mouse/proc/scratch)
		add_verb(src, /mob/living/simple_animal/mouse/proc/washup)


/mob/living/simple_animal/mouse/update_icons()
	if(!jetpack)
		..()
		return

	icon_state = "[initial(icon_state)]_jet"
	regenerate_icons()


/mob/living/simple_animal/mouse/attack_hand(mob/living/carbon/human/M)
	if(M.a_intent == INTENT_HELP)
		get_scooped(M)
	..()


/mob/living/simple_animal/mouse/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/mouse_jetpack)) // fly me to the moon
		add_fingerprint(user)
		if(place_on_back(I, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	return ..()


/mob/living/simple_animal/mouse/proc/place_on_back(obj/item/item_to_add, mob/living/user)
	if(stat != CONSCIOUS)
		to_chat(user, span_warning("[src] has problems with health."))
		return FALSE
	if(jetpack)
		to_chat(user, span_warning("[src] already has a jetpack!"))
		return FALSE
	if(!mind || !is_available_for_anim())
		to_chat(user, span_warning("[src] doesn't seem interested in that."))
		return FALSE
	if(!user.drop_transfer_item_to_loc(item_to_add, src))
		return FALSE

	jetpack = item_to_add
	user.visible_message(span_notice("[user] put something on [src]."),
		span_notice("You equip [src] with a cool jetpack! Sick!"),
		span_italics("You hear the roar of a small engine."))

	RegisterSignal(src, COMSIG_MOB_GHOSTIZE, PROC_REF(remove_from_back))
	update_icons()
	update_move_type(item_to_add)
	return TRUE


/mob/living/simple_animal/mouse/proc/delayed_jetpack_remove()
	to_chat(src, span_notice("You start dragging jetpack from your back."))
	if(do_after(src, 3 SECONDS, src, NONE))
		remove_from_back(null)


/mob/living/simple_animal/mouse/proc/remove_from_back(mob/living/user)
	SIGNAL_HANDLER

	if(!jetpack || QDELETED(jetpack))
		return

	drop_item_ground(jetpack)

	if(user)
		user.put_in_hands(jetpack, ignore_anim = FALSE)
	else if(prob(85))
		step_rand(jetpack)

	var/removed_item = jetpack
	jetpack = null

	UnregisterSignal(src, COMSIG_MOB_GHOSTIZE)
	update_icons()
	update_move_type(removed_item)


/mob/living/simple_animal/mouse/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return jetpack ? TRUE : ..()


/mob/living/simple_animal/mouse/proc/update_move_type(obj/item/mouse_jetpack/jetpack)
	if(src.jetpack)
		if(resting)
			set_resting(FALSE, instant = TRUE)

		if(can_hide)
			for(var/datum/action/innate/hide/hide in actions)
				if(layer == hide.layer_to_change_to)
					hide.Activate()
				hide.Remove(src)

		var/datum/action/innate/drop_jetpack/dropjet = new()
		dropjet.Grant(src)

		add_movespeed_modifier(/datum/movespeed_modifier/mouse_jetpack)
		REMOVE_TRAIT(src, initial(ventcrawler_trait), INNATE_TRAIT)
		ADD_TRAIT(src, TRAIT_FORCED_STANDING, UNIQUE_TRAIT_SOURCE(src.jetpack))
	else
		for(var/datum/action/innate/drop_jetpack/dropjet in actions)
			dropjet.Remove(src)

		if(can_hide)
			var/datum/action/innate/hide/hide = new()
			hide.Grant(src)

		remove_movespeed_modifier(/datum/movespeed_modifier/mouse_jetpack)
		ADD_TRAIT(src, initial(ventcrawler_trait), INNATE_TRAIT)
		REMOVE_TRAIT(src, TRAIT_FORCED_STANDING, UNIQUE_TRAIT_SOURCE(jetpack))


/mob/living/simple_animal/mouse/attack_animal(mob/living/simple_animal/M)
	if(istype(M, /mob/living/simple_animal/pet/cat))
		var/mob/living/simple_animal/pet/cat/C = M
		if(C.friendly && C.eats_mice && C.a_intent == INTENT_HARM)
			apply_damage(15, BRUTE) //3x от ХП обычной мыши или полное хп крысы
			visible_message(span_danger("[M.declent_ru(NOMINATIVE)] [M.attacktext] [src.declent_ru(ACCUSATIVE)]!"), \
							span_userdanger("[M.declent_ru(NOMINATIVE)] [M.attacktext] [src.declent_ru(ACCUSATIVE)]!"))
			return
	. = ..()

/mob/living/simple_animal/mouse/pull_constraint(atom/movable/pulled_atom, state, supress_message = FALSE) //Prevents mouse from pulling things
	if(istype(pulled_atom, /obj/item/reagent_containers/food/snacks/cheesewedge))
		return TRUE // Get dem
	if(!supress_message)
		to_chat(src, span_warning("You are too small to pull anything except cheese."))
	return FALSE


/mob/living/simple_animal/mouse/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	mouse_crossed(arrived)


/mob/living/simple_animal/mouse/proc/mouse_crossed(atom/movable/arrived)
	if(!stat && ishuman(arrived))
		to_chat(arrived, span_notice("[bicon(src)] Squeek!"))


/mob/living/simple_animal/mouse/ratvar_act()
	new/mob/living/simple_animal/mouse/clockwork(loc)
	gib()

/mob/living/simple_animal/mouse/proc/toast()
	add_atom_colour("#3A3A3A", FIXED_COLOUR_PRIORITY)
	desc = "It's toast."
	death()

/mob/living/simple_animal/mouse/proc/splat(obj/item/item, mob/living/user)
	var/temp_state = initial(icon_state)
	icon_dead = "[temp_state]_splat"
	icon_state = "[temp_state]_splat"

	if(prob(50))
		var/turf/location = get_turf(src)
		add_splatter_floor(location)
		if(item)
			item.add_mob_blood(src)
		if(user)
			user.add_mob_blood(src)

/mob/living/simple_animal/mouse/death(gibbed)
	if(gibbed)
		make_remains()

	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	layer = MOB_LAYER

/mob/living/simple_animal/mouse/proc/make_remains()
	var/obj/effect/decal/remains = new /obj/effect/decal/remains/mouse(src.loc)
	remains.pixel_x = pixel_x
	remains.pixel_y = pixel_y

/*
 * Mouse animation emotes
 */

/mob/living/simple_animal/mouse/proc/sniff()
	set name = "Понюхать"
	set desc = "Пытаешься что-то почуять"
	set category = "Мышь"

	emote("msniff", intentional = TRUE)

/mob/living/simple_animal/mouse/proc/shake()
	set name = "Дрожать"
	set desc = "Дрожит или дрыгается"
	set category = "Мышь"

	emote("mshake", intentional = TRUE)

/mob/living/simple_animal/mouse/proc/scratch()
	set name = "Почесаться"
	set desc = "Чешется"
	set category = "Мышь"

	emote("mscratch", intentional = TRUE)

/mob/living/simple_animal/mouse/proc/washup()
	set name = "Умыться"
	set desc = "Умывается"
	set category = "Мышь"

	emote("mwashup", intentional = TRUE)

/datum/emote/living/simple_animal/mouse/idle
	key = "msniff"
	key_third_person = "msniffs"
	message = "нюха%(ет,ют)%!"
	emote_type = EMOTE_AUDIBLE
	muzzled_noises = list("гортанные", "громкие")
	cooldown = 1 MINUTES
	audio_cooldown = 1 MINUTES
	var/anim_type = SNIFF
	volume = 1
	emote_type = EMOTE_VISIBLE|EMOTE_FORCE_NO_RUNECHAT

/datum/emote/living/simple_animal/mouse/idle/run_emote(mob/living/simple_animal/mouse/user, params, type_override, intentional)
	if(user.jetpack)
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob/living/simple_animal/mouse, delayed_jetpack_remove))
		return FALSE
	else
		INVOKE_ASYNC(user, TYPE_PROC_REF(/mob/living/simple_animal/mouse, do_idle_animation), anim_type)
		return ..()

/datum/emote/living/simple_animal/mouse/idle/get_sound(mob/living/simple_animal/mouse/user)
	return user.squeak_sound

/datum/emote/living/simple_animal/mouse/idle/shake
	key = "mshake"
	key_third_person = "mshakes"
	message = "дрож%(ит,ат)%!"
	anim_type = SHAKE

/datum/emote/living/simple_animal/mouse/idle/scratch
	key = "mscratch"
	key_third_person = "mscratches"
	message = "чеш%(ет,ут)%ся!"
	anim_type = SCRATCH

/datum/emote/living/simple_animal/mouse/idle/washup
	key = "mwashup"
	key_third_person = "mwashesup"
	message = "умыва%(ет,ют)%ся!"
	anim_type = WASHUP

/*
 * Mouse types
 */

/mob/living/simple_animal/mouse/white
	icon_state = "mouse_white"
	icon_living = "mouse_white"
	icon_dead = "mouse_white_dead"
	icon_resting = "mouse_white_sleep"
	tts_seed = "Meepo"

/mob/living/simple_animal/mouse/brown
	icon_state = "mouse_brown"
	icon_living = "mouse_brown"
	icon_dead = "mouse_brown_dead"
	icon_resting = "mouse_brown_sleep"
	tts_seed = "Clockwerk"

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/brown/Tom
	name = "Tom"
	desc = "Jerry the cat is not amused."
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN
	tts_seed = "Arthas"
	maxHealth = 10
	health = 10


/mob/living/simple_animal/mouse/blobinfected
	maxHealth = 100
	health = 100
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	gold_core_spawnable = NO_SPAWN


/mob/living/simple_animal/mouse/blobinfected/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(get_mind)), MOUSE_REVOTE_TIME)


/mob/living/simple_animal/mouse/blobinfected/get_scooped(mob/living/carbon/grabber)
	to_chat(grabber, span_warning("You try to pick up [src], but they slip out of your grasp!"))
	to_chat(src, span_warning("[src] tries to pick you up, but you wriggle free of their grasp!"))

/mob/living/simple_animal/mouse/blobinfected/proc/get_mind()
	if(mind || !SSticker || !SSticker.mode)
		return
	var/list/candidates = SSghost_spawns.poll_candidates("Вы хотите сыграть за мышь, зараженную Блобом?", ROLE_BLOB, TRUE, source = /mob/living/simple_animal/mouse/blobinfected)
	if(!length(candidates))
		log_and_message_admins("There were no players willing to play as a mouse infected with a blob.")
		return
	var/mob/M = pick(candidates)
	key = M.key
	var/datum_type = mind.get_blob_infected_type()
	var/datum/antagonist/blob_infected/blob_datum = new datum_type()
	blob_datum.time_to_burst_hight = TIME_TO_BURST_MOUSE_HIGHT
	blob_datum.time_to_burst_low = TIME_TO_BURST_MOUSE_LOW
	mind.add_antag_datum(blob_datum)
	to_chat(src, span_userdanger("Теперь вы мышь, заражённая спорами Блоба. Найдите какое-нибудь укромное место до того, как вы взорветесь и станете Блобом! Вы можете перемещаться по вентиляции, нажав Alt+ЛКМ на вентиляционном отверстии."))
	log_game("[key] has become blob infested mouse.")
	notify_ghosts("Заражённая мышь появилась в [get_area(src)].", source = src, action = NOTIFY_FOLLOW)

/mob/living/simple_animal/mouse/fluff/clockwork
	name = "Chip"
	real_name = "Chip"
	icon_state = "mouse_clockwork"
	icon_living = "mouse_clockwork"
	icon_dead = "mouse_clockwork_dead"
	icon_resting = "mouse_clockwork_sleep"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "stamps on"
	gold_core_spawnable = NO_SPAWN
	can_collar = FALSE
	butcher_results = list(/obj/item/stack/sheet/metal = 1)
	maxHealth = 20
	health = 20

/mob/living/simple_animal/mouse/decompile_act(obj/item/matter_decompiler/C, mob/user)
	if(!isdrone(user))
		user.visible_message(span_notice("[user] sucks [src] into its decompiler. There's a horrible crunching noise."), \
		span_warning("It's a bit of a struggle, but you manage to suck [src] into your decompiler. It makes a series of visceral crunching noises."))
		new/obj/effect/decal/cleanable/blood/splatter(get_turf(src))
		C.stored_comms["wood"] += 2
		C.stored_comms["glass"] += 2
		qdel(src)
		return TRUE
	return ..()

/mob/living/simple_animal/mouse/rat
	name = "rat"
	real_name = "rat"
	desc = "Серая крыса. Не самый яркий представитель своего вида."
	squeak_sound = 'sound/creatures/rat_squeak.ogg'
	icon_state 		= "rat_gray"
	icon_living 	= "rat_gray"
	icon_dead 		= "rat_gray_dead"
	icon_resting 	= "rat_gray_sleep"
	maxHealth = 15
	health = 15
	mob_size = MOB_SIZE_SMALL
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/mouse = 2)


/mob/living/simple_animal/mouse/rat/gray
	name = "gray rat"
	real_name = "gray rat"
	desc = "Серая крыса. Не самый яркий представитель своего вида."

/mob/living/simple_animal/mouse/rat/white
	name = "white rat"
	real_name = "white rat"
	desc = "Типичный представитель лабораторных крыс."
	icon_state 		= "rat_white"
	icon_living 	= "rat_white"
	icon_dead 		= "rat_white_dead"
	icon_resting 	= "rat_white_sleep"

/mob/living/simple_animal/mouse/rat/irish
	name = "irish rat"		//Да, я знаю что это вид. Это каламбурчик.
	real_name = "irish rat"
	desc = "Ирландская крыса. На космической станции?! На этот раз им точно некуда бежать!"
	icon_state 		= "rat_irish"
	icon_living 	= "rat_irish"
	icon_dead 		= "rat_irish_dead"
	icon_resting 	= "rat_irish_sleep"

#define MAX_HAMSTER 50
GLOBAL_VAR_INIT(hamster_count, 0)

/mob/living/simple_animal/mouse/hamster
	name = "хомяк"
	real_name = "хомяк"
	desc = "С надутыми щёчками."
	icon_state = "hamster"
	icon_living = "hamster"
	icon_dead = "hamster_dead"
	icon_resting = "hamster_rest"
	gender = MALE
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	speak_chance = 0
	childtype = list(/mob/living/simple_animal/mouse/hamster/baby)
	animal_species = /mob/living/simple_animal/mouse/hamster
	holder_type = /obj/item/holder/hamster
	gold_core_spawnable = FRIENDLY_SPAWN
	tts_seed = "Gyro"
	maxHealth = 10
	health = 10


/mob/living/simple_animal/mouse/hamster/update_desc(updates)
	. = ..()	// We get initial desc here.
	desc += gender == MALE ? " Самец!" : " Самочка! Ох... Нет..."


/mob/living/simple_animal/mouse/hamster/Initialize(mapload)
	. = ..()
	GLOB.hamster_count++
	gender = prob(80) ? MALE : FEMALE
	update_appearance(UPDATE_DESC)


/mob/living/simple_animal/mouse/hamster/Destroy()
	GLOB.hamster_count--
	. = ..()

/mob/living/simple_animal/mouse/hamster/death(gibbed)
	if(!gibbed)
		GLOB.hamster_count--
	. = ..()

/mob/living/simple_animal/mouse/hamster/pull_constraint(atom/movable/pulled_atom, state, supress_message = FALSE)
	return TRUE

/mob/living/simple_animal/mouse/hamster/Life(seconds, times_fired)
	..()
	if(GLOB.hamster_count < MAX_HAMSTER)
		make_babies()

/mob/living/simple_animal/mouse/hamster/baby
	name = "хомячок"
	real_name = "хомячок"
	desc = "Очень миленький! Какие у него пушистые щёчки!"
	tts_seed = "Meepo"
	turns_per_move = 2
	response_help  = "полапал"
	response_disarm = "аккуратно отодвинул"
	response_harm   = "наступил на"
	attacktext = "толкается"
	transform = matrix(0.7, 0, 0, 0, 0.7, 0)
	health = 3
	maxHealth = 3
	var/amount_grown = 0
	can_collar = FALSE
	holder_type = /obj/item/holder/hamster


/mob/living/simple_animal/mouse/hamster/baby/start_pulling(atom/movable/pulled_atom, state, force = pull_force, supress_message = FALSE)
	if(!supress_message)
		to_chat(src, span_warning("Вы слишком малы, чтобы что-то тащить."))
	return FALSE


/mob/living/simple_animal/mouse/hamster/baby/Life(seconds, times_fired)
	. =..()
	if(!.)
		return .

	amount_grown++
	if(amount_grown < 100)
		return .

	var/mob/living/simple_animal/A = new /mob/living/simple_animal/mouse/hamster(loc)
	if(mind)
		mind.transfer_to(A)
	qdel(src)


/mob/living/simple_animal/mouse/hamster/baby/mouse_crossed(atom/movable/arrived)
	if(!stat && ishuman(arrived))
		to_chat(arrived, span_notice("[bicon(src)] раздавл[genderize_ru(gender, "ен", "на", "но")]!"))
		death()
		splat(user = arrived)



#undef SNIFF
#undef SHAKE
#undef SCRATCH
#undef WASHUP
