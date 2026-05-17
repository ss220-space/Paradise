// MARK: Tasers
/obj/item/gun/energy/taser
	name = "taser gun"
	desc = "A small, low capacity gun used for non-lethal takedowns."
	icon_state = "taser"
	item_state = null	//so the human update icon uses the icon_state instead.
	origin_tech = "combat=3"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode)
	ammo_x_offset = 3
	accuracy = GUN_ACCURACY_SNIPER

/obj/item/gun/energy/gun/advtaser
	name = "hybrid taser"
	desc = "A dual-mode taser designed to fire both short-range high-power electrodes and long-range disabler beams."
	icon_state = "advtaser"
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler)
	origin_tech = "combat=4"
	ammo_x_offset = 2
	accuracy = GUN_ACCURACY_RIFLE_LASER
	attachable_allowed = GUN_MODULE_CLASS_PISTOL_UNDER | GUN_MODULE_CLASS_ENERGY_WEAPON
	attachable_offset = list(
		ATTACHMENT_SLOT_UNDER = list(ATTACHMENT_OFFSET_X = 7, ATTACHMENT_OFFSET_Y = -6),
	)

/obj/item/gun/energy/gun/advtaser/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/gun/advtaser/cyborg
	name = "cyborg taser"
	desc = "An integrated hybrid taser that draws directly from a cyborg's power cell. The weapon contains a limiter to prevent the cyborg's power cell from overheating."
	can_charge = FALSE
	accuracy = GUN_ACCURACY_RIFLE_LASER

/obj/item/gun/energy/gun/advtaser/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/gun/advtaser/mounted
	name = "mounted taser"
	desc = "An arm mounted dual-mode weapon that fires electrodes and disabler shots."
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "taser"
	item_state = "armcannonstun4"
	selfcharge = TRUE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL // Has no trigger at all, uses neural signals instead
	attachable_allowed = null

// MARK: Disablers
/obj/item/gun/energy/disabler
	name = "disabler"
	desc = "A self-defense weapon that exhausts organic targets, weakening them until they collapse."
	icon_state = "disabler"
	item_state = null
	origin_tech = "combat=3"
	ammo_type = list(/obj/item/ammo_casing/energy/disabler)
	ammo_x_offset = 3
	accuracy = GUN_ACCURACY_PISTOL

/obj/item/gun/energy/disabler/sibyl/Initialize(mapload)
	. = ..()
	install_sibyl()

/obj/item/gun/energy/disabler/cyborg
	name = "cyborg disabler"
	desc = "An integrated disabler that draws from a cyborg's power cell. This weapon contains a limiter to prevent the cyborg's power cell from overheating."
	ammo_type = list(/obj/item/ammo_casing/energy/disabler/cyborg)
	can_charge = FALSE
	accuracy = GUN_ACCURACY_RIFLE_LASER

/obj/item/gun/energy/disabler/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/disabler/cyborg/emp_act(severity)
	return

/**
 * MARK: Tesla Cannon
 *
 * An advanced weapon that provides extremely high dps output at pinpoint accuracy due to its hitscan nature.
 * Due to its normal w_class when folded it is suitable as a heavy reinforcement weapon, since the cell drains very quickly when firing.
 * The power level is somewhat tempered by several drawbacks such as research requirements, anomalock, two handed firing requirement, and insultation providing damage reduction.
 * It is often confused with the mech weapon of the same name, since it is a bit more obscure despite being very powerful. Formerly called the tesla revolver.
 */
/obj/item/gun/energy/tesla_cannon
	name = "tesla cannon"
	desc = "A high voltage flux projector prototype created using the latest advancements in the anomaly science.\n\nThe anomalous nature of the flux core allows the tesla arc to be guided from the electrode to the target without being diverted to stray conductors outside the target field."
	icon = 'icons/obj/weapons/guns/wide_guns.dmi'
	icon_state = "tesla"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	item_state = null // null so we build the correct inhand.
	pixel_w = -8
	base_pixel_w = -8
	ammo_type = list(/obj/item/ammo_casing/energy/tesla_cannon)
	inhand_x_dimension = 64
	shaded_charge = TRUE
	charge_sections = 2
	//display_empty =  FALSE
	weapon_weight = WEAPON_HEAVY
	w_class = WEIGHT_CLASS_BULKY
	accuracy = GUN_ACCURACY_MINIMAL
	cell_type = /obj/item/stock_parts/cell/laser/tesla_cannon
	can_add_sibyl_system = FALSE
	attachable_allowed = GUN_MODULE_CLASS_NONE
	fire_delay = 100 MILLISECONDS
	gun_firemode = GUN_FIREMODE_AUTOMATIC
	gun_firemode_list = list(GUN_FIREMODE_AUTOMATIC)
	sound_loop = /datum/looping_sound/tesla_cannon
	materials = list(MAT_METAL = SHEET_MATERIAL_AMOUNT * 5, MAT_GLASS = SHEET_MATERIAL_AMOUNT * 5, MAT_SILVER = SHEET_MATERIAL_AMOUNT * 5)
	var/ready_to_fire = FALSE

/obj/item/gun/energy/tesla_cannon/can_trigger_gun(mob/living/user, akimbo_usage)
	if(ready_to_fire)
		return ..()
	// If we have charge, but the stock is folded, do sparks.
	. = FALSE
	if(!can_shoot())
		return
	balloon_alert(user, "электричество бьёт в приклад!")
	if(prob(75)) // fake sparks to cut on spark spam
		playsound(user, 'sound/effects/sparks1.ogg', 50, TRUE)
		return
	do_sparks(3, FALSE, user)

/obj/item/gun/energy/tesla_cannon/attack_self(mob/living/user)
	. = ..()
	if(ready_to_fire)
		w_class = WEIGHT_CLASS_NORMAL
		ready_to_fire = FALSE
		playsound(user, 'sound/weapons/gun/tesla/squeak_latch.ogg', 100)
	else
		playsound(user, 'sound/weapons/gun/tesla/click_creak.ogg', 100)
		if(!do_after(user, 1.5 SECONDS, src))
			return
		w_class = WEIGHT_CLASS_BULKY
		ready_to_fire = TRUE
		playsound(user, 'sound/weapons/gun/tesla/squeak_latch.ogg', 100)

	update_appearance()
	balloon_alert_to_viewers("[ready_to_fire ? "разложен" : "сложен"] приклад")

/obj/item/gun/energy/tesla_cannon/update_icon_state()
	. = ..()
	if(ready_to_fire)
		icon_state = "tesla_unfolded"
		overlay_set = "tesla_unfolded"
	else
		icon_state = initial(icon_state)
		overlay_set = initial(overlay_set)
