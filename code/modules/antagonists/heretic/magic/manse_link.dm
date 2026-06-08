/obj/effect/proc_holder/spell/pointed/manse_link
	name = "Связь Мансуса"
	desc = "Это заклинание позволяет вам соединять разумы с другими существами. \
			Все разумы, подключенные к вашей связи, смогут \
			незаметно общаться на больших расстояниях."
	action_background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	action_icon = 'icons/mob/actions/actions_ecult.dmi'
	action_icon_state = "mansus_link"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	human_req = FALSE
	clothes_req = FALSE
	base_cooldown = 20 SECONDS

	invocation = "Р'СКР'Й СВ'Й Р'З'М"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	/// The time it takes to link to a mob.
	var/link_time = 6 SECONDS


/obj/effect/proc_holder/spell/pointed/manse_link/New(Target)
	. = ..()
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		qdel(src)


/obj/effect/proc_holder/spell/pointed/manse_link/valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	return isliving(cast_on)


/obj/effect/proc_holder/spell/pointed/manse_link/before_cast(list/targets)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	var/mob/living/cast_on = targets[1]
	if(!istype(cast_on))
		return SPELL_CANCEL_CAST

	// If we fail to link, cancel the spell.
	if(!do_linking(cast_on))
		return . | SPELL_CANCEL_CAST


/**
 * The actual process of linking [linkee] to our network.
 */
/obj/effect/proc_holder/spell/pointed/manse_link/proc/do_linking(mob/living/linkee)
	var/datum/component/mind_linker/linker = action.owner
	if(linkee.stat == DEAD)
		to_chat(action.owner, span_warning("[genderize_ru(linkee.gender, "Он мёртв", "Она мертва", "Оно мертво", "Они мертвы")]!"))
		return FALSE

	to_chat(action.owner, span_notice("Вы начинаете соединять разум [linkee.declent_ru(GENITIVE)] с вашим..."))
	to_chat(linkee, span_warning("Вы чувствуете, как ваш разум куда-то тянется... соединяется... переплетается с самой тканью реальности..."))

	if(!do_after(action.owner, link_time, linkee))
		to_chat(action.owner, span_warning("Вы не смогли соединиться с разумом [linkee.declent_ru(GENITIVE)]."))
		to_chat(linkee, span_warning("Чужое присутствие покидает ваш разум."))
		return FALSE

	if(QDELETED(src) || QDELETED(action.owner) || QDELETED(linkee))
		return FALSE

	if(linker.link_mob(linkee))
		return TRUE

	to_chat(action.owner, span_warning("Похоже, вы не можете подключиться к разуму [linkee.declent_ru(GENITIVE)]."))
	to_chat(linkee, span_warning("Нечто чужеродное покидает ваш разум."))
	return FALSE
