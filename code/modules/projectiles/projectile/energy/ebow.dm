// MARK: Bolt
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

// MARK: Toy Bolt
// TODO: MAKE IT /bolt/toy TYPE FOR GOD SAKE
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
