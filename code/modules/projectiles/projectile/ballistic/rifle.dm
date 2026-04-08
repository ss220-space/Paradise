// MARK: 7.62x51mm - 'L6 SAW'
/obj/projectile/bullet/saw
	damage = 45
	armour_penetration = 5

/obj/projectile/bullet/saw/weak
	damage = 30
	ricochet_chance = 10

/obj/projectile/bullet/saw/bleeding
	damage = 20
	armour_penetration = 0

/obj/projectile/bullet/saw/bleeding/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.bleed(35)

/obj/projectile/bullet/saw/hollow
	damage = 60
	armour_penetration = -10
	ricochets_max = 0

/obj/projectile/bullet/saw/ap
	damage = 40
	armour_penetration = 75

/obj/projectile/bullet/saw/incen
	damage = 7
	armour_penetration = 0
	immolate = 3

/obj/projectile/bullet/saw/incen/Move(atom/newloc, direct = NONE, glide_size_override = 0, update_dir = TRUE)
	. = ..()
	var/turf/location = get_turf(src)
	if(location)
		var/obj/effect/hotspot/hotspot = new /obj/effect/hotspot/fake(location)
		hotspot.temperature = 1000
		hotspot.recolor()
		location.hotspot_expose(700, 50)

// MARK: .50 - Syndicate SR
/obj/projectile/bullet/sniper
	//speed = 0.75
	//range = 100
	damage = 70
	weaken = 4 SECONDS
	dismemberment = 50
	armour_penetration = 50
	forced_accuracy = TRUE
	var/breakthings = TRUE

/obj/projectile/bullet/sniper/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && (!ismob(target) && breakthings))
		target.ex_act(rand(EXPLODE_DEVASTATE, EXPLODE_HEAVY))

	return ..()

/obj/projectile/bullet/sniper/soporific
	armour_penetration = 0
	nodamage = TRUE
	dismemberment = 0
	weaken = 0
	breakthings = FALSE
	var/sleep_time = 40 SECONDS

/obj/projectile/bullet/sniper/soporific/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && isliving(target))
		var/mob/living/L = target
		L.SetSleeping(sleep_time)

	return ..()

/obj/projectile/bullet/sniper/explosive
	weaken = 6 SECONDS
	stun = 6 SECONDS
	damage = 85
	dismemberment = 0
	ricochets_max = 0

/obj/projectile/bullet/sniper/explosive/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && (!ismob(target, /mob/living) && breakthings))
		explosion(target, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 5, cause = "[type] fired by [key_name(firer)]")

	return ..()

/obj/projectile/bullet/sniper/haemorrhage
	armour_penetration = 15
	damage = 15
	dismemberment = 0
	weaken = 0
	breakthings = FALSE
	var/bleeding = 100

/obj/projectile/bullet/sniper/haemorrhage/on_hit(atom/target, blocked = 0, hit_zone)
	if((blocked != 100) && iscarbon(target))
		var/mob/living/carbon/C = target
		C.bleed(bleeding)

	return ..()

/obj/projectile/bullet/sniper/penetrator
	icon_state = "gauss"
	name = "penetrator round"
	damage = 60
	forcedodge = -1
	dismemberment = 0
	weaken = 0
	breakthings = FALSE
	ricochet_chance = 0

/obj/projectile/bullet/sniper/penetrator/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_RICOCHET, INNATE_TRAIT)

// MARK: .50L - Compact Syndicate SR
/obj/projectile/bullet/sniper/compact //Can't dismember, and can't break things; just deals massive damage.
	knockdown = 4 SECONDS
	weaken = 0
	breakthings = FALSE
	dismemberment = 0

// MARK: .338 - AXMC
/obj/projectile/bullet/sniper/a338
	damage = 80
	dismemberment = 0

/obj/projectile/bullet/sniper/soporific/a338

/obj/projectile/bullet/sniper/explosive/a338

/obj/projectile/bullet/sniper/haemorrhage/a338

/obj/projectile/bullet/sniper/penetrator/a338
