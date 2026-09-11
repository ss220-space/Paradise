//TERROR SPIDERS ABILLITIES

//TIER 1 SPIDERS

//LURKER//

//STEALTH AKA INVISIBILLITY
/datum/action/cooldown/spell/terror_stealth
	name = "Невидимость"
	desc = "Стать полностью невидимым на короткое время."
	button_icon_state = "stealth"
	background_icon_state = "bg_terror"
	cooldown_time = 25 SECONDS
	spell_requirements = NONE
	sound = 'sound/creatures/terrorspiders/stealth.ogg'
	var/duration = 8 SECONDS

/datum/action/cooldown/spell/terror_stealth/cast(atom/cast_on)
	. = ..()
	owner.alpha = 0
	owner.visible_message(span_warning("[DECLENT_RU_CAP(owner, NOMINATIVE)] внезапно исчезает!"), span_purple("Вы теперь невидимы!"))
	addtimer(CALLBACK(src, PROC_REF(reveal), owner), duration)

/datum/action/cooldown/spell/terror_stealth/proc/reveal(mob/user)
	if(QDELETED(user))
		return

	user.alpha = initial(user.alpha)
	user.visible_message(span_warning("[DECLENT_RU_CAP(user, NOMINATIVE)] появляется из ниоткуда!"), span_purple("Вы снова видимы!"))
	playsound(user.loc, 'sound/creatures/terrorspiders/stealth_out.ogg', 150, TRUE)

//HEALER//

//LESSER HEALING
/datum/action/cooldown/spell/aoe/terror_healing
	name = "Исцеляющие феромоны"
	desc = "Выбросить в атмосферу феромоны, лечащие ваших союзников."
	button_icon_state = "heal"
	background_icon_state = "bg_terror"
	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	aoe_radius = 6
	sound = 'sound/creatures/terrorspiders/heal.ogg'
	targeting_type = /datum/aoe_targeting/terror_spiders
	var/heal_amount = 20
	var/apply_heal_buff = FALSE

/datum/action/cooldown/spell/aoe/terror_healing/cast(atom/cast_on)
	. = ..()
	owner.visible_message(span_green("[DECLENT_RU_CAP(owner, NOMINATIVE)] источает целительные феромоны!"))

/datum/action/cooldown/spell/aoe/terror_healing/cast_on_thing_in_aoe(atom/victim, atom/caster)
	. = ..()
	var/mob/living/simple_animal/hostile/poison/terror_spider/spider = victim
	spider.adjustBruteLoss(-heal_amount)
	if(apply_heal_buff)
		spider.apply_status_effect(STATUS_EFFECT_TERROR_REGEN)
	new /obj/effect/temp_visual/heal(get_turf(spider), "#00ff0d")
	new /obj/effect/temp_visual/heal(get_turf(spider), "#09ff00")
	new /obj/effect/temp_visual/heal(get_turf(spider), "#09ff00")

//TIER 2 SPIDERS

//WIDOW//

//VENOM SPIT
/datum/action/cooldown/spell/pointed/projectile/venom_spit
	name = "Кислотный плевок"
	desc = "Плюнуть кислоту, при контакте создающую дым, наполненный наркотиками и ядом."
	button_icon_state = "fake_death"
	background_icon_state = "bg_terror"
	active_msg = span_notice_alt("Вы подготавливаете свой ядовитый плевок! <b>ЛКМ, чтобы плюнуть в цель</b>.")
	deactive_msg = span_notice_alt("Вы отменяете свой плевок.")
	sound = 'sound/creatures/terrorspiders/spit2.ogg'
	cooldown_time = 25 SECONDS
	projectile_type = /obj/projectile/terrorspider/widow/venom

//SMOKE SPIT
/datum/action/cooldown/spell/pointed/projectile/smoke_spit
	name = "Плевок дымящейся кислотой"
	desc = "Плюнуть кислоту, создающую дым при контакте."
	button_icon_state = "smoke"
	background_icon_state = "bg_terror"
	active_msg = span_notice_alt("Вы подготавливаете дымный плевок! <b>ЛКМ, чтобы плюнуть в цель</b>")
	deactive_msg = span_notice_alt("Вы отменяете свой плевок.")
	sound = 'sound/creatures/terrorspiders/spit2.ogg'
	cooldown_time = 10 SECONDS
	projectile_type = /obj/projectile/terrorspider/widow/smoke

/datum/action/cooldown/spell/emplosion/terror_emp
	name = "Электро-магнитный визг"
	desc = "Издать визг, вызывающий ЭМИ."
	button_icon_state = "emp_new"
	background_icon_state = "bg_terror"
	cooldown_time = 40 SECONDS
	spell_requirements = NONE
	sound = 'sound/creatures/terrorspiders/brown_shriek.ogg'
	emp_heavy = 3
	emp_light = 2

/datum/action/cooldown/spell/emplosion/terror_emp/can_cast_spell(feedback)
	if(!isturf(owner.loc))
		return FALSE
	return ..()

//EXPLOSION
/datum/action/cooldown/spell/explosion/terror_spider
	name = "Воспламенение"
	desc = "Высвободить энергию, создавая огромное огненное кольцо."
	background_icon_state = "bg_terror"
	cooldown_time = 60 SECONDS
	spell_requirements = NONE
	sound = 'sound/creatures/terrorspiders/brown_shriek.ogg'
	ex_flame = 5

/datum/action/cooldown/spell/explosion/terror_spider/can_cast_spell(feedback)
	if(!isturf(owner.loc))
		return FALSE
	return ..()

//GUARD//

//SHIELD
/datum/action/cooldown/spell/conjure/terror_shield
	name = "Защитная мембрана"
	desc = "Создать временный органический щит для защиты вашего гнезда."
	button_icon_state = "terror_shield"
	background_icon_state = "bg_terror"
	cooldown_time = 8 SECONDS
	spell_requirements = NONE
	sound = 'sound/creatures/terrorspiders/mod_defence.ogg'
	summon_type = list(/obj/effect/forcefield/terror)
	summon_radius = 0

/obj/effect/forcefield/terror
	name = "Защитная мембрана"
	desc = "Толстая защитная мембрана, созданная Защитником Ужаса."
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
/datum/action/cooldown/spell/smoke/terror
	name = "Дымовая завеса"
	desc = "Извергнуть дым, сбивающий врагов с толку."
	background_icon_state = "bg_terror"
	cooldown_time = 8 SECONDS
	sound = 'sound/creatures/terrorspiders/attack2.ogg'
	smoke_type = /datum/effect_system/fluid_spread/smoke
	smoke_amt = 15

/datum/action/cooldown/spell/smoke/terror/can_cast_spell(feedback)
	if(!isturf(owner.loc))
		return FALSE
	return ..()

//PARALYSING SMOKE
/datum/action/cooldown/spell/terror_parasmoke
	name = "Парализующий дым"
	desc = "Извергнуть дым, парализующий врагов."
	button_icon_state = "biohazard2"
	background_icon_state = "bg_terror"
	cooldown_time = 60 SECONDS
	spell_requirements = NONE
	sound = 'sound/creatures/terrorspiders/attack2.ogg'

/datum/action/cooldown/spell/terror_parasmoke/can_cast_spell(feedback)
	if(!isturf(owner.loc))
		return FALSE
	return ..()

/datum/action/cooldown/spell/terror_parasmoke/cast(atom/cast_on)
	. = ..()
	var/datum/effect_system/fluid_spread/smoke/chem/smoke = new
	owner.create_reagents(2000)
	owner.reagents.add_reagent("neurotoxin", 1000)
	owner.reagents.add_reagent("capulettium_plus", 1000)
	smoke.set_up(range = 2, location = owner, carry = owner.reagents, silent = TRUE)
	smoke.start()

//TERRIFYING SHRIEK
/datum/action/cooldown/spell/aoe/terror_shriek
	name = "Ужасающий визг"
	desc = "Издать громкий крик, пугающий врагов."
	button_icon_state = "terror_shriek"
	background_icon_state = "bg_terror"
	cooldown_time = 60 SECONDS
	spell_requirements = NONE
	sound = 'sound/creatures/terrorspiders/white_shriek.ogg'
	targeting_type = /datum/aoe_targeting/living_non_terrors

/datum/action/cooldown/spell/aoe/terror_shriek/cast_on_thing_in_aoe(atom/victim, atom/caster)
	. = ..()
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_t = victim
		to_chat(carbon_t, span_danger("<b>Всплеск боли пронзает вашу голову и путает ваши мысли!</b>"))
		carbon_t.AdjustConfused(20 SECONDS)
		carbon_t.Slowed(2 SECONDS)
		carbon_t.Jitter(20 SECONDS)

	if(issilicon(victim))
		var/mob/living/silicon/silicon_t = victim
		to_chat(silicon_t, span_warning("<b>ОШИБКА $!(@ ОШИБКА )#^! СЕНСОРНАЯ ПЕРЕГРУЗКА \[$(!@#</b>"))
		SEND_SOUND(silicon_t, sound('sound/misc/interference.ogg'))
		playsound(silicon_t, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
		do_sparks(5, TRUE, silicon_t)
		silicon_t.Weaken(12 SECONDS)

//TIER 3

//PRINCESS//

//SHRIEK
/datum/action/cooldown/spell/aoe/terror_shriek_princess
	name = "Ужасающий визг Принцессы"
	desc = "Издать громкий визг, ослабляющий врагов."
	button_icon_state = "terror_shriek"
	background_icon_state = "bg_terror"
	cooldown_time = 60 SECONDS
	spell_requirements = NONE
	aoe_radius = 6
	sound = 'sound/creatures/terrorspiders/princess_shriek.ogg'
	targeting_type = /datum/aoe_targeting/living_non_terrors

/datum/action/cooldown/spell/aoe/terror_shriek_princess/cast_on_thing_in_aoe(atom/victim, atom/caster)
	. = ..()
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_t = victim
		to_chat(carbon_t, span_danger("<b>Всплеск боли пронзает вашу голову и путает ваши мысли!</b>"))
		carbon_t.apply_damage(30, STAMINA)
		carbon_t.Slowed(10 SECONDS)
		carbon_t.Jitter(20 SECONDS)

	if(issilicon(victim))
		var/mob/living/silicon/silicon_t = victim
		to_chat(silicon_t, span_warning("<b>ОШИБКА $!(@ ОШИБКА )#^! СЕНСОРНАЯ ПЕРЕГРУЗКА \[$(!@#</b>"))
		SEND_SOUND(silicon_t, sound('sound/misc/interference.ogg'))
		playsound(silicon_t, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
		do_sparks(5, TRUE, silicon_t)
		silicon_t.Weaken(12 SECONDS)

//PRINCE//

//SLAM
/datum/action/cooldown/spell/aoe/terror_slam
	name = "Топот"
	desc = "Ударить землю своим телом."
	button_icon_state = "slam"
	background_icon_state = "bg_terror"
	cooldown_time = 35 SECONDS
	spell_requirements = NONE
	aoe_radius = 2
	sound = 'sound/creatures/terrorspiders/prince_attack.ogg'
	targeting_type = /datum/aoe_targeting/turfs

/datum/action/cooldown/spell/aoe/terror_slam/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/turf/target_turf = victim
	for(var/mob/living/carbon/target in target_turf.contents)
		target.AdjustWeakened(2 SECONDS)
		target.adjustBruteLoss(20)
		target.Slowed(8 SECONDS)

	if(isfloorturf(target_turf))
		var/turf/simulated/floor/floor_tile = target_turf
		floor_tile.break_tile()

//MOTHER//

//JELLY PRODUCTION
/datum/action/cooldown/spell/conjure/terror_jelly
	name = "Секреция желе"
	desc = "Произвести органическое желе, лечащее пауков."
	button_icon_state = "spiderjelly"
	background_icon_state = "bg_terror"
	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	create_summon_timer = 3.3 SECONDS
	summon_radius = 0
	sound = 'sound/creatures/terrorspiders/jelly.ogg'
	summon_type = list(/obj/structure/spider/royaljelly)

//MASS HEAL
/datum/action/cooldown/spell/aoe/terror_healing/greater
	name = "Массовое исцеление"
	cooldown_time = 40 SECONDS
	aoe_radius = 7
	heal_amount = 30
	apply_heal_buff = TRUE

//TIER 4

//ALL HAIL THE QUEEN//

//SHRIEK
/datum/action/cooldown/spell/aoe/terror_shriek_queen
	name = "Ужасающий визг Королевы"
	desc = "Издать громкий визг, ослабляющий врагов."
	button_icon_state = "terror_shriek"
	background_icon_state = "bg_terror"
	cooldown_time = 45 SECONDS
	spell_requirements = NONE
	sound = 'sound/creatures/terrorspiders/queen_shriek.ogg'
	targeting_type = /datum/aoe_targeting/living_non_terrors

/datum/action/cooldown/spell/aoe/terror_shriek_queen/cast_on_thing_in_aoe(atom/victim, atom/caster)
	. = ..()
	var/turf/target_turf = victim
	for(var/mob/living/target in target_turf.contents)
		if(iscarbon(target))
			to_chat(target, span_danger("<b>Всплеск боли пронзает вашу голову и путает ваши мысли!</b>"))
			target.AdjustWeakened(2 SECONDS)
			target.apply_damage(50, STAMINA)
			target.Jitter(40 SECONDS)
			target.Slowed(14 SECONDS)

		if(issilicon(target))
			to_chat(target, span_warning("<b>ОШИБКА $!(@ ОШИБКА )#^! СЕНСОРНАЯ ПЕРЕГРУЗКА \[$(!@#</b>"))
			SEND_SOUND(target, sound('sound/misc/interference.ogg'))
			playsound(target, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
			do_sparks(5, TRUE, target)
			target.Weaken(16 SECONDS)

	for(var/obj/machinery/light/lamp in target_turf.contents)
		lamp.break_light_tube()

//KING??// one day..
