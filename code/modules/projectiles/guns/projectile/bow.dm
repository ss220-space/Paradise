/obj/item/gun/projectile/bow
	name = "bow"
	desc = "A sturdy bow made out of wood and reinforced with iron."
	icon_state = "bow"
	item_state = "bow"
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/bow
	item_flags = SLOWS_WHILE_IN_HAND
	slot_flags = ITEM_SLOT_BACK
	weapon_weight = WEAPON_HEAVY
	trigger_guard = TRIGGER_GUARD_NONE
	var/draw_sound = 'sound/weapons/draw_bow.ogg'
	var/ready_to_fire = FALSE
	var/slowdown_when_ready = 2

/obj/item/gun/projectile/bow/ashen //better than wooden
	name = "bone bow"
	desc = "A primitive bow with a sinew bowstring. Typically used by tribal hunters and warriors. Due to the specific design of the bow, it's able to shoot only bone arrows."
	icon_state = "ashenbow"
	item_state = "ashenbow"
	mag_type = /obj/item/ammo_box/magazine/internal/bow/ashen //you can't shoot wooden arrows from bone bow!
	flags = NONE
	force = 10
	slowdown_when_ready = 1


/obj/item/gun/projectile/bow/proc/update_state()
	update_slowdown()
	update_icon(UPDATE_ICON_STATE)
	update_equipped_item()


/obj/item/gun/projectile/bow/update_icon_state()
	if(chambered && !ready_to_fire)
		icon_state = "[initial(icon_state)]_loaded"
	else if(ready_to_fire)
		icon_state = "[initial(icon_state)]_firing"
	else
		icon_state = initial(icon_state)


/obj/item/gun/projectile/bow/proc/update_slowdown()
	slowdown = ready_to_fire ? slowdown_when_ready : initial(slowdown)


/obj/item/gun/projectile/bow/dropped(mob/user, slot, silent = FALSE)
	if(chambered)
		chambered.forceMove(drop_location())
		chambered = null
		ready_to_fire = FALSE
		update_state()

	. = ..()


/obj/item/gun/projectile/bow/attack_self(mob/living/user)
	if(chambered && !ready_to_fire)
		ready_to_fire = TRUE
		playsound(user, draw_sound, 100, TRUE)
	else
		ready_to_fire = FALSE
	update_state()


/obj/item/gun/projectile/bow/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/ammo_box) || istype(I, /obj/item/ammo_casing))
		add_fingerprint(user)
		var/loaded = magazine.reload(I, user, silent = TRUE, count_chambered = TRUE)
		if(loaded)
			balloon_alert(user, "стрела помещена")
			chamber_round()
			update_state()
			return ATTACK_CHAIN_BLOCKED_ALL
		balloon_alert(user, "не удалось!")
		return ATTACK_CHAIN_PROCEED

	return ..()


/obj/item/gun/projectile/bow/can_shoot(mob/user)
	return chambered && ready_to_fire


/obj/item/gun/projectile/bow/shoot_with_empty_chamber(mob/living/user)
	return


/obj/item/gun/projectile/bow/process_chamber(eject_casing = FALSE, empty_chamber = TRUE)
	. = ..()
	ready_to_fire = FALSE
	update_state()


// ammo
/obj/item/ammo_box/magazine/internal/bow
	name = "bow internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	caliber = "arrow"
	max_ammo = 1
	start_empty = TRUE

/obj/item/ammo_box/magazine/internal/bow/ashen
	name = "ashen bow internal magazine"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone_tipped
	caliber = "bone_arrow"

/obj/item/projectile/bullet/reusable/arrow //only for wooden bow!
	name = "arrow"
	icon_state = "arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow
	range = 10
	damage = 25
	damage_type = BRUTE

/obj/item/projectile/bullet/reusable/arrow/bone //A fully upgraded normal arrow; it's got the stats to show. Still *less* damage than a slug, slower, and with negative AP. Only for bone bow!
	name = "bone-tipped arrow"
	icon_state = "bone_arrow"
	ammo_type = /obj/item/ammo_casing/caseless/arrow/bone_tipped
	range = 12
	damage = 45
	armour_penetration = -10

/obj/item/ammo_casing/caseless/arrow
	name = "arrow"
	desc = "Stab, stab, stab."
	icon_state = "arrow"
	force = 10
	projectile_type = /obj/item/projectile/bullet/reusable/arrow
	muzzle_flash_effect = null
	caliber = "arrow"

/obj/item/ammo_casing/caseless/arrow/bone_tipped
	name = "bone-tipped arrow"
	desc = "An arrow made from bone, wood, and sinew. Sturdy and sharp."
	icon_state = "bone_arrow"
	force = 12
	projectile_type = /obj/item/projectile/bullet/reusable/arrow/bone
	caliber = "bone_arrow"

//quiver
/obj/item/storage/backpack/quiver
	name = "quiver"
	desc = "A quiver for holding arrows."
	icon_state = "quiver"
	item_state = "quiver"
	storage_slots = 21
	max_combined_w_class = INFINITY
	display_contents_with_number = TRUE
	can_hold = list(
		/obj/item/ammo_casing/caseless/arrow
		)

/obj/item/storage/backpack/quiver/full/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow(src)
	update_icon()

/obj/item/storage/backpack/quiver/update_icon_state()
	if(length(contents))
		icon_state = "quiver_[clamp(length(contents),1,5)]"
	else
		icon_state = initial(icon_state)

/obj/item/storage/belt/quiver_weaver //belt slot
	name = "weaver chitin quiver"
	desc = "A fireproof quiver made from the chitin of a marrow weaver. Used to hold arrows."
	icon_state = "quiver_weaver"
	item_state = "quiver_weaver"
	storage_slots = 21 //every craft makes 3 arrows
	max_combined_w_class = INFINITY
	display_contents_with_number = TRUE
	can_hold = list(
		/obj/item/ammo_casing/caseless/arrow
		)
	resistance_flags = FIRE_PROOF

/obj/item/storage/belt/quiver_weaver/full/populate_contents()
	for(var/i in 1 to storage_slots)
		new /obj/item/ammo_casing/caseless/arrow/bone_tipped(src)
