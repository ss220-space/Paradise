/obj/projectile/clown
	name = "snap-pop"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	nodamage = TRUE
	damage = 0

/obj/projectile/clown/get_ru_names()
	return list(
		NOMINATIVE = "щёлк-хлоп",
		GENITIVE = "щёлк-хлопа",
		DATIVE = "щёлк-хлопу",
		ACCUSATIVE = "щёлк-хлоп",
		INSTRUMENTAL = "щёлк-хлопом",
		PREPOSITIONAL = "щёлк-хлопе",
	)

/obj/projectile/clown/on_hit(atom/target, blocked, hit_zone)
	. = ..()
	if(blocked >= 100)
		return .
	do_sparks(3, TRUE, target)
	target.visible_message(span_warning("[DECLENT_RU_CAP(src, NOMINATIVE)] взрывается!"))
	playsound(target, 'sound/effects/snap.ogg', 50, TRUE)
	if(isturf(target.loc) && !target.loc.density)
		new /obj/effect/decal/cleanable/ash(target.loc)
