// Ye old forbidden book, the Кодекс Истезания.
/obj/item/codex_cicatrix
	name = "Кодекс Истезания"
	ru_names = list(
		NOMINATIVE = "Кодекс Истезания",
		GENITIVE = "Кодекса Истезания",
		DATIVE = "Кодексу Истезания",
		ACCUSATIVE = "Кодекс Истезания",
		INSTRUMENTAL = "Кодексом Истезания",
		PREPOSITIONAL = "Кодексе Истезания",
	)
	desc = "Этот увесистый том полон загадочных каракулей и невероятных схем. \
			Согласно легенде, его можно расшифровать, раскрыв тайны завесы между мирами."
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
	var/draw_speed = 8 SECONDS


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


/obj/item/codex_cicatrix/examine(mob/user)
	. = ..()
	if(!isheretic(user))
		return

	. += span_notice("Может использоваться для поглощения расколов реальности с целью получения дополнительных очков знаний.")
	. += span_notice("Также может быть использован для легкого рисования или удаления рун трансмутации.")
	. += span_notice("Кроме того, при удерживании в руках он может служить амулетом для ваших заклинаний.")


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


// Upgraded version of the Кодекс Истезания that allows us to cast curses
/obj/item/codex_cicatrix/morbus // I'm morbing all over
	name = "Кодекс Морбус"
	ru_names = list(
		NOMINATIVE = "Кодекс Морбус",
		GENITIVE = "Кодекса Морбус",
		DATIVE = "Кодексу Морбус",
		ACCUSATIVE = "Кодекс Морбус",
		INSTRUMENTAL = "Кодексом Морбус",
		PREPOSITIONAL = "Кодексе Морбус",
	)
	desc = "Ужасная, рваная книга, покрытая моргающими глазами. Вы понятия не имеете, как правильно держать её, \
			и, честно говоря, не уверены, стоит ли вообще."
	base_icon_state = "book_morbus"
	icon_state = "book_morbus"
	drain_speed = 7 SECONDS
	draw_speed = 5 SECONDS
	/// List of mobs we've cursed with transmutation. When the codex is destroyed all those curses become undone
	var/list/transmuted_victims = list()


/obj/item/codex_cicatrix/morbus/examine(mob/user)
	. = ..()
	if(isheretic(user))
		. += span_info("Можно использовать для наложения проклятия через кровь в ваших руках, щелкнув правой кнопкой мыши по руне.")
		return

	. += span_danger("Глаза перестают моргать. Они пристально смотрят на вас. Их взгляд обжигает...")
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/human_user = user
	to_chat(human_user, span_userdanger("Ваш разум горит, когда вы смотрите на страницы!"))
	human_user.adjustOrganLoss(INTERNAL_ORGAN_BRAIN, 10, 190)


/obj/item/codex_cicatrix/morbus/afterattack(atom/interacting_with, mob/living/user, proximity, modifiers, status)
	if(!modifiers["alt"])
		return ..()

	if(!istype(interacting_with, /obj/effect/decal/heretic_rune/big))
		return NONE

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

	var/blood_samples = list()
	//blood_samples[requirement.get_blood_dna_list()] = TRUE

	for(var/datum/reagent/blood/usable_reagent as anything in held_offhand.reagents?.reagent_list)
		if(!istype(usable_reagent, /datum/reagent/blood))
			continue

		blood_samples += usable_reagent.data["blood_DNA"]

	if(isnull(blood_samples))
		user.balloon_alert(user, "нет крови!")
		return ATTACK_CHAIN_BLOCKED

	var/curse_type = curse_list[selected_curse]
	var/datum/heretic_knowledge/curse/to_cast = new curse_type
	to_cast.recipe_snowflake_check(user, list(held_offhand), loc = get_turf(user))
	to_cast.on_finished_recipe(user, list(src, held_offhand), loc = get_turf(user))
	return ATTACK_CHAIN_SUCCESS


/obj/item/codex_cicatrix/morbus/Destroy()
	for(var/mob/to_uncurse as anything in transmuted_victims)
		if(!to_uncurse || !ismob(to_uncurse))
			continue

		var/datum/heretic_knowledge/curse/transmutation/to_undo = new()
		to_undo.uncurse(to_uncurse)
		transmuted_victims -= to_uncurse

	return ..()
