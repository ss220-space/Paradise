//In here: Hatch and Ascendance
GLOBAL_LIST_INIT(possibleShadowlingNames, list("U'ruan", "Y`shej", "Nex", "Hel-uae", "Noaey'gief", "Mii`mahza", "Amerziox", "Gyrg-mylin", "Kanet'pruunance", "Vigistaezian")) //Unpronouncable 2: electric boogalo)

/datum/action/cooldown/spell/shadowling_hatch
	name = "Hatch"
	desc = "Сбрасывает вашу маскировку."
	cooldown_time = 5 MINUTES
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_HUMAN
	school = SCHOOL_FORBIDDEN
	button_icon_state = "hatch"
	background_icon_state = "bg_shadowling"
	var/cycles_unused = 0
	var/hatching = FALSE
	var/list/datum/action/cooldown/spell/shadowling_spells = list(
		/datum/action/cooldown/spell/pointed/shadowling_enthrall,
		/datum/action/cooldown/spell/aoe/shadowling_glare,
		/datum/action/cooldown/spell/aoe/shadowling_veil,
		/datum/action/cooldown/spell/jaunt/ethereal_jaunt/shadowling_shadow_walk,
		/datum/action/cooldown/spell/aoe/shadowling_icy_veins,
		/datum/action/cooldown/spell/shadowling_regen_armor,
	)

/datum/action/cooldown/spell/shadowling_hatch/can_cast_spell(feedback)
	return ..() && !hatching

/datum/action/cooldown/spell/shadowling_hatch/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = cast_on
	if(user.stat || !ishuman(user) || !user || !is_shadow(user) || user.isinspace())
		return

	if(!isturf(user.loc))
		reset_spell_cooldown()
		to_chat(user, span_warning("Вы должны стоять на полу, чтобы раскрыться!"))
		return
	hatching = TRUE
	if(tgui_alert(user, "Вы уверены, что хотите раскрыться? Вы не сможете прервать это!", "Hatch", list("Yes", "No")) != "Yes")
		to_chat(user, span_warning("Вы решили не раскрываться сейчас."))
		hatching = FALSE
		reset_spell_cooldown()
		return

	ADD_TRAIT(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
	user.visible_message(span_warning("Вещи [user] неожиданно начали сползать. С них стекает обильное количество фиолетовой жижи, которая формируется вокруг них."), \
						span_shadowling("Вы сбрасываете одежду, которая может помешать вашему вылуплению и начинаете выделять смолу, которая защитит вас."))
	user.Stun(35 SECONDS, TRUE)
	for(var/obj/item/item as anything in user.get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		user.drop_item_ground(item, force = TRUE)

	sleep(5 SECONDS)
	if(QDELETED(user))
		return

	var/turf/shadowturf = get_turf(user)
	for(var/turf/simulated/floor/F in orange(1, user))
		new /obj/structure/alien/resin/wall/shadowling(F)

	for(var/obj/structure/alien/resin/wall/shadowling/R in shadowturf) //extremely hacky
		qdel(R)
		new /obj/structure/alien/weeds/node(shadowturf) //Dim lighting in the chrysalis -- removes itself afterwards

	//Can't die while hatching
	ADD_TRAIT(user, TRAIT_GODMODE, UNIQUE_TRAIT_SOURCE(src))

	user.visible_message(span_warning("Хризалида окутывает [user] и [user.p_them()] скрывается внутри."), \
						span_shadowling("Вы обвиваетесь в хризалиду и начинаете извиваться внутри."))

	sleep(10 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message(span_boldwarning("Кожа на спине [user] начинает расслаиваться. Из дыр медленно показываются чёрные шипы."), \
						span_shadowling("Шипы пронзают вашу спину. Когти разрывают ваши пальцы. Вы чувствуете мучительную боль, когда ваша истинная форма начинает проявляться."))

	sleep(9 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message(span_boldwarning("[user], кожа рвётся, налипая на стены вокруг [user.p_them()]."), \
						span_shadowling("Ваша фальшивая кожа отваливается. Вы начинаете рвать защищающую вас хрупкую мембрану."))

	sleep(8 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/weapons/slash.ogg', 15, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(user, span_boldnotice("Вы рвёте и режете."))

	sleep(1 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/weapons/slashmiss.ogg', 15, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(user, span_boldnotice("Хризалида осыпается перед вами, как капли воды."))

	sleep(1 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/weapons/slice.ogg', 15, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(user, span_boldnotice("Вы освободились!"))

	sleep(1 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/effects/ghost.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/newNameId = pick(GLOB.possibleShadowlingNames)
	GLOB.possibleShadowlingNames.Remove(newNameId)
	user.real_name = newNameId
	user.name = user.real_name
	to_chat(user, span_mind_control("ВЫ ЖИВЫ!!!"))
	user.remove_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))

	for(var/obj/structure/alien/resin/wall/shadowling/resin in orange(user, 1))
		qdel(resin)

	for(var/obj/structure/alien/weeds/node/node in shadowturf)
		qdel(node)

	user.visible_message(span_warning("Хризалиду разрывает и из неё бьёт поток фиолетовой плоти и жидкости!"))
	user.underwear = "None"
	user.undershirt = "None"
	user.socks = "None"
	user.faction |= "faithless"

	user.set_species(/datum/species/shadow/ling)	//can't be a shadowling without being a shadowling
	user.mind.RemoveSpell(src)
	var/obj/item/organ/internal/cyberimp/eyes/eyes
	eyes = new /obj/item/organ/internal/cyberimp/eyes/thermals/ling(null) // thermal without item
	eyes.insert(user)
	user.set_vision_override(/datum/vision_override/nightvision) // nighvision withot button

	sleep(1 SECONDS)
	if(QDELETED(user))
		return

	to_chat(user, span_shadowling("<b><i>Ваши силы пробудились. Теперь вы заживёте в полную меру. Помните свои цели. Сотрудничайте со своими союзниками и рабами.</b></i>"))
	user.ExtinguishMob()
	user.set_nutrition(NUTRITION_LEVEL_FED)
	for(var/spell in shadowling_spells)
		user.mind.AddSpell(new spell)

	QDEL_NULL(user.hud_used)
	user.set_hud_used(new /datum/hud/human(user, ui_style2icon(user.client.prefs.UI_style), user.client.prefs.UI_style_color, user.client.prefs.UI_style_alpha))
	user.hud_used.show_hud(user.hud_used.hud_version)
	user.RemoveSpell(src)

/datum/action/cooldown/spell/shadowling_ascend
	name = "Ascend"
	desc = "Завершить свою истинную форму."
	cooldown_time = 5 MINUTES
	spell_requirements = SPELL_REQUIRES_HUMAN
	school = SCHOOL_FORBIDDEN
	button_icon_state = "ascend"
	background_icon_state = "bg_shadowling"
	var/list/ascendant_spells = list(
		/datum/action/cooldown/spell/pointed/ascendant_annihilate,
		/datum/action/cooldown/spell/pointed/ascendant_hypnosis,
		/datum/action/cooldown/spell/jaunt/ascendant_phase_shift,
		/datum/action/cooldown/spell/aoe/ascendant_storm,
		/datum/action/cooldown/spell/ascendant_transmit,
		/datum/action/cooldown/spell/pointed/shadowling_revive_thrall/ascendant,
	)

/datum/action/cooldown/spell/shadowling_ascend/cast(atom/cast_on)
	. = ..()
	var/mob/living/carbon/human/user = cast_on
	if(!shadowling_check(user))
		return

	if(tgui_alert(user, "Время завершить свою форму. Вы уверены?", "Ascend", list("Yes", "No")) != "Yes")
		to_chat(user, span_warning("Вы передумали завершать свою форму сейчас."))
		reset_spell_cooldown()
		return

	ADD_TRAIT(user, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	user.visible_message(span_warning("[user] взмывает в воздух, красный свет бъёт из его глаз."), \
						span_shadowling("Вы взмываете в воздух и готовы к своей трансформации."))

	sleep(5 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message(span_warning("Кожа [user] начинает трескаться и становится твержё."), \
						span_shadowling("Ваша кожа становится вашим щитом."))

	sleep(10 SECONDS)
	if(QDELETED(user))
		return
	user.visible_message(span_warning("Рожки на голове [user] начинают расти."), \
						span_shadowling("Ваше тело начинает мутировать. Ваши телепатические силы растут."))

	sleep(9 SECONDS)
	if(QDELETED(user))
		return
	user.visible_message(span_warning("Тело [user] начинает сильно растягиваться."), \
						span_shadowling("Вы разрушаете последние врата к божественности."))

	sleep(4 SECONDS)
	if(QDELETED(user))
		return
	to_chat(user, span_boldwarning("Да!"))

	sleep(1 SECONDS)
	if(QDELETED(user))
		return
	to_chat(user, span_big(span_boldwarning("ДА!!")))

	sleep(1 SECONDS)
	if(QDELETED(user))
		return
	to_chat(user, span_reallybig(span_boldwarning("ДАА---!!!")))

	sleep(0.1 SECONDS)
	if(QDELETED(user))
		return
	for(var/mob/living/mob in orange(7, user))
		mob.Weaken(20 SECONDS)
		to_chat(mob, span_userdanger("Огромное давление прибивает вас к полу!"))

	for(var/obj/machinery/power/apc/apc in GLOB.apcs)
		INVOKE_ASYNC(apc, TYPE_PROC_REF(/obj/machinery/power/apc, overload_lighting))

	var/mob/living/simple_animal/ascendant_shadowling/ascendant = new (user.loc)
	ascendant.announce("VYSHA NERADA YEKHEZET U'RUU!!", 5, 'sound/hallucinations/veryfar_noise.ogg')
	for(var/datum/action/cooldown/spell/spell as anything in user.mind.spell_list)
		if(spell == src || !spell.shadowling_spell)
			continue
		user.mind.RemoveSpell(spell)

	user.mind.transfer_to(ascendant)
	ascendant.name = user.real_name
	ascendant.languages = user.languages
	for(var/spell_to_add in ascendant_spells)
		ascendant.mind.AddSpell(new spell_to_add)

	if(ascendant.real_name)
		ascendant.real_name = user.real_name

	qdel(user)

	sleep(5 SECONDS)

	if(!SSticker.mode.shadowling_ascended)
		sleep(60 SECONDS)
		SSticker?.mode?.end_game()

	SSticker.mode.shadowling_ascended = TRUE

/**
 * Testing purpose.
 */
/mob/living/carbon/human/proc/make_unhatched_shadowling()
	for(var/obj/item/item as anything in get_equipped_items(INCLUDE_POCKETS | INCLUDE_HELD))
		drop_item_ground(item, force = TRUE)

	var/newNameId = pick(GLOB.possibleShadowlingNames)
	GLOB.possibleShadowlingNames.Remove(newNameId)
	real_name = newNameId
	name = real_name

	underwear = "None"
	undershirt = "None"
	socks = "None"
	faction |= "faithless"
	add_language(LANGUAGE_HIVE_SHADOWLING)
	set_species(/datum/species/shadow/ling)
	to_chat(src, span_shadowling("<b><i>Ваши силы пробудились. Теперь вы заживёте в полную меру. Помните свои цели. Сотрудничайте со своими союзниками и рабами.</b></i>"))

	ExtinguishMob()
	set_nutrition(NUTRITION_LEVEL_FED)
	mind.AddSpell(new /datum/action/cooldown/spell/pointed/shadowling_enthrall)
	mind.AddSpell(new /datum/action/cooldown/spell/aoe/shadowling_glare)
	mind.AddSpell(new /datum/action/cooldown/spell/aoe/shadowling_veil)
	mind.AddSpell(new /datum/action/cooldown/spell/jaunt/ethereal_jaunt/shadowling_shadow_walk)
	mind.AddSpell(new /datum/action/cooldown/spell/aoe/shadowling_icy_veins)
	mind.AddSpell(new /datum/action/cooldown/spell/shadowling_regen_armor)
	mind.AddSpell(new /datum/action/cooldown/spell/aoe/shadowling_screech)
	mind.AddSpell(new /datum/action/cooldown/spell/shadowling_blindness_smoke/)
	mind.AddSpell(new /datum/action/cooldown/spell/pointed/shadowling_revive_thrall)
	mind.AddSpell(new /datum/action/cooldown/spell/shadowling_ascend)

	mind.special_role = SPECIAL_ROLE_SHADOWLING
	SSticker.mode.shadows += mind
	SSticker.mode.update_shadow_icons_added(mind)

