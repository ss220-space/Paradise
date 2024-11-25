///////////////////Vanilla Morph////////////////////////////////////

/datum/dna/gene/basic/grant_spell/morph
	name = "Morphism"
	desc = "Позволяет субъекту изменить свою внешность на внешность любого человека."
	spelltype = /obj/effect/proc_holder/spell/morph
	activation_messages = list("Вы чувствуете, что можете изменить свой внешний вид.")
	deactivation_messages = list("Вы больше не способны менять свой внешний вид.")
	instability = GENE_INSTABILITY_MINOR


/datum/dna/gene/basic/grant_spell/morph/New()
	..()
	block = GLOB.morphblock

/obj/effect/proc_holder/spell/morph
	name = "Morph"
	desc = "Играйтесь со своей внешностью как душе угодно!"
	base_cooldown = 3 MINUTES

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_morph"


/obj/effect/proc_holder/spell/morph/create_new_targeting()
	return new /datum/spell_targeting/self


/obj/effect/proc_holder/spell/morph/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return

	if(ismob(user.loc))
		balloon_alert(user, "невозможно в данный момент")
		return
	var/mob/living/carbon/human/M = user
	var/obj/item/organ/external/head/head_organ = M.get_organ(BODY_ZONE_HEAD)
	var/obj/item/organ/internal/eyes/eyes_organ = M.get_int_organ(/obj/item/organ/internal/eyes)

	var/new_gender = tgui_alert(user, "Пожалуйста, выберите пол.", "Создание персонажа", list("Мужчина", "Женщина"))
	if(new_gender)
		if(new_gender == "Мужчина")
			M.change_gender(MALE)
		else
			M.change_gender(FEMALE)

	if(eyes_organ)
		var/new_eyes = input("Пожалуйста, выберите цвет глаз.", "Создание персонажа", eyes_organ.eye_colour) as null|color
		if(new_eyes)
			M.change_eye_color(new_eyes)

	if(istype(head_organ))
		//Alt heads.
		if(head_organ.dna.species.bodyflags & HAS_ALT_HEADS)
			var/list/valid_alt_heads = M.generate_valid_alt_heads()
			var/new_alt_head = input("Пожалуйста, выберите другую форму головы.", "Создание персонажа", head_organ.alt_head) as null|anything in valid_alt_heads
			if(new_alt_head)
				M.change_alt_head(new_alt_head)

		// hair
		var/list/valid_hairstyles = M.generate_valid_hairstyles()
		var/new_style = input("Пожалуйста, выберите стиль прически.", "Создание персонажа", head_organ.h_style) as null|anything in valid_hairstyles

		// if new style selected (not cancel)
		if(new_style)
			M.change_hair(new_style)

		var/new_hair = input("Пожалуйста, выберите цвет волос.", "Создание персонажа", head_organ.hair_colour) as null|color
		if(new_hair)
			M.change_hair_color(new_hair)

		var/datum/sprite_accessory/hair_style = GLOB.hair_styles_public_list[head_organ.h_style]
		if(hair_style.secondary_theme && !hair_style.no_sec_colour)
			new_hair = input("Пожалуйста, выберите дополнительный цвет волос.", "Создание персонажа", head_organ.sec_hair_colour) as null|color
			if(new_hair)
				M.change_hair_color(new_hair, TRUE)

		// facial hair
		var/list/valid_facial_hairstyles = M.generate_valid_facial_hairstyles()
		new_style = input("Пожалуйста, выберите тип лицевой растительности.", "Создание персонажа", head_organ.f_style) as null|anything in valid_facial_hairstyles

		if(new_style)
			M.change_facial_hair(new_style)

		var/new_facial = input("Пожалуйста, выберите цвет лицевой растительности.", "Создание персонажа", head_organ.facial_colour) as null|color
		if(new_facial)
			M.change_facial_hair_color(new_facial)

		var/datum/sprite_accessory/facial_hair_style = GLOB.facial_hair_styles_list[head_organ.f_style]
		if(facial_hair_style.secondary_theme && !facial_hair_style.no_sec_colour)
			new_facial = input("Пожалуйста, выберите дополнительный цвет лицевой растительности.", "Создание персонажа", head_organ.sec_facial_colour) as null|color
			if(new_facial)
				M.change_facial_hair_color(new_facial, TRUE)

		//Head accessory.
		if(head_organ.dna.species.bodyflags & HAS_HEAD_ACCESSORY)
			var/list/valid_head_accessories = M.generate_valid_head_accessories()
			var/new_head_accessory = input("Пожалуйста, выберите стиль аксессуаров для головы.", "Создание персонажа", head_organ.ha_style) as null|anything in valid_head_accessories
			if(new_head_accessory)
				M.change_head_accessory(new_head_accessory)

			var/new_head_accessory_colour = input("Пожалуйста, выберите цвет аксессуаров для головы.", "Создание персонажа", head_organ.headacc_colour) as null|color
			if(new_head_accessory_colour)
				M.change_head_accessory_color(new_head_accessory_colour)

	//Body accessory.
	if((M.dna.species.tail && M.dna.species.bodyflags & (HAS_TAIL)) || (M.dna.species.wing && M.dna.species.bodyflags & (HAS_WING)))
		var/list/valid_body_accessories = M.generate_valid_body_accessories()
		if(valid_body_accessories.len > 1) //By default valid_body_accessories will always have at the very least a 'none' entry populating the list, even if the user's species is not present in any of the list items.
			var/new_body_accessory = input("Пожалуйста, выберите стиль аксессуаров для тела.", "Создание персонажа", M.body_accessory) as null|anything in valid_body_accessories
			if(new_body_accessory)
				M.change_body_accessory(new_body_accessory)

	if(istype(head_organ))
		//Head markings.
		if(M.dna.species.bodyflags & HAS_HEAD_MARKINGS)
			var/list/valid_head_markings = M.generate_valid_markings("head")
			var/new_marking = input("Пожалуйста, выберите стиль маркировки головы.", "Создание персонажа", M.m_styles["head"]) as null|anything in valid_head_markings
			if(new_marking)
				M.change_markings(new_marking, "head")

			var/new_marking_colour = input("Пожалуйста, выберите цвет маркировки головы.", "Создание персонажа", M.m_colours["head"]) as null|color
			if(new_marking_colour)
				M.change_marking_color(new_marking_colour, "head")

	//Body markings.
	if(M.dna.species.bodyflags & HAS_BODY_MARKINGS)
		var/list/valid_body_markings = M.generate_valid_markings("body")
		var/new_marking = input("Пожалуйста, выберите стиль маркировки тела.", "Создание персонажа", M.m_styles["body"]) as null|anything in valid_body_markings
		if(new_marking)
			M.change_markings(new_marking, "body")

		var/new_marking_colour = input("Пожалуйста, выберите цвет маркировки тела.", "Создание персонажа", M.m_colours["body"]) as null|color
		if(new_marking_colour)
			M.change_marking_color(new_marking_colour, "body")
	//Tail markings.
	if(M.dna.species.bodyflags & HAS_TAIL_MARKINGS)
		var/list/valid_tail_markings = M.generate_valid_markings("tail")
		var/new_marking = input("Пожалуйста, выберите стиль маркировки хвоста.", "Создание персонажа", M.m_styles["tail"]) as null|anything in valid_tail_markings
		if(new_marking)
			M.change_markings(new_marking, "tail")

		var/new_marking_colour = input("Пожалуйста, выберите цвет маркировки хвоста.", "Создание персонажа", M.m_colours["tail"]) as null|color
		if(new_marking_colour)
			M.change_marking_color(new_marking_colour, "tail")

	//Skin tone.
	if(M.dna.species.bodyflags & HAS_SKIN_TONE)
		var/new_tone = input("Пожалуйста, выберите уровень тона кожи: 1-220 (1=альбинос, 35=белый, 150=тёмный, 220=чёрный)", "Создание персонажа", M.s_tone) as null|text
		if(!new_tone)
			new_tone = 35
		else
			new_tone = 35 - max(min(round(text2num(new_tone)), 220), 1)
			M.change_skin_tone(new_tone)

	if(M.dna.species.bodyflags & HAS_ICON_SKIN_TONE)
		var/prompt = "Пожалуйста, выберите тон кожи: 1-[M.dna.species.icon_skin_tones.len] ("
		for(var/i = 1 to M.dna.species.icon_skin_tones.len)
			prompt += "[i] = [M.dna.species.icon_skin_tones[i]]"
			if(i != M.dna.species.icon_skin_tones.len)
				prompt += ", "
		prompt += ")"

		var/new_tone = input(prompt, "Создание персонажа", M.s_tone) as null|text
		if(!new_tone)
			new_tone = 0
		else
			new_tone = max(min(round(text2num(new_tone)), M.dna.species.icon_skin_tones.len), 1)
			M.change_skin_tone(new_tone)

	//Skin colour.
	if(M.dna.species.bodyflags & HAS_SKIN_COLOR)
		var/new_body_colour = input("Пожалуйста, выберите цвет тела.", "Создание персонажа", M.skin_colour) as null|color
		if(new_body_colour)
			M.change_skin_color(new_body_colour)

	M.update_dna()

	M.visible_message(span_notice("[M] трансформиру[pluralize_ru(M.gender, "ет", "ют")]ся, изменяя свой внешний вид!"),
					span_notice("Вы меняете свою внешность!"),
					span_warning("О боже!  Что это, чёрт возьми, было?  Звук был такой, будто плоть сплющивают, а кости перетирают, придавая им другую форму!"))


/datum/dna/gene/basic/grant_spell/remotetalk
	name = "Telepathy"
	activation_messages = list("Вы чувствуете, что можете проецировать свои мысли.")
	deactivation_messages = list("Вы больше не чувствуете, что можете проецировать свои мысли.")
	instability = GENE_INSTABILITY_MINOR
	spelltype = /obj/effect/proc_holder/spell/remotetalk


/datum/dna/gene/basic/grant_spell/remotetalk/New()
	..()
	block = GLOB.remotetalkblock


/datum/dna/gene/basic/grant_spell/remotetalk/activate(mob/living/mutant, flags)
	. = ..()
	var/datum/atom_hud/thoughts/hud = GLOB.huds[THOUGHTS_HUD]
	mutant.AddSpell(new /obj/effect/proc_holder/spell/mindscan(null))
	hud.manage_hud(mutant, THOUGHTS_HUD_PRECISE)


/datum/dna/gene/basic/grant_spell/remotetalk/deactivate(mob/living/mutant, flags)
	. = ..()
	var/datum/atom_hud/thoughts/hud = GLOB.huds[THOUGHTS_HUD]
	for(var/obj/effect/proc_holder/spell/mindscan/spell in mutant.mob_spell_list)
		mutant.RemoveSpell(spell)
	hud.manage_hud(mutant, THOUGHTS_HUD_DISPERSE)


/obj/effect/proc_holder/spell/remotetalk
	name = "Project Mind"
	desc = "Позвольте другим ощущать ваши мысли."
	base_cooldown = 0

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_project"

/obj/effect/proc_holder/spell/remotetalk/create_new_targeting()
	return new /datum/spell_targeting/telepathic


/obj/effect/proc_holder/spell/remotetalk/cast(list/targets, mob/living/carbon/human/user = usr)
	if(!ishuman(user))
		return
	if(user.mind?.miming) // Dont let mimes telepathically talk
		to_chat(user, span_warning("Вы не можете общаться, не нарушив свой обет молчания."))
		return
	for(var/mob/living/target in targets)
		var/datum/atom_hud/thoughts/hud = GLOB.huds[THOUGHTS_HUD]
		hud.manage_hud(target, THOUGHTS_HUD_PRECISE)
		user.thoughts_hud_set(TRUE)
		var/say = tgui_input_text(user, "Что вы хотите сказать?", "Project Mind")
		user.typing = FALSE

		if(!say || user.stat)
			hud.manage_hud(target, THOUGHTS_HUD_DISPERSE)
			user.thoughts_hud_set(FALSE)
			return

		user.thoughts_hud_set(TRUE, say_test(say))
		addtimer(CALLBACK(hud, TYPE_PROC_REF(/datum/atom_hud/thoughts/, manage_hud), target, THOUGHTS_HUD_DISPERSE), 3 SECONDS)
		say = strip_html(say)
		say = pencode_to_html(say, user, format = 0, fields = 0)
		log_say("(TPATH to [key_name(target)]) [say]", user)
		user.create_log(SAY_LOG, "Telepathically said '[say]' using [src]", target)

		if(target.dna?.GetSEState(GLOB.remotetalkblock))
			target.show_message(span_abductor("Вы слышите голос [user.real_name]: [say]"))

		else
			target.show_message(span_abductor("Вы слышите голос, который, кажется, эхом разносится по комнате: [say]"))

		user.show_message(span_abductor("Вы проецируете свой разум на [(target in user.get_visible_mobs()) ? target.name : "неизвестную сущность"]: [say]"))

		for(var/mob/dead/observer/G in GLOB.player_list)
			G.show_message(span_italics("Телепатическое сообщение от <b>[user]</b> ([ghost_follow_link(user, ghost=G)]) для <b>[target]</b> ([ghost_follow_link(target, ghost=G)]): [say]"))


/obj/effect/proc_holder/spell/mindscan
	name = "Scan Mind"
	desc = "Дайте людям возможность поделиться их мыслями!"
	base_cooldown = 45 SECONDS
	clothes_req = FALSE
	stat_allowed = CONSCIOUS
	action_icon_state = "genetic_mindscan"
	var/list/available_targets = list()


/obj/effect/proc_holder/spell/mindscan/create_new_targeting()
	return new /datum/spell_targeting/telepathic


/obj/effect/proc_holder/spell/mindscan/cast(list/targets, mob/user = usr)
	if(!ishuman(user))
		return
	for(var/mob/living/target in targets)
		var/datum/atom_hud/thoughts/hud = GLOB.huds[THOUGHTS_HUD]
		var/message = "Вы чувствуете, что ваш разум ненадолго расширяется... (Нажмите, чтобы отправить сообщение.)"
		if(target.dna?.GetSEState(GLOB.remotetalkblock))
			message = "Вы чувствуете, что [user.real_name] хочет что-то от вас услышать... (Нажмите здесь, чтобы спроецировать мысли.)"
		user.show_message(span_abductor("Вы предлагаете доступ в свой разум [(target in user.get_visible_mobs()) ? target.name : "неизвестной сущности"]."))
		target.show_message(span_abductor("<a href='byond://?src=[UID()];target=[target.UID()];user=[user.UID()]'>[message]</a>"))
		available_targets += target
		hud.manage_hud(target, THOUGHTS_HUD_PRECISE)
		addtimer(CALLBACK(src, PROC_REF(removeAvailability), target), 45 SECONDS)


/obj/effect/proc_holder/spell/mindscan/proc/removeAvailability(mob/living/target)
	if(target in available_targets)
		var/datum/atom_hud/thoughts/hud = GLOB.huds[THOUGHTS_HUD]
		available_targets -= target
		hud.manage_hud(target, THOUGHTS_HUD_DISPERSE)
		target.show_message(span_abductor("Вы чувствуете, как это ощущение исчезает..."))


/obj/effect/proc_holder/spell/mindscan/Topic(href, href_list)
	var/mob/living/user
	if(href_list["user"])
		user = locateUID(href_list["user"])

	if(href_list["target"])
		if(!user)
			return

		var/mob/living/target = locateUID(href_list["target"])
		if(!(target in available_targets))
			return

		target.thoughts_hud_set(TRUE)
		var/say = tgui_input_text(target, "Что вы хотите сказать?", "Scan Mind")
		target.typing = FALSE

		if(!say || target.stat)
			target.thoughts_hud_set(FALSE)
			return

		target.thoughts_hud_set(TRUE, say_test(say))
		say = strip_html(say)
		say = pencode_to_html(say, target, format = 0, fields = 0)
		user.create_log(SAY_LOG, "Telepathically responded '[say]' using [src]", target)
		log_say("(TPATH to [key_name(target)]) [say]", user)

		if(target.dna?.GetSEState(GLOB.remotetalkblock))
			target.show_message(span_abductor("Вы проецируете свой разум на [user.name]: [say]"))

		else
			target.show_message(span_abductor("Вы заполняете пространство в своих мыслях: [say]"))

		user.show_message(span_abductor("Вы слышите голос [target.name]: [say]"))

		for(var/mob/dead/observer/G in GLOB.player_list)
			G.show_message(span_italics("Телепатический ответ от <b>[target]</b> ([ghost_follow_link(target, ghost=G)]) для <b>[user]</b> ([ghost_follow_link(user, ghost=G)]): [say]"))


/obj/effect/proc_holder/spell/mindscan/Destroy()
	for(var/mob/living/target in available_targets)
		removeAvailability(target)
	return ..()


/datum/dna/gene/basic/grant_spell/remoteview
	name = "Remote Viewing"
	activation_messages = list("Ваш разум может видеть на расстоянии.")
	deactivation_messages = list("Ваш разум больше не может видеть издалека.")
	instability = GENE_INSTABILITY_MINOR
	spelltype = /obj/effect/proc_holder/spell/remoteview
	traits_to_add = list(TRAIT_OPEN_MIND)


/datum/dna/gene/basic/grant_spell/remoteview/New()
	..()
	block = GLOB.remoteviewblock


/obj/effect/proc_holder/spell/remoteview
	name = "Remote View"
	desc = "Следите за людьми с любого расстояния!"
	base_cooldown = 10 SECONDS

	clothes_req = FALSE
	stat_allowed = CONSCIOUS

	action_icon_state = "genetic_view"


/obj/effect/proc_holder/spell/remoteview/create_new_targeting()
	return new /datum/spell_targeting/remoteview


/obj/effect/proc_holder/spell/remoteview/cast(list/targets, mob/user = usr)
	var/mob/living/carbon/human/H
	if(ishuman(user))
		H = user
	else
		return

	var/mob/target

	if(istype(H.l_hand, /obj/item/tk_grab) || istype(H.r_hand, /obj/item/tk_grab))
		balloon_alert(H, "разум занят")
		H.remoteview_target = null
		H.reset_perspective()
		return

	if(H.client.eye != user.client.mob)
		H.remoteview_target = null
		H.reset_perspective()
		return

	for(var/mob/living/L in targets)
		target = L

	if(target)
		H.remoteview_target = target
		H.reset_perspective(target)
	else
		H.remoteview_target = null
		H.reset_perspective()

