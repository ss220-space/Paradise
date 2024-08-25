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
	tts_seed = "Stetmann"
	faction = list("neutral")
	maxHealth = 50
	health = 50
	melee_damage_type = STAMINA
	melee_damage_lower = 6
	melee_damage_upper = 10
	attacktext = "кусает"
	nightvision = 5
	speak_chance = 1
	turns_per_move = 10
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	var/bark_sound = list('sound/creatures/dog_bark1.ogg','sound/creatures/dog_bark2.ogg') //Used in emote.
	var/bark_emote = list("ла%(ет,ют)%.", "гавка%(ет,ют)%.")	// used in emote.
	var/growl_sound = list('sound/creatures/dog_grawl1.ogg','sound/creatures/dog_grawl2.ogg') //Used in emote.
	var/yelp_sound = 'sound/creatures/dog_yelp.ogg' //Used on death.
	var/last_eaten = 0
	var/had_fashion
	///Currently worn item on the head slot
	var/obj/item/inventory_head = null
	///Currently worn item on the back slot
	var/obj/item/inventory_back = null
	///Currently wotn item oh the mask slot
	var/obj/item/inventory_mask = null
	///Item slots that are available for this dog to equip stuff into
	var/list/strippable_inventory_slots = list()
	footstep_type = FOOTSTEP_MOB_CLAW
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/dog = 4)
	collar_type = "dog"

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
				custom_emote(EMOTE_VISIBLE, "радостно тявка%(ет,ют)%!")
		else
			if(M && stat != DEAD) // Same check here, even though emote checks it as well (poor form to check it only in the help case)
				custom_emote(EMOTE_VISIBLE, "рыч%(ит,ат)%!")

/mob/living/simple_animal/pet/dog/proc/place_on_head(obj/item/item_to_add, mob/user)
	return

/mob/living/simple_animal/pet/dog/proc/update_dog_fluff()
	return

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
	tts_seed = "Stetmann"
	holder_type = /obj/item/holder/corgi

/mob/living/simple_animal/pet/dog/corgi/Initialize(mapload)
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/add_strippable_element()
	AddElement(/datum/element/strippable, length(strippable_inventory_slots) ? create_strippable_list(strippable_inventory_slots) : GLOB.strippable_corgi_items)

/mob/living/simple_animal/pet/dog/corgi/Destroy()
	QDEL_NULL(inventory_head)
	QDEL_NULL(inventory_back)
	return ..()

/mob/living/simple_animal/pet/dog/corgi/handle_atom_del(atom/A)
	if(A == inventory_head)
		inventory_head = null
		regenerate_icons()
	if(A == inventory_back)
		inventory_back = null
		regenerate_icons()
	return ..()

/mob/living/simple_animal/pet/dog/corgi/Life(seconds, times_fired)
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/death(gibbed)
	..(gibbed)
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/getarmor(def_zone, attack_flag)
	var/armorval = 0

	if(def_zone)
		if(def_zone == BODY_ZONE_HEAD)
			if(inventory_head)
				armorval = inventory_head.armor.getRating(attack_flag)
		else
			if(inventory_back)
				armorval = inventory_back.armor.getRating(attack_flag)
		return armorval
	else
		if(inventory_head)
			armorval += inventory_head.armor.getRating(attack_flag)
		if(inventory_back)
			armorval += inventory_back.armor.getRating(attack_flag)
	return armorval * 0.5


/mob/living/simple_animal/pet/dog/corgi/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/razor))
		add_fingerprint(user)
		if(shaved)
			to_chat(user, span_warning("You cannot shave this corgi, it has been already shaved!"))
			return ATTACK_CHAIN_PROCEED
		if(nofur)
			to_chat(user, span_warning("You cannot shave this corgi, it doesn't have any fur!"))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] starts to shave [src], using [I]."),
			span_notice("You start to shave [src]..."),
		)
		I.play_tool_sound(src, 30)
		if(!do_after(user, 5 SECONDS, src, category = DA_CAT_TOOL) || shaved || nofur)
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] has shaved [src]'s fur using [I]."),
			span_notice("You have shaved [src]'s fur."),
		)
		I.play_tool_sound(src, 30)
		shaved = TRUE
		icon_living = "[initial(icon_living)]_shaved"
		icon_dead = "[initial(icon_living)]_shaved_dead"
		update_icons()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


//Corgis are supposed to be simpler, so only a select few objects can actually be put
//to be compatible with them. The objects are below.
//Many  hats added, Some will probably be removed, just want to see which ones are popular.
// > some will probably be removed

/mob/living/simple_animal/pet/dog/corgi/place_on_head(obj/item/item_to_add, mob/user)

	if(istype(item_to_add, /obj/item/grenade/plastic/c4)) // last thing he ever wears, I guess
		item_to_add.afterattack(src, user, TRUE)
		return

	if(inventory_head)
		if(user)
			to_chat(user, "<span class='warning'>You can't put more than one hat on [src]!</span>")
		return
	if(!item_to_add)
		user.visible_message("<span class='notice'>[user] pets [src].</span>", "<span class='notice'>You rest your hand on [src]'s head for a moment.</span>")
		if(flags & HOLOGRAM)
			return
		return

	if(user && !user.drop_item_ground(item_to_add))
		to_chat(user, "<span class='warning'>\The [item_to_add] is stuck to your hand, you cannot put it on [src]'s head!</span>")
		return 0

	var/valid = FALSE
	if(ispath(item_to_add.dog_fashion, /datum/dog_fashion/head))
		valid = TRUE

	//Various hats and items (worn on his head) change Ian's behaviour. His attributes are reset when a hat is removed.

	if(valid)
		if(health <= 0)
			to_chat(user, "<span class='notice'>There is merely a dull, lifeless look in [real_name]'s eyes as you put the [item_to_add] on [p_them()].</span>")
		else if(user)
			user.visible_message("<span class='notice'>[user] puts [item_to_add] on [real_name]'s head. [src] looks at [user] and barks once.</span>",
				"<span class='notice'>You put [item_to_add] on [real_name]'s head. [src] gives you a peculiar look, then wags [p_their()] tail once and barks.</span>",
				"<span class='italics'>You hear a friendly-sounding bark.</span>")
		item_to_add.forceMove(src)
		inventory_head = item_to_add
		update_dog_fluff()
		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>You set [item_to_add] on [src]'s head, but it falls off!</span>")
		item_to_add.forceMove(drop_location())
		if(prob(25))
			step_rand(item_to_add)
		for(var/i in list(1,2,4,8,4,8,4,dir))
			setDir(i)
			sleep(1)

	return valid

/mob/living/simple_animal/pet/dog/corgi/update_dog_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak = list("YAP", "Woof!", "Bark!", "AUUUUUU")
	speak_emote = list("barks", "woofs")
	emote_hear = list("barks!", "woofs!", "yaps.","pants.")
	emote_see = list("shakes its head.", "chases its tail.","shivers.")
	desc = initial(desc)
	set_light_on(FALSE)
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	REMOVE_TRAIT(src, TRAIT_NO_BREATH, CORGI_HARDSUIT_TRAIT)
	minbodytemp = initial(minbodytemp)

	if(inventory_head && inventory_head.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)
		DF.apply(src)

	if(inventory_back && inventory_back.dog_fashion)
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)
		DF.apply(src)

/mob/living/simple_animal/pet/dog/corgi/regenerate_icons()
	..()
	if(inventory_head)
		var/image/head_icon
		var/datum/dog_fashion/DF = new inventory_head.dog_fashion(src)

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

	if(inventory_back)
		var/image/back_icon
		var/datum/dog_fashion/DF = new inventory_back.dog_fashion(src)

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

/mob/living/simple_animal/pet/dog/corgi/Ian/death(gibbed)
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
		holder_type = /obj/item/holder/old_corgi

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
								custom_emote(EMOTE_VISIBLE, "stares at [movement_target.loc]'s [movement_target] with a sad puppy-face")

		if(prob(1))
			custom_emote(EMOTE_VISIBLE, pick("танцу%(ет,ют)% на месте.", "гоня%(ет,ют)%ся за своим хвостом."))
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
	bark_emote = list("рыч%(ит,ат)%.", "зловеще ла%(ет,ют)%.")
	gold_core_spawnable = NO_SPAWN
	nofur = TRUE
	unique_pet = TRUE
	tts_seed = "Mannoroth"
	holder_type = /obj/item/holder/narsian
	maxHealth = 300
	health = 300
	melee_damage_type = STAMINA	//Пади ниц!
	melee_damage_lower = 50
	melee_damage_upper = 100

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

/mob/living/simple_animal/pet/dog/corgi/narsie/update_dog_fluff()
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
	maxHealth = 100
	health = 100

/mob/living/simple_animal/pet/dog/corgi/ratvar/update_dog_fluff()
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
	tts_seed = "Jaina"
	maxHealth = 20
	health = 20
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/corgi = 1)
	strippable_inventory_slots = list(/datum/strippable_item/pet_collar) // Puppies do not have a head or back equipment slot.

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
	tts_seed = "Kael"
	holder_type = /obj/item/holder/void_puppy
	maxHealth = 60
	health = 60

/mob/living/simple_animal/pet/dog/corgi/puppy/void/Process_Spacemove(movement_dir = NONE, continuous_move = FALSE)
	return TRUE	//Void puppies can navigate space.

/mob/living/simple_animal/pet/dog/corgi/puppy/slime
	name = "\improper slime puppy"
	real_name = "slimy"
	desc = "Крайне склизкий. Но прикольный!"
	icon_state = "slime_puppy"
	icon_living = "slime_puppy"
	icon_dead = "slime_puppy_dead"
	nofur = TRUE
	holder_type = /obj/item/holder/slime_puppy
	minbodytemp = 250 //Weak to cold
	maxbodytemp = INFINITY

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
	tts_seed = "Luna"
	holder_type = /obj/item/holder/lisa

/mob/living/simple_animal/pet/dog/corgi/Lisa/Life()
	..()
	make_babies()

/mob/living/simple_animal/pet/dog/corgi/Lisa/handle_automated_movement()
	. = ..()
	if(!resting && !buckled)
		if(prob(1))
			custom_emote(EMOTE_VISIBLE, pick("танцу%(ет,ют)% на месте.", "гоня%(ет,ют)%ся за своим хвостом."))
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
	tts_seed = "Glados"
	var/emagged = 0
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	loot = list(/obj/effect/decal/cleanable/blood/gibs/robot)
	del_on_death = 1
	deathmessage = "blows apart!"
	animal_species = /mob/living/simple_animal/pet/dog/corgi/borgi
	nofur = TRUE
	holder_type = /obj/item/holder/borgi

/mob/living/simple_animal/pet/dog/corgi/borgi/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		visible_message("<span class='warning'>[user] swipes a card through [src].</span>", "<span class='notice'>You overload [src]s internal reactor.</span>")
		addtimer(CALLBACK(src, PROC_REF(explode)), 1000)

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
	A.firer = src
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


/mob/living/simple_animal/pet/dog/corgi/borgi/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/stack/nanopaste))
		add_fingerprint(user)
		var/obj/item/stack/nanopaste/nanopaste = I
		if(!LAZYLEN(diseases))
			to_chat(user, span_warning("[src] has nothing to fix."))
			return ATTACK_CHAIN_PROCEED
		if(!nanopaste.use(1))
			to_chat(user, span_warning("You need at least one unit of [nanopaste] to proceed."))
			return ATTACK_CHAIN_PROCEED
		CureAllDiseases()
		visible_message(span_notice("[src] looks happy!"))
		chasetail()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


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
	tts_seed = "Kleiner"
	holder_type = /obj/item/holder/pug
	maxHealth = 30
	health = 30

/mob/living/simple_animal/pet/dog/pug/handle_automated_movement()
	. = ..()
	if(!resting && !buckled)
		if(prob(1))
			custom_emote(EMOTE_VISIBLE, pick("гоня%(ет,ют)%ся за своим хвостом."))
			spawn(0)
				for(var/i in list(1, 2, 4, 8, 4, 2, 1, 2, 4, 8, 4, 2, 1, 2, 4, 8, 4, 2))
					dir = i
					sleep(1)

/mob/living/simple_animal/pet/dog/bullterrier
	name = "\improper bullterrier"
	real_name = "bullterrier"
	desc = "Кого-то его мордочка напоминает..."
	icon = 'icons/mob/pets.dmi'
	icon_state = "bullterrier"
	icon_living = "bullterrier"
	icon_dead = "bullterrier_dead"
	//tts_seed = "Kleiner"
	holder_type = /obj/item/holder/bullterrier

/mob/living/simple_animal/pet/dog/tamaskan
	name = "\improper tamaskan"
	real_name = "tamaskan"
	desc = "Хорошая семейная собака. Уживается с другими собаками и ассистентами."
	icon = 'icons/mob/pets.dmi'
	icon_state = "tamaskan"
	icon_living = "tamaskan"
	icon_dead = "tamaskan_dead"
	//tts_seed = "Kleiner"
	holder_type = /obj/item/holder/bullterrier

/mob/living/simple_animal/pet/dog/german
	name = "\improper german"
	real_name = "german"
	desc = "Немецкая овчарка с помесью двортерьера. Судя по крупу - явно не породистый."
	icon = 'icons/mob/pets.dmi'
	icon_state = "german"
	icon_living = "german"
	icon_dead = "german_dead"
	//tts_seed = "Kleiner"

/mob/living/simple_animal/pet/dog/brittany
	name = "\improper brittany"
	real_name = "brittany"
	desc = "Старая порода, которую любят аристократы."
	icon = 'icons/mob/pets.dmi'
	icon_state = "brittany"
	icon_living = "brittany"
	icon_dead = "brittany_dead"
