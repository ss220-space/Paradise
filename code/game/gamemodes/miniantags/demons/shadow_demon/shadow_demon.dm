/mob/living/simple_animal/demon/shadow
	name = "shadow demon"
	ru_names = list(
		NOMINATIVE = "теневой демон",
		GENITIVE = "теневого демона",
		DATIVE = "теневому демону",
		ACCUSATIVE = "теневого демона",
		INSTRUMENTAL = "теневым демоном",
		PREPOSITIONAL = "теневом демоне"
	)
	desc = "Существо, которое едва ощутимо. Вы чувствуете, как его взгляд пронзает вас."
	icon = 'icons/mob/mob.dmi'
	icon_state = "shadow_demon"
	icon_living = "shadow_demon"
	speed = 0
	maxHealth = 300
	health = 300
	move_resist = MOVE_FORCE_STRONG
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE // so they can tell where the darkness is
	loot = list(/obj/item/organ/internal/heart/demon/shadow)
	death_sound = 'sound/shadowdemon/shadowdeath.ogg'
	var/thrown_alert = FALSE
	var/wrapping = FALSE
	var/list/wrapped_victims


/mob/living/simple_animal/demon/shadow/Initialize(mapload)
	. = ..()
	remove_from_all_data_huds()
	AddSpell(new /obj/effect/proc_holder/spell/fireball/shadow_grapple)
	ADD_TRAIT(src, TRAIT_HEALS_FROM_HELL_RIFTS, INNATE_TRAIT)
	var/obj/effect/proc_holder/spell/bloodcrawl/shadow_crawl/crawl = new
	AddSpell(crawl)
	whisper_action.button_icon_state = "shadow_whisper"
	whisper_action.background_icon_state = "shadow_demon_bg"
	if(istype(loc, /obj/effect/dummy/slaughter))
		crawl.phased = TRUE
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/living/simple_animal/demon/shadow, check_darkness))
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(check_darkness))
	add_overlay(emissive_appearance(icon, "shadow_demon_eye_glow_overlay", src))


/mob/living/simple_animal/demon/shadow/Life(seconds, times_fired)
	. = ..()
	var/lum_count = check_darkness()
	var/damage_mod = istype(loc, /obj/effect/dummy/slaughter) ? 0.5 : 1
	if(lum_count > 0.2)
		adjustBruteLoss(30 * damage_mod) // 20 seconds in light and you are done
		SEND_SOUND(src, sound('sound/weapons/sear.ogg'))
		to_chat(src, span_biggerdanger("Свет обжигает вас!"))
	else
		adjustBruteLoss(-30)


/mob/living/simple_animal/demon/shadow/proc/check_darkness()
	var/turf/source_turf = get_turf(src)
	var/lum_count = source_turf.get_lumcount()
	if(lum_count > 0.2)
		if(!thrown_alert)
			thrown_alert = TRUE
			throw_alert("light", /atom/movable/screen/alert/lightexposure)
		animate(src, alpha = 255, time = 0.5 SECONDS)
		set_varspeed(initial(speed))
	else
		if(thrown_alert)
			thrown_alert = FALSE
			clear_alert("light")
		animate(src, alpha = 125, time = 0.5 SECONDS)
		set_varspeed(-0.3)
	return lum_count


/mob/living/simple_animal/demon/shadow/OnUnarmedAttack(atom/target)
	// Pick a random attack sound for each attack
	attack_sound = pick('sound/shadowdemon/shadowattack2.ogg', 'sound/shadowdemon/shadowattack3.ogg', 'sound/shadowdemon/shadowattack4.ogg')
	if(!ishuman(target))
		if(isitem(target))
			target.extinguish_light(TRUE)
		return ..()

	var/mob/living/carbon/human/h_target = target
	if(h_target.stat != DEAD)
		return ..()

	if(isLivingSSD(h_target) && client.send_ssd_warning(h_target)) //Similar to revenants, only wrap SSD targets if you've accepted the SSD warning
		return

	if(wrapping)
		balloon_alert(src, "занят!")
		return

	visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] начинает обматывать [h_target.declent_ru(ACCUSATIVE)] теневой паутиной."))
	wrapping = TRUE
	if(!do_after(src, 4 SECONDS, h_target, DEFAULT_DOAFTER_IGNORE|DA_IGNORE_HELD_ITEM))
		wrapping = FALSE
		return

	h_target.visible_message(span_warning("<b>[capitalize(declent_ru(NOMINATIVE))] окутывает [h_target.declent_ru(ACCUSATIVE)] в теневой кокон, и из него начинает расползаться тьма.</b>"))
	var/obj/structure/shadowcocoon/cocoon = new(get_turf(h_target))
	h_target.extinguish_light(TRUE) // may as well be safe
	h_target.forceMove(cocoon)
	wrapping = FALSE

	if(!h_target.mind)
		return

	if(!wrapped_victims)
		wrapped_victims = list()
	var/human_UID = h_target.UID()
	if(!(human_UID in wrapped_victims))
		wrapped_victims += human_UID


/obj/structure/shadowcocoon
	name = "shadowy cocoon"
	desc = "Объект, завёрнутый в густую, почти осязаемую тьму. Его поверхность дрожит и переливается, словно живая, а вокруг него клубится непроглядный мрак."
	ru_names = list(
		NOMINATIVE = "теневой кокон",
		GENITIVE = "теневого кокона",
		DATIVE = "теневому кокону",
		ACCUSATIVE = "теневой кокон",
		INSTRUMENTAL = "теневым коконом",
		PREPOSITIONAL = "теневом коконе"
	)
	icon = 'icons/effects/effects.dmi'
	icon_state = "shadowcocoon"
	light_power = -4
	light_range = 6
	max_integrity = 100
	light_color = "#ddd6cf"
	anchored = TRUE
	/// Amount of SSobj ticks (Roughly 2 seconds) since the last hallucination proc'd
	var/time_since_last_hallucination = 0
	/// Will we play hallucination sounds or not
	var/silent = TRUE


/obj/structure/shadowcocoon/Initialize(mapload)
	. = ..()
	playsound(loc, 'sound/shadowdemon/shadownode.ogg', 5, TRUE, -1)
	START_PROCESSING(SSobj, src)


/obj/structure/shadowcocoon/process()
	time_since_last_hallucination++
	for(var/atom/to_darken in range(4, src))
		if(prob(60) || !length(to_darken.light_sources))
			continue
		if(iswelder(to_darken) && length(to_darken.light_sources))
			to_darken.visible_message(span_notice("Тени смыкаются вокруг и поглощают пламя [to_darken.declent_ru(GENITIVE)]."))
		to_darken.extinguish_light(TRUE)
	if(!silent && time_since_last_hallucination >= rand(8, 12))
		playsound(src, pick('sound/shadowdemon/shadowhalluc1.ogg', 'sound/shadowdemon/shadowhalluc2.ogg', 'sound/machines/airlock_open.ogg',  'sound/machines/airlock_close.ogg', 'sound/machines/boltsup.ogg', 'sound/shadowdemon/shadowhalluc3.ogg', 'sound/effects/eleczap.ogg', get_sfx("bodyfall"), get_sfx("gunshot"), 'sound/weapons/egloves.ogg'), 50)
		time_since_last_hallucination = 0


// Allows you to turn on cocoons making hallucination sounds or not.
/obj/structure/shadowcocoon/click_alt(mob/user)
	if(!isdemon(user))
		return NONE
	if(user.incapacitated())
		return CLICK_ACTION_BLOCKING
	if(silent)
		to_chat(user, span_notice("Вы искажаете и изменяете свою пойманную жертву в [declent_ru(ACCUSATIVE)], чтобы заманить больше добычи."))
		silent = FALSE
		return CLICK_ACTION_BLOCKING
	to_chat(user, span_notice("Щупальца [declent_ru(GENITIVE)] возвращаются к своей изначальной форме."))
	silent = TRUE
	return CLICK_ACTION_SUCCESS


/obj/structure/shadowcocoon/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = NONE)
	if(damage_type != BURN) //I unashamedly stole this from spider cocoon code
		return
	playsound(loc, 'sound/items/welder.ogg', 100, TRUE)


/obj/structure/shadowcocoon/obj_destruction()
	visible_message(span_danger("[capitalize(declent_ru(NOMINATIVE))] раскрывается, и тени, танцующие вокруг, рассеиваются."))
	return ..()


/obj/structure/shadowcocoon/Destroy()
	for(var/atom/movable/AM in contents)
		AM.forceMove(loc)
	return..()


/mob/living/simple_animal/demon/shadow/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isliving(AM)) // when a living creature is thrown at it, dont knock it back
		return
	..()


/obj/effect/proc_holder/spell/fireball/shadow_grapple
	name = "Теневой захват"
	desc = "Выстрелите одной из своих рук. Если она попадёт в человека, вы притянете его к себе. Если же она попадёт в структуру, то вы сами притянетесь к ней."
	action_background_icon_state = "shadow_demon_bg"
	action_icon_state = "shadow_grapple"
	invocation_type = "none"
	invocation = null
	sound = null
	need_active_overlay = TRUE
	human_req = FALSE
	selection_activated_message = span_notice("Вы поднимаете руку, наполненную демонической энергией! <b>ЛКМ, чтобы применить к цели!</b>")
	selection_deactivated_message = span_notice("Вы поглощаете энергию обратно... пока что.")
	base_cooldown = 10 SECONDS
	fireball_type = /obj/projectile/magic/shadow_hand


/obj/effect/proc_holder/spell/fireball/shadow_grapple/update_icon_state()
	return


/obj/projectile/magic/shadow_hand
	name = "shadow hand"
	ru_names = list(
		NOMINATIVE = "теневая рука",
		GENITIVE = "теневой руки",
		DATIVE = "теневой руке",
		ACCUSATIVE = "теневую руку",
		INSTRUMENTAL = "теневой рукой",
		PREPOSITIONAL = "теневой руке"
	)
	icon_state = "shadow_hand"
	plane = FLOOR_PLANE
	speed = 1
	hitsound = 'sound/shadowdemon/shadowattack1.ogg' // Plays when hitting something living or a light
	var/hit = FALSE


/obj/projectile/magic/shadow_hand/fire(setAngle)
	if(firer)
		firer.Beam(src, icon_state = "grabber_beam", time = INFINITY, maxdistance = INFINITY, beam_type = /obj/effect/ebeam/floor, layer = BELOW_MOB_LAYER)
	return ..()


/obj/projectile/magic/shadow_hand/on_hit(atom/target, blocked, hit_zone)
	if(hit)
		return
	hit = TRUE // to prevent double hits from the pull
	. = ..()
	for(var/atom/extinguish_target in range(2, src))
		extinguish_target.extinguish_light(TRUE)
	if(isliving(target))
		var/mob/living/l_target = target
		l_target.Immobilize(4 SECONDS)
		l_target.apply_damage(40, BRUTE, BODY_ZONE_CHEST)
		l_target.throw_at(get_step(firer, get_dir(firer, target)), 50, 10)
	else
		firer.throw_at(get_step(target, get_dir(target, firer)), 50, 10)


/obj/item/organ/internal/heart/demon/shadow
	name = "heart of darkness"
	ru_names = list(
		NOMINATIVE = "сердце тьмы",
		GENITIVE = "сердца тьмы",
		DATIVE = "сердцу тьмы",
		ACCUSATIVE = "сердце тьмы",
		INSTRUMENTAL = "сердцем тьмы",
		PREPOSITIONAL = "сердце тьмы"
	)
	desc = "Оно всё ещё яростно бьётся, излучая ауру страха."
	color = COLOR_BLACK


/obj/item/organ/internal/heart/demon/shadow/attack_self(mob/living/user)
	. = ..()
	user.drop_from_active_hand()
	insert(user)


/obj/item/organ/internal/heart/demon/shadow/insert(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	. = ..()
	M?.mind?.AddSpell(new /obj/effect/proc_holder/spell/fireball/shadow_grapple)


/obj/item/organ/internal/heart/demon/shadow/remove(mob/living/carbon/M, special = ORGAN_MANIPULATION_DEFAULT)
	M?.mind?.RemoveSpell(/obj/effect/proc_holder/spell/fireball/shadow_grapple)
	. = ..()


/mob/living/simple_animal/demon/shadow/attempt_objectives()
	if(!..())
		return

	var/list/messages = list()
	messages.Add(span_fontsize3(span_red("Вы — Теневой Демон.</font><br></b>")))
	messages.Add("<b>Вы — ужасное существо из иного измерения. У вас две цели: выжить и поджидать неосторожную добычу.</b>")
	messages.Add("<b>Вы можете использовать способность \"Теневой Путь\" рядом с тёмными участками, появляясь и исчезая на станции по своему желанию.</b>")
	messages.Add("<b>Ваша способность \"Теневой Захват\" позволяет вам притягивать живую добычу или притягиваться к объектам. Также она гасит все источники света в зоне удара.</b>")
	messages.Add("<b>Вы можете оборачивать мёртвые гуманоидные тела, атакуя их. Используйте Alt+ЛКМ на теневом коконе, чтобы заманить больше жертв.</b>")
	messages.Add("<b>Вы быстро двигаетесь и восстанавливаетесь в тенях, но любой источник света причиняет вам боль и может убить. ДЕРЖИТЕСЬ ПОДАЛЬШЕ ОТ СВЕТА!</b>")
	messages.Add(span_notice("<b>Сейчас вы находитесь в ином измерении, отличном от станции. Используйте способность \"Теневой Путь\" рядом с тёмным участком.</b>"))
	messages.Add(span_motd("С полной информацией вы можете ознакомиться на вики: <a href=\"[CONFIG_GET(string/wikiurl)]/index.php/Shadow_Demon\">Теневой демон</a></span>"))
	SEND_SOUND(src, sound('sound/misc/demon_dies.ogg'))
	if(vialspawned)
		return

	var/datum/objective/wrap/wrap_objective = new
	var/datum/objective/survive/survive_objective = new
	wrap_objective.owner = mind
	survive_objective.owner = mind
	mind.objectives += wrap_objective
	mind.objectives += survive_objective
	messages.Add(mind.prepare_announce_objectives())
	to_chat(src, chat_box_red(messages.Join("<br>")))


/datum/objective/wrap
	name = "Обёртывание"
	antag_menu_name = "Обернуть в кокон"
	needs_target = FALSE
	target_amount = 10


/datum/objective/wrap/New(text, datum/team/team_to_join)
	target_amount = rand(10,20)
	explanation_text = "Устройте засаду тем, кто осмелится бросить вызов теням. Оберните хотя бы [target_amount] смертных."
	..()


/datum/objective/wrap/check_completion()
	var/wrap_count = 0
	for(var/datum/mind/player in get_owners())
		if(!istype(player.current, /mob/living/simple_animal/demon/shadow) || QDELETED(player.current))
			continue

		var/mob/living/simple_animal/demon/shadow/demon = player.current
		if(!demon.wrapped_victims || !length(demon.wrapped_victims))
			continue

		wrap_count += length(demon.wrapped_victims)

	return wrap_count >= target_amount

