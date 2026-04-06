// MARK: Ratvar shit
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
	knockdown = 2 SECONDS

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
	icon_state = "brassslug_emp" // there is no "brassshot_emp"
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

// MARK: Energy sphere shit
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
		target.Beam(src, beam_icon, 'icons/obj/weapons/guns/projectiles.dmi', time = 1 SECONDS, maxdistance = 2)

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
