/obj/structure/firepit
	name = "firepit"
	desc = "Warm and toasty."
	icon = 'icons/obj/fireplace.dmi'
	icon_state = "firepit"
	density = FALSE
	anchored = TRUE
	max_integrity = 50
	var/active = FALSE
	var/lighter // Who lit the thing
	var/fire_stack_strength = 5


/obj/structure/firepit/attack_hand(mob/living/user)
	if(active)
		toggleFirepit()
	else
		..()

/obj/structure/firepit/attackby(obj/item/W, mob/living/user, params)
	if(!active)
		if(is_hot(W))
			visible_message(span_notice("[user] lights [src] with [W]."))
			toggleFirepit()
			lighter = user.ckey
		else
			return ..()
	else
		W.fire_act()


/obj/structure/firepit/proc/adjust_light()
	if(active)
		set_light(4, ,"#ffb366")
	else
		set_light_on(FALSE)


/obj/structure/firepit/update_icon_state()
	if(active)
		icon_state = "firepit-active"
	else
		icon_state = "firepit"


/obj/structure/firepit/proc/toggleFirepit()
	active = !active
	update_icon(UPDATE_ICON_STATE)
	adjust_light()


/obj/structure/firepit/extinguish()
	. = ..()
	if(active)
		toggleFirepit()

/obj/structure/firepit/fire_act(exposed_temperature, exposed_volume)
	if(!active)
		toggleFirepit()

/obj/structure/firepit/Crossed(atom/movable/AM, oldloc)
	if(active)
		Burn()
		if(ishuman(AM))
			var/mob/living/carbon/human/H = AM
			add_attack_logs(src, H, "Burned by a firepit (Lit by [lighter])", ATKLOG_ALMOSTALL)

/obj/structure/firepit/proc/Burn()
	var/turf/current_location = get_turf(src)
	current_location.hotspot_expose(1000,500,1)
	for(var/A in current_location)
		if(A == src)
			continue
		if(isobj(A))
			var/obj/O = A
			O.fire_act(1000, 500)
		else if(isliving(A))
			var/mob/living/L = A
			L.adjust_fire_stacks(fire_stack_strength)
			L.IgniteMob()
