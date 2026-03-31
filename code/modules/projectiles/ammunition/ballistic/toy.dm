// MARK: Foam dart
/obj/item/ammo_casing/caseless/foam_dart
	name = "foam dart"
	desc = "It's nerf or nothing! Ages 8 and up."
	icon = 'icons/obj/weapons/toy.dmi'
	icon_state = "foamdart"
	materials = list(MAT_METAL = 10)
	caliber = CALIBER_FOAM_FORCE
	projectile_type = /obj/projectile/bullet/reusable/foam_dart
	muzzle_flash_effect = null
	var/modified = FALSE
	harmful = FALSE

/obj/item/ammo_casing/caseless/foam_dart/update_icon_state()
	if(modified)
		icon_state = "foamdart_empty"
		if(BB)
			BB.icon_state = "foamdart_empty"
	else
		icon_state = initial(icon_state)
		if(BB)
			BB.icon_state = initial(BB.icon_state)

/obj/item/ammo_casing/caseless/foam_dart/update_desc(updates)
	. = ..()
	desc = modified ? "Its nerf or nothing! ... Although, this one doesn't look too safe." : initial(desc)

/obj/item/ammo_casing/caseless/foam_dart/attackby(obj/item/I, mob/user, params)
	if(is_pen(I))
		add_fingerprint(user)
		var/obj/projectile/bullet/reusable/foam_dart/bullet = BB
		if(!bullet)
			to_chat(user, span_warning("The [name] has no bullet."))
			return ATTACK_CHAIN_PROCEED
		if(!modified)
			to_chat(user, span_warning("The [name] should be modified first."))
			return ATTACK_CHAIN_PROCEED
		if(bullet.pen)
			to_chat(user, span_warning("The [name] already has a pen inserted."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		harmful = TRUE
		I.forceMove(bullet)
		bullet.log_override = FALSE
		bullet.pen = I
		bullet.damage = 5
		bullet.nodamage = FALSE
		to_chat(user, span_notice("You have inserted [I] into [src]."))
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()

/obj/item/ammo_casing/caseless/foam_dart/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!BB)
		add_fingerprint(user)
		to_chat(user, span_warning("The [name] has no bullet."))
		return .
	if(modified)
		add_fingerprint(user)
		to_chat(user, span_warning("The [name] is already modified."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	modified = TRUE
	BB.damage_type = BRUTE
	update_icon()

/obj/item/ammo_casing/caseless/foam_dart/attack_self(mob/living/user)
	var/obj/projectile/bullet/reusable/foam_dart/FD = BB
	if(FD.pen)
		FD.damage = initial(FD.damage)
		FD.nodamage = initial(FD.nodamage)
		user.put_in_hands(FD.pen)
		to_chat(user, span_notice("You remove [FD.pen] from [src]."))
		FD.pen = null

/obj/item/ammo_casing/caseless/foam_dart/riot
	name = "riot foam dart"
	desc = "Whose smart idea was it to use toys as crowd control? Ages 18 and up."
	icon_state = "foamdart_riot"
	materials = list(MAT_METAL = 650)
	projectile_type = /obj/projectile/bullet/reusable/foam_dart/riot

/obj/item/ammo_casing/caseless/foam_dart/sniper
	name = "foam sniper dart"
	desc = "For the big nerf! Ages 8 and up."
	icon_state = "foamdartsniper"
	materials = list(MAT_METAL = 20)
	caliber = CALIBER_FOAM_FORCE_SNIPER
	projectile_type = /obj/projectile/bullet/reusable/foam_dart/sniper

/obj/item/ammo_casing/caseless/foam_dart/sniper/update_icon_state()
	if(modified)
		icon_state = "foamdartsniper_empty"
		if(BB)
			BB.icon_state = "foamdartsniper_empty"
	else
		icon_state = initial(icon_state)
		if(BB)
			BB.icon_state = initial(BB.icon_state)

/obj/item/ammo_casing/caseless/foam_dart/sniper/update_desc(updates)
	. = ..()
	desc = modified ? "Its nerf or nothing! ... Although, this one doesn't look too safe." : initial(desc)

/obj/item/ammo_casing/caseless/foam_dart/sniper/riot
	name = "riot foam sniper dart"
	desc = "For the bigger brother of the crowd control toy. Ages 18 and up."
	icon_state = "foamdartsniper_riot"
	materials = list(MAT_METAL = 1800)
	projectile_type = /obj/projectile/bullet/reusable/foam_dart/sniper/riot

// MARK: Cap
/obj/item/ammo_casing/cap
	desc = "A cap for children toys."
	materials = list(MAT_METAL = 10)
	caliber = CALIBER_CAP
	projectile_type = /obj/projectile/bullet/cap
	muzzle_flash_strength = MUZZLE_FLASH_STRENGTH_NORMAL
	muzzle_flash_range = MUZZLE_FLASH_RANGE_NORMAL
