/datum/action/cooldown/spell/pointed/manse_link
	name = "Связь Обители"
	desc = "Это заклинание позволяет вам соединять разумы с другими существами. \
			Все разумы, подключенные к вашей связи, смогут \
			незаметно общаться на больших расстояниях."
	background_icon = 'icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_heretic"
	overlay_icon_state = "bg_heretic_border"
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "mansus_link"
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

	school = SCHOOL_FORBIDDEN
	cooldown_time = 20 SECONDS

	invocation = "Р'СКР'Й СВ'Й Р'З'М"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	/// The time it takes to link to a mob.
	var/link_time = 6 SECONDS
	/// The mind_linker component that created us. `owner` is the CASTER mob, not the component.
	var/datum/component/mind_linker/linker


/datum/action/cooldown/spell/pointed/manse_link/New(Target)
	. = ..()
	if(isnull(Target)) // instantiated bare (e.g. unit tests) — the linker will never be set, but don't runtime
		return
	if(!istype(Target, /datum/component/mind_linker))
		stack_trace("[name] ([type]) was instantiated on a non-mind_linker target, this doesn't work.")
		return
	linker = Target


/datum/action/cooldown/spell/pointed/manse_link/Destroy(force)
	linker = null
	return ..()


/datum/action/cooldown/spell/pointed/manse_link/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	return isliving(cast_on)


/datum/action/cooldown/spell/pointed/manse_link/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	if(!isliving(cast_on))
		return SPELL_CANCEL_CAST

	if(!do_linking(cast_on))
		return . | SPELL_CANCEL_CAST


/// Links linkee to our network.
/datum/action/cooldown/spell/pointed/manse_link/proc/do_linking(mob/living/linkee)
	var/mob/living/caster = owner
	if(QDELETED(linker) || QDELETED(caster))
		return FALSE

	if(linkee.stat == DEAD)
		to_chat(caster, span_warning("[GEND_HE_SHE_CAP(linkee)] [GEND_MERTV(linkee)]!"))
		return FALSE

	to_chat(caster, span_notice("Вы начинаете соединять разум [linkee.declent_ru(GENITIVE)] с вашим..."))
	to_chat(linkee, span_warning("Вы чувствуете, как ваш разум куда-то тянется... соединяется... переплетается с самой тканью реальности..."))

	if(!do_after(caster, link_time, linkee, cog_icon = null))
		to_chat(caster, span_warning("Вы не смогли соединиться с разумом [linkee.declent_ru(GENITIVE)]."))
		to_chat(linkee, span_warning("Чужое присутствие покидает ваш разум."))
		return FALSE

	if(QDELETED(src) || QDELETED(caster) || QDELETED(linkee))
		return FALSE

	if(linker.link_mob(linkee))
		return TRUE

	to_chat(caster, span_warning("Похоже, вы не можете подключиться к разуму [linkee.declent_ru(GENITIVE)]."))
	to_chat(linkee, span_warning("Нечто чужеродное покидает ваш разум."))
	return FALSE
