/mob/living/simple_animal/hostile/retaliate/poison
	var/poison_per_bite = 0
	var/poison_type = "toxin"

/mob/living/simple_animal/hostile/retaliate/poison/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(L.reagents && !poison_per_bite == 0)
			L.reagents.add_reagent(poison_type, poison_per_bite)
		return .

/mob/living/simple_animal/hostile/retaliate/poison/snake
	name = "snake"
	desc = "A slithery snake. These legless reptiles are the bane of mice and adventurers alike."
	icon_state = "snake"
	icon_living = "snake"
	icon_dead = "snake_dead"
	speak_emote = list("hisses")
	tts_seed = "Ladyvashj"
	health = 20
	maxHealth = 20
	attacktext = "кусает"
	attack_sound = 'sound/weapons/bite.ogg'
	death_sound = 'sound/creatures/snake_death.ogg'
	melee_damage_lower = 5
	melee_damage_upper = 6
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "steps on"
	faction = list("hostile")
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	holder_type = /obj/item/holder/snake
	can_collar = TRUE


/mob/living/simple_animal/hostile/retaliate/poison/snake/ListTargets(atom/the_target)
	. = oview(vision_range, targets_from) //get list of things in vision range
	var/list/living_mobs = list()
	var/list/mice = list()
	for(var/HM in .)
		//Yum a tasty mouse
		if(istype(HM, /mob/living/simple_animal/mouse))
			mice += HM
		if(isliving(HM))
			living_mobs += HM

	// if no tasty mice to chase, lets chase any living mob enemies in our vision range
	if(length(mice) == 0)
		//Filter living mobs (in range mobs) by those we consider enemies (retaliate behaviour)
		return  living_mobs & enemies
	return mice

/mob/living/simple_animal/hostile/retaliate/poison/snake/AttackingTarget()
	if(istype(target, /mob/living/simple_animal/mouse))
		visible_message("<span class='notice'>[name] consumes [target] in a single gulp!</span>", "<span class='notice'>You consume [target] in a single gulp!</span>")
		QDEL_NULL(target)
		adjustHealth(-2)
	else
		return ..()

//Уникальный питомец Офицера Телекомов. Спрайты от Элл Гуда
/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge
	name = "Руж"
	desc = "Уникальная трёхголовая змея Офицера Телекоммуникаций синдиката. Выращена в лаборатории. У каждой головы свой характер!"
	icon = 'icons/mob/pets.dmi'
	mob_size = MOB_SIZE_SMALL
	blood_volume = BLOOD_VOLUME_NORMAL
	can_collar = TRUE
	gender = FEMALE
	icon_state = "rouge"
	icon_living = "rouge"
	icon_dead = "rouge_dead"
	icon_resting = "rouge_rest"
	speak_chance = 5
	speak = list("Шшш", "Тсс!", "Тц тц тц!", "ШШшшШШшшШ!")
	speak_emote = list("hisses")
	emote_hear = list("зевает", "шипит", "дурачится", "толкается")
	emote_see = list("высовывает язык", "кружится", "трясёт хвостом")
	tts_seed = "Ladyvashj"
	health = 20
	maxHealth = 20
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	attacktext = "кусает"
	melee_damage_lower = 5
	melee_damage_upper = 6
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "steps on"
	var/obj/item/inventory_head
	var/list/strippable_inventory_slots = list()
	faction = list("neutral", "syndicate")
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	can_hide = 1

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/add_strippable_element()
	AddElement(/datum/element/strippable, length(strippable_inventory_slots) ? create_strippable_list(strippable_inventory_slots) : GLOB.strippable_snake_items)

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/verb/chasetail()
	set name = "Chase your tail"
	set desc = "d'awwww."
	set category = "Animal"
	visible_message("[src] [pick("dances around", "chases [p_their()] tail")].", "[pick("You dance around", "You chase your tail")].")
	spin(20, 1)


/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if(INTENT_HELP)
			shh(1, M)
		if(INTENT_HARM)
			shh(-1, M)


/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/post_lying_on_rest()
	. = ..()
	if(inventory_head)
		regenerate_icons()


/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/post_get_up()
	. = ..()
	if(inventory_head)
		regenerate_icons()


/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/proc/shh(change, mob/M)
	if(!M || stat)
		return
	if(change > 0)
		new /obj/effect/temp_visual/heart(loc)
		custom_emote(EMOTE_AUDIBLE, "шип%(ит,ят)% счастливо!")
	else
		custom_emote(EMOTE_AUDIBLE, "шип%(ит,ят)% гневно!")

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/Initialize(mapload)
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/Destroy()
	QDEL_NULL(inventory_head)
	return ..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/handle_atom_del(atom/A)
	if(A == inventory_head)
		inventory_head = null
		regenerate_icons()
	return ..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/Life(seconds, times_fired)
	. = ..()
	regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/death(gibbed)
	..(gibbed)
	regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/getarmor(def_zone, attack_flag)
	var/armorval = inventory_head?.armor.getRating(attack_flag)
	if(!def_zone)
		armorval *= 0.5
	else if(def_zone != BODY_ZONE_HEAD)
		armorval = 0
	return armorval

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/proc/place_on_head(obj/item/item_to_add, mob/user)

	if(istype(item_to_add, /obj/item/grenade/plastic/c4)) // last thing she ever wears, I guess
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
	if(ispath(item_to_add.snake_fashion, /datum/snake_fashion/head))
		valid = TRUE

	if(valid)
		if(health <= 0)
			to_chat(user, "<span class='notice'>Безжизненный взгляд в глазах [real_name] никак не меняется, когда вы надеваете [item_to_add] на неё.</span>")
		else if(user)
			user.visible_message("<span class='notice'>[user] надевает [item_to_add] на центральную голову [real_name]. [src] смотрит на [user] и довольно шипит.</span>",
				"<span class='notice'>Вы надеваете [item_to_add] на голову [real_name]. [src] озадачено смотрит на вас, пока другие головы смотрят на центральную с завистью.</span>",
				"<span class='italics'>Вы слышите дружелюбное шипение.</span>")
		item_to_add.forceMove(src)
		inventory_head = item_to_add
		update_snek_fluff()
		regenerate_icons()
	else
		to_chat(user, "<span class='warning'>Вы надеваете [item_to_add] на голову [src], но она скидывает [item_to_add] с себя!</span>")
		item_to_add.forceMove(drop_location())
		if(prob(25))
			step_rand(item_to_add)
		for(var/i in list(1,2,4,8,4,8,4,dir))
			setDir(i)
			sleep(1)

	return valid

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/proc/update_snek_fluff() //имя, описание, эмоуты
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak = list("Шшш", "Тсс!", "Тц тц тц!", "ШШшшШШшшШ!")
	speak_emote = list("hisses")
	emote_hear = list("зевает", "шипит", "дурачится", "толкается")
	emote_see = list("высовывает язык", "кружится", "трясёт хвостом")

	if(inventory_head?.snake_fashion)
		var/datum/snake_fashion/SF = new inventory_head.snake_fashion(src)
		SF.apply(src)

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/regenerate_icons() // оверлей
	..()
	if(inventory_head)
		var/image/head_icon
		var/datum/snake_fashion/SF = new inventory_head.snake_fashion(src)

		if(!SF.obj_icon_state)
			SF.obj_icon_state = inventory_head.icon_state
			if(resting || stat == DEAD)
				SF.obj_icon_state += "_rest"
		if(!SF.obj_alpha)
			SF.obj_alpha = inventory_head.alpha
		if(!SF.obj_color)
			SF.obj_color = inventory_head.color

		if(stat || resting) //без сознания или отдыхает
			head_icon = SF.get_overlay()
			if(stat)
				head_icon.pixel_y = -2
				head_icon.pixel_x = -2
		else
			head_icon = SF.get_overlay()

		add_overlay(head_icon)
