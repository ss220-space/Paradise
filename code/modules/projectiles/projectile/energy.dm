#define ELECTRODE_BUCKLED_WEAKEN_MULTIPLIER 0.1
/obj/projectile/energy
	name = "energy"
	icon_state = "spark"
	damage = 0
	hitsound = 'sound/weapons/tap.ogg'
	damage_type = BURN
	flag = "energy"
	reflectability = REFLECTABILITY_ENERGY

/obj/projectile/energy/get_ru_names()
	return list(
		NOMINATIVE = "энергия",
		GENITIVE = "энергии",
		DATIVE = "энергии",
		ACCUSATIVE = "энергию",
		INSTRUMENTAL = "энергией",
		PREPOSITIONAL = "энергии",
	)

/obj/projectile/energy/electrode
	name = "electrode"
	color = COLOR_YELLOW
	shockbull = TRUE
	nodamage = TRUE
	confused = 2.5 SECONDS
	stamina = 20
	stutter = 8 SECONDS
	jitter = 30 SECONDS
	hitsound = 'sound/weapons/tase.ogg'
	range = 6
	tracer_type = /obj/effect/projectile/tracer/stun
	muzzle_type = /obj/effect/projectile/muzzle/stun
	impact_type = /obj/effect/projectile/impact/stun
	///Damage will be handled on the MOB side, to prevent window shattering.
	var/tasered_duration = 8 SECONDS

/obj/projectile/energy/electrode/get_ru_names()
	return list(
		NOMINATIVE = "электрод",
		GENITIVE = "электрода",
		DATIVE = "электроду",
		ACCUSATIVE = "электрод",
		INSTRUMENTAL = "электродом",
		PREPOSITIONAL = "электроде",
	)

/obj/projectile/energy/electrode/on_hit(atom/target, blocked = 0)
	. = ..()
	if(!ismob(target) || blocked >= 100) //Fully blocked by mob or collided with dense object - burst into sparks!
		do_sparks(1, TRUE, src)
		return
	if(!iscarbon(target))
		return
	var/mob/living/carbon/carbon = target
	if(HAS_TRAIT(carbon, TRAIT_HULK))
		return
	if(carbon.status_flags & CANWEAKEN)
		if(carbon.buckled && istype(carbon.buckled, /obj/vehicle/ridden))
			carbon.buckled.unbuckle_mob(carbon, TRUE)
		addtimer(CALLBACK(carbon, TYPE_PROC_REF(/mob/living/carbon, Jitter), jitter), 0.5 SECONDS)

/obj/projectile/energy/electrode/apply_effect_on_hit(mob/living/target, blocked = 0, hit_zone)
	process_tasered_effect(target)
	. = ..()

/obj/projectile/energy/electrode/proc/process_tasered_effect(mob/living/target)
	if(target.buckled)
		target.apply_effect(stamina * ELECTRODE_BUCKLED_WEAKEN_MULTIPLIER, WEAKEN)

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
	do_sparks(1, TRUE, src)
	return ..()

/obj/projectile/energy/electrode/dominator
	color = LIGHT_COLOR_LIGHT_CYAN

/obj/projectile/energy/electrode/advanced
	stun = 10 SECONDS
	weaken =  10 SECONDS

/obj/projectile/energy/declone
	name = "declone"
	icon_state = "declone"
	damage = 20
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	damage_type = CLONE
	irradiate = 10
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/projectile/energy/declone/get_ru_names()
	return list(
		NOMINATIVE = "деклонер",
		GENITIVE = "деклонера",
		DATIVE = "деклонеру",
		ACCUSATIVE = "деклонер",
		INSTRUMENTAL = "деклонером",
		PREPOSITIONAL = "деклонере",
	)

/obj/projectile/energy/dart
	name = "dart"
	icon_state = "toxin"
	damage = 1
	damage_type = TOX
	weaken = 4 SECONDS
	stamina = 40
	range = 7
	shockbull = TRUE

/obj/projectile/energy/dart/get_ru_names()
	return list(
		NOMINATIVE = "дротик",
		GENITIVE = "дротика",
		DATIVE = "дротику",
		ACCUSATIVE = "дротик",
		INSTRUMENTAL = "дротиком",
		PREPOSITIONAL = "дротике",
	)

/obj/projectile/energy/bolt
	name = "bolt"
	icon_state = "cbbolt"
	damage = 15
	hitsound = 'sound/weapons/pierce.ogg'
	damage_type = TOX
	stamina = 40
	knockdown = 0.5 SECONDS
	stutter = 2 SECONDS
	shockbull = TRUE

/obj/projectile/energy/bolt/get_ru_names()
	return list(
		NOMINATIVE = "болт",
		GENITIVE = "болта",
		DATIVE = "болту",
		ACCUSATIVE = "болт",
		INSTRUMENTAL = "болтом",
		PREPOSITIONAL = "болте",
	)

/obj/projectile/energy/bolt/on_hit(atom/target)
	. = ..()
	var/mob/living/simple_animal/hostile/carp/carp = target
	if(istype(carp))
		carp.gib()
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	var/is_robot = isrobot(living_target)
	if(is_robot || ismachineperson(living_target))
		living_target.emp_act(EMP_LIGHT)
		if(is_robot)
			return

	living_target.apply_status_effect(STATUS_EFFECT_OXYDOT)
	living_target.Confused(15 SECONDS)
	living_target.Jitter(5 SECONDS)


/obj/projectile/energy/bolt/large
	damage = 20
	stamina = 30

/obj/projectile/energy/bolttoy
	name = "bolttoy"
	icon_state = "cbbolttoy"
	hitsound = 'sound/weapons/pierce.ogg'
	damage_type = STAMINA
	nodamage = TRUE
	weaken = 0.1 SECONDS
	stutter = 2 SECONDS
	shockbull = TRUE

/obj/projectile/energy/bolttoy/get_ru_names()
	return list(
		NOMINATIVE = "игрушечный болт",
		GENITIVE = "игрушечного болта",
		DATIVE = "игрушечному болту",
		ACCUSATIVE = "игрушечный болт",
		INSTRUMENTAL = "игрушечным болтом",
		PREPOSITIONAL = "игрушечном болте",
	)

/obj/projectile/energy/shock_revolver
	name = "shock bolt"
	icon_state = "purple_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	damage = 10 //A worse lasergun
	var/zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE
	var/zap_range = 3
	var/power = 10000

/obj/projectile/energy/shock_revolver/get_ru_names()
	return list(
		NOMINATIVE = "шоковый заряд",
		GENITIVE = "шокового заряда",
		DATIVE = "шоковому заряду",
		ACCUSATIVE = "шоковый заряд",
		INSTRUMENTAL = "шоковым зарядом",
		PREPOSITIONAL = "шоковом заряде",
	)

/obj/item/ammo_casing/energy/shock_revolver/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	. = ..()
	var/obj/projectile/energy/shock_revolver/P = BB
	spawn(1)
		P.chain = P.Beam(user, icon_state = "purple_lightning", icon = 'icons/effects/effects.dmi', time = 1000, maxdistance = 30)

/obj/projectile/energy/shock_revolver/on_hit(atom/target)
	. = ..()
	tesla_zap(source = src, zap_range = zap_range, power = power, cutoff = 1e3, zap_flags = zap_flags)
	qdel(src)

/obj/projectile/energy/shock_revolver/Destroy()
	QDEL_NULL(chain)
	return ..()

/obj/projectile/energy/toxplasma
	name = "toxin bolt"
	icon_state = "energy"
	damage = 20
	hitsound = 'sound/weapons/plasma_cutter.ogg'
	damage_type = TOX
	irradiate = 20

/obj/projectile/energy/toxplasma/get_ru_names()
	return list(
		NOMINATIVE = "токсичный заряд",
		GENITIVE = "токсичного заряда",
		DATIVE = "токсичному заряду",
		ACCUSATIVE = "токсичный заряд",
		INSTRUMENTAL = "токсичным зарядом",
		PREPOSITIONAL = "токсичном заряде",
	)

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

#undef ELECTRODE_BUCKLED_WEAKEN_MULTIPLIER
