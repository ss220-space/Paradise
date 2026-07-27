/obj/effect/proc_holder/spell/cone/staggered/entropic_plume
	name = "Шлейф Разложения"
	desc = "Выбрасывает дезориентирующий шлейф, заставляющий врагов атаковать друг друга, \
			кратковременно ослепляет их (эффект усиливается с увеличением расстояния) и \
			отравляет (эффект уменьшается с увеличением расстояния). \
			Также распространяет ржавчину на пути шлейфа."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "entropic_plume"
	sound = 'sound/magic/forcewall.ogg'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 30 SECONDS

	invocation = "ШЛ'ЙФ Р'ЗЛ'Ж'Н!"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cone_levels = 5
	respect_density = TRUE


/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/cast(list/targets, mob/user = usr)
	. = ..()
	var/atom/cast_on = targets[1]
	new /obj/effect/temp_visual/dir_setting/entropic(get_step(cast_on, cast_on.dir), cast_on.dir)


/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/do_turf_cone_effect(turf/target_turf, mob/living/caster, level)
	if(ismob(caster))
		caster.do_rust_heretic_act(target_turf)
		return

	target_turf.rust_heretic_act()


/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/do_mob_cone_effect(mob/living/victim, atom/caster, level)
	if(victim.can_block_magic(antimagic_flags) || IS_HERETIC_OR_MONSTER(victim) || victim == caster)
		return

	victim.apply_status_effect(/datum/status_effect/amok)
	victim.apply_status_effect(/datum/status_effect/cloudstruck, 5 SECONDS)
	victim.AdjustDisgust(100)


/obj/effect/proc_holder/spell/cone/staggered/entropic_plume/calculate_cone_shape(current_level)
	if(current_level == 2)
		return 3

	if(current_level == cone_levels)
		return 3

	return 5


/obj/effect/temp_visual/dir_setting/entropic
	icon = 'icons/effects/160x160.dmi'
	icon_state = "entropic_plume"
	duration = 3 SECONDS


/obj/effect/temp_visual/dir_setting/entropic/setDir(dir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -64

		if(SOUTH)
			pixel_x = -64
			pixel_y = -128

		if(EAST)
			pixel_y = -64

		if(WEST)
			pixel_y = -64
			pixel_x = -128


/obj/effect/proc_holder/spell/fireball/rust_wave
	name = "Ковровая Дорожка"
	desc = "Направляет энергию в ваши руки, позволяя высвободить волну ржавчины."
	action_background_icon = 'icons/mob/actions/backgrounds.dmi'
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "rust_wave"

	school = SCHOOL_FORBIDDEN
	base_cooldown = 35 SECONDS

	invocation = "К'ВР'В Д'Р'ЖК"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	fireball_type = /obj/projectile/magic/aoe/rust_wave


/obj/effect/proc_holder/spell/fireball/rust_wave/update_icon_state()
	if(!action)
		return
	action.targeting_process = active
	action.UpdateButtonIcon()


/obj/projectile/magic/aoe/rust_wave
	name = "rust wave"
	gender = MALE
	icon_state = "eldritch_projectile"
	alpha = 180
	damage = 30
	damage_type = TOX
	hitsound = 'sound/weapons/punch3.ogg'
	var/list/ignored_factions = list(FACTION_HERETIC)
	range = 15
	speed = 1


/obj/projectile/magic/aoe/rust_wave/prehit(atom/target)
	if(isliving(target))
		var/mob/living/living_target = target
		for(var/ignored_faction in ignored_factions)
			if(ignored_faction in living_target.faction)
				nodamage = TRUE
				damage = 0
				break
	return ..()


/obj/projectile/magic/aoe/rust_wave/get_ru_names()
	return alist(
		NOMINATIVE = "сгусток ржавчины",
		GENITIVE = "сгустка ржавчины",
		DATIVE = "сгустку ржавчины",
		ACCUSATIVE = "сгусток ржавчины",
		INSTRUMENTAL = "сгустком ржавчины",
		PREPOSITIONAL = "сгустке ржавчины",
	)


/obj/projectile/magic/aoe/rust_wave/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	playsound(src, 'sound/items/welder.ogg', 75, TRUE)
	var/list/turflist = list()
	var/turf/T1
	turflist += get_turf(src)
	T1 = get_step(src,turn(movement_dir,90))
	turflist += T1
	turflist += get_step(T1,turn(movement_dir,90))
	T1 = get_step(src,turn(movement_dir,-90))
	turflist += T1
	turflist += get_step(T1,turn(movement_dir,-90))
	for(var/turf/T as anything in turflist)
		if(!T || prob(25))
			continue

		T.rust_heretic_act()


/obj/effect/proc_holder/spell/fireball/rust_wave/short
	name = "Малая Ковровая Дорожка"
	fireball_type = /obj/projectile/magic/aoe/rust_wave/short


/obj/projectile/magic/aoe/rust_wave/short
	range = 7
	speed = 2
