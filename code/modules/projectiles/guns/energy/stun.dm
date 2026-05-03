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

// MARK: Shock revolver
/obj/item/gun/energy/shock_revolver
	name = "tesla revolver"
	desc = "A high-tech revolver that fires internal, reusable shock cartridges in a revolving cylinder. The cartridges can be recharged using conventional rechargers."
	icon_state = "stunrevolver"
	origin_tech = "combat=4;materials=4;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/shock_revolver)
	shaded_charge = TRUE
	accuracy = GUN_ACCURACY_MINIMAL
