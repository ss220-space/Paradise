/obj/item/weldingtool/sword
	name = "welding sword"
	desc = "Аналог энергетического меча, изготовленный из сварки неизвестным мастером из Грейтайда. Он имеет аналогичные характеристики, но наносит ожоги вместо травм в активном состоянии. Во время атаки расходует сварочное топливо."
	icon = 'icons/obj/items.dmi'
	icon_state = "fuelsword"
	item_state = "fuelsword"
	needs_permit = 1
	belt_icon = null
	force_enabled = 30
	low_fuel_changes_icon = FALSE
	block_chance = 50
	item_flags = NOSHARPENING
	sharp = 1
	tool_behaviour = NONE
	maximum_fuel = 50
	origin_tech = "combat=3;magnets=4;plasmatech=5;"
	/// Сan be combined with other similar item
	var/combinable = TRUE


/obj/item/weldingtool/sword/toggle_welder(turn_off)
	. = ..()
	if(tool_enabled)
		tool_behaviour = NONE
	else
		tool_behaviour = TOOL_WELDER

/obj/item/weldingtool/sword/update_icon_state()
	. = ..()
	if(tool_enabled)
		icon_state = "[initial(item_state)]1"
	else
		icon_state = "[initial(item_state)]"

/obj/item/weldingtool/sword/tool_use_check(mob/living/user, amount, silent)
	return FALSE

/obj/item/weldingtool/sword/afterattack(atom/target, mob/user, proximity, params, status)
	. = ..()
	if(ATTACK_CHAIN_SUCCESS_CHECK(status))
		remove_fuel(1)

/obj/item/weldingtool/sword/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weldingtool/sword) && combinable)
		add_fingerprint(user)
		var/obj/item/weldingtool/sword/sword = I

		if(!sword.combinable)
			return ATTACK_CHAIN_PROCEED

		if(I == src)
			to_chat(user, span_warning("You try to attach the end of sword to... itself. You're not very smart, are you?"))
			user.apply_damage(10, BRAIN)
			return ATTACK_CHAIN_PROCEED

		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED

		if(!user.drop_transfer_item_to_loc(I, src))
			return ATTACK_CHAIN_PROCEED

		to_chat(user,  span_notice("You attach the ends of the two welder swords, making a single double-bladed weapon! You're cool."))
		var/obj/item/weldingtool/sword/double/dual_sword = new(drop_location())
		user.temporarily_remove_item_from_inventory(src)
		user.put_in_hands(dual_sword, ignore_anim = FALSE)
		qdel(I)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/weldingtool/sword/double
	name = "double-bladed welding sword"
	desc = "Оружие, полученное путем объединения двух мечей из сварки в один. В отличие от двухклинкового энергетического меча, не способен отражать лазеры. Во время атаки расходует сварочное топливо."
	icon_state = "fuelsworddouble"
	item_state = "fuelsworddouble"
	force_enabled = 40
	force = 5
	block_chance = 75
	maximum_fuel = 70
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")
	origin_tech = "combat=5;magnets=5;plasmatech=6;"
	combinable = FALSE

/obj/item/weldingtool/sword/double/ComponentInitialize()
	AddComponent(/datum/component/two_handed, \
		force_unwielded = force, \
		force_wielded = force_enabled, \
		wieldsound = activation_sound, \
		unwieldsound = deactivation_sound, \
		sharp_when_wielded = TRUE, \
		wield_callback = CALLBACK(src, PROC_REF(wield)), \
		unwield_callback = CALLBACK(src, PROC_REF(unwield)), \
	)


/obj/item/weldingtool/sword/double/proc/wield(obj/item/source, mob/living/carbon/user)
	toggle_welder()


/obj/item/weldingtool/sword/double/proc/unwield(obj/item/source, mob/living/carbon/user)
	toggle_welder()


/obj/item/weldingtool/sword/double/remove_fuel(amount)
	reagents.remove_reagent("fuel", amount * requires_fuel)
	if(!GET_FUEL && tool_enabled)
		attack_self(usr)


/obj/item/weldingtool/sword/double/try_toggle_welder(mob/user, manual_toggle = TRUE)
	return ..(user, manual_toggle = FALSE)


/obj/item/weldingtool/sword/double/attack(mob/living/target, mob/living/user, params, def_zone, skip_attack_anim = FALSE)
	. = ..()
	if(!ATTACK_CHAIN_SUCCESS_CHECK(.) || !HAS_TRAIT(src, TRAIT_WIELDED))
		return .

	if(prob(50))
		INVOKE_ASYNC(src, GLOBAL_PROC_REF(jedi_spin), user)


/obj/item/weldingtool/sword/double/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = ITEM_ATTACK)
	if(tool_enabled)
		return ..()
	return FALSE

