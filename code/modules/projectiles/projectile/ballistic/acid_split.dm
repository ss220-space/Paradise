/obj/projectile/bullet/acid_split
	name = "acid spit"
	icon_state = "neurotoxin"
	damage = 25
	damage_type = TOX

/obj/projectile/bullet/acid_split/get_ru_names()
	return alist(
		NOMINATIVE = "слюна с кислотой",
		GENITIVE = "слюны с кислотой",
		DATIVE = "слюне с кислотой",
		ACCUSATIVE = "слюну с кислотой",
		INSTRUMENTAL = "слюной с кислотой",
		PREPOSITIONAL = "слюне с кислотой",
	)

/obj/projectile/bullet/acid_split/prehit(atom/target)
	if(HAS_TRAIT(target, TRAIT_I_WANT_BRAINS))
		nodamage = TRUE
	if(isobj(target) || issilicon(target) || ismachineperson(target))
		damage_type = BURN
	return ..()

/obj/projectile/bullet/acid_split/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	if(blocked)
		return
	new /obj/effect/acid/alien(get_turf(target), 201, damage * 4)
	if(HAS_TRAIT(target, TRAIT_I_WANT_BRAINS))
		return
	target.acid_act(70, damage * 2)
