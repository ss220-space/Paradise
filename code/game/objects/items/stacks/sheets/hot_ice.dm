/obj/item/stack/sheet/hot_ice
	name = "hot ice"
	icon_state = "hot-ice"
	item_state = "hot-ice"
	materials = list(MAT_PLASMA = 200)

/obj/item/stack/sheet/hot_ice/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins licking \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return FIRELOSS//dont you kids know that stuff is toxic?

/obj/item/stack/sheet/hot_ice/fire_act(exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		hot_ice_melt()

/obj/item/stack/sheet/hot_ice/attackby(obj/item/thing, mob/user, params)
	if(thing.get_temperature())
		hot_ice_melt(user)
		return ATTACK_CHAIN_BLOCKED
	. = ..()

/obj/item/stack/sheet/hot_ice/proc/hot_ice_melt(mob/user)
	var/turf/location = get_turf(src)
	atmos_spawn_air(LINDA_SPAWN_TOXINS, amount * 50, amount * 20 + T300K)
	if(user)
		message_admins("Hot Ice ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(location)]")
	log_game("Hot Ice ignited by [key_name(user)] in [AREACOORD(location)]")
	qdel(src)

