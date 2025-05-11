//In here: Hatch and Ascendance
GLOBAL_LIST_INIT(possibleShadowlingNames, list("U'ruan", "Y`shej", "Nex", "Hel-uae", "Noaey'gief", "Mii`mahza", "Amerziox", "Gyrg-mylin", "Kanet'pruunance", "Vigistaezian")) //Unpronouncable 2: electric boogalo)


/obj/effect/proc_holder/spell/shadowling_hatch
	name = "Hatch"
	desc = "Сбрасывает вашу маскировку."
	base_cooldown = 5 MINUTES
	clothes_req = FALSE
	action_icon_state = "hatch"
	var/cycles_unused = 0


/obj/effect/proc_holder/spell/shadowling_hatch/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_hatch/cast(list/targets, mob/living/carbon/human/user = usr)
	if(user.stat || !ishuman(user) || !user || !is_shadow(user) || isinspace(user))
		return

	if(!isturf(user.loc))
		revert_cast(user)
		to_chat(user, span_warning("Ты должен стоять на полу, чтобы раскрыться!"))
		return

	if(tgui_alert(user,"Ты уверен, что хочешь раскрыться? Ты не сможешь прервать это!", "Hatch", list("Yes", "No")) != "Yes")
		to_chat(user, span_warning("Ты решил не раскрываться сейчас."))
		revert_cast(user)
		return

	ADD_TRAIT(user, TRAIT_NO_TRANSFORM, UNIQUE_TRAIT_SOURCE(src))
	user.visible_message(span_warning("Вещи [user] неожиданно начали сползать. С них стикает обильное количество фиолетовой жижи, которая формируется вокруг них"), \
						span_shadowling("Ты сбрасываешь свою одежду, которая может помешать твоему вылуплению и начинаешь выделять смолу, которая защитит тебя."))
	user.Stun(35 SECONDS, TRUE)
	for(var/obj/item/item as anything in user.get_equipped_items(TRUE, TRUE))
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
						span_shadowling("Ты обвиваешься в хризалиду и начинаете извиваться внутри."))

	sleep(10 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message(span_boldwarning("Кожа на спине [user] начинает расслаиваться. Из дыр медленно показываются чёрные шипы."), \
						span_shadowling("Шипы пронзают твою спину. Когти разрывают твои пальцы. Ты чувствуешь мучительную боль, когда твоя истинная форма начинают проявляться."))

	sleep(9 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message(span_boldwarning("[user], кожа рвётся, налипая на стены вокруг [user.p_them()]."), \
						span_shadowling("Твоя фальшивая кожа отваливается. Ты начинаете рвать хрупкую мембрану, защищающую тебя.."))

	sleep(8 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/weapons/slash.ogg', 15, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(user, span_boldnotice("Ты рвешь и режешь."))


	sleep(1 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/weapons/slashmiss.ogg', 15, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(user, span_boldnotice("Хризалида осыпается перед тобой, как капли воды."))

	sleep(1 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/weapons/slice.ogg', 15, TRUE, SILENCED_SOUND_EXTRARANGE)
	to_chat(user, span_boldnotice("Ты освободился!"))

	sleep(1 SECONDS)
	if(QDELETED(user))
		return

	playsound(user.loc, 'sound/effects/ghost.ogg', 30, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	var/newNameId = pick(GLOB.possibleShadowlingNames)
	GLOB.possibleShadowlingNames.Remove(newNameId)
	user.real_name = newNameId
	user.name = user.real_name
	to_chat(user, span_mind_control("ТЫ ЖИВОЙ!!!"))
	user.remove_traits(list(TRAIT_NO_TRANSFORM, TRAIT_GODMODE), UNIQUE_TRAIT_SOURCE(src))

	for(var/obj/structure/alien/resin/wall/shadowling/resin in orange(user, 1))
		qdel(resin)

	for(var/obj/structure/alien/weeds/node/node in shadowturf)
		qdel(node)

	user.visible_message(span_warning("Хризалиду разрывает и из неё бъётся поток фиолетовой плоти и жидкости!"))
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

	to_chat(user, span_shadowling("<b><i>Твои силы пробудились. Теперь ты заживешь в полную меру. Помни свои цели. Сотрудничай со своими союзниками и рабами.</b></i>"))
	user.ExtinguishMob()
	user.set_nutrition(NUTRITION_LEVEL_FED + 50)
	//user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_vision(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_enthrall(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_glare(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_veil(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_shadow_walk(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_icy_veins(null))
	user.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_regen_armor(null))

	QDEL_NULL(user.hud_used)
	user.hud_used = new /datum/hud/human(user, ui_style2icon(user.client.prefs.UI_style), user.client.prefs.UI_style_color, user.client.prefs.UI_style_alpha)
	user.hud_used.show_hud(user.hud_used.hud_version)


/obj/effect/proc_holder/spell/shadowling_ascend
	name = "Ascend"
	desc = "Завершить свою истинную форму."
	base_cooldown = 5 MINUTES
	clothes_req = FALSE
	action_icon_state = "ascend"


/obj/effect/proc_holder/spell/shadowling_ascend/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/shadowling_ascend/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!shadowling_check(user))
		return

	if(tgui_alert(user, "Время завершить свою форму. Ты уверен?", "Ascend", list("Yes", "No")) != "Yes")
		to_chat(user, span_warning("Ты передумал завершать свою форму сейчас."))
		revert_cast(user)
		return

	ADD_TRAIT(user, TRAIT_NO_TRANSFORM, PERMANENT_TRANSFORMATION_TRAIT)
	user.visible_message(span_warning("[user] взмывает в воздух, красный свет бъёт из его глаз."), \
						span_shadowling("Ты взмываешь в воздух и ты готов к своей трансформации."))

	sleep(5 SECONDS)
	if(QDELETED(user))
		return

	user.visible_message(span_warning("Кожа [user] начинает трескаться и становится твержё."), \
						span_shadowling("Твоя кожа становится твойм щитом."))

	sleep(10 SECONDS)
	if(QDELETED(user))
		return
	user.visible_message(span_warning("Рожки на голове [user] начинают расти."), \
						span_shadowling("Твоё тело начинает мутировать. Твои телепатические силы растут."))

	sleep(9 SECONDS)
	if(QDELETED(user))
		return
	user.visible_message(span_warning("Тело [user] начинает сильно растягиваться."), \
						span_shadowling("Ты разрушаешь последние врата к божественности."))

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
	for(var/obj/effect/proc_holder/spell/spell as anything in user.mind.spell_list)
		if(spell == src)
			continue
		user.mind.RemoveSpell(spell)

	user.mind.transfer_to(ascendant)
	ascendant.name = user.real_name
	ascendant.languages = user.languages
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/ascendant_annihilate(null))
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/ascendant_hypnosis(null))
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/ascendant_phase_shift(null))
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/ascendant_storm(null))
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/ascendant_transmit(null))
	ascendant.mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_revive_thrall/ascendant(null))

	if(ascendant.real_name)
		ascendant.real_name = user.real_name

	user.invisibility = INVISIBILITY_OBSERVER	//This is pretty bad, but is also necessary for the shuttle call to function properly
	user.forceMove(ascendant)

	sleep(5 SECONDS)
	if(QDELETED(user))
		return

	if(!SSticker.mode.shadowling_ascended)
		sleep(60 SECONDS)
		SSticker?.mode?.end_game()

	SSticker.mode.shadowling_ascended = TRUE
	ascendant.mind.RemoveSpell(src)
	qdel(user)



/**
 * Testing purpose.
 */
/mob/living/carbon/human/proc/make_unhatched_shadowling()
	for(var/obj/item/item as anything in get_equipped_items(TRUE, TRUE))
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
	to_chat(src, span_shadowling("<b><i>Твои силы пробудились. Теперь ты заживешь в полную меру. Помни свои цели. Сотрудничай со своими союзниками и рабами.</b></i>"))

	ExtinguishMob()
	set_nutrition(NUTRITION_LEVEL_FED + 50)
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_enthrall(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_glare(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_veil(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_shadow_walk(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_icy_veins(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_regen_armor(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/aoe/shadowling_screech(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_blindness_smoke(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_null_charge(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_revive_thrall(null))
	mind.AddSpell(new /obj/effect/proc_holder/spell/shadowling_ascend(null))

	mind.special_role = SPECIAL_ROLE_SHADOWLING
	SSticker.mode.shadows += mind
	SSticker.mode.update_shadow_icons_added(mind)

