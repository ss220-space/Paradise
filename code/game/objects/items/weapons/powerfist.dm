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
			. += "<span class='notice'>[bicon(tank)] It has [tank] mounted onto it.</span>"
		if(cell)
			. += "<span class='notice'>[bicon(cell)]The fist is charged for [cell.charge] KW.</span>"
	else . += "<span class='notice'>You'll need to get closer to see any more.</span>"

/obj/item/melee/powerfist/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/tank/internals))
		if(!tank)
			var/obj/item/tank/internals/IT = W
			if(IT.volume <= 3)
				to_chat(user, "<span class='warning'>[IT] is too small for [src].</span>")
				return
			updateTank(W, 0, user)
			return
	else if(istype(W, /obj/item/stock_parts/cell))
		if(cell)
			to_chat(user, "<span class='notice'>[src] already has a cell.</span>")
		else
			if(!user.drop_transfer_item_to_loc(W, src))
				return
			cell = W
			to_chat(user, "<span class='notice'>You install a cell in [src].</span>")
			update_icon()

/obj/item/melee/powerfist/attack_self(mob/user)
	cell.loc = get_turf(src.loc)
	cell = null
	to_chat(user, "<span class='notice'>You remove a cell from [src].</span>")

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
	to_chat(user, "<span class='notice'>You tweak [src]'s piston valve to [fisto_setting].</span>")

/obj/item/melee/powerfist/screwdriver_act(mob/user, obj/item/I)
	if(!tank)
		return
	. = TRUE
	if(!I.use_tool(src, user, 0, volume = I.tool_volume))
		return
	updateTank(tank, 1, user)

/obj/item/melee/powerfist/proc/updateTank(obj/item/tank/thetank, removing = 0, mob/living/carbon/human/user)
	if(removing)
		if(!tank)
			to_chat(user, "<span class='notice'>[src] currently has no tank attached to it.</span>")
			return
		to_chat(user, "<span class='notice'>You detach [thetank] from [src].</span>")
		tank.forceMove(get_turf(user))
		user.put_in_hands(tank)
		tank = null
	if(!removing)
		if(tank)
			to_chat(user, "<span class='warning'>[src] already has a tank.</span>")
			return
		if(!user.drop_transfer_item_to_loc(thetank, src))
			return
		to_chat(user, "<span class='notice'>You hook [thetank] up to [src].</span>")
		tank = thetank
		thetank.forceMove(src)


/obj/item/melee/powerfist/attack(mob/living/target, mob/living/user)
	if(!tank)
		to_chat(user, "<span class='warning'>[src] can't operate without a source of gas!</span>")
		return
	if(tank && !tank.air_contents.remove(gasperfist * fisto_setting))
		to_chat(user, "<span class='warning'>[src]'s piston-ram lets out a weak hiss, it needs more gas!</span>")
		playsound(loc, 'sound/effects/refill.ogg', 50, 1)
		return

	user.do_attack_animation(target)

	new /obj/effect/temp_visual/kinetic_blast(target.loc)
	playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, 1)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, 1)

	target.apply_damage(force * fisto_setting, BRUTE)
	target.visible_message("<span class='danger'>[user]'s powerfist lets out a loud hiss as [user.p_they()] punch[user.p_es()] [target.name]!</span>", \
		"<span class='userdanger'>You cry out in pain as [user]'s punch flings you backwards!</span>")
	new /obj/effect/temp_visual/kinetic_blast(target.loc)
	playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, 1)
	playsound(loc, 'sound/weapons/genhit2.ogg', 50, 1)

	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))

	target.throw_at(throw_target, 5 * fisto_setting, 0.5 + (fisto_setting / 2))

	add_attack_logs(user, target, "POWER FISTED with [src]")
	user.changeNext_move(CLICK_CD_MELEE * click_delay)
	if(cell && cell.charge > 0)
		target.emp_act(1)
		spark_system.start()
		if(cell.charge >= 15000)
			target.electrocute_act(cell.charge/1250, src, 1)
		cell.charge = 0
		to_chat(user, "[src] sparkles violently")

/obj/item/melee/powerfist/afterattack(atom/movable/A, mob/user, proximity)
	if(!proximity) return
	if(!ismob(A))
		if(!tank)
			to_chat(user, "<span class='warning'>[src] can't operate without a source of gas!</span>")
			return
		if(tank && !tank.air_contents.remove(gasperfist * fisto_setting))
			to_chat(user, "<span class='warning'>[src]'s piston-ram lets out a weak hiss, it needs more gas!</span>")
			playsound(loc, 'sound/effects/refill.ogg', 50, 1)
			return
		user.do_attack_animation(A)
		if(cell.charge > 0)
			A.emp_act(1)
			cell.charge = 0
			spark_system.start()
			new /obj/effect/temp_visual/kinetic_blast(A.loc)
			playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, 1)
			playsound(loc, 'sound/weapons/genhit2.ogg', 50, 1)
			A.visible_message("<span class='danger'>As [user]'s powerfist comes into contact with an [A.name], you see how sparks fly out of it and it remain cracked at the point of impact!</span>")
		else if(!ismob(A))
			new /obj/effect/temp_visual/kinetic_blast(A.loc)
			playsound(loc, 'sound/weapons/resonator_blast.ogg', 50, 1)
			playsound(loc, 'sound/weapons/genhit2.ogg', 50, 1)
			A.visible_message("<span class='danger'>As [user]'s powerfist comes into contact with an [A.name], you see how it remain cracked at the point of impact!</span>")
