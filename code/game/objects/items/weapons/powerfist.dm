/obj/item/melee/powerfist
	name = "power-fist"
	desc = "A metal gauntlet with a piston-powered ram ontop for that extra 'ompfh' in your punch."
	icon_state = "powerfist"
	item_state = "powerfist"
	flags = CONDUCT
	attack_verb = list("whacked", "fisted", "power-punched")
	force = 12
	throwforce = 10
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 40)
	resistance_flags = FIRE_PROOF
	origin_tech = "combat=5;powerstorage=3;syndicate=1"
	var/click_delay = 1.5
	var/fisto_setting = 1
	var/gasperfist = 3
	var/obj/item/tank/internals/tank = null //Tank used for the gauntlet's piston-ram.
	var/obj/item/stock_parts/cell/high/cell = null
	var/datum/effect_system/spark_spread/spark_system

/obj/item/melee/powerfist/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/melee/powerfist/Destroy()
	QDEL_NULL(spark_system)
	QDEL_NULL(cell)
	QDEL_NULL(tank)
	return ..()

/obj/item/melee/powerfist/examine(mob/user)
	. = ..()
	if(in_range(user, src))
		if(tank)
			. += span_notice("[bicon(tank)] It has [tank] mounted onto it.")
		if(cell)
			. += span_notice("[bicon(cell)]The fist is charged for [cell.charge] W")
	else
		. += span_notice("You'll need to get closer to see any more.")


/obj/item/melee/powerfist/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank/internals))
		add_fingerprint(user)
		if(tank)
			to_chat(user, span_warning("There is already [tank] installed."))
			return ATTACK_CHAIN_PROCEED
		var/obj/item/tank/internals/new_tank = I
		if(new_tank.volume <= 3)
			to_chat(user, span_warning("The [new_tank.name] is too small for [src]."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(new_tank, src))
			return ..()
		to_chat(user, span_notice("You hook [new_tank] up to [src]."))
		tank = new_tank
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stock_parts/cell))
		add_fingerprint(user)
		if(cell)
			to_chat(user, span_warning("The [name] already has a cell."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		to_chat(user, span_notice("You insert [I] into [src]."))
		cell = I
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/melee/powerfist/attack_self(mob/user)
	. = ..()
	if(.)
		return .
	if(!cell)
		to_chat(user, span_warning("There is no cell installed."))
		return .
	to_chat(user, span_notice("You detach [cell] from [src]."))
	cell.forceMove(drop_location())
	user.put_in_hands(cell, ignore_anim = FALSE)
	cell = null


/obj/item/melee/powerfist/wrench_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	switch(fisto_setting)
		if(1)
			fisto_setting = 2
		if(2)
			fisto_setting = 3
		if(3)
			fisto_setting = 1
	to_chat(user, span_notice("You tweak [src]'s piston valve to [fisto_setting]."))


/obj/item/melee/powerfist/screwdriver_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!tank)
		to_chat(user, span_warning("There is no tank inside."))
		return .
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("You detach [tank] from [src]."))
	tank.forceMove(drop_location())
	user.put_in_hands(tank, ignore_anim = FALSE)
	tank = null


/obj/item/melee/powerfist/afterattack(atom/target, mob/living/user, proximity, params)
	if(!proximity)
		return
	if(QDELETED(target))
		return
	if(!isobj(target) && !isliving(target))
		return
	if(!tank)
		to_chat(user, span_warning("[src] can't operate without a source of gas!"))
		return
	if(tank && !tank.air_contents.remove(gasperfist * fisto_setting))
		to_chat(user, span_warning("[src]'s piston-ram lets out a weak hiss, it needs more gas!"))
		playsound(loc, 'sound/effects/refill.ogg', 50, 1)
		return

	user.do_attack_animation(target)
	new /obj/effect/temp_visual/kinetic_blast(target.loc)
	playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, 1)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, 1)

	if(isliving(target))
		var/mob/living/mobtarget = target
		var/atom/throw_target = get_edge_target_turf(mobtarget, get_dir(src, get_step_away(target, src)))
		mobtarget.throw_at(throw_target, 5 * fisto_setting, 0.5 + (fisto_setting / 2))
		mobtarget.apply_damage(force * fisto_setting, BRUTE)
		mobtarget.visible_message(span_danger("[user]'s powerfist lets out a loud hiss as [user.p_they()] punch[user.p_es()] [mobtarget.name]!"), \
			span_userdanger("You cry out in pain as [user]'s punch flings you backwards!"))
		if(cell?.charge > 0)
			mobtarget.emp_act(1)
			spark_system.start()
			if(cell.charge >= 15000)
				mobtarget.electrocute_act(cell.charge/1250, "силового кулака")
			cell.use(cell.maxcharge)
			to_chat(user, "[src] sparkles violently")
	else
		target.visible_message(span_danger("As [user]'s powerfist comes into contact with an [target.name], you see how it remain cracked at the point of impact!"))
		if(cell?.charge > 0)
			target.emp_act(1)
			cell.use(cell.maxcharge)
			spark_system.start()
			to_chat(user, "[src] sparkles violently")
	user.changeNext_move(attack_speed * click_delay)
	add_attack_logs(user, target, "POWER FISTED with [src]")
