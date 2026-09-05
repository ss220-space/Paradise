/datum/action/cooldown/spell/touch/banana_touch
	name = "Banana Touch"
	desc = "A spell popular at wizard birthday parties, this spell will put on a clown costume on the target, \
		stun them with a loud HONK, and mutate them to make them more entertaining! \
		Warning : Effects are permanent on non-wizards."
	hand_path = /obj/item/melee/touch_attack/banana_touch
	school = SCHOOL_TRANSMUTATION
	sound = 'sound/items/AirHorn.ogg'
	invocation = "NWOLC YRGNA"
	cooldown_time = 30 SECONDS
	cooldown_reduction_per_rank = 5 SECONDS //50 deciseconds reduction per rank
	button_icon_state = "clown"

/obj/item/melee/touch_attack/banana_touch
	name = "banana touch"
	desc = "It's time to start clowning around."
	icon_state = "banana_touch"
	item_state = "banana_touch"

/datum/action/cooldown/spell/touch/banana_touch/is_valid_target(atom/cast_on)
	return ishuman(cast_on)

/datum/action/cooldown/spell/touch/banana_touch/cast_on_hand_hit(obj/item/melee/touch_attack/hand, atom/victim, mob/living/carbon/caster)
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	smoke.set_up(amount = 5, location = victim)
	smoke.start()
	to_chat(victim, "<font color='red' size='6'>HONK</font>")
	var/mob/living/carbon/human/h_target = victim
	h_target.bananatouched()
	return TRUE

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

