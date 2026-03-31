/obj/item/gun/projectile/automatic/speargun
	name = "kinetic speargun"
	desc = "A weapon favored by carp hunters. Fires specialized spears using kinetic energy."
	icon_state = "speargun"
	item_state = "speargun"
	w_class = WEIGHT_CLASS_BULKY
	origin_tech = "combat=4;engineering=4"
	force = 10
	mag_type = /obj/item/ammo_box/magazine/internal/speargun
	fire_sound = 'sound/weapons/genhit.ogg'
	burst_size = 1
	fire_delay = 0
	select = 0
	actions_types = null
	accuracy = GUN_ACCURACY_DEFAULT
	recoil = null
	fire_modes = GUN_MODE_SINGLE_ONLY

/obj/item/gun/projectile/automatic/speargun/update_icon_state()
	return

/obj/item/gun/projectile/automatic/speargun/attack_self()
	return

/obj/item/gun/projectile/automatic/speargun/can_shoot(mob/user)
	if(chambered)
		return TRUE
	return FALSE

/obj/item/gun/projectile/automatic/speargun/process_chamber(eject_casing = FALSE, empty_chamber = TRUE)
	. = ..()

/obj/item/gun/projectile/automatic/speargun/attackby(obj/item/I, mob/user, params)
	if(isammobox(I) || isammocasing(I))
		add_fingerprint(user)
		var/num_loaded = magazine.reload(I, user, silent = TRUE, count_chambered = TRUE)
		if(num_loaded)
			balloon_alert(user, "копьё заряжено")
			chamber_round()
			update_icon()
			return ATTACK_CHAIN_BLOCKED_ALL
		balloon_alert(user, "не удалось!")
		return ATTACK_CHAIN_PROCEED

	return ..()
