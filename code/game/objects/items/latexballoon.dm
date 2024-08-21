#define BALLOON_NORMAL 0
#define BALLOON_BLOW 1
#define BALLOON_BURSTED 2

/obj/item/latexballon
	name = "latex glove"
	desc = "You wanted a fiery fist o' pain, but all you got was this dumb balloon."
	icon_state = "latexballon"
	item_state = "lgloves"
	force = 0
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 7
	/// Current balloon air state
	var/state = BALLOON_NORMAL
	var/datum/gas_mixture/air_contents = null


/obj/item/latexballon/Destroy()
	QDEL_NULL(air_contents)
	return ..()


/obj/item/latexballon/update_icon_state()
	switch(state)
		if(BALLOON_NORMAL)
			icon_state = "latexballon"
			item_state = "lgloves"
		if(BALLOON_BLOW)
			icon_state = "latexballon_blow"
			item_state = "latexballon"
		if(BALLOON_BURSTED)
			icon_state = "latexballon_bursted"
			item_state = "lgloves"
	update_equipped_item(update_speedmods = FALSE)


/obj/item/latexballon/proc/blow(obj/item/tank/tank, mob/user)
	if(state == BALLOON_BURSTED)
		return
	state = BALLOON_BLOW
	update_icon(UPDATE_ICON_STATE)
	to_chat(user, span_notice("You blow up [src] with [tank]."))
	air_contents = tank.remove_air_volume(3)


/obj/item/latexballon/proc/burst()
	if(!air_contents || state != BALLOON_BLOW)
		return
	playsound(loc, 'sound/weapons/gunshots/gunshot.ogg', 100, TRUE)
	state = BALLOON_BURSTED
	update_icon(UPDATE_ICON_STATE)
	loc.assume_air(air_contents)


/obj/item/latexballon/ex_act(severity)
	burst()
	switch(severity)
		if(EXPLODE_DEVASTATE)
			qdel(src)
		if(EXPLODE_HEAVY)
			if(prob(50))
				qdel(src)


/obj/item/latexballon/bullet_act(obj/item/projectile/P)
	if(!P.nodamage)
		burst()
	return ..()


/obj/item/latexballon/temperature_expose(datum/gas_mixture/air, temperature, volume)
	..()
	if(temperature > T0C+100)
		burst()


/obj/item/latexballon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/tank))
		blow(I, user)
		return ATTACK_CHAIN_PROCEED_SUCCESS

	if(state == BALLOON_BLOW && (is_sharp(I) || is_hot(I) || is_pointed(I)))
		burst()
		return ATTACK_CHAIN_PROCEED_SUCCESS

	return ..()


#undef BALLOON_NORMAL
#undef BALLOON_BLOW
#undef BALLOON_BURSTED

