/obj/item/biocore
	name = "biocore"
	desc = "Острое биоядро с живым организмом внутри. Оно пульсирует и ответно реагирует толчками на каждые взаимодействия."
	icon = 'icons/obj/weapons/vox_guns.dmi'
	icon_state = "biocore"
	item_state = "cottoncandy_purple"
	throwforce = 20
	var/mob/living/mob_spawner_type = /mob/living/simple_animal/hostile/creature
	var/spawn_amount = 1	// сколько в одном ядре
	var/is_spin = TRUE

	// Дополнительные эффекты при втыкании в гуманоида
	var/stun = 0
	var/weaken = 5 SECONDS
	var/knockdown = 2 SECONDS
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 5 SECONDS
	var/slur = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/stamina = 30
	var/jitter = 10 SECONDS

/obj/item/biocore/throw_at(atom/target, range, speed, mob/thrower, spin, diagonals_first, datum/callback/callback, force, dodgeable)
	playsound(loc,'sound/weapons/bolathrow.ogg', 50, TRUE)
	return ..()

/obj/item/biocore/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	spawn_mobs()
	hurt_impact(hit_atom)

/obj/item/biocore/click_alt(mob/user)
	. = ..()
	spawn_mobs()

/obj/item/biocore/proc/spawn_mobs()
	var/turf/location = get_turf(src)
	var/list/cardinals = GLOB.cardinal
	for(var/i in 1 to spawn_amount)
		var/atom/movable/spawned_item = new mob_spawner_type(location)
		if(spawned_item.flags & ADMIN_SPAWNED)
			spawned_item.flags |= ADMIN_SPAWNED

		if(prob(50))
			continue

		for(var/j in 1 to rand(1, 3))
			step(spawned_item, pick(cardinals))

	do_sparks(5, TRUE, location)
	qdel(src)

/obj/item/biocore/proc/hurt_impact(atom/hit_atom)
	if(!isliving(hit_atom))
		return

	var/mob/living/hit_mob = hit_atom
	hit_mob.apply_effects(stun, weaken, knockdown, paralyze, irradiate, slur, stutter, eyeblur, drowsy, 0, stamina, jitter)

/obj/item/biocore/viscerator
	name = "biocore (viscerator)"
	spawn_amount = 3
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox

/obj/item/biocore/stamina
	name = "biocore (stakikamka)"
	spawn_amount = 3
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox/stamina

/obj/item/biocore/acid
	name = "biocore (acikikid)"
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox/acid

/obj/item/biocore/kusaka
	name = "biocore (kusakika)"
	spawn_amount = 4
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox/kusaka

/obj/item/biocore/taran
	name = "biocore (tarakikan)"
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox/taran

/obj/item/biocore/tox
	name = "biocore (toxikikic)"
	spawn_amount = 3
	mob_spawner_type = /mob/living/simple_animal/hostile/viscerator/vox/tox
