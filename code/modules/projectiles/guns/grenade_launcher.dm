/obj/item/gun/grenadelauncher
	name = "grenade launcher"
	desc = "a terrible, terrible thing. it's really awful!"
	icon = 'icons/obj/weapons/projectile.dmi'
	icon_state = "riotgun"
	item_state = "riotgun"
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 10
	force = 5
	var/list/grenades = new/list()
	var/max_grenades = 3

	materials = list(MAT_METAL=2000)


/obj/item/gun/grenadelauncher/examine(mob/user)
	. = ..()
	if(get_dist(user, src) <= 2)
		. += span_info("Contains <b>[length(grenades)]/[max_grenades]</b> grenades.")


/obj/item/gun/grenadelauncher/attackby(obj/item/I, mob/user, params)
	if((istype(I, /obj/item/grenade)))
		add_fingerprint(user)
		if(length(grenades) >= max_grenades)
			to_chat(user, span_warning("The [name] cannot hold more grenades."))
			return ATTACK_CHAIN_PROCEED
		if(!user.drop_transfer_item_to_loc(I, src))
			return ..()
		grenades += I
		to_chat(user, span_notice("You have put [I] into [src]. In now contains <b>[length(grenades)]/[max_grenades]</b> grenades."))
		return ATTACK_CHAIN_BLOCKED_ALL

	return ..()


/obj/item/gun/grenadelauncher/afterattack(obj/target, mob/user, flag, params)
	if(target == user)
		return

	if(grenades.len)
		fire_grenade(target,user)
	else
		to_chat(user, "<span class='danger'>The grenade launcher is empty.</span>")

/obj/item/gun/grenadelauncher/proc/fire_grenade(atom/target, mob/user)
	user.visible_message("<span class='danger'>[user] fired a grenade!</span>", \
						"<span class='danger'>You fire the grenade launcher!</span>")
	var/obj/item/grenade/chem_grenade/F = grenades[1] //Now with less copypasta!
	grenades -= F
	F.loc = user.loc
	F.throw_at(target, 30, 2, user)
	add_attack_logs(user, target, "fired [F.name] from [name]")
	F.active = 1
	F.icon_state = initial(icon_state) + "_active"
	playsound(user.loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	spawn(15)
		F.prime()
