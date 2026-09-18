// An almost space vine, but without mutations.
/obj/structure/vine
	name = "vines"
	desc = "Достаточно прочная старая лиана."
	icon = 'icons/effects/spacevines.dmi'
	icon_state = "Light1"
	anchored = TRUE
	layer = SPACEVINE_LAYER
	mouse_opacity = MOUSE_OPACITY_OPAQUE
	max_integrity = 50
	cares_about_temperature = TRUE

/obj/structure/vine/Initialize(mapload)
	. = ..()
	icon_state = "Light[pick(1,3)]"
	max_integrity = pick(25, 45)

/obj/structure/vine/medium
	icon_state = "Med1"

/obj/structure/vine/medium/Initialize(mapload)
	. = ..()
	icon_state = "Med[pick(1,3)]"
	max_integrity = pick(55, 85)

/obj/structure/vine/heavy
	icon_state = "Hvy1"

/obj/structure/vine/medium/Initialize(mapload)
	. = ..()
	icon_state = "Hvy[pick(1,3)]"
	max_integrity = pick(90, 150)

/obj/structure/vine/attackby(obj/item/item, mob/user, params)
	. = ATTACK_CHAIN_PROCEED_SUCCESS
	playsound(src.loc, 'sound/effects/vegetation_hit.ogg', 25, TRUE)
	if(!item.sharp)
		return .
	var/damage = rand(10, 15)
	if(istype(item, /obj/item/kitchen/knife/combat) || istype(item, /obj/item/hatchet))
		damage = rand(20, 35)
	take_damage(damage, item.damtype, MELEE, FALSE, get_dir(user, src), item.armour_penetration)
	if(QDELETED(src))
		return ATTACK_CHAIN_BLOCKED_ALL
	return .

/obj/structure/vine/CanAllowThrough(atom/movable/mover, border_dir)
	return FALSE
