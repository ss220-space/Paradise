#define HERALD_TRISHOT 1
#define HERALD_DIRECTIONALSHOT 2
#define HERALD_TELESHOT 3
#define HERALD_MIRROR 4

/**
 * # Herald
 *
 * A slow-moving projectile user with a few tricks up it's sleeve.  Less unga-bunga than Colossus, with more cleverness in it's fighting style.
 * As it's health gets lower, the amount of projectiles fired per-attack increases.
 * It's attacks are as follows:
 * - Fires three projectiles in a given direction.
 * - Fires a spread in every cardinal and diagonal direction at once, then does it again after a bit.
 * - Shoots a single, golden bolt.  Wherever it lands, the herald will be teleported to the location.
 * - Spawns a mirror which reflects projectiles directly at the target.
 * Herald is a more concentrated variation of the Colossus fight, having less projectiles overall, but more focused attacks.
 */

/mob/living/simple_animal/hostile/asteroid/elite/herald
	name = "herald"
	desc = "Чудовищный зверь, поражающий угрозы и добычу смертоносными снарядами."
	ru_names = list(
		NOMINATIVE = "вестник",
		GENITIVE = "вестника",
		DATIVE = "вестнику",
		ACCUSATIVE = "вестника",
		INSTRUMENTAL = "вестником",
		PREPOSITIONAL = "вестнике"
	)
	icon_state = "herald"
	icon_living = "herald"
	icon_aggro = "herald"
	icon_dead = "herald_dying"
	icon_gib = "syndicate_gib"
	maxHealth = 1300
	health = 1300
	melee_damage_lower = 20
	melee_damage_upper = 20
	armour_penetration = 30
	light_power = 5
	light_range = 2
	light_color = "#FF0000"
	attacktext = "проповедует"
	attack_sound = 'sound/effects/hit_punch.ogg'
	throw_message = "не наносит вреда"
	speed = 1.4
	move_to_delay = 10
	mouse_opacity = MOUSE_OPACITY_ICON
	death_sound = 'sound/misc/demon_dies.ogg'
	deathmessage = "начинает дрожать и становится прозрачным..."
	loot_drop = /obj/item/clothing/accessory/necklace/herald_cloak
	tts_seed = "Abathur"

	attack_action_types = list(/datum/action/innate/elite_attack/herald_trishot,
								/datum/action/innate/elite_attack/herald_directionalshot,
								/datum/action/innate/elite_attack/herald_teleshot,
								/datum/action/innate/elite_attack/herald_mirror)

	var/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror/my_mirror = null
	var/is_mirror = FALSE

/mob/living/simple_animal/hostile/asteroid/elite/herald/death(gibbed)
	. = ..()
	if(!is_mirror)
		addtimer(CALLBACK(src, PROC_REF(become_ghost)), 0.8 SECONDS)
		if(my_mirror)
			QDEL_NULL(my_mirror)


/mob/living/simple_animal/hostile/asteroid/elite/herald/Destroy()
	if(my_mirror)
		QDEL_NULL(my_mirror)
	return ..()

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/become_ghost()
	icon_state = "herald_ghost"

/mob/living/simple_animal/hostile/asteroid/elite/herald/say(message, verb = "говор%(ит,ят)%", sanitize = TRUE, ignore_speech_problems = FALSE, ignore_atmospherics = FALSE, ignore_languages = FALSE)
	. = ..()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)

/datum/action/innate/elite_attack/herald_trishot
	name = "Тройной залп"
	button_icon_state = "herald_trishot"
	chosen_message = span_boldwarning("Теперь вы выпускаете три снаряда в выбранном направлении.")
	chosen_attack_num = HERALD_TRISHOT

/datum/action/innate/elite_attack/herald_directionalshot
	name = "Круговой залп"
	button_icon_state = "herald_directionalshot"
	chosen_message = span_boldwarning("Вы выпускаете снаряды во всех направлениях.")
	chosen_attack_num = HERALD_DIRECTIONALSHOT

/datum/action/innate/elite_attack/herald_teleshot
	name = "Телепортирующий выстрел"
	button_icon_state = "herald_teleshot"
	chosen_message = span_boldwarning("Следующий снаряд телепортирует вас к месту попадания.")
	chosen_attack_num = HERALD_TELESHOT

/datum/action/innate/elite_attack/herald_mirror
	name = "Призыв зеркала"
	button_icon_state = "herald_mirror"
	chosen_message = span_boldwarning("Вы создадите зеркало, дублирующее ваши атаки.")
	chosen_attack_num = HERALD_MIRROR

/mob/living/simple_animal/hostile/asteroid/elite/herald/OpenFire()
	if(client)
		switch(chosen_attack)
			if(HERALD_TRISHOT)
				herald_trishot(target)
				my_mirror?.herald_trishot(target)
			if(HERALD_DIRECTIONALSHOT)
				herald_directionalshot()
				my_mirror?.herald_directionalshot()
			if(HERALD_TELESHOT)
				herald_teleshot(target)
				my_mirror?.herald_teleshot(target)
			if(HERALD_MIRROR)
				herald_mirror()
		return
	var/aiattack = rand(1,4)
	switch(aiattack)
		if(HERALD_TRISHOT)
			herald_trishot(target)
			my_mirror?.herald_trishot(target)
		if(HERALD_DIRECTIONALSHOT)
			herald_directionalshot()
			my_mirror?.herald_directionalshot()
		if(HERALD_TELESHOT)
			herald_teleshot(target)
			my_mirror?.herald_teleshot(target)
		if(HERALD_MIRROR)
			herald_mirror()

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/shoot_projectile(turf/marker, set_angle, is_teleshot, is_trishot)
	var/turf/startloc = get_turf(src)
	if(!is_teleshot)
		var/obj/projectile/herald/H = new(startloc)
		H.preparePixelProjectile(marker, marker, src)
		H.firer = src
		H.damage = H.damage * dif_mult_dmg
		if(target)
			H.original = target
		H.fire(set_angle)
		if(is_trishot)
			shoot_projectile(marker, set_angle + 15, FALSE, FALSE)
			shoot_projectile(marker, set_angle - 15, FALSE, FALSE)
	else
		var/obj/projectile/herald/teleshot/H = new(startloc)
		H.preparePixelProjectile(marker, marker, src)
		H.firer = src
		H.damage = H.damage * dif_mult_dmg
		if(target)
			H.original = target
		H.fire(set_angle)

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/herald_trishot(target)
	ranged_cooldown = world.time + 3 SECONDS * revive_multiplier()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
	var/target_turf = get_turf(target)
	var/angle_to_target = get_angle(src, target_turf)
	say("Молись")
	SLEEP_CHECK_DEATH(src, 0.5 SECONDS)// no point blank instant shotgun.
	shoot_projectile(target_turf, angle_to_target, FALSE, TRUE)
	addtimer(CALLBACK(src, PROC_REF(shoot_projectile), target_turf, angle_to_target, FALSE, TRUE), 0.2 SECONDS)
	if(health < maxHealth * 0.5 && !is_mirror)
		playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 2 SECONDS, TRUE)
		addtimer(CALLBACK(src, PROC_REF(shoot_projectile), target_turf, angle_to_target, FALSE, TRUE), 1 SECONDS)
		addtimer(CALLBACK(src, PROC_REF(shoot_projectile), target_turf, angle_to_target, FALSE, TRUE), 1.2 SECONDS)

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/herald_circleshot(offset)
	var/static/list/directional_shot_angles = list(1, 45, 90, 135, 180, 225, 270, 315) //Trust me, use 1. It really doesn't like zero.
	for(var/i in directional_shot_angles)
		playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
		shoot_projectile(get_turf(src), i + offset, FALSE, FALSE)

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/unenrage()
	if(stat == DEAD || is_mirror)
		return
	icon_state = "herald"

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/herald_directionalshot()
	ranged_cooldown = world.time + 3 SECONDS * revive_multiplier()
	if(!is_mirror)
		icon_state = "herald_enraged"
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
	addtimer(CALLBACK(src, PROC_REF(herald_circleshot), 0), 0.5 SECONDS)
	if(health < maxHealth * 0.5 && !is_mirror)
		addtimer(CALLBACK(src, PROC_REF(herald_circleshot), 22.5), 1.5 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(unenrage)), 20)

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/herald_teleshot(target)
	ranged_cooldown = world.time + 3 SECONDS * revive_multiplier()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
	var/target_turf = get_turf(target)
	var/angle_to_target = get_angle(src, target_turf)
	shoot_projectile(target_turf, angle_to_target, TRUE, FALSE)

/mob/living/simple_animal/hostile/asteroid/elite/herald/proc/herald_mirror()
	ranged_cooldown = world.time + 4 SECONDS * revive_multiplier()
	playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, TRUE)
	if(my_mirror != null)
		QDEL_NULL(my_mirror)
	var/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror/new_mirror = new(loc)
	my_mirror = new_mirror
	my_mirror.my_master = src
	my_mirror.maxHealth *= dif_mult
	my_mirror.health *= dif_mult
	my_mirror.faction = faction.Copy()

/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror
	name = "herald's mirror"
	desc = "Демоническое творение магии, копирующее атаки Вестника. Логично было бы разбить его."
	ru_names = list(
		NOMINATIVE = "зеркало вестника",
		GENITIVE = "зеркала вестника",
		DATIVE = "зеркалу вестника",
		ACCUSATIVE = "зеркало вестника",
		INSTRUMENTAL = "зеркалом вестника",
		PREPOSITIONAL = "зеркале вестника"
	)
	health = 170
	maxHealth = 170
	icon_state = "herald_mirror"
	icon_aggro = "herald_mirror"
	deathmessage = "разбивается вдребезги!"
	death_sound = 'sound/effects/glassbr1.ogg'
	del_on_death = TRUE
	is_mirror = TRUE
	move_resist = MOVE_FORCE_OVERPOWERING // no dragging your mirror around
	var/mob/living/simple_animal/hostile/asteroid/elite/herald/my_master = null

/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror/Initialize(mapload)
	. = ..()
	toggle_ai(AI_OFF)
	AddElement(/datum/element/simple_flying)

/mob/living/simple_animal/hostile/asteroid/elite/herald/mirror/Destroy()
	my_master?.my_mirror = null
	my_master = null
	. = ..()

/obj/projectile/herald
	name = "death bolt"
	ru_names = list(
		NOMINATIVE = "смертоносный заряд",
		GENITIVE = "смертоносного заряда",
		DATIVE = "смертоносному заряду",
		ACCUSATIVE = "смертоносный заряд",
		INSTRUMENTAL = "смертоносным зарядом",
		PREPOSITIONAL = "смертоносном заряде"
	)
	icon_state = "chronobolt"
	damage = 15
	armour_penetration = 35
	speed = 2

/obj/projectile/herald/teleshot
	name = "golden bolt"
	ru_names = list(
		NOMINATIVE = "золотой заряд",
		GENITIVE = "золотого заряда",
		DATIVE = "золотому заряду",
		ACCUSATIVE = "золотой заряд",
		INSTRUMENTAL = "золотым зарядом",
		PREPOSITIONAL = "золотом заряде"
	)
	damage = 25
	color = rgb(255,255,102)

/obj/projectile/herald/prehit(atom/target)
	if(ismob(target) && ismob(firer))
		var/mob/living/mob_target = target
		if(mob_target.faction_check_mob(firer))
			nodamage = TRUE
			damage = 0
			return
		if(mob_target.buckled && mob_target.stat == DEAD)
			mob_target.dust() //no body cheese

/obj/projectile/herald/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ismineralturf(target))
		var/turf/simulated/mineral/M = target
		M.attempt_drill()

/obj/projectile/herald/teleshot/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(!istype(target, /mob/living/simple_animal/hostile/asteroid/elite/herald))
		firer.forceMove(get_turf(src))


//Herald's loot: Cloak of the Prophet

/obj/item/clothing/accessory/necklace/herald_cloak
	name = "cloak of the prophet"
	ru_names = list(
		NOMINATIVE = "плащ пророка",
		GENITIVE = "плаща пророка",
		DATIVE = "плащу пророка",
		ACCUSATIVE = "плащ пророка",
		INSTRUMENTAL = "плащом пророка",
		PREPOSITIONAL = "плаще пророка"
	)
	desc = "Плащ, позволяющий путешествовать через идеальное отражение мира."
	icon = 'icons/obj/lavaland/elite_trophies.dmi'
	icon_state = "herald_cloak"
	item_state = "herald_cloak"
	item_color = "herald_cloak"
	allow_duplicates = FALSE
	actions_types = list(/datum/action/item_action/accessory/herald)

/obj/item/clothing/accessory/necklace/herald_cloak/attack_self()
	if(has_suit)
		mirror_walk()

/obj/item/clothing/accessory/necklace/herald_cloak/proc/mirror_walk()
	var/found_mirror = FALSE
	var/list/mirrors_to_use = list()
	var/list/areaindex = list()
	var/obj/starting_mirror = null

	for(var/obj/i in GLOB.mirrors)
		var/turf/T = get_turf(i)
		if(!is_teleport_allowed(i.z))
			continue
		if(T.z != usr.z) //No crossing zlvls
			continue
		if(istype(i, /obj/item/shield/mirror) && !iscultist(usr)) //No teleporting to cult bases
			continue
		if(istype(i, /obj/structure/mirror))
			var/obj/structure/mirror/B = i
			if(B.broken)
				return
		var/tmpname = T.loc.name
		if(areaindex[tmpname])
			tmpname = "[tmpname] ([++areaindex[tmpname]])"
		else
			areaindex[tmpname] = 1
		mirrors_to_use[tmpname] = i
		if(get_dist(src, i) > 1)
			continue
		found_mirror = TRUE
		starting_mirror = i

	if(!found_mirror)
		to_chat(usr, span_warning("Вы недостаточно близко к рабочему зеркалу для телепортации!"))
		return
	var/input_mirror = tgui_input_list(usr, "Выберите зеркало для телепортации", "Телепортация к зеркалу", mirrors_to_use)
	var/obj/chosen = mirrors_to_use[input_mirror]
	if(chosen == null)
		return
	usr.visible_message(span_warning("[usr] начина[pluralize_ru(usr.gender,"ет","ют")] пролезать в [starting_mirror.declent_ru(ACCUSATIVE)]..."), span_notice("Вы начинаете пролезать в [starting_mirror.declent_ru(ACCUSATIVE)]..."))
	if(do_after(usr, 2 SECONDS, usr))
		var/turf/destination = get_turf(chosen)
		if(QDELETED(chosen) || !usr|| usr.incapacitated() || !chosen || (get_dist(src, starting_mirror) > 1 || destination.z != usr.z))
			return
		usr.visible_message(span_warning("[usr] пролеза[pluralize_ru(usr.gender,"ет","ют")] в [starting_mirror.declent_ru(ACCUSATIVE)], и исчеза[pluralize_ru(usr.gender,"ет","ют")] в нём!"), span_notice("Вы пролезаете в [starting_mirror.declent_ru(ACCUSATIVE)]..."))
		usr.forceMove(destination)
		usr.visible_message(span_warning("[usr] вылеза[pluralize_ru(usr.gender,"ет","ют")] из [chosen.declent_ru(ACCUSATIVE)], разбивая его!"), span_warning("Вы вылезаете из собственного отражения, разбивая зеркало!"))
		if(istype(chosen, /obj/structure/mirror))
			var/obj/structure/mirror/M = chosen
			M.obj_break("brute")
		else if(istype(chosen, /obj/item/shield/mirror))
			var/turf/T = get_turf(usr)
			new /obj/effect/temp_visual/cult/sparks(T)
			playsound(T, 'sound/effects/glassbr3.ogg', 100)
			if(isliving(chosen.loc))
				var/mob/living/shatterer = loc
				shatterer.Weaken(6 SECONDS)
			qdel(chosen)

#undef HERALD_TRISHOT
#undef HERALD_DIRECTIONALSHOT
#undef HERALD_TELESHOT
#undef HERALD_MIRROR
