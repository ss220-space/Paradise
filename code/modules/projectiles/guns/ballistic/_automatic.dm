/obj/item/gun/projectile/automatic
	abstract_type = /obj/item/gun/projectile/automatic
	can_tactical = TRUE
	can_holster = FALSE
	burst_amount = 3
	fire_delay = 0.3 SECONDS
	gun_firemode_list = list(GUN_FIREMODE_SEMIAUTO, GUN_FIREMODE_BURSTFIRE)

/obj/item/gun/projectile/automatic/update_icon_state()
	icon_state = "[initial(icon_state)][magazine ? "-[magazine.max_ammo]" : ""][chambered ? "" : "-e"]"

/obj/item/gun/projectile/automatic/update_overlays()
	. = ..()
	switch(gun_firemode)
		if(GUN_FIREMODE_SEMIAUTO)
			. += "[initial(icon_state)]semi"
		if(GUN_FIREMODE_BURSTFIRE)
			. += "[initial(icon_state)]burst"

/obj/item/gun/projectile/automatic/can_shoot(mob/user)
	return get_ammo()

/obj/item/gun/projectile/automatic/CtrlClick(mob/user)
	if(user.is_in_hands(src) && chambered)
		process_chamber(TRUE, TRUE)
		balloon_alert(user, "патрон извлечён")
		playsound(loc, 'sound/weapons/gun_interactions/remove_bullet.ogg', 50, TRUE)
		update_appearance(UPDATE_ICON_STATE|UPDATE_OVERLAYS)
		return
	return ..()
