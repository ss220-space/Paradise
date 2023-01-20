//Cat
/mob/living/simple_animal/pet/cat
	name = "cat"
	desc = "Kitty!!"
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	icon_resting = "cat2_rest"
	gender = MALE
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	emote_hear = list("meows", "mews")
	emote_see = list("shakes its head", "shivers")
	var/meow_sound = 'sound/creatures/cat_meow.ogg'	//Used in emote.
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	mob_size = MOB_SIZE_SMALL
	animal_species = /mob/living/simple_animal/pet/cat
	childtype = list(/mob/living/simple_animal/pet/cat/kitten)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 3)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_type = "cat"
	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target
	var/eats_mice = 1
	footstep_type = FOOTSTEP_MOB_CLAW
	tts_seed = "Valerian"
	holder_type = /obj/item/holder/cat2

/mob/living/simple_animal/pet/cat/floppa
	name = "Big Floppa"
	desc = "He looks like he is about to commit a warcrime.."
	icon_state = "floppa"
	icon_living = "floppa"
	icon_dead = "floppa_dead"
	icon_resting = "floppa_rest"
	unique_pet = TRUE
	tts_seed = "Uther"
	holder_type = null

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/pet/cat/Runtime
	name = "Runtime"
	desc = "GCAT"
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	icon_resting = "cat_rest"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	var/list/family = list()
	var/list/children = list() //Actual mob instances of children
	holder_type = /obj/item/holder/cat

/mob/living/simple_animal/pet/cat/Runtime/New()
	SSpersistent_data.register(src)
	..()

/mob/living/simple_animal/pet/cat/Runtime/persistent_load()
	read_memory()
	deploy_the_cats()

/mob/living/simple_animal/pet/cat/Runtime/persistent_save()
	write_memory(FALSE)

/mob/living/simple_animal/pet/cat/Runtime/make_babies()
	var/mob/baby = ..()
	if(baby)
		children += baby
		return baby

/mob/living/simple_animal/pet/cat/Runtime/death()
	if(can_die())
		write_memory(TRUE)
		SSpersistent_data.registered_atoms -= src // We just saved. Dont save at round end
	return ..()

/mob/living/simple_animal/pet/cat/Runtime/proc/read_memory()
	var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
	S["family"] 			>> family

	if(isnull(family))
		family = list()
	log_debug("Persistent data for [src] loaded (family: [family ? list2params(family) : "None"])")

/mob/living/simple_animal/pet/cat/Runtime/proc/write_memory(dead)
	var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
	family = list()
	if(!dead)
		for(var/mob/living/simple_animal/pet/cat/kitten/C in children)
			if(istype(C,type) || C.stat || !C.z || !C.butcher_results)
				continue
			if(C.type in family)
				family[C.type] += 1
			else
				family[C.type] = 1
	S["family"]				<< family
	log_debug("Persistent data for [src] saved (family: [family ? list2params(family) : "None"])")

/mob/living/simple_animal/pet/cat/Runtime/proc/deploy_the_cats()
	for(var/cat_type in family)
		if(family[cat_type] > 0)
			for(var/i in 1 to min(family[cat_type],100)) //Limits to about 500 cats, you wouldn't think this would be needed (BUT IT IS)
				new cat_type(loc)

/mob/living/simple_animal/pet/cat/Life()
	..()
	make_babies()

/mob/living/simple_animal/pet/cat/handle_automated_action()
	if(!stat && !buckled)
		if(prob(1))
			custom_emote(1, pick("stretches out for a belly rub.", "wags its tail.", "lies down."))
			StartResting()
		else if(prob(1))
			custom_emote(1, pick("sits down.", "crouches on its hind legs.", "looks alert."))
			icon_state = "[icon_living]_sit"
			collar_type = "[initial(collar_type)]_sit"
			resting = TRUE
			update_canmove()
		else if(prob(1))
			if(resting)
				custom_emote(1, pick("gets up and meows.", "walks around.", "stops resting."))
				StopResting()
			else
				custom_emote(1, pick("grooms its fur.", "twitches its whiskers.", "shakes out its coat."))

	//MICE!
	if(eats_mice && isturf(loc) && !incapacitated())
		for(var/mob/living/simple_animal/mouse/M in view(1, src))
			if(!M.stat && Adjacent(M))
				custom_emote(1, "splats \the [M]!")
				M.death()
				M.splat()
				movement_target = null
				stop_automated_movement = 0
				break
		for(var/obj/item/toy/cattoy/T in view(1, src))
			if(T.cooldown < (world.time - 400))
				custom_emote(1, "bats \the [T] around with its paw!")
				T.cooldown = world.time

/mob/living/simple_animal/pet/cat/handle_automated_movement()
	. = ..()
	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			walk_to(src,0)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/mob/living/simple_animal/mouse/snack in oview(src,3))
					if(isturf(snack.loc) && !snack.stat)
						movement_target = snack
						break
			if(movement_target)
				stop_automated_movement = 1
				walk_to(src,movement_target,0,3)

/mob/living/simple_animal/pet/cat/emote(act, m_type = 1, message = null, force)
	if(stat != CONSCIOUS)
		return

	var/on_CD = 0
	act = lowertext(act)
	switch(act)
		if("meow")
			on_CD = handle_emote_CD()
		if("hiss")
			on_CD = handle_emote_CD()
		if("purr")
			on_CD = handle_emote_CD()
		else
			on_CD = 0

	if(!force && on_CD == 1)
		return

	switch(act)
		if("meow")
			message = "[pick(emote_hear)]!"
			m_type = 2 //audible
			playsound(src, meow_sound, 50, 0.75)
		if("hiss")
			message = "hisses!"
			m_type = 2
		if("purr")
			message = "purrs."
			m_type = 2
		if("help")
			to_chat(src, "scream, meow, hiss, purr")

	..()

/mob/living/simple_animal/pet/cat/Proc
	name = "Proc"
	gender = MALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/pet/cat/kitten
	name = "kitten"
	desc = "D'aaawwww"
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	icon_resting = null
	gender = NEUTER
	density = 0
	pass_flags = PASSMOB
	collar_type = "kitten"

/mob/living/simple_animal/pet/cat/Syndi
	name = "SyndiCat"
	desc = "It's a SyndiCat droid."
	icon_state = "Syndicat"
	icon_living = "Syndicat"
	icon_dead = "Syndicat_dead"
	icon_resting = "Syndicat_rest"
	meow_sound = null	//Need robo-meow.
	gender = FEMALE
	mutations = list(BREATHLESS)
	faction = list("syndicate")
	gold_core_spawnable = NO_SPAWN
	eats_mice = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	melee_damage_lower = 5
	melee_damage_upper = 15

/mob/living/simple_animal/pet/cat/Syndi/Initialize(mapload)
	. = ..()
	add_language("Galactic Common")

/mob/living/simple_animal/pet/cat/cak
	name = "Keeki"
	desc = "It's a cat made out of cake."
	icon_state = "cak"
	icon_living = "cak"
	icon_resting = "cak_rest"
	icon_dead = "cak_dead"
	health = 50
	maxHealth = 50
	harm_intent_damage = 10
	butcher_results = list(
		/obj/item/organ/internal/brain = 1,
		/obj/item/organ/internal/heart = 1,
		/obj/item/reagent_containers/food/snacks/birthdaycakeslice = 3,
		/obj/item/reagent_containers/food/snacks/meat/slab = 2
	)
	response_harm = "takes a bite out of"
	attacked_sound = "sound/items/eatfood.ogg"
	deathmessage = "loses its false life and collapses!"
	death_sound = "bodyfall"
	holder_type = /obj/item/holder/cak

/mob/living/simple_animal/pet/cat/cak/Life()
	..()
	if(stat)
		return
	if(health < maxHealth)
		adjustBruteLoss(-4)
	for(var/obj/item/reagent_containers/food/snacks/donut/D in range(1, src))
		if(D.icon_state != "donut2")
			D.name = "frosted donut"
			D.icon_state = "donut2"
			D.reagents.add_reagent("sprinkles", 2)
			D.filling_color = "#FF69B4"

/mob/living/simple_animal/pet/cat/cak/attack_hand(mob/living/L)
	..()
	if(L.a_intent == INTENT_HARM && L.reagents && !stat)
		L.reagents.add_reagent("nutriment", 0.4)
		L.reagents.add_reagent("vitamin", 0.4)

/mob/living/simple_animal/pet/cat/cak/CheckParts(list/parts)
	..()
	var/obj/item/organ/internal/brain/B = locate(/obj/item/organ/internal/brain) in contents
	if(!B || !B.brainmob || !B.brainmob.mind)
		return
	B.brainmob.mind.transfer_to(src)
	to_chat(src, "<span class='big bold'>You are a cak!</span><b> You're a harmless cat/cake hybrid that everyone loves. People can take bites out of you if they're hungry, but you regenerate health \
	so quickly that it generally doesn't matter. You're remarkably resilient to any damage besides this and it's hard for you to really die at all. You should go around and bring happiness and \
	free cake to the station!</b>")
	var/new_name = stripped_input(src, "Enter your name, or press \"Cancel\" to stick with Keeki.", "Name Change")
	if(new_name)
		to_chat(src, "<span class='notice'>Your name is now <b>\"[new_name]\"</b>!</span>")
		name = new_name

/mob/living/simple_animal/pet/cat/white
	name = "white"
	desc = "Белоснежная шерстка. Плохо различается на белой плитке, зато отлично виден в темноте!"
	icon_state = "penny"
	icon_living = "penny"
	icon_dead = "penny_dead"
	icon_resting = "penny_rest"
	gender = FEMALE
	holder_type = /obj/item/holder/cak

/mob/living/simple_animal/pet/cat/white/Penny
	name = "Penny"
	desc = "Любит таскать монетки и мелкие предметы. Успевайте прятать их!"
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/cat/birman
	name = "birman"
	desc = "Священная порода Бирма"
	icon_state = "crusher"
	icon_living = "crusher"
	icon_dead = "crusher_dead"
	icon_resting = "crusher_rest"
	gender = FEMALE
	holder_type = /obj/item/holder/cak

/mob/living/simple_animal/pet/cat/birman/Crusher
	name = "Crusher"
	desc = "Любит крушить всё что не прикручено. Нужно вовремя прибираться."
	unique_pet = TRUE
	gold_core_spawnable = NO_SPAWN

/mob/living/simple_animal/pet/spacecat
	name = "spacecat"
	desc = "Space Kitty!!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	icon_resting = "spacecat_rest"
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40
	holder_type = /obj/item/holder/spacecat
