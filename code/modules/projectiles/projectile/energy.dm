/obj/projectile/energy
	name = "energy"
	ru_names = list(
		NOMINATIVE = "энергия",
		GENITIVE = "энергии",
		DATIVE = "энергии",
		ACCUSATIVE = "энергию",
		INSTRUMENTAL = "энергией",
		PREPOSITIONAL = "энергии"
	)
	icon_state = "spark"
	damage = 0
	hitsound = 'sound/weapons/tap.ogg'
	damage_type = BURN
	flag = "energy"
	reflectability = REFLECTABILITY_ENERGY

/obj/projectile/energy/electrode
	name = "electrode"
	ru_names = list(
		NOMINATIVE = "электрод",
		GENITIVE = "электрода",
		DATIVE = "электроду",
		ACCUSATIVE = "электрод",
		INSTRUMENTAL = "электродом",
		PREPOSITIONAL = "электроде"
	)
	icon_state = "spark"
	color = "#FFFF00"
	shockbull = TRUE
	nodamage = TRUE
	confused = 2.5 SECONDS
	stamina = 20
	stutter = 8 SECONDS
	jitter = 30 SECONDS
	hitsound = 'sound/weapons/tase.ogg'
	range = 6
	//Damage will be handled on the MOB side, to prevent window shattering.
	var/tasered_duration = 8 SECONDS

/obj/projectile/energy/electrode/on_hit(var/atom/target, var/blocked = 0)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, 1, src)
		return
	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon = target
	if(HAS_TRAIT(carbon, TRAIT_HULK))
		return
	if(carbon.status_flags & CANWEAKEN)
		addtimer(CALLBACK(carbon, TYPE_PROC_REF(/mob/living/carbon, Jitter), jitter), 0.5 SECONDS)

/obj/projectile/energy/electrode/apply_effect_on_hit(mob/living/target, blocked = 0, hit_zone)
	process_tasered_effect(target)
	. = ..()

/obj/projectile/energy/electrode/proc/process_tasered_effect(mob/living/target)
	if(HAS_TRAIT(target, TRAIT_TASERED))
		if(target.getStaminaLoss() >= 40)
			target.drop_all_held_items()
			REMOVE_TRAIT(target, TRAIT_TASERED, TASER_TRAIT)
			return
	// add temprolly trait
	ADD_TRAIT(target, TRAIT_TASERED, TASER_TRAIT)
	addtimer(CALLBACK(target, TYPE_PROC_REF(/mob/living/carbon, remove_tasered_trait)), tasered_duration, flags = TIMER_UNIQUE|TIMER_OVERRIDE)

/mob/living/proc/remove_tasered_trait()
	REMOVE_TRAIT(src, TRAIT_TASERED, TASER_TRAIT)

/obj/projectile/energy/electrode/on_range() //to ensure the bolt sparks when it reaches the end of its range if it didn't hit a target yet
	do_sparks(1, 1, src)
	..()

/obj/projectile/energy/electrode/dominator
	color = LIGHT_COLOR_LIGHT_CYAN

/obj/projectile/energy/electrode/advanced
	stun = 10 SECONDS
	weaken =  10 SECONDS

/obj/projectile/energy/declone
	name = "declone"
	ru_names = list(
		NOMINATIVE = "деклонер",
		GENITIVE = "деклонера",
		DATIVE = "деклонеру",
		ACCUSATIVE = "деклонер",
		INSTRUMENTAL = "деклонером",
		PREPOSITIONAL = "деклонере"
	)
	icon_state = "declone"
	damage = 20
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	damage_type = CLONE
	irradiate = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/projectile/energy/dart
	name = "dart"
	ru_names = list(
		NOMINATIVE = "дротик",
		GENITIVE = "дротика",
		DATIVE = "дротику",
		ACCUSATIVE = "дротик",
		INSTRUMENTAL = "дротиком",
		PREPOSITIONAL = "дротике"
	)
	icon_state = "toxin"
	damage = 1
	damage_type = TOX
	weaken = 4 SECONDS
	stamina = 40
	range = 7
	shockbull = TRUE

/obj/projectile/energy/bolt
	name = "bolt"
	ru_names = list(
		NOMINATIVE = "болт",
		GENITIVE = "болта",
		DATIVE = "болту",
		ACCUSATIVE = "болт",
		INSTRUMENTAL = "болтом",
		PREPOSITIONAL = "болте"
	)
	icon_state = "cbbolt"
	damage = 15
	hitsound = 'sound/weapons/pierce.ogg'
	damage_type = TOX
	stamina = 40
	nodamage = FALSE
	weaken = 3 SECONDS
	stutter = 2 SECONDS
	shockbull = TRUE

/obj/projectile/energy/bolt/on_hit(atom/target)
	. = ..()
	var/mob/living/simple_animal/hostile/carp/carp = target
	if(istype(carp))
		carp.gib()

/obj/projectile/energy/bolt/large
	damage = 20
	weaken = 0.1 SECONDS
	stamina = 30

/obj/projectile/energy/bolttoy
	name = "bolttoy"
	ru_names = list(
		NOMINATIVE = "игрушечный болт",
		GENITIVE = "игрушечного болта",
		DATIVE = "игрушечному болту",
		ACCUSATIVE = "игрушечный болт",
		INSTRUMENTAL = "игрушечным болтом",
		PREPOSITIONAL = "игрушечном болте"
	)
	icon_state = "cbbolttoy"
	hitsound = 'sound/weapons/pierce.ogg'
	damage_type = STAMINA
	nodamage = TRUE
	weaken = 0.1 SECONDS
	stutter = 2 SECONDS
	shockbull = TRUE

/obj/projectile/energy/shock_revolver
	name = "shock bolt"
	ru_names = list(
		NOMINATIVE = "шоковый заряд",
		GENITIVE = "шокового заряда",
		DATIVE = "шоковому заряду",
		ACCUSATIVE = "шоковый заряд",
		INSTRUMENTAL = "шоковым зарядом",
		PREPOSITIONAL = "шоковом заряде"
	)
	icon_state = "purple_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	damage = 10 //A worse lasergun
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	var/zap_range = 3
	var/power = 10000

/obj/item/ammo_casing/energy/shock_revolver/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	..()
	var/obj/projectile/energy/shock_revolver/P = BB
	spawn(1)
		P.chain = P.Beam(user, icon_state = "purple_lightning", icon = 'icons/effects/effects.dmi', time = 1000, maxdistance = 30)

/obj/projectile/energy/shock_revolver/on_hit(atom/target)
	. = ..()
	tesla_zap(source = src, zap_range = zap_range, power = power, cutoff = 1e3, zap_flags = zap_flags)
	qdel(src)

/obj/projectile/energy/toxplasma
	name = "toxin bolt"
	ru_names = list(
		NOMINATIVE = "токсичный заряд",
		GENITIVE = "токсичного заряда",
		DATIVE = "токсичному заряду",
		ACCUSATIVE = "токсичный заряд",
		INSTRUMENTAL = "токсичным зарядом",
		PREPOSITIONAL = "токсичном заряде"
	)
	icon_state = "energy"
	damage = 20
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	damage_type = TOX
	irradiate = 20

/obj/projectile/energy/weak_plasma
	name = "plasma bolt"
	ru_names = list(
		NOMINATIVE = "плазменный импульс",
		GENITIVE = "плазменного импульса",
		DATIVE = "плазменному импульсу",
		ACCUSATIVE = "плазменный импульс",
		INSTRUMENTAL = "плазменным импульсом",
		PREPOSITIONAL = "плазменном импульсе"
	)
	icon_state = "plasma_light"
	damage = 20
	damage_type = BURN

/obj/projectile/energy/charged_plasma
	name = "charged plasma bolt"
	ru_names = list(
		NOMINATIVE = "заряженный плазменный импульс",
		GENITIVE = "заряженного плазменного импульса",
		DATIVE = "заряженному плазменному импульсу",
		ACCUSATIVE = "заряженный плазменный импульс",
		INSTRUMENTAL = "заряженным плазменным импульсом",
		PREPOSITIONAL = "заряженном плазменном импульсе"
	)
	icon_state = "plasma_heavy"
	damage = 50
	damage_type = BURN
	armour_penetration = 10 // It can have a little armor pen, as a treat. Bigger than it looks, energy armor is often low.
	shield_buster = TRUE
	reflectability = REFLECTABILITY_NEVER //I will let eswords block it like a normal projectile, but it's not getting reflected, and eshields will take the hit hard.
