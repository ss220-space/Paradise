/datum/action/cooldown/spell/goon_vamp_rejuvenate
	name = "Восстановление"
	desc= "Используйте накопленную кровь, чтобы влить в тело новые силы, устраняя любое ошеломление"
	button_icon_state = "vampire_rejuvinate_old"
	background_icon_state = "bg_vampire_old"
	cooldown_time = 20 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	check_flags = AB_CHECK_PHASED
	charge_restore_time = 20 SECONDS
	cooldown_between_charges = 5 SECONDS
	var/effect_timer
	var/counter = 0

/datum/action/cooldown/spell/goon_vamp_rejuvenate/can_cast_spell(feedback)
	return ..() && owner.stat != DEAD

/datum/action/cooldown/spell/goon_vamp_rejuvenate/create_new_handler()
	var/datum/spell_handler/vampire/goon/handler = new(src)
	return handler

/datum/action/cooldown/spell/goon_vamp_rejuvenate/Grant(mob/grant_to)
	. = ..()
	var/datum/antagonist/vampire/vampire = grant_to.mind.has_antag_datum(/datum/antagonist/vampire)
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_GAIN, PROC_REF(on_diablerie_level_gain), override = TRUE)
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_REMOVE, PROC_REF(on_diablerie_level_remove), override = TRUE)

/datum/action/cooldown/spell/goon_vamp_rejuvenate/proc/on_diablerie_level_gain(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.upgrade_rejuvenate_charges(src)

/datum/action/cooldown/spell/goon_vamp_rejuvenate/proc/on_diablerie_level_remove(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.downgrade_rejuvenate_charges(src)

/datum/action/cooldown/spell/goon_vamp_rejuvenate/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = cast_on
	// mech supress escape
	if(HAS_TRAIT_FROM(user, TRAIT_IMMOBILIZED, MECH_SUPRESSED_TRAIT))
		user.remove_traits(list(TRAIT_IMMOBILIZED, TRAIT_FLOORED), MECH_SUPRESSED_TRAIT)
	user.SetWeakened(0)
	user.SetStunned(0)
	user.SetKnockdown(0)
	user.SetParalysis(0)
	user.SetSleeping(0)
	user.adjustStaminaLoss(-60)
	user.set_resting(FALSE, instant = TRUE)
	user.get_up(instant = TRUE)
	to_chat(user, span_notice("Ваше тело наполняется чистой кровью, снимая все ошеломляющие эффекты."))
	var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)
	if(vampire?.get_ability(/datum/vampire_passive/regen))
		effect_timer = addtimer(CALLBACK(src, PROC_REF(rejuvenate_effect), user), 3.5 SECONDS, TIMER_STOPPABLE|TIMER_LOOP)

/datum/action/cooldown/spell/goon_vamp_rejuvenate/proc/rejuvenate_effect(mob/living/carbon/human/user)
	if(QDELETED(user) || counter > 5)
		deltimer(effect_timer)
		effect_timer = null
		counter = 0
		var/datum/antagonist/vampire/vampire = user.mind.has_antag_datum(/datum/antagonist/vampire)

		if(!vampire.get_ability(/datum/vampire_passive/regen_bleeding))
			return

		var/list/internal_bleedings = user.check_internal_bleedings()

		if(!length(internal_bleedings))
			return

		var/obj/item/organ/external/bodypart = pick(internal_bleedings)
		bodypart.stop_internal_bleeding()
		return

	counter++
	var/update = NONE
	update |= user.heal_overall_damage(2, 2, updating_health = FALSE, affect_robotic = TRUE)
	update |= user.heal_damages(tox = 2, oxy = 5, stamina = 10, updating_health = FALSE)
	if(update)
		user.updatehealth()

/datum/action/cooldown/spell/pointed/vampire_hypnotise
	name = "Гипноз"
	desc= "Пронзающий взгляд, ошеломляющий жертву на довольно долгое время"
	button_icon_state = "vampire_hypnotise"
	background_icon_state = "bg_vampire_old"
	background_icon_state_active = "bg_vampire_old"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE
	cast_range = 1
	cooldown_time = 3 MINUTES
	var/required_blood = 25

/datum/action/cooldown/spell/pointed/vampire_hypnotise/create_new_handler()
	var/datum/spell_handler/vampire/goon/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/pointed/vampire_hypnotise/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/vampire_hypnotise/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on

	owner.visible_message(span_warning("Глаза [owner] ярко вспыхивают, когда он[GEND_A_O_I(owner)] пристально смотр[PLUR_IT_YAT(owner)] в глаза [target]."))
	if(do_after(owner, 6 SECONDS, target, NONE))
		var/datum/spell_handler/vampire/handler = custom_handler
		if(!handler.affects(target, owner))
			to_chat(owner, span_warning("Ваш пронзительный взгляд не смог заворожить [target]."))
			to_chat(target, span_notice("Невыразительный взгляд [owner] ничего вам не делает."))
		else
			to_chat(owner, span_warning("Ваш пронзающий взгляд завораживает [target]."))
			to_chat(target, span_warning("Вы чувствуете сильную слабость."))
			target.SetSleeping(40 SECONDS)
	else
		reset_spell_cooldown()
		to_chat(owner, span_warning("Вы смотрите в никуда."))

/datum/action/cooldown/spell/pointed/goon_vamp_disease
	name = "Заражающее касание"
	desc = "Ваше касание инфицирует кровь жертвы, заражая её могильной лихорадкой. Пока лихорадку не вылечат, жертва будет с трудом держаться на ногах, а её кровь будет наполняться токсинами."
	gain_desc = "Вы получили способность «Заражающее касание». Она позволит вам ослаблять тех, кого вы коснётесь до тех пор, пока их не вылечат."
	button_icon_state = "vampire_disease"
	background_icon_state = "bg_vampire_old"
	background_icon_state_active = "bg_vampire_old"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE
	cast_range = 1
	cooldown_time = 3 MINUTES
	var/required_blood = 50

/datum/action/cooldown/spell/pointed/goon_vamp_disease/create_new_handler()
	var/datum/spell_handler/vampire/goon/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/pointed/goon_vamp_disease/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/goon_vamp_disease/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on

	to_chat(owner, span_warning("Вы незаметно инфицируете [target] заражающим касанием."))
	target.help_shake_act(owner)
	var/datum/spell_handler/vampire/handler = custom_handler
	if(!handler.affects(target, owner))
		to_chat(owner, span_warning("Вам кажется, что заражающее касание не подействовало на [target]."))
		return

	var/datum/disease/vampire/virus = new
	virus.Contract(target)

/datum/action/cooldown/spell/aoe/goon_vamp_glare
	name = "Вспышка"
	desc = "Вы сверкаете глазами, ненадолго ошеломляя всех людей вокруг"
	button_icon_state = "vampire_glare_old"
	background_icon_state = "bg_vampire_old"
	cooldown_time = 30 SECONDS
	cooldown_between_charges = 3 SECONDS
	charge_restore_time = 30 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	check_flags = AB_CHECK_PHASED
	aoe_radius = 1
	school = SCHOOL_SANGUINE
	targeting_type = /datum/aoe_targeting/goon_glare

/datum/action/cooldown/spell/aoe/goon_vamp_glare/can_cast_spell(feedback)
	return ..() && owner.stat == CONSCIOUS

/datum/action/cooldown/spell/aoe/goon_vamp_glare/create_new_handler()
	var/datum/spell_handler/vampire/goon/handler = new(src)
	return handler

/datum/action/cooldown/spell/aoe/goon_vamp_glare/Grant(mob/grant_to)
	. = ..()
	var/datum/antagonist/vampire/vampire = grant_to.mind.has_antag_datum(/datum/antagonist/vampire)
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_GAIN, PROC_REF(on_diablerie_level_gain), override = TRUE)
	RegisterSignal(vampire, SIGNAL_DIABLERIE_LEVEL_REMOVE, PROC_REF(on_diablerie_level_remove), override = TRUE)

/datum/action/cooldown/spell/aoe/goon_vamp_glare/proc/on_diablerie_level_gain(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.upgrade_glare_charges(src)

/datum/action/cooldown/spell/aoe/goon_vamp_glare/proc/on_diablerie_level_remove(datum/source, datum/diablerie_level/level)
	SIGNAL_HANDLER
	level.downgrade_glare_charges(src)

/datum/action/cooldown/spell/aoe/goon_vamp_glare/before_cast(atom/cast_on)
	var/mob/living/carbon/human/caster = owner
	if(istype(caster.glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
		to_chat(caster, span_warning("У вас на глазах повязка!"))
		return FALSE
	caster.visible_message(span_warning("Глаза [caster] ослепительно вспыхивают!"))
	return ..()

/datum/action/cooldown/spell/aoe/goon_vamp_glare/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/carbon/human/target = victim

	if(isninja(target))
		var/mob/living/carbon/human/target_human = target
		var/obj/item/clothing/glasses/ninja/ninja_visor = target_human.glasses

		if(istype(ninja_visor) && ninja_visor.vamp_protection_active && ninja_visor.current_mode == "flashprotection")
			to_chat(target, span_warning("Глаза [owner] засветились, но ваш визор защитил вас."))
			return

	target.Weaken(4 SECONDS)
	target.AdjustStuttering(40 SECONDS)
	target.adjustStaminaLoss(20)
	to_chat(target, span_userdanger("Вы ослеплены вспышкой из глаз [owner]."))
	add_attack_logs(owner, target, "(Vampire) слепит")
	target.apply_status_effect(STATUS_EFFECT_STAMINADOT)

/datum/action/cooldown/spell/vamp_shapeshift
	name = "Превращение"
	desc = "Изменяет ваше имя и внешность, тратя 50 крови, с откатом в 3 минуты."
	gain_desc = "Вы получили способность «Превращение», позволяющую навсегда обернуться другим обликом, затратив часть накопленной крови."
	button_icon_state = "genetic_poly"
	background_icon_state = "bg_vampire_old"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cooldown_time = 3 MINUTES
	school = SCHOOL_SANGUINE
	var/required_blood = 50

/datum/action/cooldown/spell/vamp_shapeshift/create_new_handler()
	var/datum/spell_handler/vampire/goon/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/vamp_shapeshift/cast(atom/cast_on)
	. = ..()
	cast_on.visible_message(span_warning("[cast_on] transforms!"))
	var/mob/living/carbon/human/user = cast_on
	scramble(TRUE, user, 100)
	user.real_name = random_name(user.gender, user.dna.species.name) //Give them a name that makes sense for their species.
	user.sync_organ_dna(assimilate = TRUE)
	user.update_body()
	user.reset_hair() //No more winding up with hairstyles you're not supposed to have, and blowing your cover.
	user.reset_markings() //...Or markings.
	user.dna.ResetUIFrom(user)
	user.flavor_text = ""
	user.update_icons()

/datum/action/cooldown/spell/aoe/goon_vamp_screech
	name = "Визг рукокрылых"
	desc = "Невероятно громкий визг, разбивающий стёкла и ошеломляющий окружающих."
	gain_desc = "Вы получили способность «Визг рукокрылых», в большом радиусе оглушающую всех, кто может слышать, и раскалывающую стёкла."
	button_icon_state = "vampire_screech"
	background_icon_state = "bg_vampire_old"
	cooldown_time = 3 MINUTES
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	aoe_radius = 4
	school = SCHOOL_SANGUINE
	targeting_type = /datum/aoe_targeting/goon_screech
	var/required_blood = 30

/datum/action/cooldown/spell/aoe/goon_vamp_screech/create_new_handler()
	var/datum/spell_handler/vampire/goon/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/aoe/goon_vamp_screech/cast(atom/cast_on)
	. = ..()
	for(var/obj/structure/window/window in view(4, owner))
		window.deconstruct(FALSE)
	playsound(owner.loc, 'sound/effects/creepyshriek.ogg', 100, TRUE)
	owner.visible_message(span_warning("[owner] издаёт душераздирающий визг!"), \
						span_warning("Вы громко визжите."), \
						span_italics("Вы слышите болезненно громкий визг!"))

/datum/action/cooldown/spell/aoe/goon_vamp_screech/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/carbon/target = victim

	if(isninja(target))
		var/mob/living/carbon/human/h_target = target
		var/obj/item/clothing/suit/space/space_ninja/ninja_suit = h_target.wear_suit
		if(istype(ninja_suit) && ninja_suit.vamp_protection_active && ninja_suit.s_initialized)
			to_chat(target, span_warning("<b>Вы начали слышать жуткий визг!</b> Но ваш костюм отреагировал на него и временно прикрыл вам уши, минимизируя урон"))
			target.Deaf(20 SECONDS)
			target.Jitter(100 SECONDS)
			target.adjustStaminaLoss(20)
			return

	to_chat(target, span_warning("<font size='3'><b>Вы слышите ушераздирающий визг и ваши чувства притупляются!</font></b>"))
	target.Weaken(4 SECONDS)
	target.Deaf(40 SECONDS)
	target.Stuttering(40 SECONDS)
	target.Jitter(300 SECONDS)
	target.apply_damage(60, STAMINA)

/datum/action/cooldown/spell/pointed/goon_vamp_enthrall
	name = "Порабощение"
	desc = "Вы используете большую часть своей силы, вынуждая тех, кто ещё никому не служит, служить только вам."
	gain_desc = "Вы получили способность «Порабощение», которая тратит много крови, но позволяет вам поработить человека, который ещё никому не служит, на случайный период времени."
	button_icon_state = "vampire_enthrall_old"
	background_icon_state = "bg_vampire_old"
	background_icon_state_active = "bg_vampire_old"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cast_range = 1
	cooldown_time = 3 MINUTES
	school = SCHOOL_SANGUINE
	var/required_blood = 300

/datum/action/cooldown/spell/pointed/goon_vamp_enthrall/create_new_handler()
	var/datum/spell_handler/vampire/goon/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/pointed/goon_vamp_enthrall/is_valid_target(atom/cast_on)
	return ..() && ishuman(cast_on)

/datum/action/cooldown/spell/pointed/goon_vamp_enthrall/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/target = cast_on

	if(!ishuman(target))
		to_chat(owner, span_warning("Вы можете порабощать только гуманоидов."))
		return

	owner.visible_message(span_warning("[owner] кусает [target] в шею!"), \
						span_warning("Вы кусаете [target] в шею и начинаете передачу части своей силы."))
	to_chat(target, span_warning("Вы ощущаете, как щупальца зла впиваются в ваш разум."))

	if(do_after(owner, 5 SECONDS, target, NONE))
		if(can_enthrall(owner, target))
			handle_enthrall(owner, target)
		else
			reset_spell_cooldown()
	else
		reset_spell_cooldown()

/datum/action/cooldown/spell/pointed/goon_vamp_enthrall/proc/can_enthrall(mob/living/carbon/human/user, mob/living/carbon/target)

	var/enthrall_safe = FALSE
	for(var/obj/item/implant/mindshield/implant in target)
		if(implant?.implanted)
			enthrall_safe = TRUE
			break

	for(var/obj/item/implant/traitor/implant in target)
		if(implant?.implanted)
			enthrall_safe = TRUE
			break

	. = FALSE
	if(!target)
		CRASH("target was null while trying to vampire enthrall, attacker is [user] [user.key] \ref[user]")

	if(!target.mind)
		to_chat(user, span_warning("Разум [target.name] сейчас не здесь, поэтому порабощение не удастся."))
		return

	if(enthrall_safe || isvampire(target) || isvampirethrall(target))
		target.visible_message(
			span_warning("Похоже что [target] сопротивляется захвату!"),
			span_notice("Вы ощущаете в голове знакомое ощущение, но оно быстро проходит."),
		)
		return
	var/datum/spell_handler/vampire/handler = custom_handler
	if(!handler.affects(target, owner))
		target.visible_message(
			span_warning("Похоже что [target] сопротивляется захвату!"),
			span_notice("Вера в [SSticker.Bible_deity_name] защищает ваш разум от всякого зла."),
		)
		return

	if(isninja(target))
		var/obj/item/clothing/suit/space/space_ninja/ninja_suit = target.wear_suit
		if(istype(ninja_suit) && ninja_suit.vamp_protection_active && ninja_suit.s_initialized)
			target.visible_message(
				span_warning("Похоже что [target] сопротивляется захвату!"),
				span_notice("Вы ощутили сильную боль, а затем слабый укол в шею. Кажется костюм только, что защитил ваш разум..."),
			)
			target.setBrainLoss(20)
			return

	if(!ishuman(target))
		to_chat(user, span_warning("Вы можете порабощать только гуманоидов!"))
		return

	return TRUE

/datum/action/cooldown/spell/pointed/goon_vamp_enthrall/proc/handle_enthrall(mob/living/user, mob/living/carbon/human/target)
	if(!istype(target))
		return FALSE

	target.mind.add_antag_datum(new /datum/antagonist/mindslave/thrall/goon_thrall(user.mind))
	if(jobban_isbanned(target, ROLE_VAMPIRE))
		SSticker.mode.replace_jobbanned_player(target, SPECIAL_ROLE_VAMPIRE_THRALL)
	target.Stun(4 SECONDS)
	to_chat(user, span_warning("Вы успешно поработили [target]. <i>Если игрок откажется Вас слушаться, используйте adminhelp.</i>"))
	user.create_log(CONVERSION_LOG, "vampire enthralled", target)
	target.create_log(CONVERSION_LOG, "was vampire enthralled", user)

/datum/action/cooldown/spell/goon_vamp_cloak
	name = "Покров тьмы"
	desc = "Переключается, маскируя вас в темноте"
	gain_desc = "Вы получили способность «Покров тьмы», которая, будучи включённой, делает вас практически невидимым в темноте."
	button_icon_state = "vampire_cloak_old"
	background_icon_state = "bg_vampire_old"
	school = SCHOOL_SANGUINE
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cooldown_time = 1 SECONDS

/datum/action/cooldown/spell/goon_vamp_cloak/create_new_handler()
	var/datum/spell_handler/vampire/goon/handler = new(src)
	return handler

/datum/action/cooldown/spell/goon_vamp_cloak/after_cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/vampire/vamp = owner?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vamp)
		return
	name = "[initial(name)] ([vamp.is_goon_cloak ? "Выключить" : "Включить"])"
	build_all_button_icons()

/datum/action/cooldown/spell/goon_vamp_cloak/cast(atom/cast_on)
	. = ..()
	var/datum/antagonist/vampire/vamp = owner?.mind?.has_antag_datum(/datum/antagonist/vampire)
	if(!vamp)
		return

	vamp.is_goon_cloak = !vamp.is_goon_cloak
	build_all_button_icons()
	to_chat(owner, span_notice("Теперь вас будет <b>[vamp.is_goon_cloak ? "не видно" : "видно"]</b> в темноте."))

/datum/action/cooldown/spell/conjure/goon_vamp_bats
	name = "Дети ночи"
	desc = "Вы вызываете пару космолетучих мышей, которые будут биться насмерть со всеми вокруг"
	gain_desc = "Вы получили способность «Дети ночи», призывающую летучих мышей."
	button_icon_state = "vampire_bats"
	background_icon_state = "bg_vampire_old"
	cooldown_time = 2 MINUTES
	var/required_blood = 50
	summon_amount = 2
	summon_radius = 1
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE
	summon_type = /mob/living/simple_animal/hostile/scarybat
	sound = 'sound/effects/creepyshriek.ogg'

/datum/action/cooldown/spell/conjure/goon_vamp_bats/create_new_handler()
	var/datum/spell_handler/vampire/goon/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/conjure/goon_vamp_bats/post_summon(atom/summoned_object, atom/cast_on)
	var/mob/summon = summoned_object
	summon.faction += PERSONAL_FACTION(owner)

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/goon_vamp_jaunt
	name = "Облик тумана"
	desc = "Вы на короткое время превращаетесь в облако тумана"
	gain_desc = "Вы получили способность «Облик тумана», которая позволит вам превращаться в облако тумана и проходить сквозь любые препятствия."
	background_icon_state = "bg_vampire_old"
	cooldown_time = 60 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	school = SCHOOL_SANGUINE
	jaunt_in_time = 2 SECONDS
	jaunt_type = /obj/effect/dummy/phased_mob/spell_jaunt/red
	var/required_blood = 50

/datum/action/cooldown/spell/jaunt/ethereal_jaunt/goon_vamp_jaunt/create_new_handler()
	var/datum/spell_handler/vampire/goon/handler = new(src, required_blood)
	return handler

// Blink for vamps
// Less smoke spam.
/datum/action/cooldown/spell/teleport/radius_turf/goon_vamp_blink
	name = "Шаг в тень"
	desc = "Растворитесь в тенях"
	gain_desc = "Вы получили способность «Шаг в тень», позволяющую вам, затратив часть крови, оказаться в ближайшей доступной тени."
	button_icon_state = "blink"
	background_icon_state = "bg_vampire_old"
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	cooldown_time = 2 SECONDS
	inner_tele_radius = 0
	outer_tele_radius = 6
	var/required_blood = 20
	// Maximum lighting_lumcount.
	var/max_lum = 1

/datum/action/cooldown/spell/teleport/radius_turf/goon_vamp_blink/create_new_handler()
	var/datum/spell_handler/vampire/goon/handler = new(src, required_blood)
	return handler

/datum/action/cooldown/spell/teleport/radius_turf/goon_vamp_blink/get_destinations(atom/center)
	var/list/valid_turfs = list()
	var/list/possibles = RANGE_TURFS(outer_tele_radius, center)
	if(inner_tele_radius > 0)
		possibles -= RANGE_TURFS(inner_tele_radius, center)

	for(var/turf/nearby_turf as anything in possibles)
		if(!is_valid_destination(nearby_turf))
			continue

		valid_turfs += nearby_turf
	if(!length(valid_turfs))
		to_chat(owner, span_warning("Поблизости нет теней, куда можно было бы шагнуть."))
		return
	return valid_turfs

/datum/action/cooldown/spell/teleport/radius_turf/goon_vamp_blink/is_valid_destination(turf/selected)
	return ..() && selected.get_lumcount(0.5)*10 <= max_lum
