/mob/living/simple_animal/pet/slugcat
	name = "слизнекот"
	desc = "Удивительное существо, напоминающее кота и слизня в одном обличии. Но это не слизь, а иной вид существа. Гордость ксенобиологии. Крайне ловкое и умное, родом с планеты с опасной средой обитания. Обожает копья, не стоит давать ему его в лапки. На нём отлично смотрятся шляпы."
	icon_state = "slugcat"
	icon_living = "slugcat"
	icon_dead = "slugcat_dead"
	icon_resting = "slugcat_rest"
	speak = list("Furrr.","Uhh.", "Hurrr.")
	gender = MALE
	turns_per_move = 5
	nightvision = 8
	health = 100
	maxHealth = 100
	blood_volume = BLOOD_VOLUME_NORMAL
	melee_damage_type = STAMINA
	melee_damage_lower = 0
	melee_damage_upper = 0
	attacktext = "бьёт"
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE
	ventcrawler_trait = TRAIT_VENTCRAWLER_ALWAYS
	mobility_flags = MOBILITY_FLAGS_REST_CAPABLE_DEFAULT
	can_collar = TRUE
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat = 5)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	gold_core_spawnable = FRIENDLY_SPAWN
	footstep_type = FOOTSTEP_MOB_SLIME
	tts_seed = "Narrator"
	faction = list("slime","neutral")
	//holder_type = /obj/item/holder/cat2 //soon

	//Шляпы для слизнекота!
	var/obj/item/inventory_head
	var/obj/item/inventory_hand
	var/list/strippable_inventory_slots = list()

	var/hat_offset_y = -8
	var/hat_offset_y_rest = -19
	var/hat_icon_file
	var/hat_icon_state
	var/hat_alpha
	var/hat_color

	var/is_pacifist = FALSE
	var/is_reduce_damage = TRUE

/mob/living/simple_animal/pet/slugcat/add_strippable_element()
	AddElement(/datum/element/strippable, length(strippable_inventory_slots) ? create_strippable_list(strippable_inventory_slots) : GLOB.strippable_slugcat_items)

/mob/living/simple_animal/pet/slugcat/monk
	name = "слизнекот-монах"
	desc = "Удивительное существо, напоминающее кота и слизня в одном обличии. Но это не слизь, а иной вид существа. Гордость ксенобиологии. Крайне ловкое и умное, родом с планеты с опасной средой обитания. Не любит охоту и не умеет пользоваться копьями. На нём отлично смотрятся шляпы."
	icon_state = "slugcat_monk"
	icon_living = "slugcat_monk"
	icon_dead = "slugcat_monk_dead"
	icon_resting = "slugcat_monk_rest"
	is_pacifist = TRUE
	gold_core_spawnable = FRIENDLY_SPAWN
	health = 80
	maxHealth = 80

/mob/living/simple_animal/pet/slugcat/hunter
	name = "слизнекот-охотник"
	desc = "Удивительное существо, напоминающее кота и слизня в одном обличии. Но это не слизь, а иной вид существа. Гордость ксенобиологии. Крайне ловкое и умное, родом с планеты с опасной средой обитания. Обожает копья и умело управляется ими, не стоит давать ему его в лапки. На нём отлично смотрятся шляпы."
	icon_state = "slugcat_hunter"
	icon_living = "slugcat_hunter"
	icon_dead = "slugcat_hunter_dead"
	icon_resting = "slugcat_hunter_rest"
	is_pacifist = FALSE
	is_reduce_damage = FALSE
	faction = list("slime","neutral","hostile")
	gold_core_spawnable = HOSTILE_SPAWN
	health = 150
	maxHealth = 150

/mob/living/simple_animal/pet/slugcat/gold	//for admins
	name = "золотой слизнекот"
	desc = "Уникальный золотой слизнекот полученный чудотворным путём."
	icon_state = "slugcat_gold"
	icon_living = "slugcat_gold"
	icon_dead = "slugcat_gold_dead"
	icon_resting = "slugcat_gold_rest"
	is_pacifist = FALSE
	is_reduce_damage = FALSE
	gold_core_spawnable = NO_SPAWN
	health = 300
	maxHealth = 300


/mob/living/simple_animal/pet/slugcat/attackby(obj/item/I, mob/user, params)
	if(user.a_intent == INTENT_HARM)
		return ..()

	if(istype(I, /obj/item/clothing/head))
		add_fingerprint(user)
		if(place_on_head(I, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	if(istype(I, /obj/item/twohanded/spear))
		add_fingerprint(user)
		if(place_to_hand(I, user))
			return ATTACK_CHAIN_BLOCKED_ALL
		return ATTACK_CHAIN_PROCEED

	return ..()


/mob/living/simple_animal/pet/slugcat/death(gibbed)
	drop_hat()
	drop_hand()
	. = ..()

/mob/living/simple_animal/pet/slugcat/regenerate_icons()
	cut_overlays()
	if(pcollar && collar_type)
		add_overlay("[collar_type]collar")
		add_overlay("[collar_type]tag")

	if(inventory_head)
		var/image/head_icon

		if(!hat_icon_state)
			hat_icon_state = inventory_head.icon_state
		if(!hat_alpha)
			hat_alpha = inventory_head.alpha
		if(!hat_color)
			hat_color = inventory_head.color
		if(!hat_icon_file)
			hat_icon_file = inventory_head.onmob_sheets[ITEM_SLOT_HEAD_STRING]

		head_icon = get_hat_overlay()

		add_overlay(head_icon)

	update_fire()

	if(blocks_emissive)
		add_overlay(get_emissive_block())


/mob/living/simple_animal/pet/slugcat/on_lying_down(new_lying_angle)
	if(inventory_head)
		hat_offset_y = hat_offset_y_rest
	drop_hand()
	. = ..()


/mob/living/simple_animal/pet/slugcat/on_standing_up()
	if(inventory_head)
		hat_offset_y = initial(hat_offset_y)
	. = ..()


/mob/living/simple_animal/pet/slugcat/proc/speared()
	icon_living = "[icon_living]_spear"
	var/obj/item/twohanded/spear = inventory_hand
	attacktext = "бьёт копьём"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	melee_damage_type = BRUTE
	melee_damage_lower = round(spear.force_unwielded / (is_reduce_damage ? 2 : 1))
	melee_damage_upper = round(spear.force_wielded / (is_reduce_damage ? 2 : 1))
	armour_penetration = spear.armour_penetration
	obj_damage = spear.force
	update_icons()

/mob/living/simple_animal/pet/slugcat/proc/unspeared()
	icon_living = initial(icon_living)
	attacktext = initial(attacktext)
	attack_sound = initial(attack_sound)
	melee_damage_type = initial(melee_damage_type)
	melee_damage_lower = initial(melee_damage_lower)
	melee_damage_upper = initial(melee_damage_upper)
	armour_penetration = initial(armour_penetration)
	obj_damage = initial(obj_damage)
	update_icons()

/mob/living/simple_animal/pet/slugcat/proc/get_hat_overlay()
	if(hat_icon_file && hat_icon_state)
		var/image/slugI = image(hat_icon_file, hat_icon_state)
		slugI.alpha = hat_alpha
		slugI.color = hat_color
		slugI.pixel_y = hat_offset_y
		//slugI.transform = matrix(1, 0, 1, 0, 1, 0)
		return slugI


/mob/living/simple_animal/pet/slugcat/proc/place_on_head(obj/item/item_to_add, mob/user)
	if(stat != CONSCIOUS)
		to_chat(user, span_warning("[declent_ru(NOMINATIVE)] не в том состоянии, чтобы пользоваться предметами!"))
		return FALSE

	if(!item_to_add)
		if(user)
			user.visible_message(
				span_notice("[user] похлопывает по голове [declent_ru(GENITIVE)]."),
				span_notice("Вы положили руку на голову [declent_ru(DATIVE)]."),
			)
		if(flags & HOLOGRAM)
			return FALSE
		return FALSE

	if(!istype(item_to_add, /obj/item/clothing/head))
		if(user)
			to_chat(user, span_warning("Предмет нельзя надеть на голову [declent_ru(DATIVE)]!"))
		return FALSE

	if(inventory_head)
		if(user)
			to_chat(user, span_warning("Нельзя надеть больше одного головного убора!"))
		return FALSE

	if(user && item_to_add.loc == user && !user.drop_transfer_item_to_loc(item_to_add, src))
		return FALSE

	if(user)
		user.visible_message(
			span_notice("[user] надевает головной убор на голову [declent_ru(DATIVE)]."),
			span_notice("Вы надеваете головной убор на голову [declent_ru(DATIVE)]."),
			span_italics("Вы слышите как что-то нацепили."),
		)
	if(item_to_add.loc != src)
		item_to_add.forceMove(src)
	inventory_head = item_to_add
	regenerate_icons()
	return TRUE


/mob/living/simple_animal/pet/slugcat/proc/remove_from_head(mob/user)
	if(inventory_head)
		if(HAS_TRAIT(inventory_head, TRAIT_NODROP))
			to_chat(user, span_warning("[inventory_head.name] застрял на голове [src.name]! Его невозможно снять!"))
			return TRUE

		to_chat(user, span_warning("Вы сняли [inventory_head.name] с головы [src.name]."))
		drop_item_ground(inventory_head)
		user.put_in_hands(inventory_head, ignore_anim = FALSE)

		null_hat()

		regenerate_icons()
	else
		to_chat(user, span_warning("На голове [src.name] нет головного убора!"))
		return FALSE

	return TRUE

/mob/living/simple_animal/pet/slugcat/proc/drop_hat()
	if(inventory_head)
		drop_item_ground(inventory_head)
		null_hat()
		regenerate_icons()

/mob/living/simple_animal/pet/slugcat/proc/null_hat()
	inventory_head = null
	hat_icon_file = null
	hat_icon_state = null
	hat_alpha = null
	hat_color = null


/mob/living/simple_animal/pet/slugcat/proc/place_to_hand(obj/item/item_to_add, mob/user)
	if(stat != CONSCIOUS)
		to_chat(user, span_warning("[declent_ru(NOMINATIVE)] не в том состоянии, чтобы пользоваться предметами!"))
		return FALSE

	if(!item_to_add)
		if(user)
			user.visible_message(
				span_notice("[user] пощупал лапки [declent_ru(DATIVE)]."),
				span_notice("Вы пощупали лапки [declent_ru(DATIVE)]."),
			)
		if(flags & HOLOGRAM)
			return FALSE
		return FALSE

	if(resting)
		to_chat(user, span_warning("[declent_ru(NOMINATIVE)] спит и не может принять предмет!"))
		return FALSE

	if(!istype(item_to_add, /obj/item/twohanded/spear))
		if(user)
			to_chat(user, span_warning("Предмет нельзя поместить в лапки [declent_ru(DATIVE)]!"))
		return FALSE

	if(inventory_hand)
		if(user)
			to_chat(user, span_warning("Лапки [declent_ru(GENITIVE)] уже заняты!"))
		return FALSE

	if(is_pacifist)
		if(user)
			to_chat(user, span_warning("[declent_ru(NOMINATIVE)] пацифист и не пользуется копьями!"))
		return FALSE

	if(user && item_to_add.loc == user && !user.drop_transfer_item_to_loc(item_to_add, src))
		return FALSE

	if(user)
		user.visible_message(
			span_notice("[declent_ru(NOMINATIVE)] выхватывает копьё из рук [user]."),
			span_notice("[declent_ru(NOMINATIVE)] выхватывает копьё из Ваших рук."),
		)
	move_item_to_hand(item_to_add)
	return TRUE


/mob/living/simple_animal/pet/slugcat/proc/move_item_to_hand(obj/item/item_to_add)
	if(item_to_add.loc != src)
		item_to_add.forceMove(src)
	inventory_hand = item_to_add
	speared()


/mob/living/simple_animal/pet/slugcat/proc/remove_from_hand(mob/user)
	if(inventory_hand)
		if(HAS_TRAIT(inventory_hand, TRAIT_NODROP))
			to_chat(user, span_warning("[inventory_hand.name] застрял в лапах [src]! Его невозможно отнять!"))
			return TRUE

		to_chat(user, span_warning("Вы забрали [inventory_hand.name] с лап [src]."))
		drop_item_ground(inventory_hand)
		user.put_in_hands(inventory_hand, ignore_anim = FALSE)
		null_hand()
	else
		to_chat(user, span_warning("В лапах [src] нечего отбирать!"))
		return FALSE

	return TRUE


/mob/living/simple_animal/pet/slugcat/proc/drop_hand()
	if(inventory_hand)
		drop_item_ground(inventory_hand)
		null_hand()


/mob/living/simple_animal/pet/slugcat/proc/null_hand()
	unspeared()
	inventory_hand = null
