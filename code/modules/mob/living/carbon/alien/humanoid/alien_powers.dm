/datum/action/innate/alien
	background_icon_state = "bg_alien"

/datum/action/innate/alien/thermal_toogle
	name = "Переключить термальное зрение"
	button_icon_state = "thermal"

/datum/action/innate/alien/thermal_toogle/Activate()
	var/mob/living/carbon/alien/host = owner

	if(!IsAvailable())
		return

	if(!host.nightvision_enabled)
		host.nightvision = 8
		host.lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
		host.nightvision_enabled = TRUE
		host.balloon_alert(host, "термальное")
		host.hud_used.nightvisionicon.icon_state = "nightvision1"
		host.update_sight()
		return

	if(host.nightvision_enabled)
		host.nightvision = initial(host.nightvision)
		host.lighting_alpha = initial(host.lighting_alpha)
		host.nightvision_enabled = FALSE
		host.balloon_alert(host, "обычное")
		host.hud_used.nightvisionicon.icon_state = "nightvision0"
		host.update_sight()
		return

/proc/playsound_xenobuild(object)
	var/turf/object_turf = get_turf(object)

	if(!object_turf)
		return

	playsound(object_turf, pick('sound/creatures/alien/xeno_resin_build4.ogg', \
								'sound/creatures/alien/xeno_resin_build5.ogg'), 30)

/datum/action/innate/alien/toggle_queen_arrow
	name = "Расположение королевы"
	desc = "Переключить указатель направления к Королеве"
	button_icon_state = "alien_queen_arrow"
	var/atom/movable/screen/navigate_arrow/arrow

/datum/action/innate/alien/toggle_queen_arrow/Activate()
	if(!IsAvailable())
		return
	var/mob/living/carbon/alien/host = owner
	if(!host.client)
		return

	if(arrow)
		host.client.screen -= arrow
		qdel(arrow)
		arrow = null
		return

	var/mob/living/carbon/alien/humanoid/queen/Q = locate(/mob/living/carbon/alien/humanoid/queen) in GLOB.aliens_list
	if(!Q || Q.stat == DEAD)
		host.balloon_alert(host, "королевы нет!")
		return

	arrow = new
	host.client.screen += arrow
	update_arrow()

/datum/action/innate/alien/toggle_queen_arrow/proc/update_arrow()
	if(!arrow || !owner?.client)
		return
	var/mob/living/carbon/alien/humanoid/queen/Q = locate(/mob/living/carbon/alien/humanoid/queen) in GLOB.aliens_list
	if(!Q || Q.stat == DEAD)
		owner.client.screen -= arrow
		qdel(arrow)
		arrow = null
		owner.balloon_alert(owner, "королева мертва!")
		return
	arrow.start_effect(get_turf(Q), "#947BA1", owner)

/datum/action/innate/alien/toggle_queen_arrow/Destroy()
	if(arrow)
		owner?.client?.screen -= arrow
		QDEL_NULL(arrow)
	return ..()

/datum/action/cooldown/spell/aoe/terror_shriek_princess/xeno
	name = "Крик Королевы"
	desc = "Издать пронзительный крик, ослабляющий и замедляющий врагов вокруг."
	button_icon_state = "terror_shriek"
	background_icon_state = "bg_terror"
	aoe_radius = 8
	cooldown_time = 50 SECONDS
	sound = 'sound/creatures/alien/alien_queen_screech.ogg'
	targeting_type = /datum/aoe_targeting/living_non_alien
	invocation_type = INVOCATION_NONE

/datum/action/cooldown/spell/aoe/terror_shriek_princess/xeno/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/alien/humanoid/queen/queen = src.owner
	if(!queen)
		return
	var/mutable_appearance/shriek = mutable_appearance('icons/effects/64x64.dmi', "shriek_waves", FLOAT_LAYER)
	shriek.pixel_x = -28
	queen.shriek_wave_overlay = shriek
	queen.add_overlay(shriek)
	addtimer(CALLBACK(src, PROC_REF(cleanup_shriek_wave), queen), 2.5 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)

/datum/action/cooldown/spell/aoe/terror_shriek_princess/xeno/proc/cleanup_shriek_wave(mob/living/carbon/alien/humanoid/queen/queen)
	if(!queen.shriek_wave_overlay)
		return

	queen.cut_overlay(queen.shriek_wave_overlay)
	queen.shriek_wave_overlay = null

/datum/action/cooldown/spell/aoe/terror_shriek_princess/xeno/cast_on_thing_in_aoe(atom/victim, atom/caster)
	. = ..()
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		carbon_victim.Slowed(12 SECONDS)
		carbon_victim.Weaken(4 SECONDS)
		carbon_victim.apply_damage(30, STAMINA)
		carbon_victim.Jitter(20 SECONDS)
		to_chat(carbon_victim, span_danger("<b>Всплеск боли пронзает вашу голову и путает ваши мысли!</b>"))

	if(issilicon(victim))
		var/mob/living/silicon/silicon_victim = victim
		to_chat(silicon_victim, span_warning("<b>ОШИБКА $!(@ ОШИБКА )#^! СЕНСОРНАЯ ПЕРЕГРУЗКА \[$(!@#</b>"))
		SEND_SOUND(silicon_victim, sound('sound/misc/interference.ogg'))
		playsound(silicon_victim, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
		do_sparks(5, TRUE, silicon_victim)
		silicon_victim.Weaken(12 SECONDS)

/datum/action/cooldown/spell/aoe/repulse/tail_lash
	name = "Удар хвостом"
	desc = "Отбрасывайте нападающих ударом хвоста."
	sound = 'sound/magic/tail_swing.ogg'
	cooldown_time = 15 SECONDS
	aoe_radius = 2
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	sparkle_path = null
	button_icon_state = "tailsweep"
	background_icon_state = "bg_alien"
	targeting_type = /datum/aoe_targeting/living_non_alien
	invocation_type = INVOCATION_NONE

/datum/action/cooldown/spell/aoe/repulse/tail_lash/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/alien/humanoid/queen/queen = src.owner
	if(!queen)
		return
	var/mutable_appearance/swing = mutable_appearance('icons/effects/96x96.dmi', "tail_swing", FLOAT_LAYER)
	queen.tail_swing_overlay = swing
	queen.add_overlay(swing)
	addtimer(CALLBACK(src, PROC_REF(cleanup_tail_swing_overlay), queen), 1.0 SECONDS, TIMER_UNIQUE | TIMER_OVERRIDE)
	queen.spin(3, 1)
	playsound(queen.loc, 'sound/creatures/alien/alien_tail_swipe.ogg', 80, TRUE)

/datum/action/cooldown/spell/aoe/repulse/tail_lash/proc/cleanup_tail_swing_overlay(mob/living/carbon/alien/humanoid/queen/queen)
	if(queen.tail_swing_overlay)
		queen.cut_overlay(queen.tail_swing_overlay)
		queen.tail_swing_overlay = null

/datum/action/cooldown/spell/aoe/repulse/tail_lash/cast_on_thing_in_aoe(atom/victim, atom/caster)
	. = ..()

	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		var/dir = get_dir(caster, victim)
		step(victim, dir)
		step(victim, dir)
		step(victim, dir)

		carbon_victim.Knockdown(3 SECONDS)
		carbon_victim.Weaken(5 SECONDS)
		carbon_victim.apply_damage(30, BRUTE)
		to_chat(carbon_victim, span_danger("<b>Хвост ксеноморфа сбивает вас с ног!</b>"))

	if(issilicon(victim))
		var/mob/living/silicon/silicon_victim = victim
		SEND_SOUND(silicon_victim, sound('sound/misc/interference.ogg'))
		playsound(silicon_victim, 'sound/machines/warning-buzzer.ogg', 50, TRUE)
		do_sparks(5, TRUE, silicon_victim)
		silicon_victim.Weaken(8 SECONDS)

/datum/action/innate/alien/sprite_toggle
	name = "Изменить размер спрайта"
	desc = "Остальные продолжат видеть вас огромным."
	button_icon_state = "alien_toggle_size"
	check_flags = AB_CHECK_CONSCIOUS
	var/small = FALSE
	var/small_icon = 'icons/mob/alien.dmi'
	var/small_icon_state = "normalsize_xeno"

/datum/action/innate/alien/sprite_toggle/Trigger(mob/clicker, trigger_flags)
	. = ..()
	if(!.)
		return

	if(!small)
		var/image/small_image = image(icon = small_icon, icon_state = small_icon_state, loc = owner)
		small_image.override = TRUE
		small_image.pixel_w -= owner.pixel_x
		small_image.pixel_z -= owner.pixel_y
		owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic, "smallsprite", small_image, AA_TARGET_SEE_APPEARANCE | AA_MATCH_TARGET_OVERLAYS)
		small = TRUE
	else
		owner.remove_alt_appearance("smallsprite")
		small = FALSE

/datum/action/cooldown/spell/aoe/resin_drone_healing
	name = "Исцеляющие феромоны"
	desc = "Излечить союзников-ксеноморфов на смоляных зарослях вокруг."
	button_icon_state = "alien_health"
	background_icon_state = "bg_alien"
	cooldown_time = 30 SECONDS
	aoe_radius = 6
	spell_requirements = NONE
	targeting_type = /datum/aoe_targeting/alien_on_resin
	sound = 'sound/creatures/terrorspiders/heal.ogg'
	var/heal_amount = 30
	var/plasma_cost = 100

/datum/action/cooldown/spell/aoe/resin_drone_healing/cast(atom/cast_on)
	var/mob/living/carbon/alien/alien_owner = owner
	if(alien_owner.get_plasma() < plasma_cost)
		to_chat(alien_owner, span_warning("Недостаточно плазмы!"))
		return
	alien_owner.adjust_alien_plasma(-plasma_cost)
	. = ..()
	owner.visible_message(span_green("[DECLENT_RU_CAP(owner, NOMINATIVE)] источает целительные феромоны!"))

/datum/action/cooldown/spell/aoe/resin_drone_healing/cast_on_thing_in_aoe(atom/victim, atom/caster)
	. = ..()
	var/mob/living/carbon/alien/alien_victim = victim
	alien_victim.adjustBruteLoss(-heal_amount)
	new /obj/effect/temp_visual/heal(get_turf(alien_victim), "#00ff0d")

/datum/action/cooldown/spell/aoe/resin_drone_healing/IsAvailable()
	if(!..())
		return FALSE
	var/mob/living/carbon/alien/alien_owner = owner
	return alien_owner.get_plasma() >= plasma_cost

/datum/action/cooldown/praetorian_shield
	name = "Щит преторианца"
	desc = "Укрепить броню спереди и по бокам на короткое время."
	button_icon_state = "praetorian_shield"
	background_icon_state = "bg_alien"
	cooldown_time = 30 SECONDS
	var/plasma_cost = 80
	var/duration = 6 SECONDS
	next_use_time = 0

/datum/action/cooldown/praetorian_shield/Activate(atom/target)
	var/mob/living/carbon/alien/humanoid/praetorian/praetorian = owner
	var/obj/item/organ/internal/xenos/plasmavessel/praetorian/vessel
	for(var/obj/item/organ/internal/xenos/plasmavessel/praetorian/P in praetorian.internal_organs)
		vessel = P
		break
	if(!vessel || vessel.stored_plasma < plasma_cost)
		to_chat(praetorian, span_warning("Недостаточно плазмы!"))
		return
	if(praetorian.shield_active)
		return
	vessel.stored_plasma = clamp(vessel.stored_plasma - plasma_cost, 0, vessel.max_plasma)
	praetorian.activate_shield(duration)
	status_text = "ACTIVE"
	next_use_time = world.time + cooldown_time
	UpdateButtonIcon()

/datum/action/cooldown/praetorian_shield/IsAvailable()
	if(world.time < next_use_time)
		return FALSE
	if(owner.stat > CONSCIOUS)
		return FALSE
	var/mob/living/carbon/alien/humanoid/praetorian/praetorian = owner
	return !praetorian.shield_active

/datum/action/cooldown/spell/praetorian_shield
	name = "Щит преторианца"
	desc = "Укрепить броню спереди и по бокам на короткое время."
	button_icon_state = "praetorian_shield"
	background_icon_state = "bg_alien"
	cooldown_time = 30 SECONDS
	check_flags = AB_CHECK_CONSCIOUS
	spell_requirements = NONE
	var/plasma_cost = 80
	var/duration = 6 SECONDS

/datum/action/cooldown/spell/praetorian_shield/create_new_handler()
	var/datum/spell_handler/alien/handler = new(src, plasma_cost)
	return handler

/datum/action/cooldown/spell/praetorian_shield/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/alien/humanoid/praetorian/praetorian = cast_on
	praetorian.activate_shield(duration)
	status_text = "ACTIVE"
	UpdateButtonIcon()

/datum/action/cooldown/spell/praetorian_shield/IsAvailable(feedback = TRUE)
	if(!..())
		return FALSE
	var/mob/living/carbon/alien/humanoid/praetorian/praetorian = owner
	return !praetorian.shield_active

