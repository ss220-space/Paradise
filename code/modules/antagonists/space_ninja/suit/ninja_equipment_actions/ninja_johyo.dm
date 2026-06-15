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
		return

	integrated_harpoon = new
	integrated_harpoon.my_suit = src
	var/datum/action/item_action/advanced/ninja/johyo/johyo = locate() in ninja.actions
	integrated_harpoon.my_action = johyo
	johyo.action_ready = TRUE
	johyo.toggle_button_on_off()

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
	return alist(
		NOMINATIVE = "джохё",
		GENITIVE = "джохё",
		DATIVE = "джохё",
		ACCUSATIVE = "джохё",
		INSTRUMENTAL = "джохё",
		PREPOSITIONAL = "джохё",
	)

/obj/item/gun/magic/johyo/Destroy()
	my_suit.integrated_harpoon = null
	my_suit = null
	my_action.action_ready = FALSE
	my_action.toggle_button_on_off()
	my_action = null
	return ..()

/obj/item/gun/magic/johyo/equip_to_best_slot(mob/user, force = FALSE, drop_on_fail = FALSE, qdel_on_fail = FALSE)
	qdel(src)

/obj/item/gun/magic/johyo/run_drop_held_item(mob/user)
	qdel(src)

/obj/item/gun/magic/johyo/can_trigger_gun(mob/living/user)
	if(!my_action.IsAvailable(feedback = TRUE))
		return FALSE
	if(!my_suit.ninjacost(cost * burst_amount))
		my_action.use_action()
		return TRUE
	return FALSE
