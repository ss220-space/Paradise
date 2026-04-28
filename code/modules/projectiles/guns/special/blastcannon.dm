/obj/item/gun/blastcannon
	name = "pipe gun"
	desc = "A pipe welded onto a gun stock, with a mechanical trigger. The pipe has an opening near the top, and there seems to be a spring loaded wheel in the hole."
	icon_state = "empty_blastcannon"
	var/icon_state_loaded = "loaded_blastcannon"
	item_state = "blastcannon_empty"
	force = 10
	fire_sound = 'sound/weapons/blastcannon.ogg'
	needs_permit = FALSE
	clumsy_check = FALSE
	randomspread = FALSE
	accuracy = GUN_ACCURACY_MINIMAL

	var/obj/item/transfer_valve/bomb

/obj/item/gun/blastcannon/Destroy()
	QDEL_NULL(bomb)
	return ..()

/obj/item/gun/blastcannon/attack_self(mob/user)
	if(bomb)
		bomb.forceMove(user.loc)
		user.put_in_hands(bomb)
		user.visible_message(span_warning("[user] detaches [bomb] from [src]."))
		bomb = null
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)
	return ..()

/obj/item/gun/blastcannon/update_name(updates = ALL)
	. = ..()
	if(bomb)
		name = "blast cannon"
	else
		name = initial(name)

/obj/item/gun/blastcannon/update_desc(updates = ALL)
	. = ..()
	if(bomb)
		desc = "A makeshift device used to concentrate a bomb's blast energy to a narrow wave."
	else
		desc = initial(desc)

/obj/item/gun/blastcannon/update_icon_state()
	if(bomb)
		icon_state = icon_state_loaded
	else
		icon_state = initial(icon_state)

/obj/item/gun/blastcannon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/transfer_valve))
		add_fingerprint(user)
		var/obj/item/transfer_valve/valve = I
		if(bomb)
			to_chat(user, span_warning("The [name] already has [bomb] attached."))
			return ATTACK_CHAIN_PROCEED
		if(!valve.tank_one || !valve.tank_two)
			to_chat(user, span_warning("What good would an incomplete bomb do?"))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(valve, src))
			return ..()
		user.visible_message(
			span_warning("[user] has attached [valve] to [src]."),
			span_notice("You have attached [valve] to [src]."),
		)
		bomb = valve
		update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()

/obj/item/gun/blastcannon/proc/calculate_bomb()
	if(!istype(bomb)||!istype(bomb.tank_one)||!istype(bomb.tank_two))
		return 0
	var/datum/gas_mixture/temp = new()	//directional buff.
	temp.volume = 60
	temp.merge(bomb.tank_one.air_contents.remove_ratio(1))
	temp.merge(bomb.tank_two.air_contents.remove_ratio(2))
	for(var/i in 1 to 6)
		temp.react()
	var/pressure = temp.return_pressure()
	qdel(temp)
	if(pressure < TANK_FRAGMENT_PRESSURE)
		return 0
	return (pressure / TANK_FRAGMENT_SCALE)

/obj/item/gun/blastcannon/afterattack(atom/target, mob/user, proximity_flag, list/modifiers, status)
	if((!bomb) || (!target) || (get_dist(get_turf(target), get_turf(user)) <= 2))
		return ..()
	var/power = calculate_bomb()
	QDEL_NULL(bomb)
	update_appearance(UPDATE_NAME|UPDATE_DESC|UPDATE_ICON_STATE)
	var/heavy = power * 0.2
	var/medium = power * 0.5
	var/light = power
	user.visible_message(span_danger("[user] opens [bomb] on [user.p_their()] [name] and fires a blast wave at [target]!"),span_danger("You open [bomb] on your [name] and fire a blast wave at [target]!"))
	playsound(user, SFX_EXPLOSION, 100, TRUE)
	add_attack_logs(user, target, "Blast waved with power [heavy]/[medium]/[light].", ATKLOG_MOST)
	var/obj/projectile/blastwave/BW = new(loc, heavy, medium, light)
	BW.preparePixelProjectile(target, get_turf(src), modifiers, 0)
	BW.firer = user
	BW.firer_source_atom = src
	BW.fire()
