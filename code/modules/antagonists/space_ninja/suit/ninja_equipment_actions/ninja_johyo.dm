/datum/action/item_action/advanced/ninja/johyo
	name = "Верёвочный кунай"
	desc = "Верёвочный кунай, спрятанный внутри костюма. \
	Укомплектован стреляющим механизмом, позволяющим выстреливать кинжал с невероятной скоростью, захватывая жертв. Затраты энергии: 500."
	charge_type = ADV_ACTION_TYPE_TOGGLE_RECHARGE
	charge_max = 5 SECONDS
	button_icon_state = "kunai"
	button_icon = 'icons/mob/actions/actions_ninja.dmi'
	background_icon_state = "background_green"
	action_initialisation_text = "Integrated Jōhyō launcher"

/obj/item/clothing/suit/space/space_ninja/proc/toggle_harpoon()
	var/mob/living/carbon/human/ninja = affecting
	if(integrated_harpoon)
		qdel(integrated_harpoon)
		integrated_harpoon = null
	else
		integrated_harpoon = new
		integrated_harpoon.my_suit = src
		for(var/datum/action/item_action/advanced/ninja/johyo/ninja_action in actions)
			integrated_harpoon.my_action = ninja_action
			ninja_action.action_ready = TRUE
			ninja_action.toggle_button_on_off()
			break
		ninja.put_in_hands(integrated_harpoon)

//Harpoon

/obj/item/gun/magic/johyo
	name = "Integrated Jōhyō"
	desc = "GET OVER HERE!"
	ammo_type = /obj/item/ammo_casing/magic/johyo
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "kunai_inhand"
	item_state = "chain"
	fire_sound = 'sound/weapons/draw_bow.ogg'
	max_charges = 1
	recharge_rate = 0
	charge_tick = 1
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	slot_flags = NONE
	item_flags = DROPDEL|ABSTRACT|NOBLUDGEON
	force = 10
	ninja_weapon = TRUE
	var/cost = 500
	var/obj/item/clothing/suit/space/space_ninja/my_suit = null
	var/datum/action/item_action/advanced/ninja/johyo/my_action = null

/obj/item/gun/magic/johyo/get_ru_names()
	return list(
		NOMINATIVE = "джохё",
		GENITIVE = "джохё",
		DATIVE = "джохё",
		ACCUSATIVE = "джохё",
		INSTRUMENTAL = "джохё",
		PREPOSITIONAL = "джохё",
	)

/obj/item/gun/magic/johyo/Destroy()
	. = ..()
	my_suit.integrated_harpoon = null
	my_suit = null
	my_action.action_ready = FALSE
	my_action.toggle_button_on_off()
	my_action = null

/obj/item/gun/magic/johyo/equip_to_best_slot(mob/user, force = FALSE, drop_on_fail = FALSE, qdel_on_fail = FALSE)
	qdel(src)

/obj/item/gun/magic/johyo/run_drop_held_item(mob/user)
	qdel(src)

/obj/item/gun/magic/johyo/can_trigger_gun(mob/living/user)
	if(!my_action.IsAvailable(feedback = TRUE))
		return FALSE
	if(!my_suit.ninjacost(cost*burst_size))
		my_action.use_action()
		return TRUE
	return FALSE

/obj/item/ammo_casing/magic/johyo
	name = "Jōhyō"
	desc = "Кинжал, прикреплённый к верёвке. Просто и эффективно."
	projectile_type = /obj/projectile/johyo
	muzzle_flash_effect = null
	caliber = "kunai"
	icon = 'icons/obj/ninjaobjects.dmi'
	icon_state = "kunai"

/obj/item/ammo_casing/magic/johyo/get_ru_names()
	return list(
		NOMINATIVE = "джохё",
		GENITIVE = "джохё",
		DATIVE = "джохё",
		ACCUSATIVE = "джохё",
		INSTRUMENTAL = "джохё",
		PREPOSITIONAL = "джохё",
	)

/obj/projectile/johyo
	name = "Jōhyō"
	icon_state = "kunai"
	icon = 'icons/obj/ninjaobjects.dmi'
	damage = 5
	armour_penetration = 100
	hitsound = 'sound/weapons/whip.ogg'
	knockdown = 2 SECONDS

/obj/projectile/johyo/fire(setAngle)
	if(firer)
		firer.say(pick("Get over here!", "Come here!"))
		chain = firer.Beam(src, icon_state = "chain_dark", time = INFINITY, maxdistance = INFINITY)
	. = ..()

/obj/projectile/johyo/on_hit(atom/target)
	. = ..()
	if(isliving(target))
		var/mob/living/target_living = target
		var/turf/firer_turf = get_turf(firer)
		if(!target_living.anchored && target_living.loc)
			target_living.visible_message(span_danger("[target_living.declent_ru(NOMINATIVE)] зацепля[PLUR_ET_YUT(target_living)]ся за цепь [firer.declent_ru(GENITIVE)]!"))

			ADD_TRAIT(target_living, TRAIT_UNDENSE, UNIQUE_TRAIT_SOURCE(src))	// Ensures the hook does not hit the target multiple times
			target_living.forceMove(firer_turf)
			REMOVE_TRAIT(target_living, TRAIT_UNDENSE, UNIQUE_TRAIT_SOURCE(src))

/obj/projectile/johyo/Destroy()
	QDEL_NULL(chain)
	return ..()
