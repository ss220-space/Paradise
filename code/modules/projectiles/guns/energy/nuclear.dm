/obj/item/gun/energy/gun
	name = "energy gun"
	desc = "A basic energy-based gun with two settings: kill and disable."
	icon_state = "energy"
	item_state = null	//so the human update icon uses the icon_state instead.
	ammo_type = list(/obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	origin_tech = "combat=4;magnets=3"
	modifystate = TRUE
	can_flashlight = TRUE
	ammo_x_offset = 3
	flight_x_offset = 15
	flight_y_offset = 10

/obj/item/gun/energy/gun/cyborg
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"

/obj/item/gun/energy/gun/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/gun/cyborg/emp_act()
	return

/obj/item/gun/energy/gun/mini
	name = "miniature energy gun"
	desc = "A small, pistol-sized energy gun with a built-in flashlight. It has two settings: disable and kill."
	icon_state = "mini"
	w_class = WEIGHT_CLASS_SMALL
	gun_light_overlay = "mini-light"
	flight_x_offset = 0
	flight_y_offset = 0
	ammo_x_offset = 2
	charge_sections = 3
	can_flashlight = FALSE


/obj/item/gun/energy/gun/mini/Initialize(mapload, ...)
	. = ..()
	set_gun_light(new /obj/item/flashlight/seclite(src))
	cell.maxcharge = 600
	cell.charge = 600


/obj/item/gun/energy/gun/hos
	name = "\improper X-01 MultiPhase Energy Gun"
	desc = "This is an expensive, modern recreation of an antique laser gun. This gun has several unique firemodes, but lacks the ability to recharge over time."
	icon_state = "hoslaser"
	origin_tech = null
	force = 10
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/hos, /obj/item/ammo_casing/energy/disabler/hos, /obj/item/ammo_casing/energy/laser/hos, /obj/item/ammo_casing/energy/dominator/slaughter)
	ammo_x_offset = 4
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/gun/energy/gun/blueshield
	name = "advanced stun revolver"
	desc = "An advanced stun revolver with the capacity to shoot both electrodes and lasers."
	icon_state = "bsgun"
	item_state = "gun"
	var/emagged = FALSE
	force = 7
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/blueshield, /obj/item/ammo_casing/energy/disabler/blueshield, /obj/item/ammo_casing/energy/laser/blueshield)
	ammo_x_offset = 1
	shaded_charge = TRUE

/obj/item/gun/energy/gun/blueshield/can_shoot(mob/user)
	. = ..()
	if(. && !isertmindshielded(user) && !emagged)
		balloon_alert(usr, "имплант \"ERT Mindshield\" не обнаружен!")
		return FALSE
	else if(. && emagged && ismindshielded(user))
		balloon_alert(usr, "имплант защиты разума обнаружен. Самоликвидация.")
		var/turf/T = get_turf(src.loc)
		user.show_message(span_danger("[src] has been exploded!"))
		T.hotspot_expose(700,125)
		explosion(T, -1, -1, 2, 3, cause = src)
		qdel(src)
	else if(. && !ismindshielded(user) && emagged)
		return TRUE


/obj/item/gun/energy/gun/blueshield/emag_act(mob/user)
	if(!emagged)
		emagged = TRUE
		user.visible_message(span_warning("Sparks fly out of the [src]!</span>"), span_notice("Revolver can't work rightly for now."))
		desc = "An advanced stun revolver with the capacity to shoot both electrodes and lasers. Something wrong in indetification systems."
		playsound(loc, 'sound/effects/sparks4.ogg', 50, TRUE)

/obj/item/gun/energy/gun/pdw9
	name = "PDW-9 taser pistol"
	desc = "A military grade sidearm, used by many militia forces throughout the local sector."
	icon_state = "pdw9pistol"
	item_state = "gun"
	force = 7
	ammo_type = list(/obj/item/ammo_casing/energy/electrode/hos, /obj/item/ammo_casing/energy/laser/hos)
	ammo_x_offset = 1
	shaded_charge = TRUE

/obj/item/gun/energy/gun/pdw9/ert

/obj/item/gun/energy/gun/pdw9/ert/can_shoot(mob/user)
	. = ..()
	if(. && !isertmindshielded(user))
		balloon_alert(usr, "имплант \"ERT Mindshield\" не обнаружен!")
		return FALSE

/obj/item/gun/energy/gun/turret
	name = "hybrid turret gun"
	desc = "A heavy hybrid energy cannon with two settings: Stun and kill."
	icon_state = "turretlaser"
	item_state = "turretlaser"
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/laser)
	weapon_weight = WEAPON_HEAVY
	can_flashlight = FALSE
	trigger_guard = TRIGGER_GUARD_NONE
	ammo_x_offset = 2

/obj/item/gun/energy/gun/nuclear
	name = "advanced energy gun"
	desc = "An energy gun with an experimental miniaturized nuclear reactor that automatically charges the internal power cell."
	icon_state = "nucgun"
	item_state = "nucgun"
	origin_tech = "combat=4;magnets=4;powerstorage=4"
	charge_delay = 5
	can_charge = FALSE
	ammo_x_offset = 1
	ammo_type = list(/obj/item/ammo_casing/energy/electrode, /obj/item/ammo_casing/energy/disabler, /obj/item/ammo_casing/energy/laser)
	selfcharge = TRUE
