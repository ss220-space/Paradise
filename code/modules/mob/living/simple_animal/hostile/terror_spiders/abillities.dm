//TERROR SPIDERS ABILLITIES

//TIER 1 SPIDERS

//LURKER//

//STEALTH AKA INVISIBILLITY
/obj/effect/proc_holder/spell/terror_stealth
	name = "Невидимость"
	desc = "Стать полностью невидимым на короткое время."
	action_icon_state = "stealth"
	action_background_icon_state = "bg_terror"
	base_cooldown = 25 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	sound = 'sound/creatures/terrorspiders/stealth.ogg'
	var/duration = 8 SECONDS


/obj/effect/proc_holder/spell/terror_stealth/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/terror_stealth/cast(list/targets, mob/user = usr)
	user.alpha = 0
	user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] внезапно исчезает!"), span_purple("Вы теперь невидимы!"))
	addtimer(CALLBACK(src, PROC_REF(reveal), user), duration)


/obj/effect/proc_holder/spell/terror_stealth/proc/reveal(mob/user)
	if(QDELETED(user))
		return

	user.alpha = initial(user.alpha)
	user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] появляется из ниоткуда!"), span_purple("Вы снова видимы!"))
	playsound(user.loc, 'sound/creatures/terrorspiders/stealth_out.ogg', 150, TRUE)


//HEALER//

//LESSER HEALING
/obj/effect/proc_holder/spell/aoe/terror_healing
	name = "Исцеляющие феромоны"
	desc = "Выбросить в атмосферу феромоны, лечащие ваших союзников."
	action_icon_state = "heal"
	action_background_icon_state = "bg_terror"
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	aoe_range = 6
	sound = 'sound/creatures/terrorspiders/heal.ogg'
	var/heal_amount = 20
	var/apply_heal_buff = FALSE


/obj/effect/proc_holder/spell/aoe/terror_healing/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	T.allowed_type = /mob/living/simple_animal/hostile/poison/terror_spider
	return T


/obj/effect/proc_holder/spell/aoe/terror_healing/cast(list/targets, mob/user = usr)
	for(var/mob/living/simple_animal/hostile/poison/terror_spider/spider in targets)
		visible_message(span_green("[capitalize(user.declent_ru(NOMINATIVE))] источает целительные феромоны!"))
		spider.adjustBruteLoss(-heal_amount)
		if(apply_heal_buff)
			spider.apply_status_effect(STATUS_EFFECT_TERROR_REGEN)
		new /obj/effect/temp_visual/heal(get_turf(spider), "#00ff0d")
		new /obj/effect/temp_visual/heal(get_turf(spider), "#09ff00")
		new /obj/effect/temp_visual/heal(get_turf(spider), "#09ff00")


//TIER 2 SPIDERS

//WIDOW//

//VENOM SPIT
/obj/effect/proc_holder/spell/fireball/venom_spit
	name = "Кислотный плевок"
	desc = "Плюнуть кислоту, при контакте создающую дым, наполненный наркотиками и ядом."
	invocation_type = "none"
	action_icon_state = "fake_death"
	action_background_icon_state = "bg_terror"
	selection_activated_message	= span_notice("Вы подготавливаете свой ядовитый плевок! <b>ЛКМ, чтобы плюнуть в цель</b>.")
	selection_deactivated_message = span_notice("Вы отменяете свой плевок.")
	sound = 'sound/creatures/terrorspiders/spit2.ogg'
	need_active_overlay = TRUE
	human_req = FALSE
	base_cooldown = 25 SECONDS
	fireball_type = /obj/projectile/terrorspider/widow/venom


/obj/effect/proc_holder/spell/fireball/venom_spit/update_icon_state()
	return


/obj/projectile/terrorspider/widow/venom
	name = "venom acid"
	damage = 5


/obj/projectile/terrorspider/widow/venom/on_hit(target)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
	var/turf/T = get_turf(target)
	create_reagents(1250)
	reagents.add_reagent("thc", 250)
	reagents.add_reagent("psilocybin", 250)
	reagents.add_reagent("lsd", 250)
	reagents.add_reagent("space_drugs", 250)
	reagents.add_reagent("terror_black_toxin", 250)
	smoke.set_up(range = 2, location = T, carry = reagents, silent = TRUE)
	smoke.start()

	return ..()


//SMOKE SPIT
/obj/effect/proc_holder/spell/fireball/smoke_spit
	name = "Плевок дымящейся кислотой"
	desc = "Плюнуть кислоту, создающую дым при контакте."
	invocation_type = "none"
	action_icon_state = "smoke"
	action_background_icon_state = "bg_terror"
	selection_activated_message	= span_notice("Вы подготавливаете дымный плевок! <b>ЛКМ, чтобы плюнуть в цель</b>")
	selection_deactivated_message = span_notice("Вы отменяете свой плевок.")
	sound = 'sound/creatures/terrorspiders/spit2.ogg'
	need_active_overlay = TRUE
	human_req = FALSE
	base_cooldown = 10 SECONDS
	fireball_type = /obj/projectile/terrorspider/widow/smoke


/obj/effect/proc_holder/spell/fireball/smoke_spit/update_icon_state()
	return


/obj/projectile/terrorspider/widow/smoke
	name = "smoke acid"
	damage = 5


/obj/projectile/terrorspider/widow/smoke/on_hit(target)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/smoke = new
	var/turf/T = get_turf(target)
	smoke.set_up(amount = 15, location = T)
	smoke.start()
	return ..()


//DESTROYER//

//EMP

/obj/effect/proc_holder/spell/emplosion/terror_emp
	name = "Электро-магнитный визг"
	desc = "Издать визг, вызывающий ЭМИ."
	action_icon_state = "emp_new"
	action_background_icon_state = "bg_terror"
	base_cooldown = 40 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	sound = 'sound/creatures/terrorspiders/brown_shriek.ogg'
	emp_heavy = 3
	emp_light = 2


/obj/effect/proc_holder/spell/emplosion/terror_emp/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!isturf(user.loc))
		return FALSE
	return ..()


//EXPLOSION
/obj/effect/proc_holder/spell/explosion/terror_burn
	name = "Воспламенение"
	desc = "Высвободить энергию, создавая огромное огненное кольцо."
	action_icon_state = "explosion"
	action_background_icon_state = "bg_terror"
	base_cooldown = 60 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	sound = 'sound/creatures/terrorspiders/brown_shriek.ogg'
	ex_flame = 5


/obj/effect/proc_holder/spell/explosion/terror_burn/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!isturf(user.loc))
		return FALSE
	return ..()


//GUARD//

//SHIELD
/obj/effect/proc_holder/spell/aoe/conjure/build/terror_shield
	name = "Защитная мембрана"
	desc = "Создать временный органический щит для защиты вашего гнезда."
	action_icon_state = "terror_shield"
	action_background_icon_state = "bg_terror"
	base_cooldown = 8 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	delay = 0 SECONDS
	cast_sound = 'sound/creatures/terrorspiders/mod_defence.ogg'
	summon_type = list(/obj/effect/forcefield/terror)


/obj/effect/forcefield/terror
	name = "Защитная мембрана"
	desc = "Толстая защитная мембрана, созданная Защитником Ужаса."
	icon = 'icons/effects/effects.dmi'
	icon_state = "terror_shield"
	lifetime = 16.5 SECONDS                       //max 2 shields existing at one time
	light_color = LIGHT_COLOR_PURPLE


/obj/effect/forcefield/terror/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(checkpass(mover))
		return TRUE
	var/mob/living/mob_check = get_mob_in_atom_without_warning(mover)
	return ("terrorspiders" in mob_check.faction)


//DEFILER//

//SMOKE
/obj/effect/proc_holder/spell/terror_smoke
	name = "Дымовая завеса"
	desc = "Извергнуть дым, сбивающий врагов с толку."
	action_icon_state = "smoke"
	action_background_icon_state = "bg_terror"
	base_cooldown = 8 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	sound = 'sound/creatures/terrorspiders/attack2.ogg'
	smoke_type = SMOKE_HARMLESS
	smoke_amt = 15


/obj/effect/proc_holder/spell/terror_smoke/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/terror_smoke/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!isturf(user.loc))
		return FALSE
	return ..()


//PARALYSING SMOKE
/obj/effect/proc_holder/spell/terror_parasmoke
	name = "Парализующий дым"
	desc = "Извергнуть дым, парализующий врагов."
	action_icon_state = "biohazard2"
	action_background_icon_state = "bg_terror"
	base_cooldown = 60 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	sound = 'sound/creatures/terrorspiders/attack2.ogg'


/obj/effect/proc_holder/spell/terror_parasmoke/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/terror_parasmoke/can_cast(mob/user = usr, charge_check = TRUE, show_message = FALSE)
	if(!isturf(user.loc))
		return FALSE
	return ..()


/obj/effect/proc_holder/spell/terror_parasmoke/cast(list/targets, mob/user = usr)
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
	create_reagents(2000)
	reagents.add_reagent("neurotoxin", 1000)
	reagents.add_reagent("capulettium_plus", 1000)
	smoke.set_up(range = 2, location = user, carry = reagents, silent = TRUE)
	smoke.start()


//TERRIFYING SHRIEK
/obj/effect/proc_holder/spell/aoe/terror_shriek
	name = "Ужасающий визг"
	desc = "Издать громкий крик, пугающий врагов."
	action_icon_state = "terror_shriek"
	action_background_icon_state = "bg_terror"
	base_cooldown = 60 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	aoe_range = 7
	sound = 'sound/creatures/terrorspiders/white_shriek.ogg'


/obj/effect/proc_holder/spell/aoe/terror_shriek/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	T.allowed_type = /mob/living
	return T


/obj/effect/proc_holder/spell/aoe/terror_shriek/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(iscarbon(target))
			to_chat(target, span_danger("<b>Всплеск боли пронзает вашу голову и путает ваши мысли!</b>"))
			target.AdjustConfused(20 SECONDS)
			target.Slowed(2 SECONDS)
			target.Jitter(20 SECONDS)

		if(issilicon(target))
			to_chat(target, span_warning("<b>ОШИБКА $!(@ ОШИБКА )#^! СЕНСОРНАЯ ПЕРЕГРУЗКА \[$(!@#</b>"))
			target << 'sound/misc/interference.ogg'
			playsound(target, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
			do_sparks(5, 1, target)
			target.Weaken(12 SECONDS)


//TIER 3

//PRINCESS//

//SHRIEK
/obj/effect/proc_holder/spell/aoe/terror_shriek_princess
	name = "Ужасающий визг Принцессы"
	desc = "Издать громкий визг, ослабляющий врагов."
	action_icon_state = "terror_shriek"
	action_background_icon_state = "bg_terror"
	base_cooldown = 60 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	aoe_range = 6
	sound = 'sound/creatures/terrorspiders/princess_shriek.ogg'


/obj/effect/proc_holder/spell/aoe/terror_shriek_princess/create_new_targeting()
	var/datum/spell_targeting/aoe/T = new()
	T.range = aoe_range
	T.allowed_type = /mob/living
	return T


/obj/effect/proc_holder/spell/aoe/terror_shriek_princess/cast(list/targets, mob/user = usr)
	for(var/mob/living/target in targets)
		if(iscarbon(target))
			to_chat(target, span_danger("<b>Всплеск боли пронзает вашу голову и путает ваши мысли!</b>"))
			target.apply_damage(30, STAMINA)
			target.Slowed(10 SECONDS)
			target.Jitter(20 SECONDS)

		if(issilicon(target))
			to_chat(target, span_warning("<b>ОШИБКА $!(@ ОШИБКА )#^! СЕНСОРНАЯ ПЕРЕГРУЗКА \[$(!@#</b>"))
			target << 'sound/misc/interference.ogg'
			playsound(target, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
			do_sparks(5, 1, target)
			target.Weaken(12 SECONDS)

//PRINCE//

//SLAM
/obj/effect/proc_holder/spell/aoe/terror_slam
	name = "Топот"
	desc = "Ударить землю своим телом."
	action_icon_state = "slam"
	action_background_icon_state = "bg_terror"
	base_cooldown = 35 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	aoe_range = 2
	sound = 'sound/creatures/terrorspiders/prince_attack.ogg'


/obj/effect/proc_holder/spell/aoe/terror_slam/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/terror_slam/cast(list/targets, mob/user = usr)
	for(var/turf/target_turf in targets)
		for(var/mob/living/carbon/target in target_turf.contents)
			target.AdjustWeakened(2 SECONDS)
			target.adjustBruteLoss(20)
			target.Slowed(8 SECONDS)

		if(isfloorturf(target_turf))
			var/turf/simulated/floor/floor_tile = target_turf
			floor_tile.break_tile()


//MOTHER//

//JELLY PRODUCTION
/obj/effect/proc_holder/spell/aoe/conjure/build/terror_jelly
	name = "Секреция желе"
	desc = "Произвести органическое желе, лечащее пауков."
	action_icon_state = "spiderjelly"
	action_background_icon_state = "bg_terror"
	base_cooldown = 30 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	delay = 3.3 SECONDS
	cast_sound = 'sound/creatures/terrorspiders/jelly.ogg'
	summon_type = list(/obj/structure/spider/royaljelly)


//MASS HEAL
/obj/effect/proc_holder/spell/aoe/terror_healing/greater
	name = "Массовое исцеление"
	base_cooldown = 40 SECONDS
	aoe_range = 7
	heal_amount = 30
	apply_heal_buff = TRUE


//TIER 4

//ALL HAIL THE QUEEN//

//SHRIEK
/obj/effect/proc_holder/spell/aoe/terror_shriek_queen
	name = "Ужасающий визг Королевы"
	desc = "Издать громкий визг, ослабляющий врагов."
	action_icon_state = "terror_shriek"
	action_background_icon_state = "bg_terror"
	base_cooldown = 45 SECONDS
	clothes_req = FALSE
	human_req = FALSE
	aoe_range = 7
	sound = 'sound/creatures/terrorspiders/queen_shriek.ogg'


/obj/effect/proc_holder/spell/aoe/terror_shriek_queen/create_new_targeting()
	var/datum/spell_targeting/aoe/turf/T = new()
	T.range = aoe_range
	return T


/obj/effect/proc_holder/spell/aoe/terror_shriek_queen/cast(list/targets, mob/user = usr)
	for(var/turf/target_turf in targets)
		for(var/mob/living/target in target_turf.contents)
			if(iscarbon(target))
				to_chat(target, span_danger("<b>Всплеск боли пронзает вашу голову и путает ваши мысли!</b>"))
				target.AdjustWeakened(2 SECONDS)
				target.apply_damage(50, STAMINA)
				target.Jitter(40 SECONDS)
				target.Slowed(14 SECONDS)

			if(issilicon(target))
				to_chat(target, span_warning("<b>ОШИБКА $!(@ ОШИБКА )#^! СЕНСОРНАЯ ПЕРЕГРУЗКА \[$(!@#</b>"))
				target << 'sound/misc/interference.ogg'
				playsound(target, 'sound/machines/warning-buzzer.ogg', 50, 1)
				do_sparks(5, 1, target)
				target.Weaken(16 SECONDS)

		for(var/obj/machinery/light/lamp in target_turf.contents)
			lamp.break_light_tube()

//KING??// one day..
