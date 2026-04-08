// MARK: Plasma
/obj/projectile/plasma
	name = "plasma blast"
	icon_state = "plasmacutter"
	damage = 5
	range = 3
	dismemberment = 20
	dismember_limbs = TRUE
	hitsound = SFX_BULLET
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/plasma_cutter
	tracer_type = /obj/effect/projectile/tracer/plasma_cutter
	impact_type = /obj/effect/projectile/impact/plasma_cutter
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	hitscan_light_intensity = 3
	hitscan_light_color_override = LIGHT_COLOR_CYAN
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = LIGHT_COLOR_CYAN
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = LIGHT_COLOR_CYAN

/obj/projectile/plasma/get_ru_names()
	return list(
		NOMINATIVE = "плазменный луч",
		GENITIVE = "плазменного луча",
		DATIVE = "плазменному лучу",
		ACCUSATIVE = "плазменный луч",
		INSTRUMENTAL = "плазменным лучом",
		PREPOSITIONAL = "плазменном луче",
	)

/obj/projectile/plasma/on_hit(atom/target, pointblank = 0)
	. = ..()
	if(ismineralturf(target))
		forcedodge = 1
		var/turf/simulated/mineral/mineral = target
		mineral.attempt_drill(firer)
	else
		forcedodge = 0

/obj/projectile/plasma/adv
	muzzle_type = /obj/effect/projectile/muzzle/plasma_cutter/adv
	tracer_type = /obj/effect/projectile/tracer/plasma_cutter/adv
	impact_type = /obj/effect/projectile/impact/plasma_cutter/adv
	damage = 7
	range = 5

/obj/projectile/plasma/adv/mega
	muzzle_type = /obj/effect/projectile/muzzle/plasma_cutter/mega
	tracer_type = /obj/effect/projectile/tracer/plasma_cutter/mega
	impact_type = /obj/effect/projectile/impact/plasma_cutter/mega
	icon_state = "plasmacutter_mega"
	hitscan_light_color_override = COLOR_FIRE_LIGHT_RED
	muzzle_flash_color_override = COLOR_FIRE_LIGHT_RED
	impact_light_color_override = COLOR_FIRE_LIGHT_RED
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	range = 7

/obj/projectile/plasma/adv/mega/on_hit(atom/target)
	if(istype(target, /turf/simulated/mineral/gibtonite))
		var/turf/simulated/mineral/gibtonite/gib = target
		gib.defuse()
	. = ..()

/obj/projectile/plasma/adv/mega/shotgun
	damage = 2
	range = 6
	dismemberment = 0

/obj/projectile/plasma/adv/mech
	damage = 10
	range = 9

/obj/projectile/plasma/shotgun
	damage = 2
	range = 4
	dismemberment = 0


// MARK: Toxin pistol
/obj/projectile/energy/toxplasma
	name = "toxin bolt"
	icon_state = "energy"
	damage = 20
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	damage_type = TOX

/obj/projectile/energy/toxplasma/get_ru_names()
	return list(
		NOMINATIVE = "токсичный заряд",
		GENITIVE = "токсичного заряда",
		DATIVE = "токсичному заряду",
		ACCUSATIVE = "токсичный заряд",
		INSTRUMENTAL = "токсичным зарядом",
		PREPOSITIONAL = "токсичном заряде",
	)

// MARK: Plasma pistol
/obj/projectile/energy/weak_plasma
	name = "plasma bolt"
	icon_state = "plasma_light"
	damage = 20

/obj/projectile/energy/weak_plasma/get_ru_names()
	return list(
		NOMINATIVE = "плазменный импульс",
		GENITIVE = "плазменного импульса",
		DATIVE = "плазменному импульсу",
		ACCUSATIVE = "плазменный импульс",
		INSTRUMENTAL = "плазменным импульсом",
		PREPOSITIONAL = "плазменном импульсе",
	)

/obj/projectile/energy/charged_plasma
	name = "charged plasma bolt"
	icon_state = "plasma_heavy"
	damage = 50
	armour_penetration = 10 // It can have a little armor pen, as a treat. Bigger than it looks, energy armor is often low.
	shield_buster = TRUE
	reflectability = REFLECTABILITY_NEVER //I will let eswords block it like a normal projectile, but it's not getting reflected, and eshields will take the hit hard.

/obj/projectile/energy/charged_plasma/get_ru_names()
	return list(
		NOMINATIVE = "заряженный плазменный импульс",
		GENITIVE = "заряженного плазменного импульса",
		DATIVE = "заряженному плазменному импульсу",
		ACCUSATIVE = "заряженный плазменный импульс",
		INSTRUMENTAL = "заряженным плазменным импульсом",
		PREPOSITIONAL = "заряженном плазменном импульсе",
	)
