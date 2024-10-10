/obj/effect/proc_holder/spell/touch/banana
	name = "Banana Touch"
	desc = "Заклинание, популярное на вечеринках по случаю дня рождения магов. Позволяет одеть жертву в костюм клоуна, \
		оглушить громким ХОНКОМ и изменить внешность! \
		Внимание: эффекты необратимы для всех целей за исключением магов."
	hand_path = /obj/item/melee/touch_attack/banana
	school = "transmutation"

	base_cooldown = 30 SECONDS
	clothes_req = TRUE
	cooldown_min = 10 SECONDS //50 deciseconds reduction per rank
	action_icon_state = "clown"


/obj/item/melee/touch_attack/banana
	name = "banana touch"
	desc = "Пришло время клоунствовать."
	catchphrase = "NWOLC YRGNA"
	on_use_sound = 'sound/items/AirHorn.ogg'
	icon_state = "banana_touch"
	item_state = "banana_touch"


/obj/item/melee/touch_attack/banana/afterattack(atom/target, mob/living/carbon/user, proximity, params)
	if(!proximity || target == user || !ishuman(target) || !iscarbon(user) || user.incapacitated() || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return

	var/datum/effect_system/smoke_spread/smoke = new
	smoke.set_up(5, FALSE, target)
	smoke.start()

	to_chat(user, "<font color='red' size='6'>HONK</font>")
	var/mob/living/carbon/human/h_target = target
	h_target.bananatouched()
	..()


/mob/living/carbon/human/proc/bananatouched()
	to_chat(src, "<font color='red' size='6'>HONK</font>")
	Weaken(14 SECONDS)
	Stuttering(30 SECONDS)
	do_jitter_animation(15)

	if(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE)) //Wizards get non-cursed clown robes and magical mask.
		drop_item_ground(shoes, force = TRUE)
		drop_item_ground(wear_mask, force = TRUE)
		drop_item_ground(head, force = TRUE)
		drop_item_ground(wear_suit, force = TRUE)
		equip_to_slot_or_del(new /obj/item/clothing/head/wizard/clown, ITEM_SLOT_HEAD)
		equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/clown, ITEM_SLOT_CLOTH_OUTER)
		equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes/magical)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clownwiz, ITEM_SLOT_MASK)
	else
		qdel(shoes)
		qdel(wear_mask)
		qdel(w_uniform)
		equip_to_slot_or_del(new /obj/item/clothing/under/rank/clown/nodrop, ITEM_SLOT_CLOTH_INNER)
		equip_to_slot_or_del(new /obj/item/clothing/shoes/clown_shoes/nodrop, ITEM_SLOT_FEET)
		equip_to_slot_or_del(new /obj/item/clothing/mask/gas/clown_hat/nodrop, ITEM_SLOT_MASK)
	force_gene_block(GLOB.clumsyblock, TRUE)
	force_gene_block(GLOB.comicblock, TRUE)
	if(!(iswizard(src) || (mind && mind.special_role == SPECIAL_ROLE_WIZARD_APPRENTICE))) //Mutations are permanent on non-wizards. Can still be removed by genetics fuckery but not mutadone.
		LAZYOR(dna.default_blocks, GLOB.clumsyblock)
		LAZYOR(dna.default_blocks, GLOB.comicblock)

