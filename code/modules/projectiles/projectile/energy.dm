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
	color = "#FFFF00"
	shockbull = TRUE
	nodamage = TRUE
	confused = 2.5 SECONDS
	stamina = 20
	stutter = 8 SECONDS
	jitter = 30 SECONDS
	hitsound = 'sound/weapons/tase.ogg'
	range = 6
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
	weaken = 3 SECONDS
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

/obj/projectile/energy/bolt/large
	damage = 20
	weaken = 0.1 SECONDS
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

/obj/projectile/energy/rat
	name = "brass bullet"
	icon_state = "brassslug"
	damage = 20
	armour_penetration = 40
	hitsound = 'sound/weapons/pierce.ogg'
	damage_type = BRUTE
	flag = "bullet"
	reflectability = REFLECTABILITY_PHYSICAL

/obj/projectile/energy/rat/get_ru_names()
	return list(
		NOMINATIVE = "латунная пуля",
		GENITIVE = "латунной пули",
		DATIVE = "латунной пуле",
		ACCUSATIVE = "латунную пулю",
		INSTRUMENTAL = "латунной пулей",
		PREPOSITIONAL = "латунной пуле",
	)

/obj/projectile/energy/rat/slug
	name = "brass slug"

/obj/projectile/energy/rat/slug/get_ru_names()
	return list(
		NOMINATIVE = "латунная пуля",
		GENITIVE = "латунной пули",
		DATIVE = "латунной пуле",
		ACCUSATIVE = "латунную пулю",
		INSTRUMENTAL = "латунной пулей",
		PREPOSITIONAL = "латунной пуле",
	)

/obj/projectile/energy/rat/slug/prehit(atom/target)
	if(isclocker(target))
		damage = 0
		nodamage = TRUE
	. = ..()

/obj/projectile/energy/rat/slug/emp
	name = "brass EMP slug"
	icon_state = "brassslug_emp"
	damage = 0

/obj/projectile/energy/rat/slug/emp/get_ru_names()
	return list(
		NOMINATIVE = "латунная ЭМИ пуля",
		GENITIVE = "латунной ЭМИ пули",
		DATIVE = "латунной ЭМИ пуле",
		ACCUSATIVE = "латунную ЭМИ пулю",
		INSTRUMENTAL = "латунной ЭМИ пулей",
		PREPOSITIONAL = "латунной ЭМИ пуле",
	)

/obj/projectile/energy/rat/slug/emp/prehit(atom/target)
	if(isclocker(target))
		return . = ..()
	if(iscarbon(target))
		target.emp_act(EMP_LIGHT)
	if(ismecha(target) || issilicon(target))
		target.emp_act(EMP_HEAVY)
	new /obj/effect/temp_visual/emp/clock(get_turf(target))
	. = ..()

/obj/projectile/energy/rat/slug/heal
	name = "brass heal slug"
	icon_state = "brassslug_heal"
	damage = 25

/obj/projectile/energy/rat/slug/heal/get_ru_names()
	return list(
		NOMINATIVE = "латунная исцеляющая пуля",
		GENITIVE = "латунной исцеляющей пули",
		DATIVE = "латунной исцеляющей пуле",
		ACCUSATIVE = "латунную исцеляющую пулю",
		INSTRUMENTAL = "латунной исцеляющей пулей",
		PREPOSITIONAL = "латунной исцеляющей пуле",
	)

/obj/projectile/energy/rat/slug/heal/prehit(atom/target)
	if(isclocker(target))
		damage = 0
		nodamage = TRUE
		if(isliving(target))
			var/mob/living/to_heal = target
			to_heal.heal_overall_damage(25, 25, TRUE)
	. = ..()

/obj/projectile/energy/rat/slug/stun
	name = "brass stun slug"
	icon_state = "brassslug_stun"
	weaken = 10 SECONDS

/obj/projectile/energy/rat/slug/stun/get_ru_names()
	return list(
		NOMINATIVE = "латунная оглушающая пуля",
		GENITIVE = "латунной оглушающей пули",
		DATIVE = "латунной оглушающей пуле",
		ACCUSATIVE = "латунную оглушающую пулю",
		INSTRUMENTAL = "латунной оглушающей пулей",
		PREPOSITIONAL = "латунной оглушающей пуле",
	)

/obj/projectile/energy/rat/slug/stun/prehit(atom/target)
	if(isclocker(target))
		weaken = 0 SECONDS
	if(issilicon(target) && !isclocker(target))
		target.emp_act(EMP_HEAVY)
		new /obj/effect/temp_visual/emp/clock(get_turf(target))
	. = ..()

/obj/projectile/energy/rat/snipe
	name = "brass sniper bullet"
	icon_state = "brassshot"
	damage = 70
	armour_penetration = 60
	weaken = 2

/obj/projectile/energy/rat/snipe/get_ru_names()
	return list(
		NOMINATIVE = "латунная снайперская пуля",
		GENITIVE = "латунной снайперской пули",
		DATIVE = "латунной снайперской пуле",
		ACCUSATIVE = "латунную снайперскую пулю",
		INSTRUMENTAL = "латунной снайперской пулей",
		PREPOSITIONAL = "латунной снайперской пуле",
	)

/obj/projectile/energy/rat/snipe/prehit(atom/target)
	if(isclocker(target))
		damage = 0
		weaken = 0
		nodamage = TRUE
	. = ..()

/obj/projectile/energy/rat/snipe/emp
	name = "brass sniper EMP bullet"
	icon_state = "brassshot_emp"
	weaken = 0
	damage = 0

/obj/projectile/energy/rat/snipe/emp/get_ru_names()
	return list(
		NOMINATIVE = "латунная снайперская ЭМИ пуля",
		GENITIVE = "латунной снайперской ЭМИ пули",
		DATIVE = "латунной снайперской ЭМИ пуле",
		ACCUSATIVE = "латунную снайперскую ЭМИ пулю",
		INSTRUMENTAL = "латунной снайперской ЭМИ пулей",
		PREPOSITIONAL = "латунной снайперской ЭМИ пуле",
	)

/obj/projectile/energy/rat/snipe/emp/prehit(atom/target)
	if(isclocker(target))
		return . = ..()
	if(iscarbon(target))
		target.emp_act(EMP_LIGHT)
	if(ismecha(target) || issilicon(target))
		target.emp_act(EMP_HEAVY)
	new /obj/effect/temp_visual/emp/clock(get_turf(target))
	. = ..()

/obj/projectile/energy/rat/snipe/heal
	name = "brass sniper heal bullet"
	icon_state = "brassshot_heal"
	damage = 0
	weaken = 0

/obj/projectile/energy/rat/snipe/heal/get_ru_names()
	return list(
		NOMINATIVE = "латунная снайперская исцеляющая пуля",
		GENITIVE = "латунной снайперской исцеляющей пули",
		DATIVE = "латунной снайперской исцеляющей пуле",
		ACCUSATIVE = "латунную снайперскую исцеляющую пулю",
		INSTRUMENTAL = "латунной снайперской исцеляющей пулей",
		PREPOSITIONAL = "латунной снайперской исцеляющей пуле",
	)

/obj/projectile/energy/rat/snipe/heal/prehit(atom/target)
	if(isclocker(target))
		damage = 0
		nodamage = TRUE
		if(isliving(target))
			var/mob/living/to_heal = target
			to_heal.heal_overall_damage(50, 50, TRUE)
	. = ..()

/obj/projectile/energy/rat/snipe/stun
	name = "brass sniper stun bullet"
	icon_state = "brassshot_stun"
	damage = 0
	weaken = 15 SECONDS

/obj/projectile/energy/rat/snipe/stun/get_ru_names()
	return list(
		NOMINATIVE = "латунная снайперская оглушающая пуля",
		GENITIVE = "латунной снайперской оглушающей пули",
		DATIVE = "латунной снайперской оглушающей пуле",
		ACCUSATIVE = "латунную снайперскую оглушающую пулю",
		INSTRUMENTAL = "латунной снайперской оглушающей пулей",
		PREPOSITIONAL = "латунной снайперской оглушающей пуле",
	)

/obj/projectile/energy/rat/snipe/stun/prehit(atom/target)
	if(isclocker(target))
		weaken = 0 SECONDS
	if(issilicon(target) && !isclocker(target))
		target.emp_act(EMP_HEAVY)
		new /obj/effect/temp_visual/emp/clock(get_turf(target))
	. = ..()

/obj/projectile/energy/sphere
	name = "energy sphere"
	icon_state = "rat_sphere"
	speed = 30
	range = 1000
	forcedodge = -1
	var/beam_icon = "sphere_beam"
	var/list/bumped_in = list()
	layer = ABOVE_ALL_MOB_LAYER + 0.1

/obj/projectile/energy/sphere/get_ru_names()
	return list(
		NOMINATIVE = "энергетическая сфера",
		GENITIVE = "энергетической сферы",
		DATIVE = "энергетической сфере",
		ACCUSATIVE = "энергетическую сферу",
		INSTRUMENTAL = "энергетической сферой",
		PREPOSITIONAL = "энергетической сфере",
	)

/obj/projectile/energy/sphere/check_ricochet(atom/A)
	return isturf(A)

/obj/projectile/energy/sphere/check_ricochet_flag(atom/A)
	return TRUE

/obj/projectile/energy/sphere/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(qdel), src), 15 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(process_beam)), 1 SECONDS, TIMER_LOOP | TIMER_DELETE_ME)

/obj/projectile/energy/sphere/proc/process_beam()
	for(var/mob/living/target in range(2, loc))
		process_effects(target)

/obj/projectile/energy/sphere/proc/process_effects(mob/living/target)
		target.Beam(src, beam_icon, 'icons/obj/weapons/projectiles.dmi', time = 1 SECONDS, maxdistance = 2)

/obj/projectile/energy/sphere/attack
	damage = 75

/obj/projectile/energy/sphere/attack/process_effects(mob/living/target)
	if(isclocker(target))
		return
	target.apply_damage(30, BURN)
	. = ..()

/obj/projectile/energy/sphere/heal
	icon_state = "sphere_heal"
	beam_icon = "beam_heal"

/obj/projectile/energy/sphere/heal/process_effects(mob/living/target)
	if(!isclocker(target))
		return
	target.heal_overall_damage(0, 30)
	. = ..()

/obj/projectile/energy/sphere/heal/on_hit(atom/target, blocked, hit_zone)
	if(!isliving(target))
		return ..()
	var/mob/living/to_heal = target
	if(!isclocker(to_heal))
		return ..()
	to_heal.heal_overall_damage(0, 75)
