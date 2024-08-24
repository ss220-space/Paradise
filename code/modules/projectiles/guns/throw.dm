/obj/item/gun/throw
	name = "abstract item thrower"
	desc = "This shouldn't be here, yell at a coder."
	fire_sound = 'sound/weapons/punchmiss.ogg'
	fire_sound_text = "thwock"

	var/obj/item/to_launch
	var/list/valid_projectile_type
	var/max_capacity = 1
	var/list/loaded_projectiles = list()

	var/projectile_speed = 1
	var/projectile_range = 1


/obj/item/gun/throw/Destroy()
	QDEL_NULL(to_launch)
	QDEL_LIST(loaded_projectiles)
	loaded_projectiles = null
	return ..()


/obj/item/gun/throw/proc/notify_ammo_count()
	return ""


/obj/item/gun/throw/proc/get_throwrange()
	return projectile_range


/obj/item/gun/throw/proc/get_throwspeed()
	return projectile_speed


/obj/item/gun/throw/proc/modify_projectile(obj/item/I, on_chamber = 0)
	return


/obj/item/gun/throw/proc/get_ammocount(include_loaded = 1)
	var/count = loaded_projectiles.len
	if(include_loaded && to_launch)
		count++
	return count


/obj/item/gun/throw/examine(mob/user)
	. = ..()
	. += span_info("It is [to_launch ? "loaded with [to_launch]" : "not loaded"].")
	var/ammo_count = notify_ammo_count()
	if(ammo_count)
		. += span_info(ammo_count)


/obj/item/gun/throw/attackby(obj/item/I, mob/user, params)
	if(istype(I, valid_projectile_type))
		add_fingerprint(user)
		if(get_ammocount() >= max_capacity)
			to_chat(user, span_warning("The [name] cannot hold more."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		loaded_projectiles += I
		var/message = span_notice("You have loaded [I] into [src].")
		var/ammo_count = notify_ammo_count()
		if(ammo_count)
			message += span_notice(" [ammo_count]")
		to_chat(user, message)
		if(!to_launch)
			process_chamber()
		update_appearance()
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/gun/throw/process_chamber()
	if(!to_launch && loaded_projectiles.len)
		to_launch = loaded_projectiles[1]
		loaded_projectiles -= to_launch


/obj/item/gun/throw/can_shoot(mob/user)
	return to_launch


/obj/item/gun/throw/process_fire(atom/target, mob/living/user, message = TRUE, params, zone_override, bonus_spread = 0)
	add_fingerprint(user)
	if(semicd)
		return

	var/obj/item/I = to_launch
	I.forceMove(get_turf(src))
	to_launch = null
	modify_projectile(I)
	playsound(user, fire_sound, 50, 1)
	I.throw_at(target, get_throwrange(), get_throwspeed(), user, FALSE)
	add_attack_logs(user, target, "fired [I] from a [src]")
	process_chamber()

	semicd = 1
	spawn(fire_delay)
		semicd = 0
