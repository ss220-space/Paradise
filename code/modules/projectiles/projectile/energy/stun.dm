#define ELECTRODE_BUCKLED_WEAKEN_MULTIPLIER 0.1

/obj/projectile/energy/electrode
	name = "electrode"
	color = COLOR_YELLOW
	shockbull = TRUE
	nodamage = TRUE
	confused = 2.5 SECONDS
	stamina = 25
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

#undef ELECTRODE_BUCKLED_WEAKEN_MULTIPLIER
