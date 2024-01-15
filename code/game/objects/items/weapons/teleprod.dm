/obj/item/melee/baton/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	icon_state = "teleprod_nocell"
	base_icon = "teleprod"
	item_state = "teleprod"
	origin_tech = "combat=2;bluespace=4;materials=3"


/obj/item/melee/baton/cattleprod/teleprod/attack(mob/living/target, mob/living/user)//handles making things teleport when hit
	. = ..()
	if(!turned_on)
		return

	if((CLUMSY in user.mutations) && prob(50))
		user.visible_message(
			span_danger("[user] accidentally hits [user.p_themselves()] with [src]!"),
			span_userdanger("You accidentally hit yourself with [src]!"),
		)
		deductcharge(hitcost)
		var/turf/user_turf = get_turf(user)
		do_teleport(user, user_turf, 50)//honk honk
		user.investigate_log("[key_name_log(user)] teleprodded himself from [COORD(user_turf)].", INVESTIGATE_TELEPORTATION)
		return

	if(iscarbon(target) && !target.anchored)
		var/turf/target_turf = get_turf(target)
		do_teleport(target, target_turf, 15)
		user.investigate_log("[key_name_log(user)] teleprodded [key_name_log(target)] from [COORD(target_turf)] to [COORD(target)].", INVESTIGATE_TELEPORTATION)

