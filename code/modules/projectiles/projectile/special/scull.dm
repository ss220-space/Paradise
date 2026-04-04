/obj/projectile/skull_projectile
	name = "infected skull"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "ashen_skull"
	pass_flags = PASSTABLE | PASSGRILLE | PASSFENCE
	speed = 1
	range = 5
	damage = 5
	armour_penetration = 100
	hitsound = null

/obj/projectile/skull_projectile/get_ru_names()
	return list(
		NOMINATIVE = "заражённый череп",
		GENITIVE = "заражённого черепа",
		DATIVE = "заражённому черепу",
		ACCUSATIVE = "заражённый череп",
		INSTRUMENTAL = "заражённым черепом",
		PREPOSITIONAL = "заражённом черепе",
	)

/obj/projectile/skull_projectile/Destroy()
	var/obj/item/gun/magic/skull_gun/skull_gun = locate() in firer
	if(skull_gun)
		qdel(skull_gun)
	QDEL_NULL(chain)
	return ..()

/obj/projectile/skull_projectile/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "sendbeam", time = INFINITY, maxdistance = INFINITY)

		var/datum/antagonist/vampire/vampire = firer.mind?.has_antag_datum(/datum/antagonist/vampire)
		var/obj/effect/proc_holder/spell/vampire/self/infected_trophy/infected_trophy = locate() in firer.mind?.spell_list
		if(vampire && infected_trophy)
			range += vampire.get_trophies(INTERNAL_ORGAN_EYES)	// 15 MAX
			var/datum/spell_handler/vampire/handler = infected_trophy.custom_handler
			var/blood_cost = handler.calculate_blood_cost(vampire)
			vampire.bloodusable -= blood_cost

	return ..()

/obj/projectile/skull_projectile/on_hit(atom/target, blocked = 0, hit_zone)
	. = ..()
	var/datum/antagonist/vampire/vampire = firer?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vampire || QDELETED(vampire.subclass))
		return

	var/t_hearts = vampire.get_trophies(INTERNAL_ORGAN_HEART)
	var/applied_damage = t_hearts * 5	// 30 MAX
	var/stun_amt = (t_hearts / 2) SECONDS	// 3s. MAX
	var/effect_aoe = round(vampire.get_trophies(INTERNAL_ORGAN_EARS) / 4)	// 2 MAX

	for(var/mob/living/victim in view(effect_aoe, get_turf(target)))
		if(victim.loc == firer)	// yeah apparently mobs can see what is inside them
			continue
		if(!victim.affects_vampire(firer))
			continue
		if(!is_vampire_compatible(victim, include_IPC = TRUE))
			continue

		victim.apply_damage(applied_damage, BRUTE, BODY_ZONE_CHEST)
		victim.Stun(stun_amt)
		to_chat(victim, span_userdanger("Вы почувствовали боль в груди!"))

		if(iscarbon(victim))
			var/mob/living/carbon/c_victim = victim
			c_victim.vomit(50, VOMIT_BLOOD, 0 SECONDS)

		if(prob(10 + vampire.get_trophies(INTERNAL_ORGAN_LIVER) * 3))
			new /obj/effect/temp_visual/cult/sparks(get_turf(victim))
			var/datum/disease/vampire/D = new
			D.Contract(victim)	// grave fever
