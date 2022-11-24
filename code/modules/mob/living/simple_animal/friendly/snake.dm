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
	health = 20
	maxHealth = 20
	attacktext = "кусает"
	melee_damage_lower = 5
	melee_damage_upper = 6
	response_help  = "pets"
	response_disarm = "shoos"
	response_harm   = "steps on"
	faction = list("hostile")
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE


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
	emote_hear = list("Зевает", "Шипит", "Дурачится", "Толкается")
	emote_see = list("Высовывает язык", "Кружится", "Трясёт хвостом")
	health = 20
	maxHealth = 20
	attacktext = "кусает"
	melee_damage_lower = 5
	melee_damage_upper = 6
	response_help  = "pets"
	var/rest = FALSE
	response_disarm = "shoos"
	response_harm   = "steps on"
	faction = list("neutral", "syndicate")
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	can_hide = 1

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/verb/chasetail()
	set name = "Chase your tail"
	set desc = "d'awwww."
	set category = "Animal"
	visible_message("[src] [pick("dances around", "chases [p_their()] tail")].", "[pick("You dance around", "You chase your tail")].")
	spin(20, 1)

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/emote(act, m_type = 1, message = null, force)
	if(incapacitated())
		return

	act = lowertext(act)
	if(!force && act == "hiss" && handle_emote_CD())
		return

	switch(act)
		if("hiss")
			message = "<B>[src]</B> [pick(src.speak_emote)]!"
	..()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if(INTENT_HELP)
			shh(1, M)
		if(INTENT_HARM)
			shh(-1, M)

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/StartResting(updating = 1)
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_resting
		rest = TRUE
		if(collar_type)
			collar_type = "[initial(collar_type)]_rest"
			regenerate_icons()
		if(inventory_head)
			regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/StopResting(updating = 1)
	..()
	if(icon_resting && stat != DEAD)
		icon_state = icon_living
		rest = FALSE
		if(collar_type)
			collar_type = "[initial(collar_type)]"
			regenerate_icons()
		if(inventory_head)
			regenerate_icons()

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/proc/shh(change, mob/M)
	if(!M || stat)
		return
	if(change > 0)
		new /obj/effect/temp_visual/heart(loc)
		custom_emote(1, "hisses happily!")
	else
		custom_emote(1, "hisses angrily!")

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/update_fluff()
	// First, change back to defaults
	name = real_name
	desc = initial(desc)
	// BYOND/DM doesn't support the use of initial on lists.
	speak = list("Шшш", "Тсс!", "Тц тц тц!", "ШШшшШШшшШ!")
	speak_emote = list("hisses")
	emote_hear = list("Зевает", "Шипит", "Дурачится", "Толкается")
	emote_see = list("Высовывает язык", "Кружится", "Трясёт хвостом")

	if(inventory_head?.snake_fashion)
		var/datum/fashion/SF = new inventory_head.snake_fashion(src)
		SF.apply(src)


/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/place_on_head_fashion(obj/item/item_to_add, mob/user)
	is_wear_fashion_head = FALSE
	if(ispath(item_to_add.snake_fashion, /datum/fashion/snake_fashion/head))
		is_wear_fashion_head = TRUE

	if(is_wear_fashion_head)
		if(health <= 0)
			to_chat(user, "<span class='notice'>Безжизненный взгляд в глазах [real_name] никак не меняется, когда вы надеваете [item_to_add] на неё.</span>")
		else if(user)
			user.visible_message("<span class='notice'>[user] надевает [item_to_add] на центральную голову [real_name]. [src] смотрит на [user] и довольно шипит.</span>",
				"<span class='notice'>Вы надеваете [item_to_add] на голову [real_name]. [src] озадачено смотрит на вас, пока другие головы смотрят на центральную с завистью.</span>",
				"<span class='italics'>Вы слышите дружелюбное шипение.</span>")

			if(item_to_add.snake_fashion.is_animated_fashion)
				animated_fashion = TRUE

		item_to_add.forceMove(src)
		inventory_head = item_to_add
		update_fluff()
		regenerate_icons()
	else
		. = ..()

	return is_wear_fashion_head

/mob/living/simple_animal/hostile/retaliate/poison/snake/rouge/regenerate_head_icon()
	if (!is_wear_fashion_head)
		return ..()

	var/image/head_icon
	var/datum/fashion/SF = new inventory_head.snake_fashion(src)

	if(!SF.obj_icon_state)
		SF.obj_icon_state = inventory_head.icon_state
		if(src.rest || stat == DEAD)
			SF.obj_icon_state += "_rest"
	if(!SF.obj_alpha)
		SF.obj_alpha = inventory_head.alpha
	if(!SF.obj_color)
		SF.obj_color = inventory_head.color

	if(stat || src.rest) //без сознания или отдыхает
		head_icon = SF.get_overlay()
		if(stat)
			head_icon.pixel_y = -2
			head_icon.pixel_x = -2
	else
		head_icon = SF.get_overlay()

	add_overlay(head_icon)
