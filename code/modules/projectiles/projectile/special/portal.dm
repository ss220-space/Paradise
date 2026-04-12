// MARK: Wormhole
/obj/projectile/beam/wormhole
	name = "bluespace beam"
	icon_state = "spark"
	hitsound = SFX_SPARKS
	damage = 0
	nodamage = TRUE
	color = COLOR_BLUE_LIGHT
	tracer_type = /obj/effect/projectile/tracer/wormhole
	impact_type = /obj/effect/projectile/impact/wormhole
	muzzle_type = /obj/effect/projectile/muzzle/wormhole
	hitscan = TRUE
	var/is_orange = FALSE

/obj/projectile/beam/wormhole/get_ru_names()
	return list(
		NOMINATIVE = "блюспейс-луч",
		GENITIVE = "блюспейс-луча",
		DATIVE = "блюспейс-лучу",
		ACCUSATIVE = "блюспейс-луч",
		INSTRUMENTAL = "блюспейс-лучом",
		PREPOSITIONAL = "блюспейс-луче",
	)

/obj/projectile/beam/wormhole/orange
	name = "orange bluespace beam"
	color = "#FF6600"
	is_orange = TRUE

/obj/projectile/beam/wormhole/orange/get_ru_names()
	return list(
		NOMINATIVE = "оранжевый блюспейс-луч",
		GENITIVE = "оранжевого блюспейс-луча",
		DATIVE = "оранжевому блюспейс-лучу",
		ACCUSATIVE = "оранжевый блюспейс-луч",
		INSTRUMENTAL = "оранжевым блюспейс-лучом",
		PREPOSITIONAL = "оранжевом блюспейс-луче",
	)

/obj/projectile/beam/wormhole/on_hit(atom/target)
	if(ismob(target))
		if(is_teleport_allowed(target.z))
			var/turf/portal_destination = pick(orange(6, src))
			do_teleport(target, portal_destination)
		return ..()
	if(!firer_source_atom)
		qdel(src)
	var/obj/item/gun/energy/wormhole_projector/gun = firer_source_atom
	if(!(locate(/obj/effect/portal) in get_turf(target)))
		gun.create_portal(src, get_turf(src))

// MARK: Teleport
/obj/projectile/energy/teleport
	name = "teleportation burst"
	icon_state = "bluespace"
	nodamage = TRUE
	var/teleport_target = null

/obj/projectile/energy/teleport/get_ru_names()
	return list(
		NOMINATIVE = "вспышка телепортации",
		GENITIVE = "вспышки телепортации",
		DATIVE = "вспышке телепортации",
		ACCUSATIVE = "вспышку телепортации",
		INSTRUMENTAL = "вспышкой телепортации",
		PREPOSITIONAL = "вспышке телепортации",
	)

/obj/projectile/energy/teleport/New(loc, tele_target)
	..(loc)
	if(tele_target)
		teleport_target = tele_target

/obj/projectile/energy/teleport/on_hit(atom/target, blocked = 0)
	if(isliving(target))
		if(teleport_target)
			do_teleport(target, teleport_target, 0)//teleport what's in the tile to the beacon
		else
			do_teleport(target, target, 15) //Otherwise it just warps you off somewhere.
	add_attack_logs(firer, target, "Shot with a [type] [teleport_target ? "(Destination: [teleport_target])" : ""]")
