// **********************
// Other harvested materials from plants (that are not food)
// **********************

/obj/item/grown // Grown weapons
	name = "grown_weapon"
	icon = 'icons/obj/hydroponics/harvest.dmi'
	resistance_flags = FLAMMABLE
	var/obj/item/seeds/seed = null // type path, gets converted to item on Initialize(). It's safe to assume it's always a seed item.

/obj/item/grown/Initialize(mapload, obj/item/seeds/new_seed = null)
	. = ..()
	create_reagents(50)

	if(new_seed)
		seed = new_seed.Copy()
	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()
		seed.adjust_potency(50-seed.potency)

	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			T.on_new(src)

		if(istype(src, seed.product)) // no adding reagents if it is just a trash item
			seed.prepare_result(src)
		transform *= TRANSFORM_USING_VARIABLE(seed.potency, 100) + 0.5
		add_juice()

/obj/item/grown/Destroy()
	QDEL_NULL(seed)
	return ..()


/obj/item/grown/attackby(obj/item/I, mob/user, params)
	. = ..()

	if(ATTACK_CHAIN_CANCEL_CHECK(.) || !istype(I, /obj/item/plant_analyzer))
		return .
	. |= ATTACK_CHAIN_SUCCESS
	send_plant_details(user)


/obj/item/grown/proc/add_juice()
	if(reagents)
		return 1
	return 0

/obj/item/grown/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_throw_impact(src, hit_atom)


/obj/item/grown/extinguish_light(force = FALSE)
	if(!force)
		return
	if(seed.get_gene(/datum/plant_gene/trait/glow/shadow))
		return
	set_light_on(FALSE)

/obj/item/grown/proc/send_plant_details(mob/user)
	var/msg = span_info("This is \a </span><span class='name'>[src]\n")
	if(seed)
		msg += seed.get_analyzer_text()
	msg += "</span>"
	to_chat(user, msg)
	return

/obj/item/grown/attack_ghost(mob/dead/observer/user)
	if(!istype(user)) // Make sure user is actually an observer. Revenents also use attack_ghost, but do not have the toggle plant analyzer var.
		return
	if(user.plant_analyzer)
		send_plant_details(user)
