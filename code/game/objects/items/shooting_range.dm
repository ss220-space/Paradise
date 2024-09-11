// Targets, the things that actually get shot!
/obj/item/target
	name = "shooting target"
	desc = "A shooting target."
	icon = 'icons/obj/objects.dmi'
	icon_state = "target_h"
	density = FALSE
	/// Lazylist of all bullet holes overlays
	var/list/bullet_holes
	/// The stake we acre currently placed on
	var/obj/structure/target_stake/stake
	/// Basically our intergrity
	var/hp = 1800
	/// Recursion avoidance
	var/currently_moving = FALSE


/obj/item/target/Destroy()
	stake = null
	LAZYNULL(bullet_holes)
	return ..()


/obj/item/target/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	if(currently_moving)
		return FALSE
	. = ..()
	// Move the stake along with the pinned target
	if(!stake)
		return .
	stake.currently_moving = TRUE
	. = stake.Move(newloc, direct, glide_size)
	stake?.set_glide_size(glide_size)
	stake?.currently_moving = FALSE
	if(!. && loc && stake && stake.loc != loc)
		stake.forceMove(loc)


/obj/item/target/welder_act(mob/living/user, obj/item/I)
	. = TRUE
	if(!I.use_tool(src, user, volume = I.tool_volume))
		return .
	LAZYNULL(bullet_holes)
	update_icon(UPDATE_OVERLAYS)
	to_chat(user, span_notice("You slice off [src]'s uneven chunks of aluminium and scorch marks."))


/obj/item/target/attack_hand(mob/user)
	if(!stake)
		return ..()

	to_chat(user, span_notice("You take [src] out of [stake]."))
	add_fingerprint(user)
	stake.add_fingerprint(user)
	stake.set_density(TRUE)
	set_density(initial(density))
	layer = initial(layer)
	user.put_in_hands(src, ignore_anim = FALSE)
	stake.pinned_target = null
	stake = null


/obj/item/target/syndicate
	icon_state = "target_s"
	desc = "A shooting target that looks like a syndicate scum."
	hp = 2600 // i guess syndie targets are sturdier?

/obj/item/target/alien
	icon_state = "target_q"
	desc = "A shooting target that looks like a xenomorphic alien."
	hp = 2350 // alium onest too kinda


/obj/item/target/update_overlays()
	return LAZYCOPY(bullet_holes)


#define DECALTYPE_SCORCH 1
#define DECALTYPE_BULLET 2

/obj/item/target/bullet_act(obj/item/projectile/P)
	var/p_x = P.p_x + pick(0,0,0,0,0,-1,1) // really ugly way of coding "sometimes offset P.p_x!"
	var/p_y = P.p_y + pick(0,0,0,0,0,-1,1)
	var/decaltype = DECALTYPE_SCORCH
	if(istype(P, /obj/item/projectile/bullet))
		decaltype = DECALTYPE_BULLET

	var/icon/source_icon = icon(icon, icon_state)
	if(LAZYLEN(bullet_holes) <= 35 && source_icon.GetPixel(p_x, p_y)) // if the located pixel isn't blank (null)
		hp -= P.damage
		if(hp <= 0)
			visible_message(span_danger("[src] breaks into tiny pieces and collapses!"))
			qdel(src)
			return
		var/mutable_appearance/bullet_hole = mutable_appearance('icons/effects/effects.dmi', "scorch", OBJ_LAYER + 0.5)
		bullet_hole.pixel_w = p_x - 1 //offset correction
		bullet_hole.pixel_z = p_y - 1
		if(decaltype == DECALTYPE_SCORCH)
			if(P.damage >= 20 || istype(P, /obj/item/projectile/beam/practice))
				bullet_hole.setDir(pick(NORTH,SOUTH,EAST,WEST))// random scorch design. light_scorch does not have different directions
			else
				bullet_hole.icon_state = "light_scorch"
		else
			bullet_hole.icon_state = "dent"

		LAZYADD(bullet_holes, bullet_hole)
		update_icon(UPDATE_OVERLAYS)
		return

	return -1 // the bullet/projectile goes through the target! Ie, you missed

#undef DECALTYPE_SCORCH
#undef DECALTYPE_BULLET
