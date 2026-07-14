/obj/item/codex_cicatrix
	name = "Кодекс Истязания"
	desc = "Этот увесистый том полон загадочных каракулей и невероятных схем. \
			Согласно легендам, если его расшифровать, можно раскрыть тайны завесы между мирами."
	gender = MALE
	icon = 'icons/obj/eldritch.dmi'
	base_icon_state = "book"
	icon_state = "book"
	item_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	/// Helps determine the icon state of this item when it's used on self.
	var/book_open = FALSE
	/// How fast we can drain influences
	var/drain_speed = 10 SECONDS
	/// How fast we can draw runes
	var/draw_speed = 15 SECONDS


/obj/item/codex_cicatrix/get_ru_names()
	return alist(
		NOMINATIVE = "Кодекс Истязания",
		GENITIVE = "Кодекса Истязания",
		DATIVE = "Кодексу Истязания",
		ACCUSATIVE = "Кодекс Истязания",
		INSTRUMENTAL = "Кодексом Истязания",
		PREPOSITIONAL = "Кодексе Истязания",
	)


/obj/item/codex_cicatrix/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You remove %THEEFFECT.", \
		tip_text = "Стереть руну", \
		on_clear_callback = CALLBACK(src, PROC_REF(after_clear_rune)), \
		effects_we_clear = list(/obj/effect/decal/heretic_rune))


/// Callback for effect_remover component after a rune is deleted
/obj/item/codex_cicatrix/proc/after_clear_rune(obj/effect/target, mob/living/user)
	new /obj/effect/temp_visual/drawing_heretic_rune/fail(target.loc/*, target.greyscale_colors*/)


/// Explicitly wipes a transmutation rune (matches the Mansus Grasp). master220's attack chain routes /obj
/// effects unreliably, so the codex erases the rune directly here to work on both left- and right-click.
/obj/item/codex_cicatrix/proc/erase_rune(obj/effect/decal/heretic_rune/rune, mob/living/user)
	to_chat(user, span_notice("Вы стираете [rune.declent_ru(ACCUSATIVE)]."))
	after_clear_rune(rune, user)
	qdel(rune)


/obj/item/codex_cicatrix/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return

	. += span_notice("Может использоваться для поглощения расколов реальности с целью получения дополнительных очков знаний.")
	. += span_notice("Также может быть использован для легкого рисования или удаления рун трансмутации.")
	. += span_notice("Кроме того, при нахождении в руках он может служить в качестве источника фокуса для ваших заклинаний.")


/obj/item/codex_cicatrix/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return

	if(book_open)
		close_animation()
		RemoveElement(/datum/element/heretic_focus)
		w_class = WEIGHT_CLASS_SMALL
		return

	open_animation()
	AddElement(/datum/element/heretic_focus)
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/codex_cicatrix/melee_attack_chain(mob/user, atom/target, params)
	if(isheretic(user))
		var/obj/effect/decal/heretic_rune/rune = istype(target, /obj/effect/decal/heretic_rune) \
			? target \
			: (locate(/obj/effect/decal/heretic_rune) in get_turf(target))
		if(rune && user.Adjacent(rune))
			erase_rune(rune, user)
			return ATTACK_CHAIN_BLOCKED

	var/obj/effect/heretic_influence/influence = locate(/obj/effect/heretic_influence) in target
	if(!isturf(target) && !influence)
		return ..()

	. = ..()
	var/datum/antagonist/heretic/heretic_datum = user.mind.has_antag_datum(/datum/antagonist/heretic)
	if(!heretic_datum)
		return ATTACK_CHAIN_BLOCKED

	if(influence?.drain_influence_with_codex(user, src))
		return ATTACK_CHAIN_BLOCKED

	heretic_datum.try_draw_rune(user, get_turf(target), drawing_time = draw_speed)
	return ATTACK_CHAIN_BLOCKED


/// Plays a little animation that shows the book opening and closing.
/obj/item/codex_cicatrix/proc/open_animation()
	icon_state = "[base_icon_state]_open"
	flick("[base_icon_state]_opening", src)
	book_open = TRUE


/// Plays a closing animation and resets the icon state.
/obj/item/codex_cicatrix/proc/close_animation()
	icon_state = base_icon_state
	flick("[base_icon_state]_closing", src)
	book_open = FALSE


/obj/item/codex_cicatrix/morbus
	name = "Кодекс Хвори"
	desc = "Ужасная, рваная книга, покрытая моргающими глазами. Вы понятия не имеете, как правильно держать её, \
			и, честно говоря, не уверены, стоит ли вообще."
	base_icon_state = "book_morbus"
	icon_state = "book_morbus"
	drain_speed = 7 SECONDS
	draw_speed = 10 SECONDS
	/// List of mobs we've cursed with transmutation. When the codex is destroyed all those curses become undone
	var/list/transmuted_victims = list()


/obj/item/codex_cicatrix/morbus/get_ru_names()
	return alist(
		NOMINATIVE = "Кодекс Хвори",
		GENITIVE = "Кодекса Хвори",
		DATIVE = "Кодексу Хвори",
		ACCUSATIVE = "Кодекс Хвори",
		INSTRUMENTAL = "Кодексом Хвори",
		PREPOSITIONAL = "Кодексе Хвори",
	)


/obj/item/codex_cicatrix/morbus/examine(mob/user)
	. = ..()
	if(isheretic(user))
		. += span_notice("Можно использовать для наложения проклятия через кровь в ваших руках, щелкнув правой кнопкой мыши по руне.")
		return

	. += span_danger("Глаза перестают моргать. Они пристально смотрят на вас. Их взгляд обжигает...")
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	to_chat(human_user, span_userdanger("Ваш разум горит, когда вы смотрите на страницы!"))
	human_user.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 10, 190)


/obj/item/codex_cicatrix/morbus/melee_attack_chain(mob/user, atom/interacting_with, params)
	if(!istype(interacting_with, /obj/effect/decal/heretic_rune) || !LAZYACCESS(params, RIGHT_CLICK))
		return ..()

	var/list/curse_list = list()
	for(var/datum/heretic_knowledge/curse/curses as anything in subtypesof(/datum/heretic_knowledge/curse))
		curse_list[curses.name] = curses

	var/selected_curse = tgui_input_list(user, "Наложие любое проклятие", "Выберите проклятие!", curse_list, timeout = 0)
	if(!selected_curse)
		return NONE

	if(!user.Adjacent(interacting_with))
		return NONE

	var/atom/held_offhand = user.get_inactive_hand()
	if(!held_offhand)
		user.balloon_alert(user, "нет крови!")
		return

	var/has_blood = LAZYLEN(held_offhand.blood_DNA)
	if(!has_blood)
		for(var/datum/reagent/blood/usable_reagent in held_offhand.reagents?.reagent_list)
			has_blood = TRUE
			break

	if(!has_blood)
		user.balloon_alert(user, "нет крови!")
		return ATTACK_CHAIN_BLOCKED

	var/curse_type = curse_list[selected_curse]
	var/datum/heretic_knowledge/curse/to_cast = new curse_type
	to_cast.recipe_snowflake_check(user, list(held_offhand), loc = get_turf(user))
	to_cast.on_finished_recipe(user, list(src, held_offhand), loc = get_turf(user))
	return ATTACK_CHAIN_SUCCESS


/obj/item/codex_cicatrix/morbus/Destroy()
	var/datum/heretic_knowledge/curse/transmutation/to_undo = new()
	for(var/datum/weakref/victim_ref as anything in transmuted_victims)
		var/mob/living/carbon/human/to_uncurse = victim_ref.resolve()
		if(!ishuman(to_uncurse))
			continue

		to_undo.uncurse(to_uncurse)

	transmuted_victims.Cut()
	return ..()
