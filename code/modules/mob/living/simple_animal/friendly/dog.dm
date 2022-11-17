//Dogs.

/mob/living/simple_animal/pet/dog
	name = "dog"
	icon_state = "blackdog"
	icon_living = "blackdog"
	icon_dead = "blackdog_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.", "pants.")
	emote_see = list("shakes its head.", "chases its tail.", "shivers.")
	faction = list("neutral")
	see_in_dark = 5
	speak_chance = 1
	turns_per_move = 10
	gold_core_spawnable = FRIENDLY_SPAWN
	var/bark_sound = list('sound/creatures/dog_bark1.ogg','sound/creatures/dog_bark2.ogg') //Used in emote.
	var/yelp_sound = 'sound/creatures/dog_yelp.ogg' //Used on death.
	var/last_eaten = 0
	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/pet/dog/verb/chasetail()
	set name = "Chase your tail"
	set desc = "d'awwww."
	set category = "Dog"

	visible_message("[src] [pick("dances around", "chases [p_their()] tail")].", "[pick("You dance around", "You chase your tail")].")
	spin(20, 1)

/mob/living/simple_animal/pet/dog/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return
	playsound(src, yelp_sound, 75, TRUE)

/mob/living/simple_animal/pet/dog/emote(act, m_type = 1, message = null, force)
	if(incapacitated())
		return

	var/on_CD = 0
	act = lowertext(act)
	switch(act)
		if("bark")
			on_CD = handle_emote_CD()
		if("yelp")
			on_CD = handle_emote_CD()
		else
			on_CD = 0

	if(!force && on_CD == 1)
		return

	switch(act)
		if("bark")
			message = "[pick(src.speak_emote)]!"
			m_type = 2 //audible
			playsound(src, pick(src.bark_sound), 50, TRUE)
		if("yelp")
			message = "yelps!"
			m_type = 2 //audible
			playsound(src, yelp_sound, 75, TRUE)
		if("growl")
			message = "growls!"
			m_type = 2 //audible
		if("help")
			to_chat(src, "scream, bark, growl")

	..()

/mob/living/simple_animal/pet/dog/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if(INTENT_HELP)
			wuv(1, M)
		if(INTENT_HARM)
			wuv(-1, M)

/mob/living/simple_animal/pet/dog/proc/wuv(change, mob/M)
	if(change)
		if(change > 0)
			if(M && stat != DEAD) // Added check to see if this mob (the corgi) is dead to fix issue 2454
				new /obj/effect/temp_visual/heart(loc)
				custom_emote(1, "yaps happily!")
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				custom_emote(1, "growls!")

//Corgis and pugs are now under one dog subtype
/mob/living/simple_animal/pet/dog/corgi
	name = "\improper corgi"
	real_name = "corgi"
	desc = "It's a corgi."
	icon_state = "corgi"
	icon_living = "corgi"
	icon_dead = "corgi_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/corgi = 3, /obj/item/clothing/head/corgipelt = 1)
	childtype = list(/mob/living/simple_animal/pet/dog/corgi/puppy = 95, /mob/living/simple_animal/pet/dog/corgi/puppy/void = 5)
	animal_species = /mob/living/simple_animal/pet/dog
	collar_type = "corgi"
	var/shaved = FALSE
	var/nofur = FALSE 		//Corgis that have risen past the material plane of existence.

/mob/living/simple_animal/pet/dog/corgi/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/razor))
		if(shaved)
			to_chat(user, "<span class='warning'>You can't shave this corgi, it's already been shaved!</span>")
			return
		if(nofur)
			to_chat(user, "<span class='warning'>You can't shave this corgi, it doesn't have a fur coat!</span>")
			return
		user.visible_message("<span class='notice'>[user] starts to shave [src] using \the [O].", "<span class='notice'>You start to shave [src] using \the [O]...</span>")
		if(do_after(user, 50, target = src))
			user.visible_message("<span class='notice'>[user] shaves [src]'s hair using \the [O].</span>")
			playsound(loc, O.usesound, 20, TRUE)
			shaved = TRUE
			icon_living = "[initial(icon_living)]_shaved"
			icon_dead = "[initial(icon_living)]_shaved_dead"
			if(stat == CONSCIOUS)
				icon_state = icon_living
			else
				icon_state = icon_dead
		return
	..()
	update_fluff()

/mob/living/simple_animal/pet/dog/corgi/place_on_back_fashion(obj/item/item_to_add, mob/user)
	var/is_wear_fashion_back = FALSE
	if(ispath(item_to_add.dog_fashion, /datum/fashion/dog_fashion/back))
		is_wear_fashion_back = TRUE
	return is_wear_fashion_back

//Corgis are supposed to be simpler, so only a select few objects can actually be put
//to be compatible with them. The objects are below.
//Many  hats added, Some will probably be removed, just want to see which ones are popular.
// > some will probably be removed
/mob/living/simple_animal/pet/dog/corgi/place_on_head_fashion(obj/item/item_to_add, mob/user)
	is_wear_fashion_head = FALSE
	if(ispath(item_to_add.dog_fashion, /datum/fashion/dog_fashion/head))
		is_wear_fashion_head = TRUE

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.

	if(is_wear_fashion_head)
		if(health <= 0)
			to_chat(user, "<span class='notice'>There is merely a dull, lifeless look in [real_name]'s eyes as you put the [item_to_add] on [p_them()].</span>")
		else if(user)
			user.visible_message("<span class='notice'>[user] puts [item_to_add] on [real_name]'s head. [src] looks at [user] and barks once.</span>",
				"<span class='notice'>You put [item_to_add] on [real_name]'s head. [src] gives you a peculiar look, then wags [p_their()] tail once and barks.</span>",
				"<span class='italics'>You hear a friendly-sounding bark.</span>")
		item_to_add.forceMove(src)
		inventory_head = item_to_add
		update_fluff()
		regenerate_icons()
	else
		. = ..()

	return is_wear_fashion_head

/mob/living/simple_animal/pet/dog/corgi/update_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	desc = initial(desc)
	set_light(0)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	mutations.Remove(BREATHLESS)
	minbodytemp = initial(minbodytemp)

	if(inventory_head && inventory_head.dog_fashion)
		var/datum/fashion/DF = new inventory_head.dog_fashion(src)
		DF.apply(src)

	if(inventory_back && inventory_back.dog_fashion)
		var/datum/fashion/DF = new inventory_back.dog_fashion(src)
		DF.apply(src)
	//message_admins("Тест 0")

/mob/living/simple_animal/pet/dog/corgi/regenerate_head_icon()
	if (!is_wear_fashion_head)
		return ..()

	var/image/head_icon	//Возникло исключение: Cannot create objects of type null.
	var/datum/fashion/DF = new inventory_head.dog_fashion(src)	//!!!!!!!Не видит (null) когда надеваем что-то вне

	if(!DF.obj_icon_state)
		DF.obj_icon_state = inventory_head.icon_state
	if(!DF.obj_alpha)
		DF.obj_alpha = inventory_head.alpha
	if(!DF.obj_color)
		DF.obj_color = inventory_head.color

	if(health <= 0)
		head_icon = DF.get_overlay(dir = EAST)
		head_icon.pixel_y = -8
		head_icon.transform = turn(head_icon.transform, 180)
	else
		head_icon = DF.get_overlay()

	add_overlay(head_icon)


/mob/living/simple_animal/pet/dog/corgi/regenerate_back_icon()
	if (!is_wear_fashion_back)
		return ..()

	var/image/back_icon
	var/datum/fashion/DF = new inventory_back.dog_fashion(src)

	if(!DF.obj_icon_state)
		DF.obj_icon_state = inventory_back.icon_state
	if(!DF.obj_alpha)
		DF.obj_alpha = inventory_back.alpha
	if(!DF.obj_color)
		DF.obj_color = inventory_back.color

	if(health <= 0)
		back_icon = DF.get_overlay(dir = EAST)
		back_icon.pixel_y = -11
		back_icon.transform = turn(back_icon.transform, 180)
	else
		back_icon = DF.get_overlay()
	add_overlay(back_icon)

//Обновление уникальных анимированных фешинов
/mob/living/simple_animal/pet/dog/corgi/Life(seconds, times_fired)
	. = ..()
	regenerate_icons()

//IAN! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/dog/corgi/Ian
	name = "Ian"
	real_name = "Ian"	//Intended to hold the name without altering it.
	gender = MALE
	desc = "It's the HoP's beloved corgi."
	var/turns_since_scan = 0
	var/obj/movement_target
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	var/age = 0
	var/record_age = 1
	var/saved_head //path

/mob/living/simple_animal/pet/dog/corgi/Ian/Initialize(mapload)
	. = ..()
	SSpersistent_data.register(src)

/mob/living/simple_animal/pet/dog/corgi/Ian/death()
	write_memory(TRUE)
	SSpersistent_data.registered_atoms -= src // We already wrote here, dont overwrite!
	..()

/mob/living/simple_animal/pet/dog/corgi/Ian/persistent_load()
	read_memory()
	if(age == 0)
		var/turf/target = get_turf(loc)
		if(target)
			var/mob/living/simple_animal/pet/dog/corgi/puppy/P = new /mob/living/simple_animal/pet/dog/corgi/puppy(target)
			P.name = "Ian"
			P.real_name = "Ian"
			P.gender = MALE
			P.desc = "It's the HoP's beloved corgi puppy."
			write_memory(FALSE)
			SSpersistent_data.registered_atoms -= src // We already wrote here, dont overwrite!
			qdel(src)
			return
	else if(age == record_age)
		icon_state = "old_corgi"
		icon_living = "old_corgi"
		icon_dead = "old_corgi_dead"
		desc = "At a ripe old age of [record_age], Ian's not as spry as he used to be, but he'll always be the HoP's beloved corgi." //RIP
		turns_per_move = 20

/mob/living/simple_animal/pet/dog/corgi/Ian/persistent_save()
	write_memory(FALSE)

/mob/living/simple_animal/pet/dog/corgi/Ian/proc/read_memory()
	if(fexists("data/npc_saves/Ian.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Ian.sav")
		S["age"] 		>> age
		S["record_age"]	>> record_age
		S["saved_head"] >> saved_head
		fdel("data/npc_saves/Ian.sav")
	else
		var/json_file = file("data/npc_saves/Ian.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(file2text(json_file))
		age = json["age"]
		record_age = json["record_age"]
		saved_head = json["saved_head"]
	if(isnull(age))
		age = 0
	if(isnull(record_age))
		record_age = 1
	if(saved_head)
		place_on_head(new saved_head)
	log_debug("Persistent data for [src] loaded (age: [age] | record_age: [record_age] | saved_head: [saved_head ? saved_head : "None"])")

/mob/living/simple_animal/pet/dog/corgi/Ian/proc/write_memory(dead)
	var/json_file = file("data/npc_saves/Ian.json")
	var/list/file_data = list()
	if(!dead)
		file_data["age"] = age + 1
		if((age + 1) > record_age)
			file_data["record_age"] = record_age + 1
		else
			file_data["record_age"] = record_age
		if(inventory_head)
			file_data["saved_head"] = inventory_head.type
		else
			file_data["saved_head"] = null
	else
		file_data["age"] = 0
		file_data["record_age"] = record_age
		file_data["saved_head"] = null
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))
	log_debug("Persistent data for [src] saved (age: [age] | record_age: [record_age] | saved_head: [saved_head ? saved_head : "None"])")

/mob/living/simple_animal/pet/dog/corgi/Ian/handle_automated_movement()
	. = ..()
	//Feeding, chasing food, FOOOOODDDD
	if(!resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if( !movement_target || !(movement_target.loc in oview(src, 3)) )
				movement_target = null
				stop_automated_movement = 0
				for(var/obj/item/reagent_containers/food/snacks/S in oview(src,3))
					if(isturf(S.loc) || ishuman(S.loc))
						movement_target = S
						break
			if(movement_target)
				spawn(0)
					stop_automated_movement = 1
					step_to(src,movement_target,1)
					sleep(3)
					step_to(src,movement_target,1)
					sleep(3)
					step_to(src,movement_target,1)

					if(movement_target)		//Not redundant due to sleeps, Item can be gone in 6 decisecomds
						if(movement_target.loc.x < src.x)
							dir = WEST
						else if(movement_target.loc.x > src.x)
							dir = EAST
						else if(movement_target.loc.y < src.y)
							dir = SOUTH
						else if(movement_target.loc.y > src.y)
							dir = NORTH
						else
							dir = SOUTH

						if(!Adjacent(movement_target)) //can't reach food through windows.
							return

						if(isturf(movement_target.loc) )
							movement_target.attack_animal(src)
						else if(ishuman(movement_target.loc) )
							if(prob(20))
								custom_emote(1, "stares at [movement_target.loc]'s [movement_target] with a sad puppy-face")

		if(prob(1))
			custom_emote(1, pick("dances around.","chases its tail!"))
			spin(20, 1)

/obj/item/reagent_containers/food/snacks/meat/corgi
	name = "Corgi meat"
	desc = "Tastes like... well you know..."

/mob/living/simple_animal/pet/dog/corgi/Ian/narsie_act()
	playsound(src, 'sound/misc/demon_dies.ogg', 75, TRUE)
	var/mob/living/simple_animal/pet/dog/corgi/narsie/N = new(loc)
	N.setDir(dir)
	gib()

/mob/living/simple_animal/pet/dog/corgi/Ian/ratvar_act()
	playsound(src, 'sound/misc/demon_dies.ogg', 75, TRUE)
	var/mob/living/simple_animal/pet/dog/corgi/ratvar/N = new(loc)
	N.setDir(dir)
	gib()

/mob/living/simple_animal/pet/dog/corgi/narsie
	name = "Nars-Ian"
	desc = "Ia! Ia!"
	icon_state = "narsian"
	icon_living = "narsian"
	icon_dead = "narsian_dead"
	faction = list("neutral", "cult")
	gold_core_spawnable = NO_SPAWN
	nofur = TRUE
	unique_pet = TRUE

/mob/living/simple_animal/pet/dog/corgi/narsie/Life()
	..()
	for(var/mob/living/simple_animal/pet/P in range(1, src))
		if(P != src && !istype(P, /mob/living/simple_animal/pet/dog/corgi/narsie))
			visible_message("<span class='warning'>[src] devours [P]!</span>", \
			"<span class='cult big bold'>DELICIOUS SOULS</span>")
			playsound(src, 'sound/misc/demon_attack1.ogg', 75, TRUE)
			narsie_act()
			if(P.mind)
				if(P.mind.hasSoul)
					P.mind.hasSoul = FALSE //Nars-Ian ate your soul; you don't have one anymore
				else
					visible_message("<span class='cult big bold'>... Aw, someone beat me to this one.</span>")
			P.gib()

/mob/living/simple_animal/pet/dog/corgi/narsie/update_fluff()
	..()
	speak = list("Tari'karat-pasnar!", "IA! IA!", "BRRUUURGHGHRHR")
	speak_emote = list("growls", "barks ominously")
	emote_hear = list("barks echoingly!", "woofs hauntingly!", "yaps in an eldritch manner.", "mutters something unspeakable.")
	emote_see = list("communes with the unnameable.", "ponders devouring some souls.", "shakes.")

/mob/living/simple_animal/pet/dog/corgi/narsie/narsie_act()
	adjustBruteLoss(-maxHealth)

/mob/living/simple_animal/pet/dog/corgi/ratvar
	name = "Cli-k"
	desc = "It's a coolish Ian that clicks!"
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "clik"
	icon_living = "clik"
	icon_dead = "clik_dead"
	faction = list("neutral", "clockwork_cult")
	gold_core_spawnable = NO_SPAWN
	nofur = TRUE
	unique_pet = TRUE

/mob/living/simple_animal/pet/dog/corgi/ratvar/update_corgi_fluff()
	..()
	speak = list("V'z fuvavat jneevbe!", "CLICK!", "KL-KL-KLIK")
	speak_emote = list("growls", "barks ominously")
	emote_hear = list("barks echoingly!", "woofs hauntingly!", "yaps in an judicial manner.", "mutters something unspeakable.")
	emote_see = list("communes with the unnameable.", "seeks the light in souls.", "shakes.")

/mob/living/simple_animal/pet/dog/corgi/ratvar/ratvar_act()
	adjustBruteLoss(-maxHealth)

/mob/living/simple_animal/pet/dog/corgi/puppy
	name = "\improper corgi puppy"
	real_name = "corgi"
	desc = "It's a corgi puppy!"
	icon_state = "puppy"
	icon_living = "puppy"
	icon_dead = "puppy_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	collar_type = "puppy"

/mob/living/simple_animal/pet/dog/corgi/puppy/void		//Tribute to the corgis born in nullspace
	name = "\improper void puppy"
	real_name = "voidy"
	desc = "A corgi puppy that has been infused with deep space energy. It's staring back..."
	icon_state = "void_puppy"
	icon_living = "void_puppy"
	icon_dead = "void_puppy_dead"
	nofur = TRUE
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40

/mob/living/simple_animal/pet/dog/corgi/puppy/void/Process_Spacemove(movement_dir = 0)
	return 1	//Void puppies can navigate space.

//LISA! SQUEEEEEEEEE~
/mob/living/simple_animal/pet/dog/corgi/Lisa
	name = "Lisa"
	real_name = "Lisa"
	gender = FEMALE
	desc = "It's a corgi with a cute pink bow."
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	icon_state = "lisa"
	icon_living = "lisa"
	icon_dead = "lisa_dead"
	response_help  = "pets"
	response_disarm = "bops"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	var/puppies = 0

/mob/living/simple_animal/pet/dog/corgi/Lisa/Life()
	..()
	make_babies()

/mob/living/simple_animal/pet/dog/corgi/Lisa/handle_automated_movement()
	. = ..()
	if(!resting && !buckled)
		if(prob(1))
			custom_emote(1, pick("dances around.","chases her tail."))
			spin(20, 1)

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi
	name = "Exotic Corgi"
	desc = "As cute as it is colorful!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "corgigrey"
	icon_living = "corgigrey"
	icon_dead = "corgigrey_dead"
	animal_species = /mob/living/simple_animal/pet/dog/corgi/exoticcorgi
	nofur = TRUE

/mob/living/simple_animal/pet/dog/corgi/exoticcorgi/Initialize(mapload)
	. = ..()
	var/newcolor = rgb(rand(0, 255), rand(0, 255), rand(0, 255))
	add_atom_colour(newcolor, FIXED_COLOUR_PRIORITY)

/mob/living/simple_animal/pet/dog/corgi/borgi
	name = "E-N"
	real_name = "E-N"	//Intended to hold the name without altering it.
	desc = "It's a borgi."
	icon_state = "borgi"
	icon_living = "borgi"
	bark_sound = null	//No robo-bjork...
	yelp_sound = null	//Or robo-Yelp.
	var/emagged = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	del_on_death = 1
	deathmessage = "blows apart!"
	animal_species = /mob/living/simple_animal/pet/dog/corgi/borgi
	nofur = TRUE

/mob/living/simple_animal/pet/dog/corgi/borgi/emag_act(user as mob)
	if(!emagged)
		emagged = 1
		visible_message("<span class='warning'>[user] swipes a card through [src].</span>", "<span class='notice'>You overload [src]s internal reactor.</span>")
		addtimer(CALLBACK(src, .proc/explode), 1000)

/mob/living/simple_animal/pet/dog/corgi/borgi/proc/explode()
	visible_message("<span class='warning'>[src] makes an odd whining noise.</span>")
	explosion(get_turf(src), 0, 1, 4, 7, cause = src)
	death()

/mob/living/simple_animal/pet/dog/corgi/borgi/proc/shootAt(var/atom/movable/target)
	var/turf/T = get_turf(src)
	var/turf/U = get_turf(target)
	if(!T || !U)
		return
	var/obj/item/projectile/beam/A = new /obj/item/projectile/beam(loc)
	A.icon = 'icons/effects/genetics.dmi'
	A.icon_state = "eyelasers"
	playsound(src.loc, 'sound/weapons/taser2.ogg', 75, 1)
	A.current = T
	A.yo = U.y - T.y
	A.xo = U.x - T.x
	A.fire()

/mob/living/simple_animal/pet/dog/corgi/borgi/Life(seconds, times_fired)
	..()
	//spark for no reason
	if(prob(5))
		do_sparks(3, 1, src)

/mob/living/simple_animal/pet/dog/corgi/borgi/handle_automated_action()
	if(emagged && prob(25))
		var/mob/living/carbon/target = locate() in view(10, src)
		if(target)
			shootAt(target)

/mob/living/simple_animal/pet/dog/corgi/borgi/death(gibbed)
	// Only execute the below if we successfully died
	. = ..(gibbed)
	if(!.)
		return FALSE
	do_sparks(3, 1, src)

///Pugs

/mob/living/simple_animal/pet/dog/pug
	name = "\improper pug"
	real_name = "pug"
	desc = "It's a pug."
	icon = 'icons/mob/pets.dmi'
	icon_state = "pug"
	icon_living = "pug"
	icon_dead = "pug_dead"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/pug = 3)
	collar_type = "pug"

/mob/living/simple_animal/pet/dog/pug/handle_automated_movement()
	. = ..()
	if(!resting && !buckled)
		if(prob(1))
			custom_emote(1, pick("chases its tail."))
			spawn(0)
				for(var/i in list(1, 2, 4, 8, 4, 2, 1, 2, 4, 8, 4, 2, 1, 2, 4, 8, 4, 2))
					dir = i
					sleep(1)
