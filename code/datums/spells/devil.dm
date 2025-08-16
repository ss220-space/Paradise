/obj/effect/proc_holder/spell/conjure_item/pitchfork
	name = "Призвать вилы"
	desc = "Призывает/отзывает дьявольские вилы."

	item_type = /obj/item/twohanded/pitchfork/demonic

	action_icon_state = "pitchfork"
	action_background_icon_state = "bg_demon"
	base_cooldown = 5 SECONDS

	human_req = FALSE

/obj/effect/proc_holder/spell/conjure_item/pitchfork/greater
	name = "Призвать великие вилы"
	item_type = /obj/item/twohanded/pitchfork/demonic/greater


/obj/effect/proc_holder/spell/conjure_item/pitchfork/ascended
	name = "Призвать вилы Архидьявола"
	item_type = /obj/item/twohanded/pitchfork/demonic/ascended


/obj/effect/proc_holder/spell/conjure_item/violin
	name = "Призвать золотую скрипку"
	desc = "Призывает/отзывает дьявольскую золотую скрипку."

	item_type = /obj/item/instrument/violin/golden

	invocation_type = "whisper"
	human_req = FALSE
	invocation = "Non multum gaudeo cum Georgia."

	action_icon_state = "golden_violin"
	action_background_icon_state = "bg_demon"


/obj/effect/proc_holder/spell/summon_contract
	name = "Призвать адский контракт"
	desc = "Зачем составлять контракт вручную, если можно сделать это с помощью магии?"

	invocation_type = "whisper"
	invocation = "Iustus signum in linea punctata."

	selection_activated_message = span_notice("Вы приготавливаете подробный контракт. ЛКМ по цели, чтобы призвать контракт ей в руку.")
	selection_deactivated_message = span_notice("Вы сохраняете контракт до лучших времен.")

	clothes_req = FALSE
	human_req = FALSE

	school = "conjuration"
	base_cooldown = 15 SECONDS
	cooldown_min = 1 SECONDS

	action_icon_state = "spell_default"
	action_background_icon_state = "bg_demon"
	need_active_overlay = TRUE


/obj/effect/proc_holder/spell/summon_contract/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.try_auto_target = FALSE
	T.range = 5
	T.click_radius = -1
	T.allowed_type = /mob/living/carbon
	return T


/obj/effect/proc_holder/spell/summon_contract/valid_target(mob/living/carbon/target, mob/user)
	return target.mind && target.mind.hasSoul && (target.mind.soulOwner == target.mind) && !HAS_TRAIT(target.mind, TRAIT_BAD_SOUL)


/obj/effect/proc_holder/spell/summon_contract/cast(list/targets, mob/user = usr)
	for(var/target in targets)
		var/mob/living/carbon/C = target
		if(!C.mind || !user.mind)
			to_chat(user, span_notice("[capitalize(C.declent_ru(NOMINATIVE))] не выглядит разумным и не сможет подписать контракт."))
			continue

		if(C.stat == DEAD)
			if(!user.drop_from_active_hand())
				continue

			var/obj/item/paper/contract/infernal/contract = new(user.loc, C.mind, user.mind, GLOB.devil_contracts[CONTRACT_REVIVE])
			user.put_in_hands(contract)
		else
			var/contract_type_name = tgui_input_list(user, "Какой тип контракта?", "Тип контракта", GLOB.devil_contracts - CONTRACT_REVIVE)

			if(!contract_type_name)
				return

			var/obj/item/paper/contract/infernal/contract = new(C.loc, C.mind, user.mind, GLOB.devil_contracts[contract_type_name])
			C.put_in_hands(contract)


/obj/effect/proc_holder/spell/take_soul
	name = "Забрать душу"
	desc = "Это заклинание забирает душу у выбраной цели."

	invocation_type = "shout"
	invocation = "Ille porcus est meus!"

	selection_activated_message = span_notice("Вы готовы забрать душу. Просто клините на свою жертву.")
	selection_deactivated_message = span_notice("Вы передумали забирать чью-то душу.")

	clothes_req = FALSE
	human_req = FALSE

	school = "conjuration"

	base_cooldown = 5 SECONDS

	action_icon_state = "spell_default"
	action_background_icon_state = "bg_demon"
	need_active_overlay = TRUE

/obj/effect/proc_holder/spell/take_soul/create_new_targeting()
	var/datum/spell_targeting/click/T = new()
	T.try_auto_target = FALSE
	T.range = 5
	T.click_radius = -1
	T.allowed_type = /mob/living/carbon
	return T


/obj/effect/proc_holder/spell/take_soul/valid_target(mob/living/carbon/target, mob/user)
	return target.mind && target.mind.hasSoul && (target.mind.soulOwner == target.mind)

/obj/effect/proc_holder/spell/take_soul/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/human = targets[1]
	var/datum/antagonist/devil/devil = user.mind?.has_antag_datum(/datum/antagonist/devil)
	devil.add_soul(human?.mind)

/obj/effect/proc_holder/spell/return_soul
	name = "Вернуть душу"
	desc = "Это заклинание возвращает душу выбраному существу."

	invocation_type = "whisper"
	invocation = "Et resuscita me; et retribuam eis!"

	clothes_req = FALSE
	human_req = FALSE

	school = "conjuration"
	base_cooldown = 5 SECONDS

	action_icon_state = "spell_default"
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/return_soul/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/return_soul/cast(list/targets, mob/user = usr)
	var/datum/antagonist/devil/devil = user.mind?.has_antag_datum(/datum/antagonist/devil)
	var/list/mobs
	for(var/datum/mind/mind in devil.soulsOwned - devil.ritualSouls)
		if(!mind.current)
			continue
		LAZYADDASSOC(mobs, mind.current.real_name, mind)

	if(!mobs)
		return

	var/datum/mind/soul = mobs[tgui_input_list(user, "Кому вы хотите вернуть душу?", "Вернуть душу", mobs)]

	if(!soul)
		return

	ADD_TRAIT(soul, TRAIT_BAD_SOUL, DEVIL_CONTRACT_TRAIT)

	devil.remove_soul(soul)

/obj/effect/proc_holder/spell/fireball/hellish
	name = "Адское пламя"
	desc = "Это заклинание запускает сгусток адского пламени в цель."

	school = "evocation"
	base_cooldown = 15 SECONDS

	clothes_req = FALSE
	human_req = FALSE

	invocation = "Quaeso, quemdam inter vos quaero!"
	invocation_type = "shout"

	fireball_type = /obj/projectile/magic/fireball/infernal
	action_background_icon_state = "bg_demon"

/obj/effect/proc_holder/spell/fireball/hellish/acsend
	fireball_type = /obj/projectile/magic/fireball/infernal/acsend

/obj/effect/proc_holder/spell/infernal_jaunt
	name = "Адский Скачок"
	desc = "Используйте адское пламя, чтобы выйти за границу материального мира."

	base_cooldown = 20 SECONDS
	cooldown_min = 0

	overlay = null

	action_icon_state = "jaunt"
	action_background_icon_state = "bg_demon"

	phase_allowed = TRUE

	clothes_req = FALSE
	human_req = FALSE

/obj/effect/proc_holder/spell/infernal_jaunt/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/infernal_jaunt/can_cast(mob/living/user, charge_check, show_message)
	. = ..()
	if(!.)
		return FALSE

	if(!istype(user))
		return FALSE

/obj/effect/proc_holder/spell/infernal_jaunt/cast(list/targets, mob/living/user = usr)
	if(istype(user.loc, /obj/effect/dummy/slaughter))
		var/continuing = 0
		if(istype(get_area(user), /area/shuttle)) // Can always phase in in a shuttle.
			continuing = TRUE
		else
			for(var/mob/living/C in orange(2, get_turf(user.loc))) //Can also phase in when nearby a potential buyer.
				if (C.mind && C.mind.soulOwner == C.mind)
					continuing = TRUE
					break
		if(continuing)
			to_chat(user, span_warning("Вы возвращаетесь в материальный мир."))
			if(do_after(user, 10 SECONDS, user, NONE))
				user.infernalphasein(src)
		else
			to_chat(user, span_warning("Вы можете материализоваться только на шаттле или рядом с тем, кто сможет подписать контракт."))
			revert_cast()
			return ..()

	else
		user.fakefire()
		to_chat(user, span_warning("Адское пламя выплёскивает вас обратно в реальность."))
		if(do_after(user, 10 SECONDS, user, NONE))
			ADD_TRAIT(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
			user.infernalphaseout(src)
		else
			to_chat(user, span_warning("Вы должны оставаться неподвижным во время возвращения."))
			user.ExtinguishMob()
			user.fakefireextinguish()

	cooldown_handler.start_recharge()
	return

/mob/living/proc/infernalphaseout(obj/effect/proc_holder/spell/infernal_jaunt/spell)
	dust_animation()

	visible_message(span_warning("[capitalize(declent_ru(NOMINATIVE))] исчезает в огненной вспышке!"))
	playsound(get_turf(src), 'sound/misc/enter_blood.ogg', 100, TRUE, -1)

	var/obj/effect/dummy/slaughter/s_holder = new(loc)

	ExtinguishMob()
	forceMove(s_holder)

	holder = s_holder

	REMOVE_TRAIT(src, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(spell))
	fakefireextinguish()


/mob/living/proc/infernalphasein(obj/effect/proc_holder/spell/infernal_jaunt/spell)
	if(HAS_TRAIT(src, TRAIT_NO_TRANSFORM))
		to_chat(src, span_warning("Вы слишком заняты, чтобы совершить прыжок."))
		return FALSE

	fakefire()
	forceMove(get_turf(src))

	visible_message(span_warning("<b>[capitalize(declent_ru(NOMINATIVE))] появляется в огненной вспышке!</b>"))
	playsound(get_turf(src), 'sound/misc/exit_blood.ogg', 100, TRUE, -1)

	addtimer(CALLBACK(src, PROC_REF(fakefireextinguish), TRUE), 1.5 SECONDS)


/obj/effect/proc_holder/spell/sintouch
	name = "Прикосновение греха"
	desc = "Данное заклинание тонко подталкивает смертных к греху."

	base_cooldown = 180 SECONDS
	cooldown_min = 0

	clothes_req = FALSE
	human_req = FALSE
	overlay = null

	action_icon_state = "sintouch"
	action_background_icon_state = "bg_demon"

	invocation = "PERVENIRE ET THESAUROS REPERIRE!"
	invocation_type = "shout"

	var/max_targets = 3


/obj/effect/proc_holder/spell/sintouch/ascended
	name = "Великое прикосновение греха"
	base_cooldown = 10 SECONDS
	max_targets = 10


/obj/effect/proc_holder/spell/sintouch/create_new_targeting()
	var/datum/spell_targeting/targeted/targeting = new()

	targeting.selection_type = SPELL_SELECTION_RANGE
	targeting.random_target = TRUE
	targeting.target_priority = SPELL_TARGET_RANDOM
	targeting.use_turf_of_user = TRUE

	targeting.range = 2
	targeting.max_targets = 3

	return targeting


/obj/effect/proc_holder/spell/sintouch/cast(list/targets, mob/living/user = usr)
	for(var/mob/living/carbon/human/human in targets)
		if(!human.mind)
			continue

		if(!human.mind.hasSoul)
			continue

		if(human.mind.has_antag_datum(/datum/antagonist/sintouched))
			continue

		human.mind.add_antag_datum(/datum/antagonist/sintouched)
		human.Weaken(4 SECONDS)

/obj/effect/proc_holder/spell/summon_dancefloor
	name = "Призвать танцпол"
	desc = "Когда Дьяволу действительно нужно зажечь."
	clothes_req = FALSE
	human_req = FALSE
	school = "conjuration"
	base_cooldown = 1 SECONDS
	cooldown_min = 5 SECONDS // 5 seconds, so the smoke can't be spammed
	action_icon_state = "funk"
	action_background_icon_state = "bg_demon"
	invocation = "Saltare, peccatores, saltare!"
	invocation_type = "shout"

	var/list/dancefloor_turfs
	var/list/dancefloor_turfs_types
	var/dancefloor_exists = FALSE

/obj/effect/proc_holder/spell/summon_dancefloor/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/summon_dancefloor/cast(list/targets, mob/user = usr)
	LAZYINITLIST(dancefloor_turfs)
	LAZYINITLIST(dancefloor_turfs_types)

	if(dancefloor_exists)
		dancefloor_exists = FALSE
		for(var/i in 1 to dancefloor_turfs.len)
			var/turf/T = dancefloor_turfs[i]
			T.ChangeTurf(dancefloor_turfs_types[i])
	else
		var/list/funky_turfs = RANGE_TURFS(1, user)
		for(var/turf/T in funky_turfs)
			if(T.density)
				to_chat(user, span_warning("Вы находитесь слишком близко к стене."))
				return

		dancefloor_exists = TRUE
		var/i = 1

		dancefloor_turfs.len = funky_turfs.len
		dancefloor_turfs_types.len = funky_turfs.len

		for(var/t in funky_turfs)
			var/turf/T = t
			dancefloor_turfs[i] = T
			dancefloor_turfs_types[i] = T.type
			T.ChangeTurf((i % 2 == 0) ? /turf/simulated/floor/light/colour_cycle/dancefloor_a : /turf/simulated/floor/light/colour_cycle/dancefloor_b)
			i++

/obj/effect/proc_holder/spell/aoe/devil_fire
	name = "Дьявольский огонь"
	desc = "Призывает огненные волны в радиусе заклинания."
	action_icon_state = "explosion_old"

	base_cooldown = 10 SECONDS
	aoe_range = 10
	invocation = "Che? non ' stimiti te faccende del inferno!"
	invocation_type = "shout"

	clothes_req = FALSE
	human_req = FALSE

	var/fire_prob = 50
	var/slow_time = 5 SECONDS

/obj/effect/proc_holder/spell/aoe/devil_fire/create_new_targeting()
	var/datum/spell_targeting/aoe/targeting = new()

	targeting.range = aoe_range
	targeting.allowed_type = /atom

	return targeting

/obj/effect/proc_holder/spell/aoe/devil_fire/cast(list/targets, mob/user = usr)
	for(var/mob/living/living in targets)
		living.Slowed(slow_time)

	for(var/turf/turf in targets)
		if(turf == get_turf(user))
			continue

		if(!prob(fire_prob))
			continue

		new /obj/effect/hotspot(turf)
		turf.hotspot_expose(2000, 50, 1)

	playsound(get_turf(user), 'sound/magic/blind.ogg', 50, TRUE)

/obj/effect/proc_holder/spell/dark_conversion
	name = "Теневое искажение"
	desc = "Превращает гуманоида в тенечеловека и искажает его восприятие реальности."

	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "horror"


	base_cooldown = 300 SECONDS
	var/cast_time = 5 SECONDS
	var/fail_cooldown = 5 SECONDS
	var/say_name_prob = 40

	clothes_req = FALSE
	human_req = FALSE

/obj/effect/proc_holder/spell/dark_conversion/create_new_targeting()
	var/datum/spell_targeting/aoe/targeting = new()

	targeting.range = 5
	targeting.allowed_type = /mob/living/carbon/human

	return targeting

/obj/effect/proc_holder/spell/dark_conversion/create_new_handler()
	var/datum/spell_handler/devil/devil = new
	return devil

/obj/effect/proc_holder/spell/dark_conversion/valid_target(mob/living/carbon/human/target, mob/user)
	return target.mind && !isshadowperson(target) && (target.mind != user?.mind)

/obj/effect/proc_holder/spell/dark_conversion/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/human = targets[1]
	var/mob/living/carbon/carbon = user
	var/datum/antagonist/devil/devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)

	if(prob(say_name_prob))
		carbon.say("INF' [devil.info.truename] NO")
	playsound(get_turf(carbon), 'sound/magic/narsie_attack.ogg', 100, TRUE)
	human.Knockdown(1 SECONDS)

	if(!do_after(user, cast_time, user, NONE))
		cooldown_handler.recharge_time = world.time + fail_cooldown
		return

	make_shadow(human, devil)

/datum/objective/assassinate/shadow_kill
	antag_menu_name = "Убить по воле проклятия"

/obj/effect/proc_holder/spell/dark_conversion/proc/make_shadow(mob/living/carbon/human/human, datum/antagonist/devil/devil)
	human.set_species(/datum/species/shadow)
	var/text = "Вы – создание тьмы. Старайтесь сохранить свою истинную форму и выполнить свои цели."
	human.store_memory(text, TRUE)
	to_chat(human, chat_box_red(text))

	var/datum/objective/assassinate/shadow_kill/kill = new
	kill.owner = human.mind
	kill.find_target()

	LAZYADD(human.mind.objectives, kill)
	LAZYADD(human.faction, "hell")

	var/list/messages = human.mind.prepare_announce_objectives()
	to_chat(human, chat_box_red(messages.Join("<br>")))

	LAZYOR(devil.shadows, human.mind)
	playsound(human, 'sound/magic/mutate.ogg', 100, TRUE)

/obj/effect/proc_holder/spell/sacrifice_circle
	name = "Создать жертвенный круг"
	desc = "Создает руну для жертвоприношений и ритуалов."

	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "sintouch"

	base_cooldown = 100 SECONDS
	var/cast_time = 5 SECONDS

	clothes_req = FALSE
	human_req = FALSE

/obj/effect/proc_holder/spell/sacrifice_circle/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/sacrifice_circle/create_new_handler()
	var/datum/spell_handler/devil/devil = new
	return devil

/obj/effect/proc_holder/spell/sacrifice_circle/cast(list/targets, mob/user = usr)
	playsound(get_turf(user), 'sound/magic/cult_spell.ogg', 100, TRUE)

	if(!do_after(user, cast_time, user, NONE))
		revert_cast(user)
		return

	create_rune(user)

/obj/effect/proc_holder/spell/sacrifice_circle/proc/create_rune(mob/user)
	var/mob/living/carbon/carbon = user
	var/datum/antagonist/devil/devil = carbon.mind?.has_antag_datum(/datum/antagonist/devil)

	if(!devil)
		return

	var/obj/effect/decal/cleanable/devil/devil_rune = new(get_turf(carbon))
	playsound(get_turf(carbon), 'sound/magic/invoke_general.ogg', 100, TRUE)

	devil_rune.AddComponent( \
		/datum/component/ritual_object, \
		allowed_categories = /datum/ritual/devil, \
		allowed_special_role = list(ROLE_DEVIL), \
	)

	devil_rune.devil = devil
	devil_rune.update_appearance(UPDATE_DESC)

	return



/obj/effect/proc_holder/spell/devil_panel
	name = "Информация о дьяволе"
	desc = "Позволяет вам узнать о своих слабостях, а так же о вашем прогрессе в повышении ранга."

	action_icon = 'icons/obj/library.dmi'
	action_icon_state = "demonomicon"

	clothes_req = FALSE
	human_req = FALSE

/obj/effect/proc_holder/spell/devil_panel/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/devil_panel/cast(list/targets, mob/user)
	var/datum/antagonist/devil/devil = user?.mind?.has_antag_datum(/datum/antagonist/devil)
	devil?.ui_interact(user)

/obj/effect/proc_holder/spell/devil_broadcast
	name = "Сказать всем"
	desc = "Скажите что-нибудь миру, который собираетесь разрушить."

	action_icon = 'icons/mob/actions/actions_cult.dmi'
	action_icon_state = "cult_comms"

	clothes_req = FALSE
	human_req = FALSE

/obj/effect/proc_holder/spell/devil_broadcast/create_new_targeting()
	return new /datum/spell_targeting/self

/obj/effect/proc_holder/spell/devil_broadcast/cast(list/targets, mob/user)
	var/text = tgui_input_text(user, "Что вы хотите сказать?", "Сказать")
	var/message = span_danger(span_fontsize5(text))
	for(var/mob/player_mob in GLOB.player_list)
		if(isnewplayer(player_mob) || !player_mob.client)
			continue
		to_chat(player_mob, message)
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, user, player_mob, message, user.tts_seed, TRUE)

