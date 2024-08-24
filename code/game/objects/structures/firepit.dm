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


/obj/structure/firepit/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)


/obj/structure/firepit/attack_hand(mob/living/user)
	if(active)
		toggleFirepit()
	else
		return ..()


/obj/structure/firepit/attackby(obj/item/I, mob/living/user, params)
	if(user.a_intent == INTENT_HARM)
		if(active)
			I.fire_act()
		return ..()

	if(is_hot(I))
		add_fingerprint(user)
		if(active)
			to_chat(user, span_warning("The [name] is already lit!"))
			return ATTACK_CHAIN_PROCEED
		user.visible_message(
			span_notice("[user] lights [src] with [I]."),
			span_notice("You have lit [src] with [I]."),
		)
		toggleFirepit()
		lighter = user.ckey
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(active)
		I.fire_act()

	return ..()


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


/obj/structure/firepit/proc/on_entered(datum/source, mob/living/carbon/human/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!active)
		return

	Burn()

	if(ishuman(arrived) && arrived.mind)
		add_attack_logs(src, arrived, "Burned by a firepit (Lit by [lighter ? lighter : "Unknown"])", ATKLOG_ALMOSTALL)


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

