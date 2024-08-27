//improvised explosives//

/obj/item/grenade/iedcasing
	name = "improvised firebomb"
	desc = "A weak, improvised incendiary device."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "improvised_grenade"
	item_state = "flashbang"
	throw_speed = 3
	throw_range = 7
	flags = CONDUCT
	slot_flags = ITEM_SLOT_BELT
	active = 0
	det_time = 5 SECONDS
	display_timer = 0
	var/list/times

/obj/item/grenade/iedcasing/New()
	..()
	add_overlay("improvised_grenade_filled")
	add_overlay("improvised_grenade_wired")
	times = list("5" = 1 SECONDS, "-1" = 2 SECONDS, "[rand(3 SECONDS, 8 SECONDS)]" = 5 SECONDS, "[rand(6.5 SECONDS, 18 SECONDS)]" = 2 SECONDS)// "Premature, Dud, Short Fuse, Long Fuse"=[weighting value]
	det_time = text2num(pickweight(times))
	if(det_time < 0) //checking for 'duds'
		det_time = rand(3 SECONDS, 8 SECONDS)

/obj/item/grenade/iedcasing/CheckParts(list/parts_list)
	..()
	var/obj/item/reagent_containers/food/drinks/cans/can = locate() in contents
	if(can)
		can.pixel_x = 0 //Reset the sprite's position to make it consistent with the rest of the IED
		can.pixel_y = 0
		var/mutable_appearance/can_underlay = new(can)
		can_underlay.layer = FLOAT_LAYER
		can_underlay.plane = FLOAT_PLANE
		underlays += can_underlay


/obj/item/grenade/iedcasing/update_overlays()
	. = ..()



/obj/item/grenade/iedcasing/attack_self(mob/user) //
	if(!active)
		if(clown_check(user))
			to_chat(user, span_warning("You light the [name]!"))
			active = TRUE
			cut_overlay("improvised_grenade_filled")
			icon_state = initial(icon_state) + "_active"
			update_icon()
			add_fingerprint(user)
			investigate_log("[key_name_log(user)] has primed a [name] for detonation", INVESTIGATE_BOMB)
			add_attack_logs(user, src, "has primed for detonation", ATKLOG_FEW)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()
			addtimer(CALLBACK(src, PROC_REF(prime)), det_time)

/obj/item/grenade/iedcasing/prime() //Blowing that can up
	update_mob()
	explosion(loc, -1, -1, 2, flame_range = 4, cause = src)	// small explosion, plus a very large fireball.
	qdel(src)

/obj/item/grenade/iedcasing/examine(mob/user)
	. = ..()
	. += span_warning("You can't tell when it will explode!")

/obj/item/grenade/iedsatchel
	name = "plastic explosive"
	desc = "Used to put holes in specific areas without too much extra hole."
	icon_state = "improvised_satchel"
	item_state = "plastic-explosive"
	toolspeed = 1
	det_time = 8 SECONDS
	var/atom/target = null
	var/image_overlay = null
	var/planted = FALSE
	var/burned_out = FALSE

/obj/item/grenade/iedsatchel/examine(mob/user)
	. = ..()
	if(anchored)
		. += span_notice("It's secured in place")
	if(burned_out)
		. += span_notice("Looks like wick has burned out")


/obj/item/grenade/iedsatchel/update_icon_state()
	if(active)
		icon_state = "[initial(icon_state)]_active"
		return
	if(anchored || burned_out)
		icon_state = "[initial(icon_state)]_burned"
		return
	icon_state = initial(icon_state)


/obj/item/grenade/iedsatchel/afterattack(atom/T, mob/user, proximity, params)
	if(!proximity)
		return
	if(!iswallturf(T) && !istype(T, /obj/machinery/door/airlock))
		return
	to_chat(user, span_notice("You start planting the [src]."))

	if(do_after(user, 5 SECONDS * toolspeed, T, category = DA_CAT_TOOL))
		if(!user.drop_transfer_item_to_loc(src, user.loc))
			return
		set_anchored(TRUE)
		target = T

		pixel_w = (T.x - x)*32
		pixel_z = (T.y - y)*32
		layer = ABOVE_OBJ_LAYER

		add_game_logs("planted [src] on [T.name] at [T.loc]", user)
		update_icon(UPDATE_ICON_STATE)
		to_chat(user, span_notice("You plant the [src]."))

/obj/item/grenade/iedsatchel/attack_hand(mob/user)
	if(anchored)
		update_icon(UPDATE_ICON_STATE)
		return
	..()

/obj/item/grenade/iedsatchel/attack_self(mob/user)
	if(burned_out)
		to_chat(user, span_notice("Without a fuse, it is impossible to trigger [src]. It looks like the wick can be made out a few wires."))
		return
	to_chat(user, span_notice("You tickled a makeshift wick made of wires, it looks like it needs to be set on fire."))


/obj/item/grenade/iedsatchel/wirecutter_act(mob/living/user, obj/item/I)
	if(!anchored)
		return FALSE
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	to_chat(user, span_notice("You unattached [src]."))
	pixel_w = 0
	pixel_z = 0
	layer = TURF_LAYER
	set_anchored(FALSE)
	target = null
	update_icon(UPDATE_ICON_STATE)


/obj/item/grenade/iedsatchel/attackby(obj/item/I, mob/user, params)
	if(active)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(is_hot(I))
		trigger(user)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(iscoil(I))
		add_fingerprint(user)
		if(!burned_out)
			to_chat(user, span_notice("[src] already has a wick"))
			return ATTACK_CHAIN_PROCEED
		if(I.use(5))
			to_chat(user, span_notice("You need at least five lengths of cable to make a wick."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You made a new wick from the cable"))
		burned_out = FALSE
		update_icon(UPDATE_ICON_STATE)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


/obj/item/grenade/iedsatchel/proc/trigger(mob/user)
	if(burned_out)
		to_chat(user, span_notice("There is no wick to ignite [src]."))
		return
	var/N = roll(11) - 1
	active = TRUE
	to_chat(user, span_danger("You ignite wires on [src]!"))
	update_icon(UPDATE_ICON_STATE)
	add_game_logs("Triggered [name] at [COORD(target)]", user)
	if(N <= 3)
		active = 1
		addtimer(CALLBACK(src, PROC_REF(prime_fake)), det_time, TRUE)
		return
	if(N <= 8)
		active = 1
		addtimer(CALLBACK(src, PROC_REF(prime)), det_time)
		return
	prime()

/obj/item/grenade/iedsatchel/proc/prime_fake()
	visible_message(span_notice("The wires on [src] burned out, but nothing happened."))
	active = FALSE
	burned_out = TRUE
	update_icon(UPDATE_ICON_STATE)

/obj/item/grenade/iedsatchel/prime()
	update_mob()
	explosion(loc, -1, -1, 2, flame_range = 4, cause = src)
	if(target)
		if(istype(target, /obj/machinery/door/airlock))
			var/obj/machinery/door/airlock/T = target
			if((T.obj_integrity - 300) <= 0)
				qdel(T)
			else
				T.take_damage(300)
		if(iswallturf(target))
			var/turf/simulated/wall/T = target
			if((T.damage + 300) >= T.damage_cap)
				T.dismantle_wall(1, 1)
			else
				T.take_damage(300)
	qdel(src)
