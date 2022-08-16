/obj/item/gun/energy/laser
	name = "laser gun"
	desc = "A basic energy-based laser gun that fires concentrated beams of light which pass through glass and thin metal."
	icon_state = "laser"
	item_state = "laser"
	w_class = WEIGHT_CLASS_NORMAL
	materials = list(MAT_METAL=2000)
	origin_tech = "combat=4;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/lasergun)
	ammo_x_offset = 1
	shaded_charge = 1

/obj/item/gun/energy/laser/practice
	name = "practice laser gun"
	desc = "A modified version of the basic laser gun, this one fires less concentrated energy bolts designed for target practice."
	origin_tech = "combat=2;magnets=2"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/practice)
	clumsy_check = 0
	needs_permit = 0

/obj/item/gun/energy/laser/retro
	name ="retro laser gun"
	icon_state = "retro"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's private security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	ammo_x_offset = 3

/obj/item/gun/energy/laser/captain
	name = "antique laser gun"
	icon_state = "caplaser"
	item_state = "caplaser"
	desc = "This is an antique laser gun. All craftsmanship is of the highest quality. It is decorated with assistant leather and chrome. The object menaces with spikes of energy. On the item is an image of Space Station 13. The station is exploding."
	force = 10
	origin_tech = null
	ammo_x_offset = 3
	selfcharge = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

/obj/item/gun/energy/laser/captain/scattershot
	name = "scatter shot laser rifle"
	icon_state = "lasercannon"
	item_state = "laser"
	desc = "An industrial-grade heavy-duty laser rifle with a modified laser lense to scatter its shot into multiple smaller lasers. The inner-core can self-charge for theorically infinite use."
	origin_tech = "combat=5;materials=4;powerstorage=4"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)
	shaded_charge = 0

/obj/item/gun/energy/laser/cyborg
	can_charge = 0
	desc = "An energy-based laser gun that draws power from the cyborg's internal energy cell directly. So this is what freedom looks like?"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/cyborg)
	origin_tech = null

/obj/item/gun/energy/laser/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/laser/cyborg/emp_act()
	return

/obj/item/gun/energy/laser/scatter
	name = "scatter laser gun"
	desc = "A laser gun equipped with a refraction kit that spreads bolts."
	ammo_type = list(/obj/item/ammo_casing/energy/laser/scatter, /obj/item/ammo_casing/energy/laser)


/obj/item/gun/energy/laser/awaymission_aeg
	name = "Wireless Energy Gun"
	desc = "An energy gun that recharges wirelessly during away missions. Does not work outside the gate."
	icon_state = "laser_gate"
	item_state = "nucgun"
	force = 10
	origin_tech = "combat=5;magnets=3;powerstorage=4"
	selfcharge = TRUE // Selfcharge is enabled and disabled, and used as the away mission tracker
	can_charge = 0
	var/emagged = FALSE

/obj/item/gun/energy/laser/awaymission_aeg/rnd
	name = "Exploreverse Strangler MK1"
	desc = "Первый прототип оружия с миниатюрным реактором и записанными протоколами безопасности для исследований в крайне отдаленных секторах.

/obj/item/gun/energy/laser/awaymission_aeg/Initialize(mapload)
	. = ..()
	// Force update it incase it spawns outside an away mission and shouldnt be charged
	onTransitZ(new_z = loc.z)

/obj/item/gun/energy/laser/awaymission_aeg/onTransitZ(old_z, new_z)
	if (!emagged)
		if(is_away_level(new_z))
			if(ismob(loc))
				to_chat(loc, "<span class='notice'>Your [src] activates, starting to draw power from a nearby wireless power source.</span>")
			selfcharge = TRUE
		else
			if(selfcharge)
				if(ismob(loc))
					to_chat(loc, "<span class='danger'>Your [src] deactivates, as it is out of range from its power source.</span>")
				cell.charge = 0
				selfcharge = FALSE
				update_icon()

/obj/item/gun/energy/laser/awaymission_aeg/emag_act(mob/user)
	. = ..()
	if (!emagged)
		user.visible_message("<span class='warning'>От [src] летят искры!</span>", "<span class='notice'>Вы взломали [src], что привело к перезаписи протоколов безопасности. Устройство может быть использовано вне ограничений.</span>")
		playsound(src.loc, 'sound/effects/sparks4.ogg', 30, 1)
		do_sparks(5, 1, src)

		emagged = TRUE
		selfcharge = TRUE



///Laser Cannon

/obj/item/gun/energy/lasercannon
	name = "accelerator laser cannon"
	desc = "An advanced laser cannon that does more damage the farther away the target is."
	icon_state = "lasercannon"
	item_state = "laser"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags =  CONDUCT
	slot_flags = SLOT_BACK
	can_holster = FALSE
	origin_tech = "combat=4;magnets=4;powerstorage=3"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/accelerator)
	ammo_x_offset = 3

/obj/item/ammo_casing/energy/laser/accelerator
	projectile_type = /obj/item/projectile/beam/laser/accelerator
	select_name = "accelerator"
	fire_sound = 'sound/weapons/lasercannonfire.ogg'

/obj/item/projectile/beam/laser/accelerator
	name = "accelerator laser"
	icon_state = "heavylaser"
	range = 255
	damage = 6

/obj/item/projectile/beam/laser/accelerator/Range()
	..()
	damage = min(damage+7, 100)

/obj/item/gun/energy/lasercannon/cyborg

/obj/item/gun/energy/lasercannon/cyborg/newshot()
	..()
	robocharge()

/obj/item/gun/energy/lasercannon/cyborg/emp_act()
	return

/obj/item/gun/energy/xray
	name = "xray laser gun"
	desc = "A high-power laser gun capable of expelling concentrated xray blasts. These blasts will penetrate solid objects, but will decrease in power the longer they have to travel."
	icon_state = "xray"
	origin_tech = "combat=6;materials=4;magnets=4"
	ammo_type = list(/obj/item/ammo_casing/energy/xray)

/obj/item/gun/energy/immolator
	name = "Immolator laser gun"
	desc = "A modified laser gun, shooting highly concetrated beams with higher intensity that ignites the target, for the cost of draining more power per shot"
	icon_state = "immolator"
	item_state = "laser"
	ammo_type = list(/obj/item/ammo_casing/energy/immolator)
	origin_tech = "combat=4;magnets=4;powerstorage=3"
	shaded_charge = 1

/obj/item/gun/energy/immolator/multi
	name = "multi lens immolator cannon"
	desc = "A large laser cannon, similar to the Immolator Laser, with toggleable firemodes. It is frequently used by military-like forces through Nanotrasen."
	icon_state = "multilensimmolator"
	ammo_type = list(/obj/item/ammo_casing/energy/immolator/strong, /obj/item/ammo_casing/energy/immolator/scatter)
	origin_tech = "combat=5;magnets=5;powerstorage=4"

/obj/item/gun/energy/immolator/multi/update_icon()
	..()
	var/obj/item/ammo_casing/energy/shot = ammo_type[select]
	var/append = shot.select_name
	overlays += image(icon = icon, icon_state = "multilensimmolator-[append]")


/obj/item/gun/energy/immolator/multi/cyborg
	name = "cyborg immolator cannon"
	ammo_type = list(/obj/item/ammo_casing/energy/immolator/scatter/cyborg, /obj/item/ammo_casing/energy/immolator/strong/cyborg) // scatter is default, because it is more useful


////////Laser Tag////////////////////

/obj/item/gun/energy/laser/tag
	name = "laser tag gun"
	desc = "Standard issue weapon of the Imperial Guard"
	origin_tech = "combat=2;magnets=2"
	clumsy_check = 0
	needs_permit = 0
	ammo_x_offset = 2
	selfcharge = 1

/obj/item/gun/energy/laser/tag/blue
	icon_state = "bluetag"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/bluetag)

/obj/item/gun/energy/laser/tag/red
	icon_state = "redtag"
	ammo_type = list(/obj/item/ammo_casing/energy/laser/redtag)
