// Glass shards

/obj/item/shard
	name = "shard"
	desc = "A nasty looking shard of glass."
	icon = 'icons/obj/shards.dmi'
	icon_state = "large"
	w_class = WEIGHT_CLASS_TINY
	force = 5
	throwforce = 10
	item_state = "shard-glass"
	materials = list(MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	attack_verb = list("stabbed", "slashed", "sliced", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list("melee" = 100, "bullet" = 0, "laser" = 0, "energy" = 100, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 100)
	max_integrity = 40
	resistance_flags = ACID_PROOF
	sharp = TRUE
	var/cooldown = 0
	var/icon_prefix
	var/obj/item/stack/sheet/welded_type = /obj/item/stack/sheet/glass

/obj/item/shard/suicide_act(mob/user)
		to_chat(viewers(user), pick("<span class='danger'>[user] is slitting [user.p_their()] wrists with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>",
									"<span class='danger'>[user] is slitting [user.p_their()] throat with [src]! It looks like [user.p_theyre()] trying to commit suicide.</span>"))
		return BRUTELOSS


/obj/item/shard/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/caltrop, force)
	icon_state = pick("large", "medium", "small")
	switch(icon_state)
		if("small")
			pixel_x = rand(-12, 12)
			pixel_y = rand(-12, 12)
		if("medium")
			pixel_x = rand(-8, 8)
			pixel_y = rand(-8, 8)
		if("large")
			pixel_x = rand(-5, 5)
			pixel_y = rand(-5, 5)
	if(icon_prefix)
		icon_state = "[icon_prefix][icon_state]"
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/item/shard/afterattack(atom/movable/AM, mob/user, proximity, params)
	if(!proximity || !(src in user))
		return
	if(isturf(AM))
		return
	if(isstorage(AM))
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(!H.gloves && !HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
			var/obj/item/organ/external/affecting = H.get_organ(H.hand ? BODY_ZONE_PRECISE_L_HAND : BODY_ZONE_PRECISE_R_HAND)
			if(!affecting || affecting.is_robotic())
				return
			to_chat(H, "<span class='warning'>[src] cuts into your hand!</span>")
			H.apply_damage(force * 0.5, def_zone = affecting)


/obj/item/shard/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/lightreplacer))
		I.attackby(src, user, params)
		return ATTACK_CHAIN_BLOCKED_ALL

	if(istype(I, /obj/item/stack/sheet/cloth))
		add_fingerprint(user)
		var/obj/item/stack/sheet/cloth/cloth = I
		if(loc == user && !user.can_unEquip(src))
			return ATTACK_CHAIN_PROCEED
		if(!cloth.use(1))
			to_chat(user, span_warning("There is not enough [cloth.name]."))
			return ATTACK_CHAIN_PROCEED
		to_chat(user, span_notice("You wrap the [name] with some [cloth.name]."))
		var/obj/item/kitchen/knife/glassshiv/shiv
		if(istype(src, /obj/item/shard/plasma))
			shiv = new /obj/item/kitchen/knife/glassshiv/plasma(drop_location(), src)
		else
			shiv = new /obj/item/kitchen/knife/glassshiv(drop_location(), src)
		shiv.add_fingerprint(user)
		user.put_in_hands(shiv, ignore_anim = FALSE)
		qdel(src)
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/shard/welder_act(mob/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return
	new welded_type(drop_location())
	var/new_amount = 0
	for(var/obj/item/stack/sheet/G in drop_location())
		if(!istype(G, welded_type))
			continue
		if(G.amount >= G.max_amount)
			continue
		new_amount += G.amount
	if(new_amount > 1)
		to_chat(user, span_notice("You add the newly-formed glass to the stack. It now contains [new_amount] sheet\s."))
	qdel(src)


/obj/item/shard/proc/on_entered(datum/source, mob/living/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isliving(arrived) || arrived.incorporeal_move || (arrived.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return

	playsound(loc, 'sound/effects/glass_step.ogg', 50, TRUE)


/obj/item/shard/decompile_act(obj/item/matter_decompiler/C, mob/user)
	C.stored_comms["glass"] += 3
	qdel(src)
	return TRUE

/obj/item/shard/plasma
	name = "plasma shard"
	desc = "A shard of plasma glass. Considerably tougher then normal glass shards. Apparently not tough enough to be a window."
	force = 6
	throwforce = 11
	icon_state = "plasmalarge"
	materials = list(MAT_PLASMA = MINERAL_MATERIAL_AMOUNT * 0.5, MAT_GLASS = MINERAL_MATERIAL_AMOUNT)
	icon_prefix = "plasma"
	welded_type = /obj/item/stack/sheet/plasmaglass
